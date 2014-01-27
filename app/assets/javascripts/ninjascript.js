/*
 * NinjaScript - 0.12.0
 * written by and copyright 2010-2014 Judson Lester and Logical Reality Design
 * Licensed under the MIT license
 *
 * 01-26-2014
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
    for(var g = [], p, n, q, m, r = !0, s = u(a), z = h;null !== (b.exec(""), p = b.exec(z));) {
      if(z = p[3], g.push(p[1]), p[2]) {
        m = p[3];
        break
      }
    }
    if(1 < g.length && y.exec(h)) {
      if(2 === g.length && k.relative[g[0]]) {
        n = t(g[0] + g[1], a)
      }else {
        for(n = k.relative[g[0]] ? [a] : l(g.shift(), a);g.length;) {
          h = g.shift(), k.relative[h] && (h += g.shift()), n = t(h, n)
        }
      }
    }else {
      if(!d && 1 < g.length && 9 === a.nodeType && !s && k.match.ID.test(g[0]) && !k.match.ID.test(g[g.length - 1]) && (p = l.find(g.shift(), a, s), a = p.expr ? l.filter(p.expr, p.set)[0] : p.set[0]), a) {
        for(p = d ? {expr:g.pop(), set:v(d)} : l.find(g.pop(), 1 !== g.length || "~" !== g[0] && "+" !== g[0] || !a.parentNode ? a : a.parentNode, s), n = p.expr ? l.filter(p.expr, p.set) : p.set, 0 < g.length ? q = v(n) : r = !1;g.length;) {
          var x = g.pop();
          p = x;
          k.relative[x] ? p = g.pop() : x = "";
          null == p && (p = a);
          k.relative[x](q, p, s)
        }
      }else {
        q = []
      }
    }
    q || (q = n);
    q || l.error(x || h);
    if("[object Array]" === e.call(q)) {
      if(r) {
        if(a && 1 === a.nodeType) {
          for(h = 0;null != q[h];h++) {
            q[h] && (!0 === q[h] || 1 === q[h].nodeType && w(a, q[h])) && c.push(n[h])
          }
        }else {
          for(h = 0;null != q[h];h++) {
            q[h] && 1 === q[h].nodeType && c.push(n[h])
          }
        }
      }else {
        c.push.apply(c, q)
      }
    }else {
      v(q, c)
    }
    m && (l(m, f, c, d), l.uniqueSort(c));
    return c
  };
  l.uniqueSort = function(h) {
    if(r && (g = m, h.sort(r), g)) {
      for(var a = 1;a < h.length;a++) {
        h[a] === h[a - 1] && h.splice(a--, 1)
      }
    }
    return h
  };
  l.matches = function(h, a) {
    return l(h, null, null, a)
  };
  l.find = function(h, a, b) {
    var c, d;
    if(!h) {
      return[]
    }
    for(var e = 0, f = k.order.length;e < f;e++) {
      var g = k.order[e];
      if(d = k.leftMatch[g].exec(h)) {
        var l = d[1];
        d.splice(1, 1);
        if("\\" !== l.substr(l.length - 1) && (d[1] = (d[1] || "").replace(/\\/g, ""), c = k.find[g](d, a, b), null != c)) {
          h = h.replace(k.match[g], "");
          break
        }
      }
    }
    c || (c = a.getElementsByTagName("*"));
    return{set:c, expr:h}
  };
  l.filter = function(h, a, b, c) {
    for(var d = h, e = [], f = a, g, n, y = a && a[0] && u(a[0]);h && a.length;) {
      for(var m in k.filter) {
        if(null != (g = k.leftMatch[m].exec(h)) && g[2]) {
          var v = k.filter[m], s, r;
          r = g[1];
          n = !1;
          g.splice(1, 1);
          if("\\" !== r.substr(r.length - 1)) {
            f === e && (e = []);
            if(k.preFilter[m]) {
              if(g = k.preFilter[m](g, f, b, e, c, y), !g) {
                n = s = !0
              }else {
                if(!0 === g) {
                  continue
                }
              }
            }
            if(g) {
              for(var w = 0;null != (r = f[w]);w++) {
                if(r) {
                  s = v(r, g, w, f);
                  var t = c ^ !!s;
                  b && null != s ? t ? n = !0 : f[w] = !1 : t && (e.push(r), n = !0)
                }
              }
            }
            if(void 0 !== s) {
              b || (f = e);
              h = h.replace(k.match[m], "");
              if(!n) {
                return[]
              }
              break
            }
          }
        }
      }
      if(h === d) {
        if(null == n) {
          l.error(h)
        }else {
          break
        }
      }
      d = h
    }
    return f
  };
  l.error = function(h) {
    throw"Syntax error, unrecognized expression: " + h;
  };
  var k = l.selectors = {order:["ID", "NAME", "TAG"], match:{ID:/#((?:[\w\u00c0-\uFFFF-]|\\.)+)/, CLASS:/\.((?:[\w\u00c0-\uFFFF-]|\\.)+)/, NAME:/\[name=['"]*((?:[\w\u00c0-\uFFFF-]|\\.)+)['"]*\]/, ATTR:/\[\s*((?:[\w\u00c0-\uFFFF-]|\\.)+)\s*(?:(\S?=)\s*(['"]*)(.*?)\3|)\s*\]/, TAG:/^((?:[\w\u00c0-\uFFFF\*-]|\\.)+)/, CHILD:/:(only|nth|last|first)-child(?:\((even|odd|[\dn+-]*)\))?/, POS:/:(nth|eq|gt|lt|first|last|even|odd)(?:\((\d*)\))?(?=[^-]|$)/, PSEUDO:/:((?:[\w\u00c0-\uFFFF-]|\\.)+)(?:\((['"]?)((?:\([^\)]+\)|[^\(\)]*)+)\2\))?/}, 
  leftMatch:{}, attrMap:{"class":"className", "for":"htmlFor"}, attrHandle:{href:function(h) {
    return h.getAttribute("href")
  }}, relative:{"+":function(h, a) {
    var b = "string" === typeof a, c = b && !/\W/.test(a), b = b && !c;
    c && (a = a.toLowerCase());
    for(var c = 0, d = h.length, e;c < d;c++) {
      if(e = h[c]) {
        for(;(e = e.previousSibling) && 1 !== e.nodeType;) {
        }
        h[c] = b || e && e.nodeName.toLowerCase() === a ? e || !1 : e === a
      }
    }
    b && l.filter(a, h, !0)
  }, ">":function(a, b) {
    var c = "string" === typeof b;
    if(c && !/\W/.test(b)) {
      b = b.toLowerCase();
      for(var d = 0, e = a.length;d < e;d++) {
        var f = a[d];
        f && (c = f.parentNode, a[d] = c.nodeName.toLowerCase() === b ? c : !1)
      }
    }else {
      d = 0;
      for(e = a.length;d < e;d++) {
        (f = a[d]) && (a[d] = c ? f.parentNode : f.parentNode === b)
      }
      c && l.filter(b, a, !0)
    }
  }, "":function(a, b, e) {
    var g = d++, k = c;
    if("string" === typeof b && !/\W/.test(b)) {
      var n = b = b.toLowerCase(), k = f
    }
    k("parentNode", b, g, a, n, e)
  }, "~":function(a, b, e) {
    var g = d++, k = c;
    if("string" === typeof b && !/\W/.test(b)) {
      var n = b = b.toLowerCase(), k = f
    }
    k("previousSibling", b, g, a, n, e)
  }}, find:{ID:function(a, b, c) {
    if("undefined" !== typeof b.getElementById && !c) {
      return(a = b.getElementById(a[1])) ? [a] : []
    }
  }, NAME:function(a, b) {
    if("undefined" !== typeof b.getElementsByName) {
      for(var c = [], d = b.getElementsByName(a[1]), e = 0, f = d.length;e < f;e++) {
        d[e].getAttribute("name") === a[1] && c.push(d[e])
      }
      return 0 === c.length ? null : c
    }
  }, TAG:function(a, b) {
    return b.getElementsByTagName(a[1])
  }}, preFilter:{CLASS:function(a, b, c, d, e, f) {
    a = " " + a[1].replace(/\\/g, "") + " ";
    if(f) {
      return a
    }
    f = 0;
    for(var g;null != (g = b[f]);f++) {
      g && (e ^ (g.className && 0 <= (" " + g.className + " ").replace(/[\t\n]/g, " ").indexOf(a)) ? c || d.push(g) : c && (b[f] = !1))
    }
    return!1
  }, ID:function(a) {
    return a[1].replace(/\\/g, "")
  }, TAG:function(a, b) {
    return a[1].toLowerCase()
  }, CHILD:function(a) {
    if("nth" === a[1]) {
      var b = /(-?)(\d*)n((?:\+|-)?\d*)/.exec("even" === a[2] && "2n" || "odd" === a[2] && "2n+1" || !/\D/.test(a[2]) && "0n+" + a[2] || a[2]);
      a[2] = b[1] + (b[2] || 1) - 0;
      a[3] = b[3] - 0
    }
    a[0] = d++;
    return a
  }, ATTR:function(a, b, c, d, e, f) {
    b = a[1].replace(/\\/g, "");
    !f && k.attrMap[b] && (a[1] = k.attrMap[b]);
    "~=" === a[2] && (a[4] = " " + a[4] + " ");
    return a
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
  }, POS:function(a) {
    a.unshift(!0);
    return a
  }}, filters:{enabled:function(a) {
    return!1 === a.disabled && "hidden" !== a.type
  }, disabled:function(a) {
    return!0 === a.disabled
  }, checked:function(a) {
    return!0 === a.checked
  }, selected:function(a) {
    a.parentNode.selectedIndex;
    return!0 === a.selected
  }, parent:function(a) {
    return!!a.firstChild
  }, empty:function(a) {
    return!a.firstChild
  }, has:function(a, b, c) {
    return!!l(c[3], a).length
  }, header:function(a) {
    return/h\d/i.test(a.nodeName)
  }, text:function(a) {
    return"text" === a.type
  }, radio:function(a) {
    return"radio" === a.type
  }, checkbox:function(a) {
    return"checkbox" === a.type
  }, file:function(a) {
    return"file" === a.type
  }, password:function(a) {
    return"password" === a.type
  }, submit:function(a) {
    return"submit" === a.type
  }, image:function(a) {
    return"image" === a.type
  }, reset:function(a) {
    return"reset" === a.type
  }, button:function(a) {
    return"button" === a.type || "button" === a.nodeName.toLowerCase()
  }, input:function(a) {
    return/input|select|textarea|button/i.test(a.nodeName)
  }}, setFilters:{first:function(a, b) {
    return 0 === b
  }, last:function(a, b, c, d) {
    return b === d.length - 1
  }, even:function(a, b) {
    return 0 === b % 2
  }, odd:function(a, b) {
    return 1 === b % 2
  }, lt:function(a, b, c) {
    return b < c[3] - 0
  }, gt:function(a, b, c) {
    return b > c[3] - 0
  }, nth:function(a, b, c) {
    return c[3] - 0 === b
  }, eq:function(a, b, c) {
    return c[3] - 0 === b
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
  }, CHILD:function(a, b) {
    var c = b[1], d = a;
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
        d = a;
      case "last":
        for(;d = d.nextSibling;) {
          if(1 === d.nodeType) {
            return!1
          }
        }
        return!0;
      case "nth":
        var c = b[2], e = b[3];
        if(1 === c && 0 === e) {
          return!0
        }
        var f = b[0], g = a.parentNode;
        if(g && (g.sizcache !== f || !a.nodeIndex)) {
          for(var k = 0, d = g.firstChild;d;d = d.nextSibling) {
            1 === d.nodeType && (d.nodeIndex = ++k)
          }
          g.sizcache = f
        }
        d = a.nodeIndex - e;
        return 0 === c ? 0 === d : 0 === d % c && 0 <= d / c
    }
  }, ID:function(a, b) {
    return 1 === a.nodeType && a.getAttribute("id") === b
  }, TAG:function(a, b) {
    return"*" === b && 1 === a.nodeType || a.nodeName.toLowerCase() === b
  }, CLASS:function(a, b) {
    return-1 < (" " + (a.className || a.getAttribute("class")) + " ").indexOf(b)
  }, ATTR:function(a, b) {
    var c = b[1], c = k.attrHandle[c] ? k.attrHandle[c](a) : null != a[c] ? a[c] : a.getAttribute(c), d = c + "", e = b[2], f = b[4];
    return null == c ? "!=" === e : "=" === e ? d === f : "*=" === e ? 0 <= d.indexOf(f) : "~=" === e ? 0 <= (" " + d + " ").indexOf(f) : f ? "!=" === e ? d !== f : "^=" === e ? 0 === d.indexOf(f) : "$=" === e ? d.substr(d.length - f.length) === f : "|=" === e ? d === f || d.substr(0, f.length + 1) === f + "-" : !1 : d && !1 !== c
  }, POS:function(a, b, c, d) {
    var e = k.setFilters[b[2]];
    if(e) {
      return e(a, c, b, d)
    }
  }}}, y = k.match.POS, n;
  for(n in k.match) {
    k.match[n] = RegExp(k.match[n].source + /(?![^\[]*\])(?![^\(]*\))/.source), k.leftMatch[n] = RegExp(/(^(?:.|\r|\n)*?)/.source + k.match[n].source.replace(/\\(\d+)/g, function(a, b) {
      return"\\" + (b - 0 + 1)
    }))
  }
  var v = function(a, b) {
    a = Array.prototype.slice.call(a, 0);
    return b ? (b.push.apply(b, a), b) : a
  };
  try {
    Array.prototype.slice.call(document.documentElement.childNodes, 0)[0].nodeType
  }catch(s) {
    v = function(a, b) {
      var c = b || [];
      if("[object Array]" === e.call(a)) {
        Array.prototype.push.apply(c, a)
      }else {
        if("number" === typeof a.length) {
          for(var d = 0, f = a.length;d < f;d++) {
            c.push(a[d])
          }
        }else {
          for(d = 0;a[d];d++) {
            c.push(a[d])
          }
        }
      }
      return c
    }
  }
  var r;
  document.documentElement.compareDocumentPosition ? r = function(a, b) {
    if(!a.compareDocumentPosition || !b.compareDocumentPosition) {
      return a == b && (g = !0), a.compareDocumentPosition ? -1 : 1
    }
    var c = a.compareDocumentPosition(b) & 4 ? -1 : a === b ? 0 : 1;
    0 === c && (g = !0);
    return c
  } : "sourceIndex" in document.documentElement ? r = function(a, b) {
    if(!a.sourceIndex || !b.sourceIndex) {
      return a == b && (g = !0), a.sourceIndex ? -1 : 1
    }
    var c = a.sourceIndex - b.sourceIndex;
    0 === c && (g = !0);
    return c
  } : document.createRange && (r = function(a, b) {
    if(!a.ownerDocument || !b.ownerDocument) {
      return a == b && (g = !0), a.ownerDocument ? -1 : 1
    }
    var c = a.ownerDocument.createRange(), d = b.ownerDocument.createRange();
    c.setStart(a, 0);
    c.setEnd(a, 0);
    d.setStart(b, 0);
    d.setEnd(b, 0);
    c = c.compareBoundaryPoints(Range.START_TO_END, d);
    0 === c && (g = !0);
    return c
  });
  (function() {
    var a = document.createElement("div"), b = "script" + (new Date).getTime();
    a.innerHTML = "<a name='" + b + "'/>";
    var c = document.documentElement;
    c.insertBefore(a, c.firstChild);
    document.getElementById(b) && (k.find.ID = function(a, b, c) {
      if("undefined" !== typeof b.getElementById && !c) {
        return(b = b.getElementById(a[1])) ? b.id === a[1] || "undefined" !== typeof b.getAttributeNode && b.getAttributeNode("id").nodeValue === a[1] ? [b] : void 0 : []
      }
    }, k.filter.ID = function(a, b) {
      var c = "undefined" !== typeof a.getAttributeNode && a.getAttributeNode("id");
      return 1 === a.nodeType && c && c.nodeValue === b
    });
    c.removeChild(a);
    c = a = null
  })();
  (function() {
    var a = document.createElement("div");
    a.appendChild(document.createComment(""));
    0 < a.getElementsByTagName("*").length && (k.find.TAG = function(a, b) {
      var c = b.getElementsByTagName(a[1]);
      if("*" === a[1]) {
        for(var d = [], e = 0;c[e];e++) {
          1 === c[e].nodeType && d.push(c[e])
        }
        c = d
      }
      return c
    });
    a.innerHTML = "<a href='#'></a>";
    a.firstChild && "undefined" !== typeof a.firstChild.getAttribute && "#" !== a.firstChild.getAttribute("href") && (k.attrHandle.href = function(a) {
      return a.getAttribute("href", 2)
    });
    a = null
  })();
  document.querySelectorAll && function() {
    var a = l, b = document.createElement("div");
    b.innerHTML = "<p class='TEST'></p>";
    if(!b.querySelectorAll || 0 !== b.querySelectorAll(".TEST").length) {
      l = function(b, c, d, e) {
        c = c || document;
        if(!e && 9 === c.nodeType && !u(c)) {
          try {
            return v(c.querySelectorAll(b), d)
          }catch(f) {
          }
        }
        return a(b, c, d, e)
      };
      for(var c in a) {
        l[c] = a[c]
      }
      b = null
    }
  }();
  (function() {
    var a = document.createElement("div");
    a.innerHTML = "<div class='test e'></div><div class='test'></div>";
    a.getElementsByClassName && 0 !== a.getElementsByClassName("e").length && (a.lastChild.className = "e", 1 !== a.getElementsByClassName("e").length && (k.order.splice(1, 0, "CLASS"), k.find.CLASS = function(a, b, c) {
      if("undefined" !== typeof b.getElementsByClassName && !c) {
        return b.getElementsByClassName(a[1])
      }
    }, a = null))
  })();
  var w = document.compareDocumentPosition ? function(a, b) {
    return!!(a.compareDocumentPosition(b) & 16)
  } : function(a, b) {
    return a !== b && (a.contains ? a.contains(b) : !0)
  }, u = function(a) {
    return(a = (a ? a.ownerDocument || a : 0).documentElement) ? "HTML" !== a.nodeName : !1
  }, t = function(a, b) {
    for(var c = [], d = "", e, f = b.nodeType ? [b] : b;e = k.match.PSEUDO.exec(a);) {
      d += e[0], a = a.replace(k.match.PSEUDO, "")
    }
    a = k.relative[a] ? a + "*" : a;
    e = 0;
    for(var g = f.length;e < g;e++) {
      l(a, f[e], c)
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
      var g = this, f = a[d].buildHandlerFunction(this.parent[e]);
      this[e] = function() {
        var a = Array.prototype.shift.call(arguments);
        Array.prototype.unshift.call(arguments, this);
        Array.prototype.unshift.call(arguments, a);
        return f.apply(g, arguments)
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
    for(;0 < this.stashedElements.length;) {
      this.unstash().trigger(a)
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
    var b, c, d, f, l, m, u, t = !1, h = [];
    l = this.rules.length;
    g.info("Applying all behavior rules");
    for(b = 0;b < l;b++) {
      for(m = this.rules[b].match(document), m = e(m, function(b) {
        return jQuery.contains(a, b)
      }), f = m.length, 0 >= f && g.debug("Behavior matched no elements:", this.rules[b]), u = h.length, c = 0;c < f;c++) {
        t = !1;
        for(d = 0;d < u;d++) {
          if(m[c] == h[d].element) {
            h[d].behaviors.push(this.rules[b].behavior);
            t = !0;
            break
          }
        }
        t || (h.push({element:m[c], behaviors:[this.rules[b].behavior]}), u = h.length)
      }
    }
    g.debug("Elements with behaviors:", h);
    for(b = 0;b < u;b++) {
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

