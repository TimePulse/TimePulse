/**
 * Javascript code to support switching, memorizing, and preselecting
 * tabs in a tabbed_panel structure for the plugin logical_tabs.
 * 
 * NOTE: Includes a full copy of Jookie by Jon Combe, see below.
 * 
 * Author : Evan Dorn
 * Website: http://lrdesign.com/tools
 * License: MIT License, see included LICENSE file.
 * Version: 1.0
 * Updated: April 29, 2010
 * 
 */   
  
// Set up the click observer on the tabs, and 
$(document).ready( function(){  
  initialize_tabs();
});        
              

function initialize_tabs() {
	$('.tabbed_panel .tab a').click(function(event){ event.preventDefault(); handle_tab_click($(this))});  	  
	$.Jookie.Initialise("tab_memory", 60*24*365);  
	$('.tabbed_panel').each(function(){ pre_select_tab($(this))});	                   
}

// Given a tabbed_panel div element, checks to see if there's a pre-stored
// tab association.  If there is, select that tab.                                                                        
function pre_select_tab(tabbed_panel) {
    tab_memory = get_tab_memory();
    tab_id = tab_memory[memory_key_from_tabbed_panel(tabbed_panel.attr('id'))]  
    if(tab_id != null) {
      select_tab($("#"+tab_id));
    }
}   

// Select a tab that's been clicked on and store that preference in a cookie.
function handle_tab_click(element) {               
  tab = element.parents("li.tab");
  select_tab(tab);    
  store_tab_preference(tab.attr('id'));
}
           
           

// Handle the display changes necessary for selecting a new tab. 
// switches on the clicked tab, finds the matching pane, and switches it
// on. Then iterates the siblings of both and switches them all off
function select_tab(tab) {
  pane_id = tab.attr('id').replace(/_tab$/,"_pane");
  pane = $("#"+pane_id);    
  tab.removeClass('tab_unselected').addClass('tab_selected');
  tab.siblings().removeClass('tab_selected').addClass('tab_unselected');    
  pane.removeClass('pane_unselected').addClass('pane_selected');
  pane.siblings().removeClass('pane_selected').addClass('pane_unselected');    
}               
                 

// extract the containing tabbed panel's ID from the tab's ID
function get_tabbed_panel_id(tab_id) {
	return tab_id.substring(0, tab_id.indexOf("_tp_"));  
}            

