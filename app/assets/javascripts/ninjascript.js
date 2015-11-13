/*
 * NinjaScript - 0.12.0
 * written by and copyright 2010-2014 Judson Lester and Logical Reality Design
 * Licensed under the MIT license
 *
 * 02-03-2014
 */
var ninjascript = {behaviors:{}};
ninjascript.behaviors.Abstract = function() {
};
(function() {
  ninjascript.behaviors.Abstract.prototype.expandRules = function(a) {
    return[]
  }
})();
ninjascript.behaviors.Select = function(a) {
  this.menu = a
};
ninjascript.behaviors.Select.prototype = new ninjascript.behaviors.Abstract;
(function() {
  ninjascript.behaviors.Select.prototype.choose = function(a) {
    for(var f in this.menu) {
      if(jQuery(a).is(f)) {
        return this.menu[f].choose(a)
      }
    }
    return null
  }
})();
ninjascript.configuration = {messageWrapping:function(a, f) {
  return"<div class='flash " + f + "'><p>" + a + "</p></div>"
}, messageList:"#messages", busyLaziness:200};
ninjascript.exceptions = {};
(function() {
  function a(a) {
    var c = function(b) {
      Error.call(this, b);
      Error.captureStackTrace && Error.captureStackTrace(this, this.constructor);
      this.name = a;
      this.message = b
    };
    c.prototype = Error();
    return c
  }
  ninjascript.exceptions.CouldntChoose = a("CouldntChoose");
  ninjascript.exceptions.TransformFailed = a("TransformFailed")
})();
ninjascript.behaviors.Meta = function(a) {
  this.chooser = a
};
ninjascript.behaviors.Meta.prototype = new ninjascript.behaviors.Abstract;
(function() {
  ninjascript.behaviors.Meta.prototype.choose = function(a) {
    var f = this.chooser(a);
    if(void 0 !== f) {
      return f.choose(a)
    }
    throw new ninjascript.exceptions.CouldntChoose("Couldn't choose behavior for " + a.toString());
  }
})();
ninjascript.Extensible = function() {
};
ninjascript.Extensible.addPackage = function(a, f) {
  var c = {}, b = function(b) {
    return function(c) {
      for(functionName in c) {
        c.hasOwnProperty(functionName) && (b[functionName] = c[functionName])
      }
    }
  };
  c.Ninja = b(a.Ninja);
  c.tools = b(a.tools);
  c.behaviors = c.Ninja;
  c.behaviours = c.Ninja;
  c.ninja = c.Ninja;
  return f(c)
};
(function() {
  ninjascript.Extensible.prototype.inject = function(a) {
    this.extensions = a;
    for(property in a) {
      a.hasOwnProperty(property) && (this[property] = a[property])
    }
  }
})();
ninjascript.Logger = function(a, f, c) {
  this.name = a;
  this.config = f;
  this.parentLogger = c
};
ninjascript.LoggerConfig = function(a) {
  this.logger = a
};
(function() {
  var a = ninjascript.Logger.prototype;
  a.logWithLevel = function(a, c, b) {
    c.unshift([this.name, this.getLevel()]);
    a <= this.getLevel() ? this.actuallyLog(a, c, b) : this.parentLogger && this.parentLogger.logWithLevel(a, c, b)
  };
  a.actuallyLog = function(a, c, b) {
    var d = a + ":", e = [];
    for(a = 0;a < c.length;a++) {
      d = d + "[" + c[a][0] + ":" + c[a][1] + "]"
    }
    e.push(d);
    for(a = 0;a < b.length;a++) {
      e.push(b[a])
    }
    try {
      console.log.apply(console, e)
    }catch(g) {
    }
  };
  a.getLevel = function() {
    return this.config.level
  };
  a.childLogger = function(a, c) {
    var b = {level:c || 0};
    this.config[a] = b;
    return new ninjascript.Logger(a, b, this)
  };
  a.fatal = function() {
    this.logWithLevel(0, [], arguments)
  };
  a.error = function() {
    this.logWithLevel(1, [], arguments)
  };
  a.warn = function() {
    this.logWithLevel(2, [], arguments)
  };
  a.info = function() {
    this.logWithLevel(3, [], arguments)
  };
  a.debug = function() {
    this.logWithLevel(4, [], arguments)
  };
  a.log = a.error
})();
(function() {
  ninjascript.Logger.rootConfig = {level:0};
  ninjascript.Logger.rootLogger = new ninjascript.Logger("root", ninjascript.Logger.rootConfig);
  ninjascript.Logger.forComponent = function(a, f) {
    return ninjascript.Logger.rootLogger.childLogger(a, f)
  }
})();
ninjascript.behaviors.EventHandlerConfig = function(a, f) {
  this.name = a;
  this.stopPropagate = this.stopDefault = this.fallThrough = !0;
  this.fireMutation = this.stopImmediate = !1;
  this.normalizeConfig(f)
};
(function() {
  var a = ninjascript.behaviors.EventHandlerConfig.prototype, f = ninjascript.Logger.forComponent("event-handler");
  a.normalizeConfig = function(c) {
    if("function" == typeof c) {
      this.handle = c
    }else {
      this.handle = c[0];
      f.info(c);
      c = c.slice(1, c.length);
      for(var b = c.length, a = 0;a < b;a++) {
        if("dontContinue" == c[a] || "overridesOthers" == c[a]) {
          this.fallThrough = !1
        }
        if("andDoDefault" == c[a] || "continues" == c[a] || "allowDefault" == c[a]) {
          this.stopDefault = !1
        }
        if("allowPropagate" == c[a] || "dontStopPropagation" == c[a]) {
          this.stopPropagate = !1
        }
        "andDoOthers" == c[a] && (this.stopImmediate = !1);
        "changesDOM" == c[a] && (this.fireMutation = !0)
      }
    }
  };
  a.buildHandlerFunction = function(a) {
    var b = this.handle, d = this, e = function(e) {
      b.apply(this, arguments);
      e.isFallthroughPrevented() || "undefined" === typeof a || a.apply(this, arguments);
      return d.stopDefault ? !1 : !e.isDefaultPrevented()
    };
    this.fallThrough || (e = this.prependAction(e, function(b) {
      b.preventFallthrough()
    }));
    this.stopDefault && (e = this.prependAction(e, function(b) {
      b.preventDefault()
    }));
    this.stopPropagate && (e = this.prependAction(e, function(b) {
      b.stopPropagation()
    }));
    this.stopImmediate && (e = this.prependAction(e, function(b) {
      b.stopImmediatePropagation()
    }));
    this.fireMutation && (e = this.appendAction(e, function(b) {
      d.fireMutationEvent()
    }));
    e = this.prependAction(e, function(b) {
      b.isFallthroughPrevented = function() {
        return!1
      };
      b.preventFallthrough = function() {
        b.isFallthroughPrevented = function() {
          return!0
        }
      }
    });
    return e = this.prependAction(e, function(b) {
      f.debug(b)
    })
  };
  a.prependAction = function(a, b) {
    return function() {
      b.apply(this, arguments);
      return a.apply(this, arguments)
    }
  };
  a.appendAction = function(a, b) {
    return function() {
      var d = a.apply(this, arguments);
      b.apply(this, arguments);
      return d
    }
  }
})();
ninjascript.sizzle = function() {
  function a(h) {
    for(var b = "", c, d = 0;h[d];d++) {
      c = h[d], 3 === c.nodeType || 4 === c.nodeType ? b += c.nodeValue : 8 !== c.nodeType && (b += a(c.childNodes))
    }
    return b
  }
  function f(h, b, a, c, d, e) {
    d = 0;
    for(var f = c.length;d < f;d++) {
      var g = c[d];
      if(g) {
        for(var g = g[h], k = !1;g;) {
          if(g.sizcache === a) {
            k = c[g.sizset];
            break
          }
          1 !== g.nodeType || e || (g.sizcache = a, g.sizset = d);
          if(g.nodeName.toLowerCase() === b) {
            k = g;
            break
          }
          g = g[h]
        }
        c[d] = k
      }
    }
  }
  function c(h, b, a, c, d, e) {
    d = 0;
    for(var f = c.length;d < f;d++) {
      var g = c[d];
      if(g) {
        for(var g = g[h], k = !1;g;) {
          if(g.sizcache === a) {
            k = c[g.sizset];
            break
          }
          if(1 === g.nodeType) {
            if(e || (g.sizcache = a, g.sizset = d), "string" !== typeof b) {
              if(g === b) {
                k = !0;
                break
              }
            }else {
              if(0 < l.filter(b, [g]).length) {
                k = g;
                break
              }
            }
          }
          g = g[h]
        }
        c[d] = k
      }
    }
  }
  var b = /((?:\((?:\([^()]+\)|[^()]+)+\)|\[(?:\[[^[\]]*\]|['"][^'"]*['"]|[^[\]'"]+)+\]|\\.|[^ >+~,(\[\\]+)+|[>+~])(\s*,\s*)?((?:.|\r|\n)*)/g, d = 0, e = Object.prototype.toString, g = !1, m = !0;
  [0, 0].sort(function() {
    m = !1;
    return 0
  });
  var l = function(h, a, c, d) {
    c = c || [];
    var f = a = a || document;
    if(1 !== a.nodeType && 9 !== a.nodeType) {
      return[]
    }
    if(!h || "string" !== typeof h) {
      return c
    }
    for(var g = [], n, q, p, m, r = !0, t = v(a), z = h;null !== (b.exec(""), n = b.exec(z));) {
      if(z = n[3], g.push(n[1]), n[2]) {
        m = n[3];
        break
      }
    }
    if(1 < g.length && s.exec(h)) {
      if(2 === g.length && k.relative[g[0]]) {
        q = u(g[0] + g[1], a)
      }else {
        for(q = k.relative[g[0]] ? [a] : l(g.shift(), a);g.length;) {
          h = g.shift(), k.relative[h] && (h += g.shift()), q = u(h, q)
        }
      }
    }else {
      if(!d && 1 < g.length && 9 === a.nodeType && !t && k.match.ID.test(g[0]) && !k.match.ID.test(g[g.length - 1]) && (n = l.find(g.shift(), a, t), a = n.expr ? l.filter(n.expr, n.set)[0] : n.set[0]), a) {
        for(n = d ? {expr:g.pop(), set:w(d)} : l.find(g.pop(), 1 !== g.length || "~" !== g[0] && "+" !== g[0] || !a.parentNode ? a : a.parentNode, t), q = n.expr ? l.filter(n.expr, n.set) : n.set, 0 < g.length ? p = w(q) : r = !1;g.length;) {
          var y = g.pop();
          n = y;
          k.relative[y] ? n = g.pop() : y = "";
          null == n && (n = a);
          k.relative[y](p, n, t)
        }
      }else {
        p = []
      }
    }
    p || (p = q);
    p || l.error(y || h);
    if("[object Array]" === e.call(p)) {
      if(r) {
        if(a && 1 === a.nodeType) {
          for(h = 0;null != p[h];h++) {
            p[h] && (!0 === p[h] || 1 === p[h].nodeType && x(a, p[h])) && c.push(q[h])
          }
        }else {
          for(h = 0;null != p[h];h++) {
            p[h] && 1 === p[h].nodeType && c.push(q[h])
          }
        }
      }else {
        c.push.apply(c, p)
      }
    }else {
      w(p, c)
    }
    m && (l(m, f, c, d), l.uniqueSort(c));
    return c
  };
  l.uniqueSort = function(h) {
    if(r && (g = m, h.sort(r), g)) {
      for(var b = 1;b < h.length;b++) {
        h[b] === h[b - 1] && h.splice(b--, 1)
      }
    }
    return h
  };
  l.matches = function(h, b) {
    return l(h, null, null, b)
  };
  l.find = function(h, b, a) {
    var c, d;
    if(!h) {
      return[]
    }
    for(var e = 0, f = k.order.length;e < f;e++) {
      var g = k.order[e];
      if(d = k.leftMatch[g].exec(h)) {
        var s = d[1];
        d.splice(1, 1);
        if("\\" !== s.substr(s.length - 1) && (d[1] = (d[1] || "").replace(/\\/g, ""), c = k.find[g](d, b, a), null != c)) {
          h = h.replace(k.match[g], "");
          break
        }
      }
    }
    c || (c = b.getElementsByTagName("*"));
    return{set:c, expr:h}
  };
  l.filter = function(h, b, a, c) {
    for(var d = h, e = [], f = b, g, s, q = b && b[0] && v(b[0]);h && b.length;) {
      for(var m in k.filter) {
        if(null != (g = k.leftMatch[m].exec(h)) && g[2]) {
          var w = k.filter[m], t, r;
          r = g[1];
          s = !1;
          g.splice(1, 1);
          if("\\" !== r.substr(r.length - 1)) {
            f === e && (e = []);
            if(k.preFilter[m]) {
              if(g = k.preFilter[m](g, f, a, e, c, q), !g) {
                s = t = !0
              }else {
                if(!0 === g) {
                  continue
                }
              }
            }
            if(g) {
              for(var x = 0;null != (r = f[x]);x++) {
                if(r) {
                  t = w(r, g, x, f);
                  var u = c ^ !!t;
                  a && null != t ? u ? s = !0 : f[x] = !1 : u && (e.push(r), s = !0)
                }
              }
            }
            if(void 0 !== t) {
              a || (f = e);
              h = h.replace(k.match[m], "");
              if(!s) {
                return[]
              }
              break
            }
          }
        }
      }
      if(h === d) {
        if(null == s) {
          l.error(h)
        }else {
          break
        }
      }
      d = h
    }
    return f
  };
  l.error = function(b) {
    throw"Syntax error, unrecognized expression: " + b;
  };
  var k = l.selectors = {order:["ID", "NAME", "TAG"], match:{ID:/#((?:[\w\u00c0-\uFFFF-]|\\.)+)/, CLASS:/\.((?:[\w\u00c0-\uFFFF-]|\\.)+)/, NAME:/\[name=['"]*((?:[\w\u00c0-\uFFFF-]|\\.)+)['"]*\]/, ATTR:/\[\s*((?:[\w\u00c0-\uFFFF-]|\\.)+)\s*(?:(\S?=)\s*(['"]*)(.*?)\3|)\s*\]/, TAG:/^((?:[\w\u00c0-\uFFFF\*-]|\\.)+)/, CHILD:/:(only|nth|last|first)-child(?:\((even|odd|[\dn+-]*)\))?/, POS:/:(nth|eq|gt|lt|first|last|even|odd)(?:\((\d*)\))?(?=[^-]|$)/, PSEUDO:/:((?:[\w\u00c0-\uFFFF-]|\\.)+)(?:\((['"]?)((?:\([^\)]+\)|[^\(\)]*)+)\2\))?/},
  leftMatch:{}, attrMap:{"class":"className", "for":"htmlFor"}, attrHandle:{href:function(b) {
    return b.getAttribute("href")
  }}, relative:{"+":function(b, a) {
    var c = "string" === typeof a, d = c && !/\W/.test(a), c = c && !d;
    d && (a = a.toLowerCase());
    for(var d = 0, e = b.length, f;d < e;d++) {
      if(f = b[d]) {
        for(;(f = f.previousSibling) && 1 !== f.nodeType;) {
        }
        b[d] = c || f && f.nodeName.toLowerCase() === a ? f || !1 : f === a
      }
    }
    c && l.filter(a, b, !0)
  }, ">":function(b, a) {
    var c = "string" === typeof a;
    if(c && !/\W/.test(a)) {
      a = a.toLowerCase();
      for(var d = 0, e = b.length;d < e;d++) {
        var f = b[d];
        f && (c = f.parentNode, b[d] = c.nodeName.toLowerCase() === a ? c : !1)
      }
    }else {
      d = 0;
      for(e = b.length;d < e;d++) {
        (f = b[d]) && (b[d] = c ? f.parentNode : f.parentNode === a)
      }
      c && l.filter(a, b, !0)
    }
  }, "":function(b, a, e) {
    var g = d++, k = c;
    if("string" === typeof a && !/\W/.test(a)) {
      var s = a = a.toLowerCase(), k = f
    }
    k("parentNode", a, g, b, s, e)
  }, "~":function(b, a, e) {
    var g = d++, k = c;
    if("string" === typeof a && !/\W/.test(a)) {
      var s = a = a.toLowerCase(), k = f
    }
    k("previousSibling", a, g, b, s, e)
  }}, find:{ID:function(b, a, c) {
    if("undefined" !== typeof a.getElementById && !c) {
      return(b = a.getElementById(b[1])) ? [b] : []
    }
  }, NAME:function(b, a) {
    if("undefined" !== typeof a.getElementsByName) {
      for(var c = [], d = a.getElementsByName(b[1]), e = 0, f = d.length;e < f;e++) {
        d[e].getAttribute("name") === b[1] && c.push(d[e])
      }
      return 0 === c.length ? null : c
    }
  }, TAG:function(b, a) {
    return a.getElementsByTagName(b[1])
  }}, preFilter:{CLASS:function(b, a, c, d, e, f) {
    b = " " + b[1].replace(/\\/g, "") + " ";
    if(f) {
      return b
    }
    f = 0;
    for(var g;null != (g = a[f]);f++) {
      g && (e ^ (g.className && 0 <= (" " + g.className + " ").replace(/[\t\n]/g, " ").indexOf(b)) ? c || d.push(g) : c && (a[f] = !1))
    }
    return!1
  }, ID:function(b) {
    return b[1].replace(/\\/g, "")
  }, TAG:function(b, a) {
    return b[1].toLowerCase()
  }, CHILD:function(b) {
    if("nth" === b[1]) {
      var a = /(-?)(\d*)n((?:\+|-)?\d*)/.exec("even" === b[2] && "2n" || "odd" === b[2] && "2n+1" || !/\D/.test(b[2]) && "0n+" + b[2] || b[2]);
      b[2] = a[1] + (a[2] || 1) - 0;
      b[3] = a[3] - 0
    }
    b[0] = d++;
    return b
  }, ATTR:function(b, a, c, d, e, f) {
    a = b[1].replace(/\\/g, "");
    !f && k.attrMap[a] && (b[1] = k.attrMap[a]);
    "~=" === b[2] && (b[4] = " " + b[4] + " ");
    return b
  }, PSEUDO:function(a, c, d, e, f) {
    if("not" === a[1]) {
      if(1 < (b.exec(a[3]) || "").length || /^\w/.test(a[3])) {
        a[3] = l(a[3], null, null, c)
      }else {
        return a = l.filter(a[3], c, d, 1 ^ f), d || e.push.apply(e, a), !1
      }
    }else {
      if(k.match.POS.test(a[0]) || k.match.CHILD.test(a[0])) {
        return!0
      }
    }
    return a
  }, POS:function(b) {
    b.unshift(!0);
    return b
  }}, filters:{enabled:function(b) {
    return!1 === b.disabled && "hidden" !== b.type
  }, disabled:function(b) {
    return!0 === b.disabled
  }, checked:function(b) {
    return!0 === b.checked
  }, selected:function(b) {
    b.parentNode.selectedIndex;
    return!0 === b.selected
  }, parent:function(b) {
    return!!b.firstChild
  }, empty:function(b) {
    return!b.firstChild
  }, has:function(b, a, c) {
    return!!l(c[3], b).length
  }, header:function(b) {
    return/h\d/i.test(b.nodeName)
  }, text:function(b) {
    return"text" === b.type
  }, radio:function(b) {
    return"radio" === b.type
  }, checkbox:function(b) {
    return"checkbox" === b.type
  }, file:function(b) {
    return"file" === b.type
  }, password:function(b) {
    return"password" === b.type
  }, submit:function(b) {
    return"submit" === b.type
  }, image:function(b) {
    return"image" === b.type
  }, reset:function(b) {
    return"reset" === b.type
  }, button:function(b) {
    return"button" === b.type || "button" === b.nodeName.toLowerCase()
  }, input:function(b) {
    return/input|select|textarea|button/i.test(b.nodeName)
  }}, setFilters:{first:function(b, a) {
    return 0 === a
  }, last:function(b, a, c, d) {
    return a === d.length - 1
  }, even:function(b, a) {
    return 0 === a % 2
  }, odd:function(b, a) {
    return 1 === a % 2
  }, lt:function(b, a, c) {
    return a < c[3] - 0
  }, gt:function(b, a, c) {
    return a > c[3] - 0
  }, nth:function(b, a, c) {
    return c[3] - 0 === a
  }, eq:function(b, a, c) {
    return c[3] - 0 === a
  }}, filter:{PSEUDO:function(b, c, d, e) {
    var f = c[1], g = k.filters[f];
    if(g) {
      return g(b, d, c, e)
    }
    if("contains" === f) {
      return 0 <= (b.textContent || b.innerText || a([b]) || "").indexOf(c[3])
    }
    if("not" === f) {
      c = c[3];
      d = 0;
      for(e = c.length;d < e;d++) {
        if(c[d] === b) {
          return!1
        }
      }
      return!0
    }
    l.error("Syntax error, unrecognized expression: " + f)
  }, CHILD:function(b, a) {
    var c = a[1], d = b;
    switch(c) {
      case "only":
      ;
      case "first":
        for(;d = d.previousSibling;) {
          if(1 === d.nodeType) {
            return!1
          }
        }
        if("first" === c) {
          return!0
        }
        d = b;
      case "last":
        for(;d = d.nextSibling;) {
          if(1 === d.nodeType) {
            return!1
          }
        }
        return!0;
      case "nth":
        var c = a[2], e = a[3];
        if(1 === c && 0 === e) {
          return!0
        }
        var f = a[0], g = b.parentNode;
        if(g && (g.sizcache !== f || !b.nodeIndex)) {
          for(var k = 0, d = g.firstChild;d;d = d.nextSibling) {
            1 === d.nodeType && (d.nodeIndex = ++k)
          }
          g.sizcache = f
        }
        d = b.nodeIndex - e;
        return 0 === c ? 0 === d : 0 === d % c && 0 <= d / c
    }
  }, ID:function(b, a) {
    return 1 === b.nodeType && b.getAttribute("id") === a
  }, TAG:function(b, a) {
    return"*" === a && 1 === b.nodeType || b.nodeName.toLowerCase() === a
  }, CLASS:function(b, a) {
    return-1 < (" " + (b.className || b.getAttribute("class")) + " ").indexOf(a)
  }, ATTR:function(b, a) {
    var c = a[1], c = k.attrHandle[c] ? k.attrHandle[c](b) : null != b[c] ? b[c] : b.getAttribute(c), d = c + "", e = a[2], f = a[4];
    return null == c ? "!=" === e : "=" === e ? d === f : "*=" === e ? 0 <= d.indexOf(f) : "~=" === e ? 0 <= (" " + d + " ").indexOf(f) : f ? "!=" === e ? d !== f : "^=" === e ? 0 === d.indexOf(f) : "$=" === e ? d.substr(d.length - f.length) === f : "|=" === e ? d === f || d.substr(0, f.length + 1) === f + "-" : !1 : d && !1 !== c
  }, POS:function(b, a, c, d) {
    var e = k.setFilters[a[2]];
    if(e) {
      return e(b, c, a, d)
    }
  }}}, s = k.match.POS, q;
  for(q in k.match) {
    k.match[q] = RegExp(k.match[q].source + /(?![^\[]*\])(?![^\(]*\))/.source), k.leftMatch[q] = RegExp(/(^(?:.|\r|\n)*?)/.source + k.match[q].source.replace(/\\(\d+)/g, function(b, a) {
      return"\\" + (a - 0 + 1)
    }))
  }
  var w = function(b, a) {
    b = Array.prototype.slice.call(b, 0);
    return a ? (a.push.apply(a, b), a) : b
  };
  try {
    Array.prototype.slice.call(document.documentElement.childNodes, 0)[0].nodeType
  }catch(t) {
    w = function(b, a) {
      var c = a || [];
      if("[object Array]" === e.call(b)) {
        Array.prototype.push.apply(c, b)
      }else {
        if("number" === typeof b.length) {
          for(var d = 0, f = b.length;d < f;d++) {
            c.push(b[d])
          }
        }else {
          for(d = 0;b[d];d++) {
            c.push(b[d])
          }
        }
      }
      return c
    }
  }
  var r;
  document.documentElement.compareDocumentPosition ? r = function(b, a) {
    if(!b.compareDocumentPosition || !a.compareDocumentPosition) {
      return b == a && (g = !0), b.compareDocumentPosition ? -1 : 1
    }
    var c = b.compareDocumentPosition(a) & 4 ? -1 : b === a ? 0 : 1;
    0 === c && (g = !0);
    return c
  } : "sourceIndex" in document.documentElement ? r = function(b, a) {
    if(!b.sourceIndex || !a.sourceIndex) {
      return b == a && (g = !0), b.sourceIndex ? -1 : 1
    }
    var c = b.sourceIndex - a.sourceIndex;
    0 === c && (g = !0);
    return c
  } : document.createRange && (r = function(b, a) {
    if(!b.ownerDocument || !a.ownerDocument) {
      return b == a && (g = !0), b.ownerDocument ? -1 : 1
    }
    var c = b.ownerDocument.createRange(), d = a.ownerDocument.createRange();
    c.setStart(b, 0);
    c.setEnd(b, 0);
    d.setStart(a, 0);
    d.setEnd(a, 0);
    c = c.compareBoundaryPoints(Range.START_TO_END, d);
    0 === c && (g = !0);
    return c
  });
  (function() {
    var b = document.createElement("div"), a = "script" + (new Date).getTime();
    b.innerHTML = "<a name='" + a + "'/>";
    var c = document.documentElement;
    c.insertBefore(b, c.firstChild);
    document.getElementById(a) && (k.find.ID = function(b, a, c) {
      if("undefined" !== typeof a.getElementById && !c) {
        return(a = a.getElementById(b[1])) ? a.id === b[1] || "undefined" !== typeof a.getAttributeNode && a.getAttributeNode("id").nodeValue === b[1] ? [a] : void 0 : []
      }
    }, k.filter.ID = function(b, a) {
      var c = "undefined" !== typeof b.getAttributeNode && b.getAttributeNode("id");
      return 1 === b.nodeType && c && c.nodeValue === a
    });
    c.removeChild(b);
    c = b = null
  })();
  (function() {
    var b = document.createElement("div");
    b.appendChild(document.createComment(""));
    0 < b.getElementsByTagName("*").length && (k.find.TAG = function(b, a) {
      var c = a.getElementsByTagName(b[1]);
      if("*" === b[1]) {
        for(var d = [], e = 0;c[e];e++) {
          1 === c[e].nodeType && d.push(c[e])
        }
        c = d
      }
      return c
    });
    b.innerHTML = "<a href='#'></a>";
    b.firstChild && "undefined" !== typeof b.firstChild.getAttribute && "#" !== b.firstChild.getAttribute("href") && (k.attrHandle.href = function(b) {
      return b.getAttribute("href", 2)
    });
    b = null
  })();
  document.querySelectorAll && function() {
    var b = l, a = document.createElement("div");
    a.innerHTML = "<p class='TEST'></p>";
    if(!a.querySelectorAll || 0 !== a.querySelectorAll(".TEST").length) {
      l = function(a, c, d, e) {
        c = c || document;
        if(!e && 9 === c.nodeType && !v(c)) {
          try {
            return w(c.querySelectorAll(a), d)
          }catch(f) {
          }
        }
        return b(a, c, d, e)
      };
      for(var c in b) {
        l[c] = b[c]
      }
      a = null
    }
  }();
  (function() {
    var b = document.createElement("div");
    b.innerHTML = "<div class='test e'></div><div class='test'></div>";
    b.getElementsByClassName && 0 !== b.getElementsByClassName("e").length && (b.lastChild.className = "e", 1 !== b.getElementsByClassName("e").length && (k.order.splice(1, 0, "CLASS"), k.find.CLASS = function(b, a, c) {
      if("undefined" !== typeof a.getElementsByClassName && !c) {
        return a.getElementsByClassName(b[1])
      }
    }, b = null))
  })();
  var x = document.compareDocumentPosition ? function(b, a) {
    return!!(b.compareDocumentPosition(a) & 16)
  } : function(b, a) {
    return b !== a && (b.contains ? b.contains(a) : !0)
  }, v = function(b) {
    return(b = (b ? b.ownerDocument || b : 0).documentElement) ? "HTML" !== b.nodeName : !1
  }, u = function(b, a) {
    for(var c = [], d = "", e, f = a.nodeType ? [a] : a;e = k.match.PSEUDO.exec(b);) {
      d += e[0], b = b.replace(k.match.PSEUDO, "")
    }
    b = k.relative[b] ? b + "*" : b;
    e = 0;
    for(var g = f.length;e < g;e++) {
      l(b, f[e], c)
    }
    return l.filter(d, c)
  };
  return l
}();
ninjascript.tools = {};
ninjascript.tools.JSONHandler = function(a) {
  this.desc = a
};
(function() {
  var a = ninjascript.tools.JSONHandler.prototype, f = ninjascript.Logger.forComponent("json");
  a.receive = function(a) {
    this.compose([], a, this.desc);
    return null
  };
  a.compose = function(a, b, d) {
    if("function" == typeof d) {
      try {
        d.call(this, b)
      }catch(e) {
        f.error("prototype.Caught = " + e + " while handling JSON at " + a.join("/"))
      }
    }else {
      for(var g in b) {
        b.hasOwnProperty(g) && g in d && this.compose(a.concat([g]), b[g], d[g])
      }
    }
    return null
  };
  a.inspectTree = function(a) {
    var b = [], d;
    for(d in a) {
      "function" == typeof a[d] ? b.push(d) : Utils.forEach(this.inspectTree(a[d]), function(a) {
        b.push(d + "." + a)
      })
    }
    return b
  };
  a.inspect = function() {
    return this.inspectTree(this.desc).join("\n")
  }
})();
ninjascript.utils = {};
(function() {
  var a = ninjascript.utils;
  a.isArray = function(a) {
    return"undefined" == typeof a ? !1 : a.constructor == Array
  };
  a.enrich = function(a, c) {
    return jQuery.extend(a, c)
  };
  a.clone = function(a) {
    return jQuery.extend(!0, {}, a)
  };
  a.filter = "function" == typeof Array.prototype.filter ? function(a, c, b) {
    return"function" == typeof a.filter ? a.filter(c, b) : Array.prototype.filter.call(a, c, b)
  } : function(a, c, b) {
    if("function" == typeof a.filter) {
      return a.filter(c, b)
    }
    for(var d = [], e = a.length, g = 0;g < e;g += 1) {
      c.call(b, a[g], g, a) && d.push(a[g])
    }
    return d
  };
  a.forEach = function(a, c, b) {
    if("function" == typeof a.forEach) {
      return a.forEach(c, b)
    }
    if("function" == typeof Array.prototype.forEach) {
      return Array.prototype.forEach.call(a, c, b)
    }
    for(var d = Number(a.length), e = 0;e < d;e += 1) {
      "undefined" != typeof a[e] && c.call(b, a[e], e, a)
    }
  }
})();
ninjascript.BehaviorBinding = function(a) {
  var f = function() {
    this.stashedElements = [];
    this.hiddenElements = [];
    this.eventHandlerSet = {}
  };
  f.prototype = a;
  a = new f;
  a.initialize = function(a, b, d) {
    this.behaviorConfig = b;
    this.parent = a;
    this.acquireTransform(b.transform);
    this.acquireEventHandlers(b.eventHandlers);
    this.acquireHelpers(b.helpers);
    this.postElement = this.previousElement = d;
    a = this.transform(d);
    void 0 !== a && (this.postElement = a);
    this.element = this.postElement;
    return this
  };
  a.binding = function(a, b) {
    var d = this, e = function() {
      this.initialize(d, a, b)
    };
    e.prototype = this;
    return new e
  };
  a.acquireEventHandlers = function(a) {
    for(var b = a.length, d = 0, e, d = 0;d < b;d++) {
      e = a[d].name;
      var f = this, m = a[d].buildHandlerFunction(this.parent[e]);
      this[e] = function() {
        var b = Array.prototype.shift.call(arguments);
        Array.prototype.unshift.call(arguments, this);
        Array.prototype.unshift.call(arguments, b);
        return m.apply(f, arguments)
      }
    }
  };
  a.acquireHelpers = function(a) {
    for(var b in a) {
      this[b] = a[b]
    }
  };
  a.acquireTransform = function(a) {
    this.transform = a
  };
  a.stash = function(a) {
    this.stashedElements.unshift(a);
    jQuery(a).detach();
    return a
  };
  a.unstash = function() {
    var a = jQuery(this.stashedElements.shift()), b = this.hiddenDiv();
    a.data("ninja-visited", this);
    jQuery(b).append(a);
    this.parent.bindHandlers();
    return a
  };
  a.clearStash = function() {
    this.stashedElements = []
  };
  a.cascadeEvent = function(a) {
    for(var b, d;0 < this.stashedElements.length;) {
      this.hiddenElements.unshift(this.unstash())
    }
    d = this.hiddenElements.length;
    for(b = 0;b < d;b++) {
      this.hiddenElements[b].trigger(a)
    }
  };
  a.bindHandlers = function() {
    for(var a = jQuery(this.postElement), b = this.behaviorConfig.eventHandlers, d = b.length, e = 0;e < d;e++) {
      a.bind(b[e].name, this[b[e].name])
    }
  };
  a.unbindHandlers = function() {
    for(var a = jQuery(this.postElement), b = this.behaviorConfig.eventHandlers, d = b.length, e = 0;e < d;e++) {
      a.unbind(b[e].name, this[b[e].name])
    }
  };
  return a.binding({transform:function(a) {
    return a
  }, eventHandlers:[], helpers:{}}, null)
};
ninjascript.BehaviorRuleBuilder = function() {
  this.ninja = null;
  this.rules = [];
  this.finder = null;
  this.behaviors = []
};
(function() {
  var a = ninjascript.BehaviorRuleBuilder.prototype, f = ninjascript.utils;
  a.normalizeFinder = function(a) {
    return"string" == typeof a ? function(b) {
      return ninjascript.sizzle(a, b)
    } : a
  };
  a.normalizeBehavior = function(a) {
    return a instanceof ninjascript.behaviors.Abstract ? a : "function" == typeof a ? a.call(this.ninja) : new ninjascript.behaviors.Basic(a)
  };
  a.buildRules = function(a) {
    this.rules = [];
    this.originalFinder = this.finder;
    this.finder = this.normalizeFinder(this.finder);
    for(f.isArray(a) ? this.behaviors = a : this.behaviors = [a];0 < this.behaviors.length;) {
      if(a = this.behaviors.shift(), a = this.normalizeBehavior(a), f.isArray(a)) {
        this.behaviors = this.behaviors.concat(a)
      }else {
        var b = new ninjascript.BehaviorRule;
        b.finder = this.finder;
        b.originalFinder = this.originalFinder == this.finder ? "[same]" : this.originalFinder;
        b.behavior = a;
        this.rules.push(b)
      }
    }
  }
})();
ninjascript.behaviors.Basic = function(a) {
  this.helpers = {};
  this.eventHandlers = [];
  this.priority = this.lexicalOrder = 0;
  "function" == typeof a.transform && (this.transform = a.transform, delete a.transform);
  "undefined" != typeof a.helpers && (this.helpers = a.helpers, delete a.helpers);
  "undefined" != typeof a.priority && (this.priority = a.priority);
  delete a.priority;
  this.eventHandlers = "undefined" != typeof a.events ? this.eventConfigs(a.events) : this.eventConfigs(a);
  return this
};
ninjascript.behaviors.Basic.prototype = new ninjascript.behaviors.Abstract;
(function() {
  var a = ninjascript.behaviors.Basic.prototype, f = ninjascript.behaviors.EventHandlerConfig;
  a.priority = function(a) {
    this.priority = a;
    return this
  };
  a.choose = function(a) {
    return this
  };
  a.eventConfigs = function(a) {
    var b = [], d;
    for(d in a) {
      b.push(new f(d, a[d]))
    }
    return b
  };
  a.transform = function(a) {
    return a
  };
  a.expandRules = function(a) {
    return[]
  };
  a.helpers = {}
})();
ninjascript.BehaviorRule = function() {
  this.finder = function(a) {
    return[]
  };
  this.behavior = null
};
ninjascript.BehaviorRule.build = function(a, f, c) {
  builder = new ninjascript.BehaviorRuleBuilder;
  builder.ninja = a;
  builder.finder = f;
  builder.buildRules(c);
  return builder.rules
};
(function() {
  var a = ninjascript.BehaviorRule.prototype;
  a.match = function(a) {
    return this.matchRoots([a], this.finder)
  };
  a.matchRoots = function(a, c) {
    var b, d = a.length, e = [];
    for(b = 0;b < d;b++) {
      e = e.concat(c(a[b]))
    }
    return e
  };
  a.chainFinder = function(a) {
    return function(c) {
      return this.matchRoots(precendent.finder(c), a)
    }
  };
  a.chainRule = function(a, c) {
    var b = new ninjascript.BehaviorRule;
    b.finder = this.chainFinder(a);
    b.behavior = c;
    return b
  }
})();
ninjascript.BehaviorCollection = function(a) {
  this.lexicalCount = 0;
  this.rules = [];
  this.parts = a;
  this.tools = a.tools;
  return this
};
(function() {
  var a = ninjascript.BehaviorCollection.prototype, f = ninjascript.utils, c = ninjascript.BehaviorBinding, b = ninjascript.BehaviorRule, d = f.forEach, e = f.filter, g = ninjascript.Logger.forComponent("behavior-list"), m = ninjascript.exceptions.TransformFailed, l = ninjascript.exceptions.CouldntChoose;
  a.ninja = function() {
    return this.parts.ninja
  };
  a.addBehavior = function(a, c) {
    f.isArray(c) ? d(c, function(b) {
      this.addBehavior(a, b)
    }, this) : d(b.build(this.ninja(), a, c), function(a) {
      this.addBehaviorRule(a)
    }, this)
  };
  a.addBehaviorRule = function(a) {
    a.behavior.lexicalOrder = this.lexicalCount;
    this.lexicalCount += 1;
    this.rules.push(a)
  };
  a.finalize = function() {
    var a;
    g.info("Finalizing ruleset. Rule count:", this.rules.length);
    for(var b = 0;b < this.rules.length;b++) {
      a = this.rules[b];
      a = a.behavior.expandRules(a);
      for(var c = 0;c < a.length;c++) {
        this.addBehaviorRule(a[c])
      }
    }
    g.debug("Complete ruleset:", this.rules)
  };
  a.applyAll = function(a) {
    var b, c, d, f, l, m, v, u = !1, h = [];
    l = this.rules.length;
    g.info("Applying all behavior rules");
    for(b = 0;b < l;b++) {
      for(m = this.rules[b].match(document), m = e(m, function(b) {
        return jQuery.contains(a, b)
      }), f = m.length, 0 >= f ? g.debug("Behavior matched no elements:", "function" == typeof this.rules[b].finder ? this.rules[b].originalFinder : this.rules[b].finder, this.rules[b]) : g.debug(f + " elements matched by:", "function" == typeof this.rules[b].finder ? this.rules[b].originalFinder : this.rules[b].finder, this.rules[b]), v = h.length, c = 0;c < f;c++) {
        u = !1;
        for(d = 0;d < v;d++) {
          if(m[c] == h[d].element) {
            h[d].behaviors.push(this.rules[b].behavior);
            u = !0;
            break
          }
        }
        u || (h.push({element:m[c], behaviors:[this.rules[b].behavior]}), v = h.length)
      }
    }
    g.debug("Elements with behaviors:", h);
    for(b = 0;b < v;b++) {
      jQuery(h[b].element).data("ninja-visited") || (g.debug("Applying:", h[b]), this.apply(h[b].element, h[b].behaviors))
    }
  };
  a.apply = function(a, b) {
    var d = [], d = this.collectBehaviors(a, b), e = jQuery(a).data("ninja-visited");
    e ? e.unbindHandlers() : e = c(this.tools);
    this.applyBehaviorsInContext(e, a, d)
  };
  a.collectBehaviors = function(a, b) {
    var c = [];
    d(b, function(b) {
      try {
        c.push(b.choose(a))
      }catch(d) {
        if(d instanceof l) {
          g.warn("couldn't choose")
        }else {
          throw g.errror(d), d;
        }
      }
    });
    return c
  };
  a.applyBehaviorsInContext = function(a, b, c) {
    var e = a;
    c = this.sortBehaviors(c);
    d(c, function(c) {
      try {
        a = a.binding(c, b), b = a.element
      }catch(d) {
        if(d instanceof m) {
          g.warn("Transform failed", a.element, c)
        }else {
          throw g.error(d), d;
        }
      }
    });
    e.visibleElement = b;
    jQuery(b).data("ninja-visited", a);
    a.bindHandlers();
    this.tools.fireMutationEvent();
    return b
  };
  a.sortBehaviors = function(a) {
    return a.sort(function(a, b) {
      return a.priority != b.priority ? void 0 === a.priority ? -1 : void 0 === b.priority ? 1 : a.priority - b.priority : a.lexicalOrder - b.lexicalOrder
    })
  }
})();
ninjascript.mutation = {};
ninjascript.mutation.EventHandler = function(a, f) {
  this.eventQueue = [];
  this.mutationTargets = [];
  this.behaviorCollection = f;
  this.docRoot = a;
  var c = this;
  this.handleMutationEvent = function(a) {
    c.mutationEventTriggered(a)
  };
  this.handleNaturalMutationEvent = function() {
    c.detachSyntheticMutationEvents()
  }
};
(function() {
  var a = ninjascript.mutation.EventHandler.prototype, f = ninjascript.Logger.forComponent("mutation"), c = ninjascript.utils.forEach;
  a.setup = function() {
    this.docRoot.bind("DOMSubtreeModified DOMNodeInserted thisChangedDOM", this.handleMutationEvent);
    this.docRoot.one("DOMSubtreeModified DOMNodeInserted", this.handleNaturalMutationEvent);
    this.setup = function() {
    }
  };
  a.teardown = function() {
    delete this.setup;
    this.docRoot.unbind("DOMSubtreeModified DOMNodeInserted thisChangedDOM", this.handleMutationEvent)
  };
  a.detachSyntheticMutationEvents = function() {
    f.debug("Detaching polyfill mutation functions");
    this.fireMutationEvent = function() {
    };
    this.addMutationTargets = function() {
    }
  };
  a.addMutationTargets = function(a) {
    this.mutationTargets = this.mutationTargets.concat(a)
  };
  a.fireMutationEvent = function() {
    var a = this.mutationTargets;
    if(0 < a.length) {
      for(var c = a[0];0 < a.length;c = a.shift()) {
        jQuery(c).trigger("thisChangedDOM")
      }
    }else {
      this.docRoot.trigger("thisChangedDOM")
    }
  };
  a.mutationEventTriggered = function(a) {
    0 == this.eventQueue.length ? (this.enqueueEvent(a), this.handleQueue()) : this.enqueueEvent(a)
  };
  a.enqueueEvent = function(a) {
    var d = !1, e = [];
    f.debug("enqueueing");
    c(this.eventQueue, function(c) {
      d = d || jQuery.contains(c.target, a.target);
      jQuery.contains(a.target, c.target) || e.push(c)
    });
    d || (e.unshift(a), this.eventQueue = e)
  };
  a.handleQueue = function() {
    for(f.info("consuming queue");0 != this.eventQueue.length;) {
      this.behaviorCollection.applyAll(this.eventQueue[0].target), this.eventQueue.shift()
    }
  }
})();
ninjascript.NinjaScript = function() {
};
ninjascript.NinjaScript.prototype = new ninjascript.Extensible;
(function() {
  var a = ninjascript.NinjaScript.prototype, f = ninjascript.utils, c = ninjascript.Logger.forComponent("ninja");
  a.plugin = function(a) {
    return ninjascript.Extensible.addPackage({Ninja:this, tools:this.tools}, a)
  };
  a.configure = function(a) {
    f.enrich(this.config, a)
  };
  a.respondToJson = function(a) {
    this.jsonDispatcher.addHandler(a)
  };
  a.goodBehavior = function(a) {
    var d = this.extensions.collection, e;
    for(e in a) {
      "undefined" == typeof a[e] ? c.warn("Selector " + e + " not properly defined - ignoring") : d.addBehavior(e, a[e])
    }
    this.failSafeGo()
  };
  a.behavior = a.goodBehavior;
  a.failSafeGo = function() {
    this.failSafeGo = function() {
    };
    jQuery(window).load(function() {
      Ninja.go()
    })
  };
  a.badBehavior = function(a) {
    throw Error("Called Ninja.behavior() after Ninja.go() - don't do that.  'Go' means 'I'm done, please proceed'");
  };
  a.go = function() {
    this.behavior != this.badBehavior && (this.behavior = this.badBehavior, this.extensions.collection.finalize(), this.mutationHandler.setup(), this.mutationHandler.fireMutationEvent())
  };
  a.stop = function() {
    this.mutationHandler.teardown();
    this.behavior = this.goodBehavior
  }
})();
ninjascript.Tools = function() {
};
ninjascript.Tools.prototype = new ninjascript.Extensible;
(function() {
  var a = ninjascript.Tools.prototype, f = ninjascript.utils, c = ninjascript.exceptions.TransformFailed, b = ninjascript.Logger.forComponent("tools");
  a.forEach = f.forEach;
  a.ensureDefaults = function(a, b) {
    a instanceof Object || (a = {});
    for(var c in b) {
      "undefined" == typeof a[c] && ("undefined" != typeof this.ninja.config[c] ? a[c] = this.ninja.config[c] : "undefined" != typeof b[c] && (a[c] = b[c]))
    }
    return a
  };
  a.getRootOfDocument = function() {
    return jQuery("html")
  };
  a.getRootCollection = function() {
    return this.ninja.collection
  };
  a.fireMutationEvent = function() {
    this.ninja.mutationHandler.fireMutationEvent()
  };
  a.copyAttributes = function(a, b, c) {
    var f = RegExp("^" + c.join("$|^") + "$");
    b = jQuery(b);
    this.forEach(a.attributes, function(a) {
      f.test(a.nodeName) && b.attr(a.nodeName, a.nodeValue)
    })
  };
  a.deriveElementsFrom = function(a, b) {
    switch(typeof b) {
      case "undefined":
        return a;
      case "string":
        return jQuery(b);
      case "function":
        return b(a)
    }
  };
  a.extractMethod = function(a, c) {
    if(void 0 !== a.dataset && void 0 !== a.dataset.method && 0 < a.dataset.method.length) {
      return b.info("Override via prototype.dataset = " + a.dataset.method), a.dataset.method
    }
    if(void 0 === a.dataset && void 0 !== jQuery(a).attr("data-method")) {
      return b.info("Override via data-prototype.method = " + jQuery(a).attr("data-method")), jQuery(a).attr("data-method")
    }
    if("undefined" !== typeof c) {
      for(var f = 0, m = c.length;f < m;f++) {
        if("Method" == c[f].name) {
          return b.info("Override via prototype.Method = " + c[f].value), c[f].value
        }
      }
    }
    return"undefined" !== typeof a.method ? a.method : "GET"
  };
  a.cantTransform = function(a) {
    throw new c(a);
  };
  a.message = function(a, b) {
    var c = this.ninja.config.messageWrapping(a, b);
    jQuery(this.ninja.config.messageList).append(c)
  };
  a.hiddenDiv = function() {
    var a = jQuery("div#ninja-hide");
    if(0 < a.length) {
      return a[0]
    }
    a = jQuery("<div id='ninja-hide'></div>").css("display", "none");
    jQuery("body").append(a);
    this.getRootCollection().apply(a, [this.ninja.suppressChangeEvents()]);
    return a
  }
})();
ninjascript.plugin = function(a) {
  ninjascript.Extensible.addPackage({Ninja:ninjascript.NinjaScript.prototype, tools:ninjascript.Tools.prototype}, a)
};
ninjascript.packagedBehaviors = {};
ninjascript.packagedBehaviors.confirm = {};
(function() {
  ninjascript.plugin(function(a) {
    a.behaviors({confirms:function(a) {
      function c(b, c) {
        confirm(a.confirmMessage(c)) || (b.preventDefault(), b.preventFallthrough())
      }
      a = this.tools.ensureDefaults(a, {confirmMessage:function(a) {
        return $(a).attr("data-confirm")
      }});
      "string" == typeof a.confirmMessage && (message = a.confirmMessage, a.confirmMessage = function(a) {
        return message
      });
      return new this.types.selects({form:new this.types.does({priority:20, events:{submit:[c, "andDoDefault"]}}), "a,input":new this.types.does({priority:20, events:{click:[c, "andDoDefault"]}})})
    }})
  })
})();
ninjascript.packagedBehaviors.placeholder = {};
(function() {
  var a = {placeholderSubmitter:function(a) {
    return new this.types.does({priority:1E3, submit:[function(c, e, f) {
      a.prepareForSubmit();
      f(c)
    }, "andDoDefault"]})
  }, grabsPlaceholderText:function(a) {
    a = this.tools.ensureDefaults(a, {textElementSelector:function(a) {
      return"*[data-for=" + a.id + "]"
    }, findTextElement:function(c) {
      c = $(a.textElementSelector(c));
      return 0 == c.length ? null : c[0]
    }});
    return new this.types.does({priority:-10, transform:function(c) {
      var e = $(a.findTextElement(c));
      null === e && this.cantTransform();
      this.placeholderText = e.text();
      $(c).attr("placeholder", e.text());
      this.stash(e.detach())
    }})
  }}, f = !!("placeholder" in document.createElement("input")), c = !!("placeholder" in document.createElement("textarea"));
  f || (a.alternateInput = function(a, c) {
    return new this.types.does({helpers:{prepareForSubmit:function() {
      $(this.element).val("")
    }}, transform:function() {
      this.applyBehaviors(c, [placeholderSubmitter(this)])
    }, events:{focus:function(c) {
      c = $(this.element);
      var d = c.attr("id");
      c.attr("id", "");
      c.replaceWith(a);
      a.attr("id", d);
      a.focus()
    }}})
  }, a.hasPlaceholderPassword = function(a) {
    a = this.tools.ensureDefaults(a, {findParentForm:function(a) {
      return a.parents("form")[0]
    }, retainedInputAttributes:"name class style title lang dir size maxlength alt tabindex accesskey data-.*".split(" ")});
    return new this.types.does({priority:1E3, helpers:{swapInAlternate:function() {
      var a = $(this.element), b = a.attr("id");
      "" == a.val() && (a.attr("id", ""), a.replaceWith(this.placeholderTextInput), this.placeholderTextInput.attr("id", b))
    }}, transform:function(c) {
      var e, f = $(c);
      e = $('<input type="text">');
      this.copyAttributes(c, e, a.retainedInputAttributes);
      e.addClass("ninja_placeholder");
      e.val(this.placeholderText);
      f = alternateInput(f, a.findParentForm(f));
      this.applyBehaviors(e, [f]);
      this.placeholderTextInput = e;
      this.swapInAlternate();
      return c
    }, events:{blur:function(a) {
      this.swapInAlternate()
    }}})
  });
  f && c || (a.hasPlaceholderText = function(a) {
    a = this.tools.ensureDefaults(a, {findParentForm:function(a) {
      return a.parents("form")[0]
    }});
    return new this.types.does({priority:1E3, helpers:{prepareForSubmit:function() {
      $(this.element).hasClass("ninja_placeholder") && $(this.element).val("")
    }}, transform:function(c) {
      var e = $(c);
      e.addClass("ninja_placeholder");
      e.val(this.placeholderText);
      this.applyBehaviors(a.findParentForm(e), [placeholderSubmitter(this)]);
      return c
    }, events:{focus:function(a) {
      $(this.element).hasClass("ninja_placeholder") && $(this.element).removeClass("ninja_placeholder").val("")
    }, blur:function(a) {
      "" == $(this.element).val() && $(this.element).addClass("ninja_placeholder").val(this.placeholderText)
    }}})
  });
  a.hasPlaceholder = function(a) {
    var d = [this.grabsPlaceholderText(a)], e = null, g = null, m = null;
    f && c || (f || (e = this.hasPlaceholderText(a), g = this.hasPlaceholderPassword(a)), c || (m = this.hasPlaceholderText(a)), d.push(new this.types.chooses(function(a) {
      a = $(a);
      if(a.is("input[type=text]")) {
        return e
      }
      if(a.is("textarea")) {
        return m
      }
      if(a.is("input[type=password]")) {
        return g
      }
    })));
    return d
  };
  ninjascript.plugin(function(b) {
    b.Ninja(a)
  })
})();
ninjascript.packagedBehaviors.standard = {};
(function() {
  var a = ninjascript.Logger.forComponent("standard-behaviors");
  ninjascript.plugin(function(f) {
    f.ninja({submitsAsAjax:function(a) {
      var b = this.submitsAsAjaxLink(a), d = this.submitsAsAjaxForm(a);
      return new this.types.chooses(function(a) {
        switch(a.tagName.toLowerCase()) {
          case "a":
            return b;
          case "form":
            return d
        }
      })
    }, submitsAsAjaxLink:function(a) {
      a = this.tools.ensureDefaults(a, {busyElement:function(a) {
        return $(a).parents("address,blockquote,body,dd,div,p,dl,dt,table,form,ol,ul,tr")[0]
      }});
      a.actions || (a.actions = a.expectsJSON);
      return new this.types.does({priority:10, helpers:{findOverlay:function(b) {
        return this.deriveElementsFrom(b, a.busyElement)
      }}, events:{click:function(b) {
        this.overlayAndSubmit(this.visibleElement, b.target, b.target.href, a.actions)
      }}})
    }, submitsAsAjaxForm:function(a) {
      a = this.tools.ensureDefaults(a, {busyElement:void 0});
      a.actions || (a.actions = a.expectsJSON);
      return new this.types.does({priority:10, helpers:{findOverlay:function(b) {
        return this.deriveElementsFrom(b, a.busyElement)
      }}, events:{submit:function(b) {
        this.overlayAndSubmit(this.visibleElement, b.target, b.target.action, a.actions)
      }}})
    }, becomesAjaxLink:function(a) {
      a = this.tools.ensureDefaults(a, {busyElement:void 0, retainedFormAttributes:"id class lang dir title data-.*".split(" ")});
      return[this.submitsAsAjax(a), this.becomesLink(a)]
    }, becomesLink:function(c) {
      c = this.tools.ensureDefaults(c, {retainedFormAttributes:"id class lang dir title rel data-.*".split(" ")});
      return new this.types.does({priority:30, transform:function(b) {
        var d, e;
        0 < (e = jQuery("button[type=submit]", b)).size() ? d = e.first().text() : 0 < (e = jQuery("input[type=image]", b)).size() ? (d = e[0], d = "<img src='" + d.src + "' alt='" + d.alt + "'") : 0 < (e = jQuery("input[type=submit]", b)).size() ? (1 < e.size() && a.warn("Multiple submits.  Using: " + e[0]), d = e[0].value) : (a.error("Couldn't find a submit input in form"), this.cantTransform("Couldn't find a submit input"));
        d = jQuery("<a rel='nofollow' href='#'>" + d + "</a>");
        this.copyAttributes(b, d, c.retainedFormAttributes);
        this.stash(jQuery(b).replaceWith(d));
        return d
      }, events:{click:function(a, c) {
        this.cascadeEvent("submit")
      }}})
    }, decays:function(a) {
      a = this.tools.ensureDefaults(a, {lifetime:1E4, diesFor:600});
      return new this.types.does({priority:100, transform:function(b) {
        jQuery(b).delay(a.lifetime).slideUp(a.diesFor, function() {
          jQuery(b).remove();
          this.tools.fireMutationEvent()
        })
      }, events:{click:[function(a) {
        jQuery(this.element).remove()
      }, "changesDOM"]}})
    }})
  })
})();
ninjascript.packagedBehaviors.triggerOn = {};
(function() {
  ninjascript.plugin(function(a) {
    a.behaviors({cascadeEvent:function(a) {
    }, removed:function() {
    }, triggersOnSelect:function(a) {
      var c = a = this.tools.ensureDefaults(a, {busyElement:void 0, selectElement:function(a) {
        return $(a).find("select").first()
      }, submitElement:function(a) {
        return $(a).find("input[type='submit']").first()
      }, placeholderText:"Select to go", placeholderValue:"instructions"});
      "object" === typeof a.actions && (c = a.actions);
      return new this.types.does({priority:20, helpers:{findOverlay:function(b) {
        return this.deriveElementsFrom(b, a.busyElement)
      }}, transform:function(b) {
        var c = this.deriveElementsFrom(b, a.selectElement), e = this.deriveElementsFrom(b, a.submitElement);
        "undefined" != typeof c && "undefined" != typeof e || this.cantTransform();
        c.prepend("<option value='" + a.placeholderValue + "'> " + a.placeholderText + "</option>");
        c.val(a.placeholderValue);
        $(b).find("input[type='submit']").remove();
        return b
      }, events:{change:[function(a, d) {
        this.overlayAndSubmit(d, d.action, c)
      }, "andDoDefault"]}})
    }})
  })
})();
ninjascript.packagedBehaviors.utility = {};
(function() {
  ninjascript.plugin(function(a) {
    a.behaviors({suppressChangeEvents:function() {
      return new this.types.does({events:{DOMSubtreeModified:function(a) {
      }, DOMNodeInserted:function(a) {
      }}})
    }})
  })
})();
ninjascript.packagedBehaviors.all = {};
ninjascript.tools.JSONDispatcher = function() {
  this.handlers = []
};
(function() {
  var a = ninjascript.utils, f = ninjascript.tools.JSONDispatcher.prototype, c = ninjascript.Logger.forComponent("json-dispatcher");
  f.addHandler = function(a) {
    this.handlers.push(new ninjascript.tools.JSONHandler(a))
  };
  f.dispatch = function(a) {
    for(var d = this.handlers.length, e = 0;e < d;e++) {
      try {
        this.handlers[e].receive(a)
      }catch(f) {
        c.error("prototype.Caught = " + f + " while handling JSON response.")
      }
    }
  };
  f.inspect = function() {
    var b = [];
    a.forEach(this.handlers, function(a) {
      b.push(a.inspect())
    });
    return"JSONDispatcher, " + this.handlers.length + " handlers:\n" + b.join("\n")
  }
})();
ninjascript.build = function() {
  var a = {};
  a.tools = new ninjascript.Tools(a);
  a.config = ninjascript.configuration;
  a.collection = new ninjascript.BehaviorCollection(a);
  a.jsonDispatcher = new ninjascript.tools.JSONDispatcher;
  a.mutationHandler = new ninjascript.mutation.EventHandler(a.tools.getRootOfDocument(), a.collection);
  a.config.logger = ninjascript.Logger.rootConfig;
  a.types = {does:ninjascript.behaviors.Basic, chooses:ninjascript.behaviors.Meta, selects:ninjascript.behaviors.Select};
  a.ninja = new ninjascript.NinjaScript(a);
  a.tools.inject(a);
  a.ninja.inject(a);
  return a.ninja
};
Ninja = ninjascript.build();
Ninja.orders = function(a) {
  a(window.Ninja)
};
ninjascript.tools.Overlay = function(a) {
  a = this.convertToElementArray(a);
  this.laziness = 0;
  var f = this;
  this.set = jQuery(jQuery.map(a, function(a, b) {
    return f.buildOverlayFor(a)
  }))
};
(function() {
  var a = ninjascript.utils.forEach, f = ninjascript.tools.Overlay.prototype;
  f.convertToElementArray = function(c) {
    var b = this;
    switch(typeof c) {
      case "undefined":
        return[];
      case "boolean":
        return[];
      case "string":
        return b.convertToElementArray(jQuery(c));
      case "function":
        return b.convertToElementArray(c());
      case "object":
        if("focus" in c && "blur" in c && !("jquery" in c)) {
          return[c]
        }
        if("length" in c && "0" in c) {
          var d = [];
          a(c, function(a) {
            d = d.concat(b.convertToElementArray(a))
          });
          return d
        }
        return[]
    }
  };
  f.buildOverlayFor = function(a) {
    var b = jQuery(document.createElement("div"));
    a = jQuery(a);
    var d = a.offset();
    b.css("position", "absolute");
    b.css("top", d.top);
    b.css("left", d.left);
    b.width(a.outerWidth());
    b.height(a.outerHeight());
    b.css("display", "none");
    return b[0]
  };
  f.affix = function() {
    this.set.appendTo(jQuery("body"));
    overlaySet = this.set;
    window.setTimeout(function() {
      overlaySet.css("display", "block")
    }, this.laziness)
  };
  f.remove = function() {
    this.set.remove()
  };
  ninjascript.plugin(function(a) {
    a.tools({overlay:function() {
      return new ninjascript.tools.Overlay(jQuery.makeArray(arguments))
    }, busyOverlay:function(a) {
      a = this.overlay(a);
      a.set.addClass("ninja_busy");
      a.laziness = this.ninja.config.busyLaziness;
      return a
    }, buildOverlayFor:function(a) {
      var c = jQuery(document.createElement("div"));
      a = jQuery(a);
      var e = a.offset();
      c.css("position", "absolute");
      c.css("top", e.top);
      c.css("left", e.left);
      c.width(a.outerWidth());
      c.height(a.outerHeight());
      c.css("zIndex", "2");
      return c
    }})
  })
})();
ninjascript.tools.AjaxSubmitter = function() {
  this.formData = [];
  this.action = "/";
  this.method = "GET";
  this.dataType = "script";
  return this
};
(function() {
  var a = ninjascript.Logger.forComponent("ajax"), f = ninjascript.tools.AjaxSubmitter.prototype;
  f.submit = function() {
    a.info("Computed prototype.method = " + this.method);
    jQuery.ajax(this.ajaxData())
  };
  f.sourceForm = function(a) {
    this.formData = jQuery(a).serializeArray()
  };
  f.ajaxData = function() {
    return{data:this.formData, dataType:this.dataType, url:this.action, type:this.method, complete:this.responseHandler(), success:this.successHandler(), error:this.onError}
  };
  f.successHandler = function() {
    var a = this;
    return function(b, d, e) {
      a.onSuccess(e, d, b)
    }
  };
  f.responseHandler = function() {
    var a = this;
    return function(b, d) {
      a.onResponse(b, d);
      Ninja.tools.fireMutationEvent()
    }
  };
  f.onResponse = function(a, b) {
  };
  f.onSuccess = function(a, b, d) {
  };
  f.onError = function(c, b, d) {
    console.log(c);
    console.log(a);
    a.error(c.responseText);
    Ninja.tools.message("Server prototype.error = " + c.statusText, "error")
  };
  ninjascript.plugin(function(a) {
    a.tools({ajaxSubmitter:function() {
      return new ninjascript.tools.AjaxSubmitter
    }, ajaxToJson:function(a) {
      a = this.ajaxSubmitter();
      var c = this.jsonDispatcher;
      a.dataType = "json";
      a.onSuccess = function(a, b, f) {
        c.dispatch(f)
      };
      return a
    }, overlayAndSubmit:function(a, c, e, f) {
      var m = this.busyOverlay(this.findOverlay(a));
      a = "undefined" == typeof f ? this.ajaxSubmitter() : this.ajaxToJson(f);
      a.sourceForm(c);
      a.action = e;
      a.method = this.extractMethod(c, a.formData);
      a.onResponse = function(a, b) {
        m.remove()
      };
      m.affix();
      a.submit()
    }})
  })
})();
ninjascript.tools.all = {};
ninjascript.loaded = {};

