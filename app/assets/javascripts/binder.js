// Polyfill for binding in JS -- uses underscore.js source without the rest

var Binder = {
  nativeBind: Function.prototype.bind,
  isFunction: function(obj) {
    return typeof obj === 'function';
  },
  bind: function(func, context) {
    var args, bound;
    if (Binder.nativeBind && func.bind === Binder.nativeBind) return Binder.nativeBind.apply(func, Array.prototype.slice.call(arguments, 1));
    if (Binder.isFunction(func)) throw new TypeError;
    args = Array.prototype.slice.call(arguments, 2);
    return bound = function() {
      if (!(this instanceof bound)) return func.apply(context, args.concat(Array.prototype.slice.call(arguments)));
      ctor.prototype = func.prototype;
      var self = new ctor;
      ctor.prototype = null;
      var result = func.apply(self, args.concat(Array.prototype.slice.call(arguments)));
      if (Object(result) === result) return result;
      return self;
    };
  },

  functions: function(obj) {
    var names = [];
    for (var key in obj) {
      if (Binder.isFunction(obj[key])) names.push(key);
    }
    return names.sort();
  },

  bindAll: function(obj) {
    var funcs = Array.prototype.slice.call(arguments, 1);
    if (funcs.length === 0) funcs = Binder.functions(obj);
    funcs.forEach(function(f) {  obj[f] = Binder.bind(obj[f], obj);});
    return obj;
  }
}