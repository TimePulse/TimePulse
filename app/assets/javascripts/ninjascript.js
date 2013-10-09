/*
 * NinjaScript - 0.10
 * written by and copyright 2010-2012 Judson Lester and Logical Reality Design
 * Licensed under the MIT license
 *
 * 03-18-2012
 */
/** vim: et:ts=4:sw=4:sts=4
 * @license RequireJS 0.24.0 Copyright (c) 2010-2011, The Dojo Foundation All Rights Reserved.
 * Available via the MIT or new BSD license.
 * see: http://github.com/jrburke/requirejs for details
 */
/*jslint strict: false, plusplus: false */
/*global window: false, navigator: false, document: false, importScripts: false,
 jQuery: false, clearInterval: false, setInterval: false, self: false,
 setTimeout: false, opera: false */

var require, define;
(function () {
    //Change this version number for each release.
    var version = "0.24.0",
        commentRegExp = /(\/\*([\s\S]*?)\*\/|\/\/(.*)$)/mg,
        cjsRequireRegExp = /require\(["']([^'"\s]+)["']\)/g,
        currDirRegExp = /^\.\//,
        jsSuffixRegExp = /\.js$/,
        ostring = Object.prototype.toString,
        ap = Array.prototype,
        aps = ap.slice,
        apsp = ap.splice,
        isBrowser = !!(typeof window !== "undefined" && navigator && document),
        isWebWorker = !isBrowser && typeof importScripts !== "undefined",
    //PS3 indicates loaded and complete, but need to wait for complete
    //specifically. Sequence is "loading", "loaded", execution,
    // then "complete". The UA check is unfortunate, but not sure how
    //to feature test w/o causing perf issues.
        readyRegExp = isBrowser && navigator.platform === 'PLAYSTATION 3' ?
            /^complete$/ : /^(complete|loaded)$/,
        defContextName = "_",
    //Oh the tragedy, detecting opera. See the usage of isOpera for reason.
        isOpera = typeof opera !== "undefined" && opera.toString() === "[object Opera]",
        reqWaitIdPrefix = "_r@@",
        empty = {},
        contexts = {},
        globalDefQueue = [],
        interactiveScript = null,
        isDone = false,
        useInteractive = false,
        req, cfg = {}, currentlyAddingScript, s, head, baseElement, scripts, script,
        src, subPath, mainScript, dataMain, i, scrollIntervalId, setReadyState, ctx;

    function isFunction(it) {
        return ostring.call(it) === "[object Function]";
    }

    function isArray(it) {
        return ostring.call(it) === "[object Array]";
    }

    /**
     * Simple function to mix in properties from source into target,
     * but only if target does not already have a property of the same name.
     * This is not robust in IE for transferring methods that match
     * Object.prototype names, but the uses of mixin here seem unlikely to
     * trigger a problem related to that.
     */
    function mixin(target, source, force) {
        for (var prop in source) {
            if (!(prop in empty) && (!(prop in target) || force)) {
                target[prop] = source[prop];
            }
        }
        return req;
    }

    /**
     * Used to set up package paths from a packagePaths or packages config object.
     * @param {Object} pkgs the object to store the new package config
     * @param {Array} currentPackages an array of packages to configure
     * @param {String} [dir] a prefix dir to use.
     */
    function configurePackageDir(pkgs, currentPackages, dir) {
        var i, location, pkgObj;

        for (i = 0; (pkgObj = currentPackages[i]); i++) {
            pkgObj = typeof pkgObj === "string" ? { name: pkgObj } : pkgObj;
            location = pkgObj.location;

            //Add dir to the path, but avoid paths that start with a slash
            //or have a colon (indicates a protocol)
            if (dir && (!location || (location.indexOf("/") !== 0 && location.indexOf(":") === -1))) {
                location = dir + "/" + (location || pkgObj.name);
            }

            //Create a brand new object on pkgs, since currentPackages can
            //be passed in again, and config.pkgs is the internal transformed
            //state for all package configs.
            pkgs[pkgObj.name] = {
                name: pkgObj.name,
                location: location || pkgObj.name,
                lib: pkgObj.lib || "lib",
                //Remove leading dot in main, so main paths are normalized,
                //and remove any trailing .js, since different package
                //envs have different conventions: some use a module name,
                //some use a file name.
                main: (pkgObj.main || "lib/main")
                    .replace(currDirRegExp, '')
                    .replace(jsSuffixRegExp, '')
            };
        }
    }

    //Check for an existing version of require. If so, then exit out. Only allow
    //one version of require to be active in a page. However, allow for a require
    //config object, just exit quickly if require is an actual function.
    if (typeof require !== "undefined") {
        if (isFunction(require)) {
            return;
        } else {
            //assume it is a config object.
            cfg = require;
        }
    }

    /**
     * Creates a new context for use in require and define calls.
     * Handle most of the heavy lifting. Do not want to use an object
     * with prototype here to avoid using "this" in require, in case it
     * needs to be used in more super secure envs that do not want this.
     * Also there should not be that many contexts in the page. Usually just
     * one for the default context, but could be extra for multiversion cases
     * or if a package needs a special context for a dependency that conflicts
     * with the standard context.
     */
    function newContext(contextName) {
        var context, resume,
            config = {
                waitSeconds: 7,
                baseUrl: s.baseUrl || "./",
                paths: {},
                pkgs: {}
            },
            defQueue = [],
            specified = {
                "require": true,
                "exports": true,
                "module": true
            },
            urlMap = {},
            defined = {},
            loaded = {},
            waiting = {},
            waitAry = [],
            waitIdCounter = 0,
            managerCallbacks = {},
            plugins = {},
            pluginsQueue = {},
            resumeDepth = 0,
            normalizedWaiting = {};

        /**
         * Trims the . and .. from an array of path segments.
         * It will keep a leading path segment if a .. will become
         * the first path segment, to help with module name lookups,
         * which act like paths, but can be remapped. But the end result,
         * all paths that use this function should look normalized.
         * NOTE: this method MODIFIES the input array.
         * @param {Array} ary the array of path segments.
         */
        function trimDots(ary) {
            var i, part;
            for (i = 0; (part = ary[i]); i++) {
                if (part === ".") {
                    ary.splice(i, 1);
                    i -= 1;
                } else if (part === "..") {
                    if (i === 1 && (ary[2] === '..' || ary[0] === '..')) {
                        //End of the line. Keep at least one non-dot
                        //path segment at the front so it can be mapped
                        //correctly to disk. Otherwise, there is likely
                        //no path mapping for a path starting with '..'.
                        //This can still fail, but catches the most reasonable
                        //uses of ..
                        break;
                    } else if (i > 0) {
                        ary.splice(i - 1, 2);
                        i -= 2;
                    }
                }
            }
        }

        /**
         * Given a relative module name, like ./something, normalize it to
         * a real name that can be mapped to a path.
         * @param {String} name the relative name
         * @param {String} baseName a real name that the name arg is relative
         * to.
         * @returns {String} normalized name
         */
        function normalize(name, baseName) {
            var pkgName, pkgConfig;

            //Adjust any relative paths.
            if (name.charAt(0) === ".") {
                //If have a base name, try to normalize against it,
                //otherwise, assume it is a top-level require that will
                //be relative to baseUrl in the end.
                if (baseName) {
                    if (config.pkgs[baseName]) {
                        //If the baseName is a package name, then just treat it as one
                        //name to concat the name with.
                        baseName = [baseName];
                    } else {
                        //Convert baseName to array, and lop off the last part,
                        //so that . matches that "directory" and not name of the baseName's
                        //module. For instance, baseName of "one/two/three", maps to
                        //"one/two/three.js", but we want the directory, "one/two" for
                        //this normalization.
                        baseName = baseName.split("/");
                        baseName = baseName.slice(0, baseName.length - 1);
                    }

                    name = baseName.concat(name.split("/"));
                    trimDots(name);

                    //Some use of packages may use a . path to reference the
                    //"main" module name, so normalize for that.
                    pkgConfig = config.pkgs[(pkgName = name[0])];
                    name = name.join("/");
                    if (pkgConfig && name === pkgName + '/' + pkgConfig.main) {
                        name = pkgName;
                    }
                }
            }
            return name;
        }

        /**
         * Creates a module mapping that includes plugin prefix, module
         * name, and path. If parentModuleMap is provided it will
         * also normalize the name via require.normalize()
         *
         * @param {String} name the module name
         * @param {String} [parentModuleMap] parent module map
         * for the module name, used to resolve relative names.
         *
         * @returns {Object}
         */
        function makeModuleMap(name, parentModuleMap) {
            var index = name ? name.indexOf("!") : -1,
                prefix = null,
                parentName = parentModuleMap ? parentModuleMap.name : null,
                originalName = name,
                normalizedName, url, pluginModule;

            if (index !== -1) {
                prefix = name.substring(0, index);
                name = name.substring(index + 1, name.length);
            }

            if (prefix) {
                prefix = normalize(prefix, parentName);
            }

            //Account for relative paths if there is a base name.
            if (name) {
                if (prefix) {
                    pluginModule = defined[prefix];
                    if (pluginModule) {
                        //Plugin is loaded, use its normalize method, otherwise,
                        //normalize name as usual.
                        if (pluginModule.normalize) {
                            normalizedName = pluginModule.normalize(name, function (name) {
                                return normalize(name, parentName);
                            });
                        } else {
                            normalizedName = normalize(name, parentName);
                        }
                    } else {
                        //Plugin is not loaded yet, so do not normalize
                        //the name, wait for plugin to load to see if
                        //it has a normalize method. To avoid possible
                        //ambiguity with relative names loaded from another
                        //plugin, use the parent's name as part of this name.
                        normalizedName = '__$p' + parentName + '@' + name;
                    }
                } else {
                    normalizedName = normalize(name, parentName);
                }

                url = urlMap[normalizedName];
                if (!url) {
                    //Calculate url for the module, if it has a name.
                    if (req.toModuleUrl) {
                        //Special logic required for a particular engine,
                        //like Node.
                        url = req.toModuleUrl(context, name, parentModuleMap);
                    } else {
                        url = context.nameToUrl(name, null, parentModuleMap);
                    }

                    //Store the URL mapping for later.
                    urlMap[normalizedName] = url;
                }
            }

            return {
                prefix: prefix,
                name: normalizedName,
                parentMap: parentModuleMap,
                url: url,
                originalName: originalName,
                fullName: prefix ? prefix + "!" + normalizedName : normalizedName
            };
        }

        /**
         * Determine if priority loading is done. If so clear the priorityWait
         */
        function isPriorityDone() {
            var priorityDone = true,
                priorityWait = config.priorityWait,
                priorityName, i;
            if (priorityWait) {
                for (i = 0; (priorityName = priorityWait[i]); i++) {
                    if (!loaded[priorityName]) {
                        priorityDone = false;
                        break;
                    }
                }
                if (priorityDone) {
                    delete config.priorityWait;
                }
            }
            return priorityDone;
        }

        /**
         * Helper function that creates a setExports function for a "module"
         * CommonJS dependency. Do this here to avoid creating a closure that
         * is part of a loop.
         */
        function makeSetExports(moduleObj) {
            return function (exports) {
                moduleObj.exports = exports;
            };
        }

        function makeContextModuleFunc(func, relModuleMap, enableBuildCallback) {
            return function () {
                //A version of a require function that passes a moduleName
                //value for items that may need to
                //look up paths relative to the moduleName
                var args = [].concat(aps.call(arguments, 0)), lastArg;
                if (enableBuildCallback &&
                    isFunction((lastArg = args[args.length - 1]))) {
                    lastArg.__requireJsBuild = true;
                }
                args.push(relModuleMap);
                return func.apply(null, args);
            };
        }

        /**
         * Helper function that creates a require function object to give to
         * modules that ask for it as a dependency. It needs to be specific
         * per module because of the implication of path mappings that may
         * need to be relative to the module name.
         */
        function makeRequire(relModuleMap, enableBuildCallback) {
            var modRequire = makeContextModuleFunc(context.require, relModuleMap, enableBuildCallback);

            mixin(modRequire, {
                nameToUrl: makeContextModuleFunc(context.nameToUrl, relModuleMap),
                toUrl: makeContextModuleFunc(context.toUrl, relModuleMap),
                isDefined: makeContextModuleFunc(context.isDefined, relModuleMap),
                ready: req.ready,
                isBrowser: req.isBrowser
            });
            //Something used by node.
            if (req.paths) {
                modRequire.paths = req.paths;
            }
            return modRequire;
        }

        /**
         * Used to update the normalized name for plugin-based dependencies
         * after a plugin loads, since it can have its own normalization structure.
         * @param {String} pluginName the normalized plugin module name.
         */
        function updateNormalizedNames(pluginName) {

            var oldFullName, oldModuleMap, moduleMap, fullName, callbacks,
                i, j, k, depArray, existingCallbacks,
                maps = normalizedWaiting[pluginName];

            if (maps) {
                for (i = 0; (oldModuleMap = maps[i]); i++) {
                    oldFullName = oldModuleMap.fullName;
                    moduleMap = makeModuleMap(oldModuleMap.originalName, oldModuleMap.parentMap);
                    fullName = moduleMap.fullName;
                    //Callbacks could be undefined if the same plugin!name was
                    //required twice in a row, so use empty array in that case.
                    callbacks = managerCallbacks[oldFullName] || [];
                    existingCallbacks = managerCallbacks[fullName];

                    if (fullName !== oldFullName) {
                        //Update the specified object, but only if it is already
                        //in there. In sync environments, it may not be yet.
                        if (oldFullName in specified) {
                            delete specified[oldFullName];
                            specified[fullName] = true;
                        }

                        //Update managerCallbacks to use the correct normalized name.
                        //If there are already callbacks for the normalized name,
                        //just add to them.
                        if (existingCallbacks) {
                            managerCallbacks[fullName] = existingCallbacks.concat(callbacks);
                        } else {
                            managerCallbacks[fullName] = callbacks;
                        }
                        delete managerCallbacks[oldFullName];

                        //In each manager callback, update the normalized name in the depArray.
                        for (j = 0; j < callbacks.length; j++) {
                            depArray = callbacks[j].depArray;
                            for (k = 0; k < depArray.length; k++) {
                                if (depArray[k] === oldFullName) {
                                    depArray[k] = fullName;
                                }
                            }
                        }
                    }
                }
            }

            delete normalizedWaiting[pluginName];
        }

        /*
         * Queues a dependency for checking after the loader is out of a
         * "paused" state, for example while a script file is being loaded
         * in the browser, where it may have many modules defined in it.
         *
         * depName will be fully qualified, no relative . or .. path.
         */
        function queueDependency(dep) {
            //Make sure to load any plugin and associate the dependency
            //with that plugin.
            var prefix = dep.prefix,
                fullName = dep.fullName;

            //Do not bother if the depName is already in transit
            if (specified[fullName] || fullName in defined) {
                return;
            }

            if (prefix && !plugins[prefix]) {
                //Queue up loading of the dependency, track it
                //via context.plugins. Mark it as a plugin so
                //that the build system will know to treat it
                //special.
                plugins[prefix] = undefined;

                //Remember this dep that needs to have normaliztion done
                //after the plugin loads.
                (normalizedWaiting[prefix] || (normalizedWaiting[prefix] = []))
                    .push(dep);

                //Register an action to do once the plugin loads, to update
                //all managerCallbacks to use a properly normalized module
                //name.
                (managerCallbacks[prefix] ||
                    (managerCallbacks[prefix] = [])).push({
                    onDep: function (name, value) {
                        if (name === prefix) {
                            updateNormalizedNames(prefix);
                        }
                    }
                });

                queueDependency(makeModuleMap(prefix));
            }

            context.paused.push(dep);
        }

        function execManager(manager) {
            var i, ret, waitingCallbacks,
                cb = manager.callback,
                fullName = manager.fullName,
                args = [],
                ary = manager.depArray;

            //Call the callback to define the module, if necessary.
            if (cb && isFunction(cb)) {
                //Pull out the defined dependencies and pass the ordered
                //values to the callback.
                if (ary) {
                    for (i = 0; i < ary.length; i++) {
                        args.push(manager.deps[ary[i]]);
                    }
                }

                ret = req.execCb(fullName, manager.callback, args);

                if (fullName) {
                    //If using exports and the function did not return a value,
                    //and the "module" object for this definition function did not
                    //define an exported value, then use the exports object.
                    if (manager.usingExports && ret === undefined && (!manager.cjsModule || !("exports" in manager.cjsModule))) {
                        ret = defined[fullName];
                    } else {
                        if (manager.cjsModule && "exports" in manager.cjsModule) {
                            ret = defined[fullName] = manager.cjsModule.exports;
                        } else {
                            if (fullName in defined && !manager.usingExports) {
                                return req.onError(new Error(fullName + " has already been defined"));
                            }
                            defined[fullName] = ret;
                        }
                    }
                }
            } else if (fullName) {
                //May just be an object definition for the module. Only
                //worry about defining if have a module name.
                ret = defined[fullName] = cb;
            }

            if (fullName) {
                //If anything was waiting for this module to be defined,
                //notify them now.
                waitingCallbacks = managerCallbacks[fullName];
                if (waitingCallbacks) {
                    for (i = 0; i < waitingCallbacks.length; i++) {
                        waitingCallbacks[i].onDep(fullName, ret);
                    }
                    delete managerCallbacks[fullName];
                }
            }

            //Clean up waiting.
            if (waiting[manager.waitId]) {
                delete waiting[manager.waitId];
                manager.isDone = true;
                context.waitCount -= 1;
                if (context.waitCount === 0) {
                    //Clear the wait array used for cycles.
                    waitAry = [];
                }
            }

            return undefined;
        }

        function main(inName, depArray, callback, relModuleMap) {
            var moduleMap = makeModuleMap(inName, relModuleMap),
                name = moduleMap.name,
                fullName = moduleMap.fullName,
                uniques = {},
                manager = {
                    //Use a wait ID because some entries are anon
                    //async require calls.
                    waitId: name || reqWaitIdPrefix + (waitIdCounter++),
                    depCount: 0,
                    depMax: 0,
                    prefix: moduleMap.prefix,
                    name: name,
                    fullName: fullName,
                    deps: {},
                    depArray: depArray,
                    callback: callback,
                    onDep: function (depName, value) {
                        if (!(depName in manager.deps)) {
                            manager.deps[depName] = value;
                            manager.depCount += 1;
                            if (manager.depCount === manager.depMax) {
                                //All done, execute!
                                execManager(manager);
                            }
                        }
                    }
                },
                i, depArg, depName, cjsMod;

            if (fullName) {
                //If module already defined for context, or already loaded,
                //then leave.
                if (fullName in defined || loaded[fullName] === true) {
                    return;
                }

                //Set specified/loaded here for modules that are also loaded
                //as part of a layer, where onScriptLoad is not fired
                //for those cases. Do this after the inline define and
                //dependency tracing is done.
                //Also check if auto-registry of jQuery needs to be skipped.
                specified[fullName] = true;
                loaded[fullName] = true;
                context.jQueryDef = (fullName === "jquery");
            }

            //Add the dependencies to the deps field, and register for callbacks
            //on the dependencies.
            for (i = 0; i < depArray.length; i++) {
                depArg = depArray[i];
                //There could be cases like in IE, where a trailing comma will
                //introduce a null dependency, so only treat a real dependency
                //value as a dependency.
                if (depArg) {
                    //Split the dependency name into plugin and name parts
                    depArg = makeModuleMap(depArg, (name ? moduleMap : relModuleMap));
                    depName = depArg.fullName;

                    //Fix the name in depArray to be just the name, since
                    //that is how it will be called back later.
                    depArray[i] = depName;

                    //Fast path CommonJS standard dependencies.
                    if (depName === "require") {
                        manager.deps[depName] = makeRequire(moduleMap);
                    } else if (depName === "exports") {
                        //CommonJS module spec 1.1
                        manager.deps[depName] = defined[fullName] = {};
                        manager.usingExports = true;
                    } else if (depName === "module") {
                        //CommonJS module spec 1.1
                        manager.cjsModule = cjsMod = manager.deps[depName] = {
                            id: name,
                            uri: name ? context.nameToUrl(name, null, relModuleMap) : undefined
                        };
                        cjsMod.setExports = makeSetExports(cjsMod);
                    } else if (depName in defined && !(depName in waiting)) {
                        //Module already defined, no need to wait for it.
                        manager.deps[depName] = defined[depName];
                    } else if (!uniques[depName]) {

                        //A dynamic dependency.
                        manager.depMax += 1;

                        queueDependency(depArg);

                        //Register to get notification when dependency loads.
                        (managerCallbacks[depName] ||
                            (managerCallbacks[depName] = [])).push(manager);

                        uniques[depName] = true;
                    }
                }
            }

            //Do not bother tracking the manager if it is all done.
            if (manager.depCount === manager.depMax) {
                //All done, execute!
                execManager(manager);
            } else {
                waiting[manager.waitId] = manager;
                waitAry.push(manager);
                context.waitCount += 1;
            }
        }

        /**
         * Convenience method to call main for a require.def call that was put on
         * hold in the defQueue.
         */
        function callDefMain(args) {
            main.apply(null, args);
            //Mark the module loaded. Must do it here in addition
            //to doing it in require.def in case a script does
            //not call require.def
            loaded[args[0]] = true;
        }

        /**
         * As of jQuery 1.4.3, it supports a readyWait property that will hold off
         * calling jQuery ready callbacks until all scripts are loaded. Be sure
         * to track it if readyWait is available. Also, since jQuery 1.4.3 does
         * not register as a module, need to do some global inference checking.
         * Even if it does register as a module, not guaranteed to be the precise
         * name of the global. If a jQuery is tracked for this context, then go
         * ahead and register it as a module too, if not already in process.
         */
        function jQueryCheck(jqCandidate) {
            if (!context.jQuery) {
                var $ = jqCandidate || (typeof jQuery !== "undefined" ? jQuery : null);
                if ($ && "readyWait" in $) {
                    context.jQuery = $;

                    //Manually create a "jquery" module entry if not one already
                    //or in process.
                    callDefMain(["jquery", [], function () {
                        return jQuery;
                    }]);

                    //Increment jQuery readyWait if ncecessary.
                    if (context.scriptCount) {
                        $.readyWait += 1;
                        context.jQueryIncremented = true;
                    }
                }
            }
        }

        function forceExec(manager, traced) {
            if (manager.isDone) {
                return undefined;
            }

            var fullName = manager.fullName,
                depArray = manager.depArray,
                depName, i;
            if (fullName) {
                if (traced[fullName]) {
                    return defined[fullName];
                }

                traced[fullName] = true;
            }

            //forceExec all of its dependencies.
            for (i = 0; i < depArray.length; i++) {
                //Some array members may be null, like if a trailing comma
                //IE, so do the explicit [i] access and check if it has a value.
                depName = depArray[i];
                if (depName) {
                    if (!manager.deps[depName] && waiting[depName]) {
                        manager.onDep(depName, forceExec(waiting[depName], traced));
                    }
                }
            }

            return fullName ? defined[fullName] : undefined;
        }

        /**
         * Checks if all modules for a context are loaded, and if so, evaluates the
         * new ones in right dependency order.
         *
         * @private
         */
        function checkLoaded() {
            var waitInterval = config.waitSeconds * 1000,
            //It is possible to disable the wait interval by using waitSeconds of 0.
                expired = waitInterval && (context.startTime + waitInterval) < new Date().getTime(),
                noLoads = "", hasLoadedProp = false, stillLoading = false, prop,
                err, manager;

            //If there are items still in the paused queue processing wait.
            //This is particularly important in the sync case where each paused
            //item is processed right away but there may be more waiting.
            if (context.pausedCount > 0) {
                return undefined;
            }

            //Determine if priority loading is done. If so clear the priority. If
            //not, then do not check
            if (config.priorityWait) {
                if (isPriorityDone()) {
                    //Call resume, since it could have
                    //some waiting dependencies to trace.
                    resume();
                } else {
                    return undefined;
                }
            }

            //See if anything is still in flight.
            for (prop in loaded) {
                if (!(prop in empty)) {
                    hasLoadedProp = true;
                    if (!loaded[prop]) {
                        if (expired) {
                            noLoads += prop + " ";
                        } else {
                            stillLoading = true;
                            break;
                        }
                    }
                }
            }

            //Check for exit conditions.
            if (!hasLoadedProp && !context.waitCount) {
                //If the loaded object had no items, then the rest of
                //the work below does not need to be done.
                return undefined;
            }
            if (expired && noLoads) {
                //If wait time expired, throw error of unloaded modules.
                err = new Error("require.js load timeout for modules: " + noLoads);
                err.requireType = "timeout";
                err.requireModules = noLoads;
                return req.onError(err);
            }
            if (stillLoading || context.scriptCount) {
                //Something is still waiting to load. Wait for it.
                if (isBrowser || isWebWorker) {
                    setTimeout(checkLoaded, 50);
                }
                return undefined;
            }

            //If still have items in the waiting cue, but all modules have
            //been loaded, then it means there are some circular dependencies
            //that need to be broken.
            //However, as a waiting thing is fired, then it can add items to
            //the waiting cue, and those items should not be fired yet, so
            //make sure to redo the checkLoaded call after breaking a single
            //cycle, if nothing else loaded then this logic will pick it up
            //again.
            if (context.waitCount) {
                //Cycle through the waitAry, and call items in sequence.
                for (i = 0; (manager = waitAry[i]); i++) {
                    forceExec(manager, {});
                }

                checkLoaded();
                return undefined;
            }

            //Check for DOM ready, and nothing is waiting across contexts.
            req.checkReadyState();

            return undefined;
        }

        function callPlugin(pluginName, dep) {
            var name = dep.name,
                fullName = dep.fullName,
                load;

            //Do not bother if plugin is already defined or being loaded.
            if (fullName in defined || fullName in loaded) {
                return;
            }

            if (!plugins[pluginName]) {
                plugins[pluginName] = defined[pluginName];
            }

            //Only set loaded to false for tracking if it has not already been set.
            if (!loaded[fullName]) {
                loaded[fullName] = false;
            }

            load = function (ret) {
                //Allow the build process to register plugin-loaded dependencies.
                if (require.onPluginLoad) {
                    require.onPluginLoad(context, pluginName, name, ret);
                }

                execManager({
                    prefix: dep.prefix,
                    name: dep.name,
                    fullName: dep.fullName,
                    callback: function () {
                        return ret;
                    }
                });
                loaded[fullName] = true;
            };

            //Allow plugins to load other code without having to know the
            //context or how to "complete" the load.
            load.fromText = function (moduleName, text) {
                /*jslint evil: true */
                var hasInteractive = useInteractive;

                //Indicate a the module is in process of loading.
                context.loaded[moduleName] = false;
                context.scriptCount += 1;

                //Turn off interactive script matching for IE for any define
                //calls in the text, then turn it back on at the end.
                if (hasInteractive) {
                    useInteractive = false;
                }
                eval(text);
                if (hasInteractive) {
                    useInteractive = true;
                }

                //Support anonymous modules.
                context.completeLoad(moduleName);
            };

            //Use parentName here since the plugin's name is not reliable,
            //could be some weird string with no path that actually wants to
            //reference the parentName's path.
            plugins[pluginName].load(name, makeRequire(dep.parentMap, true), load, config);
        }

        function loadPaused(dep) {
            //Renormalize dependency if its name was waiting on a plugin
            //to load, which as since loaded.
            if (dep.prefix && dep.name.indexOf('__$p') === 0 && defined[dep.prefix]) {
                dep = makeModuleMap(dep.originalName, dep.parentMap);
            }

            var pluginName = dep.prefix,
                fullName = dep.fullName;

            //Do not bother if the dependency has already been specified.
            if (specified[fullName] || loaded[fullName]) {
                return;
            } else {
                specified[fullName] = true;
            }

            if (pluginName) {
                //If plugin not loaded, wait for it.
                //set up callback list. if no list, then register
                //managerCallback for that plugin.
                if (defined[pluginName]) {
                    callPlugin(pluginName, dep);
                } else {
                    if (!pluginsQueue[pluginName]) {
                        pluginsQueue[pluginName] = [];
                        (managerCallbacks[pluginName] ||
                            (managerCallbacks[pluginName] = [])).push({
                            onDep: function (name, value) {
                                if (name === pluginName) {
                                    var i, oldModuleMap, ary = pluginsQueue[pluginName];

                                    //Now update all queued plugin actions.
                                    for (i = 0; i < ary.length; i++) {
                                        oldModuleMap = ary[i];
                                        //Update the moduleMap since the
                                        //module name may be normalized
                                        //differently now.
                                        callPlugin(pluginName,
                                            makeModuleMap(oldModuleMap.originalName, oldModuleMap.parentMap));
                                    }
                                    delete pluginsQueue[pluginName];
                                }
                            }
                        });
                    }
                    pluginsQueue[pluginName].push(dep);
                }
            } else {
                req.load(context, fullName, dep.url);
            }
        }

        /**
         * Resumes tracing of dependencies and then checks if everything is loaded.
         */
        resume = function () {
            var args, i, p;

            resumeDepth += 1;

            if (context.scriptCount <= 0) {
                //Synchronous envs will push the number below zero with the
                //decrement above, be sure to set it back to zero for good measure.
                //require() calls that also do not end up loading scripts could
                //push the number negative too.
                context.scriptCount = 0;
            }

            //Make sure any remaining defQueue items get properly processed.
            while (defQueue.length) {
                args = defQueue.shift();
                if (args[0] === null) {
                    return req.onError(new Error('Mismatched anonymous require.def modules'));
                } else {
                    callDefMain(args);
                }
            }

            //Skip the resume of paused dependencies
            //if current context is in priority wait.
            if (!config.priorityWait || isPriorityDone()) {
                while (context.paused.length) {
                    p = context.paused;
                    context.pausedCount += p.length;
                    //Reset paused list
                    context.paused = [];

                    for (i = 0; (args = p[i]); i++) {
                        loadPaused(args);
                    }
                    //Move the start time for timeout forward.
                    context.startTime = (new Date()).getTime();
                    context.pausedCount -= p.length;
                }
            }

            //Only check if loaded when resume depth is 1. It is likely that
            //it is only greater than 1 in sync environments where a factory
            //function also then calls the callback-style require. In those
            //cases, the checkLoaded should not occur until the resume
            //depth is back at the top level.
            if (resumeDepth === 1) {
                checkLoaded();
            }

            resumeDepth -= 1;

            return undefined;
        };

        //Define the context object. Many of these fields are on here
        //just to make debugging easier.
        context = {
            contextName: contextName,
            config: config,
            defQueue: defQueue,
            waiting: waiting,
            waitCount: 0,
            specified: specified,
            loaded: loaded,
            urlMap: urlMap,
            scriptCount: 0,
            urlFetched: {},
            defined: defined,
            paused: [],
            pausedCount: 0,
            plugins: plugins,
            managerCallbacks: managerCallbacks,
            makeModuleMap: makeModuleMap,
            normalize: normalize,
            /**
             * Set a configuration for the context.
             * @param {Object} cfg config object to integrate.
             */
            configure: function (cfg) {
                var paths, prop, packages, pkgs, packagePaths, requireWait;

                //Make sure the baseUrl ends in a slash.
                if (cfg.baseUrl) {
                    if (cfg.baseUrl.charAt(cfg.baseUrl.length - 1) !== "/") {
                        cfg.baseUrl += "/";
                    }
                }

                //Save off the paths and packages since they require special processing,
                //they are additive.
                paths = config.paths;
                packages = config.packages;
                pkgs = config.pkgs;

                //Mix in the config values, favoring the new values over
                //existing ones in context.config.
                mixin(config, cfg, true);

                //Adjust paths if necessary.
                if (cfg.paths) {
                    for (prop in cfg.paths) {
                        if (!(prop in empty)) {
                            paths[prop] = cfg.paths[prop];
                        }
                    }
                    config.paths = paths;
                }

                packagePaths = cfg.packagePaths;
                if (packagePaths || cfg.packages) {
                    //Convert packagePaths into a packages config.
                    if (packagePaths) {
                        for (prop in packagePaths) {
                            if (!(prop in empty)) {
                                configurePackageDir(pkgs, packagePaths[prop], prop);
                            }
                        }
                    }

                    //Adjust packages if necessary.
                    if (cfg.packages) {
                        configurePackageDir(pkgs, cfg.packages);
                    }

                    //Done with modifications, assing packages back to context config
                    config.pkgs = pkgs;
                }

                //If priority loading is in effect, trigger the loads now
                if (cfg.priority) {
                    //Hold on to requireWait value, and reset it after done
                    requireWait = context.requireWait;

                    //Allow tracing some require calls to allow the fetching
                    //of the priority config.
                    context.requireWait = false;

                    //But first, call resume to register any defined modules that may
                    //be in a data-main built file before the priority config
                    //call. Also grab any waiting define calls for this context.
                    context.takeGlobalQueue();
                    resume();

                    context.require(cfg.priority);

                    //Trigger a resume right away, for the case when
                    //the script with the priority load is done as part
                    //of a data-main call. In that case the normal resume
                    //call will not happen because the scriptCount will be
                    //at 1, since the script for data-main is being processed.
                    resume();

                    //Restore previous state.
                    context.requireWait = requireWait;
                    config.priorityWait = cfg.priority;
                }

                //If a deps array or a config callback is specified, then call
                //require with those args. This is useful when require is defined as a
                //config object before require.js is loaded.
                if (cfg.deps || cfg.callback) {
                    context.require(cfg.deps || [], cfg.callback);
                }

                //Set up ready callback, if asked. Useful when require is defined as a
                //config object before require.js is loaded.
                if (cfg.ready) {
                    req.ready(cfg.ready);
                }
            },

            isDefined: function (moduleName, relModuleMap) {
                return makeModuleMap(moduleName, relModuleMap).fullName in defined;
            },

            require: function (deps, callback, relModuleMap) {
                var moduleName, ret, moduleMap;
                if (typeof deps === "string") {
                    //Synchronous access to one module. If require.get is
                    //available (as in the Node adapter), prefer that.
                    //In this case deps is the moduleName and callback is
                    //the relModuleMap
                    if (req.get) {
                        return req.get(context, deps, callback);
                    }

                    //Just return the module wanted. In this scenario, the
                    //second arg (if passed) is just the relModuleMap.
                    moduleName = deps;
                    relModuleMap = callback;

                    //Normalize module name, if it contains . or ..
                    moduleMap = makeModuleMap(moduleName, relModuleMap);

                    ret = defined[moduleMap.fullName];
                    if (ret === undefined) {
                        return req.onError(new Error("require: module name '" +
                            moduleMap.fullName +
                            "' has not been loaded yet for context: " +
                            contextName));
                    }
                    return ret;
                }

                main(null, deps, callback, relModuleMap);

                //If the require call does not trigger anything new to load,
                //then resume the dependency processing.
                if (!context.requireWait) {
                    while (!context.scriptCount && context.paused.length) {
                        resume();
                    }
                }
                return undefined;
            },

            /**
             * Internal method to transfer globalQueue items to this context's
             * defQueue.
             */
            takeGlobalQueue: function () {
                //Push all the globalDefQueue items into the context's defQueue
                if (globalDefQueue.length) {
                    //Array splice in the values since the context code has a
                    //local var ref to defQueue, so cannot just reassign the one
                    //on context.
                    apsp.apply(context.defQueue,
                        [context.defQueue.length - 1, 0].concat(globalDefQueue));
                    globalDefQueue = [];
                }
            },

            /**
             * Internal method used by environment adapters to complete a load event.
             * A load event could be a script load or just a load pass from a synchronous
             * load call.
             * @param {String} moduleName the name of the module to potentially complete.
             */
            completeLoad: function (moduleName) {
                var args;

                context.takeGlobalQueue();

                while (defQueue.length) {
                    args = defQueue.shift();

                    if (args[0] === null) {
                        args[0] = moduleName;
                        break;
                    } else if (args[0] === moduleName) {
                        //Found matching require.def call for this script!
                        break;
                    } else {
                        //Some other named require.def call, most likely the result
                        //of a build layer that included many require.def calls.
                        callDefMain(args);
                        args = null;
                    }
                }
                if (args) {
                    callDefMain(args);
                } else {
                    //A script that does not call define(), so just simulate
                    //the call for it. Special exception for jQuery dynamic load.
                    callDefMain([moduleName, [],
                        moduleName === "jquery" && typeof jQuery !== "undefined" ?
                            function () {
                                return jQuery;
                            } : null]);
                }

                //Mark the script as loaded. Note that this can be different from a
                //moduleName that maps to a require.def call. This line is important
                //for traditional browser scripts.
                loaded[moduleName] = true;

                //If a global jQuery is defined, check for it. Need to do it here
                //instead of main() since stock jQuery does not register as
                //a module via define.
                jQueryCheck();

                //Doing this scriptCount decrement branching because sync envs
                //need to decrement after resume, otherwise it looks like
                //loading is complete after the first dependency is fetched.
                //For browsers, it works fine to decrement after, but it means
                //the checkLoaded setTimeout 50 ms cost is taken. To avoid
                //that cost, decrement beforehand.
                if (req.isAsync) {
                    context.scriptCount -= 1;
                }
                resume();
                if (!req.isAsync) {
                    context.scriptCount -= 1;
                }
            },

            /**
             * Converts a module name + .extension into an URL path.
             * *Requires* the use of a module name. It does not support using
             * plain URLs like nameToUrl.
             */
            toUrl: function (moduleNamePlusExt, relModuleMap) {
                var index = moduleNamePlusExt.lastIndexOf("."),
                    ext = null;

                if (index !== -1) {
                    ext = moduleNamePlusExt.substring(index, moduleNamePlusExt.length);
                    moduleNamePlusExt = moduleNamePlusExt.substring(0, index);
                }

                return context.nameToUrl(moduleNamePlusExt, ext, relModuleMap);
            },

            /**
             * Converts a module name to a file path. Supports cases where
             * moduleName may actually be just an URL.
             */
            nameToUrl: function (moduleName, ext, relModuleMap) {
                var paths, pkgs, pkg, pkgPath, syms, i, parentModule, url,
                    config = context.config;

                if (moduleName.indexOf("./") === 0 || moduleName.indexOf("../") === 0) {
                    //A relative ID, just map it relative to relModuleMap's url
                    syms = relModuleMap && relModuleMap.url ? relModuleMap.url.split('/') : [];
                    //Pop off the file name.
                    if (syms.length) {
                        syms.pop();
                    }
                    syms = syms.concat(moduleName.split('/'));
                    trimDots(syms);
                    url = syms.join('/') +
                        (ext ? ext :
                            (req.jsExtRegExp.test(moduleName) ? "" : ".js"));
                } else {

                    //Normalize module name if have a base relative module name to work from.
                    moduleName = normalize(moduleName, relModuleMap);

                    //If a colon is in the URL, it indicates a protocol is used and it is just
                    //an URL to a file, or if it starts with a slash or ends with .js, it is just a plain file.
                    //The slash is important for protocol-less URLs as well as full paths.
                    if (req.jsExtRegExp.test(moduleName)) {
                        //Just a plain path, not module name lookup, so just return it.
                        //Add extension if it is included. This is a bit wonky, only non-.js things pass
                        //an extension, this method probably needs to be reworked.
                        url = moduleName + (ext ? ext : "");
                    } else {
                        //A module that needs to be converted to a path.
                        paths = config.paths;
                        pkgs = config.pkgs;

                        syms = moduleName.split("/");
                        //For each module name segment, see if there is a path
                        //registered for it. Start with most specific name
                        //and work up from it.
                        for (i = syms.length; i > 0; i--) {
                            parentModule = syms.slice(0, i).join("/");
                            if (paths[parentModule]) {
                                syms.splice(0, i, paths[parentModule]);
                                break;
                            } else if ((pkg = pkgs[parentModule])) {
                                //If module name is just the package name, then looking
                                //for the main module.
                                if (moduleName === pkg.name) {
                                    pkgPath = pkg.location + '/' + pkg.main;
                                } else {
                                    pkgPath = pkg.location + '/' + pkg.lib;
                                }
                                syms.splice(0, i, pkgPath);
                                break;
                            }
                        }

                        //Join the path parts together, then figure out if baseUrl is needed.
                        url = syms.join("/") + (ext || ".js");
                        url = (url.charAt(0) === '/' || url.match(/^\w+:/) ? "" : config.baseUrl) + url;
                    }
                }

                return config.urlArgs ? url +
                    ((url.indexOf('?') === -1 ? '?' : '&') +
                        config.urlArgs) : url;
            }
        };

        //Make these visible on the context so can be called at the very
        //end of the file to bootstrap
        context.jQueryCheck = jQueryCheck;
        context.resume = resume;

        return context;
    }

    /**
     * Main entry point.
     *
     * If the only argument to require is a string, then the module that
     * is represented by that string is fetched for the appropriate context.
     *
     * If the first argument is an array, then it will be treated as an array
     * of dependency string names to fetch. An optional function callback can
     * be specified to execute when all of those dependencies are available.
     *
     * Make a local req variable to help Caja compliance (it assumes things
     * on a require that are not standardized), and to give a short
     * name for minification/local scope use.
     */
    req = require = function (deps, callback) {

        //Find the right context, use default
        var contextName = defContextName,
            context, config;

        // Determine if have config object in the call.
        if (!isArray(deps) && typeof deps !== "string") {
            // deps is a config object
            config = deps;
            if (isArray(callback)) {
                // Adjust args if there are dependencies
                deps = callback;
                callback = arguments[2];
            } else {
                deps = [];
            }
        }

        if (config && config.context) {
            contextName = config.context;
        }

        context = contexts[contextName] ||
            (contexts[contextName] = newContext(contextName));

        if (config) {
            context.configure(config);
        }

        return context.require(deps, callback);
    };

    req.version = version;
    req.isArray = isArray;
    req.isFunction = isFunction;
    req.mixin = mixin;
    //Used to filter out dependencies that are already paths.
    req.jsExtRegExp = /^\/|:|\?|\.js$/;
    s = req.s = {
        contexts: contexts,
        //Stores a list of URLs that should not get async script tag treatment.
        skipAsync: {},
        isPageLoaded: !isBrowser,
        readyCalls: []
    };

    req.isAsync = req.isBrowser = isBrowser;
    if (isBrowser) {
        head = s.head = document.getElementsByTagName("head")[0];
        //If BASE tag is in play, using appendChild is a problem for IE6.
        //When that browser dies, this can be removed. Details in this jQuery bug:
        //http://dev.jquery.com/ticket/2709
        baseElement = document.getElementsByTagName("base")[0];
        if (baseElement) {
            head = s.head = baseElement.parentNode;
        }
    }

    /**
     * Any errors that require explicitly generates will be passed to this
     * function. Intercept/override it if you want custom error handling.
     * @param {Error} err the error object.
     */
    req.onError = function (err) {
        throw err;
    };

    /**
     * Does the request to load a module for the browser case.
     * Make this a separate function to allow other environments
     * to override it.
     *
     * @param {Object} context the require context to find state.
     * @param {String} moduleName the name of the module.
     * @param {Object} url the URL to the module.
     */
    req.load = function (context, moduleName, url) {
        var contextName = context.contextName,
            urlFetched = context.urlFetched,
            loaded = context.loaded;
        isDone = false;

        //Only set loaded to false for tracking if it has not already been set.
        if (!loaded[moduleName]) {
            loaded[moduleName] = false;
        }

        if (!urlFetched[url]) {
            context.scriptCount += 1;
            req.attach(url, contextName, moduleName);
            urlFetched[url] = true;

            //If tracking a jQuery, then make sure its readyWait
            //is incremented to prevent its ready callbacks from
            //triggering too soon.
            if (context.jQuery && !context.jQueryIncremented) {
                context.jQuery.readyWait += 1;
                context.jQueryIncremented = true;
            }
        }
    };

    function getInteractiveScript() {
        var scripts, i, script;
        if (interactiveScript && interactiveScript.readyState === 'interactive') {
            return interactiveScript;
        }

        scripts = document.getElementsByTagName('script');
        for (i = scripts.length - 1; i > -1 && (script = scripts[i]); i--) {
            if (script.readyState === 'interactive') {
                return (interactiveScript = script);
            }
        }

        return null;
    }

    /**
     * The function that handles definitions of modules. Differs from
     * require() in that a string for the module should be the first argument,
     * and the function to execute after dependencies are loaded should
     * return a value to define the module corresponding to the first argument's
     * name.
     */
    define = req.def = function (name, deps, callback) {
        var node, context;

        //Allow for anonymous functions
        if (typeof name !== 'string') {
            //Adjust args appropriately
            callback = deps;
            deps = name;
            name = null;
        }

        //This module may not have dependencies
        if (!req.isArray(deps)) {
            callback = deps;
            deps = [];
        }

        //If no name, and callback is a function, then figure out if it a
        //CommonJS thing with dependencies.
        if (!name && !deps.length && req.isFunction(callback)) {
            //Remove comments from the callback string,
            //look for require calls, and pull them into the dependencies,
            //but only if there are function args.
            if (callback.length) {
                callback
                    .toString()
                    .replace(commentRegExp, "")
                    .replace(cjsRequireRegExp, function (match, dep) {
                        deps.push(dep);
                    });

                //May be a CommonJS thing even without require calls, but still
                //could use exports, and such, so always add those as dependencies.
                //This is a bit wasteful for RequireJS modules that do not need
                //an exports or module object, but erring on side of safety.
                //REQUIRES the function to expect the CommonJS variables in the
                //order listed below.
                deps = ["require", "exports", "module"].concat(deps);
            }
        }

        //If in IE 6-8 and hit an anonymous define() call, do the interactive
        //work.
        if (useInteractive) {
            node = currentlyAddingScript || getInteractiveScript();
            if (!node) {
                return req.onError(new Error("ERROR: No matching script interactive for " + callback));
            }
            if (!name) {
                name = node.getAttribute("data-requiremodule");
            }
            context = contexts[node.getAttribute("data-requirecontext")];
        }

        //Always save off evaluating the def call until the script onload handler.
        //This allows multiple modules to be in a file without prematurely
        //tracing dependencies, and allows for anonymous module support,
        //where the module name is not known until the script onload event
        //occurs. If no context, use the global queue, and get it processed
        //in the onscript load callback.
        (context ? context.defQueue : globalDefQueue).push([name, deps, callback]);

        return undefined;
    };

    define.amd = {
        multiversion: true,
        plugins: true
    };

    /**
     * Executes a module callack function. Broken out as a separate function
     * solely to allow the build system to sequence the files in the built
     * layer in the right sequence.
     *
     * @private
     */
    req.execCb = function (name, callback, args) {
        return callback.apply(null, args);
    };

    /**
     * callback for script loads, used to check status of loading.
     *
     * @param {Event} evt the event from the browser for the script
     * that was loaded.
     *
     * @private
     */
    req.onScriptLoad = function (evt) {
        //Using currentTarget instead of target for Firefox 2.0's sake. Not
        //all old browsers will be supported, but this one was easy enough
        //to support and still makes sense.
        var node = evt.currentTarget || evt.srcElement, contextName, moduleName,
            context;

        if (evt.type === "load" || readyRegExp.test(node.readyState)) {
            //Reset interactive script so a script node is not held onto for
            //to long.
            interactiveScript = null;

            //Pull out the name of the module and the context.
            contextName = node.getAttribute("data-requirecontext");
            moduleName = node.getAttribute("data-requiremodule");
            context = contexts[contextName];

            contexts[contextName].completeLoad(moduleName);

            //Clean up script binding. Favor detachEvent because of IE9
            //issue, see attachEvent/addEventListener comment elsewhere
            //in this file.
            if (node.detachEvent && !isOpera) {
                //Probably IE. If not it will throw an error, which will be
                //useful to know.
                node.detachEvent("onreadystatechange", req.onScriptLoad);
            } else {
                node.removeEventListener("load", req.onScriptLoad, false);
            }
        }
    };

    /**
     * Attaches the script represented by the URL to the current
     * environment. Right now only supports browser loading,
     * but can be redefined in other environments to do the right thing.
     * @param {String} url the url of the script to attach.
     * @param {String} contextName the name of the context that wants the script.
     * @param {moduleName} the name of the module that is associated with the script.
     * @param {Function} [callback] optional callback, defaults to require.onScriptLoad
     * @param {String} [type] optional type, defaults to text/javascript
     */
    req.attach = function (url, contextName, moduleName, callback, type) {
        var node, loaded, context;
        if (isBrowser) {
            //In the browser so use a script tag
            callback = callback || req.onScriptLoad;
            node = document.createElement("script");
            node.type = type || "text/javascript";
            node.charset = "utf-8";
            //Use async so Gecko does not block on executing the script if something
            //like a long-polling comet tag is being run first. Gecko likes
            //to evaluate scripts in DOM order, even for dynamic scripts.
            //It will fetch them async, but only evaluate the contents in DOM
            //order, so a long-polling script tag can delay execution of scripts
            //after it. But telling Gecko we expect async gets us the behavior
            //we want -- execute it whenever it is finished downloading. Only
            //Helps Firefox 3.6+
            //Allow some URLs to not be fetched async. Mostly helps the order!
            //plugin
            node.async = !s.skipAsync[url];

            node.setAttribute("data-requirecontext", contextName);
            node.setAttribute("data-requiremodule", moduleName);

            //Set up load listener. Test attachEvent first because IE9 has
            //a subtle issue in its addEventListener and script onload firings
            //that do not match the behavior of all other browsers with
            //addEventListener support, which fire the onload event for a
            //script right after the script execution. See:
            //https://connect.microsoft.com/IE/feedback/details/648057/script-onload-event-is-not-fired-immediately-after-script-execution
            //UNFORTUNATELY Opera implements attachEvent but does not follow the script
            //script execution mode.
            if (node.attachEvent && !isOpera) {
                //Probably IE. IE (at least 6-8) do not fire
                //script onload right after executing the script, so
                //we cannot tie the anonymous require.def call to a name.
                //However, IE reports the script as being in "interactive"
                //readyState at the time of the require.def call.
                useInteractive = true;
                node.attachEvent("onreadystatechange", callback);
            } else {
                node.addEventListener("load", callback, false);
            }
            node.src = url;

            //For some cache cases in IE 6-8, the script executes before the end
            //of the appendChild execution, so to tie an anonymous require.def
            //call to the module name (which is stored on the node), hold on
            //to a reference to this node, but clear after the DOM insertion.
            currentlyAddingScript = node;
            if (baseElement) {
                head.insertBefore(node, baseElement);
            } else {
                head.appendChild(node);
            }
            currentlyAddingScript = null;
            return node;
        } else if (isWebWorker) {
            //In a web worker, use importScripts. This is not a very
            //efficient use of importScripts, importScripts will block until
            //its script is downloaded and evaluated. However, if web workers
            //are in play, the expectation that a build has been done so that
            //only one script needs to be loaded anyway. This may need to be
            //reevaluated if other use cases become common.
            context = contexts[contextName];
            loaded = context.loaded;
            loaded[moduleName] = false;

            importScripts(url);

            //Account for anonymous modules
            context.completeLoad(moduleName);
        }
        return null;
    };

    //Look for a data-main script attribute, which could also adjust the baseUrl.
    if (isBrowser) {
        //Figure out baseUrl. Get it from the script tag with require.js in it.
        scripts = document.getElementsByTagName("script");

        for (i = scripts.length - 1; i > -1 && (script = scripts[i]); i--) {
            //Set the "head" where we can append children by
            //using the script's parent.
            if (!head) {
                head = script.parentNode;
            }

            //Look for a data-main attribute to set main script for the page
            //to load. If it is there, the path to data main becomes the
            //baseUrl, if it is not already set.
            if ((dataMain = script.getAttribute('data-main'))) {
                if (!cfg.baseUrl) {
                    //Pull off the directory of data-main for use as the
                    //baseUrl.
                    src = dataMain.split('/');
                    mainScript = src.pop();
                    subPath = src.length ? src.join('/')  + '/' : './';

                    //Set final config.
                    cfg.baseUrl = subPath;
                    //Strip off any trailing .js since dataMain is now
                    //like a module name.
                    dataMain = mainScript.replace(jsSuffixRegExp, '');
                }

                //Put the data-main script in the files to load.
                cfg.deps = cfg.deps ? cfg.deps.concat(dataMain) : [dataMain];

                break;
            }
        }
    }

    //Set baseUrl based on config.
    s.baseUrl = cfg.baseUrl;

    //****** START page load functionality ****************
    /**
     * Sets the page as loaded and triggers check for all modules loaded.
     */
    req.pageLoaded = function () {
        if (!s.isPageLoaded) {
            s.isPageLoaded = true;
            if (scrollIntervalId) {
                clearInterval(scrollIntervalId);
            }

            //Part of a fix for FF < 3.6 where readyState was not set to
            //complete so libraries like jQuery that check for readyState
            //after page load where not getting initialized correctly.
            //Original approach suggested by Andrea Giammarchi:
            //http://webreflection.blogspot.com/2009/11/195-chars-to-help-lazy-loading.html
            //see other setReadyState reference for the rest of the fix.
            if (setReadyState) {
                document.readyState = "complete";
            }

            req.callReady();
        }
    };

    //See if there is nothing waiting across contexts, and if not, trigger
    //callReady.
    req.checkReadyState = function () {
        var contexts = s.contexts, prop;
        for (prop in contexts) {
            if (!(prop in empty)) {
                if (contexts[prop].waitCount) {
                    return;
                }
            }
        }
        s.isDone = true;
        req.callReady();
    };

    /**
     * Internal function that calls back any ready functions. If you are
     * integrating RequireJS with another library without require.ready support,
     * you can define this method to call your page ready code instead.
     */
    req.callReady = function () {
        var callbacks = s.readyCalls, i, callback, contexts, context, prop;

        if (s.isPageLoaded && s.isDone) {
            if (callbacks.length) {
                s.readyCalls = [];
                for (i = 0; (callback = callbacks[i]); i++) {
                    callback();
                }
            }

            //If jQuery with readyWait is being tracked, updated its
            //readyWait count.
            contexts = s.contexts;
            for (prop in contexts) {
                if (!(prop in empty)) {
                    context = contexts[prop];
                    if (context.jQueryIncremented) {
                        context.jQuery.ready(true);
                        context.jQueryIncremented = false;
                    }
                }
            }
        }
    };

    /**
     * Registers functions to call when the page is loaded
     */
    req.ready = function (callback) {
        if (s.isPageLoaded && s.isDone) {
            callback();
        } else {
            s.readyCalls.push(callback);
        }
        return req;
    };

    if (isBrowser) {
        if (document.addEventListener) {
            //Standards. Hooray! Assumption here that if standards based,
            //it knows about DOMContentLoaded.
            document.addEventListener("DOMContentLoaded", req.pageLoaded, false);
            window.addEventListener("load", req.pageLoaded, false);
            //Part of FF < 3.6 readystate fix (see setReadyState refs for more info)
            if (!document.readyState) {
                setReadyState = true;
                document.readyState = "loading";
            }
        } else if (window.attachEvent) {
            window.attachEvent("onload", req.pageLoaded);

            //DOMContentLoaded approximation, as found by Diego Perini:
            //http://javascript.nwbox.com/IEContentLoaded/
            if (self === self.top) {
                scrollIntervalId = setInterval(function () {
                    try {
                        //From this ticket:
                        //http://bugs.dojotoolkit.org/ticket/11106,
                        //In IE HTML Application (HTA), such as in a selenium test,
                        //javascript in the iframe can't see anything outside
                        //of it, so self===self.top is true, but the iframe is
                        //not the top window and doScroll will be available
                        //before document.body is set. Test document.body
                        //before trying the doScroll trick.
                        if (document.body) {
                            document.documentElement.doScroll("left");
                            req.pageLoaded();
                        }
                    } catch (e) {}
                }, 30);
            }
        }

        //Check if document already complete, and if so, just trigger page load
        //listeners. NOTE: does not work with Firefox before 3.6. To support
        //those browsers, manually call require.pageLoaded().
        if (document.readyState === "complete") {
            req.pageLoaded();
        }
    }
    //****** END page load functionality ****************

    //Set up default context. If require was a configuration object, use that as base config.
    req(cfg);

    //If modules are built into require.js, then need to make sure dependencies are
    //traced. Use a setTimeout in the browser world, to allow all the modules to register
    //themselves. In a non-browser env, assume that modules are not built into require.js,
    //which seems odd to do on the server.
    if (req.isAsync && typeof setTimeout !== "undefined") {
        ctx = s.contexts[(cfg.context || defContextName)];
        //Indicate that the script that includes require() is still loading,
        //so that require()'d dependencies are not traced until the end of the
        //file is parsed (approximated via the setTimeout call).
        ctx.requireWait = true;
        setTimeout(function () {
            ctx.requireWait = false;

            //Any modules included with the require.js file will be in the
            //global queue, assign them to this context.
            ctx.takeGlobalQueue();

            //Allow for jQuery to be loaded/already in the page, and if jQuery 1.4.3,
            //make sure to hold onto it for readyWait triggering.
            ctx.jQueryCheck();

            if (!ctx.scriptCount) {
                ctx.resume();
            }
            req.checkReadyState();
        }, 0);
    }
}());

define('utils',['require','exports','module'],function(){
    function Utils() {
        this.log_function = null
    }

    Utils.prototype = {
        log: function(message) {
            this.log_function(message)
        },
        active_logging: function(message) {
            try {
                console.log(message)
            }
            catch(e) {} //we're in IE or FF w/o Firebug or something
        },
        inactive_logging: function(message) {
        },
        disactivate_logging: function() {
            this.log_function = this.inactive_logging
        },
        activate_logging: function() {
            this.log_function = this.active_logging
        },
        isArray: function(candidate) {
            return (candidate.constructor == Array)
        },

        forEach: function(list, callback, thisArg) {
            if(typeof list.forEach == "function") {
                return list.forEach(callback, thisArg)
            }
            else if(typeof Array.prototype.forEach == "function") {
                return Array.prototype.forEach.call(list, callback, thisArg)
            }
            else {
                var len = Number(list.length)
                for(var k = 0; k < len; k+=1) {
                    if(typeof list[k] != "undefined") {
                        callback.call(thisArg, list[k], k, list)
                    }
                }
                return
            }
        }
    }
    var utils = new Utils
    if(typeof NINJASCRIPT_DEBUGGING == 'undefined') {
        utils.disactivate_logging()
    } else {
        utils.activate_logging()
    }


    return utils
})
define('ninja/exceptions',['require','exports','module'],function () {
    function buildException(named) {
        var exceptionConstructor = function (message) {
            Error.call(this, message)
            if(Error.captureStackTrace) {
                Error.captureStackTrace(this, this.constructor)
            }
            this.name = named; // Used to cause messages like "UserError: message" instead of the default "Error: message"
            this.message = message; // Used to set the message
        }
        exceptionConstructor.prototype = Error.prototype
        return exceptionConstructor
    }

    return {
        CouldntChoose: buildException("CouldntChoose"),
        TransformFailed: buildException("TransformFailed")
    }
})
define('ninja/behaviors',["ninja/exceptions"], function(Exceptions) {
    var CouldntChooseException = Exceptions.CouldntChoose

    var behaviors = {
    }

    behaviors.meta = function(setup, callback) {
        setup(this)
        this.chooser = callback
    }

    behaviors.meta.prototype = {
        choose: function(element) {
            var chosen = this.chooser(element)
            if(chosen !== undefined) {
                return chosen.choose(element)
            }
            else {
                throw new CouldntChooseException("Couldn't choose behavior for " . element.toString())
            }
        }
    }

    //For these to be acceptable, I need to fit them into the pattern that
    //Ninja.behavior accepts...
    behaviors.select = function(menu) {
        this.menu = menu
    }

    behaviors.select.prototype = {
        choose: function(element) {
            for(var selector in this.menu) {
                if(jQuery(element).is(selector)) {
                    return this.menu[selector].choose(element)
                }
            }
            return null //XXX Should raise exception
        }
    }

    behaviors.base = function(handlers) {
        this.helpers = {}
        this.eventHandlers = []
        this.lexicalOrder = 0
        this.priority = 0

        if (typeof handlers.transform == "function") {
            this.transform = handlers.transform
            delete handlers.transform
        }
        if (typeof handlers.helpers != "undefined"){
            this.helpers = handlers.helpers
            delete handlers.helpers
        }
        if (typeof handlers.priority != "undefined"){
            this.priority = handlers.priority
        }
        delete handlers.priority
        if (typeof handlers.events != "undefined") {
            this.eventHandlers = handlers.events
        }
        else {
            this.eventHandlers = handlers
        }

        return this
    }

    behaviors.base.prototype = {
        //XXX applyTo?
        apply: function(elem) {
            var context = this.inContext({})

            elem = this.applyTransform(context, elem)
            jQuery(elem).data("ninja-visited", context)

            this.applyEventHandlers(context, elem)

            return elem
        },
        priority: function(value) {
            this.priority = value
            return this
        },
        choose: function(element) {
            return this
        },
        inContext: function(basedOn) {
            function Context() {}
            Context.prototype = basedOn
            return Ninja.tools.enrich(new Context, this.helpers)
        },
        applyTransform: function(context, elem) {
            var previousElem = elem
            var newElem = this.transform.call(context, elem)
            if(newElem === undefined) {
                return previousElem
            }
            else {
                return newElem
            }
        },
        applyEventHandlers: function(context, elem) {
            for(var eventName in this.eventHandlers) {
                var handler = this.eventHandlers[eventName]
                jQuery(elem).bind(eventName, this.makeHandler.call(context, handler))
            }
            return elem
        },
        recordEventHandlers: function(scribe, context) {
            for(var eventName in this.eventHandlers) {
                scribe.recordHandler(this, eventName, function(oldHandler){
                        return this.makeHandler.call(context, this.eventHandlers[eventName], oldHandler)
                    }
                )
            }
        },
        buildHandler: function(context, eventName, previousHandler) {
            var handle
            var fallThrough = true
            var stopDefault = true
            var stopPropagate = true
            var stopImmediate = false
            var fireMutation = false
            var config = this.eventHandlers[eventName]

            if (typeof config == "function") {
                handle = config
            }
            else {
                handle = config[0]
                config = config.slice(1,config.length)
                var len = config.length
                for(var i = 0; i < len; i++) {
                    var found = true
                    if (config[i] == "dontContinue" ||
                        config[i] == "overridesOthers") {
                        fallThrough = false
                    }
                    if (config[i] == "andDoDefault" ||
                        config[i] == "continues" ||
                        config[i] == "allowDefault") {
                        stopDefault = false
                    }
                    if (config[i] == "allowPropagate" || config[i] == "dontStopPropagation") {
                        stopPropagate = false
                    }
                    //stopImmediatePropagation is a jQuery thing
                    if (config[i] == "andDoOthers") {
                        stopImmediate = false
                    }
                    if (config[i] == "changesDOM") {
                        fireMutation = true
                    }
                    if (!found) {
                        console.log("Event handler modifier unrecognized: " + config[i])
                    }
                }
            }
            var handler = function() {
                var eventRecord = Array.prototype.shift.call(arguments)
                Array.prototype.unshift.call(arguments, this)
                Array.prototype.unshift.call(arguments, eventRecord)

                handle.apply(context, arguments)
                if(!eventRecord.isFallthroughPrevented()) {
                    previousHandler.apply(context, arguments)
                }
                if(stopDefault){
                    return false
                } else {
                    return !eventRecord.isDefaultPrevented()
                }
            }
            if(!fallThrough) {
                handler = this.prependAction(handler, function(eventRecord) {
                    eventRecord.preventFallthrough()
                })
            }
            if(stopDefault) {
                handler = this.prependAction(handler, function(eventRecord) {
                    eventRecord.preventDefault()
                })
            }
            if(stopPropagate) {
                handler = this.prependAction(handler, function(eventRecord) {
                    eventRecord.stopPropagation()
                })
            }
            if (stopImmediate) {
                handler = this.prependAction(handler, function(eventRecord) {
                    eventRecord.stopImmediatePropagation()
                })
            }
            if (fireMutation) {
                handler = this.appendAction(handler, function(eventRecord) {
                    Ninja.tools.fireMutationEvent()
                })
            }
            handler = this.prependAction(handler, function(eventRecord) {
                eventRecord.isFallthroughPrevented = function(){ return false };
                eventRecord.preventFallthrough = function(){
                    eventRecord.isFallthroughPrevented =function(){ return true };
                }
            })

            return handler
        },
        prependAction: function(handler, doWhat) {
            return function() {
                doWhat.apply(this, arguments)
                return handler.apply(this, arguments)
            }
        },
        appendAction: function(handler, doWhat) {
            return function() {
                var result = handler.apply(this, arguments)
                doWhat.apply(this, arguments)
                return result
            }
        },
        transform: function(elem){
            return elem
        }
    }

    return behaviors
})
define('sizzle-1.0',['require','exports','module'],function() {
    /*
     * Sizzle CSS engine
     * Copyright 2009 The Dojo Foundation
     * Released under the MIT, BSD, and GPL Licenses.
     *
     * This version of the Sizzle engine taken from jQuery 1.4.2
     * Doesn't conflict with Mutation events.
     */

    var chunker = /((?:\((?:\([^()]+\)|[^()]+)+\)|\[(?:\[[^[\]]*\]|['"][^'"]*['"]|[^[\]'"]+)+\]|\\.|[^ >+~,(\[\\]+)+|[>+~])(\s*,\s*)?((?:.|\r|\n)*)/g,
        done = 0,
        toString = Object.prototype.toString,
        hasDuplicate = false,
        baseHasDuplicate = true;

    // Here we check if the JavaScript engine is using some sort of
    // optimization where it does not always call our comparision
    // function. If that is the case, discard the hasDuplicate value.
    //   Thus far that includes Google Chrome.
    [0, 0].sort(function(){
        baseHasDuplicate = false;
        return 0;
    });

    var Sizzle = function(selector, context, results, seed) {
        results = results || [];
        var origContext = context = context || document;

        if ( context.nodeType !== 1 && context.nodeType !== 9 ) {
            return [];
        }

        if ( !selector || typeof selector !== "string" ) {
            return results;
        }

        var parts = [], m, set, checkSet, extra, prune = true, contextXML = isXML(context),
            soFar = selector;

        // Reset the position of the chunker regexp (start from head)
        while ( (chunker.exec(""), m = chunker.exec(soFar)) !== null ) {
            soFar = m[3];

            parts.push( m[1] );

            if ( m[2] ) {
                extra = m[3];
                break;
            }
        }

        if ( parts.length > 1 && origPOS.exec( selector ) ) {
            if ( parts.length === 2 && Expr.relative[ parts[0] ] ) {
                set = posProcess( parts[0] + parts[1], context );
            } else {
                set = Expr.relative[ parts[0] ] ?
                    [ context ] :
                    Sizzle( parts.shift(), context );

                while ( parts.length ) {
                    selector = parts.shift();

                    if ( Expr.relative[ selector ] ) {
                        selector += parts.shift();
                    }

                    set = posProcess( selector, set );
                }
            }
        } else {
            // Take a shortcut and set the context if the root selector is an ID
            // (but not if it'll be faster if the inner selector is an ID)
            if ( !seed && parts.length > 1 && context.nodeType === 9 && !contextXML &&
                Expr.match.ID.test(parts[0]) && !Expr.match.ID.test(parts[parts.length - 1]) ) {
                var ret = Sizzle.find( parts.shift(), context, contextXML );
                context = ret.expr ? Sizzle.filter( ret.expr, ret.set )[0] : ret.set[0];
            }

            if ( context ) {
                var ret = seed ?
                { expr: parts.pop(), set: makeArray(seed) } :
                    Sizzle.find( parts.pop(), parts.length === 1 && (parts[0] === "~" || parts[0] === "+") && context.parentNode ? context.parentNode : context, contextXML );
                set = ret.expr ? Sizzle.filter( ret.expr, ret.set ) : ret.set;

                if ( parts.length > 0 ) {
                    checkSet = makeArray(set);
                } else {
                    prune = false;
                }

                while ( parts.length ) {
                    var cur = parts.pop(), pop = cur;

                    if ( !Expr.relative[ cur ] ) {
                        cur = "";
                    } else {
                        pop = parts.pop();
                    }

                    if ( pop == null ) {
                        pop = context;
                    }

                    Expr.relative[ cur ]( checkSet, pop, contextXML );
                }
            } else {
                checkSet = parts = [];
            }
        }

        if ( !checkSet ) {
            checkSet = set;
        }

        if ( !checkSet ) {
            Sizzle.error( cur || selector );
        }

        if ( toString.call(checkSet) === "[object Array]" ) {
            if ( !prune ) {
                results.push.apply( results, checkSet );
            } else if ( context && context.nodeType === 1 ) {
                for ( var i = 0; checkSet[i] != null; i++ ) {
                    if ( checkSet[i] && (checkSet[i] === true || checkSet[i].nodeType === 1 && contains(context, checkSet[i])) ) {
                        results.push( set[i] );
                    }
                }
            } else {
                for ( var i = 0; checkSet[i] != null; i++ ) {
                    if ( checkSet[i] && checkSet[i].nodeType === 1 ) {
                        results.push( set[i] );
                    }
                }
            }
        } else {
            makeArray( checkSet, results );
        }

        if ( extra ) {
            Sizzle( extra, origContext, results, seed );
            Sizzle.uniqueSort( results );
        }

        return results;
    };

    Sizzle.uniqueSort = function(results){
        if ( sortOrder ) {
            hasDuplicate = baseHasDuplicate;
            results.sort(sortOrder);

            if ( hasDuplicate ) {
                for ( var i = 1; i < results.length; i++ ) {
                    if ( results[i] === results[i-1] ) {
                        results.splice(i--, 1);
                    }
                }
            }
        }

        return results;
    };

    Sizzle.matches = function(expr, set){
        return Sizzle(expr, null, null, set);
    };

    Sizzle.find = function(expr, context, isXML){
        var set, match;

        if ( !expr ) {
            return [];
        }

        for ( var i = 0, l = Expr.order.length; i < l; i++ ) {
            var type = Expr.order[i], match;

            if ( (match = Expr.leftMatch[ type ].exec( expr )) ) {
                var left = match[1];
                match.splice(1,1);

                if ( left.substr( left.length - 1 ) !== "\\" ) {
                    match[1] = (match[1] || "").replace(/\\/g, "");
                    set = Expr.find[ type ]( match, context, isXML );
                    if ( set != null ) {
                        expr = expr.replace( Expr.match[ type ], "" );
                        break;
                    }
                }
            }
        }

        if ( !set ) {
            set = context.getElementsByTagName("*");
        }

        return {set: set, expr: expr};
    };

    Sizzle.filter = function(expr, set, inplace, not){
        var old = expr, result = [], curLoop = set, match, anyFound,
            isXMLFilter = set && set[0] && isXML(set[0]);

        while ( expr && set.length ) {
            for ( var type in Expr.filter ) {
                if ( (match = Expr.leftMatch[ type ].exec( expr )) != null && match[2] ) {
                    var filter = Expr.filter[ type ], found, item, left = match[1];
                    anyFound = false;

                    match.splice(1,1);

                    if ( left.substr( left.length - 1 ) === "\\" ) {
                        continue;
                    }

                    if ( curLoop === result ) {
                        result = [];
                    }

                    if ( Expr.preFilter[ type ] ) {
                        match = Expr.preFilter[ type ]( match, curLoop, inplace, result, not, isXMLFilter );

                        if ( !match ) {
                            anyFound = found = true;
                        } else if ( match === true ) {
                            continue;
                        }
                    }

                    if ( match ) {
                        for ( var i = 0; (item = curLoop[i]) != null; i++ ) {
                            if ( item ) {
                                found = filter( item, match, i, curLoop );
                                var pass = not ^ !!found;

                                if ( inplace && found != null ) {
                                    if ( pass ) {
                                        anyFound = true;
                                    } else {
                                        curLoop[i] = false;
                                    }
                                } else if ( pass ) {
                                    result.push( item );
                                    anyFound = true;
                                }
                            }
                        }
                    }

                    if ( found !== undefined ) {
                        if ( !inplace ) {
                            curLoop = result;
                        }

                        expr = expr.replace( Expr.match[ type ], "" );

                        if ( !anyFound ) {
                            return [];
                        }

                        break;
                    }
                }
            }

            // Improper expression
            if ( expr === old ) {
                if ( anyFound == null ) {
                    Sizzle.error( expr );
                } else {
                    break;
                }
            }

            old = expr;
        }

        return curLoop;
    };

    Sizzle.error = function( msg ) {
        throw "Syntax error, unrecognized expression: " + msg;
    };

    var Expr = Sizzle.selectors = {
        order: [ "ID", "NAME", "TAG" ],
        match: {
            ID: /#((?:[\w\u00c0-\uFFFF-]|\\.)+)/,
            CLASS: /\.((?:[\w\u00c0-\uFFFF-]|\\.)+)/,
            NAME: /\[name=['"]*((?:[\w\u00c0-\uFFFF-]|\\.)+)['"]*\]/,
            ATTR: /\[\s*((?:[\w\u00c0-\uFFFF-]|\\.)+)\s*(?:(\S?=)\s*(['"]*)(.*?)\3|)\s*\]/,
            TAG: /^((?:[\w\u00c0-\uFFFF\*-]|\\.)+)/,
            CHILD: /:(only|nth|last|first)-child(?:\((even|odd|[\dn+-]*)\))?/,
            POS: /:(nth|eq|gt|lt|first|last|even|odd)(?:\((\d*)\))?(?=[^-]|$)/,
            PSEUDO: /:((?:[\w\u00c0-\uFFFF-]|\\.)+)(?:\((['"]?)((?:\([^\)]+\)|[^\(\)]*)+)\2\))?/
        },
        leftMatch: {},
        attrMap: {
            "class": "className",
            "for": "htmlFor"
        },
        attrHandle: {
            href: function(elem){
                return elem.getAttribute("href");
            }
        },
        relative: {
            "+": function(checkSet, part){
                var isPartStr = typeof part === "string",
                    isTag = isPartStr && !/\W/.test(part),
                    isPartStrNotTag = isPartStr && !isTag;

                if ( isTag ) {
                    part = part.toLowerCase();
                }

                for ( var i = 0, l = checkSet.length, elem; i < l; i++ ) {
                    if ( (elem = checkSet[i]) ) {
                        while ( (elem = elem.previousSibling) && elem.nodeType !== 1 ) {}

                        checkSet[i] = isPartStrNotTag || elem && elem.nodeName.toLowerCase() === part ?
                            elem || false :
                            elem === part;
                    }
                }

                if ( isPartStrNotTag ) {
                    Sizzle.filter( part, checkSet, true );
                }
            },
            ">": function(checkSet, part){
                var isPartStr = typeof part === "string";

                if ( isPartStr && !/\W/.test(part) ) {
                    part = part.toLowerCase();

                    for ( var i = 0, l = checkSet.length; i < l; i++ ) {
                        var elem = checkSet[i];
                        if ( elem ) {
                            var parent = elem.parentNode;
                            checkSet[i] = parent.nodeName.toLowerCase() === part ? parent : false;
                        }
                    }
                } else {
                    for ( var i = 0, l = checkSet.length; i < l; i++ ) {
                        var elem = checkSet[i];
                        if ( elem ) {
                            checkSet[i] = isPartStr ?
                                elem.parentNode :
                                elem.parentNode === part;
                        }
                    }

                    if ( isPartStr ) {
                        Sizzle.filter( part, checkSet, true );
                    }
                }
            },
            "": function(checkSet, part, isXML){
                var doneName = done++, checkFn = dirCheck;

                if ( typeof part === "string" && !/\W/.test(part) ) {
                    var nodeCheck = part = part.toLowerCase();
                    checkFn = dirNodeCheck;
                }

                checkFn("parentNode", part, doneName, checkSet, nodeCheck, isXML);
            },
            "~": function(checkSet, part, isXML){
                var doneName = done++, checkFn = dirCheck;

                if ( typeof part === "string" && !/\W/.test(part) ) {
                    var nodeCheck = part = part.toLowerCase();
                    checkFn = dirNodeCheck;
                }

                checkFn("previousSibling", part, doneName, checkSet, nodeCheck, isXML);
            }
        },
        find: {
            ID: function(match, context, isXML){
                if ( typeof context.getElementById !== "undefined" && !isXML ) {
                    var m = context.getElementById(match[1]);
                    return m ? [m] : [];
                }
            },
            NAME: function(match, context){
                if ( typeof context.getElementsByName !== "undefined" ) {
                    var ret = [], results = context.getElementsByName(match[1]);

                    for ( var i = 0, l = results.length; i < l; i++ ) {
                        if ( results[i].getAttribute("name") === match[1] ) {
                            ret.push( results[i] );
                        }
                    }

                    return ret.length === 0 ? null : ret;
                }
            },
            TAG: function(match, context){
                return context.getElementsByTagName(match[1]);
            }
        },
        preFilter: {
            CLASS: function(match, curLoop, inplace, result, not, isXML){
                match = " " + match[1].replace(/\\/g, "") + " ";

                if ( isXML ) {
                    return match;
                }

                for ( var i = 0, elem; (elem = curLoop[i]) != null; i++ ) {
                    if ( elem ) {
                        if ( not ^ (elem.className && (" " + elem.className + " ").replace(/[\t\n]/g, " ").indexOf(match) >= 0) ) {
                            if ( !inplace ) {
                                result.push( elem );
                            }
                        } else if ( inplace ) {
                            curLoop[i] = false;
                        }
                    }
                }

                return false;
            },
            ID: function(match){
                return match[1].replace(/\\/g, "");
            },
            TAG: function(match, curLoop){
                return match[1].toLowerCase();
            },
            CHILD: function(match){
                if ( match[1] === "nth" ) {
                    // parse equations like 'even', 'odd', '5', '2n', '3n+2', '4n-1', '-n+6'
                    var test = /(-?)(\d*)n((?:\+|-)?\d*)/.exec(
                        match[2] === "even" && "2n" || match[2] === "odd" && "2n+1" ||
                            !/\D/.test( match[2] ) && "0n+" + match[2] || match[2]);

                    // calculate the numbers (first)n+(last) including if they are negative
                    match[2] = (test[1] + (test[2] || 1)) - 0;
                    match[3] = test[3] - 0;
                }

                // TODO: Move to normal caching system
                match[0] = done++;

                return match;
            },
            ATTR: function(match, curLoop, inplace, result, not, isXML){
                var name = match[1].replace(/\\/g, "");

                if ( !isXML && Expr.attrMap[name] ) {
                    match[1] = Expr.attrMap[name];
                }

                if ( match[2] === "~=" ) {
                    match[4] = " " + match[4] + " ";
                }

                return match;
            },
            PSEUDO: function(match, curLoop, inplace, result, not){
                if ( match[1] === "not" ) {
                    // If we're dealing with a complex expression, or a simple one
                    if ( ( chunker.exec(match[3]) || "" ).length > 1 || /^\w/.test(match[3]) ) {
                        match[3] = Sizzle(match[3], null, null, curLoop);
                    } else {
                        var ret = Sizzle.filter(match[3], curLoop, inplace, true ^ not);
                        if ( !inplace ) {
                            result.push.apply( result, ret );
                        }
                        return false;
                    }
                } else if ( Expr.match.POS.test( match[0] ) || Expr.match.CHILD.test( match[0] ) ) {
                    return true;
                }

                return match;
            },
            POS: function(match){
                match.unshift( true );
                return match;
            }
        },
        filters: {
            enabled: function(elem){
                return elem.disabled === false && elem.type !== "hidden";
            },
            disabled: function(elem){
                return elem.disabled === true;
            },
            checked: function(elem){
                return elem.checked === true;
            },
            selected: function(elem){
                // Accessing this property makes selected-by-default
                // options in Safari work properly
                elem.parentNode.selectedIndex;
                return elem.selected === true;
            },
            parent: function(elem){
                return !!elem.firstChild;
            },
            empty: function(elem){
                return !elem.firstChild;
            },
            has: function(elem, i, match){
                return !!Sizzle( match[3], elem ).length;
            },
            header: function(elem){
                return /h\d/i.test( elem.nodeName );
            },
            text: function(elem){
                return "text" === elem.type;
            },
            radio: function(elem){
                return "radio" === elem.type;
            },
            checkbox: function(elem){
                return "checkbox" === elem.type;
            },
            file: function(elem){
                return "file" === elem.type;
            },
            password: function(elem){
                return "password" === elem.type;
            },
            submit: function(elem){
                return "submit" === elem.type;
            },
            image: function(elem){
                return "image" === elem.type;
            },
            reset: function(elem){
                return "reset" === elem.type;
            },
            button: function(elem){
                return "button" === elem.type || elem.nodeName.toLowerCase() === "button";
            },
            input: function(elem){
                return /input|select|textarea|button/i.test(elem.nodeName);
            }
        },
        setFilters: {
            first: function(elem, i){
                return i === 0;
            },
            last: function(elem, i, match, array){
                return i === array.length - 1;
            },
            even: function(elem, i){
                return i % 2 === 0;
            },
            odd: function(elem, i){
                return i % 2 === 1;
            },
            lt: function(elem, i, match){
                return i < match[3] - 0;
            },
            gt: function(elem, i, match){
                return i > match[3] - 0;
            },
            nth: function(elem, i, match){
                return match[3] - 0 === i;
            },
            eq: function(elem, i, match){
                return match[3] - 0 === i;
            }
        },
        filter: {
            PSEUDO: function(elem, match, i, array){
                var name = match[1], filter = Expr.filters[ name ];

                if ( filter ) {
                    return filter( elem, i, match, array );
                } else if ( name === "contains" ) {
                    return (elem.textContent || elem.innerText || getText([ elem ]) || "").indexOf(match[3]) >= 0;
                } else if ( name === "not" ) {
                    var not = match[3];

                    for ( var i = 0, l = not.length; i < l; i++ ) {
                        if ( not[i] === elem ) {
                            return false;
                        }
                    }

                    return true;
                } else {
                    Sizzle.error( "Syntax error, unrecognized expression: " + name );
                }
            },
            CHILD: function(elem, match){
                var type = match[1], node = elem;
                switch (type) {
                    case 'only':
                    case 'first':
                        while ( (node = node.previousSibling) )	 {
                            if ( node.nodeType === 1 ) {
                                return false;
                            }
                        }
                        if ( type === "first" ) {
                            return true;
                        }
                        node = elem;
                    case 'last':
                        while ( (node = node.nextSibling) )	 {
                            if ( node.nodeType === 1 ) {
                                return false;
                            }
                        }
                        return true;
                    case 'nth':
                        var first = match[2], last = match[3];

                        if ( first === 1 && last === 0 ) {
                            return true;
                        }

                        var doneName = match[0],
                            parent = elem.parentNode;

                        if ( parent && (parent.sizcache !== doneName || !elem.nodeIndex) ) {
                            var count = 0;
                            for ( node = parent.firstChild; node; node = node.nextSibling ) {
                                if ( node.nodeType === 1 ) {
                                    node.nodeIndex = ++count;
                                }
                            }
                            parent.sizcache = doneName;
                        }

                        var diff = elem.nodeIndex - last;
                        if ( first === 0 ) {
                            return diff === 0;
                        } else {
                            return ( diff % first === 0 && diff / first >= 0 );
                        }
                }
            },
            ID: function(elem, match){
                return elem.nodeType === 1 && elem.getAttribute("id") === match;
            },
            TAG: function(elem, match){
                return (match === "*" && elem.nodeType === 1) || elem.nodeName.toLowerCase() === match;
            },
            CLASS: function(elem, match){
                return (" " + (elem.className || elem.getAttribute("class")) + " ")
                    .indexOf( match ) > -1;
            },
            ATTR: function(elem, match){
                var name = match[1],
                    result = Expr.attrHandle[ name ] ?
                        Expr.attrHandle[ name ]( elem ) :
                        elem[ name ] != null ?
                            elem[ name ] :
                            elem.getAttribute( name ),
                    value = result + "",
                    type = match[2],
                    check = match[4];

                return result == null ?
                    type === "!=" :
                    type === "=" ?
                        value === check :
                        type === "*=" ?
                            value.indexOf(check) >= 0 :
                            type === "~=" ?
                                (" " + value + " ").indexOf(check) >= 0 :
                                !check ?
                                    value && result !== false :
                                    type === "!=" ?
                                        value !== check :
                                        type === "^=" ?
                                            value.indexOf(check) === 0 :
                                            type === "$=" ?
                                                value.substr(value.length - check.length) === check :
                                                type === "|=" ?
                                                    value === check || value.substr(0, check.length + 1) === check + "-" :
                                                    false;
            },
            POS: function(elem, match, i, array){
                var name = match[2], filter = Expr.setFilters[ name ];

                if ( filter ) {
                    return filter( elem, i, match, array );
                }
            }
        }
    };

    var origPOS = Expr.match.POS;

    for ( var type in Expr.match ) {
        Expr.match[ type ] = new RegExp( Expr.match[ type ].source + /(?![^\[]*\])(?![^\(]*\))/.source );
        Expr.leftMatch[ type ] = new RegExp( /(^(?:.|\r|\n)*?)/.source + Expr.match[ type ].source.replace(/\\(\d+)/g, function(all, num){
            return "\\" + (num - 0 + 1);
        }));
    }

    var makeArray = function(array, results) {
        array = Array.prototype.slice.call( array, 0 );

        if ( results ) {
            results.push.apply( results, array );
            return results;
        }

        return array;
    };

    // Perform a simple check to determine if the browser is capable of
    // converting a NodeList to an array using builtin methods.
    // Also verifies that the returned array holds DOM nodes
    // (which is not the case in the Blackberry browser)
    try {
        Array.prototype.slice.call( document.documentElement.childNodes, 0 )[0].nodeType;

        // Provide a fallback method if it does not work
    } catch(e){
        makeArray = function(array, results) {
            var ret = results || [];

            if ( toString.call(array) === "[object Array]" ) {
                Array.prototype.push.apply( ret, array );
            } else {
                if ( typeof array.length === "number" ) {
                    for ( var i = 0, l = array.length; i < l; i++ ) {
                        ret.push( array[i] );
                    }
                } else {
                    for ( var i = 0; array[i]; i++ ) {
                        ret.push( array[i] );
                    }
                }
            }

            return ret;
        };
    }

    var sortOrder;

    if ( document.documentElement.compareDocumentPosition ) {
        sortOrder = function( a, b ) {
            if ( !a.compareDocumentPosition || !b.compareDocumentPosition ) {
                if ( a == b ) {
                    hasDuplicate = true;
                }
                return a.compareDocumentPosition ? -1 : 1;
            }

            var ret = a.compareDocumentPosition(b) & 4 ? -1 : a === b ? 0 : 1;
            if ( ret === 0 ) {
                hasDuplicate = true;
            }
            return ret;
        };
    } else if ( "sourceIndex" in document.documentElement ) {
        sortOrder = function( a, b ) {
            if ( !a.sourceIndex || !b.sourceIndex ) {
                if ( a == b ) {
                    hasDuplicate = true;
                }
                return a.sourceIndex ? -1 : 1;
            }

            var ret = a.sourceIndex - b.sourceIndex;
            if ( ret === 0 ) {
                hasDuplicate = true;
            }
            return ret;
        };
    } else if ( document.createRange ) {
        sortOrder = function( a, b ) {
            if ( !a.ownerDocument || !b.ownerDocument ) {
                if ( a == b ) {
                    hasDuplicate = true;
                }
                return a.ownerDocument ? -1 : 1;
            }

            var aRange = a.ownerDocument.createRange(), bRange = b.ownerDocument.createRange();
            aRange.setStart(a, 0);
            aRange.setEnd(a, 0);
            bRange.setStart(b, 0);
            bRange.setEnd(b, 0);
            var ret = aRange.compareBoundaryPoints(Range.START_TO_END, bRange);
            if ( ret === 0 ) {
                hasDuplicate = true;
            }
            return ret;
        };
    }

    // Utility function for retreiving the text value of an array of DOM nodes
    function getText( elems ) {
        var ret = "", elem;

        for ( var i = 0; elems[i]; i++ ) {
            elem = elems[i];

            // Get the text from text nodes and CDATA nodes
            if ( elem.nodeType === 3 || elem.nodeType === 4 ) {
                ret += elem.nodeValue;

                // Traverse everything else, except comment nodes
            } else if ( elem.nodeType !== 8 ) {
                ret += getText( elem.childNodes );
            }
        }

        return ret;
    }

    // Check to see if the browser returns elements by name when
    // querying by getElementById (and provide a workaround)
    (function(){
        // We're going to inject a fake input element with a specified name
        var form = document.createElement("div"),
            id = "script" + (new Date).getTime();
        form.innerHTML = "<a name='" + id + "'/>";

        // Inject it into the root element, check its status, and remove it quickly
        var root = document.documentElement;
        root.insertBefore( form, root.firstChild );

        // The workaround has to do additional checks after a getElementById
        // Which slows things down for other browsers (hence the branching)
        if ( document.getElementById( id ) ) {
            Expr.find.ID = function(match, context, isXML){
                if ( typeof context.getElementById !== "undefined" && !isXML ) {
                    var m = context.getElementById(match[1]);
                    return m ? m.id === match[1] || typeof m.getAttributeNode !== "undefined" && m.getAttributeNode("id").nodeValue === match[1] ? [m] : undefined : [];
                }
            };

            Expr.filter.ID = function(elem, match){
                var node = typeof elem.getAttributeNode !== "undefined" && elem.getAttributeNode("id");
                return elem.nodeType === 1 && node && node.nodeValue === match;
            };
        }

        root.removeChild( form );
        root = form = null; // release memory in IE
    })();

    (function(){
        // Check to see if the browser returns only elements
        // when doing getElementsByTagName("*")

        // Create a fake element
        var div = document.createElement("div");
        div.appendChild( document.createComment("") );

        // Make sure no comments are found
        if ( div.getElementsByTagName("*").length > 0 ) {
            Expr.find.TAG = function(match, context){
                var results = context.getElementsByTagName(match[1]);

                // Filter out possible comments
                if ( match[1] === "*" ) {
                    var tmp = [];

                    for ( var i = 0; results[i]; i++ ) {
                        if ( results[i].nodeType === 1 ) {
                            tmp.push( results[i] );
                        }
                    }

                    results = tmp;
                }

                return results;
            };
        }

        // Check to see if an attribute returns normalized href attributes
        div.innerHTML = "<a href='#'></a>";
        if ( div.firstChild && typeof div.firstChild.getAttribute !== "undefined" &&
            div.firstChild.getAttribute("href") !== "#" ) {
            Expr.attrHandle.href = function(elem){
                return elem.getAttribute("href", 2);
            };
        }

        div = null; // release memory in IE
    })();

    if ( document.querySelectorAll ) {
        (function(){
            var oldSizzle = Sizzle, div = document.createElement("div");
            div.innerHTML = "<p class='TEST'></p>";

            // Safari can't handle uppercase or unicode characters when
            // in quirks mode.
            if ( div.querySelectorAll && div.querySelectorAll(".TEST").length === 0 ) {
                return;
            }

            Sizzle = function(query, context, extra, seed){
                context = context || document;

                // Only use querySelectorAll on non-XML documents
                // (ID selectors don't work in non-HTML documents)
                if ( !seed && context.nodeType === 9 && !isXML(context) ) {
                    try {
                        return makeArray( context.querySelectorAll(query), extra );
                    } catch(e){}
                }

                return oldSizzle(query, context, extra, seed);
            };

            for ( var prop in oldSizzle ) {
                Sizzle[ prop ] = oldSizzle[ prop ];
            }

            div = null; // release memory in IE
        })();
    }

    (function(){
        var div = document.createElement("div");

        div.innerHTML = "<div class='test e'></div><div class='test'></div>";

        // Opera can't find a second classname (in 9.6)
        // Also, make sure that getElementsByClassName actually exists
        if ( !div.getElementsByClassName || div.getElementsByClassName("e").length === 0 ) {
            return;
        }

        // Safari caches class attributes, doesn't catch changes (in 3.2)
        div.lastChild.className = "e";

        if ( div.getElementsByClassName("e").length === 1 ) {
            return;
        }

        Expr.order.splice(1, 0, "CLASS");
        Expr.find.CLASS = function(match, context, isXML) {
            if ( typeof context.getElementsByClassName !== "undefined" && !isXML ) {
                return context.getElementsByClassName(match[1]);
            }
        };

        div = null; // release memory in IE
    })();

    function dirNodeCheck( dir, cur, doneName, checkSet, nodeCheck, isXML ) {
        for ( var i = 0, l = checkSet.length; i < l; i++ ) {
            var elem = checkSet[i];
            if ( elem ) {
                elem = elem[dir];
                var match = false;

                while ( elem ) {
                    if ( elem.sizcache === doneName ) {
                        match = checkSet[elem.sizset];
                        break;
                    }

                    if ( elem.nodeType === 1 && !isXML ){
                        elem.sizcache = doneName;
                        elem.sizset = i;
                    }

                    if ( elem.nodeName.toLowerCase() === cur ) {
                        match = elem;
                        break;
                    }

                    elem = elem[dir];
                }

                checkSet[i] = match;
            }
        }
    }

    function dirCheck( dir, cur, doneName, checkSet, nodeCheck, isXML ) {
        for ( var i = 0, l = checkSet.length; i < l; i++ ) {
            var elem = checkSet[i];
            if ( elem ) {
                elem = elem[dir];
                var match = false;

                while ( elem ) {
                    if ( elem.sizcache === doneName ) {
                        match = checkSet[elem.sizset];
                        break;
                    }

                    if ( elem.nodeType === 1 ) {
                        if ( !isXML ) {
                            elem.sizcache = doneName;
                            elem.sizset = i;
                        }
                        if ( typeof cur !== "string" ) {
                            if ( elem === cur ) {
                                match = true;
                                break;
                            }

                        } else if ( Sizzle.filter( cur, [elem] ).length > 0 ) {
                            match = elem;
                            break;
                        }
                    }

                    elem = elem[dir];
                }

                checkSet[i] = match;
            }
        }
    }

    var contains = document.compareDocumentPosition ? function(a, b){
        return !!(a.compareDocumentPosition(b) & 16);
    } : function(a, b){
        return a !== b && (a.contains ? a.contains(b) : true);
    };

    var isXML = function(elem){
        // documentElement is verified for cases where it doesn't yet exist
        // (such as loading iframes in IE - #4833)
        var documentElement = (elem ? elem.ownerDocument || elem : 0).documentElement;
        return documentElement ? documentElement.nodeName !== "HTML" : false;
    };

    var posProcess = function(selector, context){
        var tmpSet = [], later = "", match,
            root = context.nodeType ? [context] : context;

        // Position selectors must be done after the filter
        // And so must :not(positional) so we move all PSEUDOs to the end
        while ( (match = Expr.match.PSEUDO.exec( selector )) ) {
            later += match[0];
            selector = selector.replace( Expr.match.PSEUDO, "" );
        }

        selector = Expr.relative[selector] ? selector + "*" : selector;

        for ( var i = 0, l = root.length; i < l; i++ ) {
            Sizzle( selector, root[i], tmpSet );
        }

        return Sizzle.filter( later, tmpSet );
    };

    return Sizzle;
})
define('ninja/event-scribe',['require','exports','module'],function() {
    function EventScribe() {
        this.handlers = {}
        this.currentElement = null
    }

    EventScribe.prototype = {
        recordEventHandlers: function (context, behavior) {
            if(this.currentElement !== context.element) {
                if(this.currentElement !== null) {
                    this.applyEventHandlers(this.currentElement)
                    this.handlers = {}
                }
                this.currentElement = context.element
            }
            for(var eventName in behavior.eventHandlers) {
                var oldHandler = this.handlers[eventName]
                if(typeof oldHandler == "undefined") {
                    oldHandler = function(){return true}
                }
                this.handlers[eventName] = behavior.buildHandler(context, eventName, oldHandler)
            }
        },
        applyEventHandlers: function(element) {
            for(var eventName in this.handlers) {
                jQuery(element).bind(eventName, this.handlers[eventName])
            }
        }
    }
    return EventScribe
})
define('ninja/behavior-collection',["sizzle-1.0", "ninja/behaviors", "utils", "ninja/event-scribe", "ninja/exceptions"],
    function(Sizzle, Behaviors, Utils, EventScribe, Exceptions) {

        var forEach = Utils.forEach
        function log(message) {
            Utils.log(message)
        }

        var TransformFailedException = Exceptions.TransformFailed
        var CouldntChooseException = Exceptions.CouldntChoose

        function BehaviorCollection(tools) {
            this.lexicalCount = 0
            this.eventQueue = []
            this.behaviors = {}
            this.selectors = []
            this.mutationTargets = []
            this.tools = tools
            return this
        }

        BehaviorCollection.prototype = {
            addBehavior: function(selector, behavior) {
                if(Utils.isArray(behavior)) {
                    forEach(behavior, function(behaves){
                        this.addBehavior(selector, behaves)
                    }, this)
                }
                else if(behavior instanceof Behaviors.base) {
                    this.insertBehavior(selector, behavior)
                }
                else if(behavior instanceof Behaviors.select) {
                    this.insertBehavior(selector, behavior)
                }
                else if(behavior instanceof Behaviors.meta) {
                    this.insertBehavior(selector, behavior)
                }
                else if(typeof behavior == "function"){
                    this.addBehavior(selector, behavior())
                }
                else {
                    var behavior = new Behaviors.base(behavior)
                    this.addBehavior(selector, behavior)
                }
            },
            insertBehavior: function(selector, behavior) {
                behavior.lexicalOrder = this.lexicalCount
                this.lexicalCount += 1
                if(this.behaviors[selector] === undefined) {
                    this.selectors.push(selector)
                    this.behaviors[selector] = [behavior]
                }
                else {
                    this.behaviors[selector].push(behavior)
                }
            },
            addMutationTargets: function(targets) {
                this.mutationTargets = this.mutationTargets.concat(targets)
            },
            //Move to Tools
            fireMutationEvent: function() {
                var targets = this.mutationTargets
                if (targets.length > 0 ) {
                    for(var target = targets[0];
                        targets.length > 0;
                        target = targets.shift()) {
                        jQuery(target).trigger("thisChangedDOM")
                    }
                }
                else {
                    this.tools.getRootOfDocument().trigger("thisChangedDOM")
                }
            },
            mutationEventTriggered: function(evnt){
                if(this.eventQueue.length == 0){
                    log("mutation event - first")
                    this.enqueueEvent(evnt)
                    this.handleQueue()
                }
                else {
                    log("mutation event - queueing")
                    this.enqueueEvent(evnt)
                }
            },
            enqueueEvent: function(evnt) {
                var eventCovered = false
                var uncovered = []
                forEach(this.eventQueue, function(val) {
                    eventCovered = eventCovered || jQuery.contains(val.target, evnt.target)
                    if (!(jQuery.contains(evnt.target, val.target))) {
                        uncovered.push(val)
                    }
                })
                if(!eventCovered) {
                    uncovered.unshift(evnt)
                    this.eventQueue = uncovered
                }
            },
            handleQueue: function(){
                while (this.eventQueue.length != 0){
                    this.applyAll(this.eventQueue[0].target)
                    this.eventQueue.shift()
                }
            },
            applyBehaviorsTo: function(element, behaviors) {
                return this.applyBehaviorsInContext(new this.tools.behaviorContext, element, behaviors)
            },
            applyBehaviorsInContext: function(context, element, behaviors) {
                var curContext,
                    rootContext = context,
                    applyList = [],
                    scribe = new EventScribe

                //Move enrich to Utils
                this.tools.enrich(scribe.handlers, context.eventHandlerSet)

                behaviors = behaviors.sort(function(left, right) {
                        if(left.priority != right.priority) {
                            if(left.priority === undefined) {
                                return -1
                            }
                            else if(right.priority === undefined) {
                                return 1
                            }
                            else {
                                return left.priority - right.priority
                            }
                        }
                        else {
                            return left.lexicalOrder - right.lexicalOrder
                        }
                    }
                )

                forEach(behaviors,
                    function(behavior){
                        try {
                            curContext = behavior.inContext(context)
                            element = behavior.applyTransform(curContext, element)

                            context = curContext
                            context.element = element

                            scribe.recordEventHandlers(context, behavior)
                        }
                        catch(ex) {
                            if(ex instanceof TransformFailedException) {
                                log("!!! Transform failed")
                            }
                            else {
                                log(ex)
                                throw ex
                            }
                        }
                    }
                )

                rootContext.visibleElement = element

                jQuery(element).data("ninja-visited", context)

                scribe.applyEventHandlers(element)
                //Move enrich to utils
                this.tools.enrich(context.eventHandlerSet, scribe.handlers)

                this.fireMutationEvent()

                return element
            },
            collectBehaviors: function(element, collection, behaviors) {
                forEach(behaviors, function(val) {
                    try {
                        collection.push(val.choose(element))
                    }
                    catch(ex) {
                        if(ex instanceof CouldntChooseException) {
                            log("!!! couldn't choose")
                        }
                        else {
                            log(ex)
                            throw(ex)
                        }
                    }
                })
            },
            //XXX Still doesn't quite handle the sub-behavior case - order of application
            apply: function(element, startBehaviors, selectorIndex) {
                var applicableBehaviors = [], len = this.selectors.length
                this.collectBehaviors(element, applicableBehaviors, startBehaviors)
                var context = jQuery(element).data('ninja-visited')
                if (!context) {
                    if(typeof selectorIndex == "undefined") {
                        selectorIndex = 0
                    }
                    for(var j = selectorIndex; j < len; j++) {
                        if(jQuery(element).is(this.selectors[j])) {
                            this.collectBehaviors(element, applicableBehaviors, this.behaviors[this.selectors[j]])
                        }
                    }
                    this.applyBehaviorsTo(element, applicableBehaviors)
                }
                else {
                    context.unbindHandlers()
                    this.applyBehaviorsInContext(context, element, applicableBehaviors)
                }
            },
            applyAll: function(root){
                var len = this.selectors.length
                for(var i = 0; i < len; i++) {
                    var collection = this

                    //Sizzle?

                    forEach(Sizzle( this.selectors[i], root), //an array, not a jQuery
                        function(elem){
                            if (!jQuery(elem).data("ninja-visited")) { //Pure optimization
                                collection.apply(elem, [], i)
                            }
                        })


                    //        jQuery(root).find(this.selectors[i]).each(
                    //          function(index, elem){
                    //            if (!jQuery(elem).data("ninja-visited")) { //Pure optimization
                    //              collection.apply(elem, [], i)
                    //            }
                    //          }
                    //        )
                }
            }
        }
        return BehaviorCollection
    })
define('ninja/root-context',["utils"], function(Utils) {
    var forEach = Utils.forEach

    return function(tools) {

        function RootContext() {
            this.stashedElements = []
            this.eventHandlerSet = {}
        }

        RootContext.prototype = tools.enrich(
            tools,
            {
                stash: function(element) {
                    this.stashedElements.unshift(element)
                },
                unstash: function() {
                    return this.stashedElements.shift()
                },
                clearStash: function() {
                    this.stashedElements = []
                },
                //XXX Of concern: how do cascading events work out?
                //Should there be a first catch?  Or a "doesn't cascade" or something?
                cascadeEvent: function(event) {
                    var formDiv = Ninja.tools.hiddenDiv()
                    forEach(this.stashedElements, function(element) {
                        var elem = jQuery(element)
                        elem.data("ninja-visited", this)
                        jQuery(formDiv).append(elem)
                        elem.trigger(event)
                    })
                },
                unbindHandlers: function() {
                    var el = jQuery(this.element)
                    for(eventName in this.eventHandlerSet) {
                        el.unbind(eventName, this.eventHandlerSet[eventName])
                    }
                }
            })

        return RootContext
    }
})

define('ninja/tools',[ "ninja/behaviors", "ninja/behavior-collection", "ninja/exceptions",
    "utils", "ninja/root-context"
], function(
    Behaviors,     BehaviorCollection,      Exceptions,
    Utils,     rootContext
    ) {
    var TransformFailedException = Exceptions.TransformFailed
    function log(message) {
        Utils.log(message)
    }

    function Tools(ninja) {
        this.ninja = ninja
        this.behaviorContext = rootContext(this)
    }

    Tools.prototype = {
        //Handy JS things
        forEach: Utils.forEach,
        enrich: function(left, right) {
            return jQuery.extend(left, right)
        },

        ensureDefaults: function(config, defaults) {
            if(!(config instanceof Object)) {
                config = {}
            }
            for(var key in defaults) {
                if(typeof config[key] == "undefined") {
                    if(typeof this.ninja.config[key] != "undefined") {
                        config[key] = this.ninja.config[key]
                    } else if(typeof defaults[key] != "undefined") {
                        config[key] = defaults[key]
                    }
                }
            }
            return config
        },

        //DOM and Events
        getRootOfDocument: function() {
            return jQuery("html") //document.firstChild)
        },
        clearRootCollection: function() {
            this.ninja.behavior = this.ninja.goodBehavior
            this.getRootOfDocument().data("ninja-behavior", null)
        },
        getRootCollection: function() {
            var rootOfDocument = this.getRootOfDocument()
            if(rootOfDocument.data("ninja-behavior") instanceof BehaviorCollection) {
                return rootOfDocument.data("ninja-behavior")
            }

            var collection = new BehaviorCollection(this)
            rootOfDocument.data("ninja-behavior", collection);
            return collection
        },
        addMutationTargets: function(targets) {
            this.getRootCollection().addMutationTargets(targets)
        },
        fireMutationEvent: function() {
            this.getRootCollection().fireMutationEvent()
        },
        detachSyntheticMutationEvents: function() {
            this.getRootCollection().fireMutationEvent = function(){}
            this.getRootCollection().addMutationTargets = function(t){}
        },
        //HTML Utils
        copyAttributes: function(from, to, which) {
            var attributeList = []
            var attrs = []
            var match = new RegExp("^" + which.join("$|^") + "$")
            to = jQuery(to)
            this.forEach(from.attributes, function(att) {
                if(match.test(att.nodeName)) {
                    to.attr(att.nodeName, att.nodeValue)
                }
            })
        },
        deriveElementsFrom: function(element, means){
            switch(typeof means){
                case 'undefined': return element
                case 'string': return jQuery(means)
                case 'function': return means(element)
            }
        },
        extractMethod: function(element, formData) {
            if(element.dataset !== undefined &&
                element.dataset["method"] !== undefined &&
                element.dataset["method"].length > 0) {
                log("Override via dataset: " + element.dataset["method"])
                return element.dataset["method"]
            }
            if(element.dataset === undefined &&
                jQuery(element).attr("data-method") !== undefined) {
                log("Override via data-method: " + jQuery(element).attr("data-method"))
                return jQuery(element).attr("data-method")
            }
            if(typeof formData !== "undefined") {
                for(var i=0, len = formData.length; i<len; i++) {
                    if(formData[i].name == "Method") {
                        log("Override via Method: " + formData[i].value)
                        return formData[i].value
                    }
                }
            }
            if(typeof element.method !== "undefined") {
                return element.method
            }
            return "GET"
        },
        //Ninjascript utils
        cantTransform: function(message) {
            throw new TransformFailedException(message)
        },
        applyBehaviors: function(element, behaviors) {
            this.getRootCollection().apply(element, behaviors)
        },
        message: function(text, classes) {
            var addingMessage = this.ninja.config.messageWrapping(text, classes)
            jQuery(this.ninja.config.messageList).append(addingMessage)
        },
        hiddenDiv: function() {
            var existing = jQuery("div#ninja-hide")
            if(existing.length > 0) {
                return existing[0]
            }

            var hide = jQuery("<div id='ninja-hide'></div>").css("display", "none")
            jQuery("body").append(hide)
            this.getRootCollection().applyBehaviorsTo(hide, [this.ninja.suppressChangeEvents()])
            return hide
        }
    }

    return Tools;
})
define('ninja/configuration',['require','exports','module'],function() {
    return {
        //This is the half-assed: it should be template of some sort
        messageWrapping: function(text, classes) {
            return "<div class='flash " + classes +"'><p>" + text + "</p></div>"
        },
        messageList: "#messages",
        busyLaziness: 200
    }
})
define('ninja/tools/json-dispatcher',["utils"], function(Utils) {
    function JSONDispatcher() {
        this.handlers = []
    }

    JSONDispatcher.prototype = {
        addHandler: function(handler) {
            this.handlers.push(new JSONHandler(handler))
        },
        dispatch: function(json) {
            var len = this.handlers.length
            for(var i = 0; i < len; i++) {
                try {
                    this.handlers[i].receive(json)
                }
                catch(problem) {
                    Utils.log("Caught: " + problem + " while handling JSON response.")
                }
            }
        },
        inspect: function() {
            var handlers = []
            Utils.forEach(this.handlers, function(handler){
                handlers.push(handler.inspect())
            })
            return "JSONDispatcher, " + this.handlers.length + " handlers:\n" + handlers.join("\n")
        }
    }

    function JSONHandler(desc) {
        this.desc = desc
    }

    /**
     * Intention is to use JSONHandler like this:
     *
     * this.ajaxToJson({
     *   item: function(html) {
     *     $('#items').append($(html))
     *   },
     *   item_count: function(html) {
     *     $('#item_count').replace($(html))
     *   }
     *   })
     *
     * And the server sends back something like:
     *
     * { "item": "<li>A list item<\li>", "item_count": 17 }
     **/

    JSONHandler.prototype = {
        receive: function (data) {
            this.compose([], data, this.desc)
            return null
        },
        compose: function(path, data, desc) {
            if(typeof desc == "function") {
                try {
                    desc.call(this, data) //Individual functions can share data through handler
                }
                catch(problem) {
                    Utils.log("Caught: " + problem + " while handling JSON at " + path.join("/"))
                }
            }

            else {
                for(var key in data) {
                    if(data.hasOwnProperty(key)) {
                        if( key in desc) {
                            this.compose(path.concat([key]), data[key], desc[key])
                        }
                    }
                }
            }
            return null
        },
        inspectTree: function(desc) {
            var keys = []
            for(var key in desc) {
                if(typeof desc[key] == "function") {
                    keys.push(key)
                }
                else {
                    Utils.forEach(this.inspectTree(desc[key]), function(subkey) {
                        keys.push(key + "." + subkey)
                    })
                }
            }
            return keys
        },
        inspect: function() {
            return this.inspectTree(this.desc).join("\n")
        }
    }

    return JSONDispatcher
})
define('ninja',["utils", "ninja/tools", "ninja/behaviors", "ninja/configuration", 'ninja/tools/json-dispatcher'],
    function(Utils,     Tools,     Behaviors, Configs, JSONDispatcher) {
        function log(message) {
            Utils.log(message)
        };

        function NinjaScript() {
            //NinjaScript-wide configurations.  Currently, not very many
            this.config = Configs
            this.utils = Utils

            this.behavior = this.goodBehavior
            this.jsonDispatcher = new JSONDispatcher()
            this.tools = new Tools(this)
        }

        NinjaScript.prototype = {

            packageBehaviors: function(callback) {
                var types = {
                    does: Behaviors.base,
                    chooses: Behaviors.meta,
                    selects: Behaviors.select
                }
                result = callback(types)
                this.tools.enrich(this, result)
            },

            packageTools: function(object) {
                this.tools.enrich(Tools.prototype, object)
            },

            configure: function(opts) {
                this.tools.enrich(this.config, opts)
            },

            goodBehavior: function(dispatching) {
                var collection = this.tools.getRootCollection()
                for(var selector in dispatching)
                {
                    if(typeof dispatching[selector] == "undefined") {
                        log("Selector " + selector + " not properly defined - ignoring")
                    }
                    else {
                        collection.addBehavior(selector, dispatching[selector])
                    }
                }
                this.failSafeGo()
            },

            failSafeGo: function() {
                this.failSafeGo = function(){}
                jQuery(window).load( function(){ Ninja.go() } )
            },

            badBehavior: function(nonsense) {
                throw new Error("Called Ninja.behavior() after Ninja.go() - don't do that.  'Go' means 'I'm done, please proceed'")
            },

            respondToJson: function(handlerConfig) {
                this.jsonDispatcher.addHandler(handlerConfig)
            },

            go: function() {
                var Ninja = this

                function handleMutation(evnt) {
                    Ninja.tools.getRootCollection().mutationEventTriggered(evnt);
                }

                if(this.behavior != this.badBehavior) {
                    var rootOfDocument = this.tools.getRootOfDocument()
                    rootOfDocument.bind("DOMSubtreeModified DOMNodeInserted thisChangedDOM", handleMutation);
                    //If we ever receive either of the W3C DOMMutation events, we don't need our IE based
                    //hack, so nerf it
                    rootOfDocument.one("DOMSubtreeModified DOMNodeInserted", function(){
                        Ninja.tools.detachSyntheticMutationEvents()
                    })
                    this.behavior = this.badBehavior
                    this.tools.fireMutationEvent()
                }
            }
        }

        return new NinjaScript()
    })
define('ninja/behaviors/utility',["ninja"], function(Ninja) {
    Ninja.packageBehaviors(function(ninja) {
        return {
            suppressChangeEvents: function() {
                return new ninja.does({
                    events: {
                        DOMSubtreeModified: function(e){},
                        DOMNodeInserted: function(e){}
                    }
                })
            }
        }
    })
})
define('ninja/behaviors/standard',["ninja", "utils"],
    function(Ninja, Utils) {
        function log(message) {
            Utils.log(message)
        }
        Ninja.packageBehaviors( function(ninja){
            return {
                /**
                 * Ninja.submitsAsAjax(configs) -> null
                 * - configs(Object): configuration for the behavior, passed directly
                 *   to either submitsAsAjaxLink or submitsAsAjaxForm
                 *
                 * Converts either a link or a form to send its requests via AJAX - we
                 * eval the Javascript we get back.  We get an busy overlay if
                 * configured to do so.
                 *
                 * This farms out the actual behavior to submitsAsAjaxLink and
                 * submitsAsAjaxForm, c.f.
                 **/
                submitsAsAjax: function(configs) {
                    return new ninja.chooses(function(meta) {
                            meta.asLink = Ninja.submitsAsAjaxLink(configs),
                                meta.asForm = Ninja.submitsAsAjaxForm(configs)
                        },
                        function(elem) {
                            switch(elem.tagName.toLowerCase()) {
                                case "a": return this.asLink
                                case "form": return this.asForm
                            }
                        })
                },


                /**
                 * Ninja.submitAsAjaxLink( configs ) -> null
                 *
                 * Converts a link to send its GET request via Ajax - we assume that we
                 * get Javascript back, which is eval'd.  While we're waiting, we'll
                 * throw up a busy overlay if configured to do so.  By default, we don't
                 * use a busy overlay.
                 *
                 **/
                submitsAsAjaxLink: function(configs) {
                    configs = Ninja.tools.ensureDefaults(configs,
                        { busyElement: function(elem) {
                            return $(elem).parents('address,blockquote,body,dd,div,p,dl,dt,table,form,ol,ul,tr')[0]
                        }})
                    if(!configs.actions) {
                        configs.actions = configs.expectsJSON
                    }

                    return new ninja.does({
                        priority: 10,
                        helpers: {
                            findOverlay: function(elem) {
                                return this.deriveElementsFrom(elem, configs.busyElement)
                            }
                        },
                        events: {
                            click:  function(evnt) {
                                this.overlayAndSubmit(this.visibleElement, evnt.target, evnt.target.href, configs.actions)
                            }
                        }
                    })
                },

                /**
                 * Ninja.submitAsAjaxForm(configs) -> null
                 *
                 * Converts a form to send its request via Ajax - we assume that we get
                 * Javascript back, which is eval'd.  We pull the method from the form:
                 * either from the method attribute itself, a data-method attribute or a
                 * Method input. While we're waiting, we'll throw up a busy overlay if
                 * configured to do so.  By default, we use the form itself as the busy
                 * element.
                 *
                 **/
                submitsAsAjaxForm: function(configs) {
                    configs = Ninja.tools.ensureDefaults(configs,
                        { busyElement: undefined })

                    if(!configs.actions) {
                        configs.actions = configs.expectsJSON
                    }

                    return new ninja.does({
                        priority: 10,
                        helpers: {
                            findOverlay: function(elem) {
                                return this.deriveElementsFrom(elem, configs.busyElement)
                            }
                        },
                        events: {
                            submit: function(evnt) {
                                this.overlayAndSubmit(this.visibleElement, evnt.target, evnt.target.action, configs.actions)
                            }
                        }
                    })
                },


                /**
                 * Ninja.becomesAjaxLink( configs ) -> null
                 *
                 * Converts a whole form into a link that submits via AJAX.  The
                 * intention is that you create a <form> elements with hidden inputs and
                 * a single submit button - then when we transform it, you don't lose
                 * anything in terms of user interface.  Like submitsAsAjaxForm, it will
                 * put up a busy overlay - by default we overlay the element itself
                 **/
                becomesAjaxLink: function(configs) {
                    configs = Ninja.tools.ensureDefaults(configs, {
                        busyElement: undefined,
                        retainedFormAttributes: ["id", "class", "lang", "dir", "title", "data-.*"]
                    })

                    return [ Ninja.submitsAsAjax(configs), Ninja.becomesLink(configs) ]
                },

                /**
                 * Ninja.becomesLink( configs ) -> null
                 *
                 * Replaces a form with a link - the text of the link is based on the
                 * Submit input of the form.  The form itself is pulled out of the
                 * document until the link is clicked, at which point, it gets stuffed
                 * back into the document and submitted, so the link behaves exactly
                 * link submitting the form with its default inputs.  The motivation is
                 * to use hidden-input-only forms for POST interactions, which
                 * Javascript can convert into links if you want.
                 *
                 **/
                becomesLink: function(configs) {
                    configs = Ninja.tools.ensureDefaults(configs, {
                        retainedFormAttributes: ["id", "class", "lang", "dir", "title", "rel", "data-.*"]
                    })

                    return new ninja.does({
                        priority: 30,
                        transform: function(form){
                            var linkText
                            if ((images = jQuery('input[type=image]', form)).size() > 0){
                                image = images[0]
                                linkText = "<img src='" + image.src + "' alt='" + image.alt +"'";
                            }
                            else if((submits = jQuery('input[type=submit]', form)).size() > 0) {
                                submit = submits[0]
                                if(submits.size() > 1) {
                                    log("Multiple submits.  Using: " + submit)
                                }
                                linkText = submit.value
                            } else if((submits = jQuery('button[type=submit]', form)).size() > 0) {
                                submit = submits[0]
                                if(submits.size() > 1) {
                                    log("Multiple submits.  Using: " + submit)
                                }
                                linkText = submit.innerHTML
                            }
                            else {
                                log("Couldn't find a submit input in form");
                                this.cantTransform("Couldn't find a submit input")
                            }

                            var link = jQuery("<a rel='nofollow' href='#'>" + linkText + "</a>")
                            this.copyAttributes(form, link, configs.retainedFormAttributes)
                            this.stash(jQuery(form).replaceWith(link))

                            return link
                        },
                        events: {
                            click: function(evnt, elem){
                                this.cascadeEvent("submit")
                            }
                        }
                    })

                },

                /**
                 * Ninja.decay( configs ) -> null
                 *
                 * Use for elements that should be transient.  For instance, the
                 * default behavior of failed AJAX calls is to insert a message into a
                 * div#messages with a "flash" class.  You can use this behavior to
                 * have those disappear after a few seconds.
                 *
                 * Configs: { lifetime: 10000, diesFor: 600 }
                 **/

                decays: function(configs) {
                    configs = Ninja.tools.ensureDefaults(configs, {
                        lifetime: 10000,
                        diesFor: 600
                    })

                    return new ninja.does({
                        priority: 100,
                        transform: function(elem) {
                            jQuery(elem).delay(configs.lifetime).slideUp(configs.diesFor, function(){
                                jQuery(elem).remove()
                                Ninja.tools.fireMutationEvent()
                            })
                        },
                        events: {
                            click:  [function(event) {
                                jQuery(this.element).remove();
                            }, "changesDOM"]
                        }
                    })
                }
            };
        })
    })
define('ninja/behaviors/placeholder',["ninja"],
    function(Ninja) {
        Ninja.packageBehaviors( function(ninja){
            function placeholderSubmitter(inputBehavior) {
                return new ninja.does({
                    priority: 1000,
                    submit: [function(event, el, oldHandler) {
                        inputBehavior.prepareForSubmit()
                        oldHandler(event)
                    }, "andDoDefault"]
                })
            }

            function grabsPlaceholderText(configs) {
                configs = Ninja.tools.ensureDefaults(configs, {
                    textElementSelector: function(elem) {
                        return "*[data-for=" + elem.id + "]"
                    },
                    findTextElement: function(elem) {
                        var textHolder = $(configs.textElementSelector(elem))
                        if(textHolder.length == 0) {
                            return null
                        }
                        return textHolder[0]
                    }
                })

                return new ninja.does({
                    priority: -10,
                    transform: function(element) {
                        var label = $(configs.findTextElement(element))
                        if( label === null ) {
                            this.cantTransform()
                        }
                        this.placeholderText = label.text()
                        $(element).attr("placeholder", label.text())
                        this.stash(label.detach())
                    }
                })
            }

            //Gratefully borrowed from Modernizr

            var input_placeholder = !!('placeholder' in document.createElement('input'))
            var textarea_placeholder = !!('placeholder' in document.createElement('textarea'))

            if(! input_placeholder) {
                function alternateInput(passwordField, parentForm) {
                    return new ninja.does({
                        helpers: {
                            prepareForSubmit: function() {
                                $(this.element).val('')
                            }
                        },
                        transform: function() {
                            this.applyBehaviors(parentForm, [placeholderSubmitter(this)])
                        },
                        events: {
                            focus: function(event) {
                                var el = $(this.element)
                                var id = el.attr("id")
                                el.attr("id", '')
                                el.replaceWith(passwordField)
                                passwordField.attr("id", id)
                                passwordField.focus()
                            }
                        }
                    })
                }

                function hasPlaceholderPassword(configs) {
                    configs = Ninja.tools.ensureDefaults(configs, {
                        findParentForm: function(elem) {
                            return elem.parents('form')[0]
                        },
                        retainedInputAttributes: [
                            "name", "class", "style", "title", "lang", "dir",
                            "size", "maxlength", "alt", "tabindex", "accesskey",
                            "data-.*"
                        ]
                    })
                    return new ninja.does({
                        priority: 1000,
                        helpers: {
                            swapInAlternate: function() {
                                var el = $(this.element)
                                var id = el.attr("id")
                                if(el.val() == '') {
                                    el.attr("id", '')
                                    el.replaceWith(this.placeholderTextInput)
                                    this.placeholderTextInput.attr('id', id)
                                }
                            }
                        },
                        transform: function(element) {
                            var replacement
                            var el = $(element)

                            replacement = $('<input type="text">')
                            this.copyAttributes(element, replacement, configs.retainedInputAttributes)
                            replacement.addClass("ninja_placeholder")
                            replacement.val(this.placeholderText)

                            var alternate = alternateInput(el, configs.findParentForm(el))
                            this.applyBehaviors(replacement, [alternate])

                            this.placeholderTextInput = replacement
                            this.swapInAlternate()

                            return element
                        },
                        events: {
                            blur: function(event) {
                                this.swapInAlternate()
                            }
                        }
                    })
                }
            }

            if((!input_placeholder) || (!textarea_placeholder)) {
                function hasPlaceholderText(configs) {
                    configs = Ninja.tools.ensureDefaults(configs, {
                        findParentForm: function(elem) {
                            return elem.parents('form')[0]
                        }
                    })
                    return new ninja.does({
                        priority: 1000,
                        helpers: {
                            prepareForSubmit: function() {
                                if($(this.element).hasClass('ninja_placeholder')) {
                                    $(this.element).val('')
                                }
                            }
                        },
                        transform: function(element) {
                            var el = $(element)
                            el.addClass('ninja_placeholder')
                            el.val(this.placeholderText)

                            this.applyBehaviors(configs.findParentForm(el), [placeholderSubmitter(this)])

                            return element
                        },
                        events: {
                            focus: function(event) {
                                if($(this.element).hasClass('ninja_placeholder')) {
                                    $(this.element).removeClass('ninja_placeholder').val('')
                                }
                            },
                            blur: function(event) {
                                if($(this.element).val() == '') {
                                    $(this.element).addClass('ninja_placeholder').val(this.placeholderText)
                                }
                            }
                        }
                    })
                }
            }

            return {
                hasPlaceholder: function(configs) {
                    var behaviors = [grabsPlaceholderText(configs)]
                    if(!input_placeholder || !textarea_placeholder) {
                        behaviors.push(
                            new ninja.chooses(function(meta) {
                                    if(input_placeholder) {
                                        meta.asTextInput = null
                                        meta.asPassword = null
                                    } else {
                                        meta.asTextInput = hasPlaceholderText(configs)
                                        meta.asPassword = hasPlaceholderPassword(configs)
                                    }

                                    if( textarea_placeholder) {
                                        meta.asTextArea = null
                                    } else {
                                        meta.asTextArea = hasPlaceholderText(configs)
                                    }
                                },
                                function(elem) {
                                    elem = $(elem)
                                    if(elem.is("input[type=text]")) {
                                        return this.asTextInput
                                    }
                                    else if(elem.is("textarea")) {
                                        return this.asTextArea
                                    }
                                    else if(elem.is("input[type=password]")) {
                                        return this.asPassword
                                    }
                                }))
                    }
                    return behaviors
                }
            }
        })
    })
define('ninja/behaviors/trigger-on',["ninja"],
    function(Ninja) {
        Ninja.packageBehaviors( function(ninja) {
            return {
                triggersOnSelect: function(configs) {
                    configs = Ninja.tools.ensureDefaults(configs,
                        {
                            busyElement: undefined,
                            placeholderText: "Select to go",
                            placeholderValue: "instructions"
                        })
                    var jsonActions = configs
                    if (typeof(configs.actions) === "object") {
                        jsonActions = configs.actions
                    }

                    return new ninja.does({
                        priority: 20,
                        helpers: {
                            findOverlay: function(elem) {
                                return this.deriveElementsFrom(elem, configs.busyElement)
                            }
                        },
                        transform: function(form) {
                            var select = $(form).find("select").first()
                            if( typeof select == "undefined" ) {
                                this.cantTransform()
                            }
                            select.prepend("<option value='"+ configs.placeholderValue  +"'> " + configs.placeholderText + "</option>")
                            select.val(configs.placeholderValue)
                            $(form).find("input[type='submit']").remove()
                            return form
                        },
                        events: {
                            change: [
                                function(evnt, elem) {
                                    this.overlayAndSubmit(elem, elem.action, jsonActions)

                                }, "andDoDefault" ]
                        }

                    })
                }
            };
        })
    })
define('ninja/behaviors/confirm',["ninja"],
    function(Ninja){
        Ninja.packageBehaviors( function(ninja) {
            return {
                confirms: function(configs) {

                    configs = Ninja.tools.ensureDefaults(configs,
                        { confirmMessage: function(elem){
                            return $(elem).attr('data-confirm')
                        }})
                    if(typeof configs.confirmMessage == "string"){
                        message = configs.confirmMessage
                        configs.confirmMessage = function(elem){
                            return message
                        }
                    }

                    function confirmDefault(event,elem) {
                        if(!confirm(configs.confirmMessage(elem))) {
                            event.preventDefault()
                            event.preventFallthrough()
                        }
                    }

                    return new ninja.selects({
                        "form": new ninja.does({
                            priority: 20,
                            events: { submit: [confirmDefault, "andDoDefault"] }
                        }),
                        "a,input": new ninja.does({
                            priority: 20,
                            events: {  click: [confirmDefault, "andDoDefault"] }
                        })
                    })
                }
            }
        })
    })
define('ninja/behaviors/all',[
    "./utility",
    "./standard",
    "./placeholder",
    "./trigger-on",
    "./confirm"
],
    function(){})
define('ninja/tools/overlay',["utils", "ninja"],
    function(Utils, Ninja) {
        var forEach = Utils.forEach

        function Overlay(list) {
            var elements = this.convertToElementArray(list)
            this.laziness = 0
            var ov = this
            this.set = jQuery(jQuery.map(elements, function(element, idx) {
                return ov.buildOverlayFor(element)
            }))
        }

        Overlay.prototype = {
            convertToElementArray: function(list) {
                var h = this
                switch(typeof list) {
                    case 'undefined': return []
                    case 'boolean': return []
                    case 'string': return h.convertToElementArray(jQuery(list))
                    case 'function': return h.convertToElementArray(list())
                    case 'object': {
                        //IE8 barfs on 'list instanceof Element'
                        if("focus" in list && "blur" in list && !("jquery" in list)) {
                            return [list]
                        }
                        else if("length" in list && "0" in list) {
                            var result = []
                            forEach(list, function(element) {
                                result = result.concat(h.convertToElementArray(element))
                            })
                            return result
                        }
                        else {
                            return []
                        }
                    }
                }
            },

            buildOverlayFor: function(elem) {
                var overlay = jQuery(document.createElement("div"))
                var hideMe = jQuery(elem)
                var offset = hideMe.offset()
                overlay.css("position", "absolute")
                overlay.css("top", offset.top)
                overlay.css("left", offset.left)
                overlay.width(hideMe.outerWidth())
                overlay.height(hideMe.outerHeight())
                overlay.css("zIndex", "2")
                overlay.css("display", "none")
                return overlay[0]
            },
            affix: function() {
                this.set.appendTo(jQuery("body"))
                overlaySet = this.set
                window.setTimeout(function() {
                    overlaySet.css("display", "block")
                }, this.laziness)
            },
            remove: function() {
                this.set.remove()
            }
        }


        Ninja.packageTools({
            overlay: function() {
                // I really liked using
                //return new Overlay([].map.apply(arguments,[function(i) {return i}]))
                //but IE8 doesn't implement ECMA 2.6.2 5th ed.

                return new Overlay(jQuery.makeArray(arguments))
            },
            busyOverlay: function(elem) {
                var overlay = this.overlay(elem)
                overlay.set.addClass("ninja_busy")
                overlay.laziness = this.ninja.config.busyLaziness
                return overlay
            },
            //Currently, this doesn't respect changes to the original block...
            //There should be an "Overlay behavior" that gets applied
            buildOverlayFor: function(elem) {
                var overlay = jQuery(document.createElement("div"))
                var hideMe = jQuery(elem)
                var offset = hideMe.offset()
                overlay.css("position", "absolute")
                overlay.css("top", offset.top)
                overlay.css("left", offset.left)
                overlay.width(hideMe.outerWidth())
                overlay.height(hideMe.outerHeight())
                overlay.css("zIndex", "2")
                return overlay
            }
        })

        return Overlay
    })

define('ninja/tools/ajax-submitter',["ninja", "utils", "./json-dispatcher", "./overlay"], function(Ninja, Utils, jH, O) {
    function log(message) {
        Utils.log(message)
    }

    function AjaxSubmitter() {
        this.formData = []
        this.action = "/"
        this.method = "GET"
        this.dataType = 'script'

        return this
    }

    AjaxSubmitter.prototype = {
        submit: function() {
            log("Computed method: " + this.method)
            jQuery.ajax(this.ajaxData())
        },

        sourceForm: function(form) {
            this.formData = jQuery(form).serializeArray()
        },

        ajaxData: function() {
            return {
                data: this.formData,
                dataType: this.dataType,
                url: this.action,
                type: this.method,
                complete: this.responseHandler(),
                success: this.successHandler(),
                error: this.onError
            }
        },

        successHandler: function() {
            var submitter = this
            return function(data, statusTxt, xhr) {
                submitter.onSuccess(xhr, statusTxt, data)
            }
        },

        responseHandler: function() {
            var submitter = this
            return function(xhr, statusTxt) {
                submitter.onResponse(xhr, statusTxt)
                Ninja.tools.fireMutationEvent()
            }
        },

        onResponse: function(xhr, statusTxt) {
        },
        onSuccess: function(xhr, statusTxt, data) {
        },
        onError: function(xhr, statusTxt, errorThrown) {
            log(xhr.responseText)
            Ninja.tools.message("Server error: " + xhr.statusText, "error")
        }
    }


    Ninja.packageTools({
        ajaxSubmitter: function() {
            return new AjaxSubmitter()
        },

        ajaxToJson: function(desc) {
            var submitter = this.ajaxSubmitter()
            submitter.dataType = 'json'
            submitter.onSuccess = function(xhr, statusText, data) {
                Ninja.jsonDispatcher.dispatch(data)
            }
            return submitter
        },

        overlayAndSubmit: function(overlaid, target, action, jsonHandling) {
            var overlay = this.busyOverlay(this.findOverlay(overlaid))

            var submitter
            if( typeof jsonHandling == "undefined" ) {
                submitter = this.ajaxSubmitter()
            }
            else {
                submitter = this.ajaxToJson(jsonHandling)
            }

            submitter.sourceForm(target)

            submitter.action = action
            submitter.method = this.extractMethod(target, submitter.formData)

            submitter.onResponse = function(xhr, statusTxt) {
                overlay.remove()
            }
            overlay.affix()
            submitter.submit()
        }
    })


    return AjaxSubmitter
})
define('ninja/tools/all',[
    "./overlay",
    "./ajax-submitter",
    "./json-dispatcher"
],
    function() { })
define('ninja/jquery',["ninja"], function(Ninja) {
    jQuery.extend(
        {
            ninja: Ninja,
            behavior: Ninja.behavior
        }
    );
})
window["Ninja"] = {
    orderList: [],
    orders: function(order_func){
        this.orderList.push(order_func)
    }
}
require([
    "ninja",
    "ninja/behaviors/all",
    "ninja/tools/all",
    "ninja/jquery"
], function(Ninja, stdBehaviors, allTools, jquery) {
    var ninjaOrders = window["Ninja"].orderList
    var ordersLength = ninjaOrders.length

    window["Ninja"] = Ninja
    Ninja['behavior'] = Ninja.behavior
    for(var i = 0; i < ordersLength; i++) {
        ninjaOrders[i](Ninja)
    }
    Ninja.orders = function(funk) {
        funk(this) //because it amuses JDL, that's why.
    }
})
define("main", function(){});
