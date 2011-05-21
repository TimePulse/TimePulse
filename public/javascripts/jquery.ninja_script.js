/* 
 * NinjaScript - 0.8.3
 * written by and copyright 2010-2011 Judson Lester and Logical Reality Design
 * Licensed under the MIT license
 * 2011-02-04
 *
 * Those new to this source should skim down to standardBehaviors
 */
Ninja = (function() {
    function log(message) {
      if(false) { //LOGGING TURNED OFF IS 100% faster!
        try {
          console.log(message)
        }
        catch(e) {} //we're in IE or FF w/o Firebug or something
      }
    }

  function isArray(candidate) {
    return (candidate.constructor == Array)
  }

  function forEach(list, callback, thisArg) {
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

  function NinjaScript() {
    //NinjaScript-wide configurations.  Currently, not very many
    this.config = {
      //This is the half-assed: it should be template of some sort
      messageWrapping: function(text, classes) {
        return "<div class='flash " + classes +"'><p>" + text + "</p></div>"
      },
      messageList: "#messages",
      busyLaziness: 200
    }


    this.behavior = this.goodBehavior
    this.tools = new Tools(this)
  }

  NinjaScript.prototype = {

    packageBehaviors: function(callback) {
      var types = {
        does: Behavior,
        chooses: Metabehavior,
        selects: Selectabehavior
      }
      result = callback(types)
      this.tools.enrich(this, result)
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
      jQuery(window).load( function(){ Ninja.go() } )
    },

    badBehavior: function(nonsense) {
      throw new Error("Called Ninja.behavior() after Ninja.go() - don't do that.  'Go' means 'I'm done, please proceed'")
    },

    go: function() {
      if(this.behavior != this.misbehavior) {
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


  function Tools(ninja) {
    this.ninja = ninja
  }

  Tools.prototype = {
    //Handy JS things
    forEach: forEach,
    enrich: function(left, right) {
      return jQuery.extend(left, right)
    },
    ensureDefaults: function(config, defaults) {
      if(!config instanceof Object) {
        config = {}
      }
      return this.enrich(defaults, config)
    },
    //DOM and Events
    getRootOfDocument: function() {
      return jQuery("html") //document.firstChild)
    },
    clearRootCollection: function() {
      Ninja.behavior = Ninja.goodBehavior
      this.getRootOfDocument().data("ninja-behavior", null)
    },
    getRootCollection: function() {
      var rootOfDocument = this.getRootOfDocument()
      if(rootOfDocument.data("ninja-behavior") instanceof BehaviorCollection) {
        return rootOfDocument.data("ninja-behavior")
      }

      var collection = new BehaviorCollection()
      rootOfDocument.data("ninja-behavior", collection);
      return collection
    },
    suppressChangeEvents: function() {
      return new Behavior({
          events: {
            DOMSubtreeModified: function(e){},
            DOMNodeInserted: function(e){}
          }
        })
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
    cantTransform: function() {
      throw new TransformFailedException
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
      Ninja.tools.getRootCollection().applyBehaviorsTo(hide, [Ninja.tools.suppressChangeEvents()])
      return hide
    },
    ajaxSubmitter: function(form) {
      return new AjaxSubmitter(form)
    },
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
  }

  var Ninja = new NinjaScript();
  //Below here is the dojo - the engines that make NinjaScript work.
  //With any luck, only the helpful and curious should have call to keep
  //reading
  //

  function handleMutation(evnt) {
    Ninja.tools.getRootCollection().mutationEventTriggered(evnt);
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

  function EventScribe() {
    this.handlers = {}
    this.currentElement = null
  }

  EventScribe.prototype = {
    makeHandlersRemove: function(element) {
      for(var eventName in this.handlers) {
        var handler = this.handlers[eventName]
        this.handlers[eventName] = function(eventRecord) {
          handler.call(this, eventRecord)
          jQuery(element).remove()
        }
      }
    },
    recordEventHandlers: function (context, behavior) {
      if(this.currentElement !== context.element) {
        if(this.currentElement !== null) {
          this.makeHandlersRemove(this.currentElement)
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

  function TransformFailedException(){}
  function CouldntChooseException() { }

  function RootContext() {
    this.stashedElements = []
    this.eventHandlerSet = {}
  }

  RootContext.prototype = Ninja.tools.enrich(
    new Tools(Ninja),
    {
      stash: function(element) {
        this.stashedElements.unshift(element)
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

  function BehaviorCollection() {
    this.lexicalCount = 0
    this.eventQueue = []
    this.behaviors = {}
    this.selectors = []
    this.mutationTargets = []
    return this
  }

  BehaviorCollection.prototype = {
    //XXX: check if this is source of new slowdown
    addBehavior: function(selector, behavior) {
      if(isArray(behavior)) {
        forEach(behavior, function(behaves){
            this.addBehavior(selector, behaves)
          }, this)
      }
      else if(behavior instanceof Behavior) {
        this.insertBehavior(selector, behavior)
      } 
      else if(behavior instanceof Selectabehavior) {
        this.insertBehavior(selector, behavior)
      }
      else if(behavior instanceof Metabehavior) {
        this.insertBehavior(selector, behavior)
      }
      else if(typeof behavior == "function"){
        this.addBehavior(selector, behavior())
      }
      else {
        var behavior = new Behavior(behavior)
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
      this.mutationTargets = this.mutationTargets.concat(target)
    },
    fireMutationEvent: function() {
      var targets = this.mutationTargets
      if (targets.length > 0 ) {
        for(var target = targets.shift(); 
          targets.length > 0; 
          target = targets.shift()) {
          jQuery(target).trigger("thisChangedDOM")
        }
      }
      else {
        Ninja.tools.getRootOfDocument().trigger("thisChangedDOM")
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
      return this.applyBehaviorsInContext(new RootContext, element, behaviors)
    },
    applyBehaviorsInContext: function(context, element, behaviors) {
      var curContext, 
      applyList = [], 
      scribe = new EventScribe
      Ninja.tools.enrich(scribe.handlers, context.eventHandlerSet)

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
          //XXX This needs to have exception handling back
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
      jQuery(element).data("ninja-visited", context)

      scribe.applyEventHandlers(element)
      Ninja.tools.enrich(context.eventHandlerSet, scribe.handlers)

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
        jQuery(root).find(this.selectors[i]).each( 
          function(index, elem){
            if (!jQuery(elem).data("ninja-visited")) { //Pure optimization
              collection.apply(elem, [], i)
            }
          }
        )
      }
    }
  }

  function Metabehavior(setup, callback) {
    setup(this)
    this.chooser = callback
  }

  Metabehavior.prototype = {
    choose: function(element) {
      var chosen = this.chooser(element)
      if(chosen !== undefined) {
        return chosen.choose(element)
      }
      else {
        throw new CouldntChooseException
      }
    }
  }

  //For these to be acceptable, I need to fit them into the pattern that
  //Ninja.behavior accepts...
  function Selectabehavior(menu) {
    this.menu = menu
  }

  Selectabehavior.prototype = {
    choose: function(element) {
      for(var selector in this.menu) {
        if(jQuery(element).is(selector)) {
          return this.menu[selector].choose(element)
        }
      }
      return null //XXX Should raise exception
    }
  }

  function Behavior(handlers) {
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
  Behavior.prototype = {   
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
          if (config[i] == "andDoDefault" || config[i] == "allowDefault") {
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
        }
      }
      var handler = function(eventRecord) {
        handle.call(context, eventRecord, this, previousHandler)
        return !stopDefault
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

      return handler
    },
    prependAction: function(handler, doWhat) {
      return function(eventRecord) {
        doWhat.call(this, eventRecord)
        handler.call(this, eventRecord)
      }
    },
    appendAction: function(handler, doWhat) {
      return function(eventRecord) {
        handler.call(this, eventRecord)
        doWhat.call(this, eventRecord)
      }
    },
    transform: function(elem){ 
      return elem 
    }
  }

  return Ninja;  
})();

(function() {
  function standardBehaviors(ninja){
    return {
      // START READING HERE
      //Stock behaviors

      //Converts either a link or a form to send its requests via AJAX - we eval
      //the Javascript we get back.  We get an busy overlay if configured to do
      //so.
      //
      //This farms out the actual behavior to submitsAsAjaxLink and
      //submitsAsAjaxForm, c.f.
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


      //Converts a link to send its GET request via Ajax - we assume that we get
      //Javascript back, which is eval'd.  While we're waiting, we'll throw up a
      //busy overlay if configured to do so.  By default, we don't use a busy
      //overlay.
      //
      //Ninja.submitAsAjaxLink({
      //  busyElement: function(elem) { elem.parent }
      //})
      //
      submitsAsAjaxLink: function(configs) {
        configs = Ninja.tools.ensureDefaults(configs,
          { busyElement: function(elem) {
              return $(elem).parents('address,blockquote,body,dd,div,p,dl,dt,table,form,ol,ul,tr')[0]
            }})

        return new ninja.does({
            priority: 10,
            helpers: {
              findOverlay: function(elem) {
                return this.deriveElementsFrom(elem, configs.busyElement)
              }
            },
            events: {
              click:  function(evnt) {
                var overlay = this.busyOverlay(this.findOverlay(evnt.target))
                var submitter = this.ajaxSubmitter()
                submitter.action = evnt.target.href
                submitter.method = this.extractMethod(evnt.target)

                submitter.onResponse = function(xhr, statusTxt) {
                  overlay.remove()
                }
                overlay.affix()
                submitter.submit()						
              }
            }
          })
      },

      //Converts a form to send its request via Ajax - we assume that we get
      //Javascript back, which is eval'd.  We pull the method from the form:
      //either from the method attribute itself, a data-method attribute or a
      //Method input. While we're waiting, we'll throw up a busy overlay if
      //configured to do so.  By default, we use the form itself as the busy
      //element.
      //
      //Ninja.submitAsAjaxForm({
      //  busyElement: function(elem) { elem.parent }
      //})
      //
      submitsAsAjaxForm: function(configs) {
        configs = Ninja.tools.ensureDefaults(configs,
          { busyElement: undefined })

        return new ninja.does({
            priority: 20,
            helpers: {
              findOverlay: function(elem) {
                return this.deriveElementsFrom(elem, configs.busyElement)
              }
            },
            events: {
              submit: function(evnt) {
                var overlay = this.busyOverlay(this.findOverlay(evnt.target))
                var submitter = this.ajaxSubmitter()
                submitter.formData = jQuery(evnt.target).serializeArray()
                submitter.action = evnt.target.action
                submitter.method = this.extractMethod(evnt.target, submitter.formData)

                submitter.onResponse = function(xhr, statusTxt) {
                  overlay.remove()
                }
                overlay.affix()
                submitter.submit()
              }
            }
          })
      },


      //Converts a whole form into a link that submits via AJAX.  The intention
      //is that you create a <form> elements with hidden inputs and a single
      //submit button - then when we transform it, you don't lose anything in
      //terms of user interface.  Like submitsAsAjaxForm, it will put up a
      //busy overlay - by default we overlay the element itself
      //
      //this.becomesAjaxLink({
      //  busyElement: function(elem) { jQuery("#user-notification") }
      //})
      becomesAjaxLink: function(configs) {
        configs = Ninja.tools.ensureDefaults(configs, {
            busyElement: undefined,
            retainAttributes: ["id", "class", "lang", "dir", "title", "data-.*"]
          })

        return [ Ninja.submitsAsAjax(configs), Ninja.becomesLink(configs) ]
      },

      //Replaces a form with a link - the text of the link is based on the Submit
      //input of the form.  The form itself is pulled out of the document until
      //the link is clicked, at which point, it gets stuffed back into the
      //document and submitted, so the link behaves exactly link submitting the
      //form with its default inputs.  The motivation is to use hidden-input-only
      //forms for POST interactions, which Javascript can convert into links if
      //you want.
      becomesLink: function(configs) {
        configs = Ninja.tools.ensureDefaults(configs, {
            retainAttributes: ["id", "class", "lang", "dir", "title", "rel", "data-.*"]
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
              } 
              else {
                log("Couldn't find a submit input in form");
                this.cantTransform()
              }

              var link = jQuery("<a rel='nofollow' href='#'>" + linkText + "</a>")
              this.copyAttributes(form, link, configs.retainAttributes)
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

      //Use for elements that should be transient.  For instance, the default
      //behavior of failed AJAX calls is to insert a message into a
      //div#messages with a "flash" class.  You can use this behavior to have
      //those disappear after a few seconds.
      //
      //Configs:
      //{ lifetime: 10000, diesFor: 600 }

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
  }

  Ninja.packageBehaviors(standardBehaviors)
})();

(function($){
    function uiBehaviors(ninja){
      function watermarkedSubmitter(inputBehavior) {
        return new ninja.does({
            priority: 1000,
            submit: [function(event, el, oldHandler) {
                inputBehavior.prepareForSubmit()
                oldHandler(event)
              }, "andDoDefault"]
          })
      }
      function isWatermarkedPassword(configs) {
        return new ninja.does({
            priority: 1000,
            helpers: {
              prepareForSubmit: function() {
                if($(this.element).hasClass('ninja_watermarked')) {
                  $(this.element).val('')
                }
              },
            },
            transform: function(element) {
              var label = $('label[for=' + $(element)[0].id + ']')
              if(label.length == 0) {
                this.cantTransform()
              }
              label.addClass('ninja_watermarked')
              this.watermarkText = label.text()

              var el = $(element)
              el.addClass('ninja_watermarked')
              el.val(this.watermarkText)
              el.attr("type", "text")

              this.applyBehaviors(el.parents('form')[0], [watermarkedSubmitter(this)])

              return element
            },
            events: {
              focus: function(event) {
                $(this.element).removeClass('ninja_watermarked').val('').attr("type", "password")
              },
              blur: function(event) {
                if($(this.element).val() == '') {
                  $(this.element).addClass('ninja_watermarked').val(this.watermarkText).attr("type", "text")
                }
              }
            }
          })
      }

      function isWatermarkedText(configs) {
        return new ninja.does({
            priority: 1000,
            helpers: {
              prepareForSubmit: function() {
                if($(this.element).hasClass('ninja_watermarked')) {
                  $(this.element).val('')
                }
              },
            },
            transform: function(element) {
              var label = $('label[for=' + $(element)[0].id + ']')
              if(label.length == 0) {
                this.cantTransform()
              }
              label.addClass('ninja_watermarked')
              this.watermarkText = label.text()
              var el = $(element)
              el.addClass('ninja_watermarked')
              el.val(this.watermarkText)

              this.applyBehaviors(el.parents('form')[0], [watermarkedSubmitter(this)])

              return element
            },
            events: {
              focus: function(event) {
                if($(this.element).hasClass('ninja_watermarked')) {
                  $(this.element).removeClass('ninja_watermarked').val('')
                }
              },
              blur: function(event) {
                if($(this.element).val() == '') {
                  $(this.element).addClass('ninja_watermarked').val(this.watermarkText)
                }
              }
            }
          })
      }

      return {
        isWatermarked: function(configs) {
          return new ninja.chooses(function(meta) {
              meta.asText = isWatermarkedText(configs)
              meta.asPassword = isWatermarkedPassword(configs)
            },
            function(elem) {
              if($(elem).is("input[type=text],textarea")) {
                return this.asText
              }
              //Seems IE has a thing about changing input types...
              //We'll get back to this one
//              else if($(elem).is("input[type=password]")){
//                return this.asPassword
//              }
            })
        }
      }
    }

    Ninja.packageBehaviors(uiBehaviors)
  })(jQuery);


//This exists to carry over interfaces from earlier versions of Ninjascript.  Likely, it will be removed from future versions of NinjaScript
( function($) {
    $.extend(
      {
        ninja: Ninja,
        behavior: Ninja.behavior
      }
    );
  }
)(jQuery);