// Generate the key associated with this page's path and this tabbed_panel,
// starting from the id of an individual tab.
function memory_key_from_tab(tab_id) {
  return (location.pathname + "--" + get_tabbed_panel_id(tab_id)).replace(/^\//,'')
}                           

// Generate the key associated with this page's path and this tabbed_panel,
// starting from the id of the tabbed panel.
function memory_key_from_tabbed_panel(tabbed_panel_id) {
  return (location.pathname + "--" + tabbed_panel_id).replace(/^\//,'')  
}

// Store which tab was selected for this URL and tabbed panel combination
function store_tab_preference(tab_id) {  
  tab_memory = get_tab_memory();
  if (tab_memory == null) {
    tab_memory = new Object();
  }
  tab_memory[memory_key_from_tab(tab_id)] = tab_id;
  $.Jookie.Set('tab_memory', 'tab_history', tab_memory);           
}   

function get_tab_memory() {
  tab_memory = $.Jookie.Get('tab_memory','tab_history'); 
  if(typeof(tab_memory) == 'undefined') {
	  tab_memory = {};
	}
  return tab_memory;
}

/*
  License:
  Jookie 1.0 jQuery Plugin

  Copyright (c) 2008 Jon Combe (http://joncom.be)

  Permission is hereby granted, free of charge, to any person
  obtaining a copy of this software and associated documentation
  files (the "Software"), to deal in the Software without
  restriction, including without limitation the rights to use,
  copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the
  Software is furnished to do so, subject to the following
  conditions:

  The above copyright notice and this permission notice shall be
  included in all copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
  OTHER DEALINGS IN THE SOFTWARE.
*/

(function($) {

    $.Jookie = {
        Data:         {},
        Debug:        function(a)     { Debug(a)        },
        Delete:       function(a)     { Delete(a)       },    // delete cookie
        Get:          function(a,b)   { return Get(a,b) },    // get a single value from a cookie
        Initialise:   function(a,b)   { Initialise(a,b) },
        Set:          function(a,b,c) { Set(a,b,c)      },    // set a single value to a cookie
        Unset:        function(a,b)   { Unset(a,b)      }     // remove a single value from a cookie
    }

    // PUBLIC: show debugging information
    function Debug(sName) {
        var lsRegExp = /\+/g;
        var sJSON = unescape(String(Extract(sName)).replace(lsRegExp, " "));
        alert("Name: " + sName +
              "\nLifespan: " + $.Jookie.Data[sName].iLifespan +
              " minutes\nCookie Existed Prior to Init: " + $.Jookie.Data[sName].bMadeEarlier + "\n\n" +
              sJSON);
    }

    // PUBLIC: delete a cookie
    function Delete(sName) {
        delete $.Jookie.Data[sName];
        document.cookie = (sName + "=; expires=" + (new Date(1990, 6, 3)).toGMTString() + "; path=/");
    }

    // PRIVATE: extract the contents of a cookie
    function Extract(sName) {
        var vValue = null;
        var aContents = document.cookie.split(';');
        sName += "=";

        // loop through cookie strings
        for (var iIndex in aContents) {
            var sString = aContents[iIndex];
            while (sString.charAt(0) == " ") {
                sString = sString.substring(1, sString.length);
            }
            if (sString.indexOf(sName) == 0) {
                vValue = sString.substring(sName.length, sString.length);
                break;
            }
        }

        // return extracted value
        return vValue;
    }

    // PUBLIC: retrieve a cookie's value
    function Get(sName, sVariableName) {
        return $.Jookie.Data[sName].oValues[sVariableName];
    }

    // PUBLIC: Initialise the plugin
    function Initialise(sName, iLifespanInMinutes) {
        if (typeof $.Jookie.Data[sName] == "undefined") {
            var oRetrievedValues = {};
            var bCookieExists = false;

            // extract cookie value
            var vCookieValue = Extract(sName);
            if (vCookieValue !== null) {
                oRetrievedValues = JSON.parse( unescape(String(vCookieValue).replace(/\+/g, " ")) );
                bCookieExists = true;
            }

            // add cookie details to object
            $.Jookie.Data[sName] = { iLifespan    : iLifespanInMinutes,
                                     bMadeEarlier : bCookieExists,
                                     oValues      : oRetrievedValues };
            Save(sName);
        }
    }

    // PRIVATE: write cookie to user's browser
    function Save(sName) {
        var sExpires = "";
        if ($.Jookie.Data[sName].iLifespan > 0) {
            var dtDate = new Date();
            dtDate.setMinutes(dtDate.getMinutes() + $.Jookie.Data[sName].iLifespan);
            sExpires = ("; expires=" + dtDate.toGMTString());
        }
        document.cookie = (sName + "=" +
                           escape(JSON.stringify($.Jookie.Data[sName].oValues)) +
                           sExpires + "; path=/");
    }

    // PUBLIC: set and save a cookie's value
    function Set(sName, sVariableName, vValue) {
        $.Jookie.Data[sName].oValues[sVariableName] = vValue;
        Save(sName);
    }

    // PUBLIC: delete a single variable from a cookie
    function Unset(sName, sVariableName) {
        delete $.Jookie.Data[sName].oValues[sVariableName];
        Save(sName);
    }

})(jQuery);

/*
    http://www.JSON.org/json2.js
    2008-05-25

    Public Domain.

    NO WARRANTY EXPRESSED OR IMPLIED. USE AT YOUR OWN RISK.

    See http://www.JSON.org/js.html

    This file creates a global JSON object containing two methods: stringify
    and parse.

        JSON.stringify(value, replacer, space)
            value       any JavaScript value, usually an object or array.

            replacer    an optional parameter that determines how object
                        values are stringified for objects without a toJSON
                        method. It can be a function or an array.

            space       an optional parameter that specifies the indentation
                        of nested structures. If it is omitted, the text will
                        be packed without extra whitespace. If it is a number,
                        it will specify the number of spaces to indent at each
                        level. If it is a string (such as '\t' or '&nbsp;'),
                        it contains the characters used to indent at each level.

            This method produces a JSON text from a JavaScript value.

            When an object value is found, if the object contains a toJSON
            method, its toJSON method will be called and the result will be
            stringified. A toJSON method does not serialize: it returns the
            value represented by the name/value pair that should be serialized,
            or undefined if nothing should be serialized. The toJSON method
            will be passed the key associated with the value, and this will be
            bound to the object holding the key.

            For example, this would serialize Dates as ISO strings.

                Date.prototype.toJSON = function (key) {
                    function f(n) {
                        // Format integers to have at least two digits.
                        return n < 10 ? '0' + n : n;
                    }

                    return this.getUTCFullYear()   + '-' +
                         f(this.getUTCMonth() + 1) + '-' +
                         f(this.getUTCDate())      + 'T' +
                         f(this.getUTCHours())     + ':' +
                         f(this.getUTCMinutes())   + ':' +
                         f(this.getUTCSeconds())   + 'Z';
                };

            You can provide an optional replacer method. It will be passed the
            key and value of each member, with this bound to the containing
            object. The value that is returned from your method will be
            serialized. If your method returns undefined, then the member will
            be excluded from the serialization.

            If the replacer parameter is an array, then it will be used to
            select the members to be serialized. It filters the results such
            that only members with keys listed in the replacer array are
            stringified.

            Values that do not have JSON representations, such as undefined or
            functions, will not be serialized. Such values in objects will be
            dropped; in arrays they will be replaced with null. You can use
            a replacer function to replace those with JSON values.
            JSON.stringify(undefined) returns undefined.

            The optional space parameter produces a stringification of the
            value that is filled with line breaks and indentation to make it
            easier to read.

            If the space parameter is a non-empty string, then that string will
            be used for indentation. If the space parameter is a number, then
            the indentation will be that many spaces.

            Example:

            text = JSON.stringify(['e', {pluribus: 'unum'}]);
            // text is '["e",{"pluribus":"unum"}]'


            text = JSON.stringify(['e', {pluribus: 'unum'}], null, '\t');
            // text is '[\n\t"e",\n\t{\n\t\t"pluribus": "unum"\n\t}\n]'

            text = JSON.stringify([new Date()], function (key, value) {
                return this[key] instanceof Date ?
                    'Date(' + this[key] + ')' : value;
            });
            // text is '["Date(---current time---)"]'


        JSON.parse(text, reviver)
            This method parses a JSON text to produce an object or array.
            It can throw a SyntaxError exception.

            The optional reviver parameter is a function that can filter and
            transform the results. It receives each of the keys and values,
            and its return value is used instead of the original value.
            If it returns what it received, then the structure is not modified.
            If it returns undefined then the member is deleted.

            Example:

            // Parse the text. Values that look like ISO date strings will
            // be converted to Date objects.

            myData = JSON.parse(text, function (key, value) {
                var a;
                if (typeof value === 'string') {
                    a =
/^(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2}):(\d{2}(?:\.\d*)?)Z$/.exec(value);
                    if (a) {
                        return new Date(Date.UTC(+a[1], +a[2] - 1, +a[3], +a[4],
                            +a[5], +a[6]));
                    }
                }
                return value;
            });

            myData = JSON.parse('["Date(09/09/2001)"]', function (key, value) {
                var d;
                if (typeof value === 'string' &&
                        value.slice(0, 5) === 'Date(' &&
                        value.slice(-1) === ')') {
                    d = new Date(value.slice(5, -1));
                    if (d) {
                        return d;
                    }
                }
                return value;
            });


    This is a reference implementation. You are free to copy, modify, or
    redistribute.

    This code should be minified before deployment.
    See http://javascript.crockford.com/jsmin.html

    USE YOUR OWN COPY. IT IS EXTREMELY UNWISE TO LOAD CODE FROM SERVERS YOU DO
    NOT CONTROL.
*/

/*jslint evil: true */

/*global JSON */

/*members "", "\b", "\t", "\n", "\f", "\r", "\"", JSON, "\\", call,
    charCodeAt, getUTCDate, getUTCFullYear, getUTCHours, getUTCMinutes,
    getUTCMonth, getUTCSeconds, hasOwnProperty, join, lastIndex, length,
    parse, propertyIsEnumerable, prototype, push, replace, slice, stringify,
    test, toJSON, toString
*/

if (!this.JSON) {

// Create a JSON object only if one does not already exist. We create the
// object in a closure to avoid creating global variables.

    JSON = function () {

        function f(n) {
            // Format integers to have at least two digits.
            return n < 10 ? '0' + n : n;
        }

        Date.prototype.toJSON = function (key) {

            return this.getUTCFullYear()   + '-' +
                 f(this.getUTCMonth() + 1) + '-' +
                 f(this.getUTCDate())      + 'T' +
                 f(this.getUTCHours())     + ':' +
                 f(this.getUTCMinutes())   + ':' +
                 f(this.getUTCSeconds())   + 'Z';
        };

        var cx = /[\u0000\u00ad\u0600-\u0604\u070f\u17b4\u17b5\u200c-\u200f\u2028-\u202f\u2060-\u206f\ufeff\ufff0-\uffff]/g,
            escapeable = /[\\\"\x00-\x1f\x7f-\x9f\u00ad\u0600-\u0604\u070f\u17b4\u17b5\u200c-\u200f\u2028-\u202f\u2060-\u206f\ufeff\ufff0-\uffff]/g,
            gap,
            indent,
            meta = {    // table of character substitutions
                '\b': '\\b',
                '\t': '\\t',
                '\n': '\\n',
                '\f': '\\f',
                '\r': '\\r',
                '"' : '\\"',
                '\\': '\\\\'
            },
            rep;


        function quote(string) {

// If the string contains no control characters, no quote characters, and no
// backslash characters, then we can safely slap some quotes around it.
// Otherwise we must also replace the offending characters with safe escape
// sequences.

            escapeable.lastIndex = 0;
            return escapeable.test(string) ?
                '"' + string.replace(escapeable, function (a) {
                    var c = meta[a];
                    if (typeof c === 'string') {
                        return c;
                    }
                    return '\\u' + ('0000' +
                            (+(a.charCodeAt(0))).toString(16)).slice(-4);
                }) + '"' :
                '"' + string + '"';
        }


        function str(key, holder) {

// Produce a string from holder[key].

            var i,          // The loop counter.
                k,          // The member key.
                v,          // The member value.
                length,
                mind = gap,
                partial,
                value = holder[key];

// If the value has a toJSON method, call it to obtain a replacement value.

            if (value && typeof value === 'object' &&
                    typeof value.toJSON === 'function') {
                value = value.toJSON(key);
            }

// If we were called with a replacer function, then call the replacer to
// obtain a replacement value.

            if (typeof rep === 'function') {
                value = rep.call(holder, key, value);
            }

// What happens next depends on the value's type.

            switch (typeof value) {
            case 'string':
                return quote(value);

            case 'number':

// JSON numbers must be finite. Encode non-finite numbers as null.

                return isFinite(value) ? String(value) : 'null';

            case 'boolean':
            case 'null':

// If the value is a boolean or null, convert it to a string. Note:
// typeof null does not produce 'null'. The case is included here in
// the remote chance that this gets fixed someday.

                return String(value);

// If the type is 'object', we might be dealing with an object or an array or
// null.

            case 'object':

// Due to a specification blunder in ECMAScript, typeof null is 'object',
// so watch out for that case.

                if (!value) {
                    return 'null';
                }

// Make an array to hold the partial results of stringifying this object value.

                gap += indent;
                partial = [];

// If the object has a dontEnum length property, we'll treat it as an array.

                if (typeof value.length === 'number' &&
                        !(value.propertyIsEnumerable('length'))) {

// The object is an array. Stringify every element. Use null as a placeholder
// for non-JSON values.

                    length = value.length;
                    for (i = 0; i < length; i += 1) {
                        partial[i] = str(i, value) || 'null';
                    }

// Join all of the elements together, separated with commas, and wrap them in
// brackets.

                    v = partial.length === 0 ? '[]' :
                        gap ? '[\n' + gap +
                                partial.join(',\n' + gap) + '\n' +
                                    mind + ']' :
                              '[' + partial.join(',') + ']';
                    gap = mind;
                    return v;
                }

// If the replacer is an array, use it to select the members to be stringified.

                if (rep && typeof rep === 'object') {
                    length = rep.length;
                    for (i = 0; i < length; i += 1) {
                        k = rep[i];
                        if (typeof k === 'string') {
                            v = str(k, value, rep);
                            if (v) {
                                partial.push(quote(k) + (gap ? ': ' : ':') + v);
                            }
                        }
                    }
                } else {

// Otherwise, iterate through all of the keys in the object.

                    for (k in value) {
                        if (Object.hasOwnProperty.call(value, k)) {
                            v = str(k, value, rep);
                            if (v) {
                                partial.push(quote(k) + (gap ? ': ' : ':') + v);
                            }
                        }
                    }
                }

// Join all of the member texts together, separated with commas,
// and wrap them in braces.

                v = partial.length === 0 ? '{}' :
                    gap ? '{\n' + gap + partial.join(',\n' + gap) + '\n' +
                            mind + '}' : '{' + partial.join(',') + '}';
                gap = mind;
                return v;
            }
        }

// Return the JSON object containing the stringify and parse methods.

        return {
            stringify: function (value, replacer, space) {

// The stringify method takes a value and an optional replacer, and an optional
// space parameter, and returns a JSON text. The replacer can be a function
// that can replace values, or an array of strings that will select the keys.
// A default replacer method can be provided. Use of the space parameter can
// produce text that is more easily readable.

                var i;
                gap = '';
                indent = '';

// If the space parameter is a number, make an indent string containing that
// many spaces.

                if (typeof space === 'number') {
                    for (i = 0; i < space; i += 1) {
                        indent += ' ';
                    }

// If the space parameter is a string, it will be used as the indent string.

                } else if (typeof space === 'string') {
                    indent = space;
                }

// If there is a replacer, it must be a function or an array.
// Otherwise, throw an error.

                rep = replacer;
                if (replacer && typeof replacer !== 'function' &&
                        (typeof replacer !== 'object' ||
                         typeof replacer.length !== 'number')) {
                    throw new Error('JSON.stringify');
                }

// Make a fake root object containing our value under the key of ''.
// Return the result of stringifying the value.

                return str('', {'': value});
            },


            parse: function (text, reviver) {

// The parse method takes a text and an optional reviver function, and returns
// a JavaScript value if the text is a valid JSON text.

                var j;

                function walk(holder, key) {

// The walk method is used to recursively walk the resulting structure so
// that modifications can be made.

                    var k, v, value = holder[key];
                    if (value && typeof value === 'object') {
                        for (k in value) {
                            if (Object.hasOwnProperty.call(value, k)) {
                                v = walk(value, k);
                                if (v !== undefined) {
                                    value[k] = v;
                                } else {
                                    delete value[k];
                                }
                            }
                        }
                    }
                    return reviver.call(holder, key, value);
                }


// Parsing happens in four stages. In the first stage, we replace certain
// Unicode characters with escape sequences. JavaScript handles many characters
// incorrectly, either silently deleting them, or treating them as line endings.

                cx.lastIndex = 0;
                if (cx.test(text)) {
                    text = text.replace(cx, function (a) {
                        return '\\u' + ('0000' +
                                (+(a.charCodeAt(0))).toString(16)).slice(-4);
                    });
                }

// In the second stage, we run the text against regular expressions that look
// for non-JSON patterns. We are especially concerned with '()' and 'new'
// because they can cause invocation, and '=' because it can cause mutation.
// But just to be safe, we want to reject all unexpected forms.

// We split the second stage into 4 regexp operations in order to work around
// crippling inefficiencies in IE's and Safari's regexp engines. First we
// replace the JSON backslash pairs with '@' (a non-JSON character). Second, we
// replace all simple value tokens with ']' characters. Third, we delete all
// open brackets that follow a colon or comma or that begin the text. Finally,
// we look to see that the remaining characters are only whitespace or ']' or
// ',' or ':' or '{' or '}'. If that is so, then the text is safe for eval.

                if (/^[\],:{}\s]*$/.
test(text.replace(/\\(?:["\\\/bfnrt]|u[0-9a-fA-F]{4})/g, '@').
replace(/"[^"\\\n\r]*"|true|false|null|-?\d+(?:\.\d*)?(?:[eE][+\-]?\d+)?/g, ']').
replace(/(?:^|:|,)(?:\s*\[)+/g, ''))) {

// In the third stage we use the eval function to compile the text into a
// JavaScript structure. The '{' operator is subject to a syntactic ambiguity
// in JavaScript: it can begin a block or an object literal. We wrap the text
// in parens to eliminate the ambiguity.

                    j = eval('(' + text + ')');

// In the optional fourth stage, we recursively walk the new structure, passing
// each name/value pair to a reviver function for possible transformation.

                    return typeof reviver === 'function' ?
                        walk({'': j}, '') : j;
                }

// If the text is not JSON parseable, then a SyntaxError is thrown.

                throw new SyntaxError('JSON.parse');
            }
        };
    }();
}
