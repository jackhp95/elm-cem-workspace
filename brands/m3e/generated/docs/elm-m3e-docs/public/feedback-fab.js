/*! feedback-fab widget — Elm UI + JS host + @m3e/web, one IIFE.
 * Load as a classic script: <script src="feedback-fab.js" defer></script> */
(function(scope){
'use strict';

function F(arity, fun, wrapper) {
  wrapper.a = arity;
  wrapper.f = fun;
  return wrapper;
}

function F2(fun) {
  return F(2, fun, function(a) { return function(b) { return fun(a,b); }; })
}
function F3(fun) {
  return F(3, fun, function(a) {
    return function(b) { return function(c) { return fun(a, b, c); }; };
  });
}
function F4(fun) {
  return F(4, fun, function(a) { return function(b) { return function(c) {
    return function(d) { return fun(a, b, c, d); }; }; };
  });
}
function F5(fun) {
  return F(5, fun, function(a) { return function(b) { return function(c) {
    return function(d) { return function(e) { return fun(a, b, c, d, e); }; }; }; };
  });
}
function F6(fun) {
  return F(6, fun, function(a) { return function(b) { return function(c) {
    return function(d) { return function(e) { return function(f) {
    return fun(a, b, c, d, e, f); }; }; }; }; };
  });
}
function F7(fun) {
  return F(7, fun, function(a) { return function(b) { return function(c) {
    return function(d) { return function(e) { return function(f) {
    return function(g) { return fun(a, b, c, d, e, f, g); }; }; }; }; }; };
  });
}
function F8(fun) {
  return F(8, fun, function(a) { return function(b) { return function(c) {
    return function(d) { return function(e) { return function(f) {
    return function(g) { return function(h) {
    return fun(a, b, c, d, e, f, g, h); }; }; }; }; }; }; };
  });
}
function F9(fun) {
  return F(9, fun, function(a) { return function(b) { return function(c) {
    return function(d) { return function(e) { return function(f) {
    return function(g) { return function(h) { return function(i) {
    return fun(a, b, c, d, e, f, g, h, i); }; }; }; }; }; }; }; };
  });
}

function A2(fun, a, b) {
  return fun.a === 2 ? fun.f(a, b) : fun(a)(b);
}
function A3(fun, a, b, c) {
  return fun.a === 3 ? fun.f(a, b, c) : fun(a)(b)(c);
}
function A4(fun, a, b, c, d) {
  return fun.a === 4 ? fun.f(a, b, c, d) : fun(a)(b)(c)(d);
}
function A5(fun, a, b, c, d, e) {
  return fun.a === 5 ? fun.f(a, b, c, d, e) : fun(a)(b)(c)(d)(e);
}
function A6(fun, a, b, c, d, e, f) {
  return fun.a === 6 ? fun.f(a, b, c, d, e, f) : fun(a)(b)(c)(d)(e)(f);
}
function A7(fun, a, b, c, d, e, f, g) {
  return fun.a === 7 ? fun.f(a, b, c, d, e, f, g) : fun(a)(b)(c)(d)(e)(f)(g);
}
function A8(fun, a, b, c, d, e, f, g, h) {
  return fun.a === 8 ? fun.f(a, b, c, d, e, f, g, h) : fun(a)(b)(c)(d)(e)(f)(g)(h);
}
function A9(fun, a, b, c, d, e, f, g, h, i) {
  return fun.a === 9 ? fun.f(a, b, c, d, e, f, g, h, i) : fun(a)(b)(c)(d)(e)(f)(g)(h)(i);
}




// EQUALITY

function _Utils_eq(x, y)
{
	for (
		var pair, stack = [], isEqual = _Utils_eqHelp(x, y, 0, stack);
		isEqual && (pair = stack.pop());
		isEqual = _Utils_eqHelp(pair.a, pair.b, 0, stack)
		)
	{}

	return isEqual;
}

function _Utils_eqHelp(x, y, depth, stack)
{
	if (x === y)
	{
		return true;
	}

	if (typeof x !== 'object' || x === null || y === null)
	{
		typeof x === 'function' && _Debug_crash(5);
		return false;
	}

	if (depth > 100)
	{
		stack.push(_Utils_Tuple2(x,y));
		return true;
	}

	/**_UNUSED/
	if (x.$ === 'Set_elm_builtin')
	{
		x = $elm$core$Set$toList(x);
		y = $elm$core$Set$toList(y);
	}
	if (x.$ === 'RBNode_elm_builtin' || x.$ === 'RBEmpty_elm_builtin')
	{
		x = $elm$core$Dict$toList(x);
		y = $elm$core$Dict$toList(y);
	}
	//*/

	/**/
	if (x.$ < 0)
	{
		x = $elm$core$Dict$toList(x);
		y = $elm$core$Dict$toList(y);
	}
	//*/

	for (var key in x)
	{
		if (!_Utils_eqHelp(x[key], y[key], depth + 1, stack))
		{
			return false;
		}
	}
	return true;
}

var _Utils_equal = F2(_Utils_eq);
var _Utils_notEqual = F2(function(a, b) { return !_Utils_eq(a,b); });



// COMPARISONS

// Code in Generate/JavaScript.hs, Basics.js, and List.js depends on
// the particular integer values assigned to LT, EQ, and GT.

function _Utils_cmp(x, y, ord)
{
	if (typeof x !== 'object')
	{
		return x === y ? /*EQ*/ 0 : x < y ? /*LT*/ -1 : /*GT*/ 1;
	}

	/**_UNUSED/
	if (x instanceof String)
	{
		var a = x.valueOf();
		var b = y.valueOf();
		return a === b ? 0 : a < b ? -1 : 1;
	}
	//*/

	/**/
	if (typeof x.$ === 'undefined')
	//*/
	/**_UNUSED/
	if (x.$[0] === '#')
	//*/
	{
		return (ord = _Utils_cmp(x.a, y.a))
			? ord
			: (ord = _Utils_cmp(x.b, y.b))
				? ord
				: _Utils_cmp(x.c, y.c);
	}

	// traverse conses until end of a list or a mismatch
	for (; x.b && y.b && !(ord = _Utils_cmp(x.a, y.a)); x = x.b, y = y.b) {} // WHILE_CONSES
	return ord || (x.b ? /*GT*/ 1 : y.b ? /*LT*/ -1 : /*EQ*/ 0);
}

var _Utils_lt = F2(function(a, b) { return _Utils_cmp(a, b) < 0; });
var _Utils_le = F2(function(a, b) { return _Utils_cmp(a, b) < 1; });
var _Utils_gt = F2(function(a, b) { return _Utils_cmp(a, b) > 0; });
var _Utils_ge = F2(function(a, b) { return _Utils_cmp(a, b) >= 0; });

var _Utils_compare = F2(function(x, y)
{
	var n = _Utils_cmp(x, y);
	return n < 0 ? $elm$core$Basics$LT : n ? $elm$core$Basics$GT : $elm$core$Basics$EQ;
});


// COMMON VALUES

var _Utils_Tuple0 = 0;
var _Utils_Tuple0_UNUSED = { $: '#0' };

function _Utils_Tuple2(a, b) { return { a: a, b: b }; }
function _Utils_Tuple2_UNUSED(a, b) { return { $: '#2', a: a, b: b }; }

function _Utils_Tuple3(a, b, c) { return { a: a, b: b, c: c }; }
function _Utils_Tuple3_UNUSED(a, b, c) { return { $: '#3', a: a, b: b, c: c }; }

function _Utils_chr(c) { return c; }
function _Utils_chr_UNUSED(c) { return new String(c); }


// RECORDS

function _Utils_update(oldRecord, updatedFields)
{
	var newRecord = {};

	for (var key in oldRecord)
	{
		newRecord[key] = oldRecord[key];
	}

	for (var key in updatedFields)
	{
		newRecord[key] = updatedFields[key];
	}

	return newRecord;
}


// APPEND

var _Utils_append = F2(_Utils_ap);

function _Utils_ap(xs, ys)
{
	// append Strings
	if (typeof xs === 'string')
	{
		return xs + ys;
	}

	// append Lists
	if (!xs.b)
	{
		return ys;
	}
	var root = _List_Cons(xs.a, ys);
	xs = xs.b
	for (var curr = root; xs.b; xs = xs.b) // WHILE_CONS
	{
		curr = curr.b = _List_Cons(xs.a, ys);
	}
	return root;
}



var _List_Nil = { $: 0 };
var _List_Nil_UNUSED = { $: '[]' };

function _List_Cons(hd, tl) { return { $: 1, a: hd, b: tl }; }
function _List_Cons_UNUSED(hd, tl) { return { $: '::', a: hd, b: tl }; }


var _List_cons = F2(_List_Cons);

function _List_fromArray(arr)
{
	var out = _List_Nil;
	for (var i = arr.length; i--; )
	{
		out = _List_Cons(arr[i], out);
	}
	return out;
}

function _List_toArray(xs)
{
	for (var out = []; xs.b; xs = xs.b) // WHILE_CONS
	{
		out.push(xs.a);
	}
	return out;
}

var _List_map2 = F3(function(f, xs, ys)
{
	for (var arr = []; xs.b && ys.b; xs = xs.b, ys = ys.b) // WHILE_CONSES
	{
		arr.push(A2(f, xs.a, ys.a));
	}
	return _List_fromArray(arr);
});

var _List_map3 = F4(function(f, xs, ys, zs)
{
	for (var arr = []; xs.b && ys.b && zs.b; xs = xs.b, ys = ys.b, zs = zs.b) // WHILE_CONSES
	{
		arr.push(A3(f, xs.a, ys.a, zs.a));
	}
	return _List_fromArray(arr);
});

var _List_map4 = F5(function(f, ws, xs, ys, zs)
{
	for (var arr = []; ws.b && xs.b && ys.b && zs.b; ws = ws.b, xs = xs.b, ys = ys.b, zs = zs.b) // WHILE_CONSES
	{
		arr.push(A4(f, ws.a, xs.a, ys.a, zs.a));
	}
	return _List_fromArray(arr);
});

var _List_map5 = F6(function(f, vs, ws, xs, ys, zs)
{
	for (var arr = []; vs.b && ws.b && xs.b && ys.b && zs.b; vs = vs.b, ws = ws.b, xs = xs.b, ys = ys.b, zs = zs.b) // WHILE_CONSES
	{
		arr.push(A5(f, vs.a, ws.a, xs.a, ys.a, zs.a));
	}
	return _List_fromArray(arr);
});

var _List_sortBy = F2(function(f, xs)
{
	return _List_fromArray(_List_toArray(xs).sort(function(a, b) {
		return _Utils_cmp(f(a), f(b));
	}));
});

var _List_sortWith = F2(function(f, xs)
{
	return _List_fromArray(_List_toArray(xs).sort(function(a, b) {
		var ord = A2(f, a, b);
		return ord === $elm$core$Basics$EQ ? 0 : ord === $elm$core$Basics$LT ? -1 : 1;
	}));
});



var _JsArray_empty = [];

function _JsArray_singleton(value)
{
    return [value];
}

function _JsArray_length(array)
{
    return array.length;
}

var _JsArray_initialize = F3(function(size, offset, func)
{
    var result = new Array(size);

    for (var i = 0; i < size; i++)
    {
        result[i] = func(offset + i);
    }

    return result;
});

var _JsArray_initializeFromList = F2(function (max, ls)
{
    var result = new Array(max);

    for (var i = 0; i < max && ls.b; i++)
    {
        result[i] = ls.a;
        ls = ls.b;
    }

    result.length = i;
    return _Utils_Tuple2(result, ls);
});

var _JsArray_unsafeGet = F2(function(index, array)
{
    return array[index];
});

var _JsArray_unsafeSet = F3(function(index, value, array)
{
    var length = array.length;
    var result = new Array(length);

    for (var i = 0; i < length; i++)
    {
        result[i] = array[i];
    }

    result[index] = value;
    return result;
});

var _JsArray_push = F2(function(value, array)
{
    var length = array.length;
    var result = new Array(length + 1);

    for (var i = 0; i < length; i++)
    {
        result[i] = array[i];
    }

    result[length] = value;
    return result;
});

var _JsArray_foldl = F3(function(func, acc, array)
{
    var length = array.length;

    for (var i = 0; i < length; i++)
    {
        acc = A2(func, array[i], acc);
    }

    return acc;
});

var _JsArray_foldr = F3(function(func, acc, array)
{
    for (var i = array.length - 1; i >= 0; i--)
    {
        acc = A2(func, array[i], acc);
    }

    return acc;
});

var _JsArray_map = F2(function(func, array)
{
    var length = array.length;
    var result = new Array(length);

    for (var i = 0; i < length; i++)
    {
        result[i] = func(array[i]);
    }

    return result;
});

var _JsArray_indexedMap = F3(function(func, offset, array)
{
    var length = array.length;
    var result = new Array(length);

    for (var i = 0; i < length; i++)
    {
        result[i] = A2(func, offset + i, array[i]);
    }

    return result;
});

var _JsArray_slice = F3(function(from, to, array)
{
    return array.slice(from, to);
});

var _JsArray_appendN = F3(function(n, dest, source)
{
    var destLen = dest.length;
    var itemsToCopy = n - destLen;

    if (itemsToCopy > source.length)
    {
        itemsToCopy = source.length;
    }

    var size = destLen + itemsToCopy;
    var result = new Array(size);

    for (var i = 0; i < destLen; i++)
    {
        result[i] = dest[i];
    }

    for (var i = 0; i < itemsToCopy; i++)
    {
        result[i + destLen] = source[i];
    }

    return result;
});



// LOG

var _Debug_log = F2(function(tag, value)
{
	return value;
});

var _Debug_log_UNUSED = F2(function(tag, value)
{
	console.log(tag + ': ' + _Debug_toString(value));
	return value;
});


// TODOS

function _Debug_todo(moduleName, region)
{
	return function(message) {
		_Debug_crash(8, moduleName, region, message);
	};
}

function _Debug_todoCase(moduleName, region, value)
{
	return function(message) {
		_Debug_crash(9, moduleName, region, value, message);
	};
}


// TO STRING

function _Debug_toString(value)
{
	return '<internals>';
}

function _Debug_toString_UNUSED(value)
{
	return _Debug_toAnsiString(false, value);
}

function _Debug_toAnsiString(ansi, value)
{
	if (typeof value === 'function')
	{
		return _Debug_internalColor(ansi, '<function>');
	}

	if (typeof value === 'boolean')
	{
		return _Debug_ctorColor(ansi, value ? 'True' : 'False');
	}

	if (typeof value === 'number')
	{
		return _Debug_numberColor(ansi, value + '');
	}

	if (value instanceof String)
	{
		return _Debug_charColor(ansi, "'" + _Debug_addSlashes(value, true) + "'");
	}

	if (typeof value === 'string')
	{
		return _Debug_stringColor(ansi, '"' + _Debug_addSlashes(value, false) + '"');
	}

	if (typeof value === 'object' && '$' in value)
	{
		var tag = value.$;

		if (typeof tag === 'number')
		{
			return _Debug_internalColor(ansi, '<internals>');
		}

		if (tag[0] === '#')
		{
			var output = [];
			for (var k in value)
			{
				if (k === '$') continue;
				output.push(_Debug_toAnsiString(ansi, value[k]));
			}
			return '(' + output.join(',') + ')';
		}

		if (tag === 'Set_elm_builtin')
		{
			return _Debug_ctorColor(ansi, 'Set')
				+ _Debug_fadeColor(ansi, '.fromList') + ' '
				+ _Debug_toAnsiString(ansi, $elm$core$Set$toList(value));
		}

		if (tag === 'RBNode_elm_builtin' || tag === 'RBEmpty_elm_builtin')
		{
			return _Debug_ctorColor(ansi, 'Dict')
				+ _Debug_fadeColor(ansi, '.fromList') + ' '
				+ _Debug_toAnsiString(ansi, $elm$core$Dict$toList(value));
		}

		if (tag === 'Array_elm_builtin')
		{
			return _Debug_ctorColor(ansi, 'Array')
				+ _Debug_fadeColor(ansi, '.fromList') + ' '
				+ _Debug_toAnsiString(ansi, $elm$core$Array$toList(value));
		}

		if (tag === '::' || tag === '[]')
		{
			var output = '[';

			value.b && (output += _Debug_toAnsiString(ansi, value.a), value = value.b)

			for (; value.b; value = value.b) // WHILE_CONS
			{
				output += ',' + _Debug_toAnsiString(ansi, value.a);
			}
			return output + ']';
		}

		var output = '';
		for (var i in value)
		{
			if (i === '$') continue;
			var str = _Debug_toAnsiString(ansi, value[i]);
			var c0 = str[0];
			var parenless = c0 === '{' || c0 === '(' || c0 === '[' || c0 === '<' || c0 === '"' || str.indexOf(' ') < 0;
			output += ' ' + (parenless ? str : '(' + str + ')');
		}
		return _Debug_ctorColor(ansi, tag) + output;
	}

	if (typeof DataView === 'function' && value instanceof DataView)
	{
		return _Debug_stringColor(ansi, '<' + value.byteLength + ' bytes>');
	}

	if (typeof File !== 'undefined' && value instanceof File)
	{
		return _Debug_internalColor(ansi, '<' + value.name + '>');
	}

	if (typeof value === 'object')
	{
		var output = [];
		for (var key in value)
		{
			var field = key[0] === '_' ? key.slice(1) : key;
			output.push(_Debug_fadeColor(ansi, field) + ' = ' + _Debug_toAnsiString(ansi, value[key]));
		}
		if (output.length === 0)
		{
			return '{}';
		}
		return '{ ' + output.join(', ') + ' }';
	}

	return _Debug_internalColor(ansi, '<internals>');
}

function _Debug_addSlashes(str, isChar)
{
	var s = str
		.replace(/\\/g, '\\\\')
		.replace(/\n/g, '\\n')
		.replace(/\t/g, '\\t')
		.replace(/\r/g, '\\r')
		.replace(/\v/g, '\\v')
		.replace(/\0/g, '\\0');

	if (isChar)
	{
		return s.replace(/\'/g, '\\\'');
	}
	else
	{
		return s.replace(/\"/g, '\\"');
	}
}

function _Debug_ctorColor(ansi, string)
{
	return ansi ? '\x1b[96m' + string + '\x1b[0m' : string;
}

function _Debug_numberColor(ansi, string)
{
	return ansi ? '\x1b[95m' + string + '\x1b[0m' : string;
}

function _Debug_stringColor(ansi, string)
{
	return ansi ? '\x1b[93m' + string + '\x1b[0m' : string;
}

function _Debug_charColor(ansi, string)
{
	return ansi ? '\x1b[92m' + string + '\x1b[0m' : string;
}

function _Debug_fadeColor(ansi, string)
{
	return ansi ? '\x1b[37m' + string + '\x1b[0m' : string;
}

function _Debug_internalColor(ansi, string)
{
	return ansi ? '\x1b[36m' + string + '\x1b[0m' : string;
}

function _Debug_toHexDigit(n)
{
	return String.fromCharCode(n < 10 ? 48 + n : 55 + n);
}


// CRASH


function _Debug_crash(identifier)
{
	throw new Error('https://github.com/elm/core/blob/1.0.0/hints/' + identifier + '.md');
}


function _Debug_crash_UNUSED(identifier, fact1, fact2, fact3, fact4)
{
	switch(identifier)
	{
		case 0:
			throw new Error('What node should I take over? In JavaScript I need something like:\n\n    Elm.Main.init({\n        node: document.getElementById("elm-node")\n    })\n\nYou need to do this with any Browser.sandbox or Browser.element program.');

		case 1:
			throw new Error('Browser.application programs cannot handle URLs like this:\n\n    ' + document.location.href + '\n\nWhat is the root? The root of your file system? Try looking at this program with `elm reactor` or some other server.');

		case 2:
			var jsonErrorString = fact1;
			throw new Error('Problem with the flags given to your Elm program on initialization.\n\n' + jsonErrorString);

		case 3:
			var portName = fact1;
			throw new Error('There can only be one port named `' + portName + '`, but your program has multiple.');

		case 4:
			var portName = fact1;
			var problem = fact2;
			throw new Error('Trying to send an unexpected type of value through port `' + portName + '`:\n' + problem);

		case 5:
			throw new Error('Trying to use `(==)` on functions.\nThere is no way to know if functions are "the same" in the Elm sense.\nRead more about this at https://package.elm-lang.org/packages/elm/core/latest/Basics#== which describes why it is this way and what the better version will look like.');

		case 6:
			var moduleName = fact1;
			throw new Error('Your page is loading multiple Elm scripts with a module named ' + moduleName + '. Maybe a duplicate script is getting loaded accidentally? If not, rename one of them so I know which is which!');

		case 8:
			var moduleName = fact1;
			var region = fact2;
			var message = fact3;
			throw new Error('TODO in module `' + moduleName + '` ' + _Debug_regionToString(region) + '\n\n' + message);

		case 9:
			var moduleName = fact1;
			var region = fact2;
			var value = fact3;
			var message = fact4;
			throw new Error(
				'TODO in module `' + moduleName + '` from the `case` expression '
				+ _Debug_regionToString(region) + '\n\nIt received the following value:\n\n    '
				+ _Debug_toString(value).replace('\n', '\n    ')
				+ '\n\nBut the branch that handles it says:\n\n    ' + message.replace('\n', '\n    ')
			);

		case 10:
			throw new Error('Bug in https://github.com/elm/virtual-dom/issues');

		case 11:
			throw new Error('Cannot perform mod 0. Division by zero error.');
	}
}

function _Debug_regionToString(region)
{
	if (region.aR.ak === region.a7.ak)
	{
		return 'on line ' + region.aR.ak;
	}
	return 'on lines ' + region.aR.ak + ' through ' + region.a7.ak;
}



// MATH

var _Basics_add = F2(function(a, b) { return a + b; });
var _Basics_sub = F2(function(a, b) { return a - b; });
var _Basics_mul = F2(function(a, b) { return a * b; });
var _Basics_fdiv = F2(function(a, b) { return a / b; });
var _Basics_idiv = F2(function(a, b) { return (a / b) | 0; });
var _Basics_pow = F2(Math.pow);

var _Basics_remainderBy = F2(function(b, a) { return a % b; });

// https://www.microsoft.com/en-us/research/wp-content/uploads/2016/02/divmodnote-letter.pdf
var _Basics_modBy = F2(function(modulus, x)
{
	var answer = x % modulus;
	return modulus === 0
		? _Debug_crash(11)
		:
	((answer > 0 && modulus < 0) || (answer < 0 && modulus > 0))
		? answer + modulus
		: answer;
});


// TRIGONOMETRY

var _Basics_pi = Math.PI;
var _Basics_e = Math.E;
var _Basics_cos = Math.cos;
var _Basics_sin = Math.sin;
var _Basics_tan = Math.tan;
var _Basics_acos = Math.acos;
var _Basics_asin = Math.asin;
var _Basics_atan = Math.atan;
var _Basics_atan2 = F2(Math.atan2);


// MORE MATH

function _Basics_toFloat(x) { return x; }
function _Basics_truncate(n) { return n | 0; }
function _Basics_isInfinite(n) { return n === Infinity || n === -Infinity; }

var _Basics_ceiling = Math.ceil;
var _Basics_floor = Math.floor;
var _Basics_round = Math.round;
var _Basics_sqrt = Math.sqrt;
var _Basics_log = Math.log;
var _Basics_isNaN = isNaN;


// BOOLEANS

function _Basics_not(bool) { return !bool; }
var _Basics_and = F2(function(a, b) { return a && b; });
var _Basics_or  = F2(function(a, b) { return a || b; });
var _Basics_xor = F2(function(a, b) { return a !== b; });



var _String_cons = F2(function(chr, str)
{
	return chr + str;
});

function _String_uncons(string)
{
	var word = string.charCodeAt(0);
	return !isNaN(word)
		? $elm$core$Maybe$Just(
			0xD800 <= word && word <= 0xDBFF
				? _Utils_Tuple2(_Utils_chr(string[0] + string[1]), string.slice(2))
				: _Utils_Tuple2(_Utils_chr(string[0]), string.slice(1))
		)
		: $elm$core$Maybe$Nothing;
}

var _String_append = F2(function(a, b)
{
	return a + b;
});

function _String_length(str)
{
	return str.length;
}

var _String_map = F2(function(func, string)
{
	var len = string.length;
	var array = new Array(len);
	var i = 0;
	while (i < len)
	{
		var word = string.charCodeAt(i);
		if (0xD800 <= word && word <= 0xDBFF)
		{
			array[i] = func(_Utils_chr(string[i] + string[i+1]));
			i += 2;
			continue;
		}
		array[i] = func(_Utils_chr(string[i]));
		i++;
	}
	return array.join('');
});

var _String_filter = F2(function(isGood, str)
{
	var arr = [];
	var len = str.length;
	var i = 0;
	while (i < len)
	{
		var char = str[i];
		var word = str.charCodeAt(i);
		i++;
		if (0xD800 <= word && word <= 0xDBFF)
		{
			char += str[i];
			i++;
		}

		if (isGood(_Utils_chr(char)))
		{
			arr.push(char);
		}
	}
	return arr.join('');
});

function _String_reverse(str)
{
	var len = str.length;
	var arr = new Array(len);
	var i = 0;
	while (i < len)
	{
		var word = str.charCodeAt(i);
		if (0xD800 <= word && word <= 0xDBFF)
		{
			arr[len - i] = str[i + 1];
			i++;
			arr[len - i] = str[i - 1];
			i++;
		}
		else
		{
			arr[len - i] = str[i];
			i++;
		}
	}
	return arr.join('');
}

var _String_foldl = F3(function(func, state, string)
{
	var len = string.length;
	var i = 0;
	while (i < len)
	{
		var char = string[i];
		var word = string.charCodeAt(i);
		i++;
		if (0xD800 <= word && word <= 0xDBFF)
		{
			char += string[i];
			i++;
		}
		state = A2(func, _Utils_chr(char), state);
	}
	return state;
});

var _String_foldr = F3(function(func, state, string)
{
	var i = string.length;
	while (i--)
	{
		var char = string[i];
		var word = string.charCodeAt(i);
		if (0xDC00 <= word && word <= 0xDFFF)
		{
			i--;
			char = string[i] + char;
		}
		state = A2(func, _Utils_chr(char), state);
	}
	return state;
});

var _String_split = F2(function(sep, str)
{
	return str.split(sep);
});

var _String_join = F2(function(sep, strs)
{
	return strs.join(sep);
});

var _String_slice = F3(function(start, end, str) {
	return str.slice(start, end);
});

function _String_trim(str)
{
	return str.trim();
}

function _String_trimLeft(str)
{
	return str.replace(/^\s+/, '');
}

function _String_trimRight(str)
{
	return str.replace(/\s+$/, '');
}

function _String_words(str)
{
	return _List_fromArray(str.trim().split(/\s+/g));
}

function _String_lines(str)
{
	return _List_fromArray(str.split(/\r\n|\r|\n/g));
}

function _String_toUpper(str)
{
	return str.toUpperCase();
}

function _String_toLower(str)
{
	return str.toLowerCase();
}

var _String_any = F2(function(isGood, string)
{
	var i = string.length;
	while (i--)
	{
		var char = string[i];
		var word = string.charCodeAt(i);
		if (0xDC00 <= word && word <= 0xDFFF)
		{
			i--;
			char = string[i] + char;
		}
		if (isGood(_Utils_chr(char)))
		{
			return true;
		}
	}
	return false;
});

var _String_all = F2(function(isGood, string)
{
	var i = string.length;
	while (i--)
	{
		var char = string[i];
		var word = string.charCodeAt(i);
		if (0xDC00 <= word && word <= 0xDFFF)
		{
			i--;
			char = string[i] + char;
		}
		if (!isGood(_Utils_chr(char)))
		{
			return false;
		}
	}
	return true;
});

var _String_contains = F2(function(sub, str)
{
	return str.indexOf(sub) > -1;
});

var _String_startsWith = F2(function(sub, str)
{
	return str.indexOf(sub) === 0;
});

var _String_endsWith = F2(function(sub, str)
{
	return str.length >= sub.length &&
		str.lastIndexOf(sub) === str.length - sub.length;
});

var _String_indexes = F2(function(sub, str)
{
	var subLen = sub.length;

	if (subLen < 1)
	{
		return _List_Nil;
	}

	var i = 0;
	var is = [];

	while ((i = str.indexOf(sub, i)) > -1)
	{
		is.push(i);
		i = i + subLen;
	}

	return _List_fromArray(is);
});


// TO STRING

function _String_fromNumber(number)
{
	return number + '';
}


// INT CONVERSIONS

function _String_toInt(str)
{
	var total = 0;
	var code0 = str.charCodeAt(0);
	var start = code0 == 0x2B /* + */ || code0 == 0x2D /* - */ ? 1 : 0;

	for (var i = start; i < str.length; ++i)
	{
		var code = str.charCodeAt(i);
		if (code < 0x30 || 0x39 < code)
		{
			return $elm$core$Maybe$Nothing;
		}
		total = 10 * total + code - 0x30;
	}

	return i == start
		? $elm$core$Maybe$Nothing
		: $elm$core$Maybe$Just(code0 == 0x2D ? -total : total);
}


// FLOAT CONVERSIONS

function _String_toFloat(s)
{
	// check if it is a hex, octal, or binary number
	if (s.length === 0 || /[\sxbo]/.test(s))
	{
		return $elm$core$Maybe$Nothing;
	}
	var n = +s;
	// faster isNaN check
	return n === n ? $elm$core$Maybe$Just(n) : $elm$core$Maybe$Nothing;
}

function _String_fromList(chars)
{
	return _List_toArray(chars).join('');
}




function _Char_toCode(char)
{
	var code = char.charCodeAt(0);
	if (0xD800 <= code && code <= 0xDBFF)
	{
		return (code - 0xD800) * 0x400 + char.charCodeAt(1) - 0xDC00 + 0x10000
	}
	return code;
}

function _Char_fromCode(code)
{
	return _Utils_chr(
		(code < 0 || 0x10FFFF < code)
			? '\uFFFD'
			:
		(code <= 0xFFFF)
			? String.fromCharCode(code)
			:
		(code -= 0x10000,
			String.fromCharCode(Math.floor(code / 0x400) + 0xD800, code % 0x400 + 0xDC00)
		)
	);
}

function _Char_toUpper(char)
{
	return _Utils_chr(char.toUpperCase());
}

function _Char_toLower(char)
{
	return _Utils_chr(char.toLowerCase());
}

function _Char_toLocaleUpper(char)
{
	return _Utils_chr(char.toLocaleUpperCase());
}

function _Char_toLocaleLower(char)
{
	return _Utils_chr(char.toLocaleLowerCase());
}



/**_UNUSED/
function _Json_errorToString(error)
{
	return $elm$json$Json$Decode$errorToString(error);
}
//*/


// CORE DECODERS

function _Json_succeed(msg)
{
	return {
		$: 0,
		a: msg
	};
}

function _Json_fail(msg)
{
	return {
		$: 1,
		a: msg
	};
}

function _Json_decodePrim(decoder)
{
	return { $: 2, b: decoder };
}

var _Json_decodeInt = _Json_decodePrim(function(value) {
	return (typeof value !== 'number')
		? _Json_expecting('an INT', value)
		:
	(-2147483647 < value && value < 2147483647 && (value | 0) === value)
		? $elm$core$Result$Ok(value)
		:
	(isFinite(value) && !(value % 1))
		? $elm$core$Result$Ok(value)
		: _Json_expecting('an INT', value);
});

var _Json_decodeBool = _Json_decodePrim(function(value) {
	return (typeof value === 'boolean')
		? $elm$core$Result$Ok(value)
		: _Json_expecting('a BOOL', value);
});

var _Json_decodeFloat = _Json_decodePrim(function(value) {
	return (typeof value === 'number')
		? $elm$core$Result$Ok(value)
		: _Json_expecting('a FLOAT', value);
});

var _Json_decodeValue = _Json_decodePrim(function(value) {
	return $elm$core$Result$Ok(_Json_wrap(value));
});

var _Json_decodeString = _Json_decodePrim(function(value) {
	return (typeof value === 'string')
		? $elm$core$Result$Ok(value)
		: (value instanceof String)
			? $elm$core$Result$Ok(value + '')
			: _Json_expecting('a STRING', value);
});

function _Json_decodeList(decoder) { return { $: 3, b: decoder }; }
function _Json_decodeArray(decoder) { return { $: 4, b: decoder }; }

function _Json_decodeNull(value) { return { $: 5, c: value }; }

var _Json_decodeField = F2(function(field, decoder)
{
	return {
		$: 6,
		d: field,
		b: decoder
	};
});

var _Json_decodeIndex = F2(function(index, decoder)
{
	return {
		$: 7,
		e: index,
		b: decoder
	};
});

function _Json_decodeKeyValuePairs(decoder)
{
	return {
		$: 8,
		b: decoder
	};
}

function _Json_mapMany(f, decoders)
{
	return {
		$: 9,
		f: f,
		g: decoders
	};
}

var _Json_andThen = F2(function(callback, decoder)
{
	return {
		$: 10,
		b: decoder,
		h: callback
	};
});

function _Json_oneOf(decoders)
{
	return {
		$: 11,
		g: decoders
	};
}


// DECODING OBJECTS

var _Json_map1 = F2(function(f, d1)
{
	return _Json_mapMany(f, [d1]);
});

var _Json_map2 = F3(function(f, d1, d2)
{
	return _Json_mapMany(f, [d1, d2]);
});

var _Json_map3 = F4(function(f, d1, d2, d3)
{
	return _Json_mapMany(f, [d1, d2, d3]);
});

var _Json_map4 = F5(function(f, d1, d2, d3, d4)
{
	return _Json_mapMany(f, [d1, d2, d3, d4]);
});

var _Json_map5 = F6(function(f, d1, d2, d3, d4, d5)
{
	return _Json_mapMany(f, [d1, d2, d3, d4, d5]);
});

var _Json_map6 = F7(function(f, d1, d2, d3, d4, d5, d6)
{
	return _Json_mapMany(f, [d1, d2, d3, d4, d5, d6]);
});

var _Json_map7 = F8(function(f, d1, d2, d3, d4, d5, d6, d7)
{
	return _Json_mapMany(f, [d1, d2, d3, d4, d5, d6, d7]);
});

var _Json_map8 = F9(function(f, d1, d2, d3, d4, d5, d6, d7, d8)
{
	return _Json_mapMany(f, [d1, d2, d3, d4, d5, d6, d7, d8]);
});


// DECODE

var _Json_runOnString = F2(function(decoder, string)
{
	try
	{
		var value = JSON.parse(string);
		return _Json_runHelp(decoder, value);
	}
	catch (e)
	{
		return $elm$core$Result$Err(A2($elm$json$Json$Decode$Failure, 'This is not valid JSON! ' + e.message, _Json_wrap(string)));
	}
});

var _Json_run = F2(function(decoder, value)
{
	return _Json_runHelp(decoder, _Json_unwrap(value));
});

function _Json_runHelp(decoder, value)
{
	switch (decoder.$)
	{
		case 2:
			return decoder.b(value);

		case 5:
			return (value === null)
				? $elm$core$Result$Ok(decoder.c)
				: _Json_expecting('null', value);

		case 3:
			if (!_Json_isArray(value))
			{
				return _Json_expecting('a LIST', value);
			}
			return _Json_runArrayDecoder(decoder.b, value, _List_fromArray);

		case 4:
			if (!_Json_isArray(value))
			{
				return _Json_expecting('an ARRAY', value);
			}
			return _Json_runArrayDecoder(decoder.b, value, _Json_toElmArray);

		case 6:
			var field = decoder.d;
			if (typeof value !== 'object' || value === null || !(field in value))
			{
				return _Json_expecting('an OBJECT with a field named `' + field + '`', value);
			}
			var result = _Json_runHelp(decoder.b, value[field]);
			return ($elm$core$Result$isOk(result)) ? result : $elm$core$Result$Err(A2($elm$json$Json$Decode$Field, field, result.a));

		case 7:
			var index = decoder.e;
			if (!_Json_isArray(value))
			{
				return _Json_expecting('an ARRAY', value);
			}
			if (index >= value.length)
			{
				return _Json_expecting('a LONGER array. Need index ' + index + ' but only see ' + value.length + ' entries', value);
			}
			var result = _Json_runHelp(decoder.b, value[index]);
			return ($elm$core$Result$isOk(result)) ? result : $elm$core$Result$Err(A2($elm$json$Json$Decode$Index, index, result.a));

		case 8:
			if (typeof value !== 'object' || value === null || _Json_isArray(value))
			{
				return _Json_expecting('an OBJECT', value);
			}

			var keyValuePairs = _List_Nil;
			// TODO test perf of Object.keys and switch when support is good enough
			for (var key in value)
			{
				if (value.hasOwnProperty(key))
				{
					var result = _Json_runHelp(decoder.b, value[key]);
					if (!$elm$core$Result$isOk(result))
					{
						return $elm$core$Result$Err(A2($elm$json$Json$Decode$Field, key, result.a));
					}
					keyValuePairs = _List_Cons(_Utils_Tuple2(key, result.a), keyValuePairs);
				}
			}
			return $elm$core$Result$Ok($elm$core$List$reverse(keyValuePairs));

		case 9:
			var answer = decoder.f;
			var decoders = decoder.g;
			for (var i = 0; i < decoders.length; i++)
			{
				var result = _Json_runHelp(decoders[i], value);
				if (!$elm$core$Result$isOk(result))
				{
					return result;
				}
				answer = answer(result.a);
			}
			return $elm$core$Result$Ok(answer);

		case 10:
			var result = _Json_runHelp(decoder.b, value);
			return (!$elm$core$Result$isOk(result))
				? result
				: _Json_runHelp(decoder.h(result.a), value);

		case 11:
			var errors = _List_Nil;
			for (var temp = decoder.g; temp.b; temp = temp.b) // WHILE_CONS
			{
				var result = _Json_runHelp(temp.a, value);
				if ($elm$core$Result$isOk(result))
				{
					return result;
				}
				errors = _List_Cons(result.a, errors);
			}
			return $elm$core$Result$Err($elm$json$Json$Decode$OneOf($elm$core$List$reverse(errors)));

		case 1:
			return $elm$core$Result$Err(A2($elm$json$Json$Decode$Failure, decoder.a, _Json_wrap(value)));

		case 0:
			return $elm$core$Result$Ok(decoder.a);
	}
}

function _Json_runArrayDecoder(decoder, value, toElmValue)
{
	var len = value.length;
	var array = new Array(len);
	for (var i = 0; i < len; i++)
	{
		var result = _Json_runHelp(decoder, value[i]);
		if (!$elm$core$Result$isOk(result))
		{
			return $elm$core$Result$Err(A2($elm$json$Json$Decode$Index, i, result.a));
		}
		array[i] = result.a;
	}
	return $elm$core$Result$Ok(toElmValue(array));
}

function _Json_isArray(value)
{
	return Array.isArray(value) || (typeof FileList !== 'undefined' && value instanceof FileList);
}

function _Json_toElmArray(array)
{
	return A2($elm$core$Array$initialize, array.length, function(i) { return array[i]; });
}

function _Json_expecting(type, value)
{
	return $elm$core$Result$Err(A2($elm$json$Json$Decode$Failure, 'Expecting ' + type, _Json_wrap(value)));
}


// EQUALITY

function _Json_equality(x, y)
{
	if (x === y)
	{
		return true;
	}

	if (x.$ !== y.$)
	{
		return false;
	}

	switch (x.$)
	{
		case 0:
		case 1:
			return x.a === y.a;

		case 2:
			return x.b === y.b;

		case 5:
			return x.c === y.c;

		case 3:
		case 4:
		case 8:
			return _Json_equality(x.b, y.b);

		case 6:
			return x.d === y.d && _Json_equality(x.b, y.b);

		case 7:
			return x.e === y.e && _Json_equality(x.b, y.b);

		case 9:
			return x.f === y.f && _Json_listEquality(x.g, y.g);

		case 10:
			return x.h === y.h && _Json_equality(x.b, y.b);

		case 11:
			return _Json_listEquality(x.g, y.g);
	}
}

function _Json_listEquality(aDecoders, bDecoders)
{
	var len = aDecoders.length;
	if (len !== bDecoders.length)
	{
		return false;
	}
	for (var i = 0; i < len; i++)
	{
		if (!_Json_equality(aDecoders[i], bDecoders[i]))
		{
			return false;
		}
	}
	return true;
}


// ENCODE

var _Json_encode = F2(function(indentLevel, value)
{
	return JSON.stringify(_Json_unwrap(value), null, indentLevel) + '';
});

function _Json_wrap_UNUSED(value) { return { $: 0, a: value }; }
function _Json_unwrap_UNUSED(value) { return value.a; }

function _Json_wrap(value) { return value; }
function _Json_unwrap(value) { return value; }

function _Json_emptyArray() { return []; }
function _Json_emptyObject() { return {}; }

var _Json_addField = F3(function(key, value, object)
{
	object[key] = _Json_unwrap(value);
	return object;
});

function _Json_addEntry(func)
{
	return F2(function(entry, array)
	{
		array.push(_Json_unwrap(func(entry)));
		return array;
	});
}

var _Json_encodeNull = _Json_wrap(null);



// TASKS

function _Scheduler_succeed(value)
{
	return {
		$: 0,
		a: value
	};
}

function _Scheduler_fail(error)
{
	return {
		$: 1,
		a: error
	};
}

function _Scheduler_binding(callback)
{
	return {
		$: 2,
		b: callback,
		c: null
	};
}

var _Scheduler_andThen = F2(function(callback, task)
{
	return {
		$: 3,
		b: callback,
		d: task
	};
});

var _Scheduler_onError = F2(function(callback, task)
{
	return {
		$: 4,
		b: callback,
		d: task
	};
});

function _Scheduler_receive(callback)
{
	return {
		$: 5,
		b: callback
	};
}


// PROCESSES

var _Scheduler_guid = 0;

function _Scheduler_rawSpawn(task)
{
	var proc = {
		$: 0,
		e: _Scheduler_guid++,
		f: task,
		g: null,
		h: []
	};

	_Scheduler_enqueue(proc);

	return proc;
}

function _Scheduler_spawn(task)
{
	return _Scheduler_binding(function(callback) {
		callback(_Scheduler_succeed(_Scheduler_rawSpawn(task)));
	});
}

function _Scheduler_rawSend(proc, msg)
{
	proc.h.push(msg);
	_Scheduler_enqueue(proc);
}

var _Scheduler_send = F2(function(proc, msg)
{
	return _Scheduler_binding(function(callback) {
		_Scheduler_rawSend(proc, msg);
		callback(_Scheduler_succeed(_Utils_Tuple0));
	});
});

function _Scheduler_kill(proc)
{
	return _Scheduler_binding(function(callback) {
		var task = proc.f;
		if (task.$ === 2 && task.c)
		{
			task.c();
		}

		proc.f = null;

		callback(_Scheduler_succeed(_Utils_Tuple0));
	});
}


/* STEP PROCESSES

type alias Process =
  { $ : tag
  , id : unique_id
  , root : Task
  , stack : null | { $: SUCCEED | FAIL, a: callback, b: stack }
  , mailbox : [msg]
  }

*/


var _Scheduler_working = false;
var _Scheduler_queue = [];


function _Scheduler_enqueue(proc)
{
	_Scheduler_queue.push(proc);
	if (_Scheduler_working)
	{
		return;
	}
	_Scheduler_working = true;
	while (proc = _Scheduler_queue.shift())
	{
		_Scheduler_step(proc);
	}
	_Scheduler_working = false;
}


function _Scheduler_step(proc)
{
	while (proc.f)
	{
		var rootTag = proc.f.$;
		if (rootTag === 0 || rootTag === 1)
		{
			while (proc.g && proc.g.$ !== rootTag)
			{
				proc.g = proc.g.i;
			}
			if (!proc.g)
			{
				return;
			}
			proc.f = proc.g.b(proc.f.a);
			proc.g = proc.g.i;
		}
		else if (rootTag === 2)
		{
			proc.f.c = proc.f.b(function(newRoot) {
				proc.f = newRoot;
				_Scheduler_enqueue(proc);
			});
			return;
		}
		else if (rootTag === 5)
		{
			if (proc.h.length === 0)
			{
				return;
			}
			proc.f = proc.f.b(proc.h.shift());
		}
		else // if (rootTag === 3 || rootTag === 4)
		{
			proc.g = {
				$: rootTag === 3 ? 0 : 1,
				b: proc.f.b,
				i: proc.g
			};
			proc.f = proc.f.d;
		}
	}
}



function _Process_sleep(time)
{
	return _Scheduler_binding(function(callback) {
		var id = setTimeout(function() {
			callback(_Scheduler_succeed(_Utils_Tuple0));
		}, time);

		return function() { clearTimeout(id); };
	});
}




// PROGRAMS


var _Platform_worker = F4(function(impl, flagDecoder, debugMetadata, args)
{
	return _Platform_initialize(
		flagDecoder,
		args,
		impl.cv,
		impl.c4,
		impl.c1,
		function() { return function() {} }
	);
});



// INITIALIZE A PROGRAM


function _Platform_initialize(flagDecoder, args, init, update, subscriptions, stepperBuilder)
{
	var result = A2(_Json_run, flagDecoder, _Json_wrap(args ? args['flags'] : undefined));
	$elm$core$Result$isOk(result) || _Debug_crash(2 /**_UNUSED/, _Json_errorToString(result.a) /**/);
	var managers = {};
	var initPair = init(result.a);
	var model = initPair.a;
	var stepper = stepperBuilder(sendToApp, model);
	var ports = _Platform_setupEffects(managers, sendToApp);

	function sendToApp(msg, viewMetadata)
	{
		var pair = A2(update, msg, model);
		stepper(model = pair.a, viewMetadata);
		_Platform_enqueueEffects(managers, pair.b, subscriptions(model));
	}

	_Platform_enqueueEffects(managers, initPair.b, subscriptions(model));

	return ports ? { ports: ports } : {};
}



// TRACK PRELOADS
//
// This is used by code in elm/browser and elm/http
// to register any HTTP requests that are triggered by init.
//


var _Platform_preload;


function _Platform_registerPreload(url)
{
	_Platform_preload.add(url);
}



// EFFECT MANAGERS


var _Platform_effectManagers = {};


function _Platform_setupEffects(managers, sendToApp)
{
	var ports;

	// setup all necessary effect managers
	for (var key in _Platform_effectManagers)
	{
		var manager = _Platform_effectManagers[key];

		if (manager.a)
		{
			ports = ports || {};
			ports[key] = manager.a(key, sendToApp);
		}

		managers[key] = _Platform_instantiateManager(manager, sendToApp);
	}

	return ports;
}


function _Platform_createManager(init, onEffects, onSelfMsg, cmdMap, subMap)
{
	return {
		b: init,
		c: onEffects,
		d: onSelfMsg,
		e: cmdMap,
		f: subMap
	};
}


function _Platform_instantiateManager(info, sendToApp)
{
	var router = {
		g: sendToApp,
		h: undefined
	};

	var onEffects = info.c;
	var onSelfMsg = info.d;
	var cmdMap = info.e;
	var subMap = info.f;

	function loop(state)
	{
		return A2(_Scheduler_andThen, loop, _Scheduler_receive(function(msg)
		{
			var value = msg.a;

			if (msg.$ === 0)
			{
				return A3(onSelfMsg, router, value, state);
			}

			return cmdMap && subMap
				? A4(onEffects, router, value.i, value.j, state)
				: A3(onEffects, router, cmdMap ? value.i : value.j, state);
		}));
	}

	return router.h = _Scheduler_rawSpawn(A2(_Scheduler_andThen, loop, info.b));
}



// ROUTING


var _Platform_sendToApp = F2(function(router, msg)
{
	return _Scheduler_binding(function(callback)
	{
		router.g(msg);
		callback(_Scheduler_succeed(_Utils_Tuple0));
	});
});


var _Platform_sendToSelf = F2(function(router, msg)
{
	return A2(_Scheduler_send, router.h, {
		$: 0,
		a: msg
	});
});



// BAGS


function _Platform_leaf(home)
{
	return function(value)
	{
		return {
			$: 1,
			k: home,
			l: value
		};
	};
}


function _Platform_batch(list)
{
	return {
		$: 2,
		m: list
	};
}


var _Platform_map = F2(function(tagger, bag)
{
	return {
		$: 3,
		n: tagger,
		o: bag
	}
});



// PIPE BAGS INTO EFFECT MANAGERS
//
// Effects must be queued!
//
// Say your init contains a synchronous command, like Time.now or Time.here
//
//   - This will produce a batch of effects (FX_1)
//   - The synchronous task triggers the subsequent `update` call
//   - This will produce a batch of effects (FX_2)
//
// If we just start dispatching FX_2, subscriptions from FX_2 can be processed
// before subscriptions from FX_1. No good! Earlier versions of this code had
// this problem, leading to these reports:
//
//   https://github.com/elm/core/issues/980
//   https://github.com/elm/core/pull/981
//   https://github.com/elm/compiler/issues/1776
//
// The queue is necessary to avoid ordering issues for synchronous commands.


// Why use true/false here? Why not just check the length of the queue?
// The goal is to detect "are we currently dispatching effects?" If we
// are, we need to bail and let the ongoing while loop handle things.
//
// Now say the queue has 1 element. When we dequeue the final element,
// the queue will be empty, but we are still actively dispatching effects.
// So you could get queue jumping in a really tricky category of cases.
//
var _Platform_effectsQueue = [];
var _Platform_effectsActive = false;


function _Platform_enqueueEffects(managers, cmdBag, subBag)
{
	_Platform_effectsQueue.push({ p: managers, q: cmdBag, r: subBag });

	if (_Platform_effectsActive) return;

	_Platform_effectsActive = true;
	for (var fx; fx = _Platform_effectsQueue.shift(); )
	{
		_Platform_dispatchEffects(fx.p, fx.q, fx.r);
	}
	_Platform_effectsActive = false;
}


function _Platform_dispatchEffects(managers, cmdBag, subBag)
{
	var effectsDict = {};
	_Platform_gatherEffects(true, cmdBag, effectsDict, null);
	_Platform_gatherEffects(false, subBag, effectsDict, null);

	for (var home in managers)
	{
		_Scheduler_rawSend(managers[home], {
			$: 'fx',
			a: effectsDict[home] || { i: _List_Nil, j: _List_Nil }
		});
	}
}


function _Platform_gatherEffects(isCmd, bag, effectsDict, taggers)
{
	switch (bag.$)
	{
		case 1:
			var home = bag.k;
			var effect = _Platform_toEffect(isCmd, home, taggers, bag.l);
			effectsDict[home] = _Platform_insert(isCmd, effect, effectsDict[home]);
			return;

		case 2:
			for (var list = bag.m; list.b; list = list.b) // WHILE_CONS
			{
				_Platform_gatherEffects(isCmd, list.a, effectsDict, taggers);
			}
			return;

		case 3:
			_Platform_gatherEffects(isCmd, bag.o, effectsDict, {
				s: bag.n,
				t: taggers
			});
			return;
	}
}


function _Platform_toEffect(isCmd, home, taggers, value)
{
	function applyTaggers(x)
	{
		for (var temp = taggers; temp; temp = temp.t)
		{
			x = temp.s(x);
		}
		return x;
	}

	var map = isCmd
		? _Platform_effectManagers[home].e
		: _Platform_effectManagers[home].f;

	return A2(map, applyTaggers, value)
}


function _Platform_insert(isCmd, newEffect, effects)
{
	effects = effects || { i: _List_Nil, j: _List_Nil };

	isCmd
		? (effects.i = _List_Cons(newEffect, effects.i))
		: (effects.j = _List_Cons(newEffect, effects.j));

	return effects;
}



// PORTS


function _Platform_checkPortName(name)
{
	if (_Platform_effectManagers[name])
	{
		_Debug_crash(3, name)
	}
}



// OUTGOING PORTS


function _Platform_outgoingPort(name, converter)
{
	_Platform_checkPortName(name);
	_Platform_effectManagers[name] = {
		e: _Platform_outgoingPortMap,
		u: converter,
		a: _Platform_setupOutgoingPort
	};
	return _Platform_leaf(name);
}


var _Platform_outgoingPortMap = F2(function(tagger, value) { return value; });


function _Platform_setupOutgoingPort(name)
{
	var subs = [];
	var converter = _Platform_effectManagers[name].u;

	// CREATE MANAGER

	var init = _Process_sleep(0);

	_Platform_effectManagers[name].b = init;
	_Platform_effectManagers[name].c = F3(function(router, cmdList, state)
	{
		for ( ; cmdList.b; cmdList = cmdList.b) // WHILE_CONS
		{
			// grab a separate reference to subs in case unsubscribe is called
			var currentSubs = subs;
			var value = _Json_unwrap(converter(cmdList.a));
			for (var i = 0; i < currentSubs.length; i++)
			{
				currentSubs[i](value);
			}
		}
		return init;
	});

	// PUBLIC API

	function subscribe(callback)
	{
		subs.push(callback);
	}

	function unsubscribe(callback)
	{
		// copy subs into a new array in case unsubscribe is called within a
		// subscribed callback
		subs = subs.slice();
		var index = subs.indexOf(callback);
		if (index >= 0)
		{
			subs.splice(index, 1);
		}
	}

	return {
		subscribe: subscribe,
		unsubscribe: unsubscribe
	};
}



// INCOMING PORTS


function _Platform_incomingPort(name, converter)
{
	_Platform_checkPortName(name);
	_Platform_effectManagers[name] = {
		f: _Platform_incomingPortMap,
		u: converter,
		a: _Platform_setupIncomingPort
	};
	return _Platform_leaf(name);
}


var _Platform_incomingPortMap = F2(function(tagger, finalTagger)
{
	return function(value)
	{
		return tagger(finalTagger(value));
	};
});


function _Platform_setupIncomingPort(name, sendToApp)
{
	var subs = _List_Nil;
	var converter = _Platform_effectManagers[name].u;

	// CREATE MANAGER

	var init = _Scheduler_succeed(null);

	_Platform_effectManagers[name].b = init;
	_Platform_effectManagers[name].c = F3(function(router, subList, state)
	{
		subs = subList;
		return init;
	});

	// PUBLIC API

	function send(incomingValue)
	{
		var result = A2(_Json_run, converter, _Json_wrap(incomingValue));

		$elm$core$Result$isOk(result) || _Debug_crash(4, name, result.a);

		var value = result.a;
		for (var temp = subs; temp.b; temp = temp.b) // WHILE_CONS
		{
			sendToApp(temp.a(value));
		}
	}

	return { send: send };
}



// EXPORT ELM MODULES
//
// Have DEBUG and PROD versions so that we can (1) give nicer errors in
// debug mode and (2) not pay for the bits needed for that in prod mode.
//


function _Platform_export(exports)
{
	scope['Elm']
		? _Platform_mergeExportsProd(scope['Elm'], exports)
		: scope['Elm'] = exports;
}


function _Platform_mergeExportsProd(obj, exports)
{
	for (var name in exports)
	{
		(name in obj)
			? (name == 'init')
				? _Debug_crash(6)
				: _Platform_mergeExportsProd(obj[name], exports[name])
			: (obj[name] = exports[name]);
	}
}


function _Platform_export_UNUSED(exports)
{
	scope['Elm']
		? _Platform_mergeExportsDebug('Elm', scope['Elm'], exports)
		: scope['Elm'] = exports;
}


function _Platform_mergeExportsDebug(moduleName, obj, exports)
{
	for (var name in exports)
	{
		(name in obj)
			? (name == 'init')
				? _Debug_crash(6, moduleName)
				: _Platform_mergeExportsDebug(moduleName + '.' + name, obj[name], exports[name])
			: (obj[name] = exports[name]);
	}
}




// HELPERS


var _VirtualDom_divertHrefToApp;

var _VirtualDom_doc = typeof document !== 'undefined' ? document : {};


function _VirtualDom_appendChild(parent, child)
{
	parent.appendChild(child);
}

var _VirtualDom_init = F4(function(virtualNode, flagDecoder, debugMetadata, args)
{
	// NOTE: this function needs _Platform_export available to work

	/**/
	var node = args['node'];
	//*/
	/**_UNUSED/
	var node = args && args['node'] ? args['node'] : _Debug_crash(0);
	//*/

	node.parentNode.replaceChild(
		_VirtualDom_render(virtualNode, function() {}),
		node
	);

	return {};
});



// TEXT


function _VirtualDom_text(string)
{
	return {
		$: 0,
		a: string
	};
}



// NODE


var _VirtualDom_nodeNS = F2(function(namespace, tag)
{
	return F2(function(factList, kidList)
	{
		for (var kids = [], descendantsCount = 0; kidList.b; kidList = kidList.b) // WHILE_CONS
		{
			var kid = kidList.a;
			descendantsCount += (kid.b || 0);
			kids.push(kid);
		}
		descendantsCount += kids.length;

		return {
			$: 1,
			c: tag,
			d: _VirtualDom_organizeFacts(factList),
			e: kids,
			f: namespace,
			b: descendantsCount
		};
	});
});


var _VirtualDom_node = _VirtualDom_nodeNS(undefined);



// KEYED NODE


var _VirtualDom_keyedNodeNS = F2(function(namespace, tag)
{
	return F2(function(factList, kidList)
	{
		for (var kids = [], descendantsCount = 0; kidList.b; kidList = kidList.b) // WHILE_CONS
		{
			var kid = kidList.a;
			descendantsCount += (kid.b.b || 0);
			kids.push(kid);
		}
		descendantsCount += kids.length;

		return {
			$: 2,
			c: tag,
			d: _VirtualDom_organizeFacts(factList),
			e: kids,
			f: namespace,
			b: descendantsCount
		};
	});
});


var _VirtualDom_keyedNode = _VirtualDom_keyedNodeNS(undefined);



// CUSTOM


function _VirtualDom_custom(factList, model, render, diff)
{
	return {
		$: 3,
		d: _VirtualDom_organizeFacts(factList),
		g: model,
		h: render,
		i: diff
	};
}



// MAP


var _VirtualDom_map = F2(function(tagger, node)
{
	return {
		$: 4,
		j: tagger,
		k: node,
		b: 1 + (node.b || 0)
	};
});



// LAZY


function _VirtualDom_thunk(refs, thunk)
{
	return {
		$: 5,
		l: refs,
		m: thunk,
		k: undefined
	};
}

var _VirtualDom_lazy = F2(function(func, a)
{
	return _VirtualDom_thunk([func, a], function() {
		return func(a);
	});
});

var _VirtualDom_lazy2 = F3(function(func, a, b)
{
	return _VirtualDom_thunk([func, a, b], function() {
		return A2(func, a, b);
	});
});

var _VirtualDom_lazy3 = F4(function(func, a, b, c)
{
	return _VirtualDom_thunk([func, a, b, c], function() {
		return A3(func, a, b, c);
	});
});

var _VirtualDom_lazy4 = F5(function(func, a, b, c, d)
{
	return _VirtualDom_thunk([func, a, b, c, d], function() {
		return A4(func, a, b, c, d);
	});
});

var _VirtualDom_lazy5 = F6(function(func, a, b, c, d, e)
{
	return _VirtualDom_thunk([func, a, b, c, d, e], function() {
		return A5(func, a, b, c, d, e);
	});
});

var _VirtualDom_lazy6 = F7(function(func, a, b, c, d, e, f)
{
	return _VirtualDom_thunk([func, a, b, c, d, e, f], function() {
		return A6(func, a, b, c, d, e, f);
	});
});

var _VirtualDom_lazy7 = F8(function(func, a, b, c, d, e, f, g)
{
	return _VirtualDom_thunk([func, a, b, c, d, e, f, g], function() {
		return A7(func, a, b, c, d, e, f, g);
	});
});

var _VirtualDom_lazy8 = F9(function(func, a, b, c, d, e, f, g, h)
{
	return _VirtualDom_thunk([func, a, b, c, d, e, f, g, h], function() {
		return A8(func, a, b, c, d, e, f, g, h);
	});
});



// FACTS


var _VirtualDom_on = F2(function(key, handler)
{
	return {
		$: 'a0',
		n: key,
		o: handler
	};
});
var _VirtualDom_style = F2(function(key, value)
{
	return {
		$: 'a1',
		n: key,
		o: value
	};
});
var _VirtualDom_property = F2(function(key, value)
{
	return {
		$: 'a2',
		n: key,
		o: value
	};
});
var _VirtualDom_attribute = F2(function(key, value)
{
	return {
		$: 'a3',
		n: key,
		o: value
	};
});
var _VirtualDom_attributeNS = F3(function(namespace, key, value)
{
	return {
		$: 'a4',
		n: key,
		o: { f: namespace, o: value }
	};
});



// XSS ATTACK VECTOR CHECKS
//
// For some reason, tabs can appear in href protocols and it still works.
// So '\tjava\tSCRIPT:alert("!!!")' and 'javascript:alert("!!!")' are the same
// in practice. That is why _VirtualDom_RE_js and _VirtualDom_RE_js_html look
// so freaky.
//
// Pulling the regular expressions out to the top level gives a slight speed
// boost in small benchmarks (4-10%) but hoisting values to reduce allocation
// can be unpredictable in large programs where JIT may have a harder time with
// functions are not fully self-contained. The benefit is more that the js and
// js_html ones are so weird that I prefer to see them near each other.


var _VirtualDom_RE_script = /^script$/i;
var _VirtualDom_RE_on_formAction = /^(on|formAction$)/i;
var _VirtualDom_RE_js = /^\s*j\s*a\s*v\s*a\s*s\s*c\s*r\s*i\s*p\s*t\s*:/i;
var _VirtualDom_RE_js_html = /^\s*(j\s*a\s*v\s*a\s*s\s*c\s*r\s*i\s*p\s*t\s*:|d\s*a\s*t\s*a\s*:\s*t\s*e\s*x\s*t\s*\/\s*h\s*t\s*m\s*l\s*(,|;))/i;


function _VirtualDom_noScript(tag)
{
	return _VirtualDom_RE_script.test(tag) ? 'p' : tag;
}

function _VirtualDom_noOnOrFormAction(key)
{
	return _VirtualDom_RE_on_formAction.test(key) ? 'data-' + key : key;
}

function _VirtualDom_noInnerHtmlOrFormAction(key)
{
	return key == 'innerHTML' || key == 'formAction' ? 'data-' + key : key;
}

function _VirtualDom_noJavaScriptUri(value)
{
	return _VirtualDom_RE_js.test(value)
		? /**/''//*//**_UNUSED/'javascript:alert("This is an XSS vector. Please use ports or web components instead.")'//*/
		: value;
}

function _VirtualDom_noJavaScriptOrHtmlUri(value)
{
	return _VirtualDom_RE_js_html.test(value)
		? /**/''//*//**_UNUSED/'javascript:alert("This is an XSS vector. Please use ports or web components instead.")'//*/
		: value;
}

function _VirtualDom_noJavaScriptOrHtmlJson(value)
{
	return (typeof _Json_unwrap(value) === 'string' && _VirtualDom_RE_js_html.test(_Json_unwrap(value)))
		? _Json_wrap(
			/**/''//*//**_UNUSED/'javascript:alert("This is an XSS vector. Please use ports or web components instead.")'//*/
		) : value;
}



// MAP FACTS


var _VirtualDom_mapAttribute = F2(function(func, attr)
{
	return (attr.$ === 'a0')
		? A2(_VirtualDom_on, attr.n, _VirtualDom_mapHandler(func, attr.o))
		: attr;
});

function _VirtualDom_mapHandler(func, handler)
{
	var tag = $elm$virtual_dom$VirtualDom$toHandlerInt(handler);

	// 0 = Normal
	// 1 = MayStopPropagation
	// 2 = MayPreventDefault
	// 3 = Custom

	return {
		$: handler.$,
		a:
			!tag
				? A2($elm$json$Json$Decode$map, func, handler.a)
				:
			A3($elm$json$Json$Decode$map2,
				tag < 3
					? _VirtualDom_mapEventTuple
					: _VirtualDom_mapEventRecord,
				$elm$json$Json$Decode$succeed(func),
				handler.a
			)
	};
}

var _VirtualDom_mapEventTuple = F2(function(func, tuple)
{
	return _Utils_Tuple2(func(tuple.a), tuple.b);
});

var _VirtualDom_mapEventRecord = F2(function(func, record)
{
	return {
		ax: func(record.ax),
		aT: record.aT,
		aO: record.aO
	}
});



// ORGANIZE FACTS


function _VirtualDom_organizeFacts(factList)
{
	for (var facts = {}; factList.b; factList = factList.b) // WHILE_CONS
	{
		var entry = factList.a;

		var tag = entry.$;
		var key = entry.n;
		var value = entry.o;

		if (tag === 'a2')
		{
			(key === 'className')
				? _VirtualDom_addClass(facts, key, _Json_unwrap(value))
				: facts[key] = _Json_unwrap(value);

			continue;
		}

		var subFacts = facts[tag] || (facts[tag] = {});
		(tag === 'a3' && key === 'class')
			? _VirtualDom_addClass(subFacts, key, value)
			: subFacts[key] = value;
	}

	return facts;
}

function _VirtualDom_addClass(object, key, newClass)
{
	var classes = object[key];
	object[key] = classes ? classes + ' ' + newClass : newClass;
}



// RENDER


function _VirtualDom_render(vNode, eventNode)
{
	var tag = vNode.$;

	if (tag === 5)
	{
		return _VirtualDom_render(vNode.k || (vNode.k = vNode.m()), eventNode);
	}

	if (tag === 0)
	{
		return _VirtualDom_doc.createTextNode(vNode.a);
	}

	if (tag === 4)
	{
		var subNode = vNode.k;
		var tagger = vNode.j;

		while (subNode.$ === 4)
		{
			typeof tagger !== 'object'
				? tagger = [tagger, subNode.j]
				: tagger.push(subNode.j);

			subNode = subNode.k;
		}

		var subEventRoot = { j: tagger, p: eventNode };
		var domNode = _VirtualDom_render(subNode, subEventRoot);
		domNode.elm_event_node_ref = subEventRoot;
		return domNode;
	}

	if (tag === 3)
	{
		var domNode = vNode.h(vNode.g);
		_VirtualDom_applyFacts(domNode, eventNode, vNode.d);
		return domNode;
	}

	// at this point `tag` must be 1 or 2

	var domNode = vNode.f
		? _VirtualDom_doc.createElementNS(vNode.f, vNode.c)
		: _VirtualDom_doc.createElement(vNode.c);

	if (_VirtualDom_divertHrefToApp && vNode.c == 'a')
	{
		domNode.addEventListener('click', _VirtualDom_divertHrefToApp(domNode));
	}

	_VirtualDom_applyFacts(domNode, eventNode, vNode.d);

	for (var kids = vNode.e, i = 0; i < kids.length; i++)
	{
		_VirtualDom_appendChild(domNode, _VirtualDom_render(tag === 1 ? kids[i] : kids[i].b, eventNode));
	}

	return domNode;
}



// APPLY FACTS


function _VirtualDom_applyFacts(domNode, eventNode, facts)
{
	for (var key in facts)
	{
		var value = facts[key];

		key === 'a1'
			? _VirtualDom_applyStyles(domNode, value)
			:
		key === 'a0'
			? _VirtualDom_applyEvents(domNode, eventNode, value)
			:
		key === 'a3'
			? _VirtualDom_applyAttrs(domNode, value)
			:
		key === 'a4'
			? _VirtualDom_applyAttrsNS(domNode, value)
			:
		((key !== 'value' && key !== 'checked') || domNode[key] !== value) && (domNode[key] = value);
	}
}



// APPLY STYLES


function _VirtualDom_applyStyles(domNode, styles)
{
	var domNodeStyle = domNode.style;

	for (var key in styles)
	{
		domNodeStyle[key] = styles[key];
	}
}



// APPLY ATTRS


function _VirtualDom_applyAttrs(domNode, attrs)
{
	for (var key in attrs)
	{
		var value = attrs[key];
		typeof value !== 'undefined'
			? domNode.setAttribute(key, value)
			: domNode.removeAttribute(key);
	}
}



// APPLY NAMESPACED ATTRS


function _VirtualDom_applyAttrsNS(domNode, nsAttrs)
{
	for (var key in nsAttrs)
	{
		var pair = nsAttrs[key];
		var namespace = pair.f;
		var value = pair.o;

		typeof value !== 'undefined'
			? domNode.setAttributeNS(namespace, key, value)
			: domNode.removeAttributeNS(namespace, key);
	}
}



// APPLY EVENTS


function _VirtualDom_applyEvents(domNode, eventNode, events)
{
	var allCallbacks = domNode.elmFs || (domNode.elmFs = {});

	for (var key in events)
	{
		var newHandler = events[key];
		var oldCallback = allCallbacks[key];

		if (!newHandler)
		{
			domNode.removeEventListener(key, oldCallback);
			allCallbacks[key] = undefined;
			continue;
		}

		if (oldCallback)
		{
			var oldHandler = oldCallback.q;
			if (oldHandler.$ === newHandler.$)
			{
				oldCallback.q = newHandler;
				continue;
			}
			domNode.removeEventListener(key, oldCallback);
		}

		oldCallback = _VirtualDom_makeCallback(eventNode, newHandler);
		domNode.addEventListener(key, oldCallback,
			_VirtualDom_passiveSupported
			&& { passive: $elm$virtual_dom$VirtualDom$toHandlerInt(newHandler) < 2 }
		);
		allCallbacks[key] = oldCallback;
	}
}



// PASSIVE EVENTS


var _VirtualDom_passiveSupported;

try
{
	window.addEventListener('t', null, Object.defineProperty({}, 'passive', {
		get: function() { _VirtualDom_passiveSupported = true; }
	}));
}
catch(e) {}



// EVENT HANDLERS


function _VirtualDom_makeCallback(eventNode, initialHandler)
{
	function callback(event)
	{
		var handler = callback.q;
		var result = _Json_runHelp(handler.a, event);

		if (!$elm$core$Result$isOk(result))
		{
			return;
		}

		var tag = $elm$virtual_dom$VirtualDom$toHandlerInt(handler);

		// 0 = Normal
		// 1 = MayStopPropagation
		// 2 = MayPreventDefault
		// 3 = Custom

		var value = result.a;
		var message = !tag ? value : tag < 3 ? value.a : value.ax;
		var stopPropagation = tag == 1 ? value.b : tag == 3 && value.aT;
		var currentEventNode = (
			stopPropagation && event.stopPropagation(),
			(tag == 2 ? value.b : tag == 3 && value.aO) && event.preventDefault(),
			eventNode
		);
		var tagger;
		var i;
		while (tagger = currentEventNode.j)
		{
			if (typeof tagger == 'function')
			{
				message = tagger(message);
			}
			else
			{
				for (var i = tagger.length; i--; )
				{
					message = tagger[i](message);
				}
			}
			currentEventNode = currentEventNode.p;
		}
		currentEventNode(message, stopPropagation); // stopPropagation implies isSync
	}

	callback.q = initialHandler;

	return callback;
}

function _VirtualDom_equalEvents(x, y)
{
	return x.$ == y.$ && _Json_equality(x.a, y.a);
}



// DIFF


// TODO: Should we do patches like in iOS?
//
// type Patch
//   = At Int Patch
//   | Batch (List Patch)
//   | Change ...
//
// How could it not be better?
//
function _VirtualDom_diff(x, y)
{
	var patches = [];
	_VirtualDom_diffHelp(x, y, patches, 0);
	return patches;
}


function _VirtualDom_pushPatch(patches, type, index, data)
{
	var patch = {
		$: type,
		r: index,
		s: data,
		t: undefined,
		u: undefined
	};
	patches.push(patch);
	return patch;
}


function _VirtualDom_diffHelp(x, y, patches, index)
{
	if (x === y)
	{
		return;
	}

	var xType = x.$;
	var yType = y.$;

	// Bail if you run into different types of nodes. Implies that the
	// structure has changed significantly and it's not worth a diff.
	if (xType !== yType)
	{
		if (xType === 1 && yType === 2)
		{
			y = _VirtualDom_dekey(y);
			yType = 1;
		}
		else
		{
			_VirtualDom_pushPatch(patches, 0, index, y);
			return;
		}
	}

	// Now we know that both nodes are the same $.
	switch (yType)
	{
		case 5:
			var xRefs = x.l;
			var yRefs = y.l;
			var i = xRefs.length;
			var same = i === yRefs.length;
			while (same && i--)
			{
				same = xRefs[i] === yRefs[i];
			}
			if (same)
			{
				y.k = x.k;
				return;
			}
			y.k = y.m();
			var subPatches = [];
			_VirtualDom_diffHelp(x.k, y.k, subPatches, 0);
			subPatches.length > 0 && _VirtualDom_pushPatch(patches, 1, index, subPatches);
			return;

		case 4:
			// gather nested taggers
			var xTaggers = x.j;
			var yTaggers = y.j;
			var nesting = false;

			var xSubNode = x.k;
			while (xSubNode.$ === 4)
			{
				nesting = true;

				typeof xTaggers !== 'object'
					? xTaggers = [xTaggers, xSubNode.j]
					: xTaggers.push(xSubNode.j);

				xSubNode = xSubNode.k;
			}

			var ySubNode = y.k;
			while (ySubNode.$ === 4)
			{
				nesting = true;

				typeof yTaggers !== 'object'
					? yTaggers = [yTaggers, ySubNode.j]
					: yTaggers.push(ySubNode.j);

				ySubNode = ySubNode.k;
			}

			// Just bail if different numbers of taggers. This implies the
			// structure of the virtual DOM has changed.
			if (nesting && xTaggers.length !== yTaggers.length)
			{
				_VirtualDom_pushPatch(patches, 0, index, y);
				return;
			}

			// check if taggers are "the same"
			if (nesting ? !_VirtualDom_pairwiseRefEqual(xTaggers, yTaggers) : xTaggers !== yTaggers)
			{
				_VirtualDom_pushPatch(patches, 2, index, yTaggers);
			}

			// diff everything below the taggers
			_VirtualDom_diffHelp(xSubNode, ySubNode, patches, index + 1);
			return;

		case 0:
			if (x.a !== y.a)
			{
				_VirtualDom_pushPatch(patches, 3, index, y.a);
			}
			return;

		case 1:
			_VirtualDom_diffNodes(x, y, patches, index, _VirtualDom_diffKids);
			return;

		case 2:
			_VirtualDom_diffNodes(x, y, patches, index, _VirtualDom_diffKeyedKids);
			return;

		case 3:
			if (x.h !== y.h)
			{
				_VirtualDom_pushPatch(patches, 0, index, y);
				return;
			}

			var factsDiff = _VirtualDom_diffFacts(x.d, y.d);
			factsDiff && _VirtualDom_pushPatch(patches, 4, index, factsDiff);

			var patch = y.i(x.g, y.g);
			patch && _VirtualDom_pushPatch(patches, 5, index, patch);

			return;
	}
}

// assumes the incoming arrays are the same length
function _VirtualDom_pairwiseRefEqual(as, bs)
{
	for (var i = 0; i < as.length; i++)
	{
		if (as[i] !== bs[i])
		{
			return false;
		}
	}

	return true;
}

function _VirtualDom_diffNodes(x, y, patches, index, diffKids)
{
	// Bail if obvious indicators have changed. Implies more serious
	// structural changes such that it's not worth it to diff.
	if (x.c !== y.c || x.f !== y.f)
	{
		_VirtualDom_pushPatch(patches, 0, index, y);
		return;
	}

	var factsDiff = _VirtualDom_diffFacts(x.d, y.d);
	factsDiff && _VirtualDom_pushPatch(patches, 4, index, factsDiff);

	diffKids(x, y, patches, index);
}



// DIFF FACTS


// TODO Instead of creating a new diff object, it's possible to just test if
// there *is* a diff. During the actual patch, do the diff again and make the
// modifications directly. This way, there's no new allocations. Worth it?
function _VirtualDom_diffFacts(x, y, category)
{
	var diff;

	// look for changes and removals
	for (var xKey in x)
	{
		if (xKey === 'a1' || xKey === 'a0' || xKey === 'a3' || xKey === 'a4')
		{
			var subDiff = _VirtualDom_diffFacts(x[xKey], y[xKey] || {}, xKey);
			if (subDiff)
			{
				diff = diff || {};
				diff[xKey] = subDiff;
			}
			continue;
		}

		// remove if not in the new facts
		if (!(xKey in y))
		{
			diff = diff || {};
			diff[xKey] =
				!category
					? (typeof x[xKey] === 'string' ? '' : null)
					:
				(category === 'a1')
					? ''
					:
				(category === 'a0' || category === 'a3')
					? undefined
					:
				{ f: x[xKey].f, o: undefined };

			continue;
		}

		var xValue = x[xKey];
		var yValue = y[xKey];

		// reference equal, so don't worry about it
		if (xValue === yValue && xKey !== 'value' && xKey !== 'checked'
			|| category === 'a0' && _VirtualDom_equalEvents(xValue, yValue))
		{
			continue;
		}

		diff = diff || {};
		diff[xKey] = yValue;
	}

	// add new stuff
	for (var yKey in y)
	{
		if (!(yKey in x))
		{
			diff = diff || {};
			diff[yKey] = y[yKey];
		}
	}

	return diff;
}



// DIFF KIDS


function _VirtualDom_diffKids(xParent, yParent, patches, index)
{
	var xKids = xParent.e;
	var yKids = yParent.e;

	var xLen = xKids.length;
	var yLen = yKids.length;

	// FIGURE OUT IF THERE ARE INSERTS OR REMOVALS

	if (xLen > yLen)
	{
		_VirtualDom_pushPatch(patches, 6, index, {
			v: yLen,
			i: xLen - yLen
		});
	}
	else if (xLen < yLen)
	{
		_VirtualDom_pushPatch(patches, 7, index, {
			v: xLen,
			e: yKids
		});
	}

	// PAIRWISE DIFF EVERYTHING ELSE

	for (var minLen = xLen < yLen ? xLen : yLen, i = 0; i < minLen; i++)
	{
		var xKid = xKids[i];
		_VirtualDom_diffHelp(xKid, yKids[i], patches, ++index);
		index += xKid.b || 0;
	}
}



// KEYED DIFF


function _VirtualDom_diffKeyedKids(xParent, yParent, patches, rootIndex)
{
	var localPatches = [];

	var changes = {}; // Dict String Entry
	var inserts = []; // Array { index : Int, entry : Entry }
	// type Entry = { tag : String, vnode : VNode, index : Int, data : _ }

	var xKids = xParent.e;
	var yKids = yParent.e;
	var xLen = xKids.length;
	var yLen = yKids.length;
	var xIndex = 0;
	var yIndex = 0;

	var index = rootIndex;

	while (xIndex < xLen && yIndex < yLen)
	{
		var x = xKids[xIndex];
		var y = yKids[yIndex];

		var xKey = x.a;
		var yKey = y.a;
		var xNode = x.b;
		var yNode = y.b;

		var newMatch = undefined;
		var oldMatch = undefined;

		// check if keys match

		if (xKey === yKey)
		{
			index++;
			_VirtualDom_diffHelp(xNode, yNode, localPatches, index);
			index += xNode.b || 0;

			xIndex++;
			yIndex++;
			continue;
		}

		// look ahead 1 to detect insertions and removals.

		var xNext = xKids[xIndex + 1];
		var yNext = yKids[yIndex + 1];

		if (xNext)
		{
			var xNextKey = xNext.a;
			var xNextNode = xNext.b;
			oldMatch = yKey === xNextKey;
		}

		if (yNext)
		{
			var yNextKey = yNext.a;
			var yNextNode = yNext.b;
			newMatch = xKey === yNextKey;
		}


		// swap x and y
		if (newMatch && oldMatch)
		{
			index++;
			_VirtualDom_diffHelp(xNode, yNextNode, localPatches, index);
			_VirtualDom_insertNode(changes, localPatches, xKey, yNode, yIndex, inserts);
			index += xNode.b || 0;

			index++;
			_VirtualDom_removeNode(changes, localPatches, xKey, xNextNode, index);
			index += xNextNode.b || 0;

			xIndex += 2;
			yIndex += 2;
			continue;
		}

		// insert y
		if (newMatch)
		{
			index++;
			_VirtualDom_insertNode(changes, localPatches, yKey, yNode, yIndex, inserts);
			_VirtualDom_diffHelp(xNode, yNextNode, localPatches, index);
			index += xNode.b || 0;

			xIndex += 1;
			yIndex += 2;
			continue;
		}

		// remove x
		if (oldMatch)
		{
			index++;
			_VirtualDom_removeNode(changes, localPatches, xKey, xNode, index);
			index += xNode.b || 0;

			index++;
			_VirtualDom_diffHelp(xNextNode, yNode, localPatches, index);
			index += xNextNode.b || 0;

			xIndex += 2;
			yIndex += 1;
			continue;
		}

		// remove x, insert y
		if (xNext && xNextKey === yNextKey)
		{
			index++;
			_VirtualDom_removeNode(changes, localPatches, xKey, xNode, index);
			_VirtualDom_insertNode(changes, localPatches, yKey, yNode, yIndex, inserts);
			index += xNode.b || 0;

			index++;
			_VirtualDom_diffHelp(xNextNode, yNextNode, localPatches, index);
			index += xNextNode.b || 0;

			xIndex += 2;
			yIndex += 2;
			continue;
		}

		break;
	}

	// eat up any remaining nodes with removeNode and insertNode

	while (xIndex < xLen)
	{
		index++;
		var x = xKids[xIndex];
		var xNode = x.b;
		_VirtualDom_removeNode(changes, localPatches, x.a, xNode, index);
		index += xNode.b || 0;
		xIndex++;
	}

	while (yIndex < yLen)
	{
		var endInserts = endInserts || [];
		var y = yKids[yIndex];
		_VirtualDom_insertNode(changes, localPatches, y.a, y.b, undefined, endInserts);
		yIndex++;
	}

	if (localPatches.length > 0 || inserts.length > 0 || endInserts)
	{
		_VirtualDom_pushPatch(patches, 8, rootIndex, {
			w: localPatches,
			x: inserts,
			y: endInserts
		});
	}
}



// CHANGES FROM KEYED DIFF


var _VirtualDom_POSTFIX = '_elmW6BL';


function _VirtualDom_insertNode(changes, localPatches, key, vnode, yIndex, inserts)
{
	var entry = changes[key];

	// never seen this key before
	if (!entry)
	{
		entry = {
			c: 0,
			z: vnode,
			r: yIndex,
			s: undefined
		};

		inserts.push({ r: yIndex, A: entry });
		changes[key] = entry;

		return;
	}

	// this key was removed earlier, a match!
	if (entry.c === 1)
	{
		inserts.push({ r: yIndex, A: entry });

		entry.c = 2;
		var subPatches = [];
		_VirtualDom_diffHelp(entry.z, vnode, subPatches, entry.r);
		entry.r = yIndex;
		entry.s.s = {
			w: subPatches,
			A: entry
		};

		return;
	}

	// this key has already been inserted or moved, a duplicate!
	_VirtualDom_insertNode(changes, localPatches, key + _VirtualDom_POSTFIX, vnode, yIndex, inserts);
}


function _VirtualDom_removeNode(changes, localPatches, key, vnode, index)
{
	var entry = changes[key];

	// never seen this key before
	if (!entry)
	{
		var patch = _VirtualDom_pushPatch(localPatches, 9, index, undefined);

		changes[key] = {
			c: 1,
			z: vnode,
			r: index,
			s: patch
		};

		return;
	}

	// this key was inserted earlier, a match!
	if (entry.c === 0)
	{
		entry.c = 2;
		var subPatches = [];
		_VirtualDom_diffHelp(vnode, entry.z, subPatches, index);

		_VirtualDom_pushPatch(localPatches, 9, index, {
			w: subPatches,
			A: entry
		});

		return;
	}

	// this key has already been removed or moved, a duplicate!
	_VirtualDom_removeNode(changes, localPatches, key + _VirtualDom_POSTFIX, vnode, index);
}



// ADD DOM NODES
//
// Each DOM node has an "index" assigned in order of traversal. It is important
// to minimize our crawl over the actual DOM, so these indexes (along with the
// descendantsCount of virtual nodes) let us skip touching entire subtrees of
// the DOM if we know there are no patches there.


function _VirtualDom_addDomNodes(domNode, vNode, patches, eventNode)
{
	_VirtualDom_addDomNodesHelp(domNode, vNode, patches, 0, 0, vNode.b, eventNode);
}


// assumes `patches` is non-empty and indexes increase monotonically.
function _VirtualDom_addDomNodesHelp(domNode, vNode, patches, i, low, high, eventNode)
{
	var patch = patches[i];
	var index = patch.r;

	while (index === low)
	{
		var patchType = patch.$;

		if (patchType === 1)
		{
			_VirtualDom_addDomNodes(domNode, vNode.k, patch.s, eventNode);
		}
		else if (patchType === 8)
		{
			patch.t = domNode;
			patch.u = eventNode;

			var subPatches = patch.s.w;
			if (subPatches.length > 0)
			{
				_VirtualDom_addDomNodesHelp(domNode, vNode, subPatches, 0, low, high, eventNode);
			}
		}
		else if (patchType === 9)
		{
			patch.t = domNode;
			patch.u = eventNode;

			var data = patch.s;
			if (data)
			{
				data.A.s = domNode;
				var subPatches = data.w;
				if (subPatches.length > 0)
				{
					_VirtualDom_addDomNodesHelp(domNode, vNode, subPatches, 0, low, high, eventNode);
				}
			}
		}
		else
		{
			patch.t = domNode;
			patch.u = eventNode;
		}

		i++;

		if (!(patch = patches[i]) || (index = patch.r) > high)
		{
			return i;
		}
	}

	var tag = vNode.$;

	if (tag === 4)
	{
		var subNode = vNode.k;

		while (subNode.$ === 4)
		{
			subNode = subNode.k;
		}

		return _VirtualDom_addDomNodesHelp(domNode, subNode, patches, i, low + 1, high, domNode.elm_event_node_ref);
	}

	// tag must be 1 or 2 at this point

	var vKids = vNode.e;
	var childNodes = domNode.childNodes;
	for (var j = 0; j < vKids.length; j++)
	{
		low++;
		var vKid = tag === 1 ? vKids[j] : vKids[j].b;
		var nextLow = low + (vKid.b || 0);
		if (low <= index && index <= nextLow)
		{
			i = _VirtualDom_addDomNodesHelp(childNodes[j], vKid, patches, i, low, nextLow, eventNode);
			if (!(patch = patches[i]) || (index = patch.r) > high)
			{
				return i;
			}
		}
		low = nextLow;
	}
	return i;
}



// APPLY PATCHES


function _VirtualDom_applyPatches(rootDomNode, oldVirtualNode, patches, eventNode)
{
	if (patches.length === 0)
	{
		return rootDomNode;
	}

	_VirtualDom_addDomNodes(rootDomNode, oldVirtualNode, patches, eventNode);
	return _VirtualDom_applyPatchesHelp(rootDomNode, patches);
}

function _VirtualDom_applyPatchesHelp(rootDomNode, patches)
{
	for (var i = 0; i < patches.length; i++)
	{
		var patch = patches[i];
		var localDomNode = patch.t
		var newNode = _VirtualDom_applyPatch(localDomNode, patch);
		if (localDomNode === rootDomNode)
		{
			rootDomNode = newNode;
		}
	}
	return rootDomNode;
}

function _VirtualDom_applyPatch(domNode, patch)
{
	switch (patch.$)
	{
		case 0:
			return _VirtualDom_applyPatchRedraw(domNode, patch.s, patch.u);

		case 4:
			_VirtualDom_applyFacts(domNode, patch.u, patch.s);
			return domNode;

		case 3:
			domNode.replaceData(0, domNode.length, patch.s);
			return domNode;

		case 1:
			return _VirtualDom_applyPatchesHelp(domNode, patch.s);

		case 2:
			if (domNode.elm_event_node_ref)
			{
				domNode.elm_event_node_ref.j = patch.s;
			}
			else
			{
				domNode.elm_event_node_ref = { j: patch.s, p: patch.u };
			}
			return domNode;

		case 6:
			var data = patch.s;
			for (var i = 0; i < data.i; i++)
			{
				domNode.removeChild(domNode.childNodes[data.v]);
			}
			return domNode;

		case 7:
			var data = patch.s;
			var kids = data.e;
			var i = data.v;
			var theEnd = domNode.childNodes[i];
			for (; i < kids.length; i++)
			{
				domNode.insertBefore(_VirtualDom_render(kids[i], patch.u), theEnd);
			}
			return domNode;

		case 9:
			var data = patch.s;
			if (!data)
			{
				domNode.parentNode.removeChild(domNode);
				return domNode;
			}
			var entry = data.A;
			if (typeof entry.r !== 'undefined')
			{
				domNode.parentNode.removeChild(domNode);
			}
			entry.s = _VirtualDom_applyPatchesHelp(domNode, data.w);
			return domNode;

		case 8:
			return _VirtualDom_applyPatchReorder(domNode, patch);

		case 5:
			return patch.s(domNode);

		default:
			_Debug_crash(10); // 'Ran into an unknown patch!'
	}
}


function _VirtualDom_applyPatchRedraw(domNode, vNode, eventNode)
{
	var parentNode = domNode.parentNode;
	var newNode = _VirtualDom_render(vNode, eventNode);

	if (!newNode.elm_event_node_ref)
	{
		newNode.elm_event_node_ref = domNode.elm_event_node_ref;
	}

	if (parentNode && newNode !== domNode)
	{
		parentNode.replaceChild(newNode, domNode);
	}
	return newNode;
}


function _VirtualDom_applyPatchReorder(domNode, patch)
{
	var data = patch.s;

	// remove end inserts
	var frag = _VirtualDom_applyPatchReorderEndInsertsHelp(data.y, patch);

	// removals
	domNode = _VirtualDom_applyPatchesHelp(domNode, data.w);

	// inserts
	var inserts = data.x;
	for (var i = 0; i < inserts.length; i++)
	{
		var insert = inserts[i];
		var entry = insert.A;
		var node = entry.c === 2
			? entry.s
			: _VirtualDom_render(entry.z, patch.u);
		domNode.insertBefore(node, domNode.childNodes[insert.r]);
	}

	// add end inserts
	if (frag)
	{
		_VirtualDom_appendChild(domNode, frag);
	}

	return domNode;
}


function _VirtualDom_applyPatchReorderEndInsertsHelp(endInserts, patch)
{
	if (!endInserts)
	{
		return;
	}

	var frag = _VirtualDom_doc.createDocumentFragment();
	for (var i = 0; i < endInserts.length; i++)
	{
		var insert = endInserts[i];
		var entry = insert.A;
		_VirtualDom_appendChild(frag, entry.c === 2
			? entry.s
			: _VirtualDom_render(entry.z, patch.u)
		);
	}
	return frag;
}


function _VirtualDom_virtualize(node)
{
	// TEXT NODES

	if (node.nodeType === 3)
	{
		return _VirtualDom_text(node.textContent);
	}


	// WEIRD NODES

	if (node.nodeType !== 1)
	{
		return _VirtualDom_text('');
	}


	// ELEMENT NODES

	var attrList = _List_Nil;
	var attrs = node.attributes;
	for (var i = attrs.length; i--; )
	{
		var attr = attrs[i];
		var name = attr.name;
		var value = attr.value;
		attrList = _List_Cons( A2(_VirtualDom_attribute, name, value), attrList );
	}

	var tag = node.tagName.toLowerCase();
	var kidList = _List_Nil;
	var kids = node.childNodes;

	for (var i = kids.length; i--; )
	{
		kidList = _List_Cons(_VirtualDom_virtualize(kids[i]), kidList);
	}
	return A3(_VirtualDom_node, tag, attrList, kidList);
}

function _VirtualDom_dekey(keyedNode)
{
	var keyedKids = keyedNode.e;
	var len = keyedKids.length;
	var kids = new Array(len);
	for (var i = 0; i < len; i++)
	{
		kids[i] = keyedKids[i].b;
	}

	return {
		$: 1,
		c: keyedNode.c,
		d: keyedNode.d,
		e: kids,
		f: keyedNode.f,
		b: keyedNode.b
	};
}




// ELEMENT


var _Debugger_element;

var _Browser_element = _Debugger_element || F4(function(impl, flagDecoder, debugMetadata, args)
{
	return _Platform_initialize(
		flagDecoder,
		args,
		impl.cv,
		impl.c4,
		impl.c1,
		function(sendToApp, initialModel) {
			var view = impl.c5;
			/**/
			var domNode = args['node'];
			//*/
			/**_UNUSED/
			var domNode = args && args['node'] ? args['node'] : _Debug_crash(0);
			//*/
			var currNode = _VirtualDom_virtualize(domNode);

			return _Browser_makeAnimator(initialModel, function(model)
			{
				var nextNode = view(model);
				var patches = _VirtualDom_diff(currNode, nextNode);
				domNode = _VirtualDom_applyPatches(domNode, currNode, patches, sendToApp);
				currNode = nextNode;
			});
		}
	);
});



// DOCUMENT


var _Debugger_document;

var _Browser_document = _Debugger_document || F4(function(impl, flagDecoder, debugMetadata, args)
{
	return _Platform_initialize(
		flagDecoder,
		args,
		impl.cv,
		impl.c4,
		impl.c1,
		function(sendToApp, initialModel) {
			var divertHrefToApp = impl.aQ && impl.aQ(sendToApp)
			var view = impl.c5;
			var title = _VirtualDom_doc.title;
			var bodyNode = _VirtualDom_doc.body;
			var currNode = _VirtualDom_virtualize(bodyNode);
			return _Browser_makeAnimator(initialModel, function(model)
			{
				_VirtualDom_divertHrefToApp = divertHrefToApp;
				var doc = view(model);
				var nextNode = _VirtualDom_node('body')(_List_Nil)(doc.cc);
				var patches = _VirtualDom_diff(currNode, nextNode);
				bodyNode = _VirtualDom_applyPatches(bodyNode, currNode, patches, sendToApp);
				currNode = nextNode;
				_VirtualDom_divertHrefToApp = 0;
				(title !== doc.bX) && (_VirtualDom_doc.title = title = doc.bX);
			});
		}
	);
});



// ANIMATION


var _Browser_cancelAnimationFrame =
	typeof cancelAnimationFrame !== 'undefined'
		? cancelAnimationFrame
		: function(id) { clearTimeout(id); };

var _Browser_requestAnimationFrame =
	typeof requestAnimationFrame !== 'undefined'
		? requestAnimationFrame
		: function(callback) { return setTimeout(callback, 1000 / 60); };


function _Browser_makeAnimator(model, draw)
{
	draw(model);

	var state = 0;

	function updateIfNeeded()
	{
		state = state === 1
			? 0
			: ( _Browser_requestAnimationFrame(updateIfNeeded), draw(model), 1 );
	}

	return function(nextModel, isSync)
	{
		model = nextModel;

		isSync
			? ( draw(model),
				state === 2 && (state = 1)
				)
			: ( state === 0 && _Browser_requestAnimationFrame(updateIfNeeded),
				state = 2
				);
	};
}



// APPLICATION


function _Browser_application(impl)
{
	var onUrlChange = impl.cM;
	var onUrlRequest = impl.cN;
	var key = function() { key.a(onUrlChange(_Browser_getUrl())); };

	return _Browser_document({
		aQ: function(sendToApp)
		{
			key.a = sendToApp;
			_Browser_window.addEventListener('popstate', key);
			_Browser_window.navigator.userAgent.indexOf('Trident') < 0 || _Browser_window.addEventListener('hashchange', key);

			return F2(function(domNode, event)
			{
				if (!event.ctrlKey && !event.metaKey && !event.shiftKey && event.button < 1 && !domNode.target && !domNode.hasAttribute('download'))
				{
					event.preventDefault();
					var href = domNode.href;
					var curr = _Browser_getUrl();
					var next = $elm$url$Url$fromString(href).a;
					sendToApp(onUrlRequest(
						(next
							&& curr.bC === next.bC
							&& curr.bh === next.bh
							&& curr.cR.a === next.cR.a
						)
							? $elm$browser$Browser$Internal(next)
							: $elm$browser$Browser$External(href)
					));
				}
			});
		},
		cv: function(flags)
		{
			return A3(impl.cv, flags, _Browser_getUrl(), key);
		},
		c5: impl.c5,
		c4: impl.c4,
		c1: impl.c1
	});
}

function _Browser_getUrl()
{
	return $elm$url$Url$fromString(_VirtualDom_doc.location.href).a || _Debug_crash(1);
}

var _Browser_go = F2(function(key, n)
{
	return A2($elm$core$Task$perform, $elm$core$Basics$never, _Scheduler_binding(function() {
		n && history.go(n);
		key();
	}));
});

var _Browser_pushUrl = F2(function(key, url)
{
	return A2($elm$core$Task$perform, $elm$core$Basics$never, _Scheduler_binding(function() {
		history.pushState({}, '', url);
		key();
	}));
});

var _Browser_replaceUrl = F2(function(key, url)
{
	return A2($elm$core$Task$perform, $elm$core$Basics$never, _Scheduler_binding(function() {
		history.replaceState({}, '', url);
		key();
	}));
});



// GLOBAL EVENTS


var _Browser_fakeNode = { addEventListener: function() {}, removeEventListener: function() {} };
var _Browser_doc = typeof document !== 'undefined' ? document : _Browser_fakeNode;
var _Browser_window = typeof window !== 'undefined' ? window : _Browser_fakeNode;

var _Browser_on = F3(function(node, eventName, sendToSelf)
{
	return _Scheduler_spawn(_Scheduler_binding(function(callback)
	{
		function handler(event)	{ _Scheduler_rawSpawn(sendToSelf(event)); }
		node.addEventListener(eventName, handler, _VirtualDom_passiveSupported && { passive: true });
		return function() { node.removeEventListener(eventName, handler); };
	}));
});

var _Browser_decodeEvent = F2(function(decoder, event)
{
	var result = _Json_runHelp(decoder, event);
	return $elm$core$Result$isOk(result) ? $elm$core$Maybe$Just(result.a) : $elm$core$Maybe$Nothing;
});



// PAGE VISIBILITY


function _Browser_visibilityInfo()
{
	return (typeof _VirtualDom_doc.hidden !== 'undefined')
		? { cs: 'hidden', cg: 'visibilitychange' }
		:
	(typeof _VirtualDom_doc.mozHidden !== 'undefined')
		? { cs: 'mozHidden', cg: 'mozvisibilitychange' }
		:
	(typeof _VirtualDom_doc.msHidden !== 'undefined')
		? { cs: 'msHidden', cg: 'msvisibilitychange' }
		:
	(typeof _VirtualDom_doc.webkitHidden !== 'undefined')
		? { cs: 'webkitHidden', cg: 'webkitvisibilitychange' }
		: { cs: 'hidden', cg: 'visibilitychange' };
}



// ANIMATION FRAMES


function _Browser_rAF()
{
	return _Scheduler_binding(function(callback)
	{
		var id = _Browser_requestAnimationFrame(function() {
			callback(_Scheduler_succeed(Date.now()));
		});

		return function() {
			_Browser_cancelAnimationFrame(id);
		};
	});
}


function _Browser_now()
{
	return _Scheduler_binding(function(callback)
	{
		callback(_Scheduler_succeed(Date.now()));
	});
}



// DOM STUFF


function _Browser_withNode(id, doStuff)
{
	return _Scheduler_binding(function(callback)
	{
		_Browser_requestAnimationFrame(function() {
			var node = document.getElementById(id);
			callback(node
				? _Scheduler_succeed(doStuff(node))
				: _Scheduler_fail($elm$browser$Browser$Dom$NotFound(id))
			);
		});
	});
}


function _Browser_withWindow(doStuff)
{
	return _Scheduler_binding(function(callback)
	{
		_Browser_requestAnimationFrame(function() {
			callback(_Scheduler_succeed(doStuff()));
		});
	});
}


// FOCUS and BLUR


var _Browser_call = F2(function(functionName, id)
{
	return _Browser_withNode(id, function(node) {
		node[functionName]();
		return _Utils_Tuple0;
	});
});



// WINDOW VIEWPORT


function _Browser_getViewport()
{
	return {
		bN: _Browser_getScene(),
		b0: {
			b4: _Browser_window.pageXOffset,
			b5: _Browser_window.pageYOffset,
			b2: _Browser_doc.documentElement.clientWidth,
			bg: _Browser_doc.documentElement.clientHeight
		}
	};
}

function _Browser_getScene()
{
	var body = _Browser_doc.body;
	var elem = _Browser_doc.documentElement;
	return {
		b2: Math.max(body.scrollWidth, body.offsetWidth, elem.scrollWidth, elem.offsetWidth, elem.clientWidth),
		bg: Math.max(body.scrollHeight, body.offsetHeight, elem.scrollHeight, elem.offsetHeight, elem.clientHeight)
	};
}

var _Browser_setViewport = F2(function(x, y)
{
	return _Browser_withWindow(function()
	{
		_Browser_window.scroll(x, y);
		return _Utils_Tuple0;
	});
});



// ELEMENT VIEWPORT


function _Browser_getViewportOf(id)
{
	return _Browser_withNode(id, function(node)
	{
		return {
			bN: {
				b2: node.scrollWidth,
				bg: node.scrollHeight
			},
			b0: {
				b4: node.scrollLeft,
				b5: node.scrollTop,
				b2: node.clientWidth,
				bg: node.clientHeight
			}
		};
	});
}


var _Browser_setViewportOf = F3(function(id, x, y)
{
	return _Browser_withNode(id, function(node)
	{
		node.scrollLeft = x;
		node.scrollTop = y;
		return _Utils_Tuple0;
	});
});



// ELEMENT


function _Browser_getElement(id)
{
	return _Browser_withNode(id, function(node)
	{
		var rect = node.getBoundingClientRect();
		var x = _Browser_window.pageXOffset;
		var y = _Browser_window.pageYOffset;
		return {
			bN: _Browser_getScene(),
			b0: {
				b4: x,
				b5: y,
				b2: _Browser_doc.documentElement.clientWidth,
				bg: _Browser_doc.documentElement.clientHeight
			},
			cm: {
				b4: x + rect.left,
				b5: y + rect.top,
				b2: rect.width,
				bg: rect.height
			}
		};
	});
}



// LOAD and RELOAD


function _Browser_reload(skipCache)
{
	return A2($elm$core$Task$perform, $elm$core$Basics$never, _Scheduler_binding(function(callback)
	{
		_VirtualDom_doc.location.reload(skipCache);
	}));
}

function _Browser_load(url)
{
	return A2($elm$core$Task$perform, $elm$core$Basics$never, _Scheduler_binding(function(callback)
	{
		try
		{
			_Browser_window.location = url;
		}
		catch(err)
		{
			// Only Firefox can throw a NS_ERROR_MALFORMED_URI exception here.
			// Other browsers reload the page, so let's be consistent about that.
			_VirtualDom_doc.location.reload(false);
		}
	}));
}
var $elm$core$Basics$EQ = 1;
var $elm$core$Basics$GT = 2;
var $elm$core$Basics$LT = 0;
var $elm$core$List$cons = _List_cons;
var $elm$core$Dict$foldr = F3(
	function (func, acc, t) {
		foldr:
		while (true) {
			if (t.$ === -2) {
				return acc;
			} else {
				var key = t.b;
				var value = t.c;
				var left = t.d;
				var right = t.e;
				var $temp$func = func,
					$temp$acc = A3(
					func,
					key,
					value,
					A3($elm$core$Dict$foldr, func, acc, right)),
					$temp$t = left;
				func = $temp$func;
				acc = $temp$acc;
				t = $temp$t;
				continue foldr;
			}
		}
	});
var $elm$core$Dict$toList = function (dict) {
	return A3(
		$elm$core$Dict$foldr,
		F3(
			function (key, value, list) {
				return A2(
					$elm$core$List$cons,
					_Utils_Tuple2(key, value),
					list);
			}),
		_List_Nil,
		dict);
};
var $elm$core$Dict$keys = function (dict) {
	return A3(
		$elm$core$Dict$foldr,
		F3(
			function (key, value, keyList) {
				return A2($elm$core$List$cons, key, keyList);
			}),
		_List_Nil,
		dict);
};
var $elm$core$Set$toList = function (_v0) {
	var dict = _v0;
	return $elm$core$Dict$keys(dict);
};
var $elm$core$Elm$JsArray$foldr = _JsArray_foldr;
var $elm$core$Array$foldr = F3(
	function (func, baseCase, _v0) {
		var tree = _v0.c;
		var tail = _v0.d;
		var helper = F2(
			function (node, acc) {
				if (!node.$) {
					var subTree = node.a;
					return A3($elm$core$Elm$JsArray$foldr, helper, acc, subTree);
				} else {
					var values = node.a;
					return A3($elm$core$Elm$JsArray$foldr, func, acc, values);
				}
			});
		return A3(
			$elm$core$Elm$JsArray$foldr,
			helper,
			A3($elm$core$Elm$JsArray$foldr, func, baseCase, tail),
			tree);
	});
var $elm$core$Array$toList = function (array) {
	return A3($elm$core$Array$foldr, $elm$core$List$cons, _List_Nil, array);
};
var $elm$core$Result$Err = function (a) {
	return {$: 1, a: a};
};
var $elm$json$Json$Decode$Failure = F2(
	function (a, b) {
		return {$: 3, a: a, b: b};
	});
var $elm$json$Json$Decode$Field = F2(
	function (a, b) {
		return {$: 0, a: a, b: b};
	});
var $elm$json$Json$Decode$Index = F2(
	function (a, b) {
		return {$: 1, a: a, b: b};
	});
var $elm$core$Result$Ok = function (a) {
	return {$: 0, a: a};
};
var $elm$json$Json$Decode$OneOf = function (a) {
	return {$: 2, a: a};
};
var $elm$core$Basics$False = 1;
var $elm$core$Basics$add = _Basics_add;
var $elm$core$Maybe$Just = function (a) {
	return {$: 0, a: a};
};
var $elm$core$Maybe$Nothing = {$: 1};
var $elm$core$String$all = _String_all;
var $elm$core$Basics$and = _Basics_and;
var $elm$core$Basics$append = _Utils_append;
var $elm$json$Json$Encode$encode = _Json_encode;
var $elm$core$String$fromInt = _String_fromNumber;
var $elm$core$String$join = F2(
	function (sep, chunks) {
		return A2(
			_String_join,
			sep,
			_List_toArray(chunks));
	});
var $elm$core$String$split = F2(
	function (sep, string) {
		return _List_fromArray(
			A2(_String_split, sep, string));
	});
var $elm$json$Json$Decode$indent = function (str) {
	return A2(
		$elm$core$String$join,
		'\n    ',
		A2($elm$core$String$split, '\n', str));
};
var $elm$core$List$foldl = F3(
	function (func, acc, list) {
		foldl:
		while (true) {
			if (!list.b) {
				return acc;
			} else {
				var x = list.a;
				var xs = list.b;
				var $temp$func = func,
					$temp$acc = A2(func, x, acc),
					$temp$list = xs;
				func = $temp$func;
				acc = $temp$acc;
				list = $temp$list;
				continue foldl;
			}
		}
	});
var $elm$core$List$length = function (xs) {
	return A3(
		$elm$core$List$foldl,
		F2(
			function (_v0, i) {
				return i + 1;
			}),
		0,
		xs);
};
var $elm$core$List$map2 = _List_map2;
var $elm$core$Basics$le = _Utils_le;
var $elm$core$Basics$sub = _Basics_sub;
var $elm$core$List$rangeHelp = F3(
	function (lo, hi, list) {
		rangeHelp:
		while (true) {
			if (_Utils_cmp(lo, hi) < 1) {
				var $temp$lo = lo,
					$temp$hi = hi - 1,
					$temp$list = A2($elm$core$List$cons, hi, list);
				lo = $temp$lo;
				hi = $temp$hi;
				list = $temp$list;
				continue rangeHelp;
			} else {
				return list;
			}
		}
	});
var $elm$core$List$range = F2(
	function (lo, hi) {
		return A3($elm$core$List$rangeHelp, lo, hi, _List_Nil);
	});
var $elm$core$List$indexedMap = F2(
	function (f, xs) {
		return A3(
			$elm$core$List$map2,
			f,
			A2(
				$elm$core$List$range,
				0,
				$elm$core$List$length(xs) - 1),
			xs);
	});
var $elm$core$Char$toCode = _Char_toCode;
var $elm$core$Char$isLower = function (_char) {
	var code = $elm$core$Char$toCode(_char);
	return (97 <= code) && (code <= 122);
};
var $elm$core$Char$isUpper = function (_char) {
	var code = $elm$core$Char$toCode(_char);
	return (code <= 90) && (65 <= code);
};
var $elm$core$Basics$or = _Basics_or;
var $elm$core$Char$isAlpha = function (_char) {
	return $elm$core$Char$isLower(_char) || $elm$core$Char$isUpper(_char);
};
var $elm$core$Char$isDigit = function (_char) {
	var code = $elm$core$Char$toCode(_char);
	return (code <= 57) && (48 <= code);
};
var $elm$core$Char$isAlphaNum = function (_char) {
	return $elm$core$Char$isLower(_char) || ($elm$core$Char$isUpper(_char) || $elm$core$Char$isDigit(_char));
};
var $elm$core$List$reverse = function (list) {
	return A3($elm$core$List$foldl, $elm$core$List$cons, _List_Nil, list);
};
var $elm$core$String$uncons = _String_uncons;
var $elm$json$Json$Decode$errorOneOf = F2(
	function (i, error) {
		return '\n\n(' + ($elm$core$String$fromInt(i + 1) + (') ' + $elm$json$Json$Decode$indent(
			$elm$json$Json$Decode$errorToString(error))));
	});
var $elm$json$Json$Decode$errorToString = function (error) {
	return A2($elm$json$Json$Decode$errorToStringHelp, error, _List_Nil);
};
var $elm$json$Json$Decode$errorToStringHelp = F2(
	function (error, context) {
		errorToStringHelp:
		while (true) {
			switch (error.$) {
				case 0:
					var f = error.a;
					var err = error.b;
					var isSimple = function () {
						var _v1 = $elm$core$String$uncons(f);
						if (_v1.$ === 1) {
							return false;
						} else {
							var _v2 = _v1.a;
							var _char = _v2.a;
							var rest = _v2.b;
							return $elm$core$Char$isAlpha(_char) && A2($elm$core$String$all, $elm$core$Char$isAlphaNum, rest);
						}
					}();
					var fieldName = isSimple ? ('.' + f) : ('[\'' + (f + '\']'));
					var $temp$error = err,
						$temp$context = A2($elm$core$List$cons, fieldName, context);
					error = $temp$error;
					context = $temp$context;
					continue errorToStringHelp;
				case 1:
					var i = error.a;
					var err = error.b;
					var indexName = '[' + ($elm$core$String$fromInt(i) + ']');
					var $temp$error = err,
						$temp$context = A2($elm$core$List$cons, indexName, context);
					error = $temp$error;
					context = $temp$context;
					continue errorToStringHelp;
				case 2:
					var errors = error.a;
					if (!errors.b) {
						return 'Ran into a Json.Decode.oneOf with no possibilities' + function () {
							if (!context.b) {
								return '!';
							} else {
								return ' at json' + A2(
									$elm$core$String$join,
									'',
									$elm$core$List$reverse(context));
							}
						}();
					} else {
						if (!errors.b.b) {
							var err = errors.a;
							var $temp$error = err,
								$temp$context = context;
							error = $temp$error;
							context = $temp$context;
							continue errorToStringHelp;
						} else {
							var starter = function () {
								if (!context.b) {
									return 'Json.Decode.oneOf';
								} else {
									return 'The Json.Decode.oneOf at json' + A2(
										$elm$core$String$join,
										'',
										$elm$core$List$reverse(context));
								}
							}();
							var introduction = starter + (' failed in the following ' + ($elm$core$String$fromInt(
								$elm$core$List$length(errors)) + ' ways:'));
							return A2(
								$elm$core$String$join,
								'\n\n',
								A2(
									$elm$core$List$cons,
									introduction,
									A2($elm$core$List$indexedMap, $elm$json$Json$Decode$errorOneOf, errors)));
						}
					}
				default:
					var msg = error.a;
					var json = error.b;
					var introduction = function () {
						if (!context.b) {
							return 'Problem with the given value:\n\n';
						} else {
							return 'Problem with the value at json' + (A2(
								$elm$core$String$join,
								'',
								$elm$core$List$reverse(context)) + ':\n\n    ');
						}
					}();
					return introduction + ($elm$json$Json$Decode$indent(
						A2($elm$json$Json$Encode$encode, 4, json)) + ('\n\n' + msg));
			}
		}
	});
var $elm$core$Array$branchFactor = 32;
var $elm$core$Array$Array_elm_builtin = F4(
	function (a, b, c, d) {
		return {$: 0, a: a, b: b, c: c, d: d};
	});
var $elm$core$Elm$JsArray$empty = _JsArray_empty;
var $elm$core$Basics$ceiling = _Basics_ceiling;
var $elm$core$Basics$fdiv = _Basics_fdiv;
var $elm$core$Basics$logBase = F2(
	function (base, number) {
		return _Basics_log(number) / _Basics_log(base);
	});
var $elm$core$Basics$toFloat = _Basics_toFloat;
var $elm$core$Array$shiftStep = $elm$core$Basics$ceiling(
	A2($elm$core$Basics$logBase, 2, $elm$core$Array$branchFactor));
var $elm$core$Array$empty = A4($elm$core$Array$Array_elm_builtin, 0, $elm$core$Array$shiftStep, $elm$core$Elm$JsArray$empty, $elm$core$Elm$JsArray$empty);
var $elm$core$Elm$JsArray$initialize = _JsArray_initialize;
var $elm$core$Array$Leaf = function (a) {
	return {$: 1, a: a};
};
var $elm$core$Basics$apL = F2(
	function (f, x) {
		return f(x);
	});
var $elm$core$Basics$apR = F2(
	function (x, f) {
		return f(x);
	});
var $elm$core$Basics$eq = _Utils_equal;
var $elm$core$Basics$floor = _Basics_floor;
var $elm$core$Elm$JsArray$length = _JsArray_length;
var $elm$core$Basics$gt = _Utils_gt;
var $elm$core$Basics$max = F2(
	function (x, y) {
		return (_Utils_cmp(x, y) > 0) ? x : y;
	});
var $elm$core$Basics$mul = _Basics_mul;
var $elm$core$Array$SubTree = function (a) {
	return {$: 0, a: a};
};
var $elm$core$Elm$JsArray$initializeFromList = _JsArray_initializeFromList;
var $elm$core$Array$compressNodes = F2(
	function (nodes, acc) {
		compressNodes:
		while (true) {
			var _v0 = A2($elm$core$Elm$JsArray$initializeFromList, $elm$core$Array$branchFactor, nodes);
			var node = _v0.a;
			var remainingNodes = _v0.b;
			var newAcc = A2(
				$elm$core$List$cons,
				$elm$core$Array$SubTree(node),
				acc);
			if (!remainingNodes.b) {
				return $elm$core$List$reverse(newAcc);
			} else {
				var $temp$nodes = remainingNodes,
					$temp$acc = newAcc;
				nodes = $temp$nodes;
				acc = $temp$acc;
				continue compressNodes;
			}
		}
	});
var $elm$core$Tuple$first = function (_v0) {
	var x = _v0.a;
	return x;
};
var $elm$core$Array$treeFromBuilder = F2(
	function (nodeList, nodeListSize) {
		treeFromBuilder:
		while (true) {
			var newNodeSize = $elm$core$Basics$ceiling(nodeListSize / $elm$core$Array$branchFactor);
			if (newNodeSize === 1) {
				return A2($elm$core$Elm$JsArray$initializeFromList, $elm$core$Array$branchFactor, nodeList).a;
			} else {
				var $temp$nodeList = A2($elm$core$Array$compressNodes, nodeList, _List_Nil),
					$temp$nodeListSize = newNodeSize;
				nodeList = $temp$nodeList;
				nodeListSize = $temp$nodeListSize;
				continue treeFromBuilder;
			}
		}
	});
var $elm$core$Array$builderToArray = F2(
	function (reverseNodeList, builder) {
		if (!builder.f) {
			return A4(
				$elm$core$Array$Array_elm_builtin,
				$elm$core$Elm$JsArray$length(builder.h),
				$elm$core$Array$shiftStep,
				$elm$core$Elm$JsArray$empty,
				builder.h);
		} else {
			var treeLen = builder.f * $elm$core$Array$branchFactor;
			var depth = $elm$core$Basics$floor(
				A2($elm$core$Basics$logBase, $elm$core$Array$branchFactor, treeLen - 1));
			var correctNodeList = reverseNodeList ? $elm$core$List$reverse(builder.i) : builder.i;
			var tree = A2($elm$core$Array$treeFromBuilder, correctNodeList, builder.f);
			return A4(
				$elm$core$Array$Array_elm_builtin,
				$elm$core$Elm$JsArray$length(builder.h) + treeLen,
				A2($elm$core$Basics$max, 5, depth * $elm$core$Array$shiftStep),
				tree,
				builder.h);
		}
	});
var $elm$core$Basics$idiv = _Basics_idiv;
var $elm$core$Basics$lt = _Utils_lt;
var $elm$core$Array$initializeHelp = F5(
	function (fn, fromIndex, len, nodeList, tail) {
		initializeHelp:
		while (true) {
			if (fromIndex < 0) {
				return A2(
					$elm$core$Array$builderToArray,
					false,
					{i: nodeList, f: (len / $elm$core$Array$branchFactor) | 0, h: tail});
			} else {
				var leaf = $elm$core$Array$Leaf(
					A3($elm$core$Elm$JsArray$initialize, $elm$core$Array$branchFactor, fromIndex, fn));
				var $temp$fn = fn,
					$temp$fromIndex = fromIndex - $elm$core$Array$branchFactor,
					$temp$len = len,
					$temp$nodeList = A2($elm$core$List$cons, leaf, nodeList),
					$temp$tail = tail;
				fn = $temp$fn;
				fromIndex = $temp$fromIndex;
				len = $temp$len;
				nodeList = $temp$nodeList;
				tail = $temp$tail;
				continue initializeHelp;
			}
		}
	});
var $elm$core$Basics$remainderBy = _Basics_remainderBy;
var $elm$core$Array$initialize = F2(
	function (len, fn) {
		if (len <= 0) {
			return $elm$core$Array$empty;
		} else {
			var tailLen = len % $elm$core$Array$branchFactor;
			var tail = A3($elm$core$Elm$JsArray$initialize, tailLen, len - tailLen, fn);
			var initialFromIndex = (len - tailLen) - $elm$core$Array$branchFactor;
			return A5($elm$core$Array$initializeHelp, fn, initialFromIndex, len, _List_Nil, tail);
		}
	});
var $elm$core$Basics$True = 0;
var $elm$core$Result$isOk = function (result) {
	if (!result.$) {
		return true;
	} else {
		return false;
	}
};
var $elm$json$Json$Decode$map = _Json_map1;
var $elm$json$Json$Decode$map2 = _Json_map2;
var $elm$json$Json$Decode$succeed = _Json_succeed;
var $elm$virtual_dom$VirtualDom$toHandlerInt = function (handler) {
	switch (handler.$) {
		case 0:
			return 0;
		case 1:
			return 1;
		case 2:
			return 2;
		default:
			return 3;
	}
};
var $elm$browser$Browser$External = function (a) {
	return {$: 1, a: a};
};
var $elm$browser$Browser$Internal = function (a) {
	return {$: 0, a: a};
};
var $elm$core$Basics$identity = function (x) {
	return x;
};
var $elm$browser$Browser$Dom$NotFound = $elm$core$Basics$identity;
var $elm$url$Url$Http = 0;
var $elm$url$Url$Https = 1;
var $elm$url$Url$Url = F6(
	function (protocol, host, port_, path, query, fragment) {
		return {bc: fragment, bh: host, by: path, cR: port_, bC: protocol, bE: query};
	});
var $elm$core$String$contains = _String_contains;
var $elm$core$String$length = _String_length;
var $elm$core$String$slice = _String_slice;
var $elm$core$String$dropLeft = F2(
	function (n, string) {
		return (n < 1) ? string : A3(
			$elm$core$String$slice,
			n,
			$elm$core$String$length(string),
			string);
	});
var $elm$core$String$indexes = _String_indexes;
var $elm$core$String$isEmpty = function (string) {
	return string === '';
};
var $elm$core$String$left = F2(
	function (n, string) {
		return (n < 1) ? '' : A3($elm$core$String$slice, 0, n, string);
	});
var $elm$core$String$toInt = _String_toInt;
var $elm$url$Url$chompBeforePath = F5(
	function (protocol, path, params, frag, str) {
		if ($elm$core$String$isEmpty(str) || A2($elm$core$String$contains, '@', str)) {
			return $elm$core$Maybe$Nothing;
		} else {
			var _v0 = A2($elm$core$String$indexes, ':', str);
			if (!_v0.b) {
				return $elm$core$Maybe$Just(
					A6($elm$url$Url$Url, protocol, str, $elm$core$Maybe$Nothing, path, params, frag));
			} else {
				if (!_v0.b.b) {
					var i = _v0.a;
					var _v1 = $elm$core$String$toInt(
						A2($elm$core$String$dropLeft, i + 1, str));
					if (_v1.$ === 1) {
						return $elm$core$Maybe$Nothing;
					} else {
						var port_ = _v1;
						return $elm$core$Maybe$Just(
							A6(
								$elm$url$Url$Url,
								protocol,
								A2($elm$core$String$left, i, str),
								port_,
								path,
								params,
								frag));
					}
				} else {
					return $elm$core$Maybe$Nothing;
				}
			}
		}
	});
var $elm$url$Url$chompBeforeQuery = F4(
	function (protocol, params, frag, str) {
		if ($elm$core$String$isEmpty(str)) {
			return $elm$core$Maybe$Nothing;
		} else {
			var _v0 = A2($elm$core$String$indexes, '/', str);
			if (!_v0.b) {
				return A5($elm$url$Url$chompBeforePath, protocol, '/', params, frag, str);
			} else {
				var i = _v0.a;
				return A5(
					$elm$url$Url$chompBeforePath,
					protocol,
					A2($elm$core$String$dropLeft, i, str),
					params,
					frag,
					A2($elm$core$String$left, i, str));
			}
		}
	});
var $elm$url$Url$chompBeforeFragment = F3(
	function (protocol, frag, str) {
		if ($elm$core$String$isEmpty(str)) {
			return $elm$core$Maybe$Nothing;
		} else {
			var _v0 = A2($elm$core$String$indexes, '?', str);
			if (!_v0.b) {
				return A4($elm$url$Url$chompBeforeQuery, protocol, $elm$core$Maybe$Nothing, frag, str);
			} else {
				var i = _v0.a;
				return A4(
					$elm$url$Url$chompBeforeQuery,
					protocol,
					$elm$core$Maybe$Just(
						A2($elm$core$String$dropLeft, i + 1, str)),
					frag,
					A2($elm$core$String$left, i, str));
			}
		}
	});
var $elm$url$Url$chompAfterProtocol = F2(
	function (protocol, str) {
		if ($elm$core$String$isEmpty(str)) {
			return $elm$core$Maybe$Nothing;
		} else {
			var _v0 = A2($elm$core$String$indexes, '#', str);
			if (!_v0.b) {
				return A3($elm$url$Url$chompBeforeFragment, protocol, $elm$core$Maybe$Nothing, str);
			} else {
				var i = _v0.a;
				return A3(
					$elm$url$Url$chompBeforeFragment,
					protocol,
					$elm$core$Maybe$Just(
						A2($elm$core$String$dropLeft, i + 1, str)),
					A2($elm$core$String$left, i, str));
			}
		}
	});
var $elm$core$String$startsWith = _String_startsWith;
var $elm$url$Url$fromString = function (str) {
	return A2($elm$core$String$startsWith, 'http://', str) ? A2(
		$elm$url$Url$chompAfterProtocol,
		0,
		A2($elm$core$String$dropLeft, 7, str)) : (A2($elm$core$String$startsWith, 'https://', str) ? A2(
		$elm$url$Url$chompAfterProtocol,
		1,
		A2($elm$core$String$dropLeft, 8, str)) : $elm$core$Maybe$Nothing);
};
var $elm$core$Basics$never = function (_v0) {
	never:
	while (true) {
		var nvr = _v0;
		var $temp$_v0 = nvr;
		_v0 = $temp$_v0;
		continue never;
	}
};
var $elm$core$Task$Perform = $elm$core$Basics$identity;
var $elm$core$Task$succeed = _Scheduler_succeed;
var $elm$core$Task$init = $elm$core$Task$succeed(0);
var $elm$core$List$foldrHelper = F4(
	function (fn, acc, ctr, ls) {
		if (!ls.b) {
			return acc;
		} else {
			var a = ls.a;
			var r1 = ls.b;
			if (!r1.b) {
				return A2(fn, a, acc);
			} else {
				var b = r1.a;
				var r2 = r1.b;
				if (!r2.b) {
					return A2(
						fn,
						a,
						A2(fn, b, acc));
				} else {
					var c = r2.a;
					var r3 = r2.b;
					if (!r3.b) {
						return A2(
							fn,
							a,
							A2(
								fn,
								b,
								A2(fn, c, acc)));
					} else {
						var d = r3.a;
						var r4 = r3.b;
						var res = (ctr > 500) ? A3(
							$elm$core$List$foldl,
							fn,
							acc,
							$elm$core$List$reverse(r4)) : A4($elm$core$List$foldrHelper, fn, acc, ctr + 1, r4);
						return A2(
							fn,
							a,
							A2(
								fn,
								b,
								A2(
									fn,
									c,
									A2(fn, d, res))));
					}
				}
			}
		}
	});
var $elm$core$List$foldr = F3(
	function (fn, acc, ls) {
		return A4($elm$core$List$foldrHelper, fn, acc, 0, ls);
	});
var $elm$core$List$map = F2(
	function (f, xs) {
		return A3(
			$elm$core$List$foldr,
			F2(
				function (x, acc) {
					return A2(
						$elm$core$List$cons,
						f(x),
						acc);
				}),
			_List_Nil,
			xs);
	});
var $elm$core$Task$andThen = _Scheduler_andThen;
var $elm$core$Task$map = F2(
	function (func, taskA) {
		return A2(
			$elm$core$Task$andThen,
			function (a) {
				return $elm$core$Task$succeed(
					func(a));
			},
			taskA);
	});
var $elm$core$Task$map2 = F3(
	function (func, taskA, taskB) {
		return A2(
			$elm$core$Task$andThen,
			function (a) {
				return A2(
					$elm$core$Task$andThen,
					function (b) {
						return $elm$core$Task$succeed(
							A2(func, a, b));
					},
					taskB);
			},
			taskA);
	});
var $elm$core$Task$sequence = function (tasks) {
	return A3(
		$elm$core$List$foldr,
		$elm$core$Task$map2($elm$core$List$cons),
		$elm$core$Task$succeed(_List_Nil),
		tasks);
};
var $elm$core$Platform$sendToApp = _Platform_sendToApp;
var $elm$core$Task$spawnCmd = F2(
	function (router, _v0) {
		var task = _v0;
		return _Scheduler_spawn(
			A2(
				$elm$core$Task$andThen,
				$elm$core$Platform$sendToApp(router),
				task));
	});
var $elm$core$Task$onEffects = F3(
	function (router, commands, state) {
		return A2(
			$elm$core$Task$map,
			function (_v0) {
				return 0;
			},
			$elm$core$Task$sequence(
				A2(
					$elm$core$List$map,
					$elm$core$Task$spawnCmd(router),
					commands)));
	});
var $elm$core$Task$onSelfMsg = F3(
	function (_v0, _v1, _v2) {
		return $elm$core$Task$succeed(0);
	});
var $elm$core$Task$cmdMap = F2(
	function (tagger, _v0) {
		var task = _v0;
		return A2($elm$core$Task$map, tagger, task);
	});
_Platform_effectManagers['Task'] = _Platform_createManager($elm$core$Task$init, $elm$core$Task$onEffects, $elm$core$Task$onSelfMsg, $elm$core$Task$cmdMap);
var $elm$core$Task$command = _Platform_leaf('Task');
var $elm$core$Task$perform = F2(
	function (toMessage, task) {
		return $elm$core$Task$command(
			A2($elm$core$Task$map, toMessage, task));
	});
var $elm$browser$Browser$element = _Browser_element;
var $author$project$Main$Closed = 0;
var $author$project$Main$Feedback = 0;
var $author$project$Main$Idle = 0;
var $elm$core$Platform$Cmd$batch = _Platform_batch;
var $elm$core$Platform$Cmd$none = $elm$core$Platform$Cmd$batch(_List_Nil);
var $author$project$Main$init = function (_v0) {
	return _Utils_Tuple2(
		{W: 0, z: $elm$core$Maybe$Nothing, G: $elm$core$Maybe$Nothing, ai: false, ao: false, ab: 0, E: 0},
		$elm$core$Platform$Cmd$none);
};
var $author$project$Main$CloseForm = {$: 2};
var $author$project$Main$GotActionResult = function (a) {
	return {$: 20, a: a};
};
var $author$project$Main$GotAppStatus = function (a) {
	return {$: 12, a: a};
};
var $author$project$Main$GotContext = function (a) {
	return {$: 0, a: a};
};
var $author$project$Main$GotDashboardMode = function (a) {
	return {$: 11, a: a};
};
var $author$project$Main$GotScreenshotAttached = function (a) {
	return {$: 8, a: a};
};
var $author$project$Main$Reopen = {$: 4};
var $author$project$Main$SubmitDone = {$: 10};
var $elm$json$Json$Decode$value = _Json_decodeValue;
var $author$project$Main$actionResult = _Platform_incomingPort('actionResult', $elm$json$Json$Decode$value);
var $author$project$Main$appStatus = _Platform_incomingPort('appStatus', $elm$json$Json$Decode$value);
var $elm$core$Platform$Sub$batch = _Platform_batch;
var $author$project$Main$context = _Platform_incomingPort('context', $elm$json$Json$Decode$value);
var $elm$json$Json$Decode$bool = _Json_decodeBool;
var $author$project$Main$dashboardMode = _Platform_incomingPort('dashboardMode', $elm$json$Json$Decode$bool);
var $elm$json$Json$Decode$null = _Json_decodeNull;
var $author$project$Main$reopen = _Platform_incomingPort(
	'reopen',
	$elm$json$Json$Decode$null(0));
var $author$project$Main$requestClose = _Platform_incomingPort(
	'requestClose',
	$elm$json$Json$Decode$null(0));
var $author$project$Main$screenshotAttached = _Platform_incomingPort('screenshotAttached', $elm$json$Json$Decode$bool);
var $author$project$Main$submitted = _Platform_incomingPort(
	'submitted',
	$elm$json$Json$Decode$null(0));
var $author$project$Main$subscriptions = function (_v0) {
	return $elm$core$Platform$Sub$batch(
		_List_fromArray(
			[
				$author$project$Main$context($author$project$Main$GotContext),
				$author$project$Main$screenshotAttached($author$project$Main$GotScreenshotAttached),
				$author$project$Main$requestClose(
				function (_v1) {
					return $author$project$Main$CloseForm;
				}),
				$author$project$Main$reopen(
				function (_v2) {
					return $author$project$Main$Reopen;
				}),
				$author$project$Main$submitted(
				function (_v3) {
					return $author$project$Main$SubmitDone;
				}),
				$author$project$Main$dashboardMode($author$project$Main$GotDashboardMode),
				$author$project$Main$appStatus($author$project$Main$GotAppStatus),
				$author$project$Main$actionResult($author$project$Main$GotActionResult)
			]));
};
var $author$project$Main$FormOpen = 1;
var $author$project$Main$Hidden = 2;
var $author$project$Main$Submitting = 1;
var $author$project$Main$ActionResult = F3(
	function (action, pr, ok) {
		return {M: action, ay: ok, K: pr};
	});
var $elm$json$Json$Decode$field = _Json_decodeField;
var $elm$json$Json$Decode$int = _Json_decodeInt;
var $elm$json$Json$Decode$map3 = _Json_map3;
var $elm$json$Json$Decode$oneOf = _Json_oneOf;
var $elm$json$Json$Decode$maybe = function (decoder) {
	return $elm$json$Json$Decode$oneOf(
		_List_fromArray(
			[
				A2($elm$json$Json$Decode$map, $elm$core$Maybe$Just, decoder),
				$elm$json$Json$Decode$succeed($elm$core$Maybe$Nothing)
			]));
};
var $elm$json$Json$Decode$string = _Json_decodeString;
var $author$project$Main$actionResultDecoder = A4(
	$elm$json$Json$Decode$map3,
	$author$project$Main$ActionResult,
	A2($elm$json$Json$Decode$field, 'action', $elm$json$Json$Decode$string),
	$elm$json$Json$Decode$maybe(
		A2($elm$json$Json$Decode$field, 'pr', $elm$json$Json$Decode$int)),
	A2($elm$json$Json$Decode$field, 'ok', $elm$json$Json$Decode$bool));
var $author$project$Dashboard$Idle = 0;
var $elm$core$Dict$Black = 1;
var $elm$core$Dict$RBNode_elm_builtin = F5(
	function (a, b, c, d, e) {
		return {$: -1, a: a, b: b, c: c, d: d, e: e};
	});
var $elm$core$Dict$RBEmpty_elm_builtin = {$: -2};
var $elm$core$Dict$Red = 0;
var $elm$core$Dict$balance = F5(
	function (color, key, value, left, right) {
		if ((right.$ === -1) && (!right.a)) {
			var _v1 = right.a;
			var rK = right.b;
			var rV = right.c;
			var rLeft = right.d;
			var rRight = right.e;
			if ((left.$ === -1) && (!left.a)) {
				var _v3 = left.a;
				var lK = left.b;
				var lV = left.c;
				var lLeft = left.d;
				var lRight = left.e;
				return A5(
					$elm$core$Dict$RBNode_elm_builtin,
					0,
					key,
					value,
					A5($elm$core$Dict$RBNode_elm_builtin, 1, lK, lV, lLeft, lRight),
					A5($elm$core$Dict$RBNode_elm_builtin, 1, rK, rV, rLeft, rRight));
			} else {
				return A5(
					$elm$core$Dict$RBNode_elm_builtin,
					color,
					rK,
					rV,
					A5($elm$core$Dict$RBNode_elm_builtin, 0, key, value, left, rLeft),
					rRight);
			}
		} else {
			if ((((left.$ === -1) && (!left.a)) && (left.d.$ === -1)) && (!left.d.a)) {
				var _v5 = left.a;
				var lK = left.b;
				var lV = left.c;
				var _v6 = left.d;
				var _v7 = _v6.a;
				var llK = _v6.b;
				var llV = _v6.c;
				var llLeft = _v6.d;
				var llRight = _v6.e;
				var lRight = left.e;
				return A5(
					$elm$core$Dict$RBNode_elm_builtin,
					0,
					lK,
					lV,
					A5($elm$core$Dict$RBNode_elm_builtin, 1, llK, llV, llLeft, llRight),
					A5($elm$core$Dict$RBNode_elm_builtin, 1, key, value, lRight, right));
			} else {
				return A5($elm$core$Dict$RBNode_elm_builtin, color, key, value, left, right);
			}
		}
	});
var $elm$core$Basics$compare = _Utils_compare;
var $elm$core$Dict$insertHelp = F3(
	function (key, value, dict) {
		if (dict.$ === -2) {
			return A5($elm$core$Dict$RBNode_elm_builtin, 0, key, value, $elm$core$Dict$RBEmpty_elm_builtin, $elm$core$Dict$RBEmpty_elm_builtin);
		} else {
			var nColor = dict.a;
			var nKey = dict.b;
			var nValue = dict.c;
			var nLeft = dict.d;
			var nRight = dict.e;
			var _v1 = A2($elm$core$Basics$compare, key, nKey);
			switch (_v1) {
				case 0:
					return A5(
						$elm$core$Dict$balance,
						nColor,
						nKey,
						nValue,
						A3($elm$core$Dict$insertHelp, key, value, nLeft),
						nRight);
				case 1:
					return A5($elm$core$Dict$RBNode_elm_builtin, nColor, nKey, value, nLeft, nRight);
				default:
					return A5(
						$elm$core$Dict$balance,
						nColor,
						nKey,
						nValue,
						nLeft,
						A3($elm$core$Dict$insertHelp, key, value, nRight));
			}
		}
	});
var $elm$core$Dict$insert = F3(
	function (key, value, dict) {
		var _v0 = A3($elm$core$Dict$insertHelp, key, value, dict);
		if ((_v0.$ === -1) && (!_v0.a)) {
			var _v1 = _v0.a;
			var k = _v0.b;
			var v = _v0.c;
			var l = _v0.d;
			var r = _v0.e;
			return A5($elm$core$Dict$RBNode_elm_builtin, 1, k, v, l, r);
		} else {
			var x = _v0;
			return x;
		}
	});
var $author$project$Dashboard$setMergePhase = F3(
	function (pr, phase, model) {
		return _Utils_update(
			model,
			{
				al: A3($elm$core$Dict$insert, pr, phase, model.al)
			});
	});
var $author$project$Dashboard$mergeFailed = function (pr) {
	return A2($author$project$Dashboard$setMergePhase, pr, 0);
};
var $author$project$Dashboard$Merged = 3;
var $author$project$Dashboard$mergeSucceeded = function (pr) {
	return A2($author$project$Dashboard$setMergePhase, pr, 3);
};
var $author$project$Dashboard$NotRequested = 0;
var $author$project$Dashboard$setPreviewState = F3(
	function (pr, state, model) {
		return _Utils_update(
			model,
			{
				an: A3($elm$core$Dict$insert, pr, state, model.an)
			});
	});
var $author$project$Dashboard$previewFailed = function (pr) {
	return A2($author$project$Dashboard$setPreviewState, pr, 0);
};
var $author$project$Dashboard$Opened = 2;
var $author$project$Dashboard$previewOpened = function (pr) {
	return A2($author$project$Dashboard$setPreviewState, pr, 2);
};
var $author$project$Dashboard$updateFailed = function (pr) {
	return A2($author$project$Dashboard$setMergePhase, pr, 3);
};
var $author$project$Dashboard$Updated = 5;
var $author$project$Dashboard$updateSucceeded = function (pr) {
	return A2($author$project$Dashboard$setMergePhase, pr, 5);
};
var $author$project$Main$applyActionResult = F2(
	function (result, dash) {
		var _v0 = _Utils_Tuple2(result.M, result.K);
		_v0$3:
		while (true) {
			switch (_v0.a) {
				case 'preview':
					if (!_v0.b.$) {
						var pr = _v0.b.a;
						return A2(
							result.ay ? $author$project$Dashboard$previewOpened : $author$project$Dashboard$previewFailed,
							pr,
							dash);
					} else {
						break _v0$3;
					}
				case 'merge':
					if (!_v0.b.$) {
						var pr = _v0.b.a;
						return A2(
							result.ay ? $author$project$Dashboard$mergeSucceeded : $author$project$Dashboard$mergeFailed,
							pr,
							dash);
					} else {
						break _v0$3;
					}
				case 'restart':
					var _v1 = result.K;
					if (!_v1.$) {
						var pr = _v1.a;
						return A2(
							result.ay ? $author$project$Dashboard$updateSucceeded : $author$project$Dashboard$updateFailed,
							pr,
							dash);
					} else {
						return dash;
					}
				default:
					break _v0$3;
			}
		}
		return dash;
	});
var $author$project$Dashboard$cancelMerge = function (pr) {
	return A2($author$project$Dashboard$setMergePhase, pr, 0);
};
var $author$project$Dashboard$Merging = 2;
var $author$project$Dashboard$confirmMerge = function (pr) {
	return A2($author$project$Dashboard$setMergePhase, pr, 2);
};
var $author$project$Contract$ContextSnapshot = F5(
	function (environment, network, console, events, errors) {
		return {a1: console, a8: environment, a9: errors, bb: events, br: network};
	});
var $author$project$Contract$ConsoleEntry = F4(
	function (id, timestamp, level, message) {
		return {B: id, bo: level, ax: message, D: timestamp};
	});
var $elm$json$Json$Decode$float = _Json_decodeFloat;
var $elm$json$Json$Decode$map4 = _Json_map4;
var $author$project$Contract$consoleEntryDecoder = A5(
	$elm$json$Json$Decode$map4,
	$author$project$Contract$ConsoleEntry,
	A2($elm$json$Json$Decode$field, 'id', $elm$json$Json$Decode$string),
	A2($elm$json$Json$Decode$field, 'timestamp', $elm$json$Json$Decode$float),
	A2($elm$json$Json$Decode$field, 'level', $elm$json$Json$Decode$string),
	A2($elm$json$Json$Decode$field, 'message', $elm$json$Json$Decode$string));
var $author$project$Contract$EnvironmentSnapshot = F5(
	function (url, referrer, viewport, userAgent, ref) {
		return {bF: ref, bG: referrer, at: url, b_: userAgent, b0: viewport};
	});
var $elm$json$Json$Decode$map5 = _Json_map5;
var $author$project$Contract$Viewport = F2(
	function (width, height) {
		return {bg: height, b2: width};
	});
var $author$project$Contract$viewportDecoder = A3(
	$elm$json$Json$Decode$map2,
	$author$project$Contract$Viewport,
	A2($elm$json$Json$Decode$field, 'width', $elm$json$Json$Decode$int),
	A2($elm$json$Json$Decode$field, 'height', $elm$json$Json$Decode$int));
var $author$project$Contract$environmentDecoder = A6(
	$elm$json$Json$Decode$map5,
	$author$project$Contract$EnvironmentSnapshot,
	A2($elm$json$Json$Decode$field, 'url', $elm$json$Json$Decode$string),
	A2($elm$json$Json$Decode$field, 'referrer', $elm$json$Json$Decode$string),
	A2($elm$json$Json$Decode$field, 'viewport', $author$project$Contract$viewportDecoder),
	A2($elm$json$Json$Decode$field, 'userAgent', $elm$json$Json$Decode$string),
	$elm$json$Json$Decode$maybe(
		A2($elm$json$Json$Decode$field, 'ref', $elm$json$Json$Decode$string)));
var $author$project$Contract$ErrorEntry = F4(
	function (id, timestamp, message, stack) {
		return {B: id, ax: message, bS: stack, D: timestamp};
	});
var $author$project$Contract$optionalString = function (name) {
	return $elm$json$Json$Decode$maybe(
		A2($elm$json$Json$Decode$field, name, $elm$json$Json$Decode$string));
};
var $author$project$Contract$errorEntryDecoder = A5(
	$elm$json$Json$Decode$map4,
	$author$project$Contract$ErrorEntry,
	A2($elm$json$Json$Decode$field, 'id', $elm$json$Json$Decode$string),
	A2($elm$json$Json$Decode$field, 'timestamp', $elm$json$Json$Decode$float),
	A2($elm$json$Json$Decode$field, 'message', $elm$json$Json$Decode$string),
	$author$project$Contract$optionalString('stack'));
var $author$project$Contract$EventEntry = F5(
	function (id, timestamp, type_, selector, value) {
		return {B: id, bP: selector, D: timestamp, bZ: type_, b$: value};
	});
var $author$project$Contract$eventEntryDecoder = A6(
	$elm$json$Json$Decode$map5,
	$author$project$Contract$EventEntry,
	A2($elm$json$Json$Decode$field, 'id', $elm$json$Json$Decode$string),
	A2($elm$json$Json$Decode$field, 'timestamp', $elm$json$Json$Decode$float),
	A2($elm$json$Json$Decode$field, 'type', $elm$json$Json$Decode$string),
	A2($elm$json$Json$Decode$field, 'selector', $elm$json$Json$Decode$string),
	$author$project$Contract$optionalString('value'));
var $elm$json$Json$Decode$list = _Json_decodeList;
var $elm$json$Json$Decode$andThen = _Json_andThen;
var $elm$core$Dict$empty = $elm$core$Dict$RBEmpty_elm_builtin;
var $elm$core$Dict$fromList = function (assocs) {
	return A3(
		$elm$core$List$foldl,
		F2(
			function (_v0, dict) {
				var key = _v0.a;
				var value = _v0.b;
				return A3($elm$core$Dict$insert, key, value, dict);
			}),
		$elm$core$Dict$empty,
		assocs);
};
var $elm$json$Json$Decode$keyValuePairs = _Json_decodeKeyValuePairs;
var $elm$json$Json$Decode$dict = function (decoder) {
	return A2(
		$elm$json$Json$Decode$map,
		$elm$core$Dict$fromList,
		$elm$json$Json$Decode$keyValuePairs(decoder));
};
var $elm$json$Json$Decode$map8 = _Json_map8;
var $elm$json$Json$Decode$nullable = function (decoder) {
	return $elm$json$Json$Decode$oneOf(
		_List_fromArray(
			[
				$elm$json$Json$Decode$null($elm$core$Maybe$Nothing),
				A2($elm$json$Json$Decode$map, $elm$core$Maybe$Just, decoder)
			]));
};
var $author$project$Contract$networkEntryDecoder = A2(
	$elm$json$Json$Decode$andThen,
	function (partial) {
		return A2(
			$elm$json$Json$Decode$map,
			function (rb) {
				return _Utils_update(
					partial,
					{az: rb});
			},
			$author$project$Contract$optionalString('responseBody'));
	},
	A9(
		$elm$json$Json$Decode$map8,
		F8(
			function (id, timestamp, method, url, status, durationMs, headers, reqBody) {
				return {aG: durationMs, aI: headers, B: id, aL: method, aP: reqBody, az: $elm$core$Maybe$Nothing, aS: status, D: timestamp, at: url};
			}),
		A2($elm$json$Json$Decode$field, 'id', $elm$json$Json$Decode$string),
		A2($elm$json$Json$Decode$field, 'timestamp', $elm$json$Json$Decode$float),
		A2($elm$json$Json$Decode$field, 'method', $elm$json$Json$Decode$string),
		A2($elm$json$Json$Decode$field, 'url', $elm$json$Json$Decode$string),
		A2(
			$elm$json$Json$Decode$field,
			'status',
			$elm$json$Json$Decode$nullable($elm$json$Json$Decode$int)),
		A2(
			$elm$json$Json$Decode$field,
			'durationMs',
			$elm$json$Json$Decode$nullable($elm$json$Json$Decode$float)),
		A2(
			$elm$json$Json$Decode$field,
			'headers',
			$elm$json$Json$Decode$dict($elm$json$Json$Decode$string)),
		$author$project$Contract$optionalString('requestBody')));
var $author$project$Contract$contextDecoder = A6(
	$elm$json$Json$Decode$map5,
	$author$project$Contract$ContextSnapshot,
	A2($elm$json$Json$Decode$field, 'environment', $author$project$Contract$environmentDecoder),
	A2(
		$elm$json$Json$Decode$field,
		'network',
		$elm$json$Json$Decode$list($author$project$Contract$networkEntryDecoder)),
	A2(
		$elm$json$Json$Decode$field,
		'console',
		$elm$json$Json$Decode$list($author$project$Contract$consoleEntryDecoder)),
	A2(
		$elm$json$Json$Decode$field,
		'events',
		$elm$json$Json$Decode$list($author$project$Contract$eventEntryDecoder)),
	A2(
		$elm$json$Json$Decode$field,
		'errors',
		$elm$json$Json$Decode$list($author$project$Contract$errorEntryDecoder)));
var $elm$json$Json$Decode$decodeValue = _Json_run;
var $elm$json$Json$Encode$float = _Json_wrap;
var $elm$json$Json$Encode$object = function (pairs) {
	return _Json_wrap(
		A3(
			$elm$core$List$foldl,
			F2(
				function (_v0, obj) {
					var k = _v0.a;
					var v = _v0.b;
					return A3(_Json_addField, k, v, obj);
				}),
			_Json_emptyObject(0),
			pairs));
};
var $elm$json$Json$Encode$string = _Json_wrap;
var $author$project$Contract$encodeConsoleEntry = function (c) {
	return $elm$json$Json$Encode$object(
		_List_fromArray(
			[
				_Utils_Tuple2(
				'id',
				$elm$json$Json$Encode$string(c.B)),
				_Utils_Tuple2(
				'timestamp',
				$elm$json$Json$Encode$float(c.D)),
				_Utils_Tuple2(
				'level',
				$elm$json$Json$Encode$string(c.bo)),
				_Utils_Tuple2(
				'message',
				$elm$json$Json$Encode$string(c.ax))
			]));
};
var $elm$json$Json$Encode$int = _Json_wrap;
var $author$project$Contract$encodeViewport = function (v) {
	return $elm$json$Json$Encode$object(
		_List_fromArray(
			[
				_Utils_Tuple2(
				'width',
				$elm$json$Json$Encode$int(v.b2)),
				_Utils_Tuple2(
				'height',
				$elm$json$Json$Encode$int(v.bg))
			]));
};
var $author$project$Contract$encodeEnvironment = function (e) {
	return $elm$json$Json$Encode$object(
		_Utils_ap(
			_List_fromArray(
				[
					_Utils_Tuple2(
					'url',
					$elm$json$Json$Encode$string(e.at)),
					_Utils_Tuple2(
					'referrer',
					$elm$json$Json$Encode$string(e.bG)),
					_Utils_Tuple2(
					'viewport',
					$author$project$Contract$encodeViewport(e.b0)),
					_Utils_Tuple2(
					'userAgent',
					$elm$json$Json$Encode$string(e.b_))
				]),
			function () {
				var _v0 = e.bF;
				if (_v0.$ === 1) {
					return _List_Nil;
				} else {
					var r = _v0.a;
					return _List_fromArray(
						[
							_Utils_Tuple2(
							'ref',
							$elm$json$Json$Encode$string(r))
						]);
				}
			}()));
};
var $elm$json$Json$Encode$null = _Json_encodeNull;
var $author$project$Contract$encodeMaybe = F2(
	function (f, m) {
		if (m.$ === 1) {
			return $elm$json$Json$Encode$null;
		} else {
			var v = m.a;
			return f(v);
		}
	});
var $author$project$Contract$encodeErrorEntry = function (e) {
	return $elm$json$Json$Encode$object(
		_List_fromArray(
			[
				_Utils_Tuple2(
				'id',
				$elm$json$Json$Encode$string(e.B)),
				_Utils_Tuple2(
				'timestamp',
				$elm$json$Json$Encode$float(e.D)),
				_Utils_Tuple2(
				'message',
				$elm$json$Json$Encode$string(e.ax)),
				_Utils_Tuple2(
				'stack',
				A2($author$project$Contract$encodeMaybe, $elm$json$Json$Encode$string, e.bS))
			]));
};
var $author$project$Contract$encodeEventEntry = function (e) {
	return $elm$json$Json$Encode$object(
		_List_fromArray(
			[
				_Utils_Tuple2(
				'id',
				$elm$json$Json$Encode$string(e.B)),
				_Utils_Tuple2(
				'timestamp',
				$elm$json$Json$Encode$float(e.D)),
				_Utils_Tuple2(
				'type',
				$elm$json$Json$Encode$string(e.bZ)),
				_Utils_Tuple2(
				'selector',
				$elm$json$Json$Encode$string(e.bP)),
				_Utils_Tuple2(
				'value',
				A2($author$project$Contract$encodeMaybe, $elm$json$Json$Encode$string, e.b$))
			]));
};
var $elm$core$Dict$foldl = F3(
	function (func, acc, dict) {
		foldl:
		while (true) {
			if (dict.$ === -2) {
				return acc;
			} else {
				var key = dict.b;
				var value = dict.c;
				var left = dict.d;
				var right = dict.e;
				var $temp$func = func,
					$temp$acc = A3(
					func,
					key,
					value,
					A3($elm$core$Dict$foldl, func, acc, left)),
					$temp$dict = right;
				func = $temp$func;
				acc = $temp$acc;
				dict = $temp$dict;
				continue foldl;
			}
		}
	});
var $elm$json$Json$Encode$dict = F3(
	function (toKey, toValue, dictionary) {
		return _Json_wrap(
			A3(
				$elm$core$Dict$foldl,
				F3(
					function (key, value, obj) {
						return A3(
							_Json_addField,
							toKey(key),
							toValue(value),
							obj);
					}),
				_Json_emptyObject(0),
				dictionary));
	});
var $author$project$Contract$encodeNetworkEntry = function (n) {
	return $elm$json$Json$Encode$object(
		_List_fromArray(
			[
				_Utils_Tuple2(
				'id',
				$elm$json$Json$Encode$string(n.B)),
				_Utils_Tuple2(
				'timestamp',
				$elm$json$Json$Encode$float(n.D)),
				_Utils_Tuple2(
				'method',
				$elm$json$Json$Encode$string(n.aL)),
				_Utils_Tuple2(
				'url',
				$elm$json$Json$Encode$string(n.at)),
				_Utils_Tuple2(
				'status',
				A2($author$project$Contract$encodeMaybe, $elm$json$Json$Encode$int, n.aS)),
				_Utils_Tuple2(
				'durationMs',
				A2($author$project$Contract$encodeMaybe, $elm$json$Json$Encode$float, n.aG)),
				_Utils_Tuple2(
				'headers',
				A3($elm$json$Json$Encode$dict, $elm$core$Basics$identity, $elm$json$Json$Encode$string, n.aI)),
				_Utils_Tuple2(
				'requestBody',
				A2($author$project$Contract$encodeMaybe, $elm$json$Json$Encode$string, n.aP)),
				_Utils_Tuple2(
				'responseBody',
				A2($author$project$Contract$encodeMaybe, $elm$json$Json$Encode$string, n.az))
			]));
};
var $elm$json$Json$Encode$list = F2(
	function (func, entries) {
		return _Json_wrap(
			A3(
				$elm$core$List$foldl,
				_Json_addEntry(func),
				_Json_emptyArray(0),
				entries));
	});
var $author$project$Contract$encodeContext = function (ctx) {
	return $elm$json$Json$Encode$object(
		_List_fromArray(
			[
				_Utils_Tuple2(
				'environment',
				$author$project$Contract$encodeEnvironment(ctx.a8)),
				_Utils_Tuple2(
				'network',
				A2($elm$json$Json$Encode$list, $author$project$Contract$encodeNetworkEntry, ctx.br)),
				_Utils_Tuple2(
				'console',
				A2($elm$json$Json$Encode$list, $author$project$Contract$encodeConsoleEntry, ctx.a1)),
				_Utils_Tuple2(
				'events',
				A2($elm$json$Json$Encode$list, $author$project$Contract$encodeEventEntry, ctx.bb)),
				_Utils_Tuple2(
				'errors',
				A2($elm$json$Json$Encode$list, $author$project$Contract$encodeErrorEntry, ctx.a9))
			]));
};
var $author$project$Contract$encodeSubmit = function (p) {
	return $elm$json$Json$Encode$object(
		_List_fromArray(
			[
				_Utils_Tuple2(
				'title',
				$elm$json$Json$Encode$string(p.bX)),
				_Utils_Tuple2(
				'description',
				$elm$json$Json$Encode$string(p.a5)),
				_Utils_Tuple2(
				'includedContext',
				$author$project$Contract$encodeContext(p.bi))
			]));
};
var $elm$json$Json$Encode$bool = _Json_wrap;
var $author$project$Main$formOpened = _Platform_outgoingPort('formOpened', $elm$json$Json$Encode$bool);
var $elm$core$Set$Set_elm_builtin = $elm$core$Basics$identity;
var $elm$core$Set$empty = $elm$core$Dict$empty;
var $author$project$Curation$init = function (snapshot) {
	return {a5: '', H: $elm$core$Set$empty, A: $elm$core$Set$empty, T: snapshot, bX: ''};
};
var $author$project$Dashboard$init = function (s) {
	return {al: $elm$core$Dict$empty, an: $elm$core$Dict$empty, aS: s};
};
var $elm$core$Maybe$map = F2(
	function (f, maybe) {
		if (!maybe.$) {
			var value = maybe.a;
			return $elm$core$Maybe$Just(
				f(value));
		} else {
			return $elm$core$Maybe$Nothing;
		}
	});
var $author$project$Main$mapDashboard = F2(
	function (f, model) {
		return _Utils_update(
			model,
			{
				G: A2($elm$core$Maybe$map, f, model.G)
			});
	});
var $author$project$Main$dashboardAction = _Platform_outgoingPort('dashboardAction', $elm$core$Basics$identity);
var $author$project$Main$encodeAction = function (a) {
	return $elm$json$Json$Encode$object(
		A2(
			$elm$core$List$cons,
			_Utils_Tuple2(
				'action',
				$elm$json$Json$Encode$string(a.M)),
			_Utils_ap(
				function () {
					var _v0 = a.K;
					if (!_v0.$) {
						var n = _v0.a;
						return _List_fromArray(
							[
								_Utils_Tuple2(
								'pr',
								$elm$json$Json$Encode$int(n))
							]);
					} else {
						return _List_Nil;
					}
				}(),
				function () {
					var _v1 = a.at;
					if (!_v1.$) {
						var u = _v1.a;
						return _List_fromArray(
							[
								_Utils_Tuple2(
								'url',
								$elm$json$Json$Encode$string(u))
							]);
					} else {
						return _List_Nil;
					}
				}())));
};
var $author$project$Main$mergeAction = function (pr) {
	return $author$project$Main$dashboardAction(
		$author$project$Main$encodeAction(
			{
				M: 'merge',
				K: $elm$core$Maybe$Just(pr),
				at: $elm$core$Maybe$Nothing
			}));
};
var $author$project$Main$openAppAction = function (url) {
	return $author$project$Main$dashboardAction(
		$author$project$Main$encodeAction(
			{
				M: 'openApp',
				K: $elm$core$Maybe$Nothing,
				at: $elm$core$Maybe$Just(url)
			}));
};
var $author$project$Main$previewAction = function (pr) {
	return $author$project$Main$dashboardAction(
		$author$project$Main$encodeAction(
			{
				M: 'preview',
				K: $elm$core$Maybe$Just(pr),
				at: $elm$core$Maybe$Nothing
			}));
};
var $author$project$Dashboard$reconcile = F2(
	function (s, model) {
		return _Utils_update(
			model,
			{aS: s});
	});
var $author$project$Dashboard$Confirming = 1;
var $author$project$Dashboard$requestMerge = function (pr) {
	return A2($author$project$Dashboard$setMergePhase, pr, 1);
};
var $author$project$Dashboard$Opening = 1;
var $author$project$Dashboard$requestPreview = function (pr) {
	return A2($author$project$Dashboard$setPreviewState, pr, 1);
};
var $author$project$Main$requestScreenshot = _Platform_outgoingPort(
	'requestScreenshot',
	function ($) {
		return $elm$json$Json$Encode$null;
	});
var $author$project$Dashboard$Updating = 4;
var $author$project$Dashboard$requestUpdate = function (pr) {
	return A2($author$project$Dashboard$setMergePhase, pr, 4);
};
var $author$project$Main$requestUpload = _Platform_outgoingPort(
	'requestUpload',
	function ($) {
		return $elm$json$Json$Encode$null;
	});
var $author$project$Main$restartAction = function (pr) {
	return $author$project$Main$dashboardAction(
		$author$project$Main$encodeAction(
			{
				M: 'restart',
				K: $elm$core$Maybe$Just(pr),
				at: $elm$core$Maybe$Nothing
			}));
};
var $author$project$Main$setHidden = _Platform_outgoingPort('setHidden', $elm$json$Json$Encode$bool);
var $author$project$Dashboard$AppStatus = F4(
	function (app, counts, workers, prs) {
		return {b8: app, ch: counts, bD: prs, b3: workers};
	});
var $author$project$Dashboard$AppInfo = F7(
	function (id, name, running, port_, serveUrl, startedAt, health) {
		return {cr: health, B: id, cC: name, cR: port_, cZ: running, c_: serveUrl, c$: startedAt};
	});
var $author$project$Dashboard$intField = function (name) {
	return $elm$json$Json$Decode$oneOf(
		_List_fromArray(
			[
				A2($elm$json$Json$Decode$field, name, $elm$json$Json$Decode$int),
				$elm$json$Json$Decode$succeed(0)
			]));
};
var $elm$json$Json$Decode$map7 = _Json_map7;
var $author$project$Dashboard$appInfoDecoder = A8(
	$elm$json$Json$Decode$map7,
	$author$project$Dashboard$AppInfo,
	$elm$json$Json$Decode$maybe(
		A2($elm$json$Json$Decode$field, 'id', $elm$json$Json$Decode$string)),
	A2($elm$json$Json$Decode$field, 'name', $elm$json$Json$Decode$string),
	$elm$json$Json$Decode$oneOf(
		_List_fromArray(
			[
				A2($elm$json$Json$Decode$field, 'running', $elm$json$Json$Decode$bool),
				$elm$json$Json$Decode$succeed(false)
			])),
	$author$project$Dashboard$intField('port'),
	$elm$json$Json$Decode$oneOf(
		_List_fromArray(
			[
				A2($elm$json$Json$Decode$field, 'serveUrl', $elm$json$Json$Decode$string),
				$elm$json$Json$Decode$succeed('')
			])),
	$elm$json$Json$Decode$oneOf(
		_List_fromArray(
			[
				A2($elm$json$Json$Decode$field, 'startedAt', $elm$json$Json$Decode$string),
				$elm$json$Json$Decode$succeed('')
			])),
	$elm$json$Json$Decode$oneOf(
		_List_fromArray(
			[
				A2($elm$json$Json$Decode$field, 'health', $elm$json$Json$Decode$string),
				$elm$json$Json$Decode$succeed('')
			])));
var $author$project$Dashboard$Counts = F3(
	function (openIssues, recentFeedback, workers) {
		return {cP: openIssues, cT: recentFeedback, b3: workers};
	});
var $author$project$Dashboard$countsDecoder = A4(
	$elm$json$Json$Decode$map3,
	$author$project$Dashboard$Counts,
	$author$project$Dashboard$intField('openIssues'),
	$author$project$Dashboard$intField('recentFeedback'),
	$author$project$Dashboard$intField('workers'));
var $author$project$Dashboard$None_ = 0;
var $author$project$Dashboard$PullRequest = F6(
	function (number, title, state, mergeable, isDraft, preview) {
		return {bk: isDraft, bp: mergeable, cL: number, cS: preview, c0: state, bX: title};
	});
var $elm$json$Json$Decode$map6 = _Json_map6;
var $author$project$Dashboard$PrPreview = F2(
	function (status, url) {
		return {aS: status, at: url};
	});
var $author$project$Dashboard$Building = 1;
var $author$project$Dashboard$Closed = 3;
var $author$project$Dashboard$Warm = 2;
var $author$project$Dashboard$previewStatusDecoder = A2(
	$elm$json$Json$Decode$map,
	function (s) {
		switch (s) {
			case 'building':
				return 1;
			case 'warm':
				return 2;
			case 'closed':
				return 3;
			default:
				return 0;
		}
	},
	$elm$json$Json$Decode$string);
var $author$project$Dashboard$previewDecoder = A3(
	$elm$json$Json$Decode$map2,
	$author$project$Dashboard$PrPreview,
	$elm$json$Json$Decode$oneOf(
		_List_fromArray(
			[
				A2($elm$json$Json$Decode$field, 'status', $author$project$Dashboard$previewStatusDecoder),
				$elm$json$Json$Decode$succeed(0)
			])),
	$elm$json$Json$Decode$oneOf(
		_List_fromArray(
			[
				A2($elm$json$Json$Decode$field, 'url', $elm$json$Json$Decode$string),
				$elm$json$Json$Decode$succeed('')
			])));
var $author$project$Dashboard$prDecoder = A7(
	$elm$json$Json$Decode$map6,
	$author$project$Dashboard$PullRequest,
	A2($elm$json$Json$Decode$field, 'number', $elm$json$Json$Decode$int),
	A2($elm$json$Json$Decode$field, 'title', $elm$json$Json$Decode$string),
	$elm$json$Json$Decode$oneOf(
		_List_fromArray(
			[
				A2($elm$json$Json$Decode$field, 'state', $elm$json$Json$Decode$string),
				$elm$json$Json$Decode$succeed('open')
			])),
	$elm$json$Json$Decode$oneOf(
		_List_fromArray(
			[
				A2($elm$json$Json$Decode$field, 'mergeable', $elm$json$Json$Decode$bool),
				$elm$json$Json$Decode$succeed(false)
			])),
	$elm$json$Json$Decode$oneOf(
		_List_fromArray(
			[
				A2($elm$json$Json$Decode$field, 'isDraft', $elm$json$Json$Decode$bool),
				$elm$json$Json$Decode$succeed(false)
			])),
	$elm$json$Json$Decode$oneOf(
		_List_fromArray(
			[
				A2($elm$json$Json$Decode$field, 'preview', $author$project$Dashboard$previewDecoder),
				$elm$json$Json$Decode$succeed(
				{aS: 0, at: ''})
			])));
var $author$project$Dashboard$Worker = F3(
	function (issue, branch, status) {
		return {cd: branch, cw: issue, aS: status};
	});
var $author$project$Dashboard$workerDecoder = A4(
	$elm$json$Json$Decode$map3,
	$author$project$Dashboard$Worker,
	A2($elm$json$Json$Decode$field, 'issue', $elm$json$Json$Decode$int),
	$elm$json$Json$Decode$oneOf(
		_List_fromArray(
			[
				A2($elm$json$Json$Decode$field, 'branch', $elm$json$Json$Decode$string),
				$elm$json$Json$Decode$succeed('')
			])),
	$elm$json$Json$Decode$oneOf(
		_List_fromArray(
			[
				A2($elm$json$Json$Decode$field, 'status', $elm$json$Json$Decode$string),
				$elm$json$Json$Decode$succeed('')
			])));
var $author$project$Dashboard$statusDecoder = A5(
	$elm$json$Json$Decode$map4,
	$author$project$Dashboard$AppStatus,
	A2($elm$json$Json$Decode$field, 'app', $author$project$Dashboard$appInfoDecoder),
	A2($elm$json$Json$Decode$field, 'counts', $author$project$Dashboard$countsDecoder),
	$elm$json$Json$Decode$oneOf(
		_List_fromArray(
			[
				A2(
				$elm$json$Json$Decode$field,
				'workers',
				$elm$json$Json$Decode$list($author$project$Dashboard$workerDecoder)),
				$elm$json$Json$Decode$succeed(_List_Nil)
			])),
	$elm$json$Json$Decode$oneOf(
		_List_fromArray(
			[
				A2(
				$elm$json$Json$Decode$field,
				'prs',
				$elm$json$Json$Decode$list($author$project$Dashboard$prDecoder)),
				$elm$json$Json$Decode$succeed(_List_Nil)
			])));
var $author$project$Main$submit = _Platform_outgoingPort('submit', $elm$core$Basics$identity);
var $author$project$Curation$ConsoleCategory = 1;
var $author$project$Curation$ErrorsCategory = 3;
var $author$project$Curation$EventsCategory = 2;
var $author$project$Curation$NetworkCategory = 0;
var $elm$core$List$filter = F2(
	function (isGood, list) {
		return A3(
			$elm$core$List$foldr,
			F2(
				function (x, xs) {
					return isGood(x) ? A2($elm$core$List$cons, x, xs) : xs;
				}),
			_List_Nil,
			list);
	});
var $author$project$Curation$categoryKey = function (cat) {
	switch (cat) {
		case 0:
			return 'network';
		case 1:
			return 'console';
		case 2:
			return 'events';
		default:
			return 'errors';
	}
};
var $elm$core$Dict$get = F2(
	function (targetKey, dict) {
		get:
		while (true) {
			if (dict.$ === -2) {
				return $elm$core$Maybe$Nothing;
			} else {
				var key = dict.b;
				var value = dict.c;
				var left = dict.d;
				var right = dict.e;
				var _v1 = A2($elm$core$Basics$compare, targetKey, key);
				switch (_v1) {
					case 0:
						var $temp$targetKey = targetKey,
							$temp$dict = left;
						targetKey = $temp$targetKey;
						dict = $temp$dict;
						continue get;
					case 1:
						return $elm$core$Maybe$Just(value);
					default:
						var $temp$targetKey = targetKey,
							$temp$dict = right;
						targetKey = $temp$targetKey;
						dict = $temp$dict;
						continue get;
				}
			}
		}
	});
var $elm$core$Dict$member = F2(
	function (key, dict) {
		var _v0 = A2($elm$core$Dict$get, key, dict);
		if (!_v0.$) {
			return true;
		} else {
			return false;
		}
	});
var $elm$core$Set$member = F2(
	function (key, _v0) {
		var dict = _v0;
		return A2($elm$core$Dict$member, key, dict);
	});
var $elm$core$Basics$not = _Basics_not;
var $author$project$Curation$isCategoryEnabled = F2(
	function (cat, model) {
		return !A2(
			$elm$core$Set$member,
			$author$project$Curation$categoryKey(cat),
			model.H);
	});
var $author$project$Curation$includedContext = function (model) {
	var keepIf = F2(
		function (cat, items) {
			return A2($author$project$Curation$isCategoryEnabled, cat, model) ? A2(
				$elm$core$List$filter,
				function (item) {
					return !A2($elm$core$Set$member, item.B, model.A);
				},
				items) : _List_Nil;
		});
	return {
		a1: A2(keepIf, 1, model.T.a1),
		a8: model.T.a8,
		a9: A2(keepIf, 3, model.T.a9),
		bb: A2(keepIf, 2, model.T.bb),
		br: A2(keepIf, 0, model.T.br)
	};
};
var $author$project$Curation$toPayload = function (model) {
	return {
		a5: model.a5,
		bi: $author$project$Curation$includedContext(model),
		bX: model.bX
	};
};
var $elm$core$Set$insert = F2(
	function (key, _v0) {
		var dict = _v0;
		return A3($elm$core$Dict$insert, key, 0, dict);
	});
var $elm$core$Dict$getMin = function (dict) {
	getMin:
	while (true) {
		if ((dict.$ === -1) && (dict.d.$ === -1)) {
			var left = dict.d;
			var $temp$dict = left;
			dict = $temp$dict;
			continue getMin;
		} else {
			return dict;
		}
	}
};
var $elm$core$Dict$moveRedLeft = function (dict) {
	if (((dict.$ === -1) && (dict.d.$ === -1)) && (dict.e.$ === -1)) {
		if ((dict.e.d.$ === -1) && (!dict.e.d.a)) {
			var clr = dict.a;
			var k = dict.b;
			var v = dict.c;
			var _v1 = dict.d;
			var lClr = _v1.a;
			var lK = _v1.b;
			var lV = _v1.c;
			var lLeft = _v1.d;
			var lRight = _v1.e;
			var _v2 = dict.e;
			var rClr = _v2.a;
			var rK = _v2.b;
			var rV = _v2.c;
			var rLeft = _v2.d;
			var _v3 = rLeft.a;
			var rlK = rLeft.b;
			var rlV = rLeft.c;
			var rlL = rLeft.d;
			var rlR = rLeft.e;
			var rRight = _v2.e;
			return A5(
				$elm$core$Dict$RBNode_elm_builtin,
				0,
				rlK,
				rlV,
				A5(
					$elm$core$Dict$RBNode_elm_builtin,
					1,
					k,
					v,
					A5($elm$core$Dict$RBNode_elm_builtin, 0, lK, lV, lLeft, lRight),
					rlL),
				A5($elm$core$Dict$RBNode_elm_builtin, 1, rK, rV, rlR, rRight));
		} else {
			var clr = dict.a;
			var k = dict.b;
			var v = dict.c;
			var _v4 = dict.d;
			var lClr = _v4.a;
			var lK = _v4.b;
			var lV = _v4.c;
			var lLeft = _v4.d;
			var lRight = _v4.e;
			var _v5 = dict.e;
			var rClr = _v5.a;
			var rK = _v5.b;
			var rV = _v5.c;
			var rLeft = _v5.d;
			var rRight = _v5.e;
			if (clr === 1) {
				return A5(
					$elm$core$Dict$RBNode_elm_builtin,
					1,
					k,
					v,
					A5($elm$core$Dict$RBNode_elm_builtin, 0, lK, lV, lLeft, lRight),
					A5($elm$core$Dict$RBNode_elm_builtin, 0, rK, rV, rLeft, rRight));
			} else {
				return A5(
					$elm$core$Dict$RBNode_elm_builtin,
					1,
					k,
					v,
					A5($elm$core$Dict$RBNode_elm_builtin, 0, lK, lV, lLeft, lRight),
					A5($elm$core$Dict$RBNode_elm_builtin, 0, rK, rV, rLeft, rRight));
			}
		}
	} else {
		return dict;
	}
};
var $elm$core$Dict$moveRedRight = function (dict) {
	if (((dict.$ === -1) && (dict.d.$ === -1)) && (dict.e.$ === -1)) {
		if ((dict.d.d.$ === -1) && (!dict.d.d.a)) {
			var clr = dict.a;
			var k = dict.b;
			var v = dict.c;
			var _v1 = dict.d;
			var lClr = _v1.a;
			var lK = _v1.b;
			var lV = _v1.c;
			var _v2 = _v1.d;
			var _v3 = _v2.a;
			var llK = _v2.b;
			var llV = _v2.c;
			var llLeft = _v2.d;
			var llRight = _v2.e;
			var lRight = _v1.e;
			var _v4 = dict.e;
			var rClr = _v4.a;
			var rK = _v4.b;
			var rV = _v4.c;
			var rLeft = _v4.d;
			var rRight = _v4.e;
			return A5(
				$elm$core$Dict$RBNode_elm_builtin,
				0,
				lK,
				lV,
				A5($elm$core$Dict$RBNode_elm_builtin, 1, llK, llV, llLeft, llRight),
				A5(
					$elm$core$Dict$RBNode_elm_builtin,
					1,
					k,
					v,
					lRight,
					A5($elm$core$Dict$RBNode_elm_builtin, 0, rK, rV, rLeft, rRight)));
		} else {
			var clr = dict.a;
			var k = dict.b;
			var v = dict.c;
			var _v5 = dict.d;
			var lClr = _v5.a;
			var lK = _v5.b;
			var lV = _v5.c;
			var lLeft = _v5.d;
			var lRight = _v5.e;
			var _v6 = dict.e;
			var rClr = _v6.a;
			var rK = _v6.b;
			var rV = _v6.c;
			var rLeft = _v6.d;
			var rRight = _v6.e;
			if (clr === 1) {
				return A5(
					$elm$core$Dict$RBNode_elm_builtin,
					1,
					k,
					v,
					A5($elm$core$Dict$RBNode_elm_builtin, 0, lK, lV, lLeft, lRight),
					A5($elm$core$Dict$RBNode_elm_builtin, 0, rK, rV, rLeft, rRight));
			} else {
				return A5(
					$elm$core$Dict$RBNode_elm_builtin,
					1,
					k,
					v,
					A5($elm$core$Dict$RBNode_elm_builtin, 0, lK, lV, lLeft, lRight),
					A5($elm$core$Dict$RBNode_elm_builtin, 0, rK, rV, rLeft, rRight));
			}
		}
	} else {
		return dict;
	}
};
var $elm$core$Dict$removeHelpPrepEQGT = F7(
	function (targetKey, dict, color, key, value, left, right) {
		if ((left.$ === -1) && (!left.a)) {
			var _v1 = left.a;
			var lK = left.b;
			var lV = left.c;
			var lLeft = left.d;
			var lRight = left.e;
			return A5(
				$elm$core$Dict$RBNode_elm_builtin,
				color,
				lK,
				lV,
				lLeft,
				A5($elm$core$Dict$RBNode_elm_builtin, 0, key, value, lRight, right));
		} else {
			_v2$2:
			while (true) {
				if ((right.$ === -1) && (right.a === 1)) {
					if (right.d.$ === -1) {
						if (right.d.a === 1) {
							var _v3 = right.a;
							var _v4 = right.d;
							var _v5 = _v4.a;
							return $elm$core$Dict$moveRedRight(dict);
						} else {
							break _v2$2;
						}
					} else {
						var _v6 = right.a;
						var _v7 = right.d;
						return $elm$core$Dict$moveRedRight(dict);
					}
				} else {
					break _v2$2;
				}
			}
			return dict;
		}
	});
var $elm$core$Dict$removeMin = function (dict) {
	if ((dict.$ === -1) && (dict.d.$ === -1)) {
		var color = dict.a;
		var key = dict.b;
		var value = dict.c;
		var left = dict.d;
		var lColor = left.a;
		var lLeft = left.d;
		var right = dict.e;
		if (lColor === 1) {
			if ((lLeft.$ === -1) && (!lLeft.a)) {
				var _v3 = lLeft.a;
				return A5(
					$elm$core$Dict$RBNode_elm_builtin,
					color,
					key,
					value,
					$elm$core$Dict$removeMin(left),
					right);
			} else {
				var _v4 = $elm$core$Dict$moveRedLeft(dict);
				if (_v4.$ === -1) {
					var nColor = _v4.a;
					var nKey = _v4.b;
					var nValue = _v4.c;
					var nLeft = _v4.d;
					var nRight = _v4.e;
					return A5(
						$elm$core$Dict$balance,
						nColor,
						nKey,
						nValue,
						$elm$core$Dict$removeMin(nLeft),
						nRight);
				} else {
					return $elm$core$Dict$RBEmpty_elm_builtin;
				}
			}
		} else {
			return A5(
				$elm$core$Dict$RBNode_elm_builtin,
				color,
				key,
				value,
				$elm$core$Dict$removeMin(left),
				right);
		}
	} else {
		return $elm$core$Dict$RBEmpty_elm_builtin;
	}
};
var $elm$core$Dict$removeHelp = F2(
	function (targetKey, dict) {
		if (dict.$ === -2) {
			return $elm$core$Dict$RBEmpty_elm_builtin;
		} else {
			var color = dict.a;
			var key = dict.b;
			var value = dict.c;
			var left = dict.d;
			var right = dict.e;
			if (_Utils_cmp(targetKey, key) < 0) {
				if ((left.$ === -1) && (left.a === 1)) {
					var _v4 = left.a;
					var lLeft = left.d;
					if ((lLeft.$ === -1) && (!lLeft.a)) {
						var _v6 = lLeft.a;
						return A5(
							$elm$core$Dict$RBNode_elm_builtin,
							color,
							key,
							value,
							A2($elm$core$Dict$removeHelp, targetKey, left),
							right);
					} else {
						var _v7 = $elm$core$Dict$moveRedLeft(dict);
						if (_v7.$ === -1) {
							var nColor = _v7.a;
							var nKey = _v7.b;
							var nValue = _v7.c;
							var nLeft = _v7.d;
							var nRight = _v7.e;
							return A5(
								$elm$core$Dict$balance,
								nColor,
								nKey,
								nValue,
								A2($elm$core$Dict$removeHelp, targetKey, nLeft),
								nRight);
						} else {
							return $elm$core$Dict$RBEmpty_elm_builtin;
						}
					}
				} else {
					return A5(
						$elm$core$Dict$RBNode_elm_builtin,
						color,
						key,
						value,
						A2($elm$core$Dict$removeHelp, targetKey, left),
						right);
				}
			} else {
				return A2(
					$elm$core$Dict$removeHelpEQGT,
					targetKey,
					A7($elm$core$Dict$removeHelpPrepEQGT, targetKey, dict, color, key, value, left, right));
			}
		}
	});
var $elm$core$Dict$removeHelpEQGT = F2(
	function (targetKey, dict) {
		if (dict.$ === -1) {
			var color = dict.a;
			var key = dict.b;
			var value = dict.c;
			var left = dict.d;
			var right = dict.e;
			if (_Utils_eq(targetKey, key)) {
				var _v1 = $elm$core$Dict$getMin(right);
				if (_v1.$ === -1) {
					var minKey = _v1.b;
					var minValue = _v1.c;
					return A5(
						$elm$core$Dict$balance,
						color,
						minKey,
						minValue,
						left,
						$elm$core$Dict$removeMin(right));
				} else {
					return $elm$core$Dict$RBEmpty_elm_builtin;
				}
			} else {
				return A5(
					$elm$core$Dict$balance,
					color,
					key,
					value,
					left,
					A2($elm$core$Dict$removeHelp, targetKey, right));
			}
		} else {
			return $elm$core$Dict$RBEmpty_elm_builtin;
		}
	});
var $elm$core$Dict$remove = F2(
	function (key, dict) {
		var _v0 = A2($elm$core$Dict$removeHelp, key, dict);
		if ((_v0.$ === -1) && (!_v0.a)) {
			var _v1 = _v0.a;
			var k = _v0.b;
			var v = _v0.c;
			var l = _v0.d;
			var r = _v0.e;
			return A5($elm$core$Dict$RBNode_elm_builtin, 1, k, v, l, r);
		} else {
			var x = _v0;
			return x;
		}
	});
var $elm$core$Set$remove = F2(
	function (key, _v0) {
		var dict = _v0;
		return A2($elm$core$Dict$remove, key, dict);
	});
var $author$project$Curation$toggleCategory = F2(
	function (cat, model) {
		var key = $author$project$Curation$categoryKey(cat);
		return A2($elm$core$Set$member, key, model.H) ? _Utils_update(
			model,
			{
				H: A2($elm$core$Set$remove, key, model.H)
			}) : _Utils_update(
			model,
			{
				H: A2($elm$core$Set$insert, key, model.H)
			});
	});
var $author$project$Main$update = F2(
	function (msg, model) {
		switch (msg.$) {
			case 0:
				var raw = msg.a;
				var _v1 = A2($elm$json$Json$Decode$decodeValue, $author$project$Contract$contextDecoder, raw);
				if (!_v1.$) {
					var snapshot = _v1.a;
					return _Utils_Tuple2(
						_Utils_update(
							model,
							{
								z: $elm$core$Maybe$Just(
									$author$project$Curation$init(snapshot))
							}),
						$elm$core$Platform$Cmd$none);
				} else {
					return _Utils_Tuple2(model, $elm$core$Platform$Cmd$none);
				}
			case 1:
				return _Utils_Tuple2(
					_Utils_update(
						model,
						{ab: 0, E: 1}),
					$author$project$Main$formOpened(true));
			case 2:
				return _Utils_Tuple2(
					_Utils_update(
						model,
						{E: 0}),
					$author$project$Main$formOpened(false));
			case 3:
				return _Utils_Tuple2(
					_Utils_update(
						model,
						{E: 2}),
					$elm$core$Platform$Cmd$batch(
						_List_fromArray(
							[
								$author$project$Main$formOpened(false),
								$author$project$Main$setHidden(true)
							])));
			case 4:
				return _Utils_Tuple2(
					_Utils_update(
						model,
						{E: 0}),
					$elm$core$Platform$Cmd$none);
			case 5:
				var cat = msg.a;
				return _Utils_Tuple2(
					_Utils_update(
						model,
						{
							z: A2(
								$elm$core$Maybe$map,
								$author$project$Curation$toggleCategory(cat),
								model.z)
						}),
					$elm$core$Platform$Cmd$none);
			case 6:
				return _Utils_Tuple2(
					model,
					$author$project$Main$requestScreenshot(0));
			case 7:
				return _Utils_Tuple2(
					model,
					$author$project$Main$requestUpload(0));
			case 8:
				var attached = msg.a;
				return _Utils_Tuple2(
					_Utils_update(
						model,
						{ao: attached}),
					$elm$core$Platform$Cmd$none);
			case 9:
				var _v2 = model.z;
				if (_v2.$ === 1) {
					return _Utils_Tuple2(model, $elm$core$Platform$Cmd$none);
				} else {
					var cur = _v2.a;
					var payload = $author$project$Curation$toPayload(cur);
					return _Utils_Tuple2(
						_Utils_update(
							model,
							{ab: 1}),
						$author$project$Main$submit(
							$author$project$Contract$encodeSubmit(payload)));
				}
			case 10:
				return _Utils_Tuple2(
					_Utils_update(
						model,
						{
							z: A2(
								$elm$core$Maybe$map,
								function (c) {
									return $author$project$Curation$init(c.T);
								},
								model.z),
							ao: false,
							ab: 0,
							E: 0
						}),
					$author$project$Main$formOpened(false));
			case 11:
				var on = msg.a;
				return _Utils_Tuple2(
					_Utils_update(
						model,
						{ai: on}),
					$elm$core$Platform$Cmd$none);
			case 12:
				var raw = msg.a;
				var _v3 = A2($elm$json$Json$Decode$decodeValue, $author$project$Dashboard$statusDecoder, raw);
				if (!_v3.$) {
					var s = _v3.a;
					return _Utils_Tuple2(
						_Utils_update(
							model,
							{
								G: function () {
									var _v4 = model.G;
									if (!_v4.$) {
										var existing = _v4.a;
										return $elm$core$Maybe$Just(
											A2($author$project$Dashboard$reconcile, s, existing));
									} else {
										return $elm$core$Maybe$Just(
											$author$project$Dashboard$init(s));
									}
								}()
							}),
						$elm$core$Platform$Cmd$none);
				} else {
					return _Utils_Tuple2(model, $elm$core$Platform$Cmd$none);
				}
			case 13:
				var tab = msg.a;
				return _Utils_Tuple2(
					_Utils_update(
						model,
						{W: tab}),
					$elm$core$Platform$Cmd$none);
			case 14:
				var url = msg.a;
				return _Utils_Tuple2(
					model,
					$author$project$Main$openAppAction(url));
			case 15:
				var pr = msg.a;
				return _Utils_Tuple2(
					A2(
						$author$project$Main$mapDashboard,
						$author$project$Dashboard$requestPreview(pr),
						model),
					$author$project$Main$previewAction(pr));
			case 16:
				var pr = msg.a;
				return _Utils_Tuple2(
					A2(
						$author$project$Main$mapDashboard,
						$author$project$Dashboard$requestMerge(pr),
						model),
					$elm$core$Platform$Cmd$none);
			case 17:
				var pr = msg.a;
				return _Utils_Tuple2(
					A2(
						$author$project$Main$mapDashboard,
						$author$project$Dashboard$cancelMerge(pr),
						model),
					$elm$core$Platform$Cmd$none);
			case 18:
				var pr = msg.a;
				return _Utils_Tuple2(
					A2(
						$author$project$Main$mapDashboard,
						$author$project$Dashboard$confirmMerge(pr),
						model),
					$author$project$Main$mergeAction(pr));
			case 19:
				var pr = msg.a;
				return _Utils_Tuple2(
					A2(
						$author$project$Main$mapDashboard,
						$author$project$Dashboard$requestUpdate(pr),
						model),
					$author$project$Main$restartAction(pr));
			default:
				var raw = msg.a;
				var _v5 = A2($elm$json$Json$Decode$decodeValue, $author$project$Main$actionResultDecoder, raw);
				if (!_v5.$) {
					var result = _v5.a;
					return _Utils_Tuple2(
						A2(
							$author$project$Main$mapDashboard,
							$author$project$Main$applyActionResult(result),
							model),
						$elm$core$Platform$Cmd$none);
				} else {
					return _Utils_Tuple2(model, $elm$core$Platform$Cmd$none);
				}
		}
	});
var $elm$html$Html$div = _VirtualDom_node('div');
var $elm$virtual_dom$VirtualDom$text = _VirtualDom_text;
var $elm$html$Html$text = $elm$virtual_dom$VirtualDom$text;
var $author$project$Main$OpenForm = {$: 1};
var $author$project$Markup$Element$Internal$El = $elm$core$Basics$identity;
var $author$project$Markup$Element$Internal$fromNode = $elm$core$Basics$identity;
var $author$project$Markup$Node$Internal$Raw = function (a) {
	return {$: 2, a: a};
};
var $author$project$Markup$Node$Internal$raw = $author$project$Markup$Node$Internal$Raw;
var $author$project$Seam$html = function (h) {
	return $author$project$Markup$Element$Internal$fromNode(
		$author$project$Markup$Node$Internal$raw(h));
};
var $elm$core$Basics$composeR = F3(
	function (f, g, x) {
		return g(
			f(x));
	});
var $author$project$Dashboard$mergeablePrCount = function (s) {
	return $elm$core$List$length(
		A2(
			$elm$core$List$filter,
			function (pr) {
				return pr.bp && (!pr.bk);
			},
			s.bD));
};
var $author$project$Dashboard$status = function (model) {
	return model.aS;
};
var $elm$core$Maybe$withDefault = F2(
	function (_default, maybe) {
		if (!maybe.$) {
			var value = maybe.a;
			return value;
		} else {
			return _default;
		}
	});
var $author$project$Main$mergeableBadgeCount = function (model) {
	return model.ai ? A2(
		$elm$core$Maybe$withDefault,
		0,
		A2(
			$elm$core$Maybe$map,
			A2($elm$core$Basics$composeR, $author$project$Dashboard$status, $author$project$Dashboard$mergeablePrCount),
			model.G)) : 0;
};
var $author$project$Markup$Html$Attr$Internal$Attr = $elm$core$Basics$identity;
var $author$project$Markup$Html$Attr$Internal$attribute = F2(
	function (fn, value) {
		return function (_v0) {
			return fn(value);
		};
	});
var $elm$virtual_dom$VirtualDom$attribute = F2(
	function (key, value) {
		return A2(
			_VirtualDom_attribute,
			_VirtualDom_noOnOrFormAction(key),
			_VirtualDom_noJavaScriptOrHtmlUri(value));
	});
var $elm$html$Html$Attributes$attribute = $elm$virtual_dom$VirtualDom$attribute;
var $author$project$M3e$Raw$Icon$name = $elm$html$Html$Attributes$attribute('name');
var $author$project$M3e$Html$Icon$name = $author$project$Markup$Html$Attr$Internal$attribute($author$project$M3e$Raw$Icon$name);
var $author$project$M3e$Icon$name = $author$project$M3e$Html$Icon$name;
var $elm$virtual_dom$VirtualDom$Normal = function (a) {
	return {$: 0, a: a};
};
var $elm$virtual_dom$VirtualDom$on = _VirtualDom_on;
var $elm$html$Html$Events$on = F2(
	function (event, decoder) {
		return A2(
			$elm$virtual_dom$VirtualDom$on,
			event,
			$elm$virtual_dom$VirtualDom$Normal(decoder));
	});
var $author$project$M3e$Raw$Fab$onClick = $elm$html$Html$Events$on('click');
var $author$project$M3e$Html$Fab$onClick = function (f_) {
	return A2(
		$author$project$Markup$Html$Attr$Internal$attribute,
		$author$project$M3e$Raw$Fab$onClick,
		$elm$json$Json$Decode$succeed(f_));
};
var $author$project$M3e$Fab$onClick = $author$project$M3e$Html$Fab$onClick;
var $author$project$Markup$Token$Core$Internal$Value = $elm$core$Basics$identity;
var $author$project$Markup$Token$Core$Internal$token = $elm$core$Basics$identity;
var $author$project$M3e$Token$primaryContainer = $author$project$Markup$Token$Core$Internal$token('primary-container');
var $author$project$M3e$Raw$Fab$size = $elm$html$Html$Attributes$attribute('size');
var $author$project$Markup$Token$Core$Internal$toString = function (_v0) {
	var s = _v0;
	return s;
};
var $author$project$Markup$Token$Core$toString = $author$project$Markup$Token$Core$Internal$toString;
var $author$project$M3e$Token$toString = $author$project$Markup$Token$Core$toString;
var $author$project$M3e$Html$Fab$size = function (v_) {
	return A2(
		$author$project$Markup$Html$Attr$Internal$attribute,
		$author$project$M3e$Raw$Fab$size,
		$author$project$M3e$Token$toString(v_));
};
var $author$project$M3e$Fab$size = $author$project$M3e$Html$Fab$size;
var $author$project$M3e$Token$small = $author$project$Markup$Token$Core$Internal$token('small');
var $elm$core$Basics$composeL = F3(
	function (g, f, x) {
		return g(
			f(x));
	});
var $author$project$Seam$text = A2($elm$core$Basics$composeL, $author$project$Seam$html, $elm$html$Html$text);
var $author$project$Markup$Node$Internal$toHtml = function (node) {
	switch (node.$) {
		case 0:
			var d = node.a;
			return A2(
				d.au,
				d.X,
				A2($elm$core$List$map, $author$project$Markup$Node$Internal$toHtml, d.Y));
		case 1:
			var s = node.a;
			return $elm$html$Html$text(s);
		default:
			var h = node.a;
			return h;
	}
};
var $author$project$Markup$Node$toHtml = $author$project$Markup$Node$Internal$toHtml;
var $author$project$Markup$Element$Internal$toNode = function (_v0) {
	var n = _v0;
	return n;
};
var $author$project$Markup$Element$toNode = $author$project$Markup$Element$Internal$toNode;
var $author$project$Main$toHtml = function (el) {
	return $author$project$Markup$Node$toHtml(
		$author$project$Markup$Element$toNode(el));
};
var $author$project$M3e$Raw$Fab$variant = $elm$html$Html$Attributes$attribute('variant');
var $author$project$M3e$Html$Fab$variant = function (v_) {
	return A2(
		$author$project$Markup$Html$Attr$Internal$attribute,
		$author$project$M3e$Raw$Fab$variant,
		$author$project$M3e$Token$toString(v_));
};
var $author$project$M3e$Fab$variant = $author$project$M3e$Html$Fab$variant;
var $elm$virtual_dom$VirtualDom$node = function (tag) {
	return _VirtualDom_node(
		_VirtualDom_noScript(tag));
};
var $elm$html$Html$node = $elm$virtual_dom$VirtualDom$node;
var $author$project$M3e$Raw$Badge$badge = $elm$html$Html$node('m3e-badge');
var $author$project$Markup$Html$Attr$Internal$toAttribute = function (_v0) {
	var run = _v0;
	return run(0);
};
var $author$project$Markup$Html$Attr$toAttribute = $author$project$Markup$Html$Attr$Internal$toAttribute;
var $author$project$M3e$Html$Badge$badge = F2(
	function (attributes, children) {
		return A2(
			$author$project$M3e$Raw$Badge$badge,
			A2($elm$core$List$map, $author$project$Markup$Html$Attr$toAttribute, attributes),
			children);
	});
var $author$project$Markup$Html$Attr$Internal$forget = function (_v0) {
	var run = _v0;
	return run;
};
var $author$project$Markup$Node$Internal$Element = function (a) {
	return {$: 0, a: a};
};
var $author$project$Markup$Node$Internal$fromComponent = F3(
	function (component, attrs, children) {
		return $author$project$Markup$Node$Internal$Element(
			{X: attrs, Y: children, au: component});
	});
var $author$project$Markup$Node$fromComponent = $author$project$Markup$Node$Internal$fromComponent;
var $author$project$M3e$Badge$view = F2(
	function (attributes, children) {
		return $author$project$Markup$Element$Internal$fromNode(
			A3(
				$author$project$Markup$Node$fromComponent,
				F2(
					function (erased, ch) {
						return A2(
							$author$project$M3e$Html$Badge$badge,
							A2($elm$core$List$map, $author$project$Markup$Html$Attr$Internal$forget, erased),
							ch);
					}),
				A2($elm$core$List$map, $author$project$Markup$Html$Attr$Internal$forget, attributes),
				A2($elm$core$List$map, $author$project$Markup$Element$toNode, children)));
	});
var $author$project$M3e$Raw$Fab$fab = $elm$html$Html$node('m3e-fab');
var $author$project$M3e$Html$Fab$fab = F2(
	function (attributes, children) {
		return A2(
			$author$project$M3e$Raw$Fab$fab,
			A2($elm$core$List$map, $author$project$Markup$Html$Attr$toAttribute, attributes),
			children);
	});
var $author$project$M3e$Fab$view = F2(
	function (attributes, children) {
		return $author$project$Markup$Element$Internal$fromNode(
			A3(
				$author$project$Markup$Node$fromComponent,
				F2(
					function (erased, ch) {
						return A2(
							$author$project$M3e$Html$Fab$fab,
							A2($elm$core$List$map, $author$project$Markup$Html$Attr$Internal$forget, erased),
							ch);
					}),
				A2($elm$core$List$map, $author$project$Markup$Html$Attr$Internal$forget, attributes),
				A2($elm$core$List$map, $author$project$Markup$Element$toNode, children)));
	});
var $author$project$M3e$Raw$Icon$icon = $elm$html$Html$node('m3e-icon');
var $author$project$M3e$Html$Icon$icon = F2(
	function (attributes, children) {
		return A2(
			$author$project$M3e$Raw$Icon$icon,
			A2($elm$core$List$map, $author$project$Markup$Html$Attr$toAttribute, attributes),
			children);
	});
var $author$project$M3e$Icon$view = F2(
	function (attributes, children) {
		return $author$project$Markup$Element$Internal$fromNode(
			A3(
				$author$project$Markup$Node$fromComponent,
				F2(
					function (erased, ch) {
						return A2(
							$author$project$M3e$Html$Icon$icon,
							A2($elm$core$List$map, $author$project$Markup$Html$Attr$Internal$forget, erased),
							ch);
					}),
				A2($elm$core$List$map, $author$project$Markup$Html$Attr$Internal$forget, attributes),
				A2($elm$core$List$map, $author$project$Markup$Element$toNode, children)));
	});
var $author$project$Markup$Node$Internal$Text = function (a) {
	return {$: 1, a: a};
};
var $elm$html$Html$span = _VirtualDom_node('span');
var $author$project$Markup$Node$Internal$addAttr = F2(
	function (a, node) {
		switch (node.$) {
			case 0:
				var d = node.a;
				return $author$project$Markup$Node$Internal$Element(
					_Utils_update(
						d,
						{
							X: A2($elm$core$List$cons, a, d.X)
						}));
			case 1:
				var s = node.a;
				return $author$project$Markup$Node$Internal$Element(
					{
						X: _List_fromArray(
							[a]),
						Y: _List_fromArray(
							[
								$author$project$Markup$Node$Internal$Text(s)
							]),
						au: F2(
							function (attrs, kids) {
								return A2(
									$elm$html$Html$span,
									A2($elm$core$List$map, $author$project$Markup$Html$Attr$toAttribute, attrs),
									kids);
							})
					});
			default:
				var h = node.a;
				return $author$project$Markup$Node$Internal$Element(
					{
						X: _List_fromArray(
							[a]),
						Y: _List_Nil,
						au: F2(
							function (attrs, _v1) {
								return A2(
									$elm$html$Html$span,
									A2($elm$core$List$map, $author$project$Markup$Html$Attr$toAttribute, attrs),
									_List_fromArray(
										[h]));
							})
					});
		}
	});
var $author$project$Markup$Node$addAttr = $author$project$Markup$Node$Internal$addAttr;
var $author$project$Markup$Element$Internal$withAttr = F3(
	function (name, value, _v0) {
		var node = _v0;
		return A2(
			$author$project$Markup$Node$addAttr,
			$author$project$Markup$Html$Attr$Internal$forget(
				A2(
					$author$project$Markup$Html$Attr$Internal$attribute,
					$elm$html$Html$Attributes$attribute(name),
					value)),
			node);
	});
var $author$project$Markup$Element$withAttr = $author$project$Markup$Element$Internal$withAttr;
var $author$project$Main$viewFab = function (model) {
	var badgeCount = $author$project$Main$mergeableBadgeCount(model);
	var badge = (badgeCount > 0) ? _List_fromArray(
		[
			$author$project$Seam$html(
			$author$project$Main$toHtml(
				A3(
					$author$project$Markup$Element$withAttr,
					'class',
					'ff-fab-badge',
					A2(
						$author$project$M3e$Badge$view,
						_List_Nil,
						_List_fromArray(
							[
								$author$project$Seam$text(
								$elm$core$String$fromInt(badgeCount))
							])))))
		]) : _List_Nil;
	return $author$project$Main$toHtml(
		A3(
			$author$project$Markup$Element$withAttr,
			'aria-label',
			'Report a bug',
			A2(
				$author$project$M3e$Fab$view,
				_List_fromArray(
					[
						$author$project$M3e$Fab$size($author$project$M3e$Token$small),
						$author$project$M3e$Fab$variant($author$project$M3e$Token$primaryContainer),
						$author$project$M3e$Fab$onClick($author$project$Main$OpenForm)
					]),
				A2(
					$elm$core$List$cons,
					A2(
						$author$project$M3e$Icon$view,
						_List_fromArray(
							[
								$author$project$M3e$Icon$name('bug_report')
							]),
						_List_Nil),
					badge))));
};
var $author$project$M3e$Token$contained = $author$project$Markup$Token$Core$Internal$token('contained');
var $author$project$M3e$Raw$BottomSheet$detents = $elm$html$Html$Attributes$attribute('detents');
var $author$project$M3e$Html$BottomSheet$detents = $author$project$Markup$Html$Attr$Internal$attribute($author$project$M3e$Raw$BottomSheet$detents);
var $author$project$M3e$BottomSheet$detents = $author$project$M3e$Html$BottomSheet$detents;
var $elm$html$Html$Attributes$stringProperty = F2(
	function (key, string) {
		return A2(
			_VirtualDom_property,
			key,
			$elm$json$Json$Encode$string(string));
	});
var $elm$html$Html$Attributes$class = $elm$html$Html$Attributes$stringProperty('className');
var $elm$core$Tuple$second = function (_v0) {
	var y = _v0.b;
	return y;
};
var $elm$html$Html$Attributes$classList = function (classes) {
	return $elm$html$Html$Attributes$class(
		A2(
			$elm$core$String$join,
			' ',
			A2(
				$elm$core$List$map,
				$elm$core$Tuple$first,
				A2($elm$core$List$filter, $elm$core$Tuple$second, classes))));
};
var $author$project$M3e$Raw$BottomSheet$handle = function (val_) {
	return val_ ? A2($elm$html$Html$Attributes$attribute, 'handle', '') : $elm$html$Html$Attributes$classList(_List_Nil);
};
var $author$project$M3e$Html$BottomSheet$handle = $author$project$Markup$Html$Attr$Internal$attribute($author$project$M3e$Raw$BottomSheet$handle);
var $author$project$M3e$BottomSheet$handle = $author$project$M3e$Html$BottomSheet$handle;
var $author$project$Markup$Html$Attr$Internal$slot = $author$project$Markup$Html$Attr$Internal$attribute(
	$elm$html$Html$Attributes$attribute('slot'));
var $author$project$Markup$Element$Internal$placeSlot = F2(
	function (name, _v0) {
		var node = _v0;
		return A2(
			$author$project$Markup$Node$addAttr,
			$author$project$Markup$Html$Attr$Internal$forget(
				$author$project$Markup$Html$Attr$Internal$slot(name)),
			node);
	});
var $author$project$M3e$BottomSheet$header = function (el) {
	return A2($author$project$Markup$Element$Internal$placeSlot, 'header', el);
};
var $author$project$M3e$Raw$BottomSheet$hideable = function (val_) {
	return val_ ? A2($elm$html$Html$Attributes$attribute, 'hideable', '') : $elm$html$Html$Attributes$classList(_List_Nil);
};
var $author$project$M3e$Html$BottomSheet$hideable = $author$project$Markup$Html$Attr$Internal$attribute($author$project$M3e$Raw$BottomSheet$hideable);
var $author$project$M3e$BottomSheet$hideable = $author$project$M3e$Html$BottomSheet$hideable;
var $author$project$M3e$AppBar$leadingIcon = function (el) {
	return A2($author$project$Markup$Element$Internal$placeSlot, 'leading-icon', el);
};
var $author$project$M3e$Raw$BottomSheet$onClosed = $elm$html$Html$Events$on('closed');
var $author$project$M3e$Html$BottomSheet$onClosed = function (f_) {
	return A2(
		$author$project$Markup$Html$Attr$Internal$attribute,
		$author$project$M3e$Raw$BottomSheet$onClosed,
		$elm$json$Json$Decode$succeed(f_));
};
var $author$project$M3e$BottomSheet$onClosed = $author$project$M3e$Html$BottomSheet$onClosed;
var $author$project$M3e$Raw$BottomSheet$open = function (val_) {
	return val_ ? A2($elm$html$Html$Attributes$attribute, 'open', '') : $elm$html$Html$Attributes$classList(_List_Nil);
};
var $author$project$M3e$Html$BottomSheet$open = $author$project$Markup$Html$Attr$Internal$attribute($author$project$M3e$Raw$BottomSheet$open);
var $author$project$M3e$BottomSheet$open = $author$project$M3e$Html$BottomSheet$open;
var $author$project$Main$DashCancelMerge = function (a) {
	return {$: 17, a: a};
};
var $author$project$Main$DashConfirmMerge = function (a) {
	return {$: 18, a: a};
};
var $author$project$Main$DashRequestMerge = function (a) {
	return {$: 16, a: a};
};
var $author$project$Main$DashRequestPreview = function (a) {
	return {$: 15, a: a};
};
var $author$project$Main$DashRequestUpdate = function (a) {
	return {$: 19, a: a};
};
var $author$project$Main$OpenAppUrl = function (a) {
	return {$: 14, a: a};
};
var $author$project$Main$dashboardConfig = {a_: $author$project$Main$DashCancelMerge, a0: $author$project$Main$DashConfirmMerge, bx: $author$project$Main$OpenAppUrl, bJ: $author$project$Main$DashRequestMerge, bK: $author$project$Main$DashRequestPreview, bL: $author$project$Main$DashRequestUpdate};
var $author$project$M3e$Raw$LoadingIndicator$variant = $elm$html$Html$Attributes$attribute('variant');
var $author$project$M3e$Html$LoadingIndicator$variant = function (v_) {
	return A2(
		$author$project$Markup$Html$Attr$Internal$attribute,
		$author$project$M3e$Raw$LoadingIndicator$variant,
		$author$project$M3e$Token$toString(v_));
};
var $author$project$M3e$LoadingIndicator$variant = $author$project$M3e$Html$LoadingIndicator$variant;
var $author$project$M3e$Card$content = function (el) {
	return A2($author$project$Markup$Element$Internal$placeSlot, 'content', el);
};
var $author$project$M3e$Token$filled = $author$project$Markup$Token$Core$Internal$token('filled');
var $author$project$M3e$Token$elevated = $author$project$Markup$Token$Core$Internal$token('elevated');
var $author$project$DashboardView$toHtml = function (el) {
	return $author$project$Markup$Node$toHtml(
		$author$project$Markup$Element$toNode(el));
};
var $author$project$M3e$Raw$SuggestionChip$variant = $elm$html$Html$Attributes$attribute('variant');
var $author$project$M3e$Html$SuggestionChip$variant = function (v_) {
	return A2(
		$author$project$Markup$Html$Attr$Internal$attribute,
		$author$project$M3e$Raw$SuggestionChip$variant,
		$author$project$M3e$Token$toString(v_));
};
var $author$project$M3e$SuggestionChip$variant = $author$project$M3e$Html$SuggestionChip$variant;
var $author$project$M3e$Raw$SuggestionChip$suggestionChip = $elm$html$Html$node('m3e-suggestion-chip');
var $author$project$M3e$Html$SuggestionChip$suggestionChip = F2(
	function (attributes, children) {
		return A2(
			$author$project$M3e$Raw$SuggestionChip$suggestionChip,
			A2($elm$core$List$map, $author$project$Markup$Html$Attr$toAttribute, attributes),
			children);
	});
var $author$project$M3e$SuggestionChip$view = F2(
	function (attributes, children) {
		return $author$project$Markup$Element$Internal$fromNode(
			A3(
				$author$project$Markup$Node$fromComponent,
				F2(
					function (erased, ch) {
						return A2(
							$author$project$M3e$Html$SuggestionChip$suggestionChip,
							A2($elm$core$List$map, $author$project$Markup$Html$Attr$Internal$forget, erased),
							ch);
					}),
				A2($elm$core$List$map, $author$project$Markup$Html$Attr$Internal$forget, attributes),
				A2($elm$core$List$map, $author$project$Markup$Element$toNode, children)));
	});
var $author$project$DashboardView$healthChip = function (health) {
	return $elm$core$String$isEmpty(health) ? $elm$html$Html$text('') : $author$project$DashboardView$toHtml(
		A2(
			$author$project$M3e$SuggestionChip$view,
			_List_fromArray(
				[
					$author$project$M3e$SuggestionChip$variant($author$project$M3e$Token$elevated)
				]),
			_List_fromArray(
				[
					$author$project$Seam$text(health)
				])));
};
var $author$project$DashboardView$portChip = function (port_) {
	return $author$project$DashboardView$toHtml(
		A2(
			$author$project$M3e$SuggestionChip$view,
			_List_fromArray(
				[
					$author$project$M3e$SuggestionChip$variant($author$project$M3e$Token$elevated)
				]),
			_List_fromArray(
				[
					$author$project$Seam$text(
					':' + $elm$core$String$fromInt(port_))
				])));
};
var $author$project$M3e$SuggestionChip$icon = function (el) {
	return A2($author$project$Markup$Element$Internal$placeSlot, 'icon', el);
};
var $author$project$DashboardView$runningChip = function (running) {
	var _v0 = running ? _Utils_Tuple2('play_circle', 'running') : _Utils_Tuple2('stop_circle', 'stopped');
	var icon = _v0.a;
	var label = _v0.b;
	return $author$project$DashboardView$toHtml(
		A2(
			$author$project$M3e$SuggestionChip$view,
			_List_fromArray(
				[
					$author$project$M3e$SuggestionChip$variant($author$project$M3e$Token$elevated)
				]),
			_List_fromArray(
				[
					$author$project$M3e$SuggestionChip$icon(
					A2(
						$author$project$M3e$Icon$view,
						_List_fromArray(
							[
								$author$project$M3e$Icon$name(icon)
							]),
						_List_Nil)),
					$author$project$Seam$text(label)
				])));
};
var $author$project$M3e$Button$icon = function (el) {
	return A2($author$project$Markup$Element$Internal$placeSlot, 'icon', el);
};
var $author$project$M3e$Raw$Button$onClick = $elm$html$Html$Events$on('click');
var $author$project$M3e$Html$Button$onClick = function (f_) {
	return A2(
		$author$project$Markup$Html$Attr$Internal$attribute,
		$author$project$M3e$Raw$Button$onClick,
		$elm$json$Json$Decode$succeed(f_));
};
var $author$project$M3e$Button$onClick = $author$project$M3e$Html$Button$onClick;
var $author$project$M3e$Token$text = $author$project$Markup$Token$Core$Internal$token('text');
var $author$project$M3e$Raw$Button$variant = $elm$html$Html$Attributes$attribute('variant');
var $author$project$M3e$Html$Button$variant = function (v_) {
	return A2(
		$author$project$Markup$Html$Attr$Internal$attribute,
		$author$project$M3e$Raw$Button$variant,
		$author$project$M3e$Token$toString(v_));
};
var $author$project$M3e$Button$variant = $author$project$M3e$Html$Button$variant;
var $author$project$M3e$Raw$Button$button = $elm$html$Html$node('m3e-button');
var $author$project$M3e$Html$Button$button = F2(
	function (attributes, children) {
		return A2(
			$author$project$M3e$Raw$Button$button,
			A2($elm$core$List$map, $author$project$Markup$Html$Attr$toAttribute, attributes),
			children);
	});
var $author$project$M3e$Button$view = F2(
	function (attributes, children) {
		return $author$project$Markup$Element$Internal$fromNode(
			A3(
				$author$project$Markup$Node$fromComponent,
				F2(
					function (erased, ch) {
						return A2(
							$author$project$M3e$Html$Button$button,
							A2($elm$core$List$map, $author$project$Markup$Html$Attr$Internal$forget, erased),
							ch);
					}),
				A2($elm$core$List$map, $author$project$Markup$Html$Attr$Internal$forget, attributes),
				A2($elm$core$List$map, $author$project$Markup$Element$toNode, children)));
	});
var $author$project$DashboardView$tailnetLink = F2(
	function (config, serveUrl) {
		return $elm$core$String$isEmpty(serveUrl) ? $elm$html$Html$text('') : $author$project$DashboardView$toHtml(
			A2(
				$author$project$M3e$Button$view,
				_List_fromArray(
					[
						$author$project$M3e$Button$variant($author$project$M3e$Token$text),
						$author$project$M3e$Button$onClick(
						config.bx(serveUrl))
					]),
				_List_fromArray(
					[
						$author$project$M3e$Button$icon(
						A2(
							$author$project$M3e$Icon$view,
							_List_fromArray(
								[
									$author$project$M3e$Icon$name('open_in_new')
								]),
							_List_Nil)),
						$author$project$Seam$text('Open app')
					])));
	});
var $author$project$M3e$Raw$Card$variant = $elm$html$Html$Attributes$attribute('variant');
var $author$project$M3e$Html$Card$variant = function (v_) {
	return A2(
		$author$project$Markup$Html$Attr$Internal$attribute,
		$author$project$M3e$Raw$Card$variant,
		$author$project$M3e$Token$toString(v_));
};
var $author$project$M3e$Card$variant = $author$project$M3e$Html$Card$variant;
var $author$project$M3e$Raw$Card$card = $elm$html$Html$node('m3e-card');
var $author$project$M3e$Html$Card$card = F2(
	function (attributes, children) {
		return A2(
			$author$project$M3e$Raw$Card$card,
			A2($elm$core$List$map, $author$project$Markup$Html$Attr$toAttribute, attributes),
			children);
	});
var $author$project$M3e$Card$view = F2(
	function (attributes, children) {
		return $author$project$Markup$Element$Internal$fromNode(
			A3(
				$author$project$Markup$Node$fromComponent,
				F2(
					function (erased, ch) {
						return A2(
							$author$project$M3e$Html$Card$card,
							A2($elm$core$List$map, $author$project$Markup$Html$Attr$Internal$forget, erased),
							ch);
					}),
				A2($elm$core$List$map, $author$project$Markup$Html$Attr$Internal$forget, attributes),
				A2($elm$core$List$map, $author$project$Markup$Element$toNode, children)));
	});
var $author$project$DashboardView$viewAppLine = F2(
	function (config, app) {
		return $author$project$DashboardView$toHtml(
			A2(
				$author$project$M3e$Card$view,
				_List_fromArray(
					[
						$author$project$M3e$Card$variant($author$project$M3e$Token$filled)
					]),
				_List_fromArray(
					[
						$author$project$M3e$Card$content(
						$author$project$Seam$html(
							A2(
								$elm$html$Html$div,
								_List_fromArray(
									[
										$elm$html$Html$Attributes$class('flex flex-col gap-2 p-1')
									]),
								_List_fromArray(
									[
										A2(
										$elm$html$Html$div,
										_List_fromArray(
											[
												$elm$html$Html$Attributes$class('flex items-center gap-2 flex-wrap')
											]),
										_List_fromArray(
											[
												$author$project$DashboardView$runningChip(app.cZ),
												$author$project$DashboardView$portChip(app.cR),
												$author$project$DashboardView$healthChip(app.cr)
											])),
										A2($author$project$DashboardView$tailnetLink, config, app.c_)
									]))))
					])));
	});
var $author$project$DashboardView$countChip = F3(
	function (icon, n, label) {
		return $author$project$DashboardView$toHtml(
			A2(
				$author$project$M3e$SuggestionChip$view,
				_List_fromArray(
					[
						$author$project$M3e$SuggestionChip$variant($author$project$M3e$Token$elevated)
					]),
				_List_fromArray(
					[
						$author$project$M3e$SuggestionChip$icon(
						A2(
							$author$project$M3e$Icon$view,
							_List_fromArray(
								[
									$author$project$M3e$Icon$name(icon)
								]),
							_List_Nil)),
						$author$project$Seam$text(
						$elm$core$String$fromInt(n) + (' ' + label))
					])));
	});
var $author$project$DashboardView$viewCounts = function (counts) {
	return A2(
		$elm$html$Html$div,
		_List_fromArray(
			[
				$elm$html$Html$Attributes$class('flex items-center gap-2 flex-wrap')
			]),
		_List_fromArray(
			[
				A3($author$project$DashboardView$countChip, 'bug_report', counts.cP, 'open'),
				A3($author$project$DashboardView$countChip, 'feedback', counts.cT, 'feedback'),
				A3($author$project$DashboardView$countChip, 'engineering', counts.b3, 'workers')
			]));
};
var $elm$core$List$isEmpty = function (xs) {
	if (!xs.b) {
		return true;
	} else {
		return false;
	}
};
var $elm$html$Html$p = _VirtualDom_node('p');
var $author$project$Dashboard$mergePhaseFor = F2(
	function (pr, model) {
		return A2(
			$elm$core$Maybe$withDefault,
			0,
			A2($elm$core$Dict$get, pr, model.al));
	});
var $author$project$DashboardView$mergeableBadge = function (pr) {
	return (pr.bp && (!pr.bk)) ? $author$project$DashboardView$toHtml(
		A3(
			$author$project$Markup$Element$withAttr,
			'class',
			'ff-badge-mergeable',
			A2(
				$author$project$M3e$Badge$view,
				_List_Nil,
				_List_fromArray(
					[
						$author$project$Seam$text('mergeable')
					])))) : (pr.bk ? $author$project$DashboardView$toHtml(
		A2(
			$author$project$M3e$Badge$view,
			_List_Nil,
			_List_fromArray(
				[
					$author$project$Seam$text('draft')
				]))) : $elm$html$Html$text(''));
};
var $author$project$M3e$Token$outlined = $author$project$Markup$Token$Core$Internal$token('outlined');
var $author$project$Dashboard$previewStateFor = F2(
	function (pr, model) {
		return A2(
			$elm$core$Maybe$withDefault,
			0,
			A2($elm$core$Dict$get, pr, model.an));
	});
var $author$project$M3e$Raw$LoadingIndicator$loadingIndicator = $elm$html$Html$node('m3e-loading-indicator');
var $author$project$M3e$Html$LoadingIndicator$loadingIndicator = F2(
	function (attributes, children) {
		return A2(
			$author$project$M3e$Raw$LoadingIndicator$loadingIndicator,
			A2($elm$core$List$map, $author$project$Markup$Html$Attr$toAttribute, attributes),
			children);
	});
var $author$project$M3e$LoadingIndicator$view = F2(
	function (attributes, children) {
		return $author$project$Markup$Element$Internal$fromNode(
			A3(
				$author$project$Markup$Node$fromComponent,
				F2(
					function (erased, ch) {
						return A2(
							$author$project$M3e$Html$LoadingIndicator$loadingIndicator,
							A2($elm$core$List$map, $author$project$Markup$Html$Attr$Internal$forget, erased),
							ch);
					}),
				A2($elm$core$List$map, $author$project$Markup$Html$Attr$Internal$forget, attributes),
				A2($elm$core$List$map, $author$project$Markup$Element$toNode, children)));
	});
var $author$project$DashboardView$spinnerLabel = function (label) {
	return A2(
		$elm$html$Html$div,
		_List_fromArray(
			[
				$elm$html$Html$Attributes$class('flex items-center gap-2')
			]),
		_List_fromArray(
			[
				$author$project$DashboardView$toHtml(
				A2(
					$author$project$M3e$LoadingIndicator$view,
					_List_fromArray(
						[
							$author$project$M3e$LoadingIndicator$variant($author$project$M3e$Token$contained)
						]),
					_List_Nil)),
				A2(
				$elm$html$Html$span,
				_List_Nil,
				_List_fromArray(
					[
						$elm$html$Html$text(label)
					]))
			]));
};
var $author$project$DashboardView$mergeControls = F3(
	function (config, pr, mergePhase) {
		switch (mergePhase) {
			case 0:
				return (pr.bp && (!pr.bk)) ? _List_fromArray(
					[
						$author$project$DashboardView$toHtml(
						A2(
							$author$project$M3e$Button$view,
							_List_fromArray(
								[
									$author$project$M3e$Button$variant($author$project$M3e$Token$filled),
									$author$project$M3e$Button$onClick(
									config.bJ(pr.cL))
								]),
							_List_fromArray(
								[
									$author$project$M3e$Button$icon(
									A2(
										$author$project$M3e$Icon$view,
										_List_fromArray(
											[
												$author$project$M3e$Icon$name('merge')
											]),
										_List_Nil)),
									$author$project$Seam$text('Merge')
								])))
					]) : _List_Nil;
			case 1:
				return _List_fromArray(
					[
						A2(
						$elm$html$Html$span,
						_List_fromArray(
							[
								$elm$html$Html$Attributes$class('text-sm opacity-80 self-center')
							]),
						_List_fromArray(
							[
								$elm$html$Html$text(
								'Merge PR #' + ($elm$core$String$fromInt(pr.cL) + ' into main?'))
							])),
						$author$project$DashboardView$toHtml(
						A2(
							$author$project$M3e$Button$view,
							_List_fromArray(
								[
									$author$project$M3e$Button$variant($author$project$M3e$Token$text),
									$author$project$M3e$Button$onClick(
									config.a_(pr.cL))
								]),
							_List_fromArray(
								[
									$author$project$Seam$text('Cancel')
								]))),
						$author$project$DashboardView$toHtml(
						A2(
							$author$project$M3e$Button$view,
							_List_fromArray(
								[
									$author$project$M3e$Button$variant($author$project$M3e$Token$filled),
									$author$project$M3e$Button$onClick(
									config.a0(pr.cL))
								]),
							_List_fromArray(
								[
									$author$project$Seam$text('Merge')
								])))
					]);
			case 2:
				return _List_fromArray(
					[
						$author$project$DashboardView$spinnerLabel('Merging…')
					]);
			case 3:
				return _List_fromArray(
					[
						A2(
						$elm$html$Html$span,
						_List_fromArray(
							[
								$elm$html$Html$Attributes$class('text-sm opacity-70 self-center')
							]),
						_List_fromArray(
							[
								$elm$html$Html$text('Merged ✓')
							])),
						$author$project$DashboardView$toHtml(
						A2(
							$author$project$M3e$Button$view,
							_List_fromArray(
								[
									$author$project$M3e$Button$variant($author$project$M3e$Token$filled),
									$author$project$M3e$Button$onClick(
									config.bL(pr.cL))
								]),
							_List_fromArray(
								[
									$author$project$M3e$Button$icon(
									A2(
										$author$project$M3e$Icon$view,
										_List_fromArray(
											[
												$author$project$M3e$Icon$name('sync')
											]),
										_List_Nil)),
									$author$project$Seam$text('Update now')
								])))
					]);
			case 4:
				return _List_fromArray(
					[
						$author$project$DashboardView$spinnerLabel('Updating…')
					]);
			default:
				return _List_fromArray(
					[
						A2(
						$elm$html$Html$span,
						_List_fromArray(
							[
								$elm$html$Html$Attributes$class('text-sm opacity-70 self-center')
							]),
						_List_fromArray(
							[
								$elm$html$Html$text('Updated ✓')
							]))
					]);
		}
	});
var $author$project$M3e$Raw$Button$disabled = function (val_) {
	return val_ ? A2($elm$html$Html$Attributes$attribute, 'disabled', '') : $elm$html$Html$Attributes$classList(_List_Nil);
};
var $author$project$M3e$Html$Button$disabled = $author$project$Markup$Html$Attr$Internal$attribute($author$project$M3e$Raw$Button$disabled);
var $author$project$M3e$Button$disabled = $author$project$M3e$Html$Button$disabled;
var $author$project$Dashboard$previewLabel = function (s) {
	if (s === 3) {
		return 'Reopen';
	} else {
		return 'Preview';
	}
};
var $author$project$M3e$Token$tonal = $author$project$Markup$Token$Core$Internal$token('tonal');
var $author$project$DashboardView$previewButton = F3(
	function (config, pr, previewState) {
		var label = $author$project$Dashboard$previewLabel(pr.cS.aS);
		if (previewState === 1) {
			return $author$project$DashboardView$toHtml(
				A2(
					$author$project$M3e$Button$view,
					_List_fromArray(
						[
							$author$project$M3e$Button$variant($author$project$M3e$Token$tonal),
							$author$project$M3e$Button$disabled(true)
						]),
					_List_fromArray(
						[
							$author$project$M3e$Button$icon(
							A2(
								$author$project$M3e$LoadingIndicator$view,
								_List_fromArray(
									[
										$author$project$M3e$LoadingIndicator$variant($author$project$M3e$Token$contained)
									]),
								_List_Nil)),
							$author$project$Seam$text('Opening…')
						])));
		} else {
			return $author$project$DashboardView$toHtml(
				A2(
					$author$project$M3e$Button$view,
					_List_fromArray(
						[
							$author$project$M3e$Button$variant($author$project$M3e$Token$tonal),
							$author$project$M3e$Button$onClick(
							config.bK(pr.cL))
						]),
					_List_fromArray(
						[
							$author$project$M3e$Button$icon(
							A2(
								$author$project$M3e$Icon$view,
								_List_fromArray(
									[
										$author$project$M3e$Icon$name('preview')
									]),
								_List_Nil)),
							$author$project$Seam$text(label)
						])));
		}
	});
var $author$project$DashboardView$viewPrActions = F4(
	function (config, pr, mergePhase, previewState) {
		return A2(
			$elm$html$Html$div,
			_List_fromArray(
				[
					$elm$html$Html$Attributes$class('flex items-center gap-2 flex-wrap justify-end')
				]),
			A2(
				$elm$core$List$cons,
				A3($author$project$DashboardView$previewButton, config, pr, previewState),
				A3($author$project$DashboardView$mergeControls, config, pr, mergePhase)));
	});
var $author$project$DashboardView$viewPr = F3(
	function (config, model, pr) {
		var previewState = A2($author$project$Dashboard$previewStateFor, pr.cL, model);
		var mergePhase = A2($author$project$Dashboard$mergePhaseFor, pr.cL, model);
		return $author$project$DashboardView$toHtml(
			A2(
				$author$project$M3e$Card$view,
				_List_fromArray(
					[
						$author$project$M3e$Card$variant($author$project$M3e$Token$outlined)
					]),
				_List_fromArray(
					[
						$author$project$M3e$Card$content(
						$author$project$Seam$html(
							A2(
								$elm$html$Html$div,
								_List_fromArray(
									[
										$elm$html$Html$Attributes$class('flex flex-col gap-2 p-1')
									]),
								_List_fromArray(
									[
										A2(
										$elm$html$Html$div,
										_List_fromArray(
											[
												$elm$html$Html$Attributes$class('flex items-center gap-2')
											]),
										_List_fromArray(
											[
												A2(
												$elm$html$Html$span,
												_List_fromArray(
													[
														$elm$html$Html$Attributes$class('text-sm font-medium flex-1')
													]),
												_List_fromArray(
													[
														$elm$html$Html$text(
														'#' + ($elm$core$String$fromInt(pr.cL) + (' ' + pr.bX)))
													])),
												$author$project$DashboardView$mergeableBadge(pr)
											])),
										A4($author$project$DashboardView$viewPrActions, config, pr, mergePhase, previewState)
									]))))
					])));
	});
var $author$project$DashboardView$viewPrs = F3(
	function (config, model, prs) {
		return $elm$core$List$isEmpty(prs) ? A2(
			$elm$html$Html$div,
			_List_fromArray(
				[
					$elm$html$Html$Attributes$class('text-sm font-medium opacity-70')
				]),
			_List_fromArray(
				[
					$elm$html$Html$text('No open PRs')
				])) : A2(
			$elm$html$Html$div,
			_List_fromArray(
				[
					$elm$html$Html$Attributes$class('flex flex-col gap-2')
				]),
			A2(
				$elm$core$List$cons,
				A2(
					$elm$html$Html$p,
					_List_fromArray(
						[
							$elm$html$Html$Attributes$class('text-sm font-medium opacity-70')
						]),
					_List_fromArray(
						[
							$elm$html$Html$text('Pull requests')
						])),
				A2(
					$elm$core$List$map,
					A2($author$project$DashboardView$viewPr, config, model),
					prs)));
	});
var $author$project$DashboardView$viewWorker = function (worker) {
	return A2(
		$elm$html$Html$div,
		_List_fromArray(
			[
				$elm$html$Html$Attributes$class('flex items-center gap-2')
			]),
		_List_fromArray(
			[
				$author$project$DashboardView$toHtml(
				A2(
					$author$project$M3e$SuggestionChip$view,
					_List_fromArray(
						[
							$author$project$M3e$SuggestionChip$variant($author$project$M3e$Token$elevated)
						]),
					_List_fromArray(
						[
							$author$project$M3e$SuggestionChip$icon(
							A2(
								$author$project$M3e$Icon$view,
								_List_fromArray(
									[
										$author$project$M3e$Icon$name('engineering')
									]),
								_List_Nil)),
							$author$project$Seam$text(
							'#' + $elm$core$String$fromInt(worker.cw))
						]))),
				A2(
				$elm$html$Html$span,
				_List_fromArray(
					[
						$elm$html$Html$Attributes$class('text-sm opacity-70')
					]),
				_List_fromArray(
					[
						$elm$html$Html$text(worker.aS)
					]))
			]));
};
var $author$project$DashboardView$viewWorkers = function (workers) {
	return $elm$core$List$isEmpty(workers) ? $elm$html$Html$text('') : A2(
		$elm$html$Html$div,
		_List_fromArray(
			[
				$elm$html$Html$Attributes$class('flex flex-col gap-1')
			]),
		A2(
			$elm$core$List$cons,
			A2(
				$elm$html$Html$p,
				_List_fromArray(
					[
						$elm$html$Html$Attributes$class('text-sm font-medium opacity-70')
					]),
				_List_fromArray(
					[
						$elm$html$Html$text('Workers')
					])),
			A2($elm$core$List$map, $author$project$DashboardView$viewWorker, workers)));
};
var $author$project$DashboardView$view = F2(
	function (config, model) {
		var s = $author$project$Dashboard$status(model);
		return A2(
			$elm$html$Html$div,
			_List_fromArray(
				[
					$elm$html$Html$Attributes$class('ff-dashboard flex flex-col items-stretch gap-3 pt-1 px-4 pb-2')
				]),
			_List_fromArray(
				[
					A2($author$project$DashboardView$viewAppLine, config, s.b8),
					$author$project$DashboardView$viewCounts(s.ch),
					$author$project$DashboardView$viewWorkers(s.b3),
					A3($author$project$DashboardView$viewPrs, config, model, s.bD)
				]));
	});
var $author$project$Main$dashboardPanel = function (model) {
	var _v0 = model.G;
	if (_v0.$ === 1) {
		return A2(
			$elm$html$Html$div,
			_List_fromArray(
				[
					$elm$html$Html$Attributes$class('ff-dashboard flex flex-col gap-2 pt-1 px-4 pb-2')
				]),
			_List_fromArray(
				[
					A2(
					$elm$html$Html$div,
					_List_fromArray(
						[
							$elm$html$Html$Attributes$class('flex items-center gap-2')
						]),
					_List_fromArray(
						[
							$author$project$Main$toHtml(
							A2(
								$author$project$M3e$LoadingIndicator$view,
								_List_fromArray(
									[
										$author$project$M3e$LoadingIndicator$variant($author$project$M3e$Token$contained)
									]),
								_List_Nil)),
							A2(
							$elm$html$Html$span,
							_List_Nil,
							_List_fromArray(
								[
									$elm$html$Html$text('Loading app status…')
								]))
						]))
				]));
	} else {
		var dash = _v0.a;
		return A2($author$project$DashboardView$view, $author$project$Main$dashboardConfig, dash);
	}
};
var $elm$html$Html$Attributes$id = $elm$html$Html$Attributes$stringProperty('id');
var $elm$html$Html$input = _VirtualDom_node('input');
var $elm$html$Html$Attributes$rows = function (n) {
	return A2(
		_VirtualDom_attribute,
		'rows',
		$elm$core$String$fromInt(n));
};
var $elm$html$Html$textarea = _VirtualDom_node('textarea');
var $elm$html$Html$Attributes$type_ = $elm$html$Html$Attributes$stringProperty('type');
var $author$project$Main$HideFab = {$: 3};
var $author$project$Main$Submit = {$: 9};
var $author$project$Main$button = F3(
	function (variant, msg, label_) {
		return $author$project$Main$toHtml(
			A2(
				$author$project$M3e$Button$view,
				_List_fromArray(
					[
						$author$project$M3e$Button$variant(variant),
						$author$project$M3e$Button$onClick(msg)
					]),
				_List_fromArray(
					[
						$author$project$Seam$text(label_)
					])));
	});
var $author$project$Main$viewActions = function (_v0) {
	return A2(
		$elm$html$Html$div,
		_List_fromArray(
			[
				$elm$html$Html$Attributes$class('flex justify-end gap-2')
			]),
		_List_fromArray(
			[
				A3($author$project$Main$button, $author$project$M3e$Token$text, $author$project$Main$HideFab, 'Hide'),
				A3($author$project$Main$button, $author$project$M3e$Token$text, $author$project$Main$CloseForm, 'Cancel'),
				A3($author$project$Main$button, $author$project$M3e$Token$filled, $author$project$Main$Submit, 'Submit')
			]));
};
var $author$project$Main$ToggleCategory = function (a) {
	return {$: 5, a: a};
};
var $author$project$M3e$Raw$FilterChip$onClick = $elm$html$Html$Events$on('click');
var $author$project$M3e$Html$FilterChip$onClick = function (f_) {
	return A2(
		$author$project$Markup$Html$Attr$Internal$attribute,
		$author$project$M3e$Raw$FilterChip$onClick,
		$elm$json$Json$Decode$succeed(f_));
};
var $author$project$M3e$FilterChip$onClick = $author$project$M3e$Html$FilterChip$onClick;
var $author$project$M3e$Raw$FilterChip$selected = function (val_) {
	return val_ ? A2($elm$html$Html$Attributes$attribute, 'selected', '') : $elm$html$Html$Attributes$classList(_List_Nil);
};
var $author$project$M3e$Html$FilterChip$selected = $author$project$Markup$Html$Attr$Internal$attribute($author$project$M3e$Raw$FilterChip$selected);
var $author$project$M3e$FilterChip$selected = $author$project$M3e$Html$FilterChip$selected;
var $author$project$M3e$FilterChip$trailingIcon = function (el) {
	return A2($author$project$Markup$Element$Internal$placeSlot, 'trailing-icon', el);
};
var $author$project$M3e$Raw$FilterChip$filterChip = $elm$html$Html$node('m3e-filter-chip');
var $author$project$M3e$Html$FilterChip$filterChip = F2(
	function (attributes, children) {
		return A2(
			$author$project$M3e$Raw$FilterChip$filterChip,
			A2($elm$core$List$map, $author$project$Markup$Html$Attr$toAttribute, attributes),
			children);
	});
var $author$project$M3e$FilterChip$view = F2(
	function (attributes, children) {
		return $author$project$Markup$Element$Internal$fromNode(
			A3(
				$author$project$Markup$Node$fromComponent,
				F2(
					function (erased, ch) {
						return A2(
							$author$project$M3e$Html$FilterChip$filterChip,
							A2($elm$core$List$map, $author$project$Markup$Html$Attr$Internal$forget, erased),
							ch);
					}),
				A2($elm$core$List$map, $author$project$Markup$Html$Attr$Internal$forget, attributes),
				A2($elm$core$List$map, $author$project$Markup$Element$toNode, children)));
	});
var $author$project$Main$categoryChip = F4(
	function (cur, cat, label_, count) {
		return A2(
			$author$project$M3e$FilterChip$view,
			_List_fromArray(
				[
					$author$project$M3e$FilterChip$selected(
					A2($author$project$Curation$isCategoryEnabled, cat, cur)),
					$author$project$M3e$FilterChip$onClick(
					$author$project$Main$ToggleCategory(cat))
				]),
			A2(
				$elm$core$List$cons,
				$author$project$Seam$text(label_),
				(count > 0) ? _List_fromArray(
					[
						$author$project$M3e$FilterChip$trailingIcon(
						$author$project$Seam$html(
							$author$project$Main$toHtml(
								A2(
									$author$project$M3e$Badge$view,
									_List_Nil,
									_List_fromArray(
										[
											$author$project$Seam$text(
											$elm$core$String$fromInt(count))
										])))))
					]) : _List_Nil));
	});
var $author$project$M3e$Raw$FilterChipSet$multi = function (val_) {
	return val_ ? A2($elm$html$Html$Attributes$attribute, 'multi', '') : $elm$html$Html$Attributes$classList(_List_Nil);
};
var $author$project$M3e$Html$FilterChipSet$multi = $author$project$Markup$Html$Attr$Internal$attribute($author$project$M3e$Raw$FilterChipSet$multi);
var $author$project$M3e$FilterChipSet$multi = $author$project$M3e$Html$FilterChipSet$multi;
var $author$project$M3e$Raw$FilterChipSet$filterChipSet = F2(
	function (attributes, children) {
		return A3(
			$elm$html$Html$node,
			'm3e-filter-chip-set',
			A2(
				$elm$core$List$cons,
				A2($elm$html$Html$Attributes$attribute, 'role', 'group'),
				attributes),
			children);
	});
var $author$project$M3e$Html$FilterChipSet$filterChipSet = F2(
	function (attributes, children) {
		return A2(
			$author$project$M3e$Raw$FilterChipSet$filterChipSet,
			A2($elm$core$List$map, $author$project$Markup$Html$Attr$toAttribute, attributes),
			children);
	});
var $author$project$M3e$FilterChipSet$view = F2(
	function (attributes, children) {
		return $author$project$Markup$Element$Internal$fromNode(
			A3(
				$author$project$Markup$Node$fromComponent,
				F2(
					function (erased, ch) {
						return A2(
							$author$project$M3e$Html$FilterChipSet$filterChipSet,
							A2($elm$core$List$map, $author$project$Markup$Html$Attr$Internal$forget, erased),
							ch);
					}),
				A2($elm$core$List$map, $author$project$Markup$Html$Attr$Internal$forget, attributes),
				A2($elm$core$List$map, $author$project$Markup$Element$toNode, children)));
	});
var $author$project$Main$viewCuration = function (curation) {
	if (curation.$ === 1) {
		return A2(
			$elm$html$Html$p,
			_List_Nil,
			_List_fromArray(
				[
					$elm$html$Html$text('Waiting for context data…')
				]));
	} else {
		var cur = curation.a;
		return A2(
			$elm$html$Html$div,
			_List_Nil,
			_List_fromArray(
				[
					A2(
					$elm$html$Html$p,
					_List_Nil,
					_List_fromArray(
						[
							$elm$html$Html$text('Context to include')
						])),
					$author$project$Main$toHtml(
					A2(
						$author$project$M3e$FilterChipSet$view,
						_List_fromArray(
							[
								$author$project$M3e$FilterChipSet$multi(true)
							]),
						_List_fromArray(
							[
								A4(
								$author$project$Main$categoryChip,
								cur,
								0,
								'Network',
								$elm$core$List$length(cur.T.br)),
								A4(
								$author$project$Main$categoryChip,
								cur,
								1,
								'Console',
								$elm$core$List$length(cur.T.a1)),
								A4(
								$author$project$Main$categoryChip,
								cur,
								2,
								'Events',
								$elm$core$List$length(cur.T.bb)),
								A4(
								$author$project$Main$categoryChip,
								cur,
								3,
								'Errors',
								$elm$core$List$length(cur.T.a9))
							])))
				]));
	}
};
var $author$project$M3e$FormField$label = F2(
	function (id_, el) {
		return A2(
			$author$project$Markup$Element$Internal$placeSlot,
			'label',
			A3($author$project$Markup$Element$withAttr, 'for', id_, el));
	});
var $author$project$M3e$Raw$FormField$variant = $elm$html$Html$Attributes$attribute('variant');
var $author$project$M3e$Html$FormField$variant = function (v_) {
	return A2(
		$author$project$Markup$Html$Attr$Internal$attribute,
		$author$project$M3e$Raw$FormField$variant,
		$author$project$M3e$Token$toString(v_));
};
var $author$project$M3e$FormField$variant = $author$project$M3e$Html$FormField$variant;
var $author$project$M3e$Raw$FormField$formField = $elm$html$Html$node('m3e-form-field');
var $author$project$M3e$Html$FormField$formField = F2(
	function (attributes, children) {
		return A2(
			$author$project$M3e$Raw$FormField$formField,
			A2($elm$core$List$map, $author$project$Markup$Html$Attr$toAttribute, attributes),
			children);
	});
var $author$project$M3e$FormField$view = F2(
	function (attributes, children) {
		return $author$project$Markup$Element$Internal$fromNode(
			A3(
				$author$project$Markup$Node$fromComponent,
				F2(
					function (erased, ch) {
						return A2(
							$author$project$M3e$Html$FormField$formField,
							A2($elm$core$List$map, $author$project$Markup$Html$Attr$Internal$forget, erased),
							ch);
					}),
				A2($elm$core$List$map, $author$project$Markup$Html$Attr$Internal$forget, attributes),
				A2($elm$core$List$map, $author$project$Markup$Element$toNode, children)));
	});
var $author$project$Main$viewField = F3(
	function (id_, label_, controls) {
		return $author$project$Main$toHtml(
			A3(
				$author$project$Markup$Element$withAttr,
				'class',
				'w-full',
				A2(
					$author$project$M3e$FormField$view,
					_List_fromArray(
						[
							$author$project$M3e$FormField$variant($author$project$M3e$Token$outlined)
						]),
					A2(
						$elm$core$List$cons,
						A2(
							$author$project$M3e$FormField$label,
							id_,
							$author$project$Seam$text(label_)),
						controls))));
	});
var $author$project$Main$RequestScreenshot = {$: 6};
var $author$project$Main$RequestUpload = {$: 7};
var $author$project$M3e$SplitButton$leadingButton = function (el) {
	return A2($author$project$Markup$Element$Internal$placeSlot, 'leading-button', el);
};
var $author$project$M3e$Raw$IconButton$onClick = $elm$html$Html$Events$on('click');
var $author$project$M3e$Html$IconButton$onClick = function (f_) {
	return A2(
		$author$project$Markup$Html$Attr$Internal$attribute,
		$author$project$M3e$Raw$IconButton$onClick,
		$elm$json$Json$Decode$succeed(f_));
};
var $author$project$M3e$IconButton$onClick = $author$project$M3e$Html$IconButton$onClick;
var $author$project$M3e$SplitButton$trailingButton = function (el) {
	return A2($author$project$Markup$Element$Internal$placeSlot, 'trailing-button', el);
};
var $author$project$M3e$Raw$IconButton$variant = $elm$html$Html$Attributes$attribute('variant');
var $author$project$M3e$Html$IconButton$variant = function (v_) {
	return A2(
		$author$project$Markup$Html$Attr$Internal$attribute,
		$author$project$M3e$Raw$IconButton$variant,
		$author$project$M3e$Token$toString(v_));
};
var $author$project$M3e$IconButton$variant = $author$project$M3e$Html$IconButton$variant;
var $author$project$M3e$Raw$SplitButton$variant = $elm$html$Html$Attributes$attribute('variant');
var $author$project$M3e$Html$SplitButton$variant = function (v_) {
	return A2(
		$author$project$Markup$Html$Attr$Internal$attribute,
		$author$project$M3e$Raw$SplitButton$variant,
		$author$project$M3e$Token$toString(v_));
};
var $author$project$M3e$SplitButton$variant = $author$project$M3e$Html$SplitButton$variant;
var $author$project$M3e$Raw$IconButton$iconButton = $elm$html$Html$node('m3e-icon-button');
var $author$project$M3e$Html$IconButton$iconButton = F2(
	function (attributes, children) {
		return A2(
			$author$project$M3e$Raw$IconButton$iconButton,
			A2($elm$core$List$map, $author$project$Markup$Html$Attr$toAttribute, attributes),
			children);
	});
var $author$project$M3e$IconButton$view = F2(
	function (attributes, children) {
		return $author$project$Markup$Element$Internal$fromNode(
			A3(
				$author$project$Markup$Node$fromComponent,
				F2(
					function (erased, ch) {
						return A2(
							$author$project$M3e$Html$IconButton$iconButton,
							A2($elm$core$List$map, $author$project$Markup$Html$Attr$Internal$forget, erased),
							ch);
					}),
				A2($elm$core$List$map, $author$project$Markup$Html$Attr$Internal$forget, attributes),
				A2($elm$core$List$map, $author$project$Markup$Element$toNode, children)));
	});
var $author$project$M3e$Raw$SplitButton$splitButton = $elm$html$Html$node('m3e-split-button');
var $author$project$M3e$Html$SplitButton$splitButton = F2(
	function (attributes, children) {
		return A2(
			$author$project$M3e$Raw$SplitButton$splitButton,
			A2($elm$core$List$map, $author$project$Markup$Html$Attr$toAttribute, attributes),
			children);
	});
var $author$project$M3e$SplitButton$view = F2(
	function (attributes, children) {
		return $author$project$Markup$Element$Internal$fromNode(
			A3(
				$author$project$Markup$Node$fromComponent,
				F2(
					function (erased, ch) {
						return A2(
							$author$project$M3e$Html$SplitButton$splitButton,
							A2($elm$core$List$map, $author$project$Markup$Html$Attr$Internal$forget, erased),
							ch);
					}),
				A2($elm$core$List$map, $author$project$Markup$Html$Attr$Internal$forget, attributes),
				A2($elm$core$List$map, $author$project$Markup$Element$toNode, children)));
	});
var $author$project$Main$viewScreenshot = function (attached) {
	return A2(
		$elm$html$Html$div,
		_List_fromArray(
			[
				$elm$html$Html$Attributes$class('flex items-center gap-2')
			]),
		_List_fromArray(
			[
				$author$project$Main$toHtml(
				A2(
					$author$project$M3e$SplitButton$view,
					_List_fromArray(
						[
							$author$project$M3e$SplitButton$variant($author$project$M3e$Token$tonal)
						]),
					_List_fromArray(
						[
							$author$project$M3e$SplitButton$leadingButton(
							A2(
								$author$project$M3e$Button$view,
								_List_fromArray(
									[
										$author$project$M3e$Button$variant($author$project$M3e$Token$tonal),
										$author$project$M3e$Button$onClick($author$project$Main$RequestScreenshot)
									]),
								_List_fromArray(
									[
										$author$project$M3e$Button$icon(
										A2(
											$author$project$M3e$Icon$view,
											_List_fromArray(
												[
													$author$project$M3e$Icon$name('screenshot_monitor')
												]),
											_List_Nil)),
										$author$project$Seam$text(
										attached ? 'Screenshot attached' : 'Attach screenshot')
									]))),
							$author$project$M3e$SplitButton$trailingButton(
							A2(
								$author$project$M3e$IconButton$view,
								_List_fromArray(
									[
										$author$project$M3e$IconButton$variant($author$project$M3e$Token$tonal),
										$author$project$M3e$IconButton$onClick($author$project$Main$RequestUpload)
									]),
								_List_fromArray(
									[
										A2(
										$author$project$M3e$Icon$view,
										_List_fromArray(
											[
												$author$project$M3e$Icon$name('upload')
											]),
										_List_Nil)
									])))
						])))
			]));
};
var $author$project$Main$sheetBody = function (model) {
	return A2(
		$elm$html$Html$div,
		_List_fromArray(
			[
				$elm$html$Html$Attributes$class('ff-sheet-body flex flex-col items-stretch gap-3 pt-1 px-4')
			]),
		_List_fromArray(
			[
				A3(
				$author$project$Main$viewField,
				'feedback-title',
				'Title',
				_List_fromArray(
					[
						$author$project$Seam$html(
						A2(
							$elm$html$Html$input,
							_List_fromArray(
								[
									$elm$html$Html$Attributes$id('feedback-title'),
									$elm$html$Html$Attributes$type_('text')
								]),
							_List_Nil))
					])),
				A3(
				$author$project$Main$viewField,
				'feedback-description',
				'Description',
				_List_fromArray(
					[
						$author$project$Seam$html(
						A2(
							$elm$html$Html$textarea,
							_List_fromArray(
								[
									$elm$html$Html$Attributes$id('feedback-description'),
									$elm$html$Html$Attributes$rows(2),
									$elm$html$Html$Attributes$class('py-2 field-sizing-content max-h-48 resize-none')
								]),
							_List_Nil))
					])),
				$author$project$Main$viewCuration(model.z),
				$author$project$Main$viewScreenshot(model.ao),
				$author$project$Main$viewActions(model)
			]));
};
var $author$project$Main$DashboardTab = 1;
var $author$project$Main$SelectTab = function (a) {
	return {$: 13, a: a};
};
var $author$project$M3e$Raw$Tab$onClick = $elm$html$Html$Events$on('click');
var $author$project$M3e$Html$Tab$onClick = function (f_) {
	return A2(
		$author$project$Markup$Html$Attr$Internal$attribute,
		$author$project$M3e$Raw$Tab$onClick,
		$elm$json$Json$Decode$succeed(f_));
};
var $author$project$M3e$Tab$onClick = $author$project$M3e$Html$Tab$onClick;
var $author$project$M3e$Token$primary = $author$project$Markup$Token$Core$Internal$token('primary');
var $author$project$M3e$Raw$Tab$selected = function (val_) {
	return val_ ? A2($elm$html$Html$Attributes$attribute, 'selected', '') : $elm$html$Html$Attributes$classList(_List_Nil);
};
var $author$project$M3e$Html$Tab$selected = $author$project$Markup$Html$Attr$Internal$attribute($author$project$M3e$Raw$Tab$selected);
var $author$project$M3e$Tab$selected = $author$project$M3e$Html$Tab$selected;
var $author$project$M3e$Raw$Tabs$stretch = function (val_) {
	return val_ ? A2($elm$html$Html$Attributes$attribute, 'stretch', '') : $elm$html$Html$Attributes$classList(_List_Nil);
};
var $author$project$M3e$Html$Tabs$stretch = $author$project$Markup$Html$Attr$Internal$attribute($author$project$M3e$Raw$Tabs$stretch);
var $author$project$M3e$Tabs$stretch = $author$project$M3e$Html$Tabs$stretch;
var $author$project$M3e$Raw$Tabs$variant = $elm$html$Html$Attributes$attribute('variant');
var $author$project$M3e$Html$Tabs$variant = function (v_) {
	return A2(
		$author$project$Markup$Html$Attr$Internal$attribute,
		$author$project$M3e$Raw$Tabs$variant,
		$author$project$M3e$Token$toString(v_));
};
var $author$project$M3e$Tabs$variant = $author$project$M3e$Html$Tabs$variant;
var $author$project$M3e$Raw$Tab$tab = $elm$html$Html$node('m3e-tab');
var $author$project$M3e$Html$Tab$tab = F2(
	function (attributes, children) {
		return A2(
			$author$project$M3e$Raw$Tab$tab,
			A2($elm$core$List$map, $author$project$Markup$Html$Attr$toAttribute, attributes),
			children);
	});
var $author$project$M3e$Tab$view = F2(
	function (attributes, children) {
		return $author$project$Markup$Element$Internal$fromNode(
			A3(
				$author$project$Markup$Node$fromComponent,
				F2(
					function (erased, ch) {
						return A2(
							$author$project$M3e$Html$Tab$tab,
							A2($elm$core$List$map, $author$project$Markup$Html$Attr$Internal$forget, erased),
							ch);
					}),
				A2($elm$core$List$map, $author$project$Markup$Html$Attr$Internal$forget, attributes),
				A2($elm$core$List$map, $author$project$Markup$Element$toNode, children)));
	});
var $author$project$M3e$Raw$Tabs$tabs = $elm$html$Html$node('m3e-tabs');
var $author$project$M3e$Html$Tabs$tabs = F2(
	function (attributes, children) {
		return A2(
			$author$project$M3e$Raw$Tabs$tabs,
			A2($elm$core$List$map, $author$project$Markup$Html$Attr$toAttribute, attributes),
			children);
	});
var $author$project$M3e$Tabs$view = F2(
	function (attributes, children) {
		return $author$project$Markup$Element$Internal$fromNode(
			A3(
				$author$project$Markup$Node$fromComponent,
				F2(
					function (erased, ch) {
						return A2(
							$author$project$M3e$Html$Tabs$tabs,
							A2($elm$core$List$map, $author$project$Markup$Html$Attr$Internal$forget, erased),
							ch);
					}),
				A2($elm$core$List$map, $author$project$Markup$Html$Attr$Internal$forget, attributes),
				A2($elm$core$List$map, $author$project$Markup$Element$toNode, children)));
	});
var $author$project$Main$tabBar = function (model) {
	var badgeCount = $author$project$Main$mergeableBadgeCount(model);
	var dashboardTabChildren = A2(
		$elm$core$List$cons,
		$author$project$Seam$text('Dashboard'),
		(badgeCount > 0) ? _List_fromArray(
			[
				$author$project$Seam$html(
				$author$project$Main$toHtml(
					A3(
						$author$project$Markup$Element$withAttr,
						'class',
						'ff-tab-badge',
						A2(
							$author$project$M3e$Badge$view,
							_List_Nil,
							_List_fromArray(
								[
									$author$project$Seam$text(
									$elm$core$String$fromInt(badgeCount))
								])))))
			]) : _List_Nil);
	return $author$project$Main$toHtml(
		A3(
			$author$project$Markup$Element$withAttr,
			'class',
			'mx-2',
			A2(
				$author$project$M3e$Tabs$view,
				_List_fromArray(
					[
						$author$project$M3e$Tabs$variant($author$project$M3e$Token$primary),
						$author$project$M3e$Tabs$stretch(true)
					]),
				_List_fromArray(
					[
						A2(
						$author$project$M3e$Tab$view,
						_List_fromArray(
							[
								$author$project$M3e$Tab$selected(!model.W),
								$author$project$M3e$Tab$onClick(
								$author$project$Main$SelectTab(0))
							]),
						_List_fromArray(
							[
								$author$project$Seam$text('Feedback')
							])),
						A2(
						$author$project$M3e$Tab$view,
						_List_fromArray(
							[
								$author$project$M3e$Tab$selected(model.W === 1),
								$author$project$M3e$Tab$onClick(
								$author$project$Main$SelectTab(1))
							]),
						dashboardTabChildren)
					]))));
};
var $author$project$Main$sheetContent = function (model) {
	return model.ai ? A2(
		$elm$html$Html$div,
		_List_fromArray(
			[
				$elm$html$Html$Attributes$class('flex flex-col')
			]),
		_List_fromArray(
			[
				$author$project$Main$tabBar(model),
				function () {
				var _v0 = model.W;
				if (!_v0) {
					return $author$project$Main$sheetBody(model);
				} else {
					return $author$project$Main$dashboardPanel(model);
				}
			}()
			])) : $author$project$Main$sheetBody(model);
};
var $author$project$M3e$Raw$AppBar$size = $elm$html$Html$Attributes$attribute('size');
var $author$project$M3e$Html$AppBar$size = function (v_) {
	return A2(
		$author$project$Markup$Html$Attr$Internal$attribute,
		$author$project$M3e$Raw$AppBar$size,
		$author$project$M3e$Token$toString(v_));
};
var $author$project$M3e$AppBar$size = $author$project$M3e$Html$AppBar$size;
var $author$project$M3e$AppBar$title = function (el) {
	return A2($author$project$Markup$Element$Internal$placeSlot, 'title', el);
};
var $author$project$M3e$Raw$AppBar$appBar = $elm$html$Html$node('m3e-app-bar');
var $author$project$M3e$Html$AppBar$appBar = F2(
	function (attributes, children) {
		return A2(
			$author$project$M3e$Raw$AppBar$appBar,
			A2($elm$core$List$map, $author$project$Markup$Html$Attr$toAttribute, attributes),
			children);
	});
var $author$project$M3e$AppBar$view = F2(
	function (attributes, children) {
		return $author$project$Markup$Element$Internal$fromNode(
			A3(
				$author$project$Markup$Node$fromComponent,
				F2(
					function (erased, ch) {
						return A2(
							$author$project$M3e$Html$AppBar$appBar,
							A2($elm$core$List$map, $author$project$Markup$Html$Attr$Internal$forget, erased),
							ch);
					}),
				A2($elm$core$List$map, $author$project$Markup$Html$Attr$Internal$forget, attributes),
				A2($elm$core$List$map, $author$project$Markup$Element$toNode, children)));
	});
var $author$project$M3e$Raw$BottomSheet$bottomSheet = $elm$html$Html$node('m3e-bottom-sheet');
var $author$project$M3e$Html$BottomSheet$bottomSheet = F2(
	function (attributes, children) {
		return A2(
			$author$project$M3e$Raw$BottomSheet$bottomSheet,
			A2($elm$core$List$map, $author$project$Markup$Html$Attr$toAttribute, attributes),
			children);
	});
var $author$project$M3e$BottomSheet$view = F2(
	function (attributes, children) {
		return $author$project$Markup$Element$Internal$fromNode(
			A3(
				$author$project$Markup$Node$fromComponent,
				F2(
					function (erased, ch) {
						return A2(
							$author$project$M3e$Html$BottomSheet$bottomSheet,
							A2($elm$core$List$map, $author$project$Markup$Html$Attr$Internal$forget, erased),
							ch);
					}),
				A2($elm$core$List$map, $author$project$Markup$Html$Attr$Internal$forget, attributes),
				A2($elm$core$List$map, $author$project$Markup$Element$toNode, children)));
	});
var $author$project$Main$viewSheet = function (model) {
	var _v0 = (model.ab === 1) ? _Utils_Tuple2(
		A2(
			$author$project$M3e$LoadingIndicator$view,
			_List_fromArray(
				[
					$author$project$M3e$LoadingIndicator$variant($author$project$M3e$Token$contained)
				]),
			_List_Nil),
		'Submitting Bug Report') : _Utils_Tuple2(
		A2(
			$author$project$M3e$Icon$view,
			_List_fromArray(
				[
					$author$project$M3e$Icon$name('bug_report')
				]),
			_List_Nil),
		'Report a bug');
	var headerIcon = _v0.a;
	var headerTitle = _v0.b;
	return $author$project$Main$toHtml(
		A2(
			$author$project$M3e$BottomSheet$view,
			_List_fromArray(
				[
					$author$project$M3e$BottomSheet$open(model.E === 1),
					$author$project$M3e$BottomSheet$handle(true),
					$author$project$M3e$BottomSheet$hideable(true),
					$author$project$M3e$BottomSheet$detents('fit'),
					$author$project$M3e$BottomSheet$onClosed($author$project$Main$CloseForm)
				]),
			_List_fromArray(
				[
					$author$project$M3e$BottomSheet$header(
					A3(
						$author$project$Markup$Element$withAttr,
						'class',
						'px-4',
						A2(
							$author$project$M3e$AppBar$view,
							_List_fromArray(
								[
									$author$project$M3e$AppBar$size($author$project$M3e$Token$small)
								]),
							_List_fromArray(
								[
									$author$project$M3e$AppBar$leadingIcon(headerIcon),
									$author$project$M3e$AppBar$title(
									$author$project$Seam$text(headerTitle))
								])))),
					$author$project$Seam$html(
					$author$project$Main$sheetContent(model))
				])));
};
var $author$project$Main$view = function (model) {
	return (model.E === 2) ? $elm$html$Html$text('') : A2(
		$elm$html$Html$div,
		_List_Nil,
		_List_fromArray(
			[
				$author$project$Main$viewFab(model),
				$author$project$Main$viewSheet(model)
			]));
};
var $author$project$Main$main = $elm$browser$Browser$element(
	{cv: $author$project$Main$init, c1: $author$project$Main$subscriptions, c4: $author$project$Main$update, c5: $author$project$Main$view});
_Platform_export({'Main':{'init':$author$project$Main$main(
	$elm$json$Json$Decode$succeed(0))(0)}});}(this));
"use strict";(()=>{var Jm=Object.defineProperty;var Qm=(t,e,r)=>e in t?Jm(t,e,{enumerable:!0,configurable:!0,writable:!0,value:r}):t[e]=r;var N=(t,e,r)=>Qm(t,typeof e!="symbol"?e+"":e,r);function h(t,e,r,i){var s=arguments.length,l=s<3?e:i===null?i=Object.getOwnPropertyDescriptor(e,r):i,c;if(typeof Reflect=="object"&&typeof Reflect.decorate=="function")l=Reflect.decorate(t,e,r,i);else for(var d=t.length-1;d>=0;d--)(c=t[d])&&(l=(s<3?c(l):s>3?c(e,r,l):c(e,r))||l);return s>3&&l&&Object.defineProperty(e,r,l),l}function n(t,e,r,i){if(r==="a"&&!i)throw new TypeError("Private accessor was defined without a getter");if(typeof e=="function"?t!==e||!i:!e.has(t))throw new TypeError("Cannot read private member from an object whose class did not declare it");return r==="m"?i:r==="a"?i.call(t):i?i.value:e.get(t)}function f(t,e,r,i,s){if(i==="m")throw new TypeError("Private method is not writable");if(i==="a"&&!s)throw new TypeError("Private accessor was defined without a setter");if(typeof e=="function"?t!==e||!s:!e.has(t))throw new TypeError("Cannot write private member to an object whose class did not declare it");return i==="a"?s.call(t,r):s?s.value=r:e.set(t,r),r}var Sn=globalThis,kn=Sn.ShadowRoot&&(Sn.ShadyCSS===void 0||Sn.ShadyCSS.nativeShadow)&&"adoptedStyleSheets"in Document.prototype&&"replace"in CSSStyleSheet.prototype,Ns=Symbol(),ad=new WeakMap,tr=class{constructor(e,r,i){if(this._$cssResult$=!0,i!==Ns)throw Error("CSSResult is not constructable. Use `unsafeCSS` or `css` instead.");this.cssText=e,this.t=r}get styleSheet(){let e=this.o,r=this.t;if(kn&&e===void 0){let i=r!==void 0&&r.length===1;i&&(e=ad.get(r)),e===void 0&&((this.o=e=new CSSStyleSheet).replaceSync(this.cssText),i&&ad.set(r,e))}return e}toString(){return this.cssText}},o=t=>new tr(typeof t=="string"?t:t+"",void 0,Ns),C=(t,...e)=>{let r=t.length===1?t[0]:e.reduce((i,s,l)=>i+(c=>{if(c._$cssResult$===!0)return c.cssText;if(typeof c=="number")return c;throw Error("Value passed to 'css' function must be a 'css' function result: "+c+". Use 'unsafeCSS' to pass non-literal values, but take care to ensure page security.")})(s)+t[l+1],t[0]);return new tr(r,t,Ns)},rd=(t,e)=>{if(kn)t.adoptedStyleSheets=e.map(r=>r instanceof CSSStyleSheet?r:r.styleSheet);else for(let r of e){let i=document.createElement("style"),s=Sn.litNonce;s!==void 0&&i.setAttribute("nonce",s),i.textContent=r.cssText,t.appendChild(i)}},qs=kn?t=>t:t=>t instanceof CSSStyleSheet?(e=>{let r="";for(let i of e.cssRules)r+=i.cssText;return o(r)})(t):t;var{is:Km,defineProperty:ep,getOwnPropertyDescriptor:tp,getOwnPropertyNames:op,getOwnPropertySymbols:ap,getPrototypeOf:rp}=Object,ao=globalThis,nd=ao.trustedTypes,np=nd?nd.emptyScript:"",ip=ao.reactiveElementPolyfillSupport,or=(t,e)=>t,ar={toAttribute(t,e){switch(e){case Boolean:t=t?np:null;break;case Object:case Array:t=t==null?t:JSON.stringify(t)}return t},fromAttribute(t,e){let r=t;switch(e){case Boolean:r=t!==null;break;case Number:r=t===null?null:Number(t);break;case Object:case Array:try{r=JSON.parse(t)}catch{r=null}}return r}},En=(t,e)=>!Km(t,e),id={attribute:!0,type:String,converter:ar,reflect:!1,useDefault:!1,hasChanged:En};Symbol.metadata??(Symbol.metadata=Symbol("metadata")),ao.litPropertyMetadata??(ao.litPropertyMetadata=new WeakMap);var Bt=class extends HTMLElement{static addInitializer(e){this._$Ei(),(this.l??(this.l=[])).push(e)}static get observedAttributes(){return this.finalize(),this._$Eh&&[...this._$Eh.keys()]}static createProperty(e,r=id){if(r.state&&(r.attribute=!1),this._$Ei(),this.prototype.hasOwnProperty(e)&&((r=Object.create(r)).wrapped=!0),this.elementProperties.set(e,r),!r.noAccessor){let i=Symbol(),s=this.getPropertyDescriptor(e,i,r);s!==void 0&&ep(this.prototype,e,s)}}static getPropertyDescriptor(e,r,i){let{get:s,set:l}=tp(this.prototype,e)??{get(){return this[r]},set(c){this[r]=c}};return{get:s,set(c){let d=s?.call(this);l?.call(this,c),this.requestUpdate(e,d,i)},configurable:!0,enumerable:!0}}static getPropertyOptions(e){return this.elementProperties.get(e)??id}static _$Ei(){if(this.hasOwnProperty(or("elementProperties")))return;let e=rp(this);e.finalize(),e.l!==void 0&&(this.l=[...e.l]),this.elementProperties=new Map(e.elementProperties)}static finalize(){if(this.hasOwnProperty(or("finalized")))return;if(this.finalized=!0,this._$Ei(),this.hasOwnProperty(or("properties"))){let r=this.properties,i=[...op(r),...ap(r)];for(let s of i)this.createProperty(s,r[s])}let e=this[Symbol.metadata];if(e!==null){let r=litPropertyMetadata.get(e);if(r!==void 0)for(let[i,s]of r)this.elementProperties.set(i,s)}this._$Eh=new Map;for(let[r,i]of this.elementProperties){let s=this._$Eu(r,i);s!==void 0&&this._$Eh.set(s,r)}this.elementStyles=this.finalizeStyles(this.styles)}static finalizeStyles(e){let r=[];if(Array.isArray(e)){let i=new Set(e.flat(1/0).reverse());for(let s of i)r.unshift(qs(s))}else e!==void 0&&r.push(qs(e));return r}static _$Eu(e,r){let i=r.attribute;return i===!1?void 0:typeof i=="string"?i:typeof e=="string"?e.toLowerCase():void 0}constructor(){super(),this._$Ep=void 0,this.isUpdatePending=!1,this.hasUpdated=!1,this._$Em=null,this._$Ev()}_$Ev(){this._$ES=new Promise(e=>this.enableUpdating=e),this._$AL=new Map,this._$E_(),this.requestUpdate(),this.constructor.l?.forEach(e=>e(this))}addController(e){(this._$EO??(this._$EO=new Set)).add(e),this.renderRoot!==void 0&&this.isConnected&&e.hostConnected?.()}removeController(e){this._$EO?.delete(e)}_$E_(){let e=new Map,r=this.constructor.elementProperties;for(let i of r.keys())this.hasOwnProperty(i)&&(e.set(i,this[i]),delete this[i]);e.size>0&&(this._$Ep=e)}createRenderRoot(){let e=this.shadowRoot??this.attachShadow(this.constructor.shadowRootOptions);return rd(e,this.constructor.elementStyles),e}connectedCallback(){this.renderRoot??(this.renderRoot=this.createRenderRoot()),this.enableUpdating(!0),this._$EO?.forEach(e=>e.hostConnected?.())}enableUpdating(e){}disconnectedCallback(){this._$EO?.forEach(e=>e.hostDisconnected?.())}attributeChangedCallback(e,r,i){this._$AK(e,i)}_$ET(e,r){let i=this.constructor.elementProperties.get(e),s=this.constructor._$Eu(e,i);if(s!==void 0&&i.reflect===!0){let l=(i.converter?.toAttribute!==void 0?i.converter:ar).toAttribute(r,i.type);this._$Em=e,l==null?this.removeAttribute(s):this.setAttribute(s,l),this._$Em=null}}_$AK(e,r){let i=this.constructor,s=i._$Eh.get(e);if(s!==void 0&&this._$Em!==s){let l=i.getPropertyOptions(s),c=typeof l.converter=="function"?{fromAttribute:l.converter}:l.converter?.fromAttribute!==void 0?l.converter:ar;this._$Em=s;let d=c.fromAttribute(r,l.type);this[s]=d??this._$Ej?.get(s)??d,this._$Em=null}}requestUpdate(e,r,i,s=!1,l){if(e!==void 0){let c=this.constructor;if(s===!1&&(l=this[e]),i??(i=c.getPropertyOptions(e)),!((i.hasChanged??En)(l,r)||i.useDefault&&i.reflect&&l===this._$Ej?.get(e)&&!this.hasAttribute(c._$Eu(e,i))))return;this.C(e,r,i)}this.isUpdatePending===!1&&(this._$ES=this._$EP())}C(e,r,{useDefault:i,reflect:s,wrapped:l},c){i&&!(this._$Ej??(this._$Ej=new Map)).has(e)&&(this._$Ej.set(e,c??r??this[e]),l!==!0||c!==void 0)||(this._$AL.has(e)||(this.hasUpdated||i||(r=void 0),this._$AL.set(e,r)),s===!0&&this._$Em!==e&&(this._$Eq??(this._$Eq=new Set)).add(e))}async _$EP(){this.isUpdatePending=!0;try{await this._$ES}catch(r){Promise.reject(r)}let e=this.scheduleUpdate();return e!=null&&await e,!this.isUpdatePending}scheduleUpdate(){return this.performUpdate()}performUpdate(){if(!this.isUpdatePending)return;if(!this.hasUpdated){if(this.renderRoot??(this.renderRoot=this.createRenderRoot()),this._$Ep){for(let[s,l]of this._$Ep)this[s]=l;this._$Ep=void 0}let i=this.constructor.elementProperties;if(i.size>0)for(let[s,l]of i){let{wrapped:c}=l,d=this[s];c!==!0||this._$AL.has(s)||d===void 0||this.C(s,void 0,l,d)}}let e=!1,r=this._$AL;try{e=this.shouldUpdate(r),e?(this.willUpdate(r),this._$EO?.forEach(i=>i.hostUpdate?.()),this.update(r)):this._$EM()}catch(i){throw e=!1,this._$EM(),i}e&&this._$AE(r)}willUpdate(e){}_$AE(e){this._$EO?.forEach(r=>r.hostUpdated?.()),this.hasUpdated||(this.hasUpdated=!0,this.firstUpdated(e)),this.updated(e)}_$EM(){this._$AL=new Map,this.isUpdatePending=!1}get updateComplete(){return this.getUpdateComplete()}getUpdateComplete(){return this._$ES}shouldUpdate(e){return!0}update(e){this._$Eq&&(this._$Eq=this._$Eq.forEach(r=>this._$ET(r,this[r]))),this._$EM()}updated(e){}firstUpdated(e){}};Bt.elementStyles=[],Bt.shadowRootOptions={mode:"open"},Bt[or("elementProperties")]=new Map,Bt[or("finalized")]=new Map,ip?.({ReactiveElement:Bt}),(ao.reactiveElementVersions??(ao.reactiveElementVersions=[])).push("2.1.2");var nr=globalThis,sd=t=>t,Mn=nr.trustedTypes,ld=Mn?Mn.createPolicy("lit-html",{createHTML:t=>t}):void 0,pd="$lit$",ro=`lit$${Math.random().toFixed(9).slice(2)}$`,fd="?"+ro,sp=`<${fd}>`,So=document,ir=()=>So.createComment(""),sr=t=>t===null||typeof t!="object"&&typeof t!="function",Zs=Array.isArray,lp=t=>Zs(t)||typeof t?.[Symbol.iterator]=="function",Vs=`[ 	
\f\r]`,rr=/<(?:(!--|\/[^a-zA-Z])|(\/?[a-zA-Z][^>\s]*)|(\/?$))/g,cd=/-->/g,dd=/>/g,$o=RegExp(`>|${Vs}(?:([^\\s"'>=/]+)(${Vs}*=${Vs}*(?:[^ 	
\f\r"'\`<>=]|("|')|))|$)`,"g"),hd=/'/g,ud=/"/g,bd=/^(?:script|style|textarea|title)$/i,Js=t=>(e,...r)=>({_$litType$:t,strings:e,values:r}),w=Js(1),Qs=Js(2),Gb=Js(3),Dt=Symbol.for("lit-noChange"),F=Symbol.for("lit-nothing"),md=new WeakMap,Co=So.createTreeWalker(So,129);function vd(t,e){if(!Zs(t)||!t.hasOwnProperty("raw"))throw Error("invalid template strings array");return ld!==void 0?ld.createHTML(e):e}var cp=(t,e)=>{let r=t.length-1,i=[],s,l=e===2?"<svg>":e===3?"<math>":"",c=rr;for(let d=0;d<r;d++){let u=t[d],p,g,m=-1,y=0;for(;y<u.length&&(c.lastIndex=y,g=c.exec(u),g!==null);)y=c.lastIndex,c===rr?g[1]==="!--"?c=cd:g[1]!==void 0?c=dd:g[2]!==void 0?(bd.test(g[2])&&(s=RegExp("</"+g[2],"g")),c=$o):g[3]!==void 0&&(c=$o):c===$o?g[0]===">"?(c=s??rr,m=-1):g[1]===void 0?m=-2:(m=c.lastIndex-g[2].length,p=g[1],c=g[3]===void 0?$o:g[3]==='"'?ud:hd):c===ud||c===hd?c=$o:c===cd||c===dd?c=rr:(c=$o,s=void 0);let v=c===$o&&t[d+1].startsWith("/>")?" ":"";l+=c===rr?u+sp:m>=0?(i.push(p),u.slice(0,m)+pd+u.slice(m)+ro+v):u+ro+(m===-2?d:v)}return[vd(t,l+(t[r]||"<?>")+(e===2?"</svg>":e===3?"</math>":"")),i]},lr=class t{constructor({strings:e,_$litType$:r},i){let s;this.parts=[];let l=0,c=0,d=e.length-1,u=this.parts,[p,g]=cp(e,r);if(this.el=t.createElement(p,i),Co.currentNode=this.el.content,r===2||r===3){let m=this.el.content.firstChild;m.replaceWith(...m.childNodes)}for(;(s=Co.nextNode())!==null&&u.length<d;){if(s.nodeType===1){if(s.hasAttributes())for(let m of s.getAttributeNames())if(m.endsWith(pd)){let y=g[c++],v=s.getAttribute(m).split(ro),x=/([.?@])?(.*)/.exec(y);u.push({type:1,index:l,name:x[2],strings:v,ctor:x[1]==="."?js:x[1]==="?"?Gs:x[1]==="@"?Ys:wa}),s.removeAttribute(m)}else m.startsWith(ro)&&(u.push({type:6,index:l}),s.removeAttribute(m));if(bd.test(s.tagName)){let m=s.textContent.split(ro),y=m.length-1;if(y>0){s.textContent=Mn?Mn.emptyScript:"";for(let v=0;v<y;v++)s.append(m[v],ir()),Co.nextNode(),u.push({type:2,index:++l});s.append(m[y],ir())}}}else if(s.nodeType===8)if(s.data===fd)u.push({type:2,index:l});else{let m=-1;for(;(m=s.data.indexOf(ro,m+1))!==-1;)u.push({type:7,index:l}),m+=ro.length-1}l++}}static createElement(e,r){let i=So.createElement("template");return i.innerHTML=e,i}};function xa(t,e,r=t,i){if(e===Dt)return e;let s=i!==void 0?r._$Co?.[i]:r._$Cl,l=sr(e)?void 0:e._$litDirective$;return s?.constructor!==l&&(s?._$AO?.(!1),l===void 0?s=void 0:(s=new l(t),s._$AT(t,r,i)),i!==void 0?(r._$Co??(r._$Co=[]))[i]=s:r._$Cl=s),s!==void 0&&(e=xa(t,s._$AS(t,e.values),s,i)),e}var Us=class{constructor(e,r){this._$AV=[],this._$AN=void 0,this._$AD=e,this._$AM=r}get parentNode(){return this._$AM.parentNode}get _$AU(){return this._$AM._$AU}u(e){let{el:{content:r},parts:i}=this._$AD,s=(e?.creationScope??So).importNode(r,!0);Co.currentNode=s;let l=Co.nextNode(),c=0,d=0,u=i[0];for(;u!==void 0;){if(c===u.index){let p;u.type===2?p=new cr(l,l.nextSibling,this,e):u.type===1?p=new u.ctor(l,u.name,u.strings,this,e):u.type===6&&(p=new Xs(l,this,e)),this._$AV.push(p),u=i[++d]}c!==u?.index&&(l=Co.nextNode(),c++)}return Co.currentNode=So,s}p(e){let r=0;for(let i of this._$AV)i!==void 0&&(i.strings!==void 0?(i._$AI(e,i,r),r+=i.strings.length-2):i._$AI(e[r])),r++}},cr=class t{get _$AU(){return this._$AM?._$AU??this._$Cv}constructor(e,r,i,s){this.type=2,this._$AH=F,this._$AN=void 0,this._$AA=e,this._$AB=r,this._$AM=i,this.options=s,this._$Cv=s?.isConnected??!0}get parentNode(){let e=this._$AA.parentNode,r=this._$AM;return r!==void 0&&e?.nodeType===11&&(e=r.parentNode),e}get startNode(){return this._$AA}get endNode(){return this._$AB}_$AI(e,r=this){e=xa(this,e,r),sr(e)?e===F||e==null||e===""?(this._$AH!==F&&this._$AR(),this._$AH=F):e!==this._$AH&&e!==Dt&&this._(e):e._$litType$!==void 0?this.$(e):e.nodeType!==void 0?this.T(e):lp(e)?this.k(e):this._(e)}O(e){return this._$AA.parentNode.insertBefore(e,this._$AB)}T(e){this._$AH!==e&&(this._$AR(),this._$AH=this.O(e))}_(e){this._$AH!==F&&sr(this._$AH)?this._$AA.nextSibling.data=e:this.T(So.createTextNode(e)),this._$AH=e}$(e){let{values:r,_$litType$:i}=e,s=typeof i=="number"?this._$AC(e):(i.el===void 0&&(i.el=lr.createElement(vd(i.h,i.h[0]),this.options)),i);if(this._$AH?._$AD===s)this._$AH.p(r);else{let l=new Us(s,this),c=l.u(this.options);l.p(r),this.T(c),this._$AH=l}}_$AC(e){let r=md.get(e.strings);return r===void 0&&md.set(e.strings,r=new lr(e)),r}k(e){Zs(this._$AH)||(this._$AH=[],this._$AR());let r=this._$AH,i,s=0;for(let l of e)s===r.length?r.push(i=new t(this.O(ir()),this.O(ir()),this,this.options)):i=r[s],i._$AI(l),s++;s<r.length&&(this._$AR(i&&i._$AB.nextSibling,s),r.length=s)}_$AR(e=this._$AA.nextSibling,r){for(this._$AP?.(!1,!0,r);e!==this._$AB;){let i=sd(e).nextSibling;sd(e).remove(),e=i}}setConnected(e){this._$AM===void 0&&(this._$Cv=e,this._$AP?.(e))}},wa=class{get tagName(){return this.element.tagName}get _$AU(){return this._$AM._$AU}constructor(e,r,i,s,l){this.type=1,this._$AH=F,this._$AN=void 0,this.element=e,this.name=r,this._$AM=s,this.options=l,i.length>2||i[0]!==""||i[1]!==""?(this._$AH=Array(i.length-1).fill(new String),this.strings=i):this._$AH=F}_$AI(e,r=this,i,s){let l=this.strings,c=!1;if(l===void 0)e=xa(this,e,r,0),c=!sr(e)||e!==this._$AH&&e!==Dt,c&&(this._$AH=e);else{let d=e,u,p;for(e=l[0],u=0;u<l.length-1;u++)p=xa(this,d[i+u],r,u),p===Dt&&(p=this._$AH[u]),c||(c=!sr(p)||p!==this._$AH[u]),p===F?e=F:e!==F&&(e+=(p??"")+l[u+1]),this._$AH[u]=p}c&&!s&&this.j(e)}j(e){e===F?this.element.removeAttribute(this.name):this.element.setAttribute(this.name,e??"")}},js=class extends wa{constructor(){super(...arguments),this.type=3}j(e){this.element[this.name]=e===F?void 0:e}},Gs=class extends wa{constructor(){super(...arguments),this.type=4}j(e){this.element.toggleAttribute(this.name,!!e&&e!==F)}},Ys=class extends wa{constructor(e,r,i,s,l){super(e,r,i,s,l),this.type=5}_$AI(e,r=this){if((e=xa(this,e,r,0)??F)===Dt)return;let i=this._$AH,s=e===F&&i!==F||e.capture!==i.capture||e.once!==i.once||e.passive!==i.passive,l=e!==F&&(i===F||s);s&&this.element.removeEventListener(this.name,this,i),l&&this.element.addEventListener(this.name,this,e),this._$AH=e}handleEvent(e){typeof this._$AH=="function"?this._$AH.call(this.options?.host??this.element,e):this._$AH.handleEvent(e)}},Xs=class{constructor(e,r,i){this.element=e,this.type=6,this._$AN=void 0,this._$AM=r,this.options=i}get _$AU(){return this._$AM._$AU}_$AI(e){xa(this,e)}};var dp=nr.litHtmlPolyfillSupport;dp?.(lr,cr),(nr.litHtmlVersions??(nr.litHtmlVersions=[])).push("3.3.3");var gd=(t,e,r)=>{let i=r?.renderBefore??e,s=i._$litPart$;if(s===void 0){let l=r?.renderBefore??null;i._$litPart$=s=new cr(e.insertBefore(ir(),l),l,void 0,r??{})}return s._$AI(t),s};var dr=globalThis,P=class extends Bt{constructor(){super(...arguments),this.renderOptions={host:this},this._$Do=void 0}createRenderRoot(){var r;let e=super.createRenderRoot();return(r=this.renderOptions).renderBefore??(r.renderBefore=e.firstChild),e}update(e){let r=this.render();this.hasUpdated||(this.renderOptions.isConnected=this.isConnected),super.update(e),this._$Do=gd(r,this.renderRoot,this.renderOptions)}connectedCallback(){super.connectedCallback(),this._$Do?.setConnected(!0)}disconnectedCallback(){super.disconnectedCallback(),this._$Do?.setConnected(!1)}render(){return Dt}};P._$litElement$=!0,P.finalized=!0,dr.litElementHydrateSupport?.({LitElement:P});var hp=dr.litElementPolyfillSupport;hp?.({LitElement:P});(dr.litElementVersions??(dr.litElementVersions=[])).push("4.2.2");var up={attribute:!0,type:String,converter:ar,reflect:!1,hasChanged:En},mp=(t=up,e,r)=>{let{kind:i,metadata:s}=r,l=globalThis.litPropertyMetadata.get(s);if(l===void 0&&globalThis.litPropertyMetadata.set(s,l=new Map),i==="setter"&&((t=Object.create(t)).wrapped=!0),l.set(r.name,t),i==="accessor"){let{name:c}=r;return{set(d){let u=e.get.call(this);e.set.call(this,d),this.requestUpdate(c,u,t,!0,d)},init(d){return d!==void 0&&this.C(c,void 0,t,d),d}}}if(i==="setter"){let{name:c}=r;return function(d){let u=this[c];e.call(this,d),this.requestUpdate(c,u,t,!0,d)}}throw Error("Unsupported decorator location: "+i)};function b(t){return(e,r)=>typeof r=="object"?mp(t,e,r):((i,s,l)=>{let c=s.hasOwnProperty(l);return s.constructor.createProperty(l,i),c?Object.getOwnPropertyDescriptor(s,l):void 0})(t,e,r)}function mt(t){return b({...t,state:!0,attribute:!1})}var no=(t,e,r)=>(r.configurable=!0,r.enumerable=!0,Reflect.decorate&&typeof e!="object"&&Object.defineProperty(t,e,r),r);function M(t,e){return(r,i,s)=>{let l=c=>c.renderRoot?.querySelector(t)??null;if(e){let{get:c,set:d}=typeof i=="object"?r:s??(()=>{let u=Symbol();return{get(){return this[u]},set(p){this[u]=p}}})();return no(r,i,{get(){let u=c.call(this);return u===void 0&&(u=l(this),(u!==null||this.hasUpdated)&&d.call(this,u)),u}})}return no(r,i,{get(){return l(this)}})}}function yd(t){return(e,r)=>{let{slot:i,selector:s}=t??{},l="slot"+(i?`[name=${i}]`:":not([name])");return no(e,r,{get(){let c=this.renderRoot?.querySelector(l),d=c?.assignedElements(t)??[];return s===void 0?d:d.filter(u=>u.matches(s))}})}}var xd={ATTRIBUTE:1,CHILD:2,PROPERTY:3,BOOLEAN_ATTRIBUTE:4,EVENT:5,ELEMENT:6},wd=t=>(...e)=>({_$litDirective$:t,values:e}),Ln=class{constructor(e){}get _$AU(){return this._$AM._$AU}_$AT(e,r,i){this._$Ct=e,this._$AM=r,this._$Ci=i}_$AS(e,r){return this.update(e,r)}update(e,r){return this.render(...r)}};var io=t=>t??F;var pp,fp,bp,vp,gp;pp=new WeakMap,fp=new WeakMap,bp=new WeakMap,vp=new WeakMap,gp=new WeakMap;var hr,ur,Mt,qt=class{constructor(e,r){hr.set(this,void 0),ur.set(this,void 0),Mt.set(this,new Set),f(this,hr,e,"f"),f(this,ur,r.target,"f"),n(this,hr,"f").addController(this)}get targets(){return n(this,Mt,"f").values()}get hasTargets(){return n(this,Mt,"f").size>0}hostConnected(){n(this,ur,"f")!==null&&this.observe(n(this,ur,"f")??n(this,hr,"f"))}hostDisconnected(){this.unobserveAll()}observe(e){n(this,Mt,"f").has(e)||(n(this,Mt,"f").add(e),this._observe(e))}isObserving(e){return n(this,Mt,"f").has(e)}unobserve(e){n(this,Mt,"f").delete(e)&&this._unobserve(e)}unobserveAll(){n(this,Mt,"f").forEach(e=>this.unobserve(e)),n(this,Mt,"f").clear()}};hr=new WeakMap,ur=new WeakMap,Mt=new WeakMap;var rl,si,In,ka,Sd,Ar=class extends qt{constructor(e,r){super(e,r),rl.add(this),si.set(this,void 0),In.set(this,i=>n(this,rl,"m",Sd).call(this,i)),ka.set(this,!1),f(this,si,r.callback,"f")}_observe(){n(this,ka,"f")||(document.addEventListener("click",n(this,In,"f")),f(this,ka,!0,"f"))}_unobserve(){!this.hasTargets&&n(this,ka,"f")&&(document.removeEventListener("click",n(this,In,"f")),f(this,ka,!1,"f"))}};si=new WeakMap,In=new WeakMap,ka=new WeakMap,rl=new WeakSet,Sd=function(e){let r=e.composedPath();r.some(i=>i instanceof HTMLElement&&this.isObserving(i))||n(this,si,"f").call(this,r)};function kd(){return!!1&&matchMedia("(forced-colors: active)").matches}function Ce(){return matchMedia("(prefers-reduced-motion)").matches}function Ed(t,e=document){return new Promise(r=>{let i=e.querySelector(`#${t}`);if(i){r(i);return}if(document.readyState==="complete"||document.readyState==="interactive"){r(e.querySelector(`#${t}`));return}document.addEventListener("DOMContentLoaded",()=>r(e.querySelector(`#${t}`)),{once:!0})})}var ft,zn,Bo=class{constructor(e=100){ft.set(this,[]),zn.set(this,void 0),f(this,zn,e,"f")}add(e,r=performance.now()){n(this,ft,"f").push({y:e,t:r});let i=r-n(this,zn,"f");for(;n(this,ft,"f").length>1&&n(this,ft,"f")[0].t<i;)n(this,ft,"f").shift()}getVelocity(){if(n(this,ft,"f").length<2)return 0;let e=n(this,ft,"f")[0],r=n(this,ft,"f")[n(this,ft,"f").length-1],i=r.y-e.y,s=(r.t-e.t)/1e3;return s>0?i/s:0}reset(){n(this,ft,"f").length=0}};ft=new WeakMap,zn=new WeakMap;var Pa,zo,Ia,kr,Aa,Fn,On,Rn,Bn,Ea,li,Md,nl,Ld,je=class extends qt{constructor(e,r){super(e,r),Pa.add(this),Ia.set(this,!1),kr.set(this,void 0),Aa.set(this,void 0),Fn.set(this,i=>n(this,Pa,"m",Md).call(this,i)),On.set(this,i=>n(this,Pa,"m",nl).call(this,i)),Rn.set(this,i=>n(this,Pa,"m",Ld).call(this,i)),Bn.set(this,()=>f(this,Ia,!0,"f")),Ea.set(this,()=>f(this,Ia,!1,"f")),f(this,kr,r.callback,"f"),f(this,Aa,r.filter,"f")}_observe(e){e.addEventListener("keydown",n(this,Fn,"f")),e.addEventListener("focusin",n(this,On,"f")),e.addEventListener("focusout",n(this,Rn,"f")),e.addEventListener("touchstart",n(this,Bn,"f"),{passive:!0}),e.addEventListener("touchend",n(this,Ea,"f")),e.addEventListener("touchcancel",n(this,Ea,"f"))}_unobserve(e){e.removeEventListener("keydown",n(this,Fn,"f")),e.removeEventListener("focusin",n(this,On,"f")),e.removeEventListener("focusout",n(this,Rn,"f")),e.removeEventListener("touchstart",n(this,Bn,"f")),e.removeEventListener("touchend",n(this,Ea,"f")),e.removeEventListener("touchcancel",n(this,Ea,"f"))}};zo=je,Ia=new WeakMap,kr=new WeakMap,Aa=new WeakMap,Fn=new WeakMap,On=new WeakMap,Rn=new WeakMap,Bn=new WeakMap,Ea=new WeakMap,Pa=new WeakSet,Md=function(e){if(n(this,Aa,"f")?.call(this,e))return;e.currentTarget.matches(":focus-within")&&n(this,Pa,"m",nl).call(this,e)},nl=function(e){if(n(this,Aa,"f")?.call(this,e)||n(this,Ia,"f"))return;let r=e.currentTarget;n(this,kr,"f").call(this,!0,r.matches(":focus-visible")||n(zo,zo,"f",li)||kd(),r)},Ld=function(e){n(this,Aa,"f")?.call(this,e)||n(this,Ia,"f")||n(this,kr,"f").call(this,!1,!1,e.currentTarget)};typeof window<"u"&&(window.addEventListener("keydown",()=>f(zo,zo,!0,"f",li),{capture:!0,passive:!0}),window.addEventListener("pointerdown",()=>f(zo,zo,!1,"f",li),{capture:!0}));li={value:!1};var at,Io,Eo,Mo,Dn,Ma,il,Tn,Pn,Td,Pd,Vt=class extends qt{constructor(e,r){super(e,r),at.add(this),Io.set(this,void 0),Eo.set(this,new Map),Mo.set(this,new Map),Dn.set(this,i=>n(this,at,"m",Td).call(this,i)),Ma.set(this,i=>n(this,at,"m",Pd).call(this,i)),f(this,Io,r.callback,"f"),this.startDelay=r.startDelay??0,this.endDelay=r.endDelay??0}clearDelays(){for(let e of this.targets)n(this,at,"m",il).call(this,e)}_observe(e){e.addEventListener("pointerenter",n(this,Dn,"f")),e.addEventListener("pointerleave",n(this,Ma,"f")),e.addEventListener("touchend",n(this,Ma,"f"))}_unobserve(e){e.removeEventListener("pointerenter",n(this,Dn,"f")),e.removeEventListener("pointerleave",n(this,Ma,"f")),e.removeEventListener("touchend",n(this,Ma,"f")),n(this,at,"m",il).call(this,e)}};Io=new WeakMap,Eo=new WeakMap,Mo=new WeakMap,Dn=new WeakMap,Ma=new WeakMap,at=new WeakSet,il=function(e){n(this,at,"m",Tn).call(this,e),n(this,at,"m",Pn).call(this,e)},Tn=function(e){return n(this,Eo,"f").has(e)?(clearTimeout(n(this,Eo,"f").get(e)),n(this,Eo,"f").delete(e)):!1},Pn=function(e){return n(this,Mo,"f").has(e)?(clearTimeout(n(this,Mo,"f").get(e)),n(this,Mo,"f").delete(e)):!1},Td=function(e){let r=e.target;n(this,at,"m",Pn).call(this,r),this.startDelay>0?(n(this,at,"m",Tn).call(this,r),n(this,Eo,"f").set(r,setTimeout(()=>{n(this,Eo,"f").delete(r),n(this,Io,"f").call(this,!0,r)},this.startDelay))):n(this,Io,"f").call(this,!0,r)},Pd=function(e){let r=e.target;n(this,at,"m",Tn).call(this,r)||(this.endDelay>0?(n(this,at,"m",Pn).call(this,r),n(this,Mo,"f").set(r,setTimeout(()=>{n(this,Mo,"f").delete(r),n(this,Io,"f").call(this,!1,r)},this.endDelay))):n(this,Io,"f").call(this,!1,r))};var Hn,mr,Ir=class{constructor(e){Hn.set(this,void 0),mr.set(this,new Array),f(this,Hn,e,"f"),e.addController(this)}lock(){this.unlock();for(let e=n(this,Hn,"f");e.parentNode&&e.parentNode!==document.documentElement;e=e.parentNode)for(let r of e.parentNode.children)r instanceof HTMLElement&&r!==e&&!r.inert&&(r.inert=!0,n(this,mr,"f").push(r))}unlock(){n(this,mr,"f").forEach(e=>e.inert=!1),n(this,mr,"f").length=0}hostDisconnected(){this.unlock()}};Hn=new WeakMap,mr=new WeakMap;var yp,xp,wp,_p;yp=new WeakMap,xp=new WeakMap,wp=new WeakMap,_p=new WeakMap;var $p,Ks,_d,An,_a,Cp,Sp,kp,Ep;Ks=new WeakMap,_d=new WeakMap,An=new WeakMap,_a=new WeakMap,Cp=new WeakMap,Sp=new WeakMap,$p=new WeakSet,kp=function(e){if(e.currentTarget instanceof HTMLElement&&this.isObserving(e.currentTarget)){let r=e.currentTarget;n(this,_a,"f").set(r,setTimeout(()=>{n(this,An,"f").add(r),n(this,_a,"f").delete(r),n(this,Ks,"f").call(this,!0,r)},n(this,_d,"f")))}},Ep=function(e){if(e.currentTarget instanceof HTMLElement&&this.isObserving(e.currentTarget)){let r=e.currentTarget;n(this,An,"f").has(r)&&(n(this,Ks,"f").call(this,!1,r),n(this,An,"f").delete(r)),n(this,_a,"f").has(r)&&(clearTimeout(n(this,_a,"f").get(r)),n(this,_a,"f").delete(r))}};var pr,Wn,fr,Lt,br,Ut=class extends qt{constructor(e,r){if(super(e,r),pr.set(this,void 0),Wn.set(this,!1),fr.set(this,void 0),Lt.set(this,void 0),br.set(this,!0),f(this,pr,r.callback,"f"),f(this,Wn,r.skipInitial??!1,"f"),f(this,fr,r.config,"f"),!!1){if(!window.MutationObserver){console.warn("MutationController error: the browser does not support MutationObserver.");return}f(this,Lt,new MutationObserver((i,s)=>n(this,pr,"f").call(this,i,s)),"f")}}async hostUpdated(){if(n(this,Lt,"f")&&!n(this,Wn,"f")&&n(this,br,"f")){let e=n(this,Lt,"f").takeRecords();e.length>0&&n(this,pr,"f").call(this,e,n(this,Lt,"f"))}f(this,br,!1,"f")}hostDisconnected(){super.hostDisconnected(),n(this,Lt,"f")?.disconnect()}_observe(e){n(this,Lt,"f")?.observe(e,n(this,fr,"f")),f(this,br,!0,"f")}_unobserve(){n(this,Lt,"f")?.disconnect();for(let e of this.targets)n(this,Lt,"f")?.observe(e,n(this,fr,"f"))}};pr=new WeakMap,Wn=new WeakMap,fr=new WeakMap,Lt=new WeakMap,br=new WeakMap;var Wt,Pe,Ht,Er,Fo,Re,Mr,Nn,qn,La,Vn,Un,Ad,Id,zd,Fd,Od,el,fe=class extends qt{constructor(e,r){super(e,r),Wt.add(this),Pe.set(this,void 0),Ht.set(this,void 0),Er.set(this,void 0),Fo.set(this,void 0),Re.set(this,new Map),Mr.set(this,void 0),Nn.set(this,i=>n(this,Wt,"m",Ad).call(this,i)),qn.set(this,i=>n(this,Wt,"m",Id).call(this,i)),La.set(this,i=>n(this,Wt,"m",zd).call(this,i)),Vn.set(this,i=>n(this,Wt,"m",Fd).call(this,i)),Un.set(this,i=>n(this,Wt,"m",Od).call(this,i)),f(this,Pe,r.capture,"f"),f(this,Ht,r.callback,"f"),f(this,Er,r.filter,"f"),f(this,Fo,r.isPressedKey,"f"),f(this,Mr,r.minPressedDuration??0,"f")}hostConnected(){document.addEventListener("pointerup",n(this,qn,"f"),{capture:n(this,Pe,"f")}),document.addEventListener("touchend",n(this,La,"f"),{capture:n(this,Pe,"f")}),document.addEventListener("touchcancel",n(this,La,"f"),{capture:n(this,Pe,"f")}),super.hostConnected()}hostDisconnected(){document.removeEventListener("pointerup",n(this,qn,"f"),{capture:n(this,Pe,"f")}),document.removeEventListener("touchend",n(this,La,"f"),{capture:n(this,Pe,"f")}),document.removeEventListener("touchcancel",n(this,La,"f"),{capture:n(this,Pe,"f")}),super.hostDisconnected(),n(this,Re,"f").clear()}_observe(e){e.addEventListener("pointerdown",n(this,Nn,"f"),{capture:n(this,Pe,"f")}),n(this,Fo,"f")&&(e.addEventListener("keydown",n(this,Vn,"f"),{capture:n(this,Pe,"f")}),e.addEventListener("keyup",n(this,Un,"f"),{capture:n(this,Pe,"f")}))}_unobserve(e){e.removeEventListener("pointerdown",n(this,Nn,"f"),{capture:n(this,Pe,"f")}),n(this,Fo,"f")&&(e.removeEventListener("keydown",n(this,Vn,"f"),{capture:n(this,Pe,"f")}),e.removeEventListener("keyup",n(this,Un,"f"),{capture:n(this,Pe,"f")}))}};Pe=new WeakMap,Ht=new WeakMap,Er=new WeakMap,Fo=new WeakMap,Re=new WeakMap,Mr=new WeakMap,Nn=new WeakMap,qn=new WeakMap,La=new WeakMap,Vn=new WeakMap,Un=new WeakMap,Wt=new WeakSet,Ad=function(e){if(!n(this,Er,"f")?.call(this,e)&&!(e.pointerType==="mouse"&&e.button>1)){for(let r of e.composedPath())if(r instanceof HTMLElement&&this.isObserving(r)){n(this,Re,"f").has(r)||(n(this,Re,"f").set(r,performance.now()),n(this,Ht,"f").call(this,!0,{x:e.x,y:e.y},r));break}}},Id=function(e){e.pointerType==="mouse"&&e.button>1||n(this,Wt,"m",el).call(this,e.x,e.y)},zd=function(e){n(this,Wt,"m",el).call(this,e.changedTouches[0]?.clientX??0,e.changedTouches[0]?.clientY??0)},Fd=function(e){if(n(this,Er,"f")?.call(this,e)||e.target!==e.currentTarget)return;let r=e.currentTarget;if(n(this,Fo,"f")?.call(this,e.key)&&(e.key===" "&&e.preventDefault(),!n(this,Re,"f").has(r))){n(this,Re,"f").set(r,performance.now());let i=r.getBoundingClientRect();n(this,Ht,"f").call(this,!0,{x:i.x+i.width/2,y:i.y+i.height/2},r)}},Od=function(e){let r=e.target;if(n(this,Re,"f").has(r)&&n(this,Fo,"f")?.call(this,e.key)){let i=n(this,Mr,"f")-(performance.now()-n(this,Re,"f").get(r)),s=r.getBoundingClientRect();i>0?setTimeout(()=>{n(this,Re,"f").delete(r),n(this,Ht,"f").call(this,!1,{x:s.x+s.width/2,y:s.y+s.height/2},r)},i):(n(this,Re,"f").delete(r),n(this,Ht,"f").call(this,!1,{x:s.x+s.width/2,y:s.y+s.height/2},r))}},el=function(e,r){for(let i of n(this,Re,"f")){let s=n(this,Mr,"f")-(performance.now()-i[1]);s>0?setTimeout(()=>{n(this,Re,"f").delete(i[0]),n(this,Ht,"f").call(this,!1,{x:e,y:r},i[0])},s):(n(this,Re,"f").delete(i[0]),n(this,Ht,"f").call(this,!1,{x:e,y:r},i[0]))}};var vr,jn,Gn,Lo,gr,we=class extends qt{constructor(e,r){if(super(e,r),vr.set(this,void 0),jn.set(this,void 0),Gn.set(this,void 0),Lo.set(this,void 0),gr.set(this,!0),f(this,vr,r.callback,"f"),f(this,jn,r.skipInitial??!1,"f"),f(this,Gn,r.config,"f"),!!1){if(!window.ResizeObserver){console.warn("ResizeController error: the browser does not support ResizeObserver.");return}f(this,Lo,new ResizeObserver((i,s)=>n(this,vr,"f").call(this,i,s)),"f")}}async hostUpdated(){n(this,Lo,"f")&&!n(this,jn,"f")&&n(this,gr,"f")&&n(this,vr,"f").call(this,[],n(this,Lo,"f")),f(this,gr,!1,"f")}_observe(e){n(this,Lo,"f")?.observe(e,n(this,Gn,"f")),f(this,gr,!0,"f")}_unobserve(e){n(this,Lo,"f")?.unobserve(e)}};vr=new WeakMap,jn=new WeakMap,Gn=new WeakMap,Lo=new WeakMap,gr=new WeakMap;var L=t=>(e,r)=>{let i=()=>{typeof window<"u"&&!customElements.get(t)&&customElements.define(t,e)};r?r.addInitializer(i):i()};function vt(t){let e=Symbol("_id");return(r,i,s)=>{let l=s.value;return s.value=function(...c){let d=this;clearTimeout(d[e]),d[e]=setTimeout(()=>l.apply(this,c),t)},s}}var Oo,ci,Lr,Yn,To,$d,tl,Rd,Bd,za=class extends qt{constructor(e,r){super(e,r),Oo.add(this),ci.set(this,void 0),Lr.set(this,void 0),Yn.set(this,i=>n(this,Oo,"m",Bd).call(this,i)),To.set(this,new Map),f(this,ci,r.debounce===!0,"f"),f(this,Lr,r.callback,"f")}getScrollContainers(e){return n(this,To,"f").get(e)}_observe(e){let r=n(this,Oo,"m",Rd).call(this,e);if(r.length>0){n(this,To,"f").set(e,r);for(let i of r)(i===document.documentElement?document:i).addEventListener("scroll",n(this,Yn,"f"),{passive:!0})}}_unobserve(e){if(n(this,To,"f").has(e)){for(let r of n(this,To,"f").get(e))(r===document.documentElement?document:r).removeEventListener("scroll",n(this,Yn,"f"));n(this,To,"f").delete(e)}}_debounceCallback(e){n(this,Lr,"f").call(this,e)}};ci=new WeakMap,Lr=new WeakMap,Yn=new WeakMap,To=new WeakMap,Oo=new WeakSet,$d=function(e){let r=e.shadowRoot;if(!r)return null;let i=document.createTreeWalker(r,NodeFilter.SHOW_ELEMENT),s=i.currentNode;for(;s;){if(s instanceof Element&&n(this,Oo,"m",tl).call(this,s))return s;s=i.nextNode()}return null},tl=function(e){let r=getComputedStyle(e);return/(auto|scroll)/.test(r.overflow+r.overflowY+r.overflowX)},Rd=function(e){let r=new Array,i=n(this,Oo,"m",$d).call(this,e);i&&r.push(i);let s=e;for(;s;)n(this,Oo,"m",tl).call(this,s)&&r.push(s),s=s.parentElement;return r},Bd=function(e){let r=e.target===document?document.documentElement:e.target;n(this,ci,"f")?this._debounceCallback(r):n(this,Lr,"f").call(this,r)};h([vt(40)],za.prototype,"_debounceCallback",null);var sl,Ta,yr,xr,Xn,Zn,Dd,zr=class{constructor(e){sl.add(this),Ta.set(this,!1),yr.set(this,0),xr.set(this,0),Xn.set(this,""),Zn.set(this,""),e.addController(this)}lock(){n(this,Ta,"f")||(f(this,Ta,!0,"f"),f(this,yr,window.scrollY,"f"),f(this,xr,window.scrollX,"f"),f(this,Xn,document.documentElement.style.overflow,"f"),f(this,Zn,document.documentElement.style.scrollbarGutter,"f"),n(this,sl,"m",Dd).call(this)&&(document.documentElement.style.scrollbarGutter="stable"),document.documentElement.style.overflow="hidden",window.scrollTo(n(this,xr,"f"),n(this,yr,"f")))}unlock(){n(this,Ta,"f")&&(f(this,Ta,!1,"f"),document.documentElement.style.overflow=n(this,Xn,"f"),document.documentElement.style.scrollbarGutter=n(this,Zn,"f"),window.scrollTo(n(this,xr,"f"),n(this,yr,"f")))}hostDisconnected(){this.unlock()}};Ta=new WeakMap,yr=new WeakMap,xr=new WeakMap,Xn=new WeakMap,Zn=new WeakMap,sl=new WeakSet,Dd=function(){return document.documentElement.scrollHeight>document.documentElement.clientHeight};var Hd="important",Wd=" !"+Hd,Mp=0-Wd.length,ll=class extends Ln{constructor(e){if(super(e),e.type!==xd.ATTRIBUTE||e.name!=="style"||e.strings?.length>2)throw new Error("The `styleMap` directive must be used in the `style` attribute and must be the only part in the attribute.")}render(e){return F}update(e,[r]){let{style:i}=e.element;this._previousStyleProperties===void 0&&(this._previousStyleProperties=new Set(Object.keys(r)));for(let s of this._previousStyleProperties)r[s]==null&&(this._previousStyleProperties.delete(s),s.includes("-")?i.removeProperty(s):i[s]=null);for(let s in r){let l=r[s];if(l!=null){this._previousStyleProperties.add(s);let c=typeof l=="string"&&l.endsWith(Wd);s.includes("-")||c?i.setProperty(s,c?l.slice(0,Mp):l,c?Hd:""):i[s]=l}}return Dt}},Lp=wd(ll);function Ye(t,...e){return typeof t=="object"&&t!==null&&e.every(r=>r in t)}var de=Symbol("internals");function Nd(t){return Ye(t,de)}var Cd=Symbol("_internals"),Do=Symbol("_customState");function Q(t,e){var r;class i extends t{constructor(){super(...arguments),this[r]=new Set}get[(r=Do,de)](){return this[Cd]??(this[Cd]=this.attachInternals())}}return i.formAssociated=e,i}function ie(t,e){return Do in t?t[Do].has(e):t[de].states.has(e)}function ae(t,e){ie(t,e)||(Do in t&&t[Do].add(e),t[de]?.states.add(e),t[de]?.states.has(e))}function D(t,e){return Do in t&&t[Do].delete(e),t[de]?.states.delete(e)?(t[de]?.states.has(e),!0):!1}function R(t,e,r){r?ae(t,e):D(t,e)}function jo(t){return Ye(t,"checked")}function pl(t){class e extends t{constructor(){super(...arguments),this.checked=!1}update(i){super.update(i),i.has("checked")&&(this.role==="button"?(this.ariaPressed=`${this.checked}`,this.ariaChecked=null):this.role&&this.role!=="none"&&this.role!=="presentation"&&(this.ariaChecked=`${this.checked}`,this.ariaPressed=null))}}return h([b({type:Boolean,reflect:!0})],e.prototype,"checked",void 0),e}function fl(t){return Ye(t,"indeterminate")&&jo(t)}function qd(t){class e extends pl(t){constructor(){super(...arguments),this.indeterminate=!1}update(i){super.update(i),i.has("indeterminate")&&this.role&&this.role!=="none"&&this.role!=="presentation"&&(this.ariaChecked=!this.checked&&this.indeterminate?"mixed":`${this.checked}`)}}return h([b({type:Boolean,reflect:!0})],e.prototype,"indeterminate",void 0),e}var mi={primary:o("var(--md-sys-color-primary, #6750A4)"),onPrimary:o("var(--md-sys-color-on-primary, #FFFFFF)"),primaryContainer:o("var(--md-sys-color-primary-container, #EADDFF)"),onPrimaryContainer:o("var(--md-sys-color-on-primary-container, #4F378B)"),primaryFixed:o("var(--md-sys-color-primary-fixed, #EADDFF)"),primaryFixedDim:o("var(--md-sys-color-primary-fixed-dim, #D0BCFF)"),onPrimaryFixed:o("var(--md-sys-color-on-primary-fixed, #21005D)"),onPrimaryFixedVariant:o("var(--md-sys-color-on-primary-fixed-variant, #4F378B)"),secondary:o("var(--md-sys-color-secondary, #625B71)"),onSecondary:o("var(--md-sys-color-on-secondary, #FFFFFF)"),secondaryContainer:o("var(--md-sys-color-secondary-container, #E8DEF8)"),onSecondaryContainer:o("var(--md-sys-color-on-secondary-container, #4A4458)"),secondaryFixed:o("var(--md-sys-color-secondary-fixed, #E8DEF8)"),secondaryFixedDim:o("var(--md-sys-color-secondary-fixed-dim, #CCC2DC)"),onSecondaryFixed:o("var(--md-sys-color-on-secondary-fixed, #1D192B)"),onSecondaryFixedVariant:o("var(--md-sys-color-on-secondary-fixed-variant, #4A4458)"),tertiary:o("var(--md-sys-color-tertiary, #7D5260)"),onTertiary:o("var(--md-sys-color-on-tertiary, #FFFFFF)"),tertiaryContainer:o("var(--md-sys-color-tertiary-container, #FFD8E4)"),onTertiaryContainer:o("var(--md-sys-color-on-tertiary-container, #633B48)"),tertiaryFixed:o("var(--md-sys-color-tertiary-fixed, #FFD8E4)"),tertiaryFixedDim:o("var(--md-sys-color-tertiary-fixed-dim, #EFB8C8)"),onTertiaryFixed:o("var(--md-sys-color-on-tertiary-fixed, #31111D)"),onTertiaryFixedVariant:o("var(--md-sys-color-on-tertiary-fixed-variant, #633B48)"),error:o("var(--md-sys-color-error, #B3261E)"),onError:o("var(--md-sys-color-on-error, #FFFFFF)"),errorContainer:o("var(--md-sys-color-error-container, #F9DEDC)"),onErrorContainer:o("var(--md-sys-color-on-error-container, #8C1D18)"),surface:o("var(--md-sys-color-surface, #FEF7FF)"),onSurface:o("var(--md-sys-color-on-surface, #1D1B20)"),onSurfaceVariant:o("var(--md-sys-color-on-surface-variant, #49454F)"),surfaceContainerLowest:o("var(--md-sys-color-surface-container-lowest, #FFFFFF)"),surfaceContainerLow:o("var(--md-sys-color-surface-container-low, #F7F2FA)"),surfaceContainer:o("var(--md-sys-color-surface-container, #F3EDF7)"),surfaceContainerHigh:o("var(--md-sys-color-surface-container-high, #ECE6F0)"),surfaceContainerHighest:o("var(--md-sys-color-surface-container-highest, #E6E0E9)"),surfaceDim:o("var(--md-sys-color-surface-dim, #DED8E1)"),surfaceBright:o("var(--md-sys-color-surface-bright, #FEF7FF)"),surfaceVariant:o("var(--md-sys-color-surface-variant, #E7E0EC)"),inverseSurface:o("var(--md-sys-color-inverse-surface, #322F35)"),inverseOnSurface:o("var(--md-sys-color-inverse-on-surface, #F5EFF7)"),inversePrimary:o("var(--md-sys-color-inverse-primary, #D0BCFF)"),outline:o("var(--md-sys-color-outline, #79747E)"),outlineVariant:o("var(--md-sys-color-outline-variant, #CAC4D0)"),shadow:o("var(--md-sys-color-shadow, #000000)"),scrim:o("var(--md-sys-color-scrim, #000000)")},ol={scale:o("var(--md-sys-density-scale, 0)"),size:o("var(--md-sys-density-size, 0.25rem)")},Tp={...ol,calc(t){return o(`calc(max(${t}, ${ol.scale}) * ${ol.size})`)}},Pp=`color-mix(in srgb, var(--m3e-elevation-color, ${mi.shadow}) 20%, transparent)`,Ap=["0px 0px 0px 0px","0px 2px 1px -1px","0px 3px 1px -2px","0px 3px 3px -2px","0px 2px 4px -1px","0px 3px 5px -1px","0px 3px 5px -1px","0px 4px 5px -2px","0px 5px 5px -3px","0px 5px 6px -3px","0px 6px 6px -3px","0px 6px 7px -4px","0px 7px 8px -4px","0px 7px 8px -4px","0px 7px 9px -4px","0px 8px 9px -5px","0px 8px 10px -5px","0px 8px 11px -5px","0px 9px 11px -5px","0px 9px 12px -6px","0px 10px 13px -6px","0px 10px 13px -6px","0px 10px 14px -6px","0px 11px 14px -7px","0px 11px 15px -7px"],Ip=`color-mix(in srgb, var(--m3e-elevation-color, ${mi.shadow}) 14%, transparent)`,zp=["0px 0px 0px 0px","0px 1px 1px 0px","0px 2px 2px 0px","0px 3px 4px 0px","0px 4px 5px 0px","0px 5px 8px 0px","0px 6px 10px 0px","0px 7px 10px 1px","0px 8px 10px 1px","0px 9px 12px 1px","0px 10px 14px 1px","0px 11px 15px 1px","0px 12px 17px 2px","0px 13px 19px 2px","0px 14px 21px 2px","0px 15px 22px 2px","0px 16px 24px 2px","0px 17px 26px 2px","0px 18px 28px 2px","0px 19px 29px 2px","0px 20px 31px 3px","0px 21px 33px 3px","0px 22px 35px 3px","0px 23px 36px 3px","0px 24px 38px 3px"],Fp=`color-mix(in srgb, var(--m3e-elevation-color, ${mi.shadow}) 12%, transparent)`,Op=["0px 0px 0px 0px","0px 1px 3px 0px","0px 1px 5px 0px","0px 1px 8px 0px","0px 1px 10px 0px","0px 1px 14px 0px","0px 1px 18px 0px","0px 2px 16px 1px","0px 3px 14px 2px","0px 3px 16px 2px","0px 4px 18px 3px","0px 4px 20px 3px","0px 5px 22px 4px","0px 5px 24px 4px","0px 5px 26px 4px","0px 6px 28px 5px","0px 6px 30px 5px","0px 6px 32px 5px","0px 7px 34px 6px","0px 7px 36px 6px","0px 8px 38px 7px","0px 8px 40px 7px","0px 8px 42px 7px","0px 9px 44px 8px","0px 9px 46px 8px"];function $a(t){return`${Pp} ${Ap[t]},${Ip} ${zp[t]},${Fp} ${Op[t]}`}var Rp={level0:o(`var(--md-sys-elevation-level0, ${$a(0)})`),level1:o(`var(--md-sys-elevation-level1, ${$a(1)})`),level2:o(`var(--md-sys-elevation-level2, ${$a(3)})`),level3:o(`var(--md-sys-elevation-level3, ${$a(6)})`),level4:o(`var(--md-sys-elevation-level4, ${$a(8)})`),level5:o(`var(--md-sys-elevation-level5, ${$a(12)})`)};function be(t){return o(`var(--md-sys-measurement-space${t}, ${.5*(t/100)}rem)`)}var Bp={space0:be(0),space25:be(25),space50:be(50),space75:be(75),space100:be(100),space125:be(125),space150:be(150),space175:be(175),space200:be(200),space250:be(250),space300:be(300),space400:be(400),space450:be(450),space500:be(500),space600:be(600),space700:be(700),space800:be(800),space900:be(900)},Dp={emphasized:o("var(--md-sys-motion-easing-emphasized, cubic-bezier(0.2, 0.0, 0, 1.0))"),emphasizedDecelerate:o("var(--md-sys-motion-easing-emphasized-decelerate, cubic-bezier(0.05, 0.7, 0.1, 1.0))"),emphasizedAccelerate:o("var(--md-sys-motion-easing-emphasized-accelerate, cubic-bezier(0.3, 0.0, 0.8, 0.15))"),standard:o("var(--md-sys-motion-easing-standard, cubic-bezier(0.2, 0.0, 0, 1.0))"),standardDecelerate:o("var(--md-sys-motion-easing-standard-decelerate, cubic-bezier(0, 0, 0, 1))"),standardAccelerate:o("var(--md-sys-motion-easing-standard-accelerate, cubic-bezier(0.3, 0, 1, 1))")},Hp={fastSpatial:o("var(--md-sys-motion-spring-fast-spatial, 350ms cubic-bezier(0.27, 1.06, 0.18, 1.00))"),defaultSpatial:o("var(--md-sys-motion-spring-default-spatial, 500ms cubic-bezier(0.27, 1.06, 0.18, 1.00))"),slowSpatial:o("var(--md-sys-motion-spring-slow-spatial, 750ms cubic-bezier(0.27, 1.06, 0.18, 1.00))"),fastEffects:o("var(--md-sys-motion-spring-fast-effects, 150ms cubic-bezier(0.31, 0.94, 0.34, 1.00))"),defaultEffects:o("var(--md-sys-motion-spring-default-effects, 200ms cubic-bezier(0.34, 0.80, 0.34, 1.00))"),slowEffects:o("var(--md-sys-motion-spring-slow-effects, 200ms cubic-bezier(0.34, 0.88, 0.34, 1.00))")},Wp={short1:o("var(--md-sys-motion-duration-short-1, 50ms)"),short2:o("var(--md-sys-motion-duration-short-2, 100ms)"),short3:o("var(--md-sys-motion-duration-short-3, 150ms)"),short4:o("var(--md-sys-motion-duration-short-4, 200ms)"),medium1:o("var(--md-sys-motion-duration-medium-1, 250ms)"),medium2:o("var(--md-sys-motion-duration-medium-2, 300ms)"),medium3:o("var(--md-sys-motion-duration-medium-3, 350ms)"),medium4:o("var(--md-sys-motion-duration-medium-4, 400ms)"),long1:o("var(--md-sys-motion-duration-long-1, 450ms)"),long2:o("var(--md-sys-motion-duration-long-2, 500ms)"),long3:o("var(--md-sys-motion-duration-long-3, 550ms)"),long4:o("var(--md-sys-motion-duration-long-4, 600ms)"),extraLong1:o("var(--md-sys-motion-duration-extra-long-1, 700ms)"),extraLong2:o("var(--md-sys-motion-duration-extra-long-2, 800ms)"),extraLong3:o("var(--md-sys-motion-duration-extra-long-3, 900ms)"),extraLong4:o("var(--md-sys-motion-duration-extra-long-4, 1000ms)")},Np={easing:Dp,duration:Wp,spring:Hp},qp={width:o("var(--m3e-scrollbar-width, auto)"),thinWidth:o("var(--m3e-scrollbar-thin-width, thin)"),color:o("var(--m3e-scrollbar-thumb-color, #938f94) var(--m3e-scrollbar-track-color, transparent)")},k={none:o("var(--md-sys-shape-corner-value-none, 0)"),extraSmall:o("var(--md-sys-shape-corner-value-extra-small, 0.25rem)"),small:o("var(--md-sys-shape-corner-value-small, 0.5rem)"),medium:o("var(--md-sys-shape-corner-value-medium, 0.75rem)"),large:o("var(--md-sys-shape-corner-value-large, 1rem)"),largeIncreased:o("var(--md-sys-shape-corner-value-large-increased, 1.25rem)"),extraLarge:o("var(--md-sys-shape-corner-value-extra-large, 1.75rem)"),extraLargeIncreased:o("var(--md-sys-shape-corner-value-extra-large-increased, 2rem)"),extraExtraLarge:o("var(--md-sys-shape-corner-value-extra-extra-large, 3rem)")},Vp={corner:{full:o("var(--md-sys-shape-corner-full, 624.9375rem)"),extraLargeTop:o(`var(--md-sys-shape-corner-extra-large-top, ${k.extraLarge} ${k.extraLarge} ${k.none} ${k.none})`),extraLarge:o(`var(--md-sys-shape-corner-extra-large, ${k.extraLarge})`),extraLargeEnd:o(`${k.none} ${k.extraLarge} ${k.extraLarge} ${k.none}`),extraLargeStart:o(`${k.extraLarge} ${k.none} ${k.none} ${k.extraLarge}`),largeTop:o(`var(--md-sys-shape-corner-large-top, ${k.large} ${k.large} ${k.none} ${k.none})`),largeEnd:o(`var(--md-sys-shape-corner-large-end, ${k.none} ${k.large} ${k.large} ${k.none})`),largeStart:o(`var(--md-sys-shape-corner-large-start, ${k.large} ${k.none} ${k.none} ${k.large})`),large:o(`var(--md-sys-shape-corner-large, ${k.large})`),medium:o(`var(--md-sys-shape-corner-medium, ${k.medium})`),mediumTop:o(`${k.medium} ${k.medium} ${k.none} ${k.none}`),mediumEnd:o(`${k.none} ${k.medium} ${k.medium} ${k.none}`),mediumStart:o(`${k.medium} ${k.none} ${k.none} ${k.medium}`),small:o(`var(--md-sys-shape-corner-small, ${k.small})`),smallTop:o(`${k.small} ${k.small} ${k.none} ${k.none}`),smallEnd:o(`${k.none} ${k.small} ${k.small} ${k.none}`),smallStart:o(`${k.small} ${k.none} ${k.none} ${k.small}`),extraSmallTop:o(`var(--md-sys-shape-corner-extra-small-top, ${k.extraSmall} ${k.extraSmall} ${k.none} ${k.none})`),extraSmall:o(`var(--md-sys-shape-corner-extra-small, ${k.extraSmall})`),extraSmallEnd:o(`${k.none} ${k.extraSmall} ${k.extraSmall} ${k.none}`),extraSmallStart:o(`${k.extraSmall} ${k.none} ${k.none} ${k.extraSmall}`),extraSmallBottom:o(`${k.none} ${k.none} ${k.extraSmall} ${k.extraSmall}`),none:o(`var(--md-sys-shape-corner-none, ${k.none})`),largeIncreased:o(`var(--md-sys-shape-corner-large-increased, ${k.largeIncreased})`),extraLargeIncreased:o(`var(--md-sys-shape-corner-extra-large-increased, ${k.extraLargeIncreased})`),extraExtraLarge:o(`var(--md-sys-shape-corner-extra-extra-large, ${k.extraExtraLarge})`),value:k}},Up={focusStateLayerOpacity:o("var(--md-sys-state-focus-state-layer-opacity, 10%)"),hoverStateLayerOpacity:o("var(--md-sys-state-hover-state-layer-opacity, 8%)"),pressedStateLayerOpacity:o("var(--md-sys-state-pressed-state-layer-opacity, 10%)")},jp={standard:{display:{large:{fontSize:o("var(--md-sys-typescale-display-large-font-size, 3.5625rem)"),fontWeight:o("var(--md-sys-typescale-display-large-font-weight, 400)"),lineHeight:o("var(--md-sys-typescale-display-large-line-height, 4rem)"),tracking:o("var(--md-sys-typescale-display-large-tracking, 0.015625rem)")},medium:{fontSize:o("var(--md-sys-typescale-display-medium-font-size, 2.8125rem)"),fontWeight:o("var(--md-sys-typescale-display-medium-font-weight, 400)"),lineHeight:o("var(--md-sys-typescale-display-medium-line-height, 3.25rem)"),tracking:o("var(--md-sys-typescale-display-medium-tracking, 0)")},small:{fontSize:o("var(--md-sys-typescale-display-small-font-size, 2.25rem)"),fontWeight:o("var(--md-sys-typescale-display-small-font-weight, 400)"),lineHeight:o("var(--md-sys-typescale-display-small-line-height, 2.75rem)"),tracking:o("var(--md-sys-typescale-display-small-tracking, 0)")}},headline:{large:{fontSize:o("var(--md-sys-typescale-headline-large-font-size, 2rem)"),fontWeight:o("var(--md-sys-typescale-headline-large-font-weight, 400)"),lineHeight:o("var(--md-sys-typescale-headline-large-line-height, 2.5rem)"),tracking:o("var(--md-sys-typescale-headline-large-tracking, 0)")},medium:{fontSize:o("var(--md-sys-typescale-headline-medium-font-size, 1.75rem)"),fontWeight:o("var(--md-sys-typescale-headline-medium-font-weight, 400)"),lineHeight:o("var(--md-sys-typescale-headline-medium-line-height, 2.25rem)"),tracking:o("var(--md-sys-typescale-headline-medium-tracking, 0)")},small:{fontSize:o("var(--md-sys-typescale-headline-small-font-size, 1.5rem)"),fontWeight:o("var(--md-sys-typescale-headline-small-font-weight, 400)"),lineHeight:o("var(--md-sys-typescale-headline-small-line-height, 2rem)"),tracking:o("var(--md-sys-typescale-headline-small-tracking, 0)")}},title:{large:{fontSize:o("var(--md-sys-typescale-title-large-font-size, 1.375rem)"),fontWeight:o("var(--md-sys-typescale-title-large-font-weight, 400)"),lineHeight:o("var(--md-sys-typescale-title-large-line-height, 1.75rem)"),tracking:o("var(--md-sys-typescale-title-large-tracking, 0)")},medium:{fontSize:o("var(--md-sys-typescale-title-medium-font-size, 1rem)"),fontWeight:o("var(--md-sys-typescale-title-medium-font-weight, 500)"),lineHeight:o("var(--md-sys-typescale-title-medium-line-height, 1.5rem)"),tracking:o("var(--md-sys-typescale-title-medium-tracking, 0.009375rem)")},small:{fontSize:o("var(--md-sys-typescale-title-small-font-size, 0.875rem)"),fontWeight:o("var(--md-sys-typescale-title-small-font-weight, 500)"),lineHeight:o("var(--md-sys-typescale-title-small-line-height, 1.25rem)"),tracking:o("var(--md-sys-typescale-title-small-tracking, 0.00625rem)")}},body:{large:{fontSize:o("var(--md-sys-typescale-body-large-font-size, 1rem)"),fontWeight:o("var(--md-sys-typescale-body-large-font-weight, 400)"),lineHeight:o("var(--md-sys-typescale-body-large-line-height, 1.5rem)"),tracking:o("var(--md-sys-typescale-body-large-tracking, 0.03125rem)")},medium:{fontSize:o("var(--md-sys-typescale-body-medium-font-size, 0.875rem)"),fontWeight:o("var(--md-sys-typescale-body-medium-font-weight, 400)"),lineHeight:o("var(--md-sys-typescale-body-medium-line-height, 1.25rem)"),tracking:o("var(--md-sys-typescale-body-medium-tracking, 0.015625rem)")},small:{fontSize:o("var(--md-sys-typescale-body-small-font-size, 0.75rem)"),fontWeight:o("var(--md-sys-typescale-body-small-font-weight, 400)"),lineHeight:o("var(--md-sys-typescale-body-small-line-height, 1rem)"),tracking:o("var(--md-sys-typescale-body-small-tracking, 0.025rem)")}},label:{large:{fontSize:o("var(--md-sys-typescale-label-large-font-size, 0.875rem)"),fontWeight:o("var(--md-sys-typescale-label-large-font-weight, 500)"),lineHeight:o("var(--md-sys-typescale-label-large-line-height, 1.25rem)"),tracking:o("var(--md-sys-typescale-label-large-tracking, 0.00625rem)")},medium:{fontSize:o("var(--md-sys-typescale-label-medium-font-size, 0.75rem)"),fontWeight:o("var(--md-sys-typescale-label-medium-font-weight, 500)"),lineHeight:o("var(--md-sys-typescale-label-medium-line-height, 1rem)"),tracking:o("var(--md-sys-typescale-label-medium-tracking, 0.03125rem)")},small:{fontSize:o("var(--md-sys-typescale-label-small-font-size, 0.6875rem)"),fontWeight:o("var(--md-sys-typescale-label-small-font-weight, 500)"),lineHeight:o("var(--md-sys-typescale-label-small-line-height, 1rem)"),tracking:o("var(--md-sys-typescale-label-small-tracking, 0.03125rem)")}}},emphasized:{display:{large:{fontSize:o("var(--md-sys-typescale-emphasized-display-large-font-size, 3.5625rem)"),fontWeight:o("var(--md-sys-typescale-emphasized-display-large-font-weight, 500)"),lineHeight:o("var(--md-sys-typescale-emphasized-display-large-line-height, 4rem)"),tracking:o("var(--md-sys-typescale-emphasized-display-large-tracking, 0.015625rem)")},medium:{fontSize:o("var(--md-sys-typescale-emphasized-display-medium-font-size, 2.8125rem)"),fontWeight:o("var(--md-sys-typescale-emphasized-display-medium-font-weight, 500)"),lineHeight:o("var(--md-sys-typescale-emphasized-display-medium-line-height, 3.25rem)"),tracking:o("var(--md-sys-typescale-emphasized-display-medium-tracking, 0)")},small:{fontSize:o("var(--md-sys-typescale-emphasized-display-small-font-size, 2.25rem)"),fontWeight:o("var(--md-sys-typescale-emphasized-display-small-font-weight, 500)"),lineHeight:o("var(--md-sys-typescale-emphasized-display-small-line-height, 2.75rem)"),tracking:o("var(--md-sys-typescale-emphasized-display-small-tracking, 0)")}},headline:{large:{fontSize:o("var(--md-sys-typescale-emphasized-headline-large-font-size, 2rem)"),fontWeight:o("var(--md-sys-typescale-emphasized-headline-large-font-weight, 500)"),lineHeight:o("var(--md-sys-typescale-emphasized-headline-large-line-height, 2.5rem)"),tracking:o("var(--md-sys-typescale-emphasized-headline-large-tracking, 0)")},medium:{fontSize:o("var(--md-sys-typescale-emphasized-headline-medium-font-size, 1.75rem)"),fontWeight:o("var(--md-sys-typescale-emphasized-headline-medium-font-weight, 500)"),lineHeight:o("var(--md-sys-typescale-emphasized-headline-medium-line-height, 2.25rem)"),tracking:o("var(--md-sys-typescale-emphasized-headline-medium-tracking, 0)")},small:{fontSize:o("var(--md-sys-typescale-emphasized-headline-small-font-size, 1.5rem)"),fontWeight:o("var(--md-sys-typescale-emphasized-headline-small-font-weight, 500)"),lineHeight:o("var(--md-sys-typescale-emphasized-headline-small-line-height, 2rem)"),tracking:o("var(--md-sys-typescale-emphasized-headline-small-tracking, 0)")}},title:{large:{fontSize:o("var(--md-sys-typescale-emphasized-title-large-font-size, 1.375rem)"),fontWeight:o("var(--md-sys-typescale-emphasized-title-large-font-weight, 500)"),lineHeight:o("var(--md-sys-typescale-emphasized-title-large-line-height, 1.75rem)"),tracking:o("var(--md-sys-typescale-emphasized-title-large-tracking, 0)")},medium:{fontSize:o("var(--md-sys-typescale-emphasized-title-medium-font-size, 1rem)"),fontWeight:o("var(--md-sys-typescale-emphasized-title-medium-font-weight, 700)"),lineHeight:o("var(--md-sys-typescale-emphasized-title-medium-line-height, 3.5rem)"),tracking:o("var(--md-sys-typescale-emphasized-title-medium-tracking, 0.009375rem)")},small:{fontSize:o("var(--md-sys-typescale-emphasized-title-small-font-size, 0.875rem)"),fontWeight:o("var(--md-sys-typescale-emphasized-title-small-font-weight, 700)"),lineHeight:o("var(--md-sys-typescale-emphasized-title-small-line-height, 1.25rem)"),tracking:o("var(--md-sys-typescale-emphasized-title-small-tracking, 0.00625rem)")}},body:{large:{fontSize:o("var(--md-sys-typescale-emphasized-body-large-font-size, 1rem)"),fontWeight:o("var(--md-sys-typescale-emphasized-body-large-font-weight, 500)"),lineHeight:o("var(--md-sys-typescale-emphasized-body-large-line-height, 1.5rem)"),tracking:o("var(--md-sys-typescale-emphasized-body-large-tracking, 0.03125rem)")},medium:{fontSize:o("var(--md-sys-typescale-emphasized-body-medium-font-size, 0.875rem)"),fontWeight:o("var(--md-sys-typescale-emphasized-body-medium-font-weight, 500)"),lineHeight:o("var(--md-sys-typescale-emphasized-body-medium-line-height, 1.25rem)"),tracking:o("var(--md-sys-typescale-emphasized-body-medium-tracking, 0.015625rem)")},small:{fontSize:o("var(--md-sys-typescale-emphasized-body-small-font-size, 0.75rem)"),fontWeight:o("var(--md-sys-typescale-emphasized-body-small-font-weight, 500)"),lineHeight:o("var(--md-sys-typescale-emphasized-body-small-line-height, 1rem)"),tracking:o("var(--md-sys-typescale-emphasized-body-small-tracking, 0.025rem)")}},label:{large:{fontSize:o("var(--md-sys-typescale-emphasized-label-large-font-size, 0.875rem)"),fontWeight:o("var(--md-sys-typescale-emphasized-label-large-font-weight, 700)"),lineHeight:o("var(--md-sys-typescale-emphasized-label-large-line-height, 1.25rem)"),tracking:o("var(--md-sys-typescale-emphasized-label-large-tracking, 0.00625rem)")},medium:{fontSize:o("var(--md-sys-typescale-emphasized-label-medium-font-size, 0.75rem)"),fontWeight:o("var(--md-sys-typescale-emphasized-label-medium-font-weight, 700)"),lineHeight:o("var(--md-sys-typescale-emphasized-label-medium-line-height, 1rem)"),tracking:o("var(--md-sys-typescale-emphasized-label-medium-tracking, 0.03125rem)")},small:{fontSize:o("var(--md-sys-typescale-emphasized-label-small-font-size, 0.6875rem)"),fontWeight:o("var(--md-sys-typescale-emphasized-label-small-font-weight, 700)"),lineHeight:o("var(--md-sys-typescale-emphasized-label-small-line-height, 1rem)"),tracking:o("var(--md-sys-typescale-emphasized-label-small-tracking, 0.03125rem)")}}}},a={color:mi,elevation:Rp,motion:Np,shape:Vp,state:Up,typescale:jp,scrollbar:qp,density:Tp,measurement:Bp};function gt(t){return Ye(t,"disabled")}function se(t,e=!0){class r extends t{constructor(){super(...arguments),this.disabled=!1}update(s){super.update(s),s.has("disabled")&&this.role&&this.role!=="none"&&this.role!=="presentation"&&(this.ariaDisabled=this.disabled?"true":null)}}return h([b({type:Boolean,reflect:e})],r.prototype,"disabled",void 0),r}var Ca=Symbol("_control"),al=Symbol("_firstUpdated");function Xe(t){var e;class r extends t{constructor(){super(...arguments),this[e]=!1,this.htmlFor=null}get control(){return this[Ca]?.deref()??null}connectedCallback(){super.connectedCallback();let s=this[Ca]?.deref();s&&this.attach(s)}disconnectedCallback(){super.disconnectedCallback();let s=this[Ca];s&&(this.detach(),this[Ca]=s)}firstUpdated(s){super.firstUpdated(s),this[al]=!0}update(s){if(super.update(s),s.has("htmlFor"))if(this.htmlFor){let l=this.getRootNode();l&&Ed(this.htmlFor,l).then(c=>{c!==this.control&&(this.control&&this.detach(),c instanceof HTMLElement&&this.attach(c))})}else this.control&&this[al]&&this.detach()}attach(s){this[Ca]=new WeakRef(s)}detach(){this[Ca]=void 0}}return e=al,h([b({attribute:"for"})],r.prototype,"htmlFor",void 0),r}function W(t,e){class r extends t{connectedCallback(){this.role=this.role||e,super.connectedCallback()}}return r}var Jn,Ho=class extends P{constructor(){super(...arguments),Jn.set(this,e=>{e.defaultPrevented||this._onClick(e)})}connectedCallback(){super.connectedCallback(),this.parentElement?.addEventListener("click",n(this,Jn,"f"))}disconnectedCallback(){super.disconnectedCallback(),this.parentElement?.removeEventListener("click",n(this,Jn,"f"))}render(){return w`<slot></slot>`}};Jn=new WeakMap;Ho.styles=C`:host { display: contents; } ::slotted(.material-icons) { font-size: inherit !important; }`;var Ue,Tr,wr,Vd,_r,$r,cl,Wo=class extends Q(P){constructor(){super(...arguments),Ue.add(this),Tr.set(this,!1),wr.set(this,!1),this.open=!1,this.orientation="vertical",this.noAnimate=!1}update(e){super.update(e);let r=this.noAnimate||e.has("orientation")&&!e.has("open");if(ae(this,"--no-animate"),!n(this,Tr,"f")){this.open&&(f(this,wr,!0,"f"),n(this,Ue,"m",_r).call(this)),f(this,Tr,!0,"f");return}this.toggleAttribute("inert",!this.open),this.open?(f(this,wr,!0,"f"),r||Ce()||(n(this,Ue,"m",_r).call(this),R(this,"--overflows",this.orientation==="vertical"?this.clientHeight<this.scrollHeight:this.orientation==="horizontal"?this.clientWidth<this.scrollWidth:this.clientHeight<this.scrollHeight||this.clientWidth<this.scrollWidth),n(this,Ue,"m",$r).call(this)),D(this,"--closing"),ae(this,"--opening"),this.dispatchEvent(new Event("opening")),n(this,Ue,"m",$r).call(this),D(this,"--no-animate"),n(this,Ue,"m",cl).call(this),r||Ce()?(n(this,Ue,"m",_r).call(this),D(this,"--opening"),this.dispatchEvent(new Event("opened"))):this.addEventListener("transitionend",()=>{this.open&&(n(this,Ue,"m",_r).call(this),D(this,"--opening"),this.dispatchEvent(new Event("opened")))},{once:!0})):(D(this,"--opening"),ae(this,"--closing"),this.dispatchEvent(new Event("closing")),n(this,Ue,"m",cl).call(this),n(this,wr,"f")&&D(this,"--no-animate"),r||Ce()?(n(this,Ue,"m",$r).call(this),D(this,"--closing"),this.dispatchEvent(new Event("closed"))):requestAnimationFrame(()=>{n(this,Ue,"m",$r).call(this),this.addEventListener("transitionend",()=>{this.open||(D(this,"--closing"),this.dispatchEvent(new Event("closed")))},{once:!0})}))}render(){return w`<slot @slotchange="${n(this,Ue,"m",Vd)}"></slot>`}};Tr=new WeakMap;wr=new WeakMap;Ue=new WeakSet;Vd=function(){f(this,Tr,!0,"f")};_r=function(){switch(this.orientation){case"vertical":this.style.height="auto";break;case"horizontal":this.style.width="auto";break;case"both":this.style.height=this.style.width="auto";break}};$r=function(){switch(this.orientation){case"vertical":this.style.height="";break;case"horizontal":this.style.width="";break;case"both":this.style.height=this.style.width="";break}};cl=function(){switch(this.orientation){case"vertical":this.style.height=`${this.scrollHeight}px`;break;case"horizontal":this.style.width=`${this.scrollWidth}px`;break;case"both":this.style.height=`${this.scrollHeight}px`,this.style.width=`${this.scrollWidth}px`;break}};Wo.styles=C`:host { display: block; overflow: hidden; } :host([orientation="vertical"]) { height: 0px; transition: ${o(`visibility var(--m3e-collapsible-animation-duration, ${a.motion.duration.medium1})
          ${a.motion.easing.standard},
        height var(--m3e-collapsible-animation-duration, ${a.motion.duration.medium1})
          ${a.motion.easing.standard},
        padding-top var(--m3e-collapsible-animation-duration, ${a.motion.duration.medium1})
          ${a.motion.easing.standard},
        padding-bottom var(--m3e-collapsible-animation-duration, ${a.motion.duration.medium1})
          ${a.motion.easing.standard}`)}; } :host([orientation="horizontal"]) { width: 0px; transition: ${o(`visibility var(--m3e-collapsible-animation-duration, ${a.motion.duration.medium1})
          ${a.motion.easing.standard},
        width var(--m3e-collapsible-animation-duration, ${a.motion.duration.medium1})
          ${a.motion.easing.standard},
        padding-left var(--m3e-collapsible-animation-duration, ${a.motion.duration.medium1})
          ${a.motion.easing.standard},
        padding-right var(--m3e-collapsible-animation-duration, ${a.motion.duration.medium1})
          ${a.motion.easing.standard}`)}; } :host([orientation="both"]) { height: 0px; width: 0px; transition: ${o(`visibility var(--m3e-collapsible-animation-duration, ${a.motion.duration.medium1})
          ${a.motion.easing.standard},
        width var(--m3e-collapsible-animation-duration, ${a.motion.duration.medium1})
          ${a.motion.easing.standard},
        height var(--m3e-collapsible-animation-duration, ${a.motion.duration.medium1})
          ${a.motion.easing.standard},
        padding var(--m3e-collapsible-animation-duration, ${a.motion.duration.medium1})
          ${a.motion.easing.standard}`)}; } :host(:not(:is(:state(--closing), :--closing)):not([open])) { visibility: hidden; } :host([orientation="vertical"]:not([open])) { min-height: unset !important; padding-top: 0px !important; padding-bottom: 0px !important; } :host([orientation="horizontal"]:not([open])) { min-width: unset !important; padding-left: 0px !important; padding-right: 0px !important; } :host([orientation="both"]:not([open])) { min-height: unset !important; min-width: unset !important; padding: 0px !important; } :host([no-animate]), :host(:is(:state(--no-animate), :--no-animate)) { transition-duration: 0ms; } :host([orientation="vertical"]:is(:state(--opening), :--opening)), :host([orientation="vertical"]:is(:state(--closing), :--closing)) { overflow-y: hidden !important; } :host([orientation="horizontal"]:is(:state(--opening), :--opening)), :host([orientation="horizontal"]:is(:state(--closing), :--closing)) { overflow-x: hidden !important; } :host([orientation="both"]:is(:state(--opening), :--opening)), :host([orientation="both"]:is(:state(--closing), :--closing)) { overflow-y: hidden !important; overflow-x: hidden !important; } :host(:is(:state(--overflows), :--overflows)) { scrollbar-gutter: stable; } ::slotted(*) { --m3e-collapsible-animation-duration: initial; } @media (prefers-reduced-motion) { :host { transition: none; } }`;h([b({type:Boolean,reflect:!0})],Wo.prototype,"open",void 0);h([b({reflect:!0})],Wo.prototype,"orientation",void 0);h([b({attribute:"no-animate",type:Boolean,reflect:!0})],Wo.prototype,"noAnimate",void 0);Wo=h([L("m3e-collapsible")],Wo);var pt={liftDuration:o(`var(--m3e-elevation-lift-duration, ${a.motion.duration.short4})`),liftEasing:o(`var(--m3e-elevation-lift-easing, ${a.motion.easing.standard})`),settleDuration:o(`var(--m3e-elevation-settle-duration, ${a.motion.duration.short3})`),settleEasing:o(`var(--m3e-elevation-settle-easing, ${a.motion.easing.standardAccelerate})`),level:o(`var(--m3e-elevation-level, ${a.elevation.level0})`),hoverLevel:o(`var(--m3e-elevation-hover-level, ${a.elevation.level0})`),focusLevel:o(`var(--m3e-elevation-focus-level, ${a.elevation.level0})`),pressedLevel:o(`var(--m3e-elevation-pressed-level, ${a.elevation.level0})`)},Cr,Qn,Kn,ei,Ud,jd,Gd,No=class extends Xe(W(P,"none")){constructor(){super(...arguments),Cr.add(this),Qn.set(this,new Vt(this,{target:null,callback:e=>n(this,Cr,"m",Ud).call(this,e)})),Kn.set(this,new je(this,{target:null,callback:e=>n(this,Cr,"m",jd).call(this,e)})),ei.set(this,new fe(this,{target:null,callback:e=>n(this,Cr,"m",Gd).call(this,e)})),this.disabled=!1,this.level=null}attach(e){super.attach(e),n(this,Qn,"f").observe(e),n(this,Kn,"f").observe(e),n(this,ei,"f").observe(e)}detach(){this.control&&(n(this,Qn,"f").unobserve(this.control),n(this,Kn,"f").unobserve(this.control),n(this,ei,"f").unobserve(this.control)),super.detach()}connectedCallback(){this.ariaHidden="true",super.connectedCallback()}disconnectedCallback(){super.disconnectedCallback(),this._shadow?.classList.toggle("hover",!1),this._shadow?.classList.toggle("focus",!1),this._shadow?.classList.toggle("pressed",!1),this._shadow?.classList.toggle("resting",!1)}updated(e){super.updated(e),e.has("disabled")&&this.disabled&&(this._shadow?.classList.toggle("hover",!1),this._shadow?.classList.toggle("focus",!1),this._shadow?.classList.toggle("pressed",!1),this._shadow?.classList.toggle("resting",!0))}render(){return w`<div class="shadow"></div>`}};Qn=new WeakMap;Kn=new WeakMap;ei=new WeakMap;Cr=new WeakSet;Ud=function(e){this.disabled||(this._shadow?.classList.toggle("hover",e),this._shadow?.classList.toggle("resting",!e))};jd=function(e){this.disabled||this._shadow?.classList.toggle("focus",e)};Gd=function(e){this.disabled||this._shadow?.classList.toggle("pressed",e)};No.styles=C`:host { display: block; } :host, .shadow { position: absolute; left: 0; top: 0; right: 0; bottom: 0; pointer-events: none; border-radius: inherit; } .shadow.resting, .shadow.focus, .shadow.pressed { will-change: box-shadow; transition: ${o(`box-shadow ${pt.settleDuration} ${pt.settleEasing};`)}; } .shadow.hover { will-change: box-shadow; transition: ${o(`box-shadow ${pt.liftDuration} ${pt.liftEasing};`)}; } .shadow { box-shadow: ${pt.level}; } .shadow.focus { box-shadow: ${pt.focusLevel}; } .shadow.hover { box-shadow: ${pt.hoverLevel}; } .shadow.pressed { box-shadow: ${pt.pressedLevel}; } :host([level="0"]) .shadow { --m3e-elevation-level: ${a.elevation.level0}; --m3e-elevation-hover-level: ${a.elevation.level1}; } :host([level="1"]) .shadow { --m3e-elevation-level: ${a.elevation.level1}; --m3e-elevation-hover-level: ${a.elevation.level2}; } :host([level="2"]) .shadow { --m3e-elevation-level: ${a.elevation.level2}; --m3e-elevation-hover-level: ${a.elevation.level3}; } :host([level="3"]) .shadow { --m3e-elevation-level: ${a.elevation.level3}; --m3e-elevation-hover-level: ${a.elevation.level4}; } :host([level="4"]) .shadow { --m3e-elevation-level: ${a.elevation.level4}; --m3e-elevation-hover-level: ${a.elevation.level5}; } :host([level="5"]) .shadow { --m3e-elevation-level: ${a.elevation.level5}; --m3e-elevation-hover-level: ${pt.level}; } :host([level]) .shadow { --m3e-elevation-focus-level: ${pt.level}; --m3e-elevation-pressed-level: ${pt.level}; } @media (prefers-reduced-motion) { .shadow.resting, .shadow.pressed, .shadow.focus, .shadow.hover { transition: none; } } @media (forced-colors: active) { .shadow { display: none; } }`;h([M(".shadow")],No.prototype,"_shadow",void 0);h([b({type:Boolean,reflect:!0})],No.prototype,"disabled",void 0);h([b({type:Number,reflect:!0})],No.prototype,"level",void 0);No=h([L("m3e-elevation")],No);var ce={color:o(`var(--m3e-focus-ring-color, ${a.color.secondary})`),duration:o(`var(--m3e-focus-ring-duration, ${a.motion.duration.long2})`),thickness:o("var(--m3e-focus-ring-thickness, 3px)"),outwardOffset:o("var(--m3e-focus-ring-outward-offset, 2px)"),inwardOffset:o("var(--m3e-focus-ring-inward-offset, 0px)"),visibility:o("var(--m3e-focus-ring-visibility, visible)"),growthFactor:o("var(--m3e-focus-ring-growth-factor, 2)")},dl,ti,Yd,qo=class extends Xe(W(P,"none")){constructor(){super(...arguments),dl.add(this),ti.set(this,new je(this,{target:null,callback:(e,r)=>n(this,dl,"m",Yd).call(this,r)})),this.inward=!1,this.disabled=!1}show(){this._outline?.classList.toggle("visible",!0)}hide(){this._outline?.classList.toggle("visible",!1)}attach(e){super.attach(e),n(this,ti,"f").observe(e)}detach(){this.control&&n(this,ti,"f").unobserve(this.control),super.detach()}connectedCallback(){this.ariaHidden="true",super.connectedCallback()}disconnectedCallback(){super.disconnectedCallback(),this.hide()}render(){return w`<div class="outline"></div>`}updated(e){super.updated(e),e.has("disabled")&&this.disabled&&this.hide()}};ti=new WeakMap;dl=new WeakSet;Yd=function(e){this.disabled||(e?this.show():this.hide())};qo.styles=C`:host { display: block; position: absolute; left: 0; top: 0; right: 0; bottom: 0; pointer-events: none; border-radius: inherit; outline: none; } .outline { contain: layout style; position: absolute; left: 0; top: 0; right: 0; bottom: 0; pointer-events: none; border-radius: inherit; z-index: 1; outline-color: ${ce.color}; outline-width: ${ce.thickness}; visibility: ${ce.visibility}; } .outline.visible { outline-style: solid; } :host(:not([inward])) .outline { outline-offset: ${ce.outwardOffset}; } :host([inward]) .outline { outline-offset: calc(${ce.inwardOffset} - ${ce.thickness}); } :host(:not([inward])) .outline.visible { animation: grow-shrink ${ce.duration}; } :host([inward]) .outline.visible { animation: shrink-grow ${ce.duration}; } @keyframes grow-shrink { 50% { outline-width: calc(${ce.thickness} * ${ce.growthFactor}); } } @keyframes shrink-grow { 50% { outline-offset: calc( ${ce.inwardOffset} - calc(${ce.thickness} * ${ce.growthFactor}) ); outline-width: calc(${ce.thickness} * ${ce.growthFactor}); } } @media (prefers-reduced-motion) { :host(:not([inward])) .outline.visible, :host([inward]) .outline.visible { animation: none; } } @media (forced-colors: active) { .outline { outline-color: Highlight; } }`;h([M(".outline")],qo.prototype,"_outline",void 0);h([b({type:Boolean,reflect:!0})],qo.prototype,"inward",void 0);h([b({type:Boolean,reflect:!0})],qo.prototype,"disabled",void 0);qo=h([L("m3e-focus-ring")],qo);var di=class extends qd(se(W(P,"none"))){connectedCallback(){super.connectedCallback(),this.ariaHidden="true"}render(){return this.indeterminate?w`<svg viewBox="0 -960 960 960" fill="currentColor"><path Required d="M240-440v-80h480v80H240Z"/></svg>`:this.checked?w`<svg viewBox="0 -960 960 960" fill="currentColor"><path d="M382-240 154-468l57-57 171 171 367-367 57 57-424 424Z"/></svg>`:F}};di.styles=C`:host { display: inline-block; vertical-align: middle; width: var(--m3e-checkbox-icon-size, 1.125rem); height: var(--m3e-checkbox-icon-size, 1.125rem); border-radius: var(--m3e-checkbox-container-shape, 2px); box-sizing: border-box; flex: none; contain: layout style paint; } :host(:not([checked]):not([indeterminate])) { border-width: var(--m3e-checkbox-unselected-outline-thickness, 2px); border-style: solid; } :host(:not([disabled])[checked]), :host(:not([disabled])[indeterminate]) { background-color: var(--m3e-checkbox-selected-container-color, ${a.color.primary}); color: var(--m3e-checkbox-selected-icon-color, ${a.color.onPrimary}); } :host(:not([disabled]):not([checked]):not([indeterminate])) { border-color: var(--m3e-checkbox-unselected-outline-color, ${a.color.onSurfaceVariant}); } :host([disabled]:not([checked]):not([indeterminate])) { border-color: color-mix( in srgb, var(--m3e-checkbox-unselected-disabled-outline-color, ${a.color.onSurface}) var(--m3e-checkbox-unselected-disabled-outline-opacity, 38%), transparent ); } :host([disabled][checked]), :host([disabled][indeterminate]) { background-color: color-mix( in srgb, var(--m3e-checkbox-selected-disabled-container-color, ${a.color.onSurface}) var(--m3e-checkbox-selected-disabled-container-opacity, 38%), transparent ); color: color-mix( in srgb, var(--m3e-checkbox-selected-disabled-icon-color, ${a.color.surface}) var(--m3e-checkbox-selected-disabled-icon-opacity, 100%), transparent ); } svg { pointer-events: none; } @media (forced-colors: active) { :host(:not([disabled])[checked]), :host(:not([disabled])[indeterminate]) { border-color: Highlight; background-color: Highlight; color: HighlightText; } :host(:not([disabled]):not([checked]):not([indeterminate])) { border-color: CanvasText; background: Canvas; } :host([disabled]:not([checked]):not([indeterminate])) { border-color: GrayText; background-color: Canvas; } :host([disabled][checked]), :host([disabled][indeterminate]) { background-color: GrayText; color: Canvas; } }`;di=h([L("m3e-pseudo-checkbox")],di);var hi=class extends pl(se(W(P,"none"))){connectedCallback(){super.connectedCallback(),this.ariaHidden="true"}render(){return w`<svg class="icon" viewBox="0 0 20 20"><mask id="cutout2"><rect width="100%" height="100%" fill="white"></rect><circle cx="10" cy="10" r="8" fill="black"></circle></mask><circle class="outer circle" cx="10" cy="10" r="10" mask="url(#cutout2)"></circle><circle class="inner circle" cx="10" cy="10" r="5"></circle></svg>`}};hi.styles=C`:host { display: inline-block; vertical-align: middle; box-sizing: border-box; width: var(--m3e-radio-icon-size, 1.25rem); height: var(--m3e-radio-icon-size, 1.25rem); flex: none; contain: layout style paint; } .circle { fill: currentColor; } :host(:not([checked])) .circle.inner { opacity: 0; } :host(:not([checked])) { color: var(--m3e-radio-unselected-icon-color, ${a.color.onSurfaceVariant}); } :host([checked]) { color: var(--m3e-radio-selected-icon-color, ${a.color.primary}); } :host([disabled]) { color: color-mix(in srgb, var(--m3e-radio-disabled-icon-color, ${a.color.onSurface}) 38%, transparent); } @media (forced-colors: active) { :host { border-radius: 50%; } :host(:not([checked])) { color: CanvasText; background-color: Canvas; } :host([checked]) { color: HighlightText; background-color: Highlight; } :host([disabled]) { color: GrayText; background-color: Canvas; } }`;hi=h([L("m3e-pseudo-radio")],hi);var ko={color:o(`var(--m3e-ripple-color, ${a.color.onSurface})`),opacity:o(`var(--m3e-ripple-opacity, ${a.state.pressedStateLayerOpacity})`),enterDuration:o(`var(--m3e-ripple-enter-duration, ${a.motion.duration.long4})`),exitDuration:o(`var(--m3e-ripple-exit-duration, ${a.motion.duration.short2})`),scaleFactor:o("var(--m3e-ripple-scale-factor, 2.5)")},Po,xe,oi,ai,Xd,Zd,so=class extends Xe(W(P,"none")){constructor(){super(...arguments),Po.add(this),xe.set(this,null),oi.set(this,new fe(this,{target:null,minPressedDuration:150,isPressedKey:e=>e===" ",callback:(e,{x:r,y:i})=>n(this,Po,"m",Zd).call(this,e,r,i)})),this.disabled=!1,this.centered=!1,this.unbounded=!1,this.radius=null}get visible(){return n(this,xe,"f")!==null}show(e,r,i=!1){n(this,Po,"m",ai).call(this);let s=this.getBoundingClientRect();this.centered&&(e=s.left+s.width/2,r=s.top+s.height/2);let l=this.radius;if(!l||isNaN(l)){let u=Math.max(Math.abs(e-s.left),Math.abs(e-s.right)),p=Math.max(Math.abs(r-s.top),Math.abs(r-s.bottom));l=Math.sqrt(u*u+p*p)}let c=e-s.left,d=r-s.top;f(this,xe,document.createElement("div"),"f"),n(this,xe,"f").classList.add("ripple"),i&&n(this,xe,"f").classList.add("persistent"),n(this,xe,"f").style.left=`${c-l}px`,n(this,xe,"f").style.top=`${d-l}px`,n(this,xe,"f").style.width=`${l*2}px`,n(this,xe,"f").style.height=`${l*2}px`,n(this,xe,"f").addEventListener("animationend",()=>n(this,Po,"m",Xd).call(this,i),{once:!0}),n(this,xe,"f").addEventListener("transitionend",()=>n(this,Po,"m",ai).call(this),{once:!0}),this.shadowRoot?.appendChild(n(this,xe,"f"))}hide(){n(this,xe,"f")?.classList.add("exit")}attach(e){super.attach(e),n(this,oi,"f").observe(e)}detach(){this.control&&n(this,oi,"f").unobserve(this.control),super.detach()}connectedCallback(){this.ariaHidden="true",super.connectedCallback()}disconnectedCallback(){super.disconnectedCallback(),n(this,Po,"m",ai).call(this)}updated(e){super.updated(e),e.has("disabled")&&this.disabled&&this.hide()}};xe=new WeakMap;oi=new WeakMap;Po=new WeakSet;ai=function(){n(this,xe,"f")?.remove(),f(this,xe,null,"f")};Xd=function(e){e?n(this,xe,"f")?.classList.add("pressed"):this.hide()};Zd=function(e,r,i){this.disabled||(e?this.show(r,i,!0):this.hide())};so.styles=C`:host { display: block; position: absolute; left: 0; top: 0; right: 0; bottom: 0; pointer-events: none; border-radius: inherit; } :host(:not([unbounded])) { overflow: hidden; } :host(:not([unbounded])) .ripple { contain: layout style paint; } :host([unbounded]) .ripple { contain: layout style; } .ripple { display: block; position: absolute; left: 0; top: 0; right: 0; bottom: 0; pointer-events: none; transform: scale(0); border-radius: ${a.shape.corner.full}; background-color: color-mix(in srgb, ${ko.color} ${ko.opacity}, transparent); will-change: background-color, opacity; animation: ripple ${ko.enterDuration} linear; } .ripple.persistent.pressed { transform: scale(${ko.scaleFactor}); } .ripple.exit { transition: opacity ${ko.exitDuration} cubic-bezier(0, 0, 0.2, 0.1); opacity: 0; } @keyframes ripple { to { transform: scale(${ko.scaleFactor}); } } @media (prefers-reduced-motion) { .ripple { transform: scale(${ko.scaleFactor}); animation-duration: 90ms; } .ripple.exit { transition-duration: 10ms; } } @media (forced-colors: active) { .ripple { display: none; } }`;h([b({type:Boolean,reflect:!0})],so.prototype,"disabled",void 0);h([b({type:Boolean,reflect:!0})],so.prototype,"centered",void 0);h([b({type:Boolean,reflect:!0})],so.prototype,"unbounded",void 0);h([b({type:Number})],so.prototype,"radius",void 0);so=h([L("m3e-ripple")],so);var Sr,Vo=class extends Q(P){constructor(){super(...arguments),Sr.set(this,()=>this._updateScroll()),this.dividers="above-below",this.thin=!1}disconnectedCallback(){super.disconnectedCallback(),this.removeEventListener("scroll",n(this,Sr,"f"))}update(e){super.update(e),e.has("dividers")&&(this.removeEventListener("scroll",n(this,Sr,"f")),this.dividers!=="none"&&this.addEventListener("scroll",n(this,Sr,"f"),{passive:!0}))}render(){return w`<slot @slotchange="${this._updateScroll}"></slot>`}_updateScroll(){let e=(this.dividers==="above"||this.dividers==="above-below")&&this.scrollTop>0,r=(this.dividers==="below"||this.dividers==="above-below")&&this.scrollHeight-this.scrollTop-this.clientHeight>1;R(this,"--above",e),R(this,"--below",r)}};Sr=new WeakMap;Vo.styles=C`:host { display: block; overflow-y: auto; position: relative; box-sizing: border-box; scrollbar-color: ${a.scrollbar.color}; border-top: var(--m3e-divider-thickness, 1px) solid transparent; border-bottom: var(--m3e-divider-thickness, 1px) solid transparent; outline-color: ${ce.color}; outline-width: ${ce.thickness}; outline-offset: ${ce.outwardOffset}; } :host([thin]) { scrollbar-width: ${a.scrollbar.thinWidth}; } :host(:not([thin])) { scrollbar-width: ${a.scrollbar.width}; } :host(:not(:focus-visible):is(:state(--above), :--above)) { border-top-color: var(--m3e-divider-color, ${a.color.outlineVariant}); } :host(:not(:focus-visible):is(:state(--below), :--below)) { border-bottom-color: var(--m3e-divider-color, ${a.color.outlineVariant}); } :host(:focus-visible) { outline-style: solid; animation: grow-shrink ${ce.duration}; } @keyframes grow-shrink { 50% { outline-width: calc(${ce.thickness} * ${ce.growthFactor}); } } @media (forced-colors: active) { :host { border-top: var(--m3e-divider-thickness, 1px) solid Canvas; border-bottom: var(--m3e-divider-thickness, 1px) solid Canvas; } :host(:not(:focus-visible):is(:state(--above), :--above)) { border-top-color: GrayText; } :host(:not(:focus-visible):is(:state(--below), :--below)) { border-bottom-color: GrayText; } } @media (prefers-reduced-motion) { :host(:focus-visible) { animation: none; } }`;h([b()],Vo.prototype,"dividers",void 0);h([b({type:Boolean,reflect:!0})],Vo.prototype,"thin",void 0);h([vt(40)],Vo.prototype,"_updateScroll",null);Vo=h([L("m3e-scroll-container")],Vo);var Pr,Ro,Jd,bl,Fr=class extends Q(P){constructor(){super(...arguments),Pr.add(this),Ro.set(this,new Array),this.selectedIndex=null}connectedCallback(){super.connectedCallback(),ae(this,"--no-animate")}update(e){super.update(e),e.has("selectedIndex")&&(this.selectedIndex===null&&ae(this,"--no-animate"),n(this,Pr,"m",bl).call(this),this.selectedIndex!==null&&ie(this,"--no-animate")&&requestAnimationFrame(()=>{this.selectedIndex!==null&&D(this,"--no-animate")}))}render(){return w`<slot @slotchange="${n(this,Pr,"m",Jd)}"></slot>`}};Ro=new WeakMap;Pr=new WeakSet;Jd=function(e){let r=[...e.target.assignedElements({flatten:!0})];for(let i of n(this,Ro,"f").filter(s=>!r.includes(s)))i.classList.remove("-before"),i.classList.remove("-after"),i.removeAttribute("inert");f(this,Ro,r,"f"),n(this,Pr,"m",bl).call(this)};bl=function(){let e=this.selectedIndex??n(this,Ro,"f").length;for(let r=0;r<n(this,Ro,"f").length;r++){let i=n(this,Ro,"f")[r];i.classList.toggle("-before",r<e),i.classList.toggle("-after",r>e),i.toggleAttribute("inert",r!==e)}};Fr.styles=C`:host { display: flex; position: relative; overflow: hidden; } ::slotted(*) { width: 100%; top: 0; transition: ${o(`inset-inline-start var(--m3e-slide-animation-duration, ${a.motion.duration.long2}) ${a.motion.easing.standard},
        visibility var(--m3e-slide-animation-duration, ${a.motion.duration.long2}) ${a.motion.easing.standard} allow-discrete`)}; } ::slotted(.-before), ::slotted(.-after) { visibility: hidden; position: absolute; } ::slotted(.-before) { inset-inline-start: -100%; } ::slotted(.-after) { inset-inline-start: 100%; } ::slotted(:not(.-before):not(.-after)) { position: relative; inset-inline-start: 0; } :host(:is(:state(--no-animate), :--no-animate)) ::slotted(*) { transition: none; } @media (prefers-reduced-motion) { ::slotted(*) { transition: none; } }`;h([b({attribute:"selected-index",type:Number,reflect:!0})],Fr.prototype,"selectedIndex",void 0);Fr=h([L("m3e-slide")],Fr);var Sa={hoverColor:o(`var(--m3e-state-layer-hover-color, ${a.color.onSurface})`),hoverOpacity:o(`var(--m3e-state-layer-hover-opacity, ${a.state.hoverStateLayerOpacity})`),focusColor:o(`var(--m3e-state-layer-focus-color, ${a.color.onSurface})`),focusOpacity:o(`var(--m3e-state-layer-focus-opacity, ${a.state.focusStateLayerOpacity})`),duration:o(`var(--m3e-state-layer-duration, ${a.motion.duration.medium1})`),easing:o(`var(--m3e-state-layer-easing, ${a.motion.easing.standard})`)},ri,ni,ii,Qd,Kd,Uo=class extends Xe(W(P,"none")){constructor(){super(...arguments),ri.add(this),ni.set(this,new Vt(this,{target:null,callback:e=>n(this,ri,"m",Qd).call(this,e)})),ii.set(this,new je(this,{target:null,callback:(e,r)=>n(this,ri,"m",Kd).call(this,r)})),this.disabled=!1,this.disableHover=!1}show(e){this._layer?.classList.toggle(e,!0)}hide(e){this._layer?.classList.toggle(e,!1)}attach(e){super.attach(e),n(this,ni,"f").observe(e),n(this,ii,"f").observe(e)}detach(){this.control&&(n(this,ni,"f").unobserve(this.control),n(this,ii,"f").unobserve(this.control)),super.detach()}connectedCallback(){this.ariaHidden="true",super.connectedCallback()}disconnectedCallback(){super.disconnectedCallback(),this.hide("hover"),this.hide("focused")}updated(e){super.updated(e),e.has("disabled")&&this.disabled&&(this.hide("hover"),this.hide("focused")),e.has("disableHover")&&this.disableHover&&this.hide("hover")}render(){return w`<div class="layer"></div>`}};ni=new WeakMap;ii=new WeakMap;ri=new WeakSet;Qd=function(e){!this.disabled&&!this.disableHover&&(e?this.show("hover"):this.hide("hover"))};Kd=function(e){this.disabled||(e?this.show("focused"):this.hide("focused"))};Uo.styles=C`:host { display: block; } :host, .layer { position: absolute; left: 0; top: 0; right: 0; bottom: 0; pointer-events: none; border-radius: inherit; } .layer { contain: layout style paint; will-change: background-color; transition: ${o(`background-color ${Sa.duration} ${Sa.easing}`)}; } .layer.focused { background-color: color-mix(in srgb, ${Sa.focusColor} ${Sa.focusOpacity}, transparent); } .layer.hover { background-color: color-mix(in srgb, ${Sa.hoverColor} ${Sa.hoverOpacity}, transparent); } @media (prefers-reduced-motion) { .layer { transition: none; } } @media (forced-colors: active) { .layer { display: none; } }`;h([M(".layer")],Uo.prototype,"_layer",void 0);h([b({type:Boolean,reflect:!0})],Uo.prototype,"disabled",void 0);h([b({attribute:"disable-hover",type:Boolean,reflect:!0})],Uo.prototype,"disableHover",void 0);Uo=h([L("m3e-state-layer")],Uo);var Nt,Or,bt,Ao,hl,eh,ul,ml,jt=ml=class extends P{constructor(){super(),Nt.add(this),Or.set(this,`m3e-text-highlight-${ml.__nextId++}`),bt.set(this,new Array),Ao.set(this,null),this.disabled=!1,this.term="",this.caseSensitive=!1,this.mode="contains",this.isSupported&&(f(this,Ao,new CSSStyleSheet,"f"),n(this,Ao,"f").replaceSync(C`::highlight(${o(n(this,Or,"f"))}) { background-color: var(--m3e-text-highlight-container-color, ${a.color.secondaryContainer}); color: var(--m3e-text-highlight-color, ${a.color.onSecondaryContainer}); text-decoration: var(--m3e-text-highlight-decoration); text-shadow: var(--m3e-text-highlight-shadow); }`.toString()))}get isSupported(){return!!(!!1&&CSS.highlights)}get ranges(){return n(this,bt,"f")}firstUpdated(e){super.firstUpdated(e),this.shadowRoot&&n(this,Ao,"f")&&!this.shadowRoot.adoptedStyleSheets.includes(n(this,Ao,"f"))&&this.shadowRoot.adoptedStyleSheets.push(n(this,Ao,"f"))}updated(e){super.updated(e),(e.has("term")||e.has("caseSensitive")||e.has("disabled"))&&n(this,Nt,"m",ul).call(this)}render(){return w`<slot @slotchange="${n(this,Nt,"m",ul)}"></slot>`}};Or=new WeakMap;bt=new WeakMap;Ao=new WeakMap;Nt=new WeakSet;hl=function(e){return!/^\s*$/.test(e.data)};eh=function t(e,r){e instanceof HTMLSlotElement?e.assignedNodes({flatten:!0}).forEach(i=>{switch(i.nodeType){case Node.TEXT_NODE:n(this,Nt,"m",hl).call(this,i)&&r.push(i);break;case Node.ELEMENT_NODE:n(this,Nt,"m",t).call(this,i,r);break}}):e.childNodes.forEach(i=>{switch(i.nodeType){case Node.TEXT_NODE:n(this,Nt,"m",hl).call(this,i)&&r.push(i);break;case Node.ELEMENT_NODE:n(this,Nt,"m",t).call(this,i,r);break}})};ul=function(){if(!this.isSupported||!this.isConnected||(CSS.highlights.delete(n(this,Or,"f")),n(this,bt,"f").length=0,this.disabled))return;if(!this.term){this.dispatchEvent(new CustomEvent("highlight",{detail:[...n(this,bt,"f")],bubbles:!1,composed:!1}));return}let e=new Array;if(n(this,Nt,"m",eh).call(this,this,e),e.length>0){let r=this.caseSensitive?this.term:this.term.toLowerCase();switch(this.mode){case"starts-with":{let i=e[0];if(((this.caseSensitive?i.textContent:i.textContent?.toLowerCase())??"").startsWith(r)){let l=new Range;l.setStart(i,0),l.setEnd(i,r.length),n(this,bt,"f").push(l)}}break;case"ends-with":{let i=e[e.length-1],s=(this.caseSensitive?i.textContent:i.textContent?.toLowerCase())??"";if(s.endsWith(r)){let l=s.length-r.length,c=l+r.length,d=new Range;d.setStart(i,l),d.setEnd(i,c),n(this,bt,"f").push(d)}}break;case"contains":f(this,bt,e.map(i=>({el:i,text:(this.caseSensitive?i.textContent:i.textContent?.toLowerCase())??""})).map(({el:i,text:s})=>{let l=new Array,c=0;for(;c<s.length;){let d=s.indexOf(r,c);if(d===-1)break;l.push(d),c=d+r.length}return l.map(d=>{let u=new Range;return u.setStart(i,d),u.setEnd(i,d+r.length),u})}).flat(),"f");break}n(this,bt,"f").length>0&&CSS.highlights.set(n(this,Or,"f"),new Highlight(...n(this,bt,"f")))}this.dispatchEvent(new CustomEvent("highlight",{detail:[...n(this,bt,"f")],bubbles:!1,composed:!1}))};jt.styles=C`:host { display: contents; }`;jt.__nextId=0;h([b({type:Boolean,reflect:!0})],jt.prototype,"disabled",void 0);h([b()],jt.prototype,"term",void 0);h([b({attribute:"case-sensitive",type:Boolean})],jt.prototype,"caseSensitive",void 0);h([b()],jt.prototype,"mode",void 0);jt=ml=h([L("m3e-text-highlight")],jt);var ui=class extends P{render(){return w`<span class="base"><slot></slot></span>`}};ui.styles=C`:host { flex: 1 1 auto; display: inline-flex; align-items: center; flex-wrap: nowrap; min-width: 0; } .base { flex: 1 1 auto; display: inline; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }`;ui=h([L("m3e-text-overflow")],ui);function Sl(t,e){if(!e)return 0;let r=document.createElement("div");r.style.all="inherit",r.style.width=e,r.style.position="absolute",r.style.visibility="hidden",r.style.pointerEvents="none",t.appendChild(r);try{return parseFloat(getComputedStyle(r).width)}finally{r.remove()}}async function ch(t,e=200){t.focus();function r(s){let l=s.getRootNode();return l instanceof ShadowRoot?l.activeElement===s:document.activeElement===s}let i=performance.now();for(;!r(t);){if(!t.isConnected||performance.now()-i>e)return!1;await new Promise(requestAnimationFrame),t.focus()}return!0}function th(t,e,r){return t+(e-t)*r}function oh(t,e,r,i){let s=Math.pow(1-i,2)*t.x+2*(1-i)*i*e.x+Math.pow(i,2)*r.x,l=Math.pow(1-i,2)*t.y+2*(1-i)*i*e.y+Math.pow(i,2)*r.y;return{x:s,y:l}}function ah(t,e,r,i,s){let l=Math.pow(1-s,3)*t.x+3*Math.pow(1-s,2)*s*e.x+3*(1-s)*Math.pow(s,2)*r.x+Math.pow(s,3)*i.x,c=Math.pow(1-s,3)*t.y+3*Math.pow(1-s,2)*s*e.y+3*(1-s)*Math.pow(s,2)*r.y+Math.pow(s,3)*i.y;return{x:l,y:c}}function Gp(t){return(t.match(/[a-zA-Z][^a-zA-Z]*/g)||[]).map(r=>{let i=r[0],s=r.slice(1).trim().split(/[\s,]+/).filter(Boolean).map(Number);return{type:i,nums:s}})}function Yp(t,e){let r=Gp(t),i={x:0,y:0},s={x:0,y:0},l=[];for(let m of r)if(m.type==="M")i={x:m.nums[0],y:m.nums[1]},s=i;else if(m.type==="L"){let y={x:m.nums[0],y:m.nums[1]},v=y.x-i.x,x=y.y-i.y;l.push({type:"L",pts:[i,y],length:Math.hypot(v,x)}),i=y}else if(m.type==="H"){let y={x:m.nums[0],y:i.y},v=y.x-i.x;l.push({type:"L",pts:[i,y],length:Math.abs(v)}),i=y}else if(m.type==="V"){let y={x:i.x,y:m.nums[0]},v=y.y-i.y;l.push({type:"L",pts:[i,y],length:Math.abs(v)}),i=y}else if(m.type==="Q"){let y={x:m.nums[0],y:m.nums[1]},v={x:m.nums[2],y:m.nums[3]},x=0,_=i,S=20;for(let $=1;$<=S;$++){let T=$/S,z=oh(i,y,v,T);x+=Math.hypot(z.x-_.x,z.y-_.y),_=z}l.push({type:"Q",pts:[i,y,v],length:x}),i=v}else if(m.type==="C"){let y={x:m.nums[0],y:m.nums[1]},v={x:m.nums[2],y:m.nums[3]},x={x:m.nums[4],y:m.nums[5]},_=0,S=i,$=20;for(let T=1;T<=$;T++){let z=T/$,O=ah(i,y,v,x,z);_+=Math.hypot(O.x-S.x,O.y-S.y),S=O}l.push({type:"C",pts:[i,y,v,x],length:_}),i=x}else if(m.type==="Z"){let y=s.x-i.x,v=s.y-i.y;l.push({type:"L",pts:[i,s],length:Math.hypot(y,v)}),i=s}let d=l.reduce((m,y)=>m+y.length,0)/(e-1),u=[],p=0,g=0;for(let m=0;m<e;m++){let y=m*d;for(;g<l.length&&p+l[g].length<y;)p+=l[g].length,g++;let v=l[g];if(!v)break;let x=(y-p)/v.length;if(v.type==="L"){let[_,S]=v.pts;u.push({x:th(_.x,S.x,x),y:th(_.y,S.y,x)})}else if(v.type==="Q"){let[_,S,$]=v.pts;u.push(oh(_,S,$,x))}else if(v.type==="C"){let[_,S,$,T]=v.pts;u.push(ah(_,S,$,T,x))}}return u}function Xp(t){return`${t.map(r=>{let i=rh(r.x*100,0,100),s=rh(r.y*100,0,100);return`${i.toFixed(2)}% ${s.toFixed(2)}%`}).join(", ")}`}function rh(t,e,r){return Math.max(e,Math.min(r,t))}function Zp(t){let e=1/0,r=1/0,i=-1/0,s=-1/0;for(let l of t)l.x<e&&(e=l.x),l.x>i&&(i=l.x),l.y<r&&(r=l.y),l.y>s&&(s=l.y);return{minX:e,minY:r,maxX:i,maxY:s,width:i-e,height:s-r}}function Jp(t,e){let r=t.length,i=new Array(r);for(let s=0;s<r;s++)i[s]=t[(s+e)%r];return i}function Qp(t,e){let r=Math.min(e.length,t.length),i=0,s=1/0;for(let l=0;l<r;l++){let c=0;for(let d=0;d<r;d++){let u=e[(d+l)%r],p=t[d],g=u.x-p.x,m=u.y-p.y;if(c+=g*g+m*m,c>=s)break}c<s&&(s=c,i=l)}return i}function nh(t){let e=0,r=t.length;for(let i=0;i<r;i++){let s=t[i],l=t[(i+1)%r];e+=s.x*l.y-l.x*s.y}return e/2}function Kp(t){let e=t.map(s=>{let l=Zp(s),c=s.map(v=>({x:v.x-l.minX,y:v.y-l.minY})),d=Math.max(l.width,l.height)||1,u=c.map(v=>({x:v.x/d,y:v.y/d})),p=l.width/d,g=l.height/d,m=(1-p)/2,y=(1-g)/2;return u.map(v=>({x:v.x+m,y:v.y+y}))}),r=e[0],i=Math.sign(nh(r));for(let s=1;s<e.length;s++){let l=e[s],c=Math.sign(nh(l));c!==0&&c!==i&&(l=l.slice().reverse());let d=Qp(r,l);e[s]=Jp(l,d)}return e}function dh(t,e){return Kp(t.map(r=>Yp(r,e))).map(r=>Xp(r))}function Go(t,e=!1){let r="";switch(t.nodeType){case Node.TEXT_NODE:r=t.nodeValue??"";break;case Node.ELEMENT_NODE:if(t instanceof HTMLSlotElement)for(let i of t.assignedNodes({flatten:!0}))r+=Go(i,e);else for(let i of t.childNodes)r+=Go(i,e);break}return e&&(r=r.trim()),r}function he(t){return t.assignedNodes({flatten:!0}).length>0}function hh(t,e,r){let i=Object.getOwnPropertyDescriptor(t,e)??Object.getOwnPropertyDescriptor(Object.getPrototypeOf(t),e);if(!i)throw new Error(`Property ${String(e)} not found on target.`);let s=i.get?.bind(t),l=i.set?.bind(t);return Object.defineProperty(t,e,{configurable:!0,enumerable:i.enumerable,get(){return r.get?r.get(()=>s?.()):s?.()},set(c){r.set?r.set(c,d=>l?.(d)):l?.(c)}}),()=>Object.defineProperty(t,e,i)}function ho(t){if(typeof window>"u")return;let e=new CSSStyleSheet;e.replaceSync(t.toString()),document.adoptedStyleSheets=[...document.adoptedStyleSheets,e]}async function uh(t){let e=t.tagName.toLowerCase();if(!e.includes("-"))return;customElements.get(e)||await customElements.whenDefined(e);let r=customElements.get(e);!r||t instanceof r||(await Promise.resolve(),!(t instanceof r)&&await Promise.resolve())}var mh={fromAttribute(t){return t?t.split(/\s+/).map(e=>e.trim()).filter(Boolean):[]},toAttribute(t){return t.join(" ")}};function kl(t){return Ye(t,"selected")}function gi(t){class e extends t{constructor(){super(...arguments),this.selected=!1}update(i){super.update(i),i.has("selected")&&(this.role==="button"?(this.ariaPressed=`${this.selected}`,this.ariaSelected=null,this.ariaChecked=null):this.role==="radio"?(this.ariaChecked=`${this.selected}`,this.ariaSelected=null,this.ariaPressed=null):this.role&&this.role!=="none"&&this.role!=="presentation"&&(this.ariaSelected=`${this.selected}`,this.ariaPressed=null,this.ariaChecked=null))}}return h([b({type:Boolean,reflect:!0})],e.prototype,"selected",void 0),e}function Yo(t){return jo(t)&&t.checked||kl(t)&&t.selected}function Hr(t,e){jo(t)?t.checked=e:t.selected=e}function ef(t){return Ye(t,"dirty","pristine","markAsDirty","markAsPristine")}var vl=Symbol("_eventHandler");function El(t){var e;class r extends t{constructor(){super(...arguments),this[e]=()=>this.markAsDirty()}get dirty(){return ie(this,"--dirty")}get pristine(){return!this.dirty}connectedCallback(){this.markAsPristine(),super.connectedCallback(),this.addEventListener("change",this[vl])}disconnectedCallback(){super.disconnectedCallback(),this.removeEventListener("change",this[vl])}markAsPristine(){D(this,"--dirty")}markAsDirty(){ae(this,"--dirty")}}return e=vl,r}function Ml(t){return Ye(t,"touched","untouched","markAsTouched","markAsUntouched")}var gl=Symbol("_eventHandler");function Ll(t){var e;class r extends t{constructor(){super(...arguments),this[e]=()=>this.markAsTouched()}get touched(){return ie(this,"--touched")}get untouched(){return!this.touched}connectedCallback(){this.markAsUntouched(),super.connectedCallback(),this.addEventListener("focusout",this[gl],{capture:!0})}disconnectedCallback(){super.disconnectedCallback(),this.removeEventListener("focusout",this[gl],{capture:!0})}markAsTouched(){ae(this,"--touched")}markAsUntouched(){D(this,"--touched")}}return e=gl,r}function co(t){return Ye(t,"disabledInteractive")&&gt(t)}var ih=["click","dblclick","auxclick","keydown","keyup"],tf=["Tab","ArrowLeft","ArrowUp","ArrowRight","ArrowDown","Left","Up","Right","Down"],yl=Symbol("_suppressedEventHandler");function Ze(t){var e;class r extends t{constructor(){super(...arguments),this[e]=s=>{if(this.disabledInteractive){if(s instanceof KeyboardEvent&&tf.includes(s.key))return;s.stopImmediatePropagation(),s.preventDefault()}},this.disabledInteractive=!1}connectedCallback(){ih.forEach(s=>this.addEventListener(s,this[yl],!0)),super.connectedCallback()}disconnectedCallback(){ih.forEach(s=>this.removeEventListener(s,this[yl],!0)),super.disconnectedCallback()}update(s){super.update(s),(s.has("disabled")||s.has("disabledInteractive"))&&this.role&&this.role!=="none"&&this.role!=="presentation"&&this.role!=="none"&&(this.ariaDisabled=this.disabled||this.disabledInteractive?"true":null)}}return e=yl,h([b({attribute:"disabled-interactive",type:Boolean,reflect:!0})],r.prototype,"disabledInteractive",void 0),r}var bi=Symbol("updateLabels");function of(t){return Ye(t,"labels")&&Nd(t)}var Rr=Symbol("_eventHandler");function ph(t){var e;class r extends t{constructor(){super(...arguments),this[e]=s=>{s.defaultPrevented||this[bi]()}}get labels(){return this[de].labels}connectedCallback(){super.connectedCallback(),this.addEventListener("focusout",this[Rr]),this.addEventListener("change",this[Rr])}disconnectedCallback(){super.disconnectedCallback(),this.removeEventListener("focusout",this[Rr]),this.removeEventListener("change",this[Rr])}update(s){super.update(s),this[bi]()}[(e=Rr,bi)](){let s=this.hasAttribute("tabindex"),l=gt(this)&&this.disabled||co(this)&&this.disabledInteractive,c=Ml(this)&&this.touched&&(this.ariaInvalid||ie(this,"--invalid"));for(let d of this.labels??[])d.style.userSelect=s?"none":"",d.style.cursor=!l&&s?"pointer":"",!l&&s?d.style.setProperty("-webkit-tap-highlight-color","rgba(0, 0, 0, 0)"):d.style.removeProperty("-webkit-tap-highlight-color"),d.style.color=l?`color-mix(in srgb, ${a.color.onSurface} 38%, transparent)`:c?`${a.color.error}`:""}}return r.formAssociated=!0,r}var Dr=Symbol("formValue"),sh=Symbol("defaultValue");var pi=Symbol("_defaultValue"),xl=Symbol("_defaultIndeterminate"),wl=Symbol("_formDisabled");function Tl(t){var e,r;class i extends t{constructor(){super(...arguments),this[e]=!1,this[r]=!1}get form(){return this[de].form}get labels(){return this[de].labels}get[(e=xl,r=wl,Dr)](){return null}get[sh](){return this[pi]}get name(){return this.getAttribute("name")??""}set name(l){l?this.setAttribute("name",l):this.removeAttribute("name")}get disabled(){return super.disabled||this[wl]}set disabled(l){super.disabled=l}connectedCallback(){super.connectedCallback(),jo(this)?(this[pi]=this.checked,fl(this)&&(this[xl]=this.indeterminate)):"value"in this&&(this[pi]=this.value)}requestUpdate(l,c,d){super.requestUpdate(l,c,d),this[de].setFormValue(this[Dr])}formDisabledCallback(l){let c=this.disabled;this[wl]=l,this.disabled!=c&&this.requestUpdate("disabled",c)}formResetCallback(){jo(this)?(this.checked=this[pi]===!0,fl(this)&&(this.indeterminate=this[xl])):"value"in this&&(this.value=this[sh]),ef(this)&&this.markAsPristine(),Ml(this)&&this.markAsUntouched()}}return i.formAssociated=!0,h([b({noAccessor:!0})],i.prototype,"name",null),h([b({type:Boolean})],i.prototype,"disabled",null),i}var vi=Symbol("validate");var lo=Symbol("_updateValidity"),fi=Symbol("_validityMessage");function fh(t){var e,r;class i extends t{constructor(){super(...arguments),e.add(this)}get willValidate(){return this[de].willValidate}get validity(){return this[lo](),this[de].validity}get validationMessage(){return this[lo](),this[de].validationMessage}[(e=new WeakSet,vi)](){return this[fi]?{customError:!0}:void 0}reportValidity(){return Ml(this)&&this.markAsTouched(),this[lo](),this[de].reportValidity()}checkValidity(){return this[lo](),this[de].checkValidity()}setCustomValidity(l){l?this[fi]=l:this[fi]=void 0,this[lo]()}requestUpdate(l,c,d){super.requestUpdate(l,c,d),this[lo]()}firstUpdated(l){super.firstUpdated(l),this[lo]()}[lo](){if(!this.isConnected)return;let l=this[vi](),c=l&&Object.keys(l).some(u=>l[u]===!0),d=l?.customError?this[fi]:"";l&&!d&&(d=n(this,e,"m",r).call(this,l)),this[de].setValidity(l,d),this.ariaInvalid=c?"true":null,R(this,"--invalid",c===!0),of(this)&&this[bi]?.()}}return r=function(l){let c=document.createElement("input");return c.type="text",l.valueMissing&&(c.required=!0,c.value=""),l.typeMismatch&&(c.type="email",c.value="not-an-email"),l.patternMismatch&&(c.pattern="[0-9]{4}",c.value="abcd"),l.tooShort&&(c.minLength=5,c.value="abc"),l.tooLong&&(c.maxLength=2,c.value="abcdef"),l.rangeUnderflow&&(c.type="number",c.min="10",c.value="5"),l.rangeOverflow&&(c.type="number",c.max="5",c.value="10"),l.stepMismatch&&(c.type="number",c.step="2",c.value="3"),l.badInput&&(c.type="number",c.value="abc"),c.setCustomValidity(""),c.checkValidity(),c.validationMessage},i}var Br=Symbol("_tabindex");function Be(t){var e;class r extends t{constructor(){super(...arguments),this[e]=0}connectedCallback(){this[Br]=Number.parseInt(this.getAttribute("tabindex")??"0"),super.connectedCallback()}firstUpdated(s){super.firstUpdated(s),!this.hasAttribute("tabindex")&&!s.has("disabled")&&this.setAttribute("tabindex",`${this[Br]}`)}update(s){if(super.update(s),s.has("disabled"))if(!this.disabled&&this.role!=="none")this.hasAttribute("tabindex")||this.setAttribute("tabindex",`${this[Br]}`);else{let l=this.getAttribute("tabindex");l&&(this[Br]=Number.parseInt(l)),this.removeAttribute("tabindex")}}}return e=Br,r}var _l=Symbol("_clickHandler");function yt(t){var e;class r extends t{constructor(){super(...arguments),this.type="button",this[e]=async s=>{if(s.defaultPrevented||gt(this)&&this.disabled||co(this)&&this.disabledInteractive)return;let l=this[de].form;if(!(!l||this.type==="button")&&(await new Promise(c=>setTimeout(c)),!s.defaultPrevented))switch(this.type){case"reset":l.reset();break;case"submit":l.addEventListener("submit",c=>Object.defineProperty(c,"submitter",{configurable:!0,enumerable:!0,get:()=>this}),{capture:!0,once:!0}),this[de].setFormValue(this.value),l.requestSubmit();break}}}get name(){return this.getAttribute("name")??""}set name(s){s?this.setAttribute("name",s):this.removeAttribute("name")}get value(){return this.getAttribute("value")}set value(s){s!=null?this.setAttribute("value",s):this.removeAttribute("value")}connectedCallback(){super.connectedCallback(),this.addEventListener("click",this[_l])}disconnectedCallback(){super.disconnectedCallback(),this.removeEventListener("click",this[_l])}}return e=_l,r.formAssociated=!0,h([b()],r.prototype,"name",null),h([b()],r.prototype,"value",null),h([b()],r.prototype,"type",void 0),r}function De(t,e=!0){var r,i,s,l,c,d,u;class p extends t{constructor(){super(...arguments),r.add(this),i.set(this,!1),s.set(this,m=>n(this,r,"m",d).call(this,m)),l.set(this,m=>n(this,r,"m",u).call(this,m)),c.set(this,()=>f(this,i,!1,"f"))}connectedCallback(){super.connectedCallback(),this.addEventListener("keydown",n(this,s,"f")),this.addEventListener("keyup",n(this,l,"f")),this.addEventListener("focusout",n(this,c,"f"))}disconnectedCallback(){super.disconnectedCallback(),this.removeEventListener("keydown",n(this,s,"f")),this.removeEventListener("keyup",n(this,l,"f")),this.removeEventListener("focusout",n(this,c,"f"))}}return i=new WeakMap,s=new WeakMap,l=new WeakMap,c=new WeakMap,r=new WeakSet,d=function(m){if(m.target!==m.currentTarget||gt(this)&&this.disabled||co(this)&&this.disabledInteractive){f(this,i,!1,"f");return}(m.key===" "||e&&m.key==="Enter")&&f(this,i,!0,"f")},u=function(m){if(m.target!==m.currentTarget||gt(this)&&this.disabled||co(this)&&this.disabledInteractive||!n(this,i,"f")){f(this,i,!1,"f");return}f(this,i,!1,"f"),this.dispatchEvent(new MouseEvent("click",{cancelable:!0,bubbles:!0,composed:!0}))},p}var xt=Symbol("renderPseudoLink");function bh(t){return Ye(t,"download","href","rel","target")}var $l=Symbol("_clickHandler");function wt(t,e=!1){var r,i,s,l,c;class d extends t{constructor(){super(...arguments),r.add(this),this[c]=async p=>{if(co(this)&&this.disabledInteractive&&(p.preventDefault(),p.stopPropagation()),await new Promise(g=>g()),!p.defaultPrevented&&this.href){p.preventDefault(),p.stopImmediatePropagation();let g=document.createElement("a");g.href=this.href,g.rel=this.rel,g.target=this.target,this.download!=null&&(g.download=this.download),g.addEventListener("click",async()=>{await new Promise(m=>m()),g.remove()}),document.body.appendChild(g),g.click()}},this.href="",this.target="",this.rel=""}get download(){return this.getAttribute("download")}set download(p){let g=this.download;g!==p&&(p?this.setAttribute("download",p):this.removeAttribute("download"),this.requestUpdate("download",g))}connectedCallback(){super.connectedCallback(),e||this.addEventListener("click",this[$l]),this.hasAttribute("href")&&this.role==="button"&&(this.role="link")}disconnectedCallback(){super.disconnectedCallback(),e||this.removeEventListener("click",this[$l])}[(r=new WeakSet,c=$l,xt)](){let p=gt(this)&&this.disabled,g=co(this)&&this.disabledInteractive;return!p&&!g&&this.href?w`<a href="${this.href}" target="${io(this.target||void 0)}" rel="${io(this.rel||void 0)}" download="${io(this.download||void 0)}" tabindex="-1" aria-hidden="true" @pointerdown="${n(this,r,"m",i)}" @focus="${n(this,r,"m",s)}" @blur="${n(this,r,"m",l)}"></a>`:F}}return i=function(p){p.button!==2?p.preventDefault():p.target.removeAttribute("aria-hidden")},s=function(p){p.target.blur(),this.focus()},l=function(p){p.target.setAttribute("aria-hidden","true")},h([b()],d.prototype,"href",void 0),h([b()],d.prototype,"target",void 0),h([b()],d.prototype,"rel",void 0),h([b({reflect:!1})],d.prototype,"download",null),d}function vh(t){return Ye(t,"readOnly")}var Cl=Symbol("_wasConnected");function uo(t){var e;class r extends t{constructor(){super(...arguments),this[e]=!1}reconnectedCallback(){}connectedCallback(){super.connectedCallback(),this[Cl]&&this.reconnectedCallback()}disconnectedCallback(){super.disconnectedCallback(),this[Cl]=!0}}return e=Cl,r}function gh(t){class e extends t{constructor(){super(...arguments),this.required=!1}get optional(){return!this.required}update(i){super.update(i),i.has("required")&&(this.ariaRequired=`${this.required}`)}}return h([b({type:Boolean,reflect:!0})],e.prototype,"required",void 0),e}function yh(t){class e extends t{[vi](){let i=super[vi]();if(!i&&this.required){if(jo(this)&&!this.checked)return{valueMissing:!0};if(!this.value)return{valueMissing:!0}}return i}}return e}var lh=Symbol("resumeAnimation");function yi(t){class e extends t{connectedCallback(){super.connectedCallback(),ae(this,"--no-animate"),this[lh]()}[lh](){requestAnimationFrame(()=>D(this,"--no-animate"))}}return e}function xh(t){class e extends t{constructor(){super(...arguments),this.vertical=!1}update(i){super.update(i),i.has("vertical")&&(this.ariaOrientation=this.vertical?"vertical":"horizontal")}}return h([b({type:Boolean,reflect:!0})],e.prototype,"vertical",void 0),e}var le={small:{containerHeight:o("var(--m3e-app-bar-small-container-height, 4rem)"),titleTextFontSize:o(`var(--m3e-app-bar-small-title-text-font-size, ${a.typescale.standard.title.large.fontSize})`),titleTextFontWeight:o(`var(--m3e-app-bar-small-title-text-font-weight, ${a.typescale.standard.title.large.fontWeight})`),titleTextLineHeight:o(`var(--m3e-app-bar-small-title-text-line-height, ${a.typescale.standard.title.large.lineHeight})`),titleTextTracking:o(`var(--m3e-app-bar-small-subtitle-text-tracking, ${a.typescale.standard.title.large.tracking})`),subtitleTextFontSize:o(`var(--m3e-app-bar-small-subtitle-text-font-size, ${a.typescale.standard.label.medium.fontSize})`),subtitleTextFontWeight:o(`var(--m3e-app-bar-small-subtitle-text-font-weight, ${a.typescale.standard.label.medium.fontWeight})`),subtitleTextLineHeight:o(`var(--m3e-app-bar-small-subtitle-text-line-height, ${a.typescale.standard.label.medium.lineHeight})`),subtitleTextTracking:o(`var(--m3e-app-bar-small-subtitle-text-tracking, ${a.typescale.standard.label.medium.tracking})`),headingPaddingLeft:o("var(--m3e-app-bar-small-heading-padding-left, 0.25rem)"),headingPaddingRight:o("var(--m3e-app-bar-small-heading-padding-right, 0.25rem)")},medium:{containerHeight:o("var(--m3e-app-bar-medium-container-height, 7rem)"),containerHeightWithSubtitle:o("var(--m3e-app-bar-medium-container-height-with-subtitle, 8.5rem)"),titleTextFontSize:o(`var(--m3e-app-bar-medium-title-text-font-size, ${a.typescale.standard.headline.medium.fontSize})`),titleTextFontWeight:o(`var(--m3e-app-bar-medium-title-text-font-weight, ${a.typescale.standard.headline.medium.fontWeight})`),titleTextLineHeight:o(`var(--m3e-app-bar-medium-title-text-line-height, ${a.typescale.standard.headline.medium.lineHeight})`),titleTextTracking:o(`var(--m3e-app-bar-medium-subtitle-text-tracking, ${a.typescale.standard.headline.medium.tracking})`),subtitleTextFontSize:o(`var(--m3e-app-bar-medium-subtitle-text-font-size, ${a.typescale.standard.title.small.fontSize})`),subtitleTextFontWeight:o(`var(--m3e-app-bar-medium-subtitle-text-font-weight, ${a.typescale.standard.title.small.fontWeight})`),subtitleTextLineHeight:o(`var(--m3e-app-bar-medium-subtitle-text-line-height, ${a.typescale.standard.title.small.lineHeight})`),subtitleTextTracking:o(`var(--m3e-app-bar-medium-subtitle-text-tracking, ${a.typescale.standard.title.small.tracking})`),headingPaddingLeft:o("var(--m3e-app-bar-medium-heading-padding-left, 1rem)"),headingPaddingRight:o("var(--m3e-app-bar-medium-heading-padding-right, 0.25rem)"),paddingTop:o("var(--m3e-app-bar-medium-padding-top, 0.5rem)"),paddingBottom:o("var(--m3e-app-bar-medium-padding-bottom, 0.75rem)"),titleMaxLines:o("var(--m3e-app-bar-medium-title-max-lines, 2)"),subtitleMaxLines:o("var(--m3e-app-bar-medium-subtitle-max-lines, 1)")},large:{containerHeight:o("var(--m3e-app-bar-large-container-height, 7.5rem)"),containerHeightWithSubtitle:o("var(--m3e-app-bar-large-container-height-with-subtitle, 9.5rem)"),titleTextFontSize:o(`var(--m3e-app-bar-large-title-text-font-size, ${a.typescale.standard.display.small.fontSize})`),titleTextFontWeight:o(`var(--m3e-app-bar-large-title-text-font-weight, ${a.typescale.standard.display.small.fontWeight})`),titleTextLineHeight:o(`var(--m3e-app-bar-large-title-text-line-height, ${a.typescale.standard.display.small.lineHeight})`),titleTextTracking:o(`var(--m3e-app-bar-large-subtitle-text-tracking, ${a.typescale.standard.display.small.tracking})`),subtitleTextFontSize:o(`var(--m3e-app-bar-large-subtitle-text-font-size, ${a.typescale.standard.title.medium.fontSize})`),subtitleTextFontWeight:o(`var(--m3e-app-bar-large-subtitle-text-font-weight, ${a.typescale.standard.title.medium.fontWeight})`),subtitleTextLineHeight:o(`var(--m3e-app-bar-large-subtitle-text-line-height, ${a.typescale.standard.title.medium.lineHeight})`),subtitleTextTracking:o(`var(--m3e-app-bar-large-subtitle-text-tracking, ${a.typescale.standard.title.medium.tracking})`),headingPaddingLeft:o("var(--m3e-app-bar-large-heading-padding-left, 1rem)"),headingPaddingRight:o("var(--m3e-app-bar-large-heading-padding-right, 0.25rem)"),paddingTop:o("var(--m3e-app-bar-large-padding-top, 0.5rem)"),paddingBottom:o("var(--m3e-app-bar-large-padding-bottom, 0.75rem)"),titleMaxLines:o("var(--m3e-app-bar-large-title-max-lines, 2)"),subtitleMaxLines:o("var(--m3e-app-bar-large-subtitle-max-lines, 1)")}};function Pl(t){return C`:host([size="${o(t)}"]) .base:not(.with-subtitle) { min-height: ${le[t].containerHeight}; } :host([size="${o(t)}"]) .base.with-subtitle { min-height: ${le[t].containerHeightWithSubtitle??le[t].containerHeight}; } :host([size="${o(t)}"]) .title { font-size: ${le[t].titleTextFontSize}; font-weight: ${le[t].titleTextFontWeight}; line-height: ${le[t].titleTextLineHeight}; letter-spacing: ${le[t].titleTextTracking}; } :host([size="${o(t)}"]) .subtitle { font-size: ${le[t].subtitleTextFontSize}; font-weight: ${le[t].subtitleTextFontWeight}; line-height: ${le[t].subtitleTextLineHeight}; letter-spacing: ${le[t].subtitleTextTracking}; } :host(:not([centered])[size="${o(t)}"]) .label { padding-inline-start: ${le[t].headingPaddingLeft}; padding-inline-end: ${le[t].headingPaddingRight}; } :host([centered][size="${o(t)}"]) .label { padding-inline: ${le[t].headingPaddingLeft}; } :host([size="${o(t)}"]) .base { padding-block-start: ${le[t].paddingTop??o("unset")}; padding-block-end: ${le[t].paddingBottom??o("unset")}; } ${le[t].titleMaxLines?C`:host([size="${o(t)}"]) .title { display: -webkit-box; -webkit-line-clamp: ${le[t].titleMaxLines}; -webkit-box-orient: vertical; overflow: hidden; line-clamp: ${le[t].titleMaxLines}; }`:C``} ${le[t].subtitleMaxLines?C`:host([size="${o(t)}"]) .subtitle { display: -webkit-box; -webkit-line-clamp: ${le[t].subtitleMaxLines}; -webkit-box-orient: vertical; overflow: hidden; line-clamp: ${le[t].subtitleMaxLines}; }`:C``}`}var af=[Pl("small"),Pl("medium"),Pl("large")],mo={containerColor:o(`var(--m3e-app-bar-container-color, ${a.color.surface})`),containerColorOnScroll:o(`var(--m3e-app-bar-container-color-on-scroll, ${a.color.surfaceContainer})`),containerElevation:o(`var(--m3e-app-bar-container-elevation, ${a.elevation.level0})`),containerElevationOnScroll:o(`var(--m3e-app-bar-container-elevation-on-scroll, ${a.elevation.level1})`),titleTextColor:o(`var(--m3e-app-bar-title-text-color, ${a.color.onSurface})`),subtitleTextColor:o(`var(--m3e-app-bar-subtitle-text-color, ${a.color.onSurfaceVariant})`),paddingLeft:o("var(--m3e-app-bar-padding-left, 0.25rem)"),paddingRight:o("var(--m3e-app-bar-padding-right, 0.25rem)")},rf=C`:host { display: block; flex: none; } :host([size="small"]) .base, :host(:not([size="small"]):not([centered])) .heading { padding-inline-start: ${mo.paddingLeft}; padding-inline-end: ${mo.paddingRight}; } .base { box-sizing: border-box; display: flex; transition: ${o(`background-color ${a.motion.duration.medium1} ${a.motion.easing.standard},
      box-shadow ${a.motion.duration.medium1} ${a.motion.easing.standard}`)}; } .base:not(.on-scroll) { background-color: ${mo.containerColor}; box-shadow: ${mo.containerElevation}; } .base.on-scroll { background-color: ${mo.containerColorOnScroll}; box-shadow: ${mo.containerElevationOnScroll}; } .leading-icon, .trailing-icon { display: flex; flex: none; align-items: center; } .leading-icon { min-width: var(--_leading-icon-min-width); } .trailing-icon { min-width: var(--_trailing-icon-min-width); } .heading { display: flex; align-items: center; } :host([size="small"]) .heading { flex: 1 1 auto; } .spacer { flex: 1 1 auto; } .label { display: flex; flex-direction: column; flex: none; } .title { color: ${mo.titleTextColor}; } .subtitle { color: ${mo.subtitleTextColor}; } .base:not(.with-title) .title, .base:not(.with-subtitle) .subtitle, .base:not(.with-title):not(.with-subtitle) .label, .base:not(.with-trailing-icon) .trailing-icon { display: none; } :host([size="small"]) .base { align-items: center; } :host([size="small"]) .heading { min-width: 0; } :host([size="small"]) .label { flex: 1 1 auto; min-width: 0; } :host([size="small"]) .title, :host([size="small"]) .subtitle { display: block; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; } :host(:not([size="small"])) .base { flex-direction: column; } :host([centered]) .title, :host([centered]) .subtitle { text-align: center; } @media (prefers-reduced-motion) { .base { transition: none; } } @media (forced-colors: active) { .base { transition: none; } .base:not(.on-scroll), .base.on-scroll { background-color: Canvas; box-shadow: unset; } .title { color: CanvasText; } .subtitle { color: FieldText; } }`,re,Fa,xi,Al,Il,zl,Fl,Wr,Rl,wi,Ol,Bl,Gt=class extends Xe(W(P,"banner")){constructor(){super(...arguments),re.add(this),Fa.set(this,e=>this._updateScroll(e)),xi.set(this,()=>n(this,re,"m",Ol).call(this)),this.centered=!1,this.size="small"}attach(e){super.attach(e),e instanceof HTMLIFrameElement?(e.addEventListener("load",n(this,xi,"f")),n(this,re,"m",Ol).call(this)):e.addEventListener("scroll",n(this,Fa,"f"),{passive:!0})}detach(){this.control instanceof HTMLIFrameElement&&(this.control.removeEventListener("load",n(this,xi,"f")),this.control.contentDocument?.removeEventListener("scroll",n(this,Fa,"f"))),this.control&&this.control.removeEventListener("scroll",n(this,Fa,"f")),super.detach()}updated(e){super.updated(e),(e.has("centered")||e.has("size"))&&(this.centered&&this.size==="small"?n(this,re,"m",wi).call(this):n(this,re,"m",Rl).call(this))}render(){switch(this.size){case"small":return w`<div class="base"><div class="leading-icon"><slot name="leading" @slotchange="${n(this,re,"m",zl)}"><slot name="leading-icon" @slotchange="${n(this,re,"m",Wr)}"></slot></slot></div><div class="heading"><div class="label"><div class="title"><slot name="title" @slotchange="${n(this,re,"m",Al)}"></slot></div><div class="subtitle"><slot name="subtitle" @slotchange="${n(this,re,"m",Il)}"></slot></div></div></div><div class="trailing-icon"><slot name="trailing" @slotchange="${n(this,re,"m",Fl)}"><slot name="trailing-icon" @slotchange="${n(this,re,"m",Wr)}"></slot></slot></div></div>`;default:return w`<div class="base"><div class="heading"><div class="leading-icon"><slot name="leading" @slotchange="${n(this,re,"m",zl)}"><slot name="leading-icon" @slotchange="${n(this,re,"m",Wr)}"></slot></slot></div><div class="spacer"></div><div class="trailing-icon"><slot name="trailing" @slotchange="${n(this,re,"m",Fl)}"><slot name="trailing-icon" @slotchange="${n(this,re,"m",Wr)}"></slot></slot></div></div><div class="spacer"></div><div class="label"><div class="title"><slot name="title" @slotchange="${n(this,re,"m",Al)}"></slot></div><div class="subtitle"><slot name="subtitle" @slotchange="${n(this,re,"m",Il)}"></slot></div></div></div>`}}_updateScroll(e){let r=0;this.control instanceof HTMLIFrameElement?r=n(this,re,"m",Bl).call(this,this.control):e.target instanceof HTMLElement&&(r=e.target.scrollTop),this._base?.classList.toggle("on-scroll",r>0)}};Fa=new WeakMap;xi=new WeakMap;re=new WeakSet;Al=function(e){this._base?.classList.toggle("with-title",he(e.target))};Il=function(e){this._base?.classList.toggle("with-subtitle",he(e.target))};zl=function(e){this._base?.classList.toggle("with-leading-icon",he(e.target)),this.centered&&this.size==="small"&&setTimeout(()=>n(this,re,"m",wi).call(this),40)};Fl=function(e){this._base?.classList.toggle("with-trailing-icon",he(e.target)),this.centered&&this.size==="small"&&setTimeout(()=>n(this,re,"m",wi).call(this),40)};Wr=function(e){let r=e.target.name,i=r.replace("-icon","");console.warn(`[m3e-app-bar] Slot "${r}" is deprecated and will be removed in a future release. Use "${i}" instead.`)};Rl=function(){this._base?.style.removeProperty("--_leading-icon-min-width"),this._base?.style.removeProperty("--_trailing-icon-min-width")};wi=function(){n(this,re,"m",Rl).call(this);let e=this._leadingIcon?.getBoundingClientRect().width??0,r=this._trailingIcon?.getBoundingClientRect().width??0;e<r?this._base?.style.setProperty("--_leading-icon-min-width",`${r}px`):e>r&&this._base?.style.setProperty("--_trailing-icon-min-width",`${e}px`)};Ol=function(){this.control instanceof HTMLIFrameElement&&(this.control.contentDocument?.addEventListener("scroll",n(this,Fa,"f"),{passive:!0}),this._base?.classList.toggle("on-scroll",n(this,re,"m",Bl).call(this,this.control)>0))};Bl=function(e){return Math.max(e.contentDocument?.documentElement?.scrollTop??0,e.contentDocument?.body?.scrollTop??0)};Gt.styles=[rf,af];h([M(".base")],Gt.prototype,"_base",void 0);h([M(".leading-icon")],Gt.prototype,"_leadingIcon",void 0);h([M(".trailing-icon")],Gt.prototype,"_trailingIcon",void 0);h([b({type:Boolean,reflect:!0})],Gt.prototype,"centered",void 0);h([b({reflect:!0})],Gt.prototype,"size",void 0);h([vt(40)],Gt.prototype,"_updateScroll",null);Gt=h([L("m3e-app-bar")],Gt);var _e,Wl,Nr,Dl,Hl,nf=/^(ar|ckb|dv|he|iw|fa|nqo|ps|sd|ug|ur|yi|.*[-_](Adlm|Arab|Hebr|Nkoo|Rohg|Thaa))(?!.*[-_](Latn|Cyrl)($|-|_))($|-|_)/i,G=class{static get current(){return n(this,_e,"f",Wl)}static observe(e){return n(this,_e,"f",Nr).push(e),()=>{n(this,_e,"f",Nr).splice(n(this,_e,"f",Nr).indexOf(e),1)}}};_e=G,Dl=function(){let e=(document.body?.dir||document.documentElement?.dir)?.toLowerCase()||"auto";f(this,_e,e==="auto"&&navigator?.language?nf.test(navigator.language)?"rtl":"ltr":e==="rtl"?"rtl":"ltr","f",Wl)},Hl=function(){n(this,_e,"m",Dl).call(this),n(this,_e,"f",Nr).forEach(e=>e())};Wl={value:"ltr"};Nr={value:Array()};(()=>{if(typeof window<"u"){if(n(_e,_e,"m",Dl).call(_e),MutationObserver){let t={attributeFilter:["dir"]},e=new MutationObserver(()=>n(_e,_e,"m",Hl).call(_e));document.body&&e.observe(document.body,t),document.documentElement&&e.observe(document.documentElement,t)}window.addEventListener("languagechange",()=>n(_e,_e,"m",Hl).call(_e))}})();globalThis.M3eDirectionality=G;var Jo=Math.min,Pt=Math.max,ki=Math.round,_i=Math.floor,At=t=>({x:t,y:t}),sf={left:"right",right:"left",bottom:"top",top:"bottom"};function wh(t,e,r){return Pt(t,Jo(e,r))}function Qo(t,e){return typeof t=="function"?t(e):t}function It(t){return t.split("-")[0]}function Mi(t){return t.split("-")[1]}function Yl(t){return t==="x"?"y":"x"}function Th(t){return t==="y"?"height":"width"}function Tt(t){let e=t[0];return e==="t"||e==="b"?"y":"x"}function Ph(t){return Yl(Tt(t))}function lf(t,e,r){r===void 0&&(r=!1);let i=Mi(t),s=Ph(t),l=Th(s),c=s==="x"?i===(r?"end":"start")?"right":"left":i==="start"?"bottom":"top";return e.reference[l]>e.floating[l]&&(c=Ei(c)),[c,Ei(c)]}function cf(t){let e=Ei(t);return[Ul(t),e,Ul(e)]}function Ul(t){return t.includes("start")?t.replace("start","end"):t.replace("end","start")}var _h=["left","right"],$h=["right","left"],df=["top","bottom"],hf=["bottom","top"];function uf(t,e,r){switch(t){case"top":case"bottom":return r?e?$h:_h:e?_h:$h;case"left":case"right":return e?df:hf;default:return[]}}function mf(t,e,r,i){let s=Mi(t),l=uf(It(t),r==="start",i);return s&&(l=l.map(c=>c+"-"+s),e&&(l=l.concat(l.map(Ul)))),l}function Ei(t){let e=It(t);return sf[e]+t.slice(e.length)}function pf(t){return{top:0,right:0,bottom:0,left:0,...t}}function Ah(t){return typeof t!="number"?pf(t):{top:t,right:t,bottom:t,left:t}}function Ra(t){let{x:e,y:r,width:i,height:s}=t;return{width:i,height:s,top:r,left:e,right:e+i,bottom:r+s,x:e,y:r}}function Ch(t,e,r){let{reference:i,floating:s}=t,l=Tt(e),c=Ph(e),d=Th(c),u=It(e),p=l==="y",g=i.x+i.width/2-s.width/2,m=i.y+i.height/2-s.height/2,y=i[d]/2-s[d]/2,v;switch(u){case"top":v={x:g,y:i.y-s.height};break;case"bottom":v={x:g,y:i.y+i.height};break;case"right":v={x:i.x+i.width,y:m};break;case"left":v={x:i.x-s.width,y:m};break;default:v={x:i.x,y:i.y}}switch(Mi(e)){case"start":v[c]-=y*(r&&p?-1:1);break;case"end":v[c]+=y*(r&&p?-1:1);break}return v}async function ff(t,e){var r;e===void 0&&(e={});let{x:i,y:s,platform:l,rects:c,elements:d,strategy:u}=t,{boundary:p="clippingAncestors",rootBoundary:g="viewport",elementContext:m="floating",altBoundary:y=!1,padding:v=0}=Qo(e,t),x=Ah(v),S=d[y?m==="floating"?"reference":"floating":m],$=Ra(await l.getClippingRect({element:(r=await(l.isElement==null?void 0:l.isElement(S)))==null||r?S:S.contextElement||await(l.getDocumentElement==null?void 0:l.getDocumentElement(d.floating)),boundary:p,rootBoundary:g,strategy:u})),T=m==="floating"?{x:i,y:s,width:c.floating.width,height:c.floating.height}:c.reference,z=await(l.getOffsetParent==null?void 0:l.getOffsetParent(d.floating)),O=await(l.isElement==null?void 0:l.isElement(z))?await(l.getScale==null?void 0:l.getScale(z))||{x:1,y:1}:{x:1,y:1},U=Ra(l.convertOffsetParentRelativeRectToViewportRelativeRect?await l.convertOffsetParentRelativeRectToViewportRelativeRect({elements:d,rect:T,offsetParent:z,strategy:u}):T);return{top:($.top-U.top+x.top)/O.y,bottom:(U.bottom-$.bottom+x.bottom)/O.y,left:($.left-U.left+x.left)/O.x,right:(U.right-$.right+x.right)/O.x}}var bf=50,vf=async(t,e,r)=>{let{placement:i="bottom",strategy:s="absolute",middleware:l=[],platform:c}=r,d=c.detectOverflow?c:{...c,detectOverflow:ff},u=await(c.isRTL==null?void 0:c.isRTL(e)),p=await c.getElementRects({reference:t,floating:e,strategy:s}),{x:g,y:m}=Ch(p,i,u),y=i,v=0,x={};for(let _=0;_<l.length;_++){let S=l[_];if(!S)continue;let{name:$,fn:T}=S,{x:z,y:O,data:U,reset:X}=await T({x:g,y:m,initialPlacement:i,placement:y,strategy:s,middlewareData:x,rects:p,platform:d,elements:{reference:t,floating:e}});g=z??g,m=O??m,x[$]={...x[$],...U},X&&v<bf&&(v++,typeof X=="object"&&(X.placement&&(y=X.placement),X.rects&&(p=X.rects===!0?await c.getElementRects({reference:t,floating:e,strategy:s}):X.rects),{x:g,y:m}=Ch(p,y,u)),_=-1)}return{x:g,y:m,placement:y,strategy:s,middlewareData:x}},gf=function(t){return t===void 0&&(t={}),{name:"flip",options:t,async fn(e){var r,i;let{placement:s,middlewareData:l,rects:c,initialPlacement:d,platform:u,elements:p}=e,{mainAxis:g=!0,crossAxis:m=!0,fallbackPlacements:y,fallbackStrategy:v="bestFit",fallbackAxisSideDirection:x="none",flipAlignment:_=!0,...S}=Qo(t,e);if((r=l.arrow)!=null&&r.alignmentOffset)return{};let $=It(s),T=Tt(d),z=It(d)===d,O=await(u.isRTL==null?void 0:u.isRTL(p.floating)),U=y||(z||!_?[Ei(d)]:cf(d)),X=x!=="none";!y&&X&&U.push(...mf(d,_,x,O));let ye=[d,...U],ot=await u.detectOverflow(e,S),Ve=[],te=((i=l.flip)==null?void 0:i.overflows)||[];if(g&&Ve.push(ot[$]),m){let j=lf(s,c,O);Ve.push(ot[j[0]],ot[j[1]])}if(te=[...te,{placement:s,overflows:Ve}],!Ve.every(j=>j<=0)){var Oe,Le;let j=(((Oe=l.flip)==null?void 0:Oe.index)||0)+1,oe=ye[j];if(oe&&(!(m==="alignment"?T!==Tt(oe):!1)||te.every(Te=>Tt(Te.placement)===T?Te.overflows[0]>0:!0)))return{data:{index:j,overflows:te},reset:{placement:oe}};let kt=(Le=te.filter(Et=>Et.overflows[0]<=0).sort((Et,Te)=>Et.overflows[1]-Te.overflows[1])[0])==null?void 0:Le.placement;if(!kt)switch(v){case"bestFit":{var ht;let Et=(ht=te.filter(Te=>{if(X){let ut=Tt(Te.placement);return ut===T||ut==="y"}return!0}).map(Te=>[Te.placement,Te.overflows.filter(ut=>ut>0).reduce((ut,Ws)=>ut+Ws,0)]).sort((Te,ut)=>Te[1]-ut[1])[0])==null?void 0:ht[0];Et&&(kt=Et);break}case"initialPlacement":kt=d;break}if(s!==kt)return{reset:{placement:kt}}}return{}}}};function Ih(t){let e=Jo(...t.map(l=>l.left)),r=Jo(...t.map(l=>l.top)),i=Pt(...t.map(l=>l.right)),s=Pt(...t.map(l=>l.bottom));return{x:e,y:r,width:i-e,height:s-r}}function yf(t){let e=t.slice().sort((s,l)=>s.y-l.y),r=[],i=null;for(let s=0;s<e.length;s++){let l=e[s];!i||l.y-i.y>i.height/2?r.push([l]):r[r.length-1].push(l),i=l}return r.map(s=>Ra(Ih(s)))}var xf=function(t){return t===void 0&&(t={}),{name:"inline",options:t,async fn(e){let{placement:r,elements:i,rects:s,platform:l,strategy:c}=e,{padding:d=2,x:u,y:p}=Qo(t,e),g=Array.from(await(l.getClientRects==null?void 0:l.getClientRects(i.reference))||[]),m=yf(g),y=Ra(Ih(g)),v=Ah(d);function x(){if(m.length===2&&m[0].left>m[1].right&&u!=null&&p!=null)return m.find(S=>u>S.left-v.left&&u<S.right+v.right&&p>S.top-v.top&&p<S.bottom+v.bottom)||y;if(m.length>=2){if(Tt(r)==="y"){let te=m[0],Oe=m[m.length-1],Le=It(r)==="top",ht=te.top,j=Oe.bottom,oe=Le?te.left:Oe.left,kt=Le?te.right:Oe.right,Et=kt-oe,Te=j-ht;return{top:ht,bottom:j,left:oe,right:kt,width:Et,height:Te,x:oe,y:ht}}let S=It(r)==="left",$=Pt(...m.map(te=>te.right)),T=Jo(...m.map(te=>te.left)),z=m.filter(te=>S?te.left===T:te.right===$),O=z[0].top,U=z[z.length-1].bottom,X=T,ye=$,ot=ye-X,Ve=U-O;return{top:O,bottom:U,left:X,right:ye,width:ot,height:Ve,x:X,y:O}}return y}let _=await l.getElementRects({reference:{getBoundingClientRect:x},floating:i.floating,strategy:c});return s.reference.x!==_.reference.x||s.reference.y!==_.reference.y||s.reference.width!==_.reference.width||s.reference.height!==_.reference.height?{reset:{rects:_}}:{}}}},zh=new Set(["left","top"]);async function wf(t,e){let{placement:r,platform:i,elements:s}=t,l=await(i.isRTL==null?void 0:i.isRTL(s.floating)),c=It(r),d=Mi(r),u=Tt(r)==="y",p=zh.has(c)?-1:1,g=l&&u?-1:1,m=Qo(e,t),{mainAxis:y,crossAxis:v,alignmentAxis:x}=typeof m=="number"?{mainAxis:m,crossAxis:0,alignmentAxis:null}:{mainAxis:m.mainAxis||0,crossAxis:m.crossAxis||0,alignmentAxis:m.alignmentAxis};return d&&typeof x=="number"&&(v=d==="end"?x*-1:x),u?{x:v*g,y:y*p}:{x:y*p,y:v*g}}var _f=function(t){return t===void 0&&(t=0),{name:"offset",options:t,async fn(e){var r,i;let{x:s,y:l,placement:c,middlewareData:d}=e,u=await wf(e,t);return c===((r=d.offset)==null?void 0:r.placement)&&(i=d.arrow)!=null&&i.alignmentOffset?{}:{x:s+u.x,y:l+u.y,data:{...u,placement:c}}}}},$f=function(t){return t===void 0&&(t={}),{name:"shift",options:t,async fn(e){let{x:r,y:i,placement:s,platform:l}=e,{mainAxis:c=!0,crossAxis:d=!1,limiter:u={fn:$=>{let{x:T,y:z}=$;return{x:T,y:z}}},...p}=Qo(t,e),g={x:r,y:i},m=await l.detectOverflow(e,p),y=Tt(It(s)),v=Yl(y),x=g[v],_=g[y];if(c){let $=v==="y"?"top":"left",T=v==="y"?"bottom":"right",z=x+m[$],O=x-m[T];x=wh(z,x,O)}if(d){let $=y==="y"?"top":"left",T=y==="y"?"bottom":"right",z=_+m[$],O=_-m[T];_=wh(z,_,O)}let S=u.fn({...e,[v]:x,[y]:_});return{...S,data:{x:S.x-r,y:S.y-i,enabled:{[v]:c,[y]:d}}}}}},Cf=function(t){return t===void 0&&(t={}),{options:t,fn(e){let{x:r,y:i,placement:s,rects:l,middlewareData:c}=e,{offset:d=0,mainAxis:u=!0,crossAxis:p=!0}=Qo(t,e),g={x:r,y:i},m=Tt(s),y=Yl(m),v=g[y],x=g[m],_=Qo(d,e),S=typeof _=="number"?{mainAxis:_,crossAxis:0}:{mainAxis:0,crossAxis:0,..._};if(u){let z=y==="y"?"height":"width",O=l.reference[y]-l.floating[z]+S.mainAxis,U=l.reference[y]+l.reference[z]-S.mainAxis;v<O?v=O:v>U&&(v=U)}if(p){var $,T;let z=y==="y"?"width":"height",O=zh.has(It(s)),U=l.reference[m]-l.floating[z]+(O&&(($=c.offset)==null?void 0:$[m])||0)+(O?0:S.crossAxis),X=l.reference[m]+l.reference[z]+(O?0:((T=c.offset)==null?void 0:T[m])||0)-(O?S.crossAxis:0);x<U?x=U:x>X&&(x=X)}return{[y]:v,[m]:x}}}};function Li(){return typeof window<"u"}function Ha(t){return Fh(t)?(t.nodeName||"").toLowerCase():"#document"}function Qe(t){var e;return(t==null||(e=t.ownerDocument)==null?void 0:e.defaultView)||window}function zt(t){var e;return(e=(Fh(t)?t.ownerDocument:t.document)||window.document)==null?void 0:e.documentElement}function Fh(t){return Li()?t instanceof Node||t instanceof Qe(t).Node:!1}function _t(t){return Li()?t instanceof Element||t instanceof Qe(t).Element:!1}function Yt(t){return Li()?t instanceof HTMLElement||t instanceof Qe(t).HTMLElement:!1}function Sh(t){return!Li()||typeof ShadowRoot>"u"?!1:t instanceof ShadowRoot||t instanceof Qe(t).ShadowRoot}function jr(t){let{overflow:e,overflowX:r,overflowY:i,display:s}=$t(t);return/auto|scroll|overlay|hidden|clip/.test(e+i+r)&&s!=="inline"&&s!=="contents"}function Sf(t){return/^(table|td|th)$/.test(Ha(t))}function Ti(t){try{if(t.matches(":popover-open"))return!0}catch{}try{return t.matches(":modal")}catch{return!1}}var kf=/transform|translate|scale|rotate|perspective|filter/,Ef=/paint|layout|strict|content/,Xo=t=>!!t&&t!=="none",Nl;function Pi(t){let e=_t(t)?$t(t):t;return Xo(e.transform)||Xo(e.translate)||Xo(e.scale)||Xo(e.rotate)||Xo(e.perspective)||!Xl()&&(Xo(e.backdropFilter)||Xo(e.filter))||kf.test(e.willChange||"")||Ef.test(e.contain||"")}function Mf(t){let e=po(t);for(;Yt(e)&&!Ba(e);){if(Pi(e))return e;if(Ti(e))return null;e=po(e)}return null}function Xl(){return Nl==null&&(Nl=typeof CSS<"u"&&CSS.supports&&CSS.supports("-webkit-backdrop-filter","none")),Nl}function Ba(t){return/^(html|body|#document)$/.test(Ha(t))}function $t(t){return Qe(t).getComputedStyle(t)}function Ai(t){return _t(t)?{scrollLeft:t.scrollLeft,scrollTop:t.scrollTop}:{scrollLeft:t.scrollX,scrollTop:t.scrollY}}function po(t){if(Ha(t)==="html")return t;let e=t.assignedSlot||t.parentNode||Sh(t)&&t.host||zt(t);return Sh(e)?e.host:e}function Oh(t){let e=po(t);return Ba(e)?t.ownerDocument?t.ownerDocument.body:t.body:Yt(e)&&jr(e)?e:Oh(e)}function Ur(t,e,r){var i;e===void 0&&(e=[]),r===void 0&&(r=!0);let s=Oh(t),l=s===((i=t.ownerDocument)==null?void 0:i.body),c=Qe(s);if(l){let d=jl(c);return e.concat(c,c.visualViewport||[],jr(s)?s:[],d&&r?Ur(d):[])}else return e.concat(s,Ur(s,[],r))}function jl(t){return t.parent&&Object.getPrototypeOf(t.parent)?t.frameElement:null}function Rh(t){let e=$t(t),r=parseFloat(e.width)||0,i=parseFloat(e.height)||0,s=Yt(t),l=s?t.offsetWidth:r,c=s?t.offsetHeight:i,d=ki(r)!==l||ki(i)!==c;return d&&(r=l,i=c),{width:r,height:i,$:d}}function Zl(t){return _t(t)?t:t.contextElement}function Oa(t){let e=Zl(t);if(!Yt(e))return At(1);let r=e.getBoundingClientRect(),{width:i,height:s,$:l}=Rh(e),c=(l?ki(r.width):r.width)/i,d=(l?ki(r.height):r.height)/s;return(!c||!Number.isFinite(c))&&(c=1),(!d||!Number.isFinite(d))&&(d=1),{x:c,y:d}}var Lf=At(0);function Bh(t){let e=Qe(t);return!Xl()||!e.visualViewport?Lf:{x:e.visualViewport.offsetLeft,y:e.visualViewport.offsetTop}}function Tf(t,e,r){return e===void 0&&(e=!1),!r||e&&r!==Qe(t)?!1:e}function Ko(t,e,r,i){e===void 0&&(e=!1),r===void 0&&(r=!1);let s=t.getBoundingClientRect(),l=Zl(t),c=At(1);e&&(i?_t(i)&&(c=Oa(i)):c=Oa(t));let d=Tf(l,r,i)?Bh(l):At(0),u=(s.left+d.x)/c.x,p=(s.top+d.y)/c.y,g=s.width/c.x,m=s.height/c.y;if(l){let y=Qe(l),v=i&&_t(i)?Qe(i):i,x=y,_=jl(x);for(;_&&i&&v!==x;){let S=Oa(_),$=_.getBoundingClientRect(),T=$t(_),z=$.left+(_.clientLeft+parseFloat(T.paddingLeft))*S.x,O=$.top+(_.clientTop+parseFloat(T.paddingTop))*S.y;u*=S.x,p*=S.y,g*=S.x,m*=S.y,u+=z,p+=O,x=Qe(_),_=jl(x)}}return Ra({width:g,height:m,x:u,y:p})}function Ii(t,e){let r=Ai(t).scrollLeft;return e?e.left+r:Ko(zt(t)).left+r}function Dh(t,e){let r=t.getBoundingClientRect(),i=r.left+e.scrollLeft-Ii(t,r),s=r.top+e.scrollTop;return{x:i,y:s}}function Pf(t){let{elements:e,rect:r,offsetParent:i,strategy:s}=t,l=s==="fixed",c=zt(i),d=e?Ti(e.floating):!1;if(i===c||d&&l)return r;let u={scrollLeft:0,scrollTop:0},p=At(1),g=At(0),m=Yt(i);if((m||!m&&!l)&&((Ha(i)!=="body"||jr(c))&&(u=Ai(i)),m)){let v=Ko(i);p=Oa(i),g.x=v.x+i.clientLeft,g.y=v.y+i.clientTop}let y=c&&!m&&!l?Dh(c,u):At(0);return{width:r.width*p.x,height:r.height*p.y,x:r.x*p.x-u.scrollLeft*p.x+g.x+y.x,y:r.y*p.y-u.scrollTop*p.y+g.y+y.y}}function Af(t){return Array.from(t.getClientRects())}function If(t){let e=zt(t),r=Ai(t),i=t.ownerDocument.body,s=Pt(e.scrollWidth,e.clientWidth,i.scrollWidth,i.clientWidth),l=Pt(e.scrollHeight,e.clientHeight,i.scrollHeight,i.clientHeight),c=-r.scrollLeft+Ii(t),d=-r.scrollTop;return $t(i).direction==="rtl"&&(c+=Pt(e.clientWidth,i.clientWidth)-s),{width:s,height:l,x:c,y:d}}var kh=25;function zf(t,e){let r=Qe(t),i=zt(t),s=r.visualViewport,l=i.clientWidth,c=i.clientHeight,d=0,u=0;if(s){l=s.width,c=s.height;let g=Xl();(!g||g&&e==="fixed")&&(d=s.offsetLeft,u=s.offsetTop)}let p=Ii(i);if(p<=0){let g=i.ownerDocument,m=g.body,y=getComputedStyle(m),v=g.compatMode==="CSS1Compat"&&parseFloat(y.marginLeft)+parseFloat(y.marginRight)||0,x=Math.abs(i.clientWidth-m.clientWidth-v);x<=kh&&(l-=x)}else p<=kh&&(l+=p);return{width:l,height:c,x:d,y:u}}function Ff(t,e){let r=Ko(t,!0,e==="fixed"),i=r.top+t.clientTop,s=r.left+t.clientLeft,l=Yt(t)?Oa(t):At(1),c=t.clientWidth*l.x,d=t.clientHeight*l.y,u=s*l.x,p=i*l.y;return{width:c,height:d,x:u,y:p}}function Eh(t,e,r){let i;if(e==="viewport")i=zf(t,r);else if(e==="document")i=If(zt(t));else if(_t(e))i=Ff(e,r);else{let s=Bh(t);i={x:e.x-s.x,y:e.y-s.y,width:e.width,height:e.height}}return Ra(i)}function Hh(t,e){let r=po(t);return r===e||!_t(r)||Ba(r)?!1:$t(r).position==="fixed"||Hh(r,e)}function Of(t,e){let r=e.get(t);if(r)return r;let i=Ur(t,[],!1).filter(d=>_t(d)&&Ha(d)!=="body"),s=null,l=$t(t).position==="fixed",c=l?po(t):t;for(;_t(c)&&!Ba(c);){let d=$t(c),u=Pi(c);!u&&d.position==="fixed"&&(s=null),(l?!u&&!s:!u&&d.position==="static"&&!!s&&(s.position==="absolute"||s.position==="fixed")||jr(c)&&!u&&Hh(t,c))?i=i.filter(g=>g!==c):s=d,c=po(c)}return e.set(t,i),i}function Rf(t){let{element:e,boundary:r,rootBoundary:i,strategy:s}=t,c=[...r==="clippingAncestors"?Ti(e)?[]:Of(e,this._c):[].concat(r),i],d=Eh(e,c[0],s),u=d.top,p=d.right,g=d.bottom,m=d.left;for(let y=1;y<c.length;y++){let v=Eh(e,c[y],s);u=Pt(v.top,u),p=Jo(v.right,p),g=Jo(v.bottom,g),m=Pt(v.left,m)}return{width:p-m,height:g-u,x:m,y:u}}function Bf(t){let{width:e,height:r}=Rh(t);return{width:e,height:r}}function Df(t,e,r){let i=Yt(e),s=zt(e),l=r==="fixed",c=Ko(t,!0,l,e),d={scrollLeft:0,scrollTop:0},u=At(0);function p(){u.x=Ii(s)}if(i||!i&&!l)if((Ha(e)!=="body"||jr(s))&&(d=Ai(e)),i){let v=Ko(e,!0,l,e);u.x=v.x+e.clientLeft,u.y=v.y+e.clientTop}else s&&p();l&&!i&&s&&p();let g=s&&!i&&!l?Dh(s,d):At(0),m=c.left+d.scrollLeft-u.x-g.x,y=c.top+d.scrollTop-u.y-g.y;return{x:m,y,width:c.width,height:c.height}}function ql(t){return $t(t).position==="static"}function Mh(t,e){if(!Yt(t)||$t(t).position==="fixed")return null;if(e)return e(t);let r=t.offsetParent;return zt(t)===r&&(r=r.ownerDocument.body),r}function Wh(t,e){let r=Qe(t);if(Ti(t))return r;if(!Yt(t)){let s=po(t);for(;s&&!Ba(s);){if(_t(s)&&!ql(s))return s;s=po(s)}return r}let i=Mh(t,e);for(;i&&Sf(i)&&ql(i);)i=Mh(i,e);return i&&Ba(i)&&ql(i)&&!Pi(i)?r:i||Mf(t)||r}var Hf=async function(t){let e=this.getOffsetParent||Wh,r=this.getDimensions,i=await r(t.floating);return{reference:Df(t.reference,await e(t.floating),t.strategy),floating:{x:0,y:0,width:i.width,height:i.height}}};function Wf(t){return $t(t).direction==="rtl"}var Gl={convertOffsetParentRelativeRectToViewportRelativeRect:Pf,getDocumentElement:zt,getClippingRect:Rf,getOffsetParent:Wh,getElementRects:Hf,getClientRects:Af,getDimensions:Bf,getScale:Oa,isElement:_t,isRTL:Wf};function Nh(t,e){return t.x===e.x&&t.y===e.y&&t.width===e.width&&t.height===e.height}function Nf(t,e){let r=null,i,s=zt(t);function l(){var d;clearTimeout(i),(d=r)==null||d.disconnect(),r=null}function c(d,u){d===void 0&&(d=!1),u===void 0&&(u=1),l();let p=t.getBoundingClientRect(),{left:g,top:m,width:y,height:v}=p;if(d||e(),!y||!v)return;let x=_i(m),_=_i(s.clientWidth-(g+y)),S=_i(s.clientHeight-(m+v)),$=_i(g),z={rootMargin:-x+"px "+-_+"px "+-S+"px "+-$+"px",threshold:Pt(0,Jo(1,u))||1},O=!0;function U(X){let ye=X[0].intersectionRatio;if(ye!==u){if(!O)return c();ye?c(!1,ye):i=setTimeout(()=>{c(!1,1e-7)},1e3)}ye===1&&!Nh(p,t.getBoundingClientRect())&&c(),O=!1}try{r=new IntersectionObserver(U,{...z,root:s.ownerDocument})}catch{r=new IntersectionObserver(U,z)}r.observe(t)}return c(!0),l}function qf(t,e,r,i){i===void 0&&(i={});let{ancestorScroll:s=!0,ancestorResize:l=!0,elementResize:c=typeof ResizeObserver=="function",layoutShift:d=typeof IntersectionObserver=="function",animationFrame:u=!1}=i,p=Zl(t),g=s||l?[...p?Ur(p):[],...e?Ur(e):[]]:[];g.forEach($=>{s&&$.addEventListener("scroll",r,{passive:!0}),l&&$.addEventListener("resize",r)});let m=p&&d?Nf(p,r):null,y=-1,v=null;c&&(v=new ResizeObserver($=>{let[T]=$;T&&T.target===p&&v&&e&&(v.unobserve(e),cancelAnimationFrame(y),y=requestAnimationFrame(()=>{var z;(z=v)==null||z.observe(e)})),r()}),p&&!u&&v.observe(p),e&&v.observe(e));let x,_=u?Ko(t):null;u&&S();function S(){let $=Ko(t);_&&!Nh(_,$)&&r(),_=$,x=requestAnimationFrame(S)}return r(),()=>{var $;g.forEach(T=>{s&&T.removeEventListener("scroll",r),l&&T.removeEventListener("resize",r)}),m?.(),($=v)==null||$.disconnect(),v=null,u&&cancelAnimationFrame(x)}}var Vf=_f,Uf=$f,Lh=gf,jf=xf,Gf=Cf,Yf=(t,e,r)=>{let i=new Map,s={platform:Gl,...r},l={...s.platform,_c:i};return vf(t,e,{...s,platform:l})};function Xf(t){return Zf(t)}function Vl(t){return t.assignedSlot?t.assignedSlot:t.parentNode instanceof ShadowRoot?t.parentNode.host:t.parentNode}function Zf(t){for(let e=t;e;e=Vl(e))if(e instanceof Element&&getComputedStyle(e).display==="none")return null;for(let e=Vl(t);e;e=Vl(e)){if(!(e instanceof Element))continue;let r=getComputedStyle(e);if(r.display!=="contents"&&(r.position!=="static"||Pi(r)||e.tagName==="BODY"))return e}return null}async function Jl(t,e,r,i){let s={x:Number.MIN_SAFE_INTEGER,y:Number.MIN_SAFE_INTEGER,placement:"bottom"};async function l(){let c=new Array;r?.inline&&c.push(jf()),r.flip&&c.push(r.flip===!0?Lh():Lh({fallbackPlacements:r.flip})),r.shift&&c.push(Uf({mainAxis:r.shift==="main"||r.shift==="both",crossAxis:r.shift==="cross"||r.shift==="both",limiter:Gf()})),r.offset&&!isNaN(r.offset)&&c.push(Vf(r.offset));let d=await Yf(e,t,{placement:r.position,middleware:c,platform:{...Gl,getOffsetParent:m=>Gl.getOffsetParent(m,Xf)}}),{x:u,y:p,placement:g}=d;(s.x!==u||s.y!==p||s.placement!==g)&&i(u,p,g),Object.assign(s,{x:u,y:p,placement:g})}return await l(),qf(e,t,async()=>await l())}var Je,Ae,qr,Zo,Vr,$i,Ci,Si,Da=class extends yi(Q(P)){constructor(){super(...arguments),Je.set(this,void 0),Ae.set(this,void 0),qr.set(this,void 0),Zo.set(this,void 0),Vr.set(this,new Ar(this,{target:null,callback:()=>this.hide()})),$i.set(this,e=>{switch(e.newState){case"open":n(this,Vr,"f").observe(this),n(this,Ae,"f")&&n(this,Vr,"f").observe(n(this,Ae,"f"));break;case"closed":n(this,Vr,"f").unobserveAll(),n(this,qr,"f")?.call(this),f(this,qr,void 0,"f"),f(this,Zo,void 0,"f");break}}),Ci.set(this,new za(this,{target:null,callback:()=>this.hide(!1)})),Si.set(this,new we(this,{target:null,callback:()=>{n(this,Ae,"f")&&this.fitAnchorWidth&&(this.style.minWidth=`${n(this,Ae,"f").clientWidth}px`)}})),this.scrollStrategy="hide",this.fitAnchorWidth=!1,this.anchorOffset=0}get isOpen(){return n(this,Je,"f")!==void 0}get trigger(){return n(this,Je,"f")??null}connectedCallback(){super.connectedCallback(),this.setAttribute("popover","manual"),this.addEventListener("toggle",n(this,$i,"f"))}disconnectedCallback(){super.disconnectedCallback(),this.removeEventListener("toggle",n(this,$i,"f"))}async show(e,r){n(this,Je,"f")&&n(this,Je,"f")!==e&&this.hide(),f(this,Je,e,"f"),n(this,Je,"f").ariaExpanded="true",f(this,Ae,r??e,"f"),this.scrollStrategy==="hide"&&n(this,Ci,"f").observe(n(this,Ae,"f")),this.fitAnchorWidth&&(n(this,Si,"f").observe(n(this,Ae,"f")),this.style.minWidth=`${n(this,Ae,"f").clientWidth}px`),f(this,qr,await Jl(this,n(this,Ae,"f"),{position:"bottom-start",inline:!0,flip:!0,offset:this.anchorOffset>0?this.anchorOffset:void 0},(i,s,l)=>{R(this,"--top",l.includes("top")),R(this,"--bottom",l.includes("bottom")),(n(this,Zo,"f")?.dir!==G.current||n(this,Zo,"f")?.x!==i)&&(G.current==="rtl"?(this.style.right=`${window.innerWidth-i-this.clientWidth}px`,this.style.left=""):(this.style.left=`${i}px`,this.style.right="")),n(this,Zo,"f")?.y!==s&&(this.style.top=`${s}px`),f(this,Zo,{x:i,y:s,dir:G.current},"f")}),"f"),this.showPopover()}hide(e=!1){this.hidePopover(),n(this,Je,"f")&&(n(this,Je,"f").ariaExpanded="false",e&&n(this,Je,"f").focus(),n(this,Ae,"f")&&(n(this,Ci,"f").unobserve(n(this,Ae,"f")),this.fitAnchorWidth&&n(this,Si,"f").unobserve(n(this,Ae,"f"))),f(this,Je,void 0,"f"),f(this,Ae,void 0,"f"))}async toggle(e,r){n(this,Je,"f")?this.hide():await this.show(e,r)}render(){return w`<div class="base"><slot></slot></div>`}};Je=new WeakMap;Ae=new WeakMap;qr=new WeakMap;Zo=new WeakMap;Vr=new WeakMap;$i=new WeakMap;Ci=new WeakMap;Si=new WeakMap;Da.styles=C`:host { position: absolute; flex-direction: column; padding: unset; margin: unset; border: unset; overflow-y: auto; scrollbar-width: ${a.scrollbar.thinWidth}; scrollbar-color: ${a.scrollbar.color}; scroll-padding-block: calc( var(--m3e-focus-ring-thickness, 3px) + var(--m3e-floating-panel-container-padding-block, 0.25rem) ); border-radius: var(--m3e-floating-panel-container-shape, ${a.shape.corner.large}); min-width: var(--m3e-floating-panel-container-min-width, 7rem); max-width: var(--m3e-floating-panel-container-max-width, 17.5rem); max-height: var(--m3e-floating-panel-container-max-height, 17.5rem); background-color: var(--m3e-floating-panel-container-color, ${a.color.surfaceContainer}); box-shadow: var(--m3e-floating-panel-container-elevation, ${a.elevation.level3}); opacity: 0; display: none; } .base { contain: layout style paint; box-sizing: border-box; display: flex; flex-direction: column; padding-block: var(--m3e-floating-panel-container-padding-block, 0.25rem); padding-inline: var(--m3e-floating-panel-container-padding-inline, 0.25rem); } :host(:not(:is(:state(--no-animate), :--no-animate))) { transition: ${o(`opacity ${a.motion.duration.short2} ${a.motion.easing.standard}, 
            transform ${a.motion.duration.short2} ${a.motion.easing.standard},
            overlay ${a.motion.duration.short2} ${a.motion.easing.standard} allow-discrete,
            display ${a.motion.duration.short2} ${a.motion.easing.standard} allow-discrete`)}; } :host { transform: scaleY(0.8); } :host(:popover-open) { transform: scaleY(1); display: block; opacity: 1; } :host::backdrop { background-color: transparent; } :host(:is(:state(--bottom), :--bottom)) { transform-origin: top; } :host(:is(:state(--top), :--top)) { transform-origin: bottom; } @starting-style { :host(:popover-open) { transform: scaleY(0.8); } } @media (prefers-reduced-motion) { :host(:not(:is(:state(--no-animate), :--no-animate))) { transition: none; } } @media (forced-colors: active) { :host { background-color: Menu; color: MenuText; outline: 1px solid MenuText; } }`;h([b({attribute:"scroll-strategy"})],Da.prototype,"scrollStrategy",void 0);h([b({attribute:"fit-anchor-width",type:Boolean})],Da.prototype,"fitAnchorWidth",void 0);h([b({attribute:"anchor-offset",type:Number})],Da.prototype,"anchorOffset",void 0);Da=h([L("m3e-floating-panel")],Da);var Xt,zi,Gr,Wa,Ql,Kl,Fi,Yr=class extends Xe(P){constructor(){super(),Xt.add(this),zi.set(this,void 0),Gr.set(this,void 0),Wa.set(this,void 0),this.size="medium",this.position="above-after",new Ut(this,{skipInitial:!0,config:{childList:!0,subtree:!0,characterData:!0,attributes:!1},callback:()=>n(this,Xt,"m",Ql).call(this)})}attach(e){super.attach(e),n(this,Xt,"m",Fi).call(this)}detach(){super.detach(),n(this,Xt,"m",Kl).call(this)}connectedCallback(){super.connectedCallback(),f(this,zi,G.observe(()=>n(this,Xt,"m",Fi).call(this)),"f")}disconnectedCallback(){super.disconnectedCallback(),n(this,zi,"f")?.call(this)}update(e){super.update(e),(e.has("position")||e.has("size")||e.has("htmlFor"))&&n(this,Xt,"m",Fi).call(this)}render(){return w`<div class="base"><slot @slotchange="${n(this,Xt,"m",Ql)}"><span aria-hidden="true">&nbsp;</span></slot></div>`}};zi=new WeakMap;Gr=new WeakMap;Wa=new WeakMap;Xt=new WeakSet;Ql=function(){this.isConnected&&this.style.setProperty("--_badge-padding",this.textContent&&this.textContent.length>2?`0 ${this.size==="medium"?"0.25rem":this.size==="large"?"0.5rem":"0"}`:"")};Kl=function(){n(this,Gr,"f")?.call(this),f(this,Gr,void 0,"f"),f(this,Wa,void 0,"f")};Fi=async function(){if(n(this,Xt,"m",Kl).call(this),!this.control)return;let e="top-end";switch(this.position){case"above":e="top";break;case"above-before":e="top-start";break;case"after":e="right";break;case"before":e="left";break;case"below":e="bottom";break;case"below-after":e="bottom-end";break;case"below-before":e="bottom-start";break}f(this,Gr,await Jl(this,this.control,{position:e},(r,i)=>{this.position.includes("before")&&this.position!=="before"&&(G.current==="rtl"?r+=this.clientWidth:r-=this.clientWidth),this.position.includes("after")&&this.position!=="after"&&(G.current==="rtl"?r-=this.clientWidth:r+=this.clientWidth),n(this,Wa,"f")?.x!==r&&(this.style.left=`${r}px`),n(this,Wa,"f")?.y!==i&&(this.style.top=`${i}px`),f(this,Wa,{x:r,y:i},"f")}),"f")};Yr.styles=C`:host { display: inline-block; vertical-align: baseline; } .base { contain: layout style paint; width: 100%; height: 100%; display: flex; align-items: center; justify-content: center; text-align: center; white-space: nowrap; vertical-align: baseline; box-sizing: border-box; user-select: none; padding: var(--_badge-padding); border-radius: var(--m3e-badge-shape, ${a.shape.corner.full}); color: var(--m3e-badge-color, ${a.color.onError}); background-color: var(--m3e-badge-container-color, ${a.color.error}); } :host([for]) { position: absolute; z-index: 1; } :host([for][position="above"]) { transform: translateY(var(--_badge-offset, 0px)); } :host([for][position="above-after"]:not(:dir(rtl))) { transform: translate3d(calc(0px - var(--_badge-offset, 0px)), var(--_badge-offset, 0px), 0); } :host([for][position="above-after"]:dir(rtl)) { transform: translate3d(var(--_badge-offset, 0px), var(--_badge-offset, 0px), 0); } :host([for][position="above-before"]:not(:dir(rtl))) { transform: translate3d(var(--_badge-offset, 0px), var(--_badge-offset, 0px), 0); } :host([for][position="above-before"]:dir(rtl)) { transform: translate3d(calc(0px - var(--_badge-offset, 0px)), var(--_badge-offset, 0px), 0); } :host([for][position="below"]) { transform: translateY(calc(0px - var(--_badge-offset, 0px))); } :host([for][position="below-after"]:not(:dir(rtl))) { transform: translate3d(calc(0px - var(--_badge-offset, 0px)), calc(0px - var(--_badge-offset, 0px)), 0); } :host([for][position="below-after"]:dir(rtl)) { transform: translate3d(var(--_badge-offset, 0px), calc(0px - var(--_badge-offset, 0px)), 0); } :host([for][position="below-before"]:not(:dir(rtl))) { transform: translate3d(var(--_badge-offset, 0px), calc(0px - var(--_badge-offset, 0px)), 0); } :host([for][position="below-before"]:dir(rtl)) { transform: translate3d(calc(0px - var(--_badge-offset, 0px)), calc(0px - var(--_badge-offset, 0px)), 0); } :host([for][position="before"]:not(:dir(rtl))), :host([for][position="after"]:dir(rtl)) { transform: translateX(var(--_badge-offset, 0px)); } :host([for][position="before"]:dir(rtl)), :host([for][position="after"]:not(:dir(rtl))) { transform: translateX(calc(0px - var(--_badge-offset, 0px))); } :host([size="small"]) { height: var(--m3e-badge-small-size, 0.375rem); max-height: var(--m3e-badge-small-size, 0.375rem); width: var(--m3e-badge-small-size, 0.375rem); min-width: var(--m3e-badge-small-size, 0.375rem); --_badge-offset: var(--m3e-badge-small-offset, 0.375rem); } :host([size="small"]) .base { font-size: 0; } :host([size="medium"]) { height: var(--m3e-badge-medium-size, 1.375rem); min-width: var(--m3e-badge-medium-size, 1.375rem); --_badge-offset: var(--m3e-badge-small-offset, 0.75rem); } :host([size="medium"]) .base { font-size: var(--m3e-badge-medium-font-size, ${a.typescale.standard.label.small.fontSize}); font-weight: var(--m3e-badge-medium-font-weight, ${a.typescale.standard.label.small.fontWeight}); line-height: var(--m3e-badge-medium-line-height, ${a.typescale.standard.label.small.lineHeight}); letter-spacing: var(--m3e-badge-medium-tracking, ${a.typescale.standard.label.small.tracking}); } :host([size="large"]) { height: var(--m3e-badge-large-size, 1.75rem); min-width: var(--m3e-badge-large-size, 1.75rem); --_badge-offset: var(--m3e-badge-small-offset, 1rem); } :host([size="large"]) .base { font-size: var(--m3e-badge-large-font-size, ${a.typescale.standard.label.large.fontSize}); font-weight: var(--m3e-badge-large-font-weight, ${a.typescale.standard.label.large.fontWeight}); line-height: var(--m3e-badge-large-line-height, ${a.typescale.standard.label.large.lineHeight}); letter-spacing: var(--m3e-badge-large-tracking, ${a.typescale.standard.label.large.tracking}); } @media (forced-colors: active) { .base { background-color: ButtonFace; color: ButtonText; outline: 1px solid ButtonText; } }`;h([b({reflect:!0})],Yr.prototype,"size",void 0);h([b({reflect:!0})],Yr.prototype,"position",void 0);Yr=h([L("m3e-badge")],Yr);var Jf=["alt","shift","ctrl","meta"],Na;(function(t){t[t.Backspace=8]="Backspace",t[t.Tab=9]="Tab",t[t.Enter=13]="Enter",t[t.Shift=16]="Shift",t[t.Ctrl=17]="Ctrl",t[t.Alt=18]="Alt",t[t.PauseBreak=19]="PauseBreak",t[t.CapsLock=20]="CapsLock",t[t.Escape=27]="Escape",t[t.Space=32]="Space",t[t.PageUp=33]="PageUp",t[t.PageDown=34]="PageDown",t[t.End=35]="End",t[t.Home=36]="Home",t[t.LeftArrow=37]="LeftArrow",t[t.UpArrow=38]="UpArrow",t[t.RightArrow=39]="RightArrow",t[t.DownArrow=40]="DownArrow",t[t.Insert=45]="Insert",t[t.Delete=46]="Delete",t[t.Zero=48]="Zero",t[t.ClosedParen=48]="ClosedParen",t[t.One=49]="One",t[t.ExclamationMark=49]="ExclamationMark",t[t.Two=50]="Two",t[t.AtSign=50]="AtSign",t[t.Three=51]="Three",t[t.PoundSign=51]="PoundSign",t[t.Hash=51]="Hash",t[t.Four=52]="Four",t[t.DollarSign=52]="DollarSign",t[t.Five=53]="Five",t[t.PercentSign=53]="PercentSign",t[t.Six=54]="Six",t[t.Caret=54]="Caret",t[t.Hat=54]="Hat",t[t.Seven=55]="Seven",t[t.Ampersand=55]="Ampersand",t[t.Eight=56]="Eight",t[t.Star=56]="Star",t[t.Asterik=56]="Asterik",t[t.Nine=57]="Nine",t[t.OpenParen=57]="OpenParen",t[t.A=65]="A",t[t.B=66]="B",t[t.C=67]="C",t[t.D=68]="D",t[t.E=69]="E",t[t.F=70]="F",t[t.G=71]="G",t[t.H=72]="H",t[t.I=73]="I",t[t.J=74]="J",t[t.K=75]="K",t[t.L=76]="L",t[t.M=77]="M",t[t.N=78]="N",t[t.O=79]="O",t[t.P=80]="P",t[t.Q=81]="Q",t[t.R=82]="R",t[t.S=83]="S",t[t.T=84]="T",t[t.U=85]="U",t[t.V=86]="V",t[t.W=87]="W",t[t.X=88]="X",t[t.Y=89]="Y",t[t.Z=90]="Z",t[t.LeftWindowKey=91]="LeftWindowKey",t[t.RightWindowKey=92]="RightWindowKey",t[t.SelectKey=93]="SelectKey",t[t.Numpad0=96]="Numpad0",t[t.Numpad1=97]="Numpad1",t[t.Numpad2=98]="Numpad2",t[t.Numpad3=99]="Numpad3",t[t.Numpad4=100]="Numpad4",t[t.Numpad5=101]="Numpad5",t[t.Numpad6=102]="Numpad6",t[t.Numpad7=103]="Numpad7",t[t.Numpad8=104]="Numpad8",t[t.Numpad9=105]="Numpad9",t[t.Multiply=106]="Multiply",t[t.Add=107]="Add",t[t.Subtract=109]="Subtract",t[t.DecimalPoint=110]="DecimalPoint",t[t.Divide=111]="Divide",t[t.F1=112]="F1",t[t.F2=113]="F2",t[t.F3=114]="F3",t[t.F4=115]="F4",t[t.F5=116]="F5",t[t.F6=117]="F6",t[t.F7=118]="F7",t[t.F8=119]="F8",t[t.F9=120]="F9",t[t.F10=121]="F10",t[t.F11=122]="F11",t[t.F12=123]="F12",t[t.NumLock=144]="NumLock",t[t.ScrollLock=145]="ScrollLock",t[t.SemiColon=186]="SemiColon",t[t.Equals=187]="Equals",t[t.Comma=188]="Comma",t[t.Dash=189]="Dash",t[t.Period=190]="Period",t[t.UnderScore=189]="UnderScore",t[t.PlusSign=187]="PlusSign",t[t.ForwardSlash=191]="ForwardSlash",t[t.Tilde=192]="Tilde",t[t.GraveAccent=192]="GraveAccent",t[t.OpenBracket=219]="OpenBracket",t[t.ClosedBracket=221]="ClosedBracket",t[t.Quote=222]="Quote"})(Na||(Na={}));function Qf(t){return t.which||t.charCode||t.keyCode}function Vh(t,...e){return e.length?e.some(r=>t[`${r}Key`]):t.altKey||t.shiftKey||t.ctrlKey||t.metaKey}function mc(t,...e){return Jf.every(r=>!Vh(t,r)||e.includes(r))}var Oi,Ri,Bi,tn=class{constructor(){Oi.set(this,new Array),Ri.set(this,null),Bi.set(this,void 0)}get items(){return n(this,Oi,"f")}get activeItem(){return n(this,Ri,"f")}setItems(e){let r=this.items.filter(s=>!e.includes(s)),i=e.filter(s=>!this.items.includes(s));return f(this,Oi,e,"f"),this.activeItem&&!this.items.includes(this.activeItem)&&this.updateActiveItem(null),{added:i,removed:r}}setActiveItem(e){this.activeItem!==e&&(this.updateActiveItem(e),n(this,Bi,"f")?.call(this))}updateActiveItem(e){f(this,Ri,e??null,"f")}onActiveItemChange(e){return f(this,Bi,e,"f"),this}};Oi=new WeakMap,Ri=new WeakMap,Bi=new WeakMap;var en,Ui,Di,ji,Gi,Ua,Yi,qa,ec,qh,Kf=Symbol("typeaheadLabel");var tc=class{constructor(e){en.add(this),Ui.set(this,void 0),Di.set(this,-1),ji.set(this,void 0),Gi.set(this,void 0),Ua.set(this,new Array),Yi.set(this,-1),qa.set(this,[]),f(this,Ui,e.debounceInterval??200,"f"),f(this,ji,e.callback,"f"),f(this,Gi,e.skipPredicate,"f")}get isTyping(){return n(this,Ua,"f").length>0}setItems(e){f(this,qa,e,"f")}setSelectedIndex(e){f(this,Yi,e,"f")}reset(){n(this,Ua,"f").length=0}onKeyDown(e){if(e.key&&e.key.length===1)n(this,en,"m",ec).call(this,e.key);else{let r=Qf(e);(r>=Na.A&&r<=Na.Z||r>=Na.Zero&&r<=Na.Nine)&&n(this,en,"m",ec).call(this,String.fromCharCode(r))}}};Ui=new WeakMap,Di=new WeakMap,ji=new WeakMap,Gi=new WeakMap,Ua=new WeakMap,Yi=new WeakMap,qa=new WeakMap,en=new WeakSet,ec=function(e){n(this,Ua,"f").push(e.toLocaleUpperCase()),clearTimeout(n(this,Di,"f")),f(this,Di,setTimeout(()=>n(this,en,"m",qh).call(this),n(this,Ui,"f")),"f")},qh=function(){let e=n(this,Ua,"f").join("");for(let r=1;r<n(this,qa,"f").length+1;r++){let i=(n(this,Yi,"f")+r)%n(this,qa,"f").length,s=n(this,qa,"f")[i],l=s[Kf]?.().toLocaleUpperCase().trim();if(!n(this,Gi,"f")?.call(this,s)&&l?.indexOf(e)===0){n(this,ji,"f").call(this,s);break}}this.reset()};var ve,fo,oc,ac,Xr,Zr,rc,nc,on=class extends tn{constructor(){super(...arguments),ve.add(this),fo.set(this,void 0),this.wrap=!1,this.homeAndEnd=!1,this.pageUpAndDown=!1,this.pageDelta=10,this.vertical=!1,this.allowedModifiers=[],this.skipPredicate=e=>gt(e)&&e.disabled,this.directionality="ltr"}setItems(e){return n(this,fo,"f")?.setItems(e),super.setItems(e)}updateActiveItem(e){super.updateActiveItem(e),n(this,fo,"f")&&n(this,fo,"f").setSelectedIndex(e?this.items.indexOf(e):-1)}withHomeAndEnd(e=!0){return this.homeAndEnd=e,this}withPageUpAndDown(e=!0,r=10){return this.pageUpAndDown=e,this.pageDelta=r,this}withWrap(e=!0){return this.wrap=e,this}withVerticalOrientation(e=!0){return this.vertical=e,this}withAllowedModifiers(...e){return this.allowedModifiers=e,this}withTypeahead(e=!0){return e?f(this,fo,new tc({callback:r=>this.setActiveItem(r)}),"f"):f(this,fo,void 0,"f"),this}withSkipPredicate(e){return this.skipPredicate=e,this}withDirectionality(e){return this.directionality=e,this}onKeyDown(e){if(e.defaultPrevented)return;let r=mc(e,...this.allowedModifiers);switch(e.key){case"Left":case"ArrowLeft":if(r&&!this.vertical){e.preventDefault();let i=this.directionality==="ltr"?n(this,ve,"m",Zr).call(this):n(this,ve,"m",Xr).call(this);i&&this.setActiveItem(i)}break;case"Up":case"ArrowUp":if(r){e.preventDefault();let i=this.directionality==="ltr"?n(this,ve,"m",Zr).call(this):n(this,ve,"m",Xr).call(this);i&&this.setActiveItem(i)}break;case"Right":case"ArrowRight":if(r&&!this.vertical){e.preventDefault();let i=this.directionality==="ltr"?n(this,ve,"m",Xr).call(this):n(this,ve,"m",Zr).call(this);i&&this.setActiveItem(i)}break;case"Down":case"ArrowDown":if(r){e.preventDefault();let i=this.directionality==="ltr"?n(this,ve,"m",Xr).call(this):n(this,ve,"m",Zr).call(this);i&&this.setActiveItem(i)}break;case"Home":if(r&&this.homeAndEnd){e.preventDefault();let i=n(this,ve,"m",oc).call(this);i&&this.setActiveItem(i)}break;case"End":if(r&&this.homeAndEnd){e.preventDefault();let i=n(this,ve,"m",ac).call(this);i&&this.setActiveItem(i)}break;case"PageUp":if(r&&this.pageUpAndDown){e.preventDefault();let i=this.activeItem?Math.max(0,this.items.indexOf(this.activeItem)-this.pageDelta):0,s=this.directionality==="ltr"?n(this,ve,"m",rc).call(this,i):n(this,ve,"m",nc).call(this,i);s&&this.setActiveItem(s)}break;case"PageDown":if(r&&this.pageUpAndDown){e.preventDefault();let i=this.activeItem?Math.min(this.items.length-1,this.items.indexOf(this.activeItem)+this.pageDelta):this.items.length-1,s=this.directionality==="ltr"?n(this,ve,"m",nc).call(this,i):n(this,ve,"m",rc).call(this,i);s&&this.setActiveItem(s)}break;default:(r||Vh(e,"shift"))&&n(this,fo,"f")?.onKeyDown(e);break}}};fo=new WeakMap,ve=new WeakSet,oc=function(){for(let e=0;e<this.items.length&&this.items[e]!==this.activeItem;e++){let r=this.items[e];if(!this.skipPredicate(r))return r}return null},ac=function(){for(let e=this.items.length-1;e>=0&&this.items[e]!==this.activeItem;e--){let r=this.items[e];if(!this.skipPredicate(r))return r}return null},Xr=function(){for(let e=0;e<this.items.length;e++)if(this.items[e]===this.activeItem){for(let r=e+1;r<this.items.length;r++){let i=this.items[r];if(!this.skipPredicate(i))return i}break}return this.wrap?n(this,ve,"m",oc).call(this):null},Zr=function(){for(let e=0;e<this.items.length;e++)if(this.items[e]===this.activeItem){for(let r=e-1;r>=0;r--){let i=this.items[r];if(!this.skipPredicate(i))return i}break}return this.wrap?n(this,ve,"m",ac).call(this):null},rc=function(e){for(let r=e;r>=0;r--){let i=this.items[r];if(!this.skipPredicate(i))return i}return null},nc=function(e){for(let r=e;r<this.items.length;r++){let i=this.items[r];if(!this.skipPredicate(i))return i}return null};var Hi,ic=class extends on{constructor(){super(...arguments),Hi.set(this,void 0)}setActiveItem(e){super.setActiveItem(e),e?.focus(n(this,Hi,"f"))}withOptions(e){return f(this,Hi,e,"f"),this}};Hi=new WeakMap;var ea,sc=class extends ic{constructor(){super(...arguments),ea.set(this,!1)}updateActiveItem(e){if(super.updateActiveItem(e),!n(this,ea,"f")){e?.setAttribute("tabindex","0");for(let r of this.items)r!==e&&r.hasAttribute("tabindex")&&r.setAttribute("tabindex","-1")}}setItems(e){let r=super.setItems(e);if(!n(this,ea,"f"))for(let i of r.added)i!==this.activeItem&&!this.skipPredicate(i)&&i.setAttribute("tabindex","-1");return r}disableRovingTabIndex(e=!0){if(e!==n(this,ea,"f")){f(this,ea,e,"f");for(let r of this.items)this.skipPredicate(r)||r?.setAttribute("tabindex",n(this,ea,"f")||r===this.activeItem?"0":"-1")}return this}};ea=new WeakMap;var Wi,lc=class extends sc{constructor(){super(...arguments),Wi.set(this,!1)}get disabled(){return n(this,Wi,"f")}set disabled(e){f(this,Wi,e,"f"),this.items.forEach(r=>r.disabled=e)}setItems(e){this.disabled&&e.forEach(s=>s.disabled=!0);let{added:r,removed:i}=super.setItems(e);if((r.length>0||i.length>0)&&(this.activeItem||this.updateActiveItem(r.find(s=>!this.skipPredicate(s))??null),this.activeItem&&(this.activeItem.disabled||!Yo(this.activeItem)))){let s=r.find(l=>!this.skipPredicate(l)&&Yo(l));s&&this.updateActiveItem(s)}return{added:r,removed:i}}};Wi=new WeakMap;var Ni,ta,Ie,qi,cc,Z=Symbol("selectionManager"),ja=class extends lc{constructor(){super(...arguments),Ni.add(this),ta.set(this,void 0),Ie.set(this,new Array),qi.set(this,!1)}get multi(){return n(this,qi,"f")}set multi(e){f(this,qi,e,"f"),n(this,Ni,"m",cc).call(this,!0)}get selectedItems(){return n(this,Ie,"f")}notifySelectionChange(e){this.items.includes(e)&&(Yo(e)?this.select(e):this.deselect(e))}deselect(e){if(this.items.includes(e)){Yo(e)&&Hr(e,!1);let r=n(this,Ie,"f").indexOf(e);r>=0&&(n(this,Ie,"f").splice(r,1),n(this,ta,"f")?.call(this))}}select(e,r=!0){if(!e||this.items.includes(e)){if(!this.multi){for(let i of n(this,Ie,"f"))i!==e&&Hr(i,!1);n(this,Ie,"f").length=0}e&&(n(this,Ie,"f").push(e),Yo(e)||Hr(e,!0)),r&&this.updateActiveItem(e),n(this,ta,"f")?.call(this)}}setItems(e){let{added:r,removed:i}=super.setItems(e);return f(this,Ie,n(this,Ie,"f").filter(s=>!i.includes(s)),"f"),n(this,Ie,"f").push(...r.filter(s=>Yo(s))),n(this,Ni,"m",cc).call(this),n(this,ta,"f")?.call(this),{added:r,removed:i}}onSelectedItemsChange(e){return f(this,ta,e,"f"),this}};ta=new WeakMap,Ie=new WeakMap,qi=new WeakMap,Ni=new WeakSet,cc=function(e=!1){if(!this.multi&&n(this,Ie,"f").length>1){for(let r=1;r<n(this,Ie,"f").length;r++)Hr(n(this,Ie,"f")[r],!1);n(this,Ie,"f").length=1,e&&n(this,ta,"f")?.call(this)}};function Uh(t,e){return t.getAttribute(e)?.match(/\S+/g)??[]}function oa(t,e,r){r=r.trim();let i=Uh(t,e);i.some(s=>s.trim()===r)||(i.push(r),t.setAttribute(e,i.join(" ")))}function an(t,e,r){r=r.trim();let i=Uh(t,e).filter(s=>s!==r);i.length>0?t.setAttribute(e,i.join(" ")):t.removeAttribute(e)}function jh(t){t.position="absolute",t.appearance="none",t.visibility="hidden",t.border="0",t.outline="0",t.overflow="hidden",t.left="0",t.height="1px",t.width="1px",t.margin="-1px",t.padding="0",t.whiteSpace="nowrap"}var Jt,dc,Jr,Gh,Yh,He=class{static describe(e,r,i="tooltip"){if(!1)return;let s=e.getRootNode();if(!(s instanceof ShadowRoot||s instanceof Document))return;let l=n(this,Jt,"f",Jr).get(s);l||(l={containerElement:n(this,Jt,"m",Gh).call(this),messageRegistry:new Map},(s instanceof Document?s.body:s).appendChild(l.containerElement),n(this,Jt,"f",Jr).set(s,l));let c=`${i}:${r}`,d=l.messageRegistry.get(c);d||(d={messageElement:n(this,Jt,"m",Yh).call(this,r,i),count:0},l.containerElement.appendChild(d.messageElement),l.messageRegistry.set(c,d)),d.count++,oa(e,"aria-describedby",d.messageElement.id)}static removeDescription(e,r,i="tooltip"){if(!1)return;let s=e.getRootNode(),l=n(this,Jt,"f",Jr).get(s);if(!l)return;let c=`${i}:${r}`,d=l.messageRegistry.get(c);d&&(d.count--,an(e,"aria-describedby",d.messageElement.id),d.count<=0&&(d.messageElement.remove(),l.messageRegistry.delete(c)),l.messageRegistry.size==0&&(l.containerElement?.remove(),n(this,Jt,"f",Jr).delete(s)))}};Jt=He,Gh=function(){let e=document.createElement("div");return e.classList.add("m3e-describedby-message-container"),jh(e.style),e},Yh=function(e,r){var i,s;let l=document.createElement("span");return l.id=`m3e-describedby-message-${f(this,Jt,(s=n(this,Jt,"f",dc),i=s++,s),"f",dc),i}`,l.role=r,l.ariaAtomic="true",l.innerText=e.trim(),l};dc={value:0};Jr={value:new Map};globalThis.M3eAriaDescriber=He;var Va,hc,Xi,bo=class{static isFocusable(e,r,i=!1,s=!1){let l=`:is(button,input,select,textarea,object,:is(a,area)[href],[tabindex]${s?"":":not([tabindex='-1'])"},[contenteditable=true])${s?"":":not(:disabled,[disabled])"}${i?"":":not([hidden])"}`;return e.matches(l)?!n(this,Va,"m",Xi).call(this,e,i)&&!n(this,Va,"m",hc).call(this,r,i):!e.localName.includes("-")||!e.matches(":not(:disabled,[disabled])")||e.getAttribute("aria-disabled")==="true"?!1:e.shadowRoot?.delegatesFocus?!n(this,Va,"m",Xi).call(this,e,i)&&!n(this,Va,"m",hc).call(this,r,i):!1}static findInteractiveElements(e,r=!1){let i=new Array,s=e.ownerDocument.createTreeWalker(e,NodeFilter.SHOW_ELEMENT);for(let l=s.nextNode();l;l=s.nextNode()){let c=s.currentNode;this.isFocusable(c,void 0,r,!0)&&i.push(c)}return i}};Va=bo,hc=function(e,r=!1){return e?.some(i=>i.matches(`:is([aria-hidden='true'],:disabled,[disabled],[inert]${r?"":",[hidden]"})`)||n(this,Va,"m",Xi).call(this,i,r))??!1},Xi=function(e,r){if(r)return!1;let i=getComputedStyle(e);return i.display==="none"||i.visibility==="hidden"};globalThis.M3eInteractivityChecker=bo;var Ct,Xh,Zh,Qi,Jh,Qh,Zi=class extends se(P){constructor(){super(...arguments),Ct.add(this)}render(){let e=w`<div class="trap" .inert="${this.disabled}" tabindex="0" aria-hidden="true" @focus="${n(this,Ct,"m",Xh)}"></div>`;return w`${e}<slot></slot>${e}`}};Ct=new WeakSet;Xh=function(e){function r(p,g){return p===g||p instanceof HTMLElement&&p.shadowRoot!==null&&p.shadowRoot.contains(g)}let[i,s]=n(this,Ct,"m",Zh).call(this),l=e?.target===this._firstTrap,c=r(e.relatedTarget,i),d=r(e.relatedTarget,s),u=!c&&!d;if(!l&&d||l&&u){i?.focus();return}(l&&c||!l&&u)&&s?.focus()};Zh=function(){let e=null,r=null;return n(this,Ct,"m",Qi).call(this,this,[],(i,s)=>{bo.isFocusable(i,s)&&i instanceof HTMLElement&&i.tabIndex>=0&&(e=e??i,r=i)}),[e,r]};Qi=function t(e,r,i){r=[...r,e];for(let s of e.childNodes){if(s.nodeType!==Node.ELEMENT_NODE)continue;let l=s;i(l,r),l.shadowRoot?n(this,Ct,"m",Jh).call(this,l,r,i):l instanceof HTMLSlotElement?n(this,Ct,"m",Qh).call(this,l,r,i):l.hasChildNodes()&&n(this,Ct,"m",t).call(this,l,r,i)}};Jh=function(e,r,i){for(let s of e.shadowRoot?.childNodes??[]){if(s.nodeType!==Node.ELEMENT_NODE)continue;let l=s;i(l,r),l.hasChildNodes()&&n(this,Ct,"m",Qi).call(this,l,r,i)}};Qh=function t(e,r,i){r=[...r,e];let s=e.assignedElements();s.length==0&&e.hasChildNodes()&&(s=e.childNodes);for(let l of s){if(l.nodeType!==Node.ELEMENT_NODE)continue;let c=l;if(c instanceof HTMLSlotElement){n(this,Ct,"m",t).call(this,c,r,i);continue}i(c,r),c.hasChildNodes()&&n(this,Ct,"m",Qi).call(this,c,r,i)}};Zi.styles=C`:host { display: contents; } .trap { outline: none; }`;h([M(".trap")],Zi.prototype,"_firstTrap",void 0);Zi=h([L("m3e-focus-trap")],Zi);var ne,uc,Zt,Qr,Kr,Vi,Kh,Ji=class{static announce(e,...r){if(!1)return Promise.resolve();f(this,ne,n(this,ne,"f",Zt)??n(this,ne,"m",Kh).call(this),"f",Zt);let i,s;r.length===1&&typeof r[0]=="number"?s=r[0]:[i,s]=r,this.clear(),clearTimeout(n(this,ne,"f",Qr)),n(this,ne,"f",Zt).setAttribute("aria-live",i??"polite");for(let l of document.querySelectorAll("m3e-dialog"))oa(l,"aria-owns",n(this,ne,"f",Zt).id);return f(this,ne,n(this,ne,"f",Kr)??new Promise(l=>f(this,ne,l,"f",Vi)),"f",Kr),clearTimeout(n(this,ne,"f",Qr)),f(this,ne,setTimeout(()=>{n(this,ne,"f",Zt)&&(n(this,ne,"f",Zt).textContent=e,s!==void 0&&f(this,ne,setTimeout(()=>this.clear(),s),"f",Qr),n(this,ne,"f",Vi)?.call(this),f(this,ne,f(this,ne,void 0,"f",Vi),"f",Kr))},100),"f",Qr),n(this,ne,"f",Kr)}static clear(){n(this,ne,"f",Zt)&&(n(this,ne,"f",Zt).textContent="")}};ne=Ji,Kh=function(){var e,r;let i=document.getElementsByClassName("m3e-live-announcer");for(let l=0;l<i.length;l++)i[l].remove();let s=document.createElement("div");return s.classList.add("m3e-live-announcer"),s.setAttribute("aria-atomic","true"),s.setAttribute("aria-live","polite"),s.id=`m3e-live-announcer-${f(this,ne,(r=n(this,ne,"f",uc),e=r++,r),"f",uc),e}`,jh(s.style),document.body.append(s),s};uc={value:0};Zt={value:void 0};Qr={value:void 0};Kr={value:void 0};Vi={value:void 0};globalThis.M3eLiveAnnouncer=Ji;var eu=class extends Ho{_onClick(){this.closest("m3e-bottom-sheet")?.hide()}};eu=h([L("m3e-bottom-sheet-action")],eu);var E,Ki,es,ts,sa,os,as,rs,Ga,ee,la,ue,rn,ra,vo,Qt,pc,tu,ou,au,ru,nu,iu,su,lu,fc,cu,du,rt,na,nn,bc,is,hu,ca,ia,nt,aa,We=aa=class extends uo(yi(Q(P))){constructor(){super(...arguments),E.add(this),Ki.set(this,e=>n(this,E,"m",ru).call(this,e)),es.set(this,e=>n(this,E,"m",nu).call(this,e)),ts.set(this,()=>n(this,E,"m",iu).call(this)),sa.set(this,new Bo),os.set(this,new zr(this)),as.set(this,new Ir(this)),rs.set(this,new we(this,{target:null,skipInitial:!0,callback:e=>n(this,E,"m",hu).call(this,e)})),Ga.set(this,null),ee.set(this,void 0),la.set(this,!1),ue.set(this,0),rn.set(this,void 0),ra.set(this,0),vo.set(this,0),Qt.set(this,void 0),this.modal=!1,this.open=!1,this.handle=!1,this.handleLabel="Drag handle",this.detents=[],this.detent=0,this.hideable=!1,this.hideFriction=.5,this.overshootLimit=4}show(e=this.detent){this.open?e!==void 0&&n(this,ue,"f")!==e&&n(this,E,"m",ca).call(this,e):(f(this,rn,e,"f"),this.open=!0)}hide(){this.open=!1}toggle(e){this.open?this.hide():this.show(e)}cycle(){var e;this.open?this.detents.length>0?n(this,ue,"f")<this.detents.length-1?(f(this,ue,(e=n(this,ue,"f"),e++,e),"f"),n(this,E,"m",ca).call(this,n(this,ue,"f"))):this.hideable&&this.hide():this.hide():this.show()}update(e){super.update(e),e.has("modal")&&(this.role=this.modal?"dialog":"region",this.ariaModal=this.modal?"true":null,this.popover=this.modal?"manual":null)}reconnectedCallback(){super.reconnectedCallback(),n(this,E,"m",pc).call(this)}firstUpdated(e){super.firstUpdated(e),n(this,E,"m",pc).call(this)}updated(e){if(super.updated(e),e.has("open")){if(this.open){if(!this.dispatchEvent(new Event("opening",{cancelable:!0}))){this.open=!1;return}aa.__openSheet!==this&&aa.__openSheet?.hide(),aa.__openSheet=this,this.inert=!1,window.addEventListener("resize",n(this,ts,"f")),this.detents.length>0?(f(this,ue,Math.min(Math.max(0,n(this,rn,"f")??this.detent),this.detents.length-1),"f"),n(this,E,"m",nt).call(this,n(this,E,"m",rt).call(this,this.detents[n(this,ue,"f")]))):n(this,E,"m",nt).call(this,Math.min(n(this,E,"m",rt).call(this,"fit"),n(this,E,"m",rt).call(this,"half"))),f(this,rn,void 0,"f")}else{if(!this.dispatchEvent(new Event("closing",{cancelable:!0}))){this.open=!0;return}requestAnimationFrame(()=>this.inert=!0),window.removeEventListener("resize",n(this,ts,"f")),aa.__openSheet===this&&(aa.__openSheet=void 0)}if(this.modal)if(this.open){f(this,Ga,document.activeElement,"f"),n(this,as,"f").lock(),n(this,os,"f").lock(),this.showPopover(),requestAnimationFrame(()=>{document.addEventListener("click",n(this,Ki,"f")),document.addEventListener("keydown",n(this,es,"f"))});let r=this.querySelector("[autofocus]");(!r||!bo.isFocusable(r))&&(r=this.shadowRoot?.querySelector(".handle")),r&&ch(r)}else n(this,E,"m",ia).call(this,0).then(()=>{n(this,as,"f").unlock(),n(this,os,"f").unlock(),document.removeEventListener("click",n(this,Ki,"f")),document.removeEventListener("keydown",n(this,es,"f")),this.hidePopover(),n(this,Ga,"f")instanceof HTMLElement&&n(this,Ga,"f").focus(),f(this,Ga,null,"f")});this.dispatchEvent(new Event(this.open?"opened":"closed"))}}render(){return w`<m3e-focus-trap ?disabled="${!this.modal}"><div class="base"><m3e-elevation class="elevation"></m3e-elevation><div class="header" @pointerdown="${n(this,E,"m",tu)}" @pointermove="${n(this,E,"m",ou)}" @pointerup="${n(this,E,"m",au)}">${this.handle?w`<div class="handle-row"><div id="handle" class="handle" role="button" aria-label="${this.handleLabel}" tabindex="0" @click="${n(this,E,"m",su)}" @keydown="${n(this,E,"m",lu)}"><m3e-focus-ring class="focus-ring" for="handle"></m3e-focus-ring><div class="handle-touch" aria-hidden="true"></div></div></div>`:F}<slot name="header"></slot></div><div class="body"><div class="content"><slot></slot></div></div></div></m3e-focus-trap>`}};Ki=new WeakMap;es=new WeakMap;ts=new WeakMap;sa=new WeakMap;os=new WeakMap;as=new WeakMap;rs=new WeakMap;Ga=new WeakMap;ee=new WeakMap;la=new WeakMap;ue=new WeakMap;rn=new WeakMap;ra=new WeakMap;vo=new WeakMap;Qt=new WeakMap;E=new WeakSet;pc=function(){let e=this.shadowRoot?.querySelector(".content");e&&(f(this,ra,e.clientHeight,"f"),n(this,rs,"f").observe(e));let r=this.shadowRoot?.querySelector(".header");r&&(f(this,vo,r.clientHeight,"f"),n(this,rs,"f").observe(r))};tu=function(e){if(e.target instanceof HTMLElement&&bo.isFocusable(e.target))return;e.target.setPointerCapture(e.pointerId),e.target.style.cursor="grabbing",n(this,sa,"f").reset(),n(this,sa,"f").add(e.clientY);let r=n(this,E,"m",na).call(this),i=this.detents.length>0?Math.max(...this.detents.map(s=>n(this,E,"m",rt).call(this,s))):r;f(this,ee,{startY:e.clientY,startHeight:this.clientHeight,effectiveMaxHeight:i,maxHeight:r,minHeight:n(this,E,"m",nn).call(this)},"f"),f(this,la,!1,"f")};ou=function(e){if(!n(this,ee,"f")||Math.abs(e.clientY-n(this,ee,"f").startY)<=8)return;(e.getCoalescedEvents?.()??[e]).forEach(s=>n(this,sa,"f").add(s.clientY,e.timeStamp));let i=n(this,ee,"f").startHeight-(e.clientY-n(this,ee,"f").startY);if(i<n(this,ee,"f").minHeight)if(this.hideable){let s=(n(this,ee,"f").minHeight-i)*this.hideFriction;i=n(this,ee,"f").minHeight-s}else{let s=n(this,ee,"f").minHeight-i,l=n(this,ee,"f").maxHeight*(this.overshootLimit/100),c=l*s/(s+l);i=n(this,ee,"f").minHeight-c}else if(i>n(this,ee,"f").effectiveMaxHeight){let s=i-n(this,ee,"f").effectiveMaxHeight,l=n(this,ee,"f").maxHeight*(this.overshootLimit/100),c=l*s/(s+l);i=n(this,ee,"f").effectiveMaxHeight+c}n(this,E,"m",nt).call(this,i),f(this,la,!0,"f")};au=function(e){if(n(this,ee,"f"))try{if(e.target.releasePointerCapture(e.pointerId),e.target.style.cursor="",!n(this,la,"f"))return;let r=e.pointerType==="touch"?1200:500,i=n(this,sa,"f").getVelocity();if(n(this,sa,"f").reset(),this.hideable&&i>=r)this.dispatchEvent(new Event("cancel",{cancelable:!0}))&&this.hide();else if(Math.abs(i)>=r)if(this.detents.length>0){let s=n(this,E,"m",fc).call(this);s!==n(this,ue,"f")&&n(this,E,"m",ca).call(this,s)}else n(this,E,"m",ia).call(this,n(this,E,"m",rt).call(this,"full"));else{if(this.hideable){let l=n(this,ee,"f").minHeight;if(this.clientHeight<l-20){this.hide();return}}this.detents.length>0?n(this,E,"m",ca).call(this,n(this,E,"m",du).call(this)):this.clientHeight<n(this,ee,"f").minHeight?n(this,E,"m",ia).call(this,n(this,ee,"f").minHeight):this.clientHeight>n(this,ee,"f").effectiveMaxHeight&&n(this,E,"m",ia).call(this,n(this,ee,"f").effectiveMaxHeight)}}finally{f(this,ee,void 0,"f")}};ru=function(e){this.open&&this.modal&&!e.composedPath().includes(this)&&this.dispatchEvent(new Event("cancel",{cancelable:!0}))&&this.hide()};nu=function(e){this.open&&this.modal&&e.key==="Escape"&&!e.shiftKey&&!e.ctrlKey&&(e.preventDefault(),this.dispatchEvent(new Event("cancel",{cancelable:!0}))&&this.hide())};iu=function(){if(this.detents.length>0&&this.detents[n(this,ue,"f")]==="half"){n(this,E,"m",nt).call(this,n(this,E,"m",rt).call(this,"half"));return}let e=n(this,E,"m",na).call(this);ie(this,"--full")?n(this,E,"m",nt).call(this,e):this.clientHeight>e&&n(this,E,"m",nt).call(this,e)};su=function(){n(this,la,"f")||this.cycle(),f(this,la,!1,"f")};lu=function(e){if(!(e.defaultPrevented||!mc(e)))switch(e.key){case"Up":case"ArrowUp":if(e.preventDefault(),this.detents.length>0){let r=n(this,E,"m",fc).call(this);r!==n(this,ue,"f")&&n(this,E,"m",ca).call(this,r)}else n(this,E,"m",ia).call(this,n(this,E,"m",rt).call(this,"full"));break;case"Down":case"ArrowDown":if(e.preventDefault(),this.detents.length>0){let r=n(this,E,"m",cu).call(this);r!==n(this,ue,"f")?n(this,E,"m",ca).call(this,r):this.hideable&&this.hide()}else this.hideable&&this.hide();break}};fc=function(){let e=this.clientHeight,r=1/0,i=n(this,ue,"f");for(let s=0;s<this.detents.length;s++){if(s===n(this,ue,"f"))continue;let l=n(this,E,"m",rt).call(this,this.detents[s]);l>e&&l<r&&(r=l,i=s)}return i};cu=function(){let e=this.clientHeight,r=-1/0,i=n(this,ue,"f");for(let s=0;s<this.detents.length;s++){if(s===n(this,ue,"f"))continue;let l=n(this,E,"m",rt).call(this,this.detents[s]);l<e&&l>r&&(r=l,i=s)}return i};du=function(){let e=this.clientHeight,r=n(this,ue,"f"),i=1/0;for(let s=0;s<this.detents.length;s++){let l=n(this,E,"m",rt).call(this,this.detents[s]),c=Math.abs(e-l);c<i&&(i=c,r=s)}return r};rt=function(e){switch(e){case"collapsed":return n(this,E,"m",nn).call(this);case"half":return n(this,E,"m",na).call(this)*.5;case"full":return n(this,E,"m",na).call(this);case"fit":return n(this,E,"m",is).call(this)}return e.endsWith("%")?n(this,E,"m",na).call(this)*(parseFloat(e)/100):e.endsWith("px")?parseFloat(e):n(this,E,"m",nn).call(this)};na=function(){let e=this.shadowRoot?.querySelector(".base");return window.innerHeight-(e?Sl(e,"var(--_bottom-sheet-top-space)"):0)};nn=function(){return this.detents.includes("fit")&&!this.detents.includes("collapsed")?n(this,E,"m",is).call(this):n(this,E,"m",bc).call(this)};bc=function(){let e=this.shadowRoot?.querySelector(".base");return n(this,vo,"f")+(e?Sl(e,"var(--_bottom-sheet-peek-height)"):0)};is=function(){let e=this.shadowRoot?.querySelector(".body");if(!e)return 0;let r=getComputedStyle(e);return n(this,vo,"f")+n(this,ra,"f")+parseFloat(r.paddingBlockStart)+parseFloat(r.paddingBlockEnd)};hu=function(e){let r=n(this,ra,"f"),i=n(this,vo,"f");for(let s of e)s.target.classList.contains("content")?f(this,ra,(Array.isArray(s.borderBoxSize)?s.borderBoxSize[0]:s.borderBoxSize).blockSize,"f"):s.target.classList.contains("header")&&f(this,vo,(Array.isArray(s.borderBoxSize)?s.borderBoxSize[0]:s.borderBoxSize).blockSize,"f");if(this.open&&this.detents.length>0&&(r!==n(this,ra,"f")||i!==n(this,vo,"f")))switch(this.detents[n(this,ue,"f")]){case"fit":n(this,E,"m",nt).call(this,n(this,E,"m",is).call(this));break;case"collapsed":n(this,E,"m",nt).call(this,n(this,E,"m",nn).call(this));break}};ca=function(e){e>=0&&e<this.detents.length&&(f(this,ue,e,"f"),n(this,E,"m",ia).call(this,n(this,E,"m",rt).call(this,this.detents[e])))};ia=async function(e){n(this,Qt,"f")&&(n(this,E,"m",nt).call(this,this.clientHeight),n(this,Qt,"f")?.cancel(),f(this,Qt,void 0,"f")),Ce()?n(this,E,"m",nt).call(this,e):(f(this,Qt,this.animate([{"--_bottom-sheet-height":`${this.clientHeight}px`},{"--_bottom-sheet-height":`${e}px`}],{duration:250,easing:"cubic-bezier(0.2, 0.0, 0, 1.0)"}),"f"),n(this,Qt,"f").onfinish=()=>{n(this,E,"m",nt).call(this,e),f(this,Qt,void 0,"f")},await n(this,Qt,"f").finished)};nt=function(e){this.style.setProperty("--_bottom-sheet-height",`${e}px`),R(this,"--full",e===n(this,E,"m",na).call(this));let r=this.shadowRoot?.querySelector(".content");r&&(r.inert=e<=n(this,E,"m",bc).call(this))};ho(C`@property --_bottom-sheet-height { syntax: "<length>"; inherits: false; initial-value: 50vh; } m3e-bottom-sheet > [slot="header"] { margin-block-end: var(--m3e-bottom-sheet-padding-block, 0.5rem); margin-inline: var(--m3e-bottom-sheet-padding-inline, 1rem); }</length>`);We.styles=C`:host { display: block; position: fixed; left: 50%; top: calc(100vh - var(--_bottom-sheet-height)); margin: 0; padding: 0; outline: none; overflow: hidden; border: none; box-sizing: border-box; width: var(--m3e-bottom-sheet-width, 100%); max-width: var(--m3e-bottom-sheet-max-width, 40rem); height: var(--_bottom-sheet-height); color: var(--m3e-bottom-sheet-color, ${a.color.onSurface}); background-color: var(--m3e-bottom-sheet-container-color, ${a.color.surfaceContainerLow}); } :host(:not(:is(:state(--no-animate), :--no-animate))) { transition: ${o(`transform ${a.motion.duration.medium2} ${a.motion.easing.standardDecelerate},
        border-radius ${a.motion.duration.medium2} ${a.motion.easing.standard}`)}; } :host(:not([modal]):not(:is(:state(--full), :--full))) .elevation { --m3e-elevation-level: var(--m3e-bottom-sheet-elevation, ${a.elevation.level1}); } :host([modal]:not(:is(:state(--full), :--full))) .elevation { --m3e-elevation-level: var(--m3e-bottom-sheet-modal-elevation, ${a.elevation.level1}); } :host(:is(:state(--full), :--full)) .elevation { --m3e-elevation-level: var(--m3e-bottom-sheet-full-elevation, ${a.elevation.level1}); } :host(:not([modal])) { z-index: var(--m3e-bottom-sheet-z-index, 10); } :host(:not([modal]):not([open])), :host([modal]:not(:popover-open)) { border-radius: var(--m3e-bottom-sheet-minimized-container-shape, ${a.shape.corner.none}); transform: translateX(-50%) translateY(100%); } :host(:not([modal])[open]:not(:is(:state(--full), :--full))), :host([modal]:not(:is(:state(--full), :--full)):popover-open) { border-radius: var(--m3e-bottom-sheet-container-shape, ${a.shape.corner.extraLargeTop}); } :host(:not([modal])[open]:is(:state(--full), :--full)), :host([modal]:is(:state(--full), :--full):popover-open) { border-radius: var(--m3e-bottom-sheet-full-container-shape, ${a.shape.corner.extraLargeTop}); } :host(:not([modal])[open]), :host([modal]:popover-open) { transform: translateX(-50%) translateY(0); } :host([modal]:not(:is(:state(--no-animate), :--no-animate)))::backdrop { transition: ${o(`background-color ${a.motion.duration.short3} ${a.motion.easing.standard}, 
        overlay ${a.motion.duration.short3} ${a.motion.easing.standard} allow-discrete,
        visibility ${a.motion.duration.short3} ${a.motion.easing.standard} allow-discrete`)}; } :host([modal]:popover-open)::backdrop { background-color: color-mix( in srgb, var(--m3e-bottom-sheet-scrim-color, ${a.color.scrim}) var(--m3e-bottom-sheet-scrim-opacity, 32%), transparent ); } :host([modal]:popover-open:not(:is(:state(--no-animate), :--no-animate)))::backdrop { transition: ${o(`background-color ${a.motion.duration.long2} ${a.motion.easing.standard}, 
        overlay ${a.motion.duration.long2} ${a.motion.easing.standard} allow-discrete,
        visibility ${a.motion.duration.long2} ${a.motion.easing.standard} allow-discrete`)}; } @starting-style { :host([modal]:popover-open)::backdrop { background-color: color-mix( in srgb, var(--m3e-bottom-sheet-scrim-color, ${a.color.scrim}) 0%, transparent ); } } .base { contain: layout style paint; display: flex; border-radius: inherit; flex-direction: column; height: 100%; --_bottom-sheet-peek-height: var(--m3e-bottom-sheet-peek-height, 0); --_bottom-sheet-top-space: var(--m3e-bottom-sheet-compact-top-space, 4.5rem); } @media (max-height: 640px) { .base { --_bottom-sheet-top-space: var(--m3e-bottom-sheet-top-space, 3.5rem); } } .body { flex: 1 1 auto; overflow-y: auto; scrollbar-width: ${a.scrollbar.thinWidth}; scrollbar-color: ${a.scrollbar.color}; padding-block-end: var(--m3e-bottom-sheet-padding-block, 0.5rem); padding-inline: var(--m3e-bottom-sheet-padding-inline, 1rem); font-size: var(--m3e-bottom-sheet-content-font-size, ${a.typescale.standard.body.medium.fontSize}); font-weight: var( --m3e-bottom-sheet-content-font-weight, ${a.typescale.standard.body.medium.fontWeight} ); line-height: var( --m3e-bottom-sheet-content-line-height, ${a.typescale.standard.body.medium.lineHeight} ); letter-spacing: var(--m3e-bottom-sheet-content-tracking, ${a.typescale.standard.body.medium.tracking}); } .content { height: fit-content; } :host(:not([handle])) .header { display: none; } :host(:not([handle])) .body, .header { border-top-left-radius: inherit; border-top-right-radius: inherit; padding-block-start: var(--m3e-bottom-sheet-padding-block, 0.5rem); font-size: var(--m3e-bottom-sheet-header-font-size, ${a.typescale.standard.title.large.fontSize}); font-weight: var(--m3e-bottom-sheet-header-font-weight, ${a.typescale.standard.title.large.fontWeight}); line-height: var(--m3e-bottom-sheet-header-line-height, ${a.typescale.standard.title.large.lineHeight}); letter-spacing: var(--m3e-bottom-sheet-header-tracking, ${a.typescale.standard.title.large.tracking}); } .header { cursor: grab; touch-action: none; outline: none; user-select: none; -webkit-tap-highlight-color: rgba(0, 0, 0, 0); box-sizing: border-box; flex: none; display: flex; flex-direction: column; min-height: 3rem; --m3e-app-bar-container-color: var(--m3e-bottom-sheet-container-color, ${a.color.surfaceContainerLow}); } .handle-row { position: relative; flex: none; display: flex; align-items: center; justify-content: center; opacity: 1; visibility: visible; height: var(--m3e-bottom-sheet-handle-container-height, 1.5rem); } :host(:not(:is(:state(--no-animate), :--no-animate))) .handle-row { transition: ${o(`opacity ${a.motion.duration.short3} ${a.motion.easing.standard},
        padding ${a.motion.duration.short3} ${a.motion.easing.standard},
        height ${a.motion.duration.short3} ${a.motion.easing.standard},
        visibility ${a.motion.duration.short3} ${a.motion.easing.standard} allow-discrete`)}; } .handle { position: relative; width: var(--m3e-bottom-sheet-handle-width, 2rem); height: var(--m3e-bottom-sheet-handle-height, 4px); border-radius: var(--m3e-bottom-sheet-handle-shape, ${a.shape.corner.full}); background-color: var(--m3e-bottom-sheet-handle-color, ${a.color.onSurfaceVariant}); } .handle-touch { position: absolute; aspect-ratio: 1 / 1; height: 3rem; left: calc(0px - calc(calc(3rem - var(--m3e-bottom-sheet-handle-width, 2rem)) / 2)); right: calc(0px - calc(calc(3rem - var(--m3e-bottom-sheet-handle-width, 2rem)) / 2)); top: calc( 0px - calc( calc(3rem - var(--m3e-bottom-sheet-handle-container-height, 1.5rem)) - calc( var(--m3e-bottom-sheet-handle-height, 4px) / 2 ) ) ); } @media (prefers-reduced-motion) { :host(:not(:is(:state(--no-animate), :--no-animate))), :host([modal]:not(:is(:state(--no-animate), :--no-animate)))::backdrop, :host([modal]:popover-open:not(:is(:state(--no-animate), :--no-animate)))::backdrop, :host(:not(:is(:state(--no-animate), :--no-animate))) .handle-row { transition: none; } } @media (forced-colors: active) { :host([modal]:not(:is(:state(--no-animate), :--no-animate)))::backdrop, :host([modal]:popover-open:not(:is(:state(--no-animate), :--no-animate)))::backdrop { transition: none; } .base { border-style: solid; border-width: 1px; border-color: CanvasText; } .handle { background-color: ButtonText; } }`;h([b({type:Boolean,reflect:!0})],We.prototype,"modal",void 0);h([b({type:Boolean,reflect:!0})],We.prototype,"open",void 0);h([b({type:Boolean})],We.prototype,"handle",void 0);h([b({attribute:"handle-label"})],We.prototype,"handleLabel",void 0);h([b({attribute:"detents",converter:mh})],We.prototype,"detents",void 0);h([b({type:Number})],We.prototype,"detent",void 0);h([b({type:Boolean,reflect:!0})],We.prototype,"hideable",void 0);h([b({attribute:"hide-friction",type:Number})],We.prototype,"hideFriction",void 0);h([b({attribute:"overshoot-limit",type:Number})],We.prototype,"overshootLimit",void 0);We=aa=h([L("m3e-bottom-sheet")],We);var ns=class extends Xe(Ho){constructor(){super(...arguments),this.secondary=!1}attach(e){e instanceof We&&(super.attach(e),this.parentElement&&(e.modal?this.parentElement.ariaHasPopup="dialog":this.secondary||(this.parentElement.ariaExpanded="false",oa(this.parentElement,"aria-controls",e.id),this.parentElement.id&&oa(e,"aria-labelledby",this.parentElement.id))))}detach(){this.control&&this.parentElement&&!this.secondary&&an(this.parentElement,"aria-controls",this.control.id),super.detach()}_onClick(){this.control instanceof We&&(this.control.modal?this.control.show(this.detent):(this.control.toggle(this.detent),!this.secondary&&this.parentElement&&(this.parentElement.ariaExpanded=`${this.control.open}`)))}};h([b({type:Number})],ns.prototype,"detent",void 0);h([b({type:Boolean})],ns.prototype,"secondary",void 0);ns=h([L("m3e-bottom-sheet-trigger")],ns);var V={"extra-small":{containerHeight:o(`calc(var(--m3e-button-extra-small-container-height, var(--m3e-button-container-height, 2rem)) + ${a.density.calc(-3)})`),outlineThickness:o("var(--m3e-button-extra-small-outline-thickness, var(--m3e-button-outline-thickness, 1px))"),labelTextFontSize:o(`var(--m3e-button-extra-small-label-text-font-size, var(--m3e-button-label-text-font-size, ${a.typescale.standard.label.large.fontSize}))`),labelTextFontWeight:o(`var(--m3e-button-extra-small-label-text-font-weight, var(--m3e-button-label-text-font-weight, ${a.typescale.standard.label.large.fontWeight}))`),labelTextLineHeight:o(`var(--m3e-button-extra-small-label-text-line-height, var(--m3e-button-label-text-line-height, ${a.typescale.standard.label.large.lineHeight}))`),labelTextTracking:o(`var(--m3e-button-extra-small-label-text-tracking, var(--m3e-button-label-text-tracking, ${a.typescale.standard.label.large.tracking}))`),iconSize:o("var(--m3e-button-extra-small-icon-size, var(--m3e-button-icon-size, 1.25rem))"),shapeRound:o(`var(--m3e-button-extra-small-shape-round, var(--m3e-button-shape-round, ${a.shape.corner.full}))`),shapeSquare:o(`var(--m3e-button-extra-small-shape-square, var(--m3e-button-shape-square, ${a.shape.corner.medium}))`),selectedShapeRound:o(`var(--m3e-button-extra-small-selected-shape-round, var(--m3e-button-selected-shape-round, ${a.shape.corner.medium}))`),selectedShapeSquare:o(`var(--m3e-button-extra-small-selected-shape-square, var(--m3e-button-selected-shape-square, ${a.shape.corner.full}))`),shapePressedMorph:o(`var(--m3e-button-extra-small-shape-pressed-morph, var(--m3e-button-shape-pressed-morph, ${a.shape.corner.small}))`),leadingSpace:o("var(--m3e-button-extra-small-leading-space, var(--m3e-button-leading-space, 0.75rem))"),trailingSpace:o("var(--m3e-button-extra-small-trailing-space, var(--m3e-button-trailing-space, 0.75rem))"),iconLabelSpace:o("var(--m3e-button-extra-small-icon-label-space, var(--m3e-button-icon-label-space, 0.5rem))")},small:{containerHeight:o(`calc(var(--m3e-button-small-container-height, var(--m3e-button-container-height, 2.5rem)) + ${a.density.calc(-3)})`),outlineThickness:o("var(--m3e-button-small-outline-thickness, var(--m3e-button-outline-thickness, 1px))"),labelTextFontSize:o(`var(--m3e-button-small-label-text-font-size, var(--m3e-button-label-text-font-size, ${a.typescale.standard.label.large.fontSize}))`),labelTextFontWeight:o(`var(--m3e-button-small-label-text-font-weight, var(--m3e-button-label-text-font-weight, ${a.typescale.standard.label.large.fontWeight}))`),labelTextLineHeight:o(`var(--m3e-button-small-label-text-line-height, var(--m3e-button-label-text-line-height, ${a.typescale.standard.label.large.lineHeight}))`),labelTextTracking:o(`var(--m3e-button-small-label-text-tracking, var(--m3e-button-label-text-tracking, ${a.typescale.standard.label.large.tracking}))`),iconSize:o("var(--m3e-button-small-icon-size, var(--m3e-button-icon-size, 1.25rem))"),shapeRound:o(`var(--m3e-button-small-shape-round, var(--m3e-button-shape-round, ${a.shape.corner.full}))`),shapeSquare:o(`var(--m3e-button-small-shape-square, var(--m3e-button-shape-square, ${a.shape.corner.medium}))`),selectedShapeRound:o(`var(--m3e-button-small-selected-shape-round, var(--m3e-button-selected-shape-round, ${a.shape.corner.medium}))`),selectedShapeSquare:o(`var(--m3e-button-small-selected-shape-square, var(--m3e-button-selected-shape-square, ${a.shape.corner.full}))`),shapePressedMorph:o(`var(--m3e-button-small-shape-pressed-morph, var(--m3e-button-shape-pressed-morph, ${a.shape.corner.small}))`),leadingSpace:o("var(--m3e-button-small-leading-space, var(--m3e-button-leading-space, 1rem))"),trailingSpace:o("var(--m3e-button-small-trailing-space, var(--m3e-button-trailing-space, 1rem))"),iconLabelSpace:o("var(--m3e-button-small-icon-label-space, var(--m3e-button-icon-label-space, 0.5rem))")},medium:{containerHeight:o(`calc(var(--m3e-button-medium-container-height, var(--m3e-button-container-height, 3.5rem)) + ${a.density.calc(-3)})`),outlineThickness:o("var(--m3e-button-medium-outline-thickness, var(--m3e-button-outline-thickness, 1px))"),labelTextFontSize:o(`var(--m3e-button-medium-label-text-font-size, var(--m3e-button-label-text-font-size, ${a.typescale.standard.body.large.fontSize}))`),labelTextFontWeight:o(`var(--m3e-button-medium-label-text-font-weight, var(--m3e-button-label-text-font-weight, ${a.typescale.standard.body.large.fontWeight}))`),labelTextLineHeight:o(`var(--m3e-button-medium-label-text-line-height, var(--m3e-button-label-text-line-height, ${a.typescale.standard.body.large.lineHeight}))`),labelTextTracking:o(`var(--m3e-button-medium-label-text-tracking, var(--m3e-button-label-text-tracking, ${a.typescale.standard.body.large.tracking}))`),iconSize:o("var(--m3e-button-medium-icon-size, var(--m3e-button-icon-size, 1.5rem))"),shapeRound:o(`var(--m3e-button-medium-shape-round, var(--m3e-button-shape-round, ${a.shape.corner.full}))`),shapeSquare:o(`var(--m3e-button-medium-shape-square, var(--m3e-button-shape-square, ${a.shape.corner.large}))`),selectedShapeRound:o(`var(--m3e-button-medium-selected-shape-round, var(--m3e-button-selected-shape-round, ${a.shape.corner.large}))`),selectedShapeSquare:o(`var(--m3e-button-medium-selected-shape-square, var(--m3e-button-selected-shape-square, ${a.shape.corner.full}))`),shapePressedMorph:o(`var(--m3e-button-medium-shape-pressed-morph, var(--m3e-button-shape-pressed-morph, ${a.shape.corner.medium}))`),leadingSpace:o("var(--m3e-button-medium-leading-space, var(--m3e-button-leading-space, 1.5rem))"),trailingSpace:o("var(--m3e-button-medium-trailing-space, var(--m3e-button-trailing-space, 1.5rem))"),iconLabelSpace:o("var(--m3e-button-medium-icon-label-space, var(--m3e-button-icon-label-space, 0.5rem))")},large:{containerHeight:o(`calc(var(--m3e-button-large-container-height, var(--m3e-button-container-height, 6rem)) + ${a.density.calc(-3)})`),outlineThickness:o("var(--m3e-button-large-outline-thickness, var(--m3e-button-outline-thickness, 2px))"),labelTextFontSize:o(`var(--m3e-button-large-label-text-font-size, var(--m3e-button-label-text-font-size, ${a.typescale.standard.headline.small.fontSize}))`),labelTextFontWeight:o(`var(--m3e-button-large-label-text-font-weight, var(--m3e-button-label-text-font-weight, ${a.typescale.standard.headline.small.fontWeight}))`),labelTextLineHeight:o(`var(--m3e-button-large-label-text-line-height, var(--m3e-button-label-text-line-height, ${a.typescale.standard.headline.small.lineHeight}))`),labelTextTracking:o(`var(--m3e-button-large-label-text-tracking, var(--m3e-button-label-text-tracking, ${a.typescale.standard.headline.small.tracking}))`),iconSize:o("var(--m3e-button-large-icon-size, var(--m3e-button-icon-size, 2rem))"),shapeRound:o(`var(--m3e-button-large-shape-round, var(--m3e-button-shape-round, ${a.shape.corner.full}))`),shapeSquare:o(`var(--m3e-button-large-shape-square, var(--m3e-button-shape-square, ${a.shape.corner.extraLarge}))`),selectedShapeRound:o(`var(--m3e-button-large-selected-shape-round, var(--m3e-button-selected-shape-round, ${a.shape.corner.extraLarge}))`),selectedShapeSquare:o(`var(--m3e-button-large-selected-shape-square, var(--m3e-button-selected-shape-square, ${a.shape.corner.full}))`),shapePressedMorph:o(`var(--m3e-button-large-shape-pressed-morph, var(--m3e-button-shape-pressed-morph, ${a.shape.corner.large}))`),leadingSpace:o("var(--m3e-button-large-leading-space, var(--m3e-button-leading-space, 3rem))"),trailingSpace:o("var(--m3e-button-large-trailing-space, var(--m3e-button-trailing-space, 3rem))"),iconLabelSpace:o("var(--m3e-button-large-icon-label-space, var(--m3e-button-icon-label-space, 0.75rem))")},"extra-large":{containerHeight:o(`calc(var(--m3e-button-extra-large-container-height, var(--m3e-button-container-height, 8.5rem)) + ${a.density.calc(-3)})`),outlineThickness:o("var(--m3e-button-extra-large-outline-thickness, var(--m3e-button-outline-thickness, 3px))"),labelTextFontSize:o(`var(--m3e-button-extra-large-label-text-font-size, var(--m3e-button-label-text-font-size, ${a.typescale.standard.headline.large.fontSize}))`),labelTextFontWeight:o(`var(--m3e-button-extra-large-label-text-font-weight, var(--m3e-button-label-text-font-weight, ${a.typescale.standard.headline.large.fontWeight}))`),labelTextLineHeight:o(`var(--m3e-button-extra-large-label-text-line-height, var(--m3e-button-label-text-line-height, ${a.typescale.standard.headline.large.lineHeight}))`),labelTextTracking:o(`var(--m3e-button-extra-large-label-text-tracking, var(--m3e-button-label-text-tracking, ${a.typescale.standard.headline.large.tracking}))`),iconSize:o("var(--m3e-button-extra-large-icon-size, var(--m3e-button-icon-size, 2.5rem))"),shapeRound:o(`var(--m3e-button-extra-large-shape-round, var(--m3e-button-shape-round, ${a.shape.corner.full}))`),shapeSquare:o(`var(--m3e-button-extra-large-shape-square, var(--m3e-button-shape-square, ${a.shape.corner.extraLarge}))`),selectedShapeRound:o(`var(--m3e-button-extra-large-selected-shape-round, var(--m3e-button-selected-shape-round, ${a.shape.corner.extraLarge}))`),selectedShapeSquare:o(`var(--m3e-button-extra-large-selected-shape-square, var(--m3e-button-selected-shape-square, ${a.shape.corner.full}))`),shapePressedMorph:o(`var(--m3e-button-extra-large-shape-pressed-morph, var(--m3e-button-shape-pressed-morph, ${a.shape.corner.large}))`),leadingSpace:o("var(--m3e-button-extra-large-leading-space, var(--m3e-button-leading-space, 4rem))"),trailingSpace:o("var(--m3e-button-extra-large-trailing-space, var(--m3e-button-trailing-space, 4rem))"),iconLabelSpace:o("var(--m3e-button-extra-large-icon-label-space, var(--m3e-button-icon-label-space, 1rem))")}};function sn(t){return C`:host([size="${o(t)}"]) .base { height: ${V[t].containerHeight}; } :host([size="${o(t)}"]) .wrapper { padding-inline-start: calc(${V[t].leadingSpace} - calc(var(--_adjacent-shrink, 0px) / 2)); padding-inline-end: calc(${V[t].trailingSpace} - calc(var(--_adjacent-shrink, 0px) / 2)); column-gap: ${V[t].iconLabelSpace}; } :host([size="${o(t)}"]) .label { font-size: ${V[t].labelTextFontSize}; font-weight: ${V[t].labelTextFontWeight}; line-height: ${V[t].labelTextLineHeight}; letter-spacing: ${V[t].labelTextTracking}; } :host([size="${o(t)}"]) .icon { font-size: ${V[t].iconSize}; --m3e-icon-size: ${V[t].iconSize}; } :host([size="${o(t)}"]) .base { outline-offset: calc(0px - ${V[t].outlineThickness}); outline-width: ${V[t].outlineThickness}; } :host(:not(:is(:state(--connected), :--connected))[size="${o(t)}"][shape="rounded"]) .base { border-radius: var(--_button-shape, ${V[t].shapeRound}); } :host( :is(:state(--connected), :--connected)[size="${o(t)}"][shape="rounded"][toggle][selected]:not( :is(:state(--pressed), :--pressed) ) ) .base { border-radius: var(--_button-shape, ${V[t].shapeRound}); } :host( :not(:is(:state(--connected), :--connected))[size="${o(t)}"][shape="rounded"][toggle][selected]:not( :is(:state(--pressed), :--pressed) ) ) .base { border-radius: ${V[t].selectedShapeRound}; } :host(:not(:is(:state(--connected), :--connected))[size="${o(t)}"][shape="square"]) .base { border-radius: ${V[t].shapeSquare}; } :host( :not(:is(:state(--connected), :--connected))[size="${o(t)}"][shape="square"][toggle][selected]:not( :is(:state(--pressed), :--pressed) ) ) .base { border-radius: var(--_button-shape, ${V[t].selectedShapeSquare}); } :host(:not(:is(:state(--connected), :--connected))[size="${o(t)}"]:is(:state(--pressed), :--pressed)) .base { border-radius: ${V[t].shapePressedMorph}; } :host(:is(:state(--connected), :--connected)[size="${o(t)}"][shape="rounded"]:not([toggle][selected])) .base { border-start-start-radius: var( --_button-rounded-start-shape, var(--_button-shape, ${V[t].shapeRound}) ); border-end-start-radius: var( --_button-rounded-start-shape, var(--_button-shape, ${V[t].shapeRound}) ); border-start-end-radius: var( --_button-rounded-end-shape, var(--_button-shape, ${V[t].shapeRound}) ); border-end-end-radius: var( --_button-rounded-end-shape, var(--_button-shape, ${V[t].shapeRound}) ); } :host(:is(:state(--connected), :--connected)[size="${o(t)}"][shape="square"]) .base { border-start-start-radius: var(--_button-square-start-shape, ${V[t].shapeSquare}); border-end-start-radius: var(--_button-square-start-shape, ${V[t].shapeSquare}); border-start-end-radius: var(--_button-square-end-shape, ${V[t].shapeSquare}); border-end-end-radius: var(--_button-square-end-shape, ${V[t].shapeSquare}); } :host( :is(:state(--connected), :--connected)[size="${o(t)}"][shape="square"][toggle][selected]:not( :is(:state(--pressed), :--pressed) ) ) .base { border-radius: var(--_button-shape, ${V[t].selectedShapeSquare}); } :host(:is(:state(--connected), :--connected)[size="${o(t)}"]:is(:state(--pressed), :--pressed)) .base { border-start-start-radius: var(--_button-start-shape-pressed-morph, ${V[t].shapePressedMorph}); border-end-start-radius: var(--_button-start-shape-pressed-morph, ${V[t].shapePressedMorph}); border-start-end-radius: var(--_button-end-shape-pressed-morph, ${V[t].shapePressedMorph}); border-end-end-radius: var(--_button-end-shape-pressed-morph, ${V[t].shapePressedMorph}); }`}var eb=[sn("extra-small"),sn("small"),sn("medium"),sn("large"),sn("extra-large")],tb=C`:host { display: inline-block; outline: none; user-select: none; -webkit-tap-highlight-color: rgba(0, 0, 0, 0); } .base { box-sizing: border-box; vertical-align: middle; display: inline-flex; align-items: center; justify-content: center; position: relative; width: 100%; transition: ${o(`background-color ${a.motion.duration.short4} ${a.motion.easing.standard}`)}; } .touch { position: absolute; height: 3rem; left: 0; right: 0; } :host(:is(:state(--pressed), :--pressed)) .base, :host(:is(:state(--resting), :--resting)) .base { transition: ${o(`background-color ${a.motion.duration.short4} ${a.motion.easing.standard},
          border-radius ${a.motion.spring.fastEffects}`)}; } .wrapper { width: 100%; overflow: hidden; display: inline-flex; align-items: center; justify-content: center; } .label { white-space: nowrap; overflow: hidden; text-overflow: ellipsis; transition: ${o(`color ${a.motion.duration.short4} ${a.motion.easing.standard}`)}; } .icon { transition: ${o(`color ${a.motion.duration.short4} ${a.motion.easing.standard}`)}; } :host(:not(:disabled):not([disabled-interactive])) { cursor: pointer; } :host([disabled-interactive]) { cursor: not-allowed; } ::slotted([slot="icon"]), ::slotted([slot="selected-icon"]), ::slotted([slot="trailing-icon"]) { font-size: inherit !important; flex: none; } ::slotted(svg[slot="icon"]), ::slotted(svg[slot="selected-icon"]), ::slotted(svg[slot="trailing-icon"]) { width: 1em; height: 1em; } :host([toggle]:not([selected])) .base.with-selected-icon slot[name="selected-icon"], :host([toggle][selected]) .base.with-selected-icon slot[name="icon"] { display: none; } a { all: unset; display: block; position: absolute; top: 0px; left: 0px; right: 0px; bottom: 0px; z-index: 1; } :host(:is(:state(--grouped), :--grouped):is(:state(--connected), :--connected)) { flex: 1 1 auto; } :host(:is(:state(--grouped), :--grouped):not(:is(:state(--connected), :--connected))) { transition: ${o(`width ${a.motion.spring.fastEffects}`)}; } :host(:is(:state(--grouped), :--grouped):not(:is(:state(--connected), :--connected))) .wrapper { transition: ${o(`padding-inline ${a.motion.spring.fastEffects}`)}; } :host(:is(:state(--grouped), :--grouped):not(:is(:state(--connected), :--connected))) { flex-shrink: 0; flex-grow: 0; } :host( :is(:state(--grouped), :--grouped):not(:is(:state(--connected), :--connected)):not( :is(:state(--pressed), :--pressed, :state(--adjacent-pressed), :--adjacent-pressed) ) ) { width: var(--_button-width); } :host( :is(:state(--grouped), :--grouped):not(:is(:state(--connected), :--connected)):not( :is(:state(--pressed), :--pressed) ):is(:state(--adjacent-pressed), :--adjacent-pressed) ) { width: calc(var(--_button-width) - var(--_adjacent-shrink, 0px)); } :host( :is(:state(--grouped), :--grouped):not(:is(:state(--connected), :--connected)):is( :state(--pressed), :--pressed ):not([disabled-interactive]):not(:disabled) ) { width: calc( var(--_button-width) + calc(var(--_button-width) * var(--m3e-standard-button-group-width-multiplier, 0.15)) ); } :host( :is(:state(--grouped), :--grouped):not(:is(:state(--connected), :--connected)):is( :state(--adjacent-pressed), :--adjacent-pressed ):not(:is(:state(--pressed), :--pressed)) ) .label { text-overflow: clip; } @media (forced-colors: active) { .base, .label, .icon { transition: none; } :host(:is(:state(--pressed), :--pressed)) .base, :host(:is(:state(--resting), :--resting)) .base { transition: ${o(`border-radius ${a.motion.spring.fastEffects}`)}; } :host([variant]:not(:disabled):not([disabled-interactive]):not([toggle])) .base { background-color: ButtonFace; outline-color: ButtonText; } :host([variant]:not(:disabled):not([disabled-interactive]):not([toggle])) .label, :host([variant]:not(:disabled):not([disabled-interactive]):not([toggle])) .icon { color: ButtonText; } :host([variant]:not(:disabled):not([disabled-interactive])[toggle]:not([selected])) .base { background-color: ButtonFace; outline-color: ButtonText; } :host([variant]:not(:disabled):not([disabled-interactive])[toggle]:not([selected])) .label, :host([variant]:hover:not(:disabled):not([disabled-interactive])[toggle]:not([selected])) .label, :host([variant]:not(:disabled):not([disabled-interactive])[toggle]:not([selected]):focus) .label, :host([variant]:not(:disabled):not([disabled-interactive])[toggle]:not([selected])) .icon, :host([variant]:hover:not(:disabled):not([disabled-interactive])[toggle]:not([selected])) .icon, :host([variant]:not(:disabled):not([disabled-interactive])[toggle]:not([selected]):focus) .icon { color: ButtonText; } :host([variant]:not(:disabled):not([disabled-interactive])[toggle][selected]) .base { background-color: ButtonText; outline: none; } :host([variant]:not(:disabled):not([disabled-interactive])[toggle][selected]) .label, :host([variant]:hover:not(:disabled):not([disabled-interactive])[toggle][selected]) .label, :host([variant]:not(:disabled):not([disabled-interactive])[toggle][selected]:focus) .label, :host([variant]:not(:disabled):not([disabled-interactive])[toggle][selected]) .icon, :host([variant]:hover:not(:disabled):not([disabled-interactive])[toggle][selected]) .icon, :host([variant]:not(:disabled):not([disabled-interactive])[toggle][selected]:focus) .icon { forced-color-adjust: none; color: ButtonFace; background-color: ButtonText; } :host([variant]:disabled) .base, :host([variant][disabled-interactive]) .base { outline-color: GrayText; background-color: unset; } :host([variant]:disabled) .label, :host([variant][disabled-interactive]) .label, :host([variant]:disabled) .icon, :host([variant][disabled-interactive]) .icon { color: GrayText; } .base { outline-style: solid; } :host([size="extra-small"]) .base { outline-offset: calc(0px - var(--m3e-button-extra-small-outline-thickness, 1px)); outline-width: var(--m3e-button-extra-small-outline-thickness, 1px); } :host([size="small"]) .base { outline-offset: calc(0px - var(--m3e-button-small-outline-thickness, 1px)); outline-width: var(--m3e-button-small-outline-thickness, 1px); } :host([size="medium"]) .base { outline-offset: calc(0px - var(--m3e-button-medium-outline-thickness, 1px)); outline-width: var(--m3e-button-medium-outline-thickness, 1px); } :host([size="large"]) .base { outline-offset: calc(0px - var(--m3e-button-large-outline-thickness, 2px)); outline-width: var(--m3e-button-large-outline-thickness, 2px); } :host([size="extra-large"]) .base { outline-offset: calc(0px - var(--m3e-button-extra-large-outline-thickness, 3px)); outline-width: var(--m3e-button-extra-large-outline-thickness, 3px); } } @media (prefers-reduced-motion) { :host(:is(:state(--grouped), :--grouped):not(:is(:state(--connected), :--connected))), :host(:is(:state(--grouped), :--grouped):not(:is(:state(--connected), :--connected))) .wrapper, :host(:is(:state(--pressed), :--pressed)) .base, :host(:is(:state(--resting), :--resting)) .base, .base, .label, .icon { transition: none; } }`,A={elevated:{labelTextColor:o(`var(--m3e-elevated-button-label-text-color, var(--m3e-button-label-text-color, ${a.color.primary}))`),iconColor:o(`var(--m3e-elevated-button-icon-color, var(--m3e-button-icon-color, ${a.color.primary}))`),containerColor:o(`var(--m3e-elevated-button-container-color, var(--m3e-button-container-color, ${a.color.surfaceContainerLow}))`),containerElevation:o(`var(--m3e-elevated-button-container-elevation, var(--m3e-button-container-elevation, ${a.elevation.level1}))`),unselectedLabelTextColor:o(`var(--m3e-elevated-button-unselected-label-text-color, var(--m3e-button-unselected-label-text-color, ${a.color.primary}))`),unselectedIconColor:o(`var(--m3e-elevated-button-unselected-icon-color, var(--m3e-button-unselected-icon-color, ${a.color.primary}))`),unselectedContainerColor:o(`var(--m3e-elevated-button-unselected-container-color, var(--m3e-button-unselected-container-color, ${a.color.surfaceContainerLow}))`),selectedLabelTextColor:o(`var(--m3e-elevated-button-selected-label-text-color, var(--m3e-button-selected-label-text-color, ${a.color.onPrimary}))`),selectedIconColor:o(`var(--m3e-elevated-button-selected-icon-color, var(--m3e-button-selected-icon-color, ${a.color.onPrimary}))`),selectedContainerColor:o(`var(--m3e-elevated-button-selected-container-color, var(--m3e-button-selected-container-color, ${a.color.primary}))`),disabled:{containerColor:o(`var(--m3e-elevated-button-disabled-container-color, var(--m3e-button-disabled-container-color, ${a.color.onSurface}))`),containerOpacity:o("var(--m3e-elevated-button-disabled-container-opacity, var(--m3e-button-disabled-container-opacity, 10%))"),iconColor:o(`var(--m3e-elevated-button-disabled-icon-color, var(--m3e-button-disabled-icon-color, ${a.color.onSurface}))`),iconOpacity:o("var(--m3e-elevated-button-disabled-icon-opacity, var(--m3e-button-disabled-icon-opacity, 38%))"),labelTextColor:o(`var(--m3e-elevated-button-disabled-label-text-color, var(--m3e-button-disabled-label-text-color, ${a.color.onSurface}))`),labelTextOpacity:o("var(--m3e-elevated-button-disabled-label-text-opacity, var(--m3e-button-disabled-label-text-opacity, 38%))"),containerElevation:o(`var(--m3e-elevated-button-disabled-container-elevation, var(--m3e-button-disabled-container-elevation, ${a.elevation.level0}))`)},hover:{iconColor:o(`var(--m3e-elevated-button-hover-icon-color, var(--m3e-button-hover-icon-color, ${a.color.primary}))`),labelTextColor:o(`var(--m3e-elevated-button-hover-label-text-color, var(--m3e-button-hover-label-text-color, ${a.color.primary}))`),stateLayerColor:o(`var(--m3e-elevated-button-hover-state-layer-color, var(--m3e-button-hover-state-layer-color, ${a.color.primary}))`),stateLayerOpacity:o(`var(--m3e-elevated-button-hover-state-layer-opacity, var(--m3e-button-hover-state-layer-opacity, ${a.state.hoverStateLayerOpacity}))`),containerElevation:o(`var(--m3e-elevated-button-hover-container-elevation, var(--m3e-button-hover-container-elevation, ${a.elevation.level2}))`),unselectedIconColor:o(`var(--m3e-elevated-button-hover-unselected-icon-color, var(--m3e-button-hover-unselected-icon-color, ${a.color.primary}))`),unselectedLabelTextColor:o(`var(--m3e-elevated-button-hover-unselected-label-text-color, var(--m3e-button-hover-unselected-label-text-color, ${a.color.primary}))`),unselectedStateLayerColor:o(`var(--m3e-elevated-button-hover-unselected-state-layer-color, var(--m3e-button-hover-unselected-state-layer-color, ${a.color.primary}))`),selectedIconColor:o(`var(--m3e-elevated-button-hover-selected-icon-color, var(--m3e-button-hover-selected-icon-color, ${a.color.onPrimary}))`),selectedLabelTextColor:o(`var(--m3e-elevated-button-hover-selected-label-text-color, var(--m3e-button-hover-selected-label-text-color, ${a.color.onPrimary}))`),selectedStateLayerColor:o(`var(--m3e-elevated-button-hover-selected-state-layer-color, var(--m3e-button-hover-selected-state-layer-color, ${a.color.onPrimary}))`)},focus:{iconColor:o(`var(--m3e-elevated-button-focus-icon-color, var(--m3e-button-focus-icon-color, ${a.color.primary}))`),labelTextColor:o(`var(--m3e-elevated-button-focus-label-text-color, var(--m3e-button-focus-label-text-color, ${a.color.primary}))`),stateLayerColor:o(`var(--m3e-elevated-button-focus-state-layer-color, var(--m3e-button-focus-state-layer-color, ${a.color.primary}))`),stateLayerOpacity:o(`var(--m3e-elevated-button-focus-state-layer-opacity, var(--m3e-button-focus-state-layer-opacity, ${a.state.focusStateLayerOpacity}))`),containerElevation:o(`var(--m3e-elevated-button-focus-container-elevation, var(--m3e-button-focus-container-elevation, ${a.elevation.level1}))`),unselectedLabelTextColor:o(`var(--m3e-elevated-button-focus-unselected-label-text-color, var(--m3e-button-focus-unselected-label-text-color, ${a.color.primary}))`),unselectedIconColor:o(`var(--m3e-elevated-button-focus-unselected-icon-color, var(--m3e-button-focus-unselected-icon-color, ${a.color.primary}))`),unselectedStateLayerColor:o(`var(--m3e-elevated-button-focus-unselected-state-layer-color, var(--m3e-button-focus-unselected-state-layer-color, ${a.color.primary}))`),selectedIconColor:o(`var(--m3e-elevated-button-focus-selected-icon-color, var(--m3e-button-focus-selected-icon-color, ${a.color.onPrimary}))`),selectedLabelTextColor:o(`var(--m3e-elevated-button-focus-selected-label-text-color, var(--m3e-button-focus-selected-label-text-color, ${a.color.onPrimary}))`),selectedStateLayerColor:o(`var(--m3e-elevated-button-focus-selected-state-layer-color, var(--m3e-button-focus-selected-state-layer-color, ${a.color.onPrimary}))`)},pressed:{iconColor:o(`var(--m3e-elevated-button-pressed-icon-color, var(--m3e-button-pressed-icon-color, ${a.color.primary}))`),labelTextColor:o(`var(--m3e-elevated-button-pressed-label-text-color, var(--m3e-button-pressed-label-text-color, ${a.color.primary}))`),stateLayerColor:o(`var(--m3e-elevated-button-pressed-state-layer-color, var(--m3e-button-pressed-state-layer-color, ${a.color.primary}))`),stateLayerOpacity:o(`var(--m3e-elevated-button-pressed-state-layer-opacity, var(--m3e-button-pressed-state-layer-opacity, ${a.state.pressedStateLayerOpacity}))`),containerElevation:o(`var(--m3e-elevated-button-pressed-container-elevation, var(--m3e-button-pressed-container-elevation, ${a.elevation.level1}))`),unselectedLabelTextColor:o(`var(--m3e-elevated-button-pressed-unselected-label-text-color, var(--m3e-button-pressed-unselected-label-text-color, ${a.color.primary}))`),unselectedIconColor:o(`var(--m3e-elevated-button-pressed-unselected-icon-color, var(--m3e-button-pressed-unselected-icon-color, ${a.color.primary}))`),unselectedStateLayerColor:o(`var(--m3e-elevated-button-pressed-unselected-state-layer-color, var(--m3e-button-pressed-unselected-state-layer-color, ${a.color.primary}))`),selectedIconColor:o(`var(--m3e-elevated-button-pressed-selected-icon-color, var(--m3e-button-pressed-selected-icon-color, ${a.color.onPrimary}))`),selectedLabelTextColor:o(`var(--m3e-elevated-button-pressed-selected-label-text-color, var(--m3e-button-pressed-selected-label-text-color, ${a.color.onPrimary}))`),selectedStateLayerColor:o(`var(--m3e-elevated-button-pressed-selected-state-layer-color, var(--m3e-button-pressed-selected-state-layer-color, ${a.color.onPrimary}))`)}},outlined:{labelTextColor:o(`var(--m3e-outlined-button-label-text-color, var(--m3e-button-label-text-color, ${a.color.onSurfaceVariant}))`),iconColor:o(`var(--m3e-outlined-button-icon-color, var(--m3e-button-icon-color, ${a.color.onSurfaceVariant}))`),outlineColor:o(`var(--m3e-outlined-button-outline-color, var(--m3e-button-outline-color, ${a.color.outlineVariant}))`),unselectedLabelTextColor:o(`var(--m3e-outlined-button-unselected-label-text-color, var(--m3e-button-unselected-label-text-color, ${a.color.onSurfaceVariant}))`),unselectedIconColor:o(`var(--m3e-outlined-button-unselected-icon-color, var(--m3e-button-unselected-icon-color, ${a.color.onSurfaceVariant}))`),selectedLabelTextColor:o(`var(--m3e-outlined-button-selected-label-text-color, var(--m3e-button-selected-label-text-color, ${a.color.inverseOnSurface}))`),selectedIconColor:o(`var(--m3e-outlined-button-selected-icon-color, var(--m3e-button-selected-icon-color, ${a.color.inverseOnSurface}))`),selectedContainerColor:o(`var(--m3e-outlined-button-selected-container-color, var(--m3e-button-selected-container-color, ${a.color.inverseSurface}))`),disabled:{containerColor:o(`var(--m3e-outlined-button-disabled-container-color, var(--m3e-button-disabled-container-color, ${a.color.onSurface}))`),containerOpacity:o("var(--m3e-outlined-button-disabled-container-opacity, var(--m3e-button-disabled-container-opacity, 10%))"),iconColor:o(`var(--m3e-outlined-button-disabled-icon-color, var(--m3e-button-disabled-icon-color, ${a.color.onSurface}))`),iconOpacity:o("var(--m3e-outlined-button-disabled-icon-opacity, var(--m3e-button-disabled-icon-opacity, 38%))"),labelTextColor:o(`var(--m3e-outlined-button-disabled-label-text-color, var(--m3e-button-disabled-label-text-color, ${a.color.onSurface}))`),labelTextOpacity:o("var(--m3e-outlined-button-disabled-label-text-opacity, var(--m3e-button-disabled-label-text-opacity, 38%))"),outlineColor:o(`var(--m3e-outlined-button-disabled-outline-color, var(--m3e-button-disabled-outline-color, ${a.color.outlineVariant}))`)},hover:{iconColor:o(`var(--m3e-outlined-button-hover-icon-color, var(--m3e-button-hover-icon-color, ${a.color.onSurfaceVariant}))`),labelTextColor:o(`var(--m3e-outlined-button-hover-label-text-color, var(--m3e-button-hover-label-text-color, ${a.color.onSurfaceVariant}))`),outlineColor:o(`var(--m3e-outlined-button-hover-outline-color, var(--m3e-button-hover-outline-color, ${a.color.outlineVariant}))`),stateLayerColor:o(`var(--m3e-outlined-button-hover-state-layer-color, var(--m3e-button-hover-state-layer-color, ${a.color.onSurfaceVariant}))`),stateLayerOpacity:o(`var(--m3e-outlined-button-hover-state-layer-opacity, var(--m3e-button-hover-state-layer-opacity, ${a.state.hoverStateLayerOpacity}))`),unselectedIconColor:o(`var(--m3e-outlined-button-hover-unselected-icon-color, var(--m3e-button-hover-unselected-icon-color, ${a.color.onSurfaceVariant}))`),unselectedLabelTextColor:o(`var(--m3e-outlined-button-hover-unselected-label-text-color, var(--m3e-button-hover-unselected-label-text-color, ${a.color.onSurfaceVariant}))`),unselectedStateLayerColor:o(`var(--m3e-outlined-button-hover-unselected-state-layer-color, var(--m3e-button-hover-unselected-state-layer-color, ${a.color.onSurfaceVariant}))`),selectedIconColor:o(`var(--m3e-outlined-button-hover-selected-icon-color, var(--m3e-button-hover-selected-icon-color, ${a.color.inverseOnSurface}))`),selectedLabelTextColor:o(`var(--m3e-outlined-button-hover-selected-label-text-color, var(--m3e-button-hover-selected-label-text-color, ${a.color.inverseOnSurface}))`),selectedStateLayerColor:o(`var(--m3e-outlined-button-hover-selected-state-layer-color, var(--m3e-button-hover-selected-state-layer-color, ${a.color.inverseOnSurface}))`)},focus:{iconColor:o(`var(--m3e-outlined-button-focus-icon-color, var(--m3e-button-focus-icon-color, ${a.color.onSurfaceVariant}))`),labelTextColor:o(`var(--m3e-outlined-button-focus-label-text-color, var(--m3e-button-focus-label-text-color, ${a.color.onSurfaceVariant}))`),outlineColor:o(`var(--m3e-outlined-button-focus-outline-color, var(--m3e-button-focus-outline-color, ${a.color.outlineVariant}))`),stateLayerColor:o(`var(--m3e-outlined-button-focus-state-layer-color, var(--m3e-button-focus-state-layer-color, ${a.color.onSurfaceVariant}))`),stateLayerOpacity:o(`var(--m3e-outlined-button-focus-state-layer-opacity, var(--m3e-button-focus-state-layer-opacity, ${a.state.focusStateLayerOpacity}))`),unselectedIconColor:o(`var(--m3e-outlined-button-focus-unselected-icon-color, var(--m3e-button-focus-unselected-icon-color, ${a.color.onSurfaceVariant}))`),unselectedLabelTextColor:o(`var(--m3e-outlined-button-focus-unselected-label-text-color, var(--m3e-button-focus-unselected-label-text-color, ${a.color.onSurfaceVariant}))`),unselectedStateLayerColor:o(`var(--m3e-outlined-button-focus-unselected-state-layer-color, var(--m3e-button-focus-unselected-state-layer-color, ${a.color.onSurfaceVariant}))`),selectedIconColor:o(`var(--m3e-outlined-button-focus-selected-icon-color, var(--m3e-button-focus-selected-icon-color, ${a.color.inverseOnSurface}))`),selectedLabelTextColor:o(`var(--m3e-outlined-button-focus-selected-label-text-color, var(--m3e-button-focus-selected-label-text-color, ${a.color.inverseOnSurface}))`),selectedStateLayerColor:o(`var(--m3e-outlined-button-focus-selected-state-layer-color, var(--m3e-button-focus-selected-state-layer-color, ${a.color.inverseOnSurface}))`)},pressed:{iconColor:o(`var(--m3e-outlined-button-pressed-icon-color, var(--m3e-button-pressed-icon-color, ${a.color.onSurfaceVariant}))`),labelTextColor:o(`var(--m3e-outlined-button-pressed-label-text-color, var(--m3e-button-pressed-label-text-color, ${a.color.onSurfaceVariant}))`),outlineColor:o(`var(--m3e-outlined-button-pressed-outline-color, var(--m3e-button-pressed-outline-color, ${a.color.outlineVariant}))`),stateLayerColor:o(`var(--m3e-outlined-button-pressed-state-layer-color, var(--m3e-button-pressed-state-layer-color, ${a.color.onSurfaceVariant}))`),stateLayerOpacity:o(`var(--m3e-outlined-button-pressed-state-layer-opacity, var(--m3e-button-pressed-state-layer-opacity, ${a.state.pressedStateLayerOpacity}))`),unselectedIconColor:o(`var(--m3e-outlined-button-pressed-unselected-icon-color, var(--m3e-button-pressed-unselected-icon-color, ${a.color.onSurfaceVariant}))`),unselectedLabelTextColor:o(`var(--m3e-outlined-button-pressed-unselected-label-text-color, var(--m3e-button-pressed-unselected-label-text-color, ${a.color.onSurfaceVariant}))`),unselectedStateLayerColor:o(`var(--m3e-outlined-button-pressed-unselected-state-layer-color, var(--m3e-button-pressed-unselected-state-layer-color, ${a.color.onSurfaceVariant}))`),selectedIconColor:o(`var(--m3e-outlined-button-pressed-selected-icon-color, var(--m3e-button-pressed-selected-icon-color, ${a.color.inverseOnSurface}))`),selectedLabelTextColor:o(`var(--m3e-outlined-button-pressed-selected-label-text-color, var(--m3e-button-pressed-selected-label-text-color, ${a.color.inverseOnSurface}))`),selectedStateLayerColor:o(`var(--m3e-outlined-button-pressed-selected-state-layer-color, var(--m3e-button-pressed-selected-state-layer-color, ${a.color.inverseOnSurface}))`)}},filled:{labelTextColor:o(`var(--m3e-filled-button-label-text-color, var(--m3e-button-label-text-color, ${a.color.onPrimary}))`),iconColor:o(`var(--m3e-filled-button-icon-color, var(--m3e-button-icon-color, ${a.color.onPrimary}))`),containerColor:o(`var(--m3e-filled-button-container-color, var(--m3e-button-container-color, ${a.color.primary}))`),containerElevation:o(`var(--m3e-filled-button-container-elevation, var(--m3e-button-container-elevation, ${a.elevation.level0}))`),unselectedLabelTextColor:o(`var(--m3e-filled-button-unselected-label-text-color, var(--m3e-button-unselected-label-text-color, ${a.color.onSurfaceVariant}))`),unselectedIconColor:o(`var(--m3e-filled-button-unselected-icon-color, var(--m3e-button-unselected-icon-color, ${a.color.onSurfaceVariant}))`),unselectedContainerColor:o(`var(--m3e-filled-button-unselected-container-color, var(--m3e-button-unselected-container-color, ${a.color.surfaceContainer}))`),selectedLabelTextColor:o(`var(--m3e-filled-button-selected-label-text-color, var(--m3e-button-selected-label-text-color, ${a.color.onPrimary}))`),selectedIconColor:o(`var(--m3e-filled-button-selected-icon-color, var(--m3e-button-selected-icon-color, ${a.color.onPrimary}))`),selectedContainerColor:o(`var(--m3e-filled-button-selected-container-color, var(--m3e-button-selected-container-color, ${a.color.primary}))`),disabled:{containerColor:o(`var(--m3e-filled-button-disabled-container-color, var(--m3e-button-disabled-container-color, ${a.color.onSurface}))`),containerOpacity:o("var(--m3e-filled-button-disabled-container-opacity, var(--m3e-button-disabled-container-opacity, 10%))"),iconColor:o(`var(--m3e-filled-button-disabled-icon-color, var(--m3e-button-disabled-icon-color, ${a.color.onSurface}))`),iconOpacity:o("var(--m3e-filled-button-disabled-icon-opacity, var(--m3e-button-disabled-icon-opacity, 38%))"),labelTextColor:o(`var(--m3e-filled-button-disabled-label-text-color, var(--m3e-button-disabled-label-text-color, ${a.color.onSurface}))`),labelTextOpacity:o("var(--m3e-filled-button-disabled-label-text-opacity, var(--m3e-button-disabled-label-text-opacity, 38%))"),containerElevation:o(`var(--m3e-filled-button-disabled-container-elevation, var(--m3e-button-disabled-container-elevation, ${a.elevation.level0}))`)},hover:{iconColor:o(`var(--m3e-filled-button-hover-icon-color, var(--m3e-button-hover-icon-color, ${a.color.onPrimary}))`),labelTextColor:o(`var(--m3e-filled-button-hover-label-text-color, var(--m3e-button-hover-label-text-color, ${a.color.onPrimary}))`),stateLayerColor:o(`var(--m3e-filled-button-hover-state-layer-color, var(--m3e-button-hover-state-layer-color, ${a.color.onPrimary}))`),stateLayerOpacity:o(`var(--m3e-filled-button-hover-state-layer-opacity, var(--m3e-button-hover-state-layer-opacity, ${a.state.hoverStateLayerOpacity}))`),containerElevation:o(`var(--m3e-filled-button-hover-container-elevation, var(--m3e-button-hover-container-elevation, ${a.elevation.level1}))`),unselectedIconColor:o(`var(--m3e-filled-button-hover-unselected-icon-color, var(--m3e-button-hover-unselected-icon-color, ${a.color.onSurfaceVariant}))`),unselectedLabelTextColor:o(`var(--m3e-filled-button-hover-unselected-label-text-color, var(--m3e-button-hover-unselected-label-text-color, ${a.color.onSurfaceVariant}))`),unselectedStateLayerColor:o(`var(--m3e-filled-button-hover-unselected-state-layer-color, var(--m3e-button-hover-unselected-state-layer-color, ${a.color.onSurfaceVariant}))`),selectedIconColor:o(`var(--m3e-filled-button-hover-selected-icon-color, var(--m3e-button-hover-selected-icon-color, ${a.color.onPrimary}))`),selectedLabelTextColor:o(`var(--m3e-filled-button-hover-selected-label-text-color, var(--m3e-button-hover-selected-label-text-color, ${a.color.onPrimary}))`),selectedStateLayerColor:o(`var(--m3e-filled-button-hover-selected-state-layer-color, var(--m3e-button-hover-selected-state-layer-color, ${a.color.onPrimary}))`)},focus:{iconColor:o(`var(--m3e-filled-button-focus-icon-color, var(--m3e-button-focus-icon-color, ${a.color.onPrimary}))`),labelTextColor:o(`var(--m3e-filled-button-focus-label-text-color, var(--m3e-button-focus-label-text-color, ${a.color.onPrimary}))`),stateLayerColor:o(`var(--m3e-filled-button-focus-state-layer-color, var(--m3e-button-focus-state-layer-color, ${a.color.onPrimary}))`),stateLayerOpacity:o(`var(--m3e-filled-button-focus-state-layer-opacity, var(--m3e-button-focus-state-layer-opacity, ${a.state.focusStateLayerOpacity}))`),containerElevation:o(`var(--m3e-filled-button-focus-container-elevation, var(--m3e-button-focus-container-elevation, ${a.elevation.level0}))`),unselectedIconColor:o(`var(--m3e-filled-button-focus-unselected-icon-color, var(--m3e-button-focus-unselected-icon-color, ${a.color.onSurfaceVariant}))`),unselectedLabelTextColor:o(`var(--m3e-filled-button-focus-unselected-label-text-color, var(--m3e-button-focus-unselected-label-text-color, ${a.color.onSurfaceVariant}))`),unselectedStateLayerColor:o(`var(--m3e-filled-button-focus-unselected-state-layer-color, var(--m3e-button-focus-unselected-state-layer-color, ${a.color.onSurfaceVariant}))`),selectedIconColor:o(`var(--m3e-filled-button-focus-selected-icon-color, var(--m3e-button-focus-selected-icon-color, ${a.color.onPrimary}))`),selectedLabelTextColor:o(`var(--m3e-filled-button-focus-selected-label-text-color, var(--m3e-button-focus-selected-label-text-color, ${a.color.onPrimary}))`),selectedStateLayerColor:o(`var(--m3e-filled-button-focus-selected-state-layer-color, var(--m3e-button-focus-selected-state-layer-color, ${a.color.onPrimary}))`)},pressed:{iconColor:o(`var(--m3e-filled-button-pressed-icon-color, var(--m3e-button-pressed-icon-color, ${a.color.onPrimary}))`),labelTextColor:o(`var(--m3e-filled-button-pressed-label-text-color, var(--m3e-button-pressed-label-text-color, ${a.color.onPrimary}))`),stateLayerColor:o(`var(--m3e-filled-button-pressed-state-layer-color, var(--m3e-button-pressed-state-layer-color, ${a.color.onPrimary}))`),stateLayerOpacity:o(`var(--m3e-filled-button-pressed-state-layer-opacity, var(--m3e-button-pressed-state-layer-opacity, ${a.state.pressedStateLayerOpacity}))`),containerElevation:o(`var(--m3e-filled-button-pressed-container-elevation, var(--m3e-button-pressed-container-elevation, ${a.elevation.level0}))`),unselectedIconColor:o(`var(--m3e-filled-button-pressed-unselected-icon-color, var(--m3e-button-pressed-unselected-icon-color, ${a.color.onSurfaceVariant}))`),unselectedLabelTextColor:o(`var(--m3e-filled-button-pressed-unselected-label-text-color, var(--m3e-button-pressed-unselected-label-text-color, ${a.color.onSurfaceVariant}))`),unselectedStateLayerColor:o(`var(--m3e-filled-button-pressed-unselected-state-layer-color, var(--m3e-button-pressed-unselected-state-layer-color, ${a.color.onSurfaceVariant}))`),selectedIconColor:o(`var(--m3e-filled-button-pressed-selected-icon-color, var(--m3e-button-pressed-selected-icon-color, ${a.color.onPrimary}))`),selectedLabelTextColor:o(`var(--m3e-filled-button-pressed-selected-label-text-color, var(--m3e-button-pressed-selected-label-text-color, ${a.color.onPrimary}))`),selectedStateLayerColor:o(`var(--m3e-filled-button-pressed-selected-state-layer-color, var(--m3e-button-pressed-selected-state-layer-color, ${a.color.onPrimary}))`)}},tonal:{labelTextColor:o(`var(--m3e-tonal-button-label-text-color, var(--m3e-button-label-text-color, ${a.color.onSecondaryContainer}))`),iconColor:o(`var(--m3e-tonal-button-icon-color, var(--m3e-button-icon-color, ${a.color.onSecondaryContainer}))`),containerColor:o(`var(--m3e-tonal-button-container-color, var(--m3e-button-container-color, ${a.color.secondaryContainer}))`),containerElevation:o(`var(--m3e-tonal-button-container-elevation, var(--m3e-button-container-elevation, ${a.elevation.level0}))`),unselectedLabelTextColor:o(`var(--m3e-tonal-button-unselected-label-text-color, var(--m3e-button-unselected-label-text-color, ${a.color.onSecondaryContainer}))`),unselectedIconColor:o(`var(--m3e-tonal-button-unselected-icon-color, var(--m3e-button-unselected-icon-color, ${a.color.onSecondaryContainer}))`),unselectedContainerColor:o(`var(--m3e-tonal-button-unselected-container-color, var(--m3e-button-unselected-container-color, ${a.color.secondaryContainer}))`),selectedLabelTextColor:o(`var(--m3e-tonal-button-selected-label-text-color, var(--m3e-button-selected-label-text-color, ${a.color.onSecondary}))`),selectedIconColor:o(`var(--m3e-tonal-button-selected-icon-color, var(--m3e-button-selected-icon-color, ${a.color.onSecondary}))`),selectedContainerColor:o(`var(--m3e-tonal-button-selected-container-color, var(--m3e-button-selected-container-color, ${a.color.secondary}))`),disabled:{containerColor:o(`var(--m3e-tonal-button-disabled-container-color, var(--m3e-button-disabled-container-color, ${a.color.onSurface}))`),containerOpacity:o("var(--m3e-tonal-button-disabled-container-opacity, var(--m3e-button-disabled-container-opacity, 10%))"),iconColor:o(`var(--m3e-tonal-button-disabled-icon-color, var(--m3e-button-disabled-icon-color, ${a.color.onSurface}))`),iconOpacity:o("var(--m3e-tonal-button-disabled-icon-opacity, var(--m3e-button-disabled-icon-opacity, 38%))"),labelTextColor:o(`var(--m3e-tonal-button-disabled-label-text-color, var(--m3e-button-disabled-label-text-color, ${a.color.onSurface}))`),labelTextOpacity:o("var(--m3e-tonal-button-disabled-label-text-opacity, var(--m3e-button-disabled-label-text-opacity, 38%))"),containerElevation:o(`var(--m3e-tonal-button-disabled-container-elevation, var(--m3e-button-disabled-container-elevation, ${a.elevation.level0}))`)},hover:{iconColor:o(`var(--m3e-tonal-button-hover-icon-color, var(--m3e-button-hover-icon-color, ${a.color.onSecondaryContainer}))`),labelTextColor:o(`var(--m3e-tonal-button-hover-label-text-color, var(--m3e-button-hover-label-text-color, ${a.color.onSecondaryContainer}))`),stateLayerColor:o(`var(--m3e-tonal-button-hover-state-layer-color, var(--m3e-button-hover-state-layer-color, ${a.color.onSecondaryContainer}))`),stateLayerOpacity:o(`var(--m3e-tonal-button-hover-state-layer-opacity, var(--m3e-button-hover-state-layer-opacity, ${a.state.hoverStateLayerOpacity}))`),containerElevation:o(`var(--m3e-tonal-button-hover-container-elevation, var(--m3e-button-hover-container-elevation, ${a.elevation.level1}))`),unselectedIconColor:o(`var(--m3e-tonal-button-hover-unselected-icon-color, var(--m3e-button-hover-unselected-icon-color, ${a.color.onSecondaryContainer}))`),unselectedLabelTextColor:o(`var(--m3e-tonal-button-hover-unselected-label-text-color, var(--m3e-button-hover-unselected-label-text-color, ${a.color.onSecondaryContainer}))`),unselectedStateLayerColor:o(`var(--m3e-tonal-button-hover-unselected-state-layer-color, var(--m3e-button-hover-unselected-state-layer-color, ${a.color.onSecondaryContainer}))`),selectedIconColor:o(`var(--m3e-tonal-button-hover-selected-icon-color, var(--m3e-button-hover-selected-icon-color, ${a.color.onSecondary}))`),selectedLabelTextColor:o(`var(--m3e-tonal-button-hover-selected-label-text-color, var(--m3e-button-hover-selected-label-text-color, ${a.color.onSecondary}))`),selectedStateLayerColor:o(`var(--m3e-tonal-button-hover-selected-state-layer-color, var(--m3e-button-hover-selected-state-layer-color, ${a.color.onSecondary}))`)},focus:{iconColor:o(`var(--m3e-tonal-button-focus-icon-color, var(--m3e-button-focus-icon-color, ${a.color.onSecondaryContainer}))`),labelTextColor:o(`var(--m3e-tonal-button-focus-label-text-color, var(--m3e-button-focus-label-text-color, ${a.color.onSecondaryContainer}))`),stateLayerColor:o(`var(--m3e-tonal-button-focus-state-layer-color, var(--m3e-button-focus-state-layer-color, ${a.color.onSecondaryContainer}))`),stateLayerOpacity:o(`var(--m3e-tonal-button-focus-state-layer-opacity, var(--m3e-button-focus-state-layer-opacity, ${a.state.focusStateLayerOpacity}))`),containerElevation:o(`var(--m3e-tonal-button-focus-container-elevation, var(--m3e-button-focus-container-elevation, ${a.elevation.level0}))`),unselectedIconColor:o(`var(--m3e-tonal-button-focus-unselected-icon-color, var(--m3e-button-focus-unselected-icon-color, ${a.color.onSecondaryContainer}))`),unselectedLabelTextColor:o(`var(--m3e-tonal-button-focus-unselected-label-text-color, var(--m3e-button-focus-unselected-label-text-color, ${a.color.onSecondaryContainer}))`),unselectedStateLayerColor:o(`var(--m3e-tonal-button-focus-unselected-state-layer-color, var(--m3e-button-focus-unselected-state-layer-color, ${a.color.onSecondaryContainer}))`),selectedIconColor:o(`var(--m3e-tonal-button-focus-selected-icon-color, var(--m3e-button-focus-selected-icon-color, ${a.color.onSecondary}))`),selectedLabelTextColor:o(`var(--m3e-tonal-button-focus-selected-label-text-color, var(--m3e-button-focus-selected-label-text-color, ${a.color.onSecondary}))`),selectedStateLayerColor:o(`var(--m3e-tonal-button-focus-selected-state-layer-color, var(--m3e-button-focus-selected-state-layer-color, ${a.color.onSecondary}))`)},pressed:{iconColor:o(`var(--m3e-tonal-button-pressed-icon-color, var(--m3e-button-pressed-icon-color, ${a.color.onSecondaryContainer}))`),labelTextColor:o(`var(--m3e-tonal-button-pressed-label-text-color, var(--m3e-button-pressed-label-text-color, ${a.color.onSecondaryContainer}))`),stateLayerColor:o(`var(--m3e-tonal-button-pressed-state-layer-color, var(--m3e-button-pressed-state-layer-color, ${a.color.onSecondaryContainer}))`),stateLayerOpacity:o(`var(--m3e-tonal-button-pressed-state-layer-opacity, var(--m3e-button-pressed-state-layer-opacity, ${a.state.pressedStateLayerOpacity}))`),containerElevation:o(`var(--m3e-tonal-button-pressed-container-elevation, var(--m3e-button-pressed-container-elevation, ${a.elevation.level0}))`),unselectedIconColor:o(`var(--m3e-tonal-button-pressed-unselected-icon-color, var(--m3e-button-pressed-unselected-icon-color, ${a.color.onSecondaryContainer}))`),unselectedLabelTextColor:o(`var(--m3e-tonal-button-pressed-unselected-label-text-color, var(--m3e-button-pressed-unselected-label-text-color, ${a.color.onSecondaryContainer}))`),unselectedStateLayerColor:o(`var(--m3e-tonal-button-pressed-unselected-state-layer-color, var(--m3e-button-pressed-unselected-state-layer-color, ${a.color.onSecondaryContainer}))`),selectedIconColor:o(`var(--m3e-tonal-button-pressed-selected-icon-color, var(--m3e-button-pressed-selected-icon-color, ${a.color.onSecondary}))`),selectedLabelTextColor:o(`var(--m3e-tonal-button-pressed-selected-label-text-color, var(--m3e-button-pressed-selected-label-text-color, ${a.color.onSecondary}))`),selectedStateLayerColor:o(`var(--m3e-tonal-button-pressed-selected-state-layer-color, var(--m3e-button-pressed-selected-state-layer-color, ${a.color.onSecondary}))`)}},text:{labelTextColor:o(`var(--m3e-text-button-label-text-color, var(--m3e-button-label-text-color, ${a.color.primary}))`),iconColor:o(`var(--m3e-text-button-icon-color, var(--m3e-button-icon-color, ${a.color.primary}))`),unselectedLabelTextColor:o(`var(--m3e-text-button-unselected-label-text-color, var(--m3e-button-unselected-label-text-color, ${a.color.primary}))`),unselectedIconColor:o(`var(--m3e-text-button-unselected-icon-color, var(--m3e-button-unselected-icon-color, ${a.color.primary}))`),selectedLabelTextColor:o(`var(--m3e-text-button-selected-label-text-color, var(--m3e-button-selected-label-text-color, ${a.color.primary}))`),selectedIconColor:o(`var(--m3e-text-button-selected-icon-color, var(--m3e-button-selected-icon-color, ${a.color.primary}))`),disabled:{containerColor:o(`var(--m3e-text-button-disabled-container-color, var(--m3e-button-disabled-container-color, ${a.color.onSurface}))`),containerOpacity:o("var(--m3e-text-button-disabled-container-opacity, var(--m3e-button-disabled-container-opacity, 10%))"),iconColor:o(`var(--m3e-text-button-disabled-icon-color, var(--m3e-button-disabled-icon-color, ${a.color.onSurface}))`),iconOpacity:o("var(--m3e-text-button-disabled-icon-opacity, var(--m3e-button-disabled-icon-opacity, 38%))"),labelTextColor:o(`var(--m3e-text-button-disabled-label-text-color, var(--m3e-button-disabled-label-text-color, ${a.color.onSurface}))`),labelTextOpacity:o("var(--m3e-text-button-disabled-label-text-opacity, var(--m3e-button-disabled-label-text-opacity, 38%))")},hover:{iconColor:o(`var(--m3e-text-button-hover-icon-color, var(--m3e-button-hover-icon-color, ${a.color.primary}))`),labelTextColor:o(`var(--m3e-text-button-hover-label-text-color, var(--m3e-button-hover-label-text-color, ${a.color.primary}))`),stateLayerColor:o(`var(--m3e-text-button-hover-state-layer-color, var(--m3e-button-hover-state-layer-color, ${a.color.primary}))`),stateLayerOpacity:o(`var(--m3e-text-button-hover-state-layer-opacity, var(--m3e-button-hover-state-layer-opacity, ${a.state.hoverStateLayerOpacity}))`),unselectedIconColor:o(`var(--m3e-text-button-hover-unselected-icon-color, var(--m3e-button-hover-unselected-icon-color, ${a.color.primary}))`),unselectedLabelTextColor:o(`var(--m3e-text-button-hover-unselected-label-text-color, var(--m3e-button-hover-unselected-label-text-color, ${a.color.primary}))`),unselectedStateLayerColor:o(`var(--m3e-text-button-hover-unselected-state-layer-color, var(--m3e-button-hover-unselected-state-layer-color, ${a.color.primary}))`),selectedIconColor:o(`var(--m3e-text-button-hover-selected-icon-color, var(--m3e-button-hover-selected-icon-color, ${a.color.primary}))`),selectedLabelTextColor:o(`var(--m3e-text-button-hover-selected-label-text-color, var(--m3e-button-hover-selected-label-text-color, ${a.color.primary}))`),selectedStateLayerColor:o(`var(--m3e-text-button-hover-selected-state-layer-color, var(--m3e-button-hover-selected-state-layer-color, ${a.color.primary}))`)},focus:{iconColor:o(`var(--m3e-text-button-focus-icon-color, var(--m3e-button-focus-icon-color, ${a.color.primary}))`),labelTextColor:o(`var(--m3e-text-button-focus-label-text-color, var(--m3e-button-focus-label-text-color, ${a.color.primary}))`),stateLayerColor:o(`var(--m3e-text-button-focus-state-layer-color, var(--m3e-button-focus-state-layer-color, ${a.color.primary}))`),stateLayerOpacity:o(`var(--m3e-text-button-focus-state-layer-opacity, var(--m3e-button-focus-state-layer-opacity, ${a.state.focusStateLayerOpacity}))`),unselectedIconColor:o(`var(--m3e-text-button-focus-unselected-icon-color, var(--m3e-button-focus-unselected-icon-color, ${a.color.primary}))`),unselectedLabelTextColor:o(`var(--m3e-text-button-focus-unselected-label-text-color, var(--m3e-button-focus-unselected-label-text-color, ${a.color.primary}))`),unselectedStateLayerColor:o(`var(--m3e-text-button-focus-unselected-state-layer-color, var(--m3e-button-focus-unselected-state-layer-color, ${a.color.primary}))`),selectedIconColor:o(`var(--m3e-text-button-focus-selected-icon-color, var(--m3e-button-focus-selected-icon-color, ${a.color.primary}))`),selectedLabelTextColor:o(`var(--m3e-text-button-focus-selected-label-text-color, var(--m3e-button-focus-selected-label-text-color, ${a.color.primary}))`),selectedStateLayerColor:o(`var(--m3e-text-button-focus-selected-state-layer-color, var(--m3e-button-focus-selected-state-layer-color, ${a.color.primary}))`)},pressed:{iconColor:o(`var(--m3e-text-button-pressed-icon-color, var(--m3e-button-pressed-icon-color, ${a.color.primary}))`),labelTextColor:o(`var(--m3e-text-button-pressed-label-text-color, var(--m3e-button-pressed-label-text-color, ${a.color.primary}))`),stateLayerColor:o(`var(--m3e-text-button-pressed-state-layer-color, var(--m3e-button-pressed-state-layer-color, ${a.color.primary}))`),stateLayerOpacity:o(`var(--m3e-text-button-pressed-state-layer-opacity, var(--m3e-button-pressed-state-layer-opacity, ${a.state.pressedStateLayerOpacity}))`),unselectedIconColor:o(`var(--m3e-text-button-pressed-unselected-icon-color, var(--m3e-button-pressed-unselected-icon-color, ${a.color.primary}))`),unselectedLabelTextColor:o(`var(--m3e-text-button-pressed-unselected-label-text-color, var(--m3e-button-pressed-unselected-label-text-color, ${a.color.primary}))`),unselectedStateLayerColor:o(`var(--m3e-text-button-pressed-unselected-state-layer-color, var(--m3e-button-pressed-unselected-state-layer-color, ${a.color.primary}))`),selectedIconColor:o(`var(--m3e-text-button-pressed-selected-icon-color, var(--m3e-button-pressed-selected-icon-color, ${a.color.primary}))`),selectedLabelTextColor:o(`var(--m3e-text-button-pressed-selected-label-text-color, var(--m3e-button-pressed-selected-label-text-color, ${a.color.primary}))`),selectedStateLayerColor:o(`var(--m3e-text-button-pressed-selected-state-layer-color, var(--m3e-button-pressed-selected-state-layer-color, ${a.color.primary}))`)}}};function ln(t){return C`:host([variant="${o(t)}"]:not(:disabled):not([disabled-interactive])) .base { background-color: ${A[t].containerColor??o("unset")}; --m3e-state-layer-hover-color: ${A[t].hover.stateLayerColor}; --m3e-state-layer-hover-opacity: ${A[t].hover.stateLayerOpacity}; --m3e-state-layer-focus-color: ${A[t].focus.stateLayerColor}; --m3e-state-layer-focus-opacity: ${A[t].focus.stateLayerOpacity}; --m3e-ripple-color: ${A[t].pressed.stateLayerColor}; --m3e-ripple-opacity: ${A[t].pressed.stateLayerOpacity}; --m3e-elevation-level: ${A[t].containerElevation??o("unset")}; --m3e-elevation-hover-level: ${A[t].hover.containerElevation??o("unset")}; --m3e-elevation-focus-level: ${A[t].focus.containerElevation??o("unset")}; --m3e-elevation-pressed-level: ${A[t].pressed.containerElevation??o("unset")}; } :host([variant="${o(t)}"][toggle]:not([selected]):not(:disabled):not([disabled-interactive])) .base { background-color: ${A[t].unselectedContainerColor??o("unset")}; --m3e-state-layer-hover-color: ${A[t].hover.unselectedStateLayerColor}; --m3e-state-layer-focus-color: ${A[t].focus.unselectedStateLayerColor}; --m3e-ripple-color: ${A[t].pressed.unselectedStateLayerColor}; } :host([variant="${o(t)}"][toggle][selected]:not(:disabled):not([disabled-interactive])) .base { background-color: ${A[t].selectedContainerColor??o("unset")}; --m3e-state-layer-hover-color: ${A[t].hover.selectedStateLayerColor}; --m3e-state-layer-focus-color: ${A[t].focus.selectedStateLayerColor}; --m3e-ripple-color: ${A[t].pressed.selectedStateLayerColor}; } :host([variant="${o(t)}"]:not(:disabled):not([disabled-interactive])) .base { outline-color: ${A[t].outlineColor??o("unset")}; } :host([variant="${o(t)}"]:focus:not(:disabled):not([disabled-interactive])) .base { outline-color: ${A[t].focus.outlineColor??o("unset")}; } :host([variant="${o(t)}"]:hover:not(:disabled):not([disabled-interactive])) .base { outline-color: ${A[t].hover.outlineColor??o("unset")}; } :host( [variant="${o(t)}"]:is(:state(--pressed), :--pressed):not(:disabled):not([disabled-interactive]) ) .base { outline-color: ${A[t].pressed.outlineColor??o("unset")}; } :host([variant="${o(t)}"]:not(:disabled):not([disabled-interactive])) .label { color: ${A[t].labelTextColor}; } :host([variant="${o(t)}"][toggle]:not([selected]):not(:disabled):not([disabled-interactive])) .label { color: ${A[t].unselectedLabelTextColor}; } :host([variant="${o(t)}"][toggle][selected]:not(:disabled):not([disabled-interactive])) .label { color: ${A[t].selectedLabelTextColor}; } :host([variant="${o(t)}"]:focus:not(:disabled):not([disabled-interactive])) .label { color: ${A[t].focus.labelTextColor}; } :host([variant="${o(t)}"][toggle]:not([selected]):focus:not(:disabled):not([disabled-interactive])) .label { color: ${A[t].focus.unselectedLabelTextColor}; } :host([variant="${o(t)}"][toggle][selected]:focus:not(:disabled):not([disabled-interactive])) .label { color: ${A[t].focus.selectedLabelTextColor}; } :host([variant="${o(t)}"]:hover:not(:disabled):not([disabled-interactive])) .label { color: ${A[t].hover.labelTextColor}; } :host([variant="${o(t)}"][toggle]:not([selected]):hover:not(:disabled):not([disabled-interactive])) .label { color: ${A[t].hover.unselectedLabelTextColor}; } :host([variant="${o(t)}"][toggle][selected]:hover:not(:disabled):not([disabled-interactive])) .label { color: ${A[t].hover.selectedLabelTextColor}; } :host( [variant="${o(t)}"]:is(:state(--pressed), :--pressed):not(:disabled):not([disabled-interactive]) ) .label { color: ${A[t].pressed.labelTextColor}; } :host( [variant="${o(t)}"][toggle]:not([selected]):is(:state(--pressed), :--pressed):not(:disabled):not( [disabled-interactive] ) ) .label { color: ${A[t].pressed.unselectedLabelTextColor}; } :host( [variant="${o(t)}"][toggle][selected]:is(:state(--pressed), :--pressed):not(:disabled):not( [disabled-interactive] ) ) .label { color: ${A[t].pressed.selectedLabelTextColor}; } :host([variant="${o(t)}"]:not(:disabled):not([disabled-interactive])) .icon { color: ${A[t].iconColor}; } :host([variant="${o(t)}"][toggle]:not([selected]):not(:disabled):not([disabled-interactive])) .icon { color: ${A[t].unselectedIconColor}; } :host([variant="${o(t)}"][toggle][selected]:not(:disabled):not([disabled-interactive])) .icon { color: ${A[t].selectedIconColor}; } :host([variant="${o(t)}"]:focus:not(:disabled):not([disabled-interactive])) .icon { color: ${A[t].focus.iconColor}; } :host([variant="${o(t)}"][toggle]:not([selected]):focus:not(:disabled):not([disabled-interactive])) .icon { color: ${A[t].focus.unselectedIconColor}; } :host([variant="${o(t)}"][toggle][selected]:focus:not(:disabled):not([disabled-interactive])) .icon { color: ${A[t].focus.selectedIconColor}; } :host([variant="${o(t)}"]:hover:not(:disabled):not([disabled-interactive])) .icon { color: ${A[t].hover.iconColor}; } :host([variant="${o(t)}"][toggle]:not([selected]):hover:not(:disabled):not([disabled-interactive])) .icon { color: ${A[t].hover.unselectedIconColor}; } :host([variant="${o(t)}"][toggle][selected]:hover:not(:disabled):not([disabled-interactive])) .icon { color: ${A[t].hover.selectedIconColor}; } :host( [variant="${o(t)}"]:is(:state(--pressed), :--pressed):not(:disabled):not([disabled-interactive]) ) .icon { color: ${A[t].pressed.iconColor}; } :host( [variant="${o(t)}"][toggle]:not([selected]):is(:state(--pressed), :--pressed):not(:disabled):not( [disabled-interactive] ) ) .icon { color: ${A[t].pressed.unselectedIconColor}; } :host( [variant="${o(t)}"][toggle][selected]:is(:state(--pressed), :--pressed):not(:disabled):not( [disabled-interactive] ) ) .icon { color: ${A[t].pressed.selectedIconColor}; } :host([variant="${o(t)}"]:disabled) .base, :host([variant="${o(t)}"][disabled-interactive]) .base { --m3e-elevation-level: ${A[t].disabled.containerElevation??o("unset")}; outline-color: ${A[t].disabled.outlineColor??o("unset")}; background-color: color-mix( in srgb, ${A[t].disabled.containerColor} ${A[t].disabled.containerOpacity}, transparent ); } :host([variant="${o(t)}"]:disabled) .label, :host([variant="${o(t)}"][disabled-interactive]) .label { color: color-mix( in srgb, ${A[t].disabled.labelTextColor} ${A[t].disabled.labelTextOpacity}, transparent ); } :host([variant="${o(t)}"]:disabled) .icon, :host([variant="${o(t)}"][disabled-interactive]) .icon { color: color-mix( in srgb, ${A[t].disabled.iconColor} ${A[t].disabled.iconOpacity}, transparent ); }`}var ob=[ln("text"),ln("elevated"),ln("outlined"),ln("filled"),ln("tonal"),C`:host([variant="outlined"]:not([toggle][selected]):not(:disabled):not([disabled-interactive])) .base { outline-style: solid; }`],Ft,ss,uu,mu,vc,gc,yc,Se=class extends De(wt(yt(Be(Ze(se(Q(W(P,"button"),!0))))))){constructor(){super(),Ft.add(this),this._adjacentPressedTimeout=-1,ss.set(this,e=>n(this,Ft,"m",uu).call(this,e)),this.variant="text",this.shape="rounded",this.size="small",this.toggle=!1,this.selected=!1,new we(this,{callback:()=>this._handleResize()}),new je(this,{callback:e=>{!this.disabledInteractive&&!e&&!this.grouped&&this._base?.style.removeProperty("--_button-shape")}}),new fe(this,{isPressedKey:e=>e===" ",minPressedDuration:150,callback:e=>{!this.disabled&&!this.disabledInteractive&&(e?(n(this,Ft,"m",vc).call(this),n(this,Ft,"m",gc).call(this,!0)):n(this,Ft,"m",gc).call(this,!1))}})}get grouped(){return ie(this,"--grouped")}render(){return w`<div class="base"><m3e-elevation class="elevation" ?disabled="${this.disabled||this.disabledInteractive}"></m3e-elevation><m3e-state-layer class="state-layer" ?disabled="${this.disabled||this.disabledInteractive}"></m3e-state-layer><m3e-focus-ring class="focus-ring" ?disabled="${this.disabled}"></m3e-focus-ring><m3e-ripple class="ripple" ?disabled="${this.disabled||this.disabledInteractive}"></m3e-ripple><div class="touch" aria-hidden="true"></div>${this[xt]()}<div class="wrapper">${this.toggle?w`<slot class="icon" name="selected-icon" aria-hidden="true" @slotchange="${n(this,Ft,"m",mu)}"></slot>`:F}<slot class="icon" name="icon" aria-hidden="true"></slot><div class="label">${this.toggle&&this.selected?w`<slot name="selected"><slot></slot></slot>`:w`<slot></slot>`}</div><slot class="icon" name="trailing-icon" aria-hidden="true"></slot></div></div>`}connectedCallback(){super.connectedCallback(),this.addEventListener("click",n(this,ss,"f"))}disconnectedCallback(){super.disconnectedCallback(),["--pressed","--resting","--grouped","--connected"].forEach(e=>D(this,e)),this._base?.style.removeProperty("--_button-shape"),this.style.removeProperty("--_button-width"),this.style.removeProperty("--_adjacent-shrink"),D(this,"--adjacent-pressed"),this.removeEventListener("click",n(this,ss,"f"))}firstUpdated(e){super.firstUpdated(e),[this._elevation,this._focusRing,this._stateLayer,this._ripple].forEach(r=>r?.attach(this))}updated(e){if(super.updated(e),(e.has("disabled")&&this.disabled||e.has("disabledInteractive")&&this.disabledInteractive)&&(D(this,"--pressed"),D(this,"--resting")),(e.has("toggle")||e.has("selected"))&&(this.ariaPressed=this.toggle?`${this.selected}`:null,this.toggle))for(let r of this.querySelectorAll("m3e-icon"))r.toggleAttribute("filled",this.selected)}_handleResize(){this.grouped&&!ie(this,"--no-resize")&&this!==document.activeElement&&(this.style.setProperty("--_button-width",`${this.getBoundingClientRect().width}px`),n(this,Ft,"m",vc).call(this,!0))}};ss=new WeakMap;Ft=new WeakSet;uu=function(e){(this.disabled||this.disabledInteractive)&&(e.preventDefault(),e.stopImmediatePropagation()),this.toggle&&!e.defaultPrevented&&this.dispatchEvent(new Event("beforeinput",{bubbles:!0,cancelable:!0}))&&(this.selected=!this.selected,this.dispatchEvent(new Event("input",{bubbles:!0})),this.dispatchEvent(new Event("change",{bubbles:!0})))};mu=function(e){this._base?.classList.toggle("with-selected-icon",he(e.target))};vc=function(e=!1){if(!this._base)return;let r=parseFloat(getComputedStyle(this._base).borderRadius);if(!isNaN(r)||e){let i=this.clientHeight/2;(i<r||e)&&this._base?.style.setProperty("--_button-shape",`${i}px`)}};gc=function(e){let r=this.getBoundingClientRect().width,i=this.closest("m3e-button-group");if(i&&i.variant==="standard"){let s=[...i.querySelectorAll("m3e-button,m3e-icon-button")];for(let c of s)clearTimeout(c._adjacentPressedTimeout),c._adjacentPressedTimeout=-1;let l=s.indexOf(this);if(e){let c=parseFloat(getComputedStyle(this).getPropertyValue("--m3e-standard-button-group-width-multiplier")||"0.15"),d=r*c;l>0&&l<s.length-1&&(d/=2);for(let u=0;u<s.length;u++)u==l-1||u==l+1?(ae(s[u],"--no-resize"),s[u].style.setProperty("--_adjacent-shrink",`${d}px`),ae(s[u],"--adjacent-pressed")):u==l?(ae(s[u],"--no-resize"),s[u].style.removeProperty("--_adjacent-shrink"),D(s[u],"--adjacent-pressed")):(D(s[u],"--no-resize"),s[u].style.removeProperty("--_adjacent-shrink"),D(s[u],"--adjacent-pressed"))}else{for(let c=0;c<s.length;c++)(c==l-1||c==l+1)&&s[c].style.setProperty("--_adjacent-shrink","0px");Ce()?n(this,Ft,"m",yc).call(this,s):this.addEventListener("transitionend",c=>{c.propertyName==="width"&&(this._adjacentPressedTimeout=setTimeout(()=>{this._adjacentPressedTimeout>-1&&n(this,Ft,"m",yc).call(this,s)},600))},{once:!0})}}R(this,"--pressed",e),R(this,"--resting",!e)};yc=function(e){for(let r of e)D(r,"--adjacent-pressed"),D(r,"--no-resize"),r.style.removeProperty("--_adjacent-shrink")};Se.styles=[eb,ob,tb];h([M(".base")],Se.prototype,"_base",void 0);h([M(".elevation")],Se.prototype,"_elevation",void 0);h([M(".focus-ring")],Se.prototype,"_focusRing",void 0);h([M(".state-layer")],Se.prototype,"_stateLayer",void 0);h([M(".ripple")],Se.prototype,"_ripple",void 0);h([b({reflect:!0})],Se.prototype,"variant",void 0);h([b({reflect:!0})],Se.prototype,"shape",void 0);h([b({reflect:!0})],Se.prototype,"size",void 0);h([b({type:Boolean,reflect:!0})],Se.prototype,"toggle",void 0);h([b({type:Boolean,reflect:!0})],Se.prototype,"selected",void 0);h([vt(40)],Se.prototype,"_handleResize",null);Se=h([L("m3e-button")],Se);var ge={padding:o("var(--m3e-card-padding, 1rem)"),shape:o(`var(--m3e-card-shape, ${a.shape.corner.medium});`)},H={filled:{textColor:o(`var(--m3e-filled-card-text-color, var(--m3e-card-text-color, ${a.color.onSurface}))`),containerColor:o(`var(--m3e-filled-card-container-color, var(--m3e-card-container-color, ${a.color.surfaceContainerHighest}))`),containerElevation:o(`var(--m3e-filled-card-container-elevation, var(--m3e-card-container-elevation, ${a.elevation.level0}))`),disabled:{textColor:o(`var(--m3e-filled-card-disabled-text-color, var(--m3e-card-disabled-text-color, ${a.color.onSurface}))`),textOpacity:o("var(--m3e-filled-card-disabled-text-opacity, var(--m3e-card-disabled-text-opacity, 38%))"),imageOpacity:o("var(--m3e-filled-card-disabled-image-opacity, var(--m3e-card-disabled-image-opacity, 38%))"),containerColor:o(`var(--m3e-filled-card-disabled-container-color, var(--m3e-card-disabled-container-color, ${a.color.surfaceVariant}))`),containerElevation:o(`var(--m3e-filled-card-disabled-container-elevation, var(--m3e-card-disabled-container-elevation, ${a.elevation.level0}))`),containerElevationColor:o(`var(--m3e-filled-card-disabled-container-elevation-color, var(--m3e-card-disabled-container-elevation-color, ${a.color.onSurface}))`),containerElevationOpacity:o("var(--m3e-filled-card-disabled-container-elevation-opacity, var(--m3e-card-disabled-container-elevation-opacity, 38%))"),containerOpacity:o("var(--m3e-filled-card-disabled-container-opacity, var(--m3e-card-disabled-container-opacity, 38%))")},hover:{textColor:o(`var(--m3e-filled-card-hover-text-color, var(--m3e-card-hover-text-color, ${a.color.onSurface}))`),stateLayerColor:o(`var(--m3e-filled-card-hover-state-layer-color, var(--m3e-card-hover-state-layer-color, ${a.color.onSurface}))`),stateLayerOpacity:o(`var(--m3e-filled-card-hover-state-layer-opacity, var(--m3e-card-hover-state-layer-opacity, ${a.state.hoverStateLayerOpacity}))`),containerElevation:o(`var(--m3e-filled-card-hover-container-elevation, var(--m3e-card-hover-container-elevation, ${a.elevation.level1}))`)},focus:{textColor:o(`var(--m3e-filled-card-focus-text-color, var(--m3e-card-focus-text-color, ${a.color.onSurface}))`),stateLayerColor:o(`var(--m3e-filled-card-focus-state-layer-color, var(--m3e-card-focus-state-layer-color, ${a.color.onSurface}))`),stateLayerOpacity:o(`var(--m3e-filled-card-focus-state-layer-opacity, var(--m3e-card-focus-state-layer-opacity, ${a.state.focusStateLayerOpacity}))`),containerElevation:o(`var(--m3e-filled-card-focus-container-elevation, var(--m3e-card-focus-container-elevation, ${a.elevation.level0}))`)},pressed:{textColor:o(`var(--m3e-filled-card-pressed-text-color, var(--m3e-card-pressed-text-color, ${a.color.onSurface}))`),stateLayerColor:o(`var(--m3e-filled-card-pressed-state-layer-color, var(--m3e-card-pressed-state-layer-color, ${a.color.onSurface}))`),stateLayerOpacity:o(`var(--m3e-filled-card-pressed-state-layer-opacity, var(--m3e-card-pressed-state-layer-opacity, ${a.state.pressedStateLayerOpacity}))`),containerElevation:o(`var(--m3e-filled-card-pressed-container-elevation, var(--m3e-card-pressed-container-elevation, ${a.elevation.level0}))`)}},elevated:{textColor:o(`var(--m3e-elevated-card-text-color, var(--m3e-card-text-color, ${a.color.onSurface}))`),containerColor:o(`var(--m3e-elevated-card-container-color, var(--m3e-card-container-color, ${a.color.surfaceContainerLow}))`),containerElevation:o(`var(--m3e-elevated-card-container-elevation, var(--m3e-card-container-elevation, ${a.elevation.level1}))`),disabled:{textColor:o(`var(--m3e-elevated-card-disabled-text-color, var(--m3e-card-disabled-text-color, ${a.color.onSurface}))`),textOpacity:o("var(--m3e-elevated-card-disabled-text-opacity, var(--m3e-card-disabled-text-opacity, 38%))"),imageOpacity:o("var(--m3e-elevated-card-disabled-image-opacity, var(--m3e-card-disabled-image-opacity, 38%))"),containerColor:o(`var(--m3e-elevated-card-disabled-container-color, var(--m3e-card-disabled-container-color, ${a.color.surface}))`),containerElevation:o(`var(--m3e-elevated-card-disabled-container-elevation, var(--m3e-card-disabled-container-elevation, ${a.elevation.level1}))`),containerElevationColor:o(`var(--m3e-elevated-card-disabled-container-elevation-color, var(--m3e-card-disabled-container-elevation-color, ${a.color.onSurface}))`),containerElevationOpacity:o("var(--m3e-elevated-card-disabled-container-elevation-opacity, var(--m3e-card-disabled-container-elevation-opacity, 38%))"),containerOpacity:o("var(--m3e-elevated-card-disabled-container-opacity, var(--m3e-card-disabled-container-opacity, 38%))")},hover:{textColor:o(`var(--m3e-elevated-card-hover-text-color, var(--m3e-card-hover-text-color, ${a.color.onSurface}))`),stateLayerColor:o(`var(--m3e-elevated-card-hover-state-layer-color, var(--m3e-card-hover-state-layer-color, ${a.color.onSurface}))`),stateLayerOpacity:o(`var(--m3e-elevated-card-hover-state-layer-opacity, var(--m3e-card-hover-state-layer-opacity, ${a.state.hoverStateLayerOpacity}))`),containerElevation:o(`var(--m3e-elevated-card-hover-container-elevation, var(--m3e-card-hover-container-elevation, ${a.elevation.level2}))`)},focus:{textColor:o(`var(--m3e-elevated-card-focus-text-color, var(--m3e-card-focus-text-color, ${a.color.onSurface}))`),stateLayerColor:o(`var(--m3e-elevated-card-focus-state-layer-color, var(--m3e-card-focus-state-layer-color, ${a.color.onSurface}))`),stateLayerOpacity:o(`var(--m3e-elevated-card-focus-state-layer-opacity, var(--m3e-card-focus-state-layer-opacity, ${a.state.focusStateLayerOpacity}))`),containerElevation:o(`var(--m3e-elevated-card-focus-container-elevation, var(--m3e-card-focus-container-elevation, ${a.elevation.level1}))`)},pressed:{textColor:o(`var(--m3e-elevated-card-pressed-text-color, var(--m3e-card-pressed-text-color, ${a.color.onSurface}))`),stateLayerColor:o(`var(--m3e-elevated-card-pressed-state-layer-color, var(--m3e-card-pressed-state-layer-color, ${a.color.onSurface}))`),stateLayerOpacity:o(`var(--m3e-elevated-card-pressed-state-layer-opacity, var(--m3e-card-pressed-state-layer-opacity, ${a.state.pressedStateLayerOpacity}))`),containerElevation:o(`var(--m3e-elevated-card-pressed-container-elevation, var(--m3e-card-pressed-container-elevation, ${a.elevation.level1}))`)}},outlined:{textColor:o(`var(--m3e-outlined-card-text-color, var(--m3e-card-text-color, ${a.color.onSurface}))`),containerColor:o(`var(--m3e-outlined-card-container-color, var(--m3e-card-container-color, ${a.color.surface}))`),containerElevation:o(`var(--m3e-outlined-card-container-elevation, var(--m3e-card-container-elevation, ${a.elevation.level0}))`),outlineColor:o(`var(--m3e-outlined-card-outline-color, var(--m3e-card-outline-color, ${a.color.outlineVariant}))`),outlineThickness:o("var(--m3e-outlined-card-outline-thickness, var(--m3e-card-outline-thickness, 1px))"),disabled:{textColor:o(`var(--m3e-outlined-card-disabled-text-color, var(--m3e-card-disabled-text-color, ${a.color.onSurface}))`),textOpacity:o("var(--m3e-outlined-card-disabled-text-opacity, var(--m3e-card-disabled-text-opacity, 38%))"),imageOpacity:o("var(--m3e-outlined-card-disabled-image-opacity, var(--m3e-card-disabled-image-opacity, 38%))"),containerElevation:o(`var(--m3e-outlined-card-disabled-container-elevation, var(--m3e-card-disabled-container-elevation, ${a.elevation.level0}))`),containerElevationColor:o(`var(--m3e-outlined-card-disabled-container-elevation-color, var(--m3e-card-disabled-container-elevation-color, ${a.color.onSurface}))`),containerElevationOpacity:o("var(--m3e-outlined-card-disabled-container-elevation-opacity, var(--m3e-card-disabled-container-elevation-opacity, 38%))"),outlineColor:o(`var(--m3e-outlined-card-disabled-outline-color, var(--m3e-card-disabled-outline-color, ${a.color.outline}))`),outlineOpacity:o("var(--m3e-outlined-card-disabled-outline-opacity, var(--m3e-card-disabled-outline-opacity, 12%))")},hover:{textColor:o(`var(--m3e-outlined-card-hover-text-color, var(--m3e-card-hover-text-color, ${a.color.onSurface}))`),stateLayerColor:o(`var(--m3e-outlined-card-hover-state-layer-color, var(--m3e-card-hover-state-layer-color, ${a.color.onSurface}))`),stateLayerOpacity:o(`var(--m3e-outlined-card-hover-state-layer-opacity, var(--m3e-card-hover-state-layer-opacity, ${a.state.hoverStateLayerOpacity}))`),containerElevation:o(`var(--m3e-outlined-card-hover-container-elevation, var(--m3e-card-hover-container-elevation, ${a.elevation.level1}))`),outlineColor:o(`var(--m3e-outlined-card-hover-outline-color, var(--m3e-card-hover-outline-color, ${a.color.outlineVariant}))`)},focus:{textColor:o(`var(--m3e-outlined-card-focus-text-color, var(--m3e-card-focus-text-color, ${a.color.onSurface}))`),stateLayerColor:o(`var(--m3e-outlined-card-focus-state-layer-color, var(--m3e-card-focus-state-layer-color, ${a.color.onSurface}))`),stateLayerOpacity:o(`var(--m3e-outlined-card-focus-state-layer-opacity, var(--m3e-card-focus-state-layer-opacity, ${a.state.focusStateLayerOpacity}))`),containerElevation:o(`var(--m3e-outlined-card-focus-container-elevation, var(--m3e-card-focus-container-elevation, ${a.elevation.level0}))`),outlineColor:o(`var(--m3e-outlined-card-focus-outline-color, var(--m3e-card-focus-outline-color, ${a.color.onSurface}))`)},pressed:{textColor:o(`var(--m3e-outlined-card-pressed-text-color, var(--m3e-card-pressed-text-color, ${a.color.onSurface}))`),stateLayerColor:o(`var(--m3e-outlined-card-pressed-state-layer-color, var(--m3e-card-pressed-state-layer-color, ${a.color.onSurface}))`),stateLayerOpacity:o(`var(--m3e-outlined-card-pressed-state-layer-opacity, var(--m3e-card-pressed-state-layer-opacity, ${a.state.pressedStateLayerOpacity}))`),containerElevation:o(`var(--m3e-outlined-card-pressed-container-elevation, var(--m3e-card-pressed-container-elevation, ${a.elevation.level0}))`),outlineColor:o(`var(--m3e-outlined-card-pressed-outline-color, var(--m3e-card-pressed-outline-color, ${a.color.outlineVariant}))`)}}},ab=C`:host { outline: none; } :host(:not([inline])) { display: block; } :host(:not([inline])) .base { display: flex; } :host([inline]) { display: inline-block; vertical-align: middle; } :host([inline]) .base { display: inline-flex; } .base { width: 100%; height: 100%; position: relative; box-sizing: border-box; border-radius: ${ge.shape}; } :host([actionable]) .base { transition: ${o(`background-color ${a.motion.duration.short4} ${a.motion.easing.standard},
      border-color ${a.motion.duration.short4} ${a.motion.easing.standard}`)}; } :host([actionable]) { user-select: none; -webkit-tap-highlight-color: rgba(0, 0, 0, 0); } :host([actionable]:not(:disabled):not([disabled-interactive])) { cursor: pointer; } :host([actionable][disabled-interactive]) { cursor: not-allowed; } :host(:not([actionable])) .focus-ring, :host(:not([actionable])) .state-layer, :host(:not([actionable])) .ripple { display: none; } :host([variant="outlined"]) .base { border-style: solid; } ::slotted([slot="content"]) { flex: 1 1 auto; } ::slotted(img), ::slotted(video) { inset: 0; object-fit: cover; } ::slotted(img[slot="header"]), ::slotted(video[slot="header"]) { border-radius: ${ge.shape}; } ::slotted([slot="actions"][end]) { justify-content: flex-end; } ::slotted([slot="header"]), ::slotted([slot="actions"]), ::slotted([slot="footer"]) { flex: none; display: flex; align-items: center; } :host([orientation="vertical"]) .base, :host([orientation="horizontal"]) ::slotted([slot="header"]), :host([orientation="horizontal"]) ::slotted([slot="actions"]), :host([orientation="horizontal"]) ::slotted([slot="footer"]) { flex-direction: column; } :host([orientation="horizontal"]) .base, :host([orientation="vertical"]) ::slotted([slot="header"]), :host([orientation="vertical"]) ::slotted([slot="actions"]), :host([orientation="vertical"]) ::slotted([slot="footer"]) { flex-direction: row; } :host([orientation="horizontal"]) ::slotted(img), :host([orientation="horizontal"]) ::slotted(video) { aspect-ratio: 16 / 9; } .has-content:not(.has-default) slot[name="content"], .has-content.has-default slot:not([name]) { display: inherit; flex-direction: inherit; flex: 1 1 auto; } .has-header slot[name="header"], .has-actions slot[name="actions"], .has-footer slot[name="footer"] { display: inherit; flex-direction: inherit; flex: none; } :host([orientation="vertical"]) .has-content:not(.has-default) slot[name="content"] { margin-inline: ${ge.padding}; } :host([orientation="vertical"]) .has-content:not(.has-default):not(.has-header) slot[name="content"] { margin-block-start: ${ge.padding}; } :host([orientation="vertical"]) .has-content:not(.has-default):not(.has-actions):not(.has-footer) slot[name="content"] { margin-block-end: ${ge.padding}; } :host([orientation="horizontal"]) .has-content:not(.has-default) slot[name="content"] { margin-block: ${ge.padding}; } :host([orientation="horizontal"]) .has-content:not(.has-default):not(.has-header) slot[name="content"] { margin-inline-start: ${ge.padding}; } :host([orientation="horizontal"]) .has-content:not(.has-default):not(.has-actions):not(.has-footer) slot[name="content"] { margin-inline-end: ${ge.padding}; } :host([orientation="vertical"]) .has-header:not(.has-header-media) slot[name="header"] { margin-inline: ${ge.padding}; margin-block-start: ${ge.padding}; } :host([orientation="horizontal"]) .has-header:not(.has-header-media) slot[name="header"] { margin-inline-start: ${ge.padding}; margin-block: ${ge.padding}; } .has-actions slot[name="actions"] { margin-inline: ${ge.padding}; margin-block: ${ge.padding}; } :host([orientation="vertical"]) .has-footer slot[name="footer"] { margin-inline: ${ge.padding}; margin-block-end: ${ge.padding}; } :host([orientation="horizontal"]) .has-footer slot[name="footer"] { margin-block: ${ge.padding}; margin-inline-end: ${ge.padding}; } a { all: unset; display: block; position: absolute; top: 0px; left: 0px; right: 0px; bottom: 0px; z-index: 1; } @media (forced-colors: active) { :host([actionable]) .base { transition: none; } :host([variant]) .base { border-style: solid; border-color: CanvasText; border-width: ${H.outlined.outlineThickness??o("unset")}; } :host([actionable][variant]:disabled) .base, :host([actionable][variant][disabled-interactive]) .base { color: GrayText; border-color: GrayText; } } @media (prefers-reduced-motion) { :host([actionable]) .base { transition: none; } }`;function xc(t){return C`:host([variant="${o(t)}"]) .base { background-color: ${H[t].containerColor??o("unset")}; box-shadow: ${H[t].containerElevation??o("unset")}; border-width: ${H[t].outlineThickness??o("unset")}; } :host([actionable][variant="${o(t)}"]) .base { --m3e-state-layer-hover-color: ${H[t].hover.stateLayerColor}; --m3e-state-layer-hover-opacity: ${H[t].hover.stateLayerOpacity}; --m3e-state-layer-focus-color: ${H[t].focus.stateLayerColor}; --m3e-state-layer-focus-opacity: ${H[t].focus.stateLayerOpacity}; --m3e-ripple-color: ${H[t].pressed.stateLayerColor}; --m3e-ripple-opacity: ${H[t].pressed.stateLayerOpacity}; --m3e-elevation-level: ${H[t].containerElevation??o("unset")}; --m3e-elevation-hover-level: ${H[t].hover.containerElevation??o("unset")}; --m3e-elevation-focus-level: ${H[t].focus.containerElevation??o("unset")}; --m3e-elevation-pressed-level: ${H[t].pressed.containerElevation??o("unset")}; } :host([variant="${o(t)}"]) .base { border-color: ${H[t].outlineColor??o("unset")}; } :host([actionable][variant="${o(t)}"]:focus .base) { border-color: ${H[t].focus.outlineColor??o("unset")}; } :host([actionable][variant="${o(t)}"]:hover .base) { border-color: ${H[t].hover.outlineColor??o("unset")}; } :host([actionable][variant="${o(t)}"]) .base.pressed { border-color: ${H[t].pressed.outlineColor??o("unset")}; } :host([variant="${o(t)}"]) .base { color: ${H[t].textColor??o("unset")}; } :host([actionable][variant="${o(t)}"]:focus) .base { color: ${H[t].focus.textColor??o("unset")}; } :host([actionable][variant="${o(t)}"]:hover) .base { color: ${H[t].hover.textColor??o("unset")}; } :host([actionable][variant="${o(t)}"]) .base.pressed { color: ${H[t].pressed.textColor??o("unset")}; } :host([actionable][variant="${o(t)}"]:disabled) .base, :host([actionable][variant="${o(t)}"][disabled-interactive]) .base { --m3e-elevation-level: ${H[t].disabled.containerElevation??o("unset")}; --m3e-elevation-color: color-mix( in srgb, ${H[t].disabled.containerElevationColor} ${H[t].disabled.containerElevationOpacity}, transparent ); color: color-mix( in srgb, ${H[t].disabled.textColor} ${H[t].disabled.textOpacity}, transparent ); background-color: ${H[t].disabled.containerColor&&H[t].disabled.containerOpacity?o(`color-mix(
        in srgb,
        ${H[t].disabled.containerColor} ${H[t].disabled.containerOpacity},
        transparent
      )`):o("unset")}; border-color: ${H[t].disabled.outlineColor&&H[t].disabled.outlineOpacity?o(`color-mix(
        in srgb,
        ${H[t].disabled.outlineColor} ${H[t].disabled.outlineOpacity},
        transparent
      )`):o("unset")}; } :host([actionable][variant="${o(t)}"]:disabled) ::slotted(img), :host([actionable][variant="${o(t)}"][disabled-interactive]) ::slotted(img), :host([actionable][variant="${o(t)}"]:disabled) ::slotted(video), :host([actionable][variant="${o(t)}"][disabled-interactive]) ::slotted(video) { opacity: ${H[t].disabled.imageOpacity}; }`}var rb=[xc("filled"),xc("elevated"),xc("outlined")],go,ls,pu,fu,bu,vu,gu,yu,it=class extends De(wt(yt(Be(Ze(se(Q(P),!0)))))){constructor(){super(),go.add(this),ls.set(this,e=>n(this,go,"m",yu).call(this,e)),this.inline=!1,this.actionable=!1,this.variant="filled",this.orientation="vertical",new fe(this,{isPressedKey:e=>e===" ",callback:e=>{this.actionable&&!this.disabled&&!this.disabledInteractive&&this._base?.classList.toggle("pressed",e)}})}connectedCallback(){this.hasAttribute("actionable")&&(this.role="button"),super.connectedCallback(),this.addEventListener("click",n(this,ls,"f"))}disconnectedCallback(){super.disconnectedCallback(),this._base?.classList.toggle("pressed",!1),this.removeEventListener("click",n(this,ls,"f"))}render(){return w`<div class="base"><m3e-elevation class="elevation" ?disabled="${!this.actionable||this.disabled||this.disabledInteractive}"></m3e-elevation><m3e-focus-ring class="focus-ring" ?disabled="${!this.actionable||this.disabled}"></m3e-focus-ring><m3e-state-layer class="state-layer" ?disabled="${!this.actionable||this.disabled||this.disabledInteractive}"></m3e-state-layer><m3e-ripple class="ripple" ?disabled="${!this.actionable||this.disabled||this.disabledInteractive}"></m3e-ripple>${this[xt]()}<slot name="header" @slotchange="${n(this,go,"m",pu)}"></slot><slot name="content" @slotchange="${n(this,go,"m",fu)}"><slot @slotchange="${n(this,go,"m",bu)}"></slot></slot><slot name="actions" @slotchange="${n(this,go,"m",vu)}"></slot><slot name="footer" @slotchange="${n(this,go,"m",gu)}"></slot></div>`}firstUpdated(e){super.firstUpdated(e),[this._elevation,this._focusRing,this._stateLayer,this._ripple].forEach(r=>r?.attach(this)),!this.actionable&&this.hasAttribute("tabindex")&&this.removeAttribute("tabindex")}update(e){super.update(e),!this.actionable&&this.hasAttribute("tabindex")&&this.removeAttribute("tabindex")}};ls=new WeakMap;go=new WeakSet;pu=function(e){let r=e.target.assignedNodes({flatten:!0}),i=this.shadowRoot?.querySelector(".base");i?.classList.toggle("has-header",r.length>0),i?.classList.toggle("has-header-media",r.some(s=>s instanceof HTMLElement&&(s.tagName==="IMG"||s.tagName==="VIDEO")))};fu=function(){this.shadowRoot?.querySelector(".base")?.classList.toggle("has-content",this.querySelector("[slot='content']")!==null)};bu=function(e){this.shadowRoot?.querySelector(".base")?.classList.toggle("has-default",he(e.target)&&this.querySelector("[slot='content']")===null)};vu=function(e){this.shadowRoot?.querySelector(".base")?.classList.toggle("has-actions",he(e.target))};gu=function(e){this.shadowRoot?.querySelector(".base")?.classList.toggle("has-footer",he(e.target))};yu=function(e){(this.disabled||this.disabledInteractive)&&(e.preventDefault(),e.stopImmediatePropagation())};it.styles=[rb,ab];h([M(".base")],it.prototype,"_base",void 0);h([M(".elevation")],it.prototype,"_elevation",void 0);h([M(".focus-ring")],it.prototype,"_focusRing",void 0);h([M(".state-layer")],it.prototype,"_stateLayer",void 0);h([M(".ripple")],it.prototype,"_ripple",void 0);h([b({type:Boolean,reflect:!0})],it.prototype,"inline",void 0);h([b({type:Boolean,reflect:!0})],it.prototype,"actionable",void 0);h([b({reflect:!0})],it.prototype,"variant",void 0);h([b({reflect:!0})],it.prototype,"orientation",void 0);it=h([L("m3e-card")],it);var Ya,ps,hn,wu,_u,$u,Cu,ze=class extends Q(P){constructor(){super(...arguments),Ya.add(this),ps.set(this,void 0),hn.set(this,""),this.variant="outlined"}get value(){return n(this,ps,"f")??n(this,hn,"f")}set value(e){f(this,ps,e,"f")}get label(){return n(this,hn,"f")}firstUpdated(e){super.firstUpdated(e),this.role==="listitem"&&this.removeAttribute("tabindex"),[this._elevation,this._focusRing,this._stateLayer,this._ripple].forEach(r=>{r?.htmlFor||r?.attach(this)})}render(){let e=!gt(this)||this.disabled,r=co(this)&&this.disabledInteractive;return w`<div class="base"><m3e-elevation class="elevation" ?disabled="${e||r}"></m3e-elevation><m3e-state-layer class="state-layer" ?disabled="${e||r}"></m3e-state-layer><m3e-focus-ring class="focus-ring" ?disabled="${e}"></m3e-focus-ring><m3e-ripple class="ripple" ?disabled="${e||r}"></m3e-ripple><div class="touch" aria-hidden="true"></div>${bh(this)?this[xt]():F}<div class="wrapper">${n(this,Ya,"m",wu).call(this)}</div></div>`}_renderIcon(){return w`<slot name="icon" aria-hidden="true" @slotchange="${n(this,Ya,"m",_u)}"></slot>`}_renderTrailingIcon(){return w`<slot name="trailing-icon" aria-hidden="true" @slotchange="${n(this,Ya,"m",$u)}"></slot>`}_renderSlot(){return w`<slot @slotchange="${n(this,Ya,"m",Cu)}"></slot>`}};ps=new WeakMap;hn=new WeakMap;Ya=new WeakSet;wu=function(){return w`${this._renderIcon()}<div class="label">${this._renderSlot()}</div>${this._renderTrailingIcon()}`};_u=function(e){R(this,"--with-icon",he(e.target))};$u=function(e){R(this,"--with-trailing-icon",he(e.target))};Cu=function(e){f(this,hn,Go(e.target),"f")};ze.styles=C`:host { display: inline-block; vertical-align: middle; outline: none; -webkit-tap-highlight-color: rgba(0, 0, 0, 0); } .base { box-sizing: border-box; vertical-align: middle; display: inline-flex; align-items: center; justify-content: center; position: relative; width: 100%; transition: ${o(`background-color ${a.motion.duration.short4} ${a.motion.easing.standard}`)}; border-radius: var(--m3e-chip-container-shape, ${a.shape.corner.small}); height: calc(var(--m3e-chip-container-height, 2rem) + ${a.density.calc(-3)}); font-size: var(--m3e-chip-label-text-font-size, ${a.typescale.standard.label.large.fontSize}); font-weight: var(--m3e-chip-label-text-font-weight, ${a.typescale.standard.label.large.fontWeight}); line-height: var(--m3e-chip-label-text-line-height, ${a.typescale.standard.label.large.lineHeight}); letter-spacing: var(--m3e-chip-label-text-tracking, ${a.typescale.standard.label.large.tracking}); } :host(:not(m3e-chip):not(:disabled):not([disabled-interactive])) { cursor: pointer; } :host(:not(m3e-chip):not(:disabled)[disabled-interactive]) { cursor: not-allowed; } :host(:not(m3e-chip):not(:disabled):not([disabled-interactive])) .base { user-select: none; } .touch { position: absolute; height: 3rem; left: 0; right: 0; } .wrapper { width: 100%; overflow: hidden; display: inline-flex; align-items: center; column-gap: var(--m3e-chip-spacing, 0.5rem); } .label { flex: 1 1 auto; min-width: 0; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; } a { all: unset; display: block; position: absolute; top: 0px; left: 0px; right: 0px; bottom: 0px; z-index: 1; } :host([variant="elevated"]) .base { background-color: var(--m3e-elevated-chip-container-color, ${a.color.surfaceContainerLow}); --m3e-elevation-level: var(--m3e-elevated-chip-elevation, ${a.elevation.level1}); --m3e-elevation-hover-level: var(--m3e-elevated-chip-hover-elevation, ${a.elevation.level2}); --m3e-elevation-focus-level: var(--m3e-elevated-chip-elevation, ${a.elevation.level1}); --m3e-elevation-pressed-level: var(--m3e-elevated-chip-elevation, ${a.elevation.level1}); } :host([variant="outlined"]) .base { outline-width: var(--m3e-outlined-chip-outline-thickness, 1px); outline-style: solid; outline-offset: calc(0px - var(--m3e-outlined-chip-outline-thickness, 1px)); } :host(:not(:disabled):not([disabled-interactive])[variant="outlined"]) .base { outline-color: var(--m3e-outlined-chip-outline-color, ${a.color.outlineVariant}); } :host(:disabled[variant="outlined"]) .base, :host([disabled-interactive][variant="outlined"]) .base { outline-color: color-mix( in srgb, var(--m3e-outlined-chip-disabled-outline-color, ${a.color.onSurface}) var(--m3e-outlined-chip-disabled-outline-opacity, 12%), transparent ); } :host(:is(:state(--with-icon), :--with-icon)) .wrapper { padding-inline-start: var(--m3e-chip-with-icon-padding-start, 0.5rem); } :host(:not(:is(:state(--with-icon), :--with-icon))) .wrapper { padding-inline-start: var(--m3e-chip-padding-start, 1rem); } :host(:is(:state(--with-trailing-icon), :--with-trailing-icon)) .wrapper { padding-inline-end: var(--m3e-chip-with-icon-padding-end, 0.5rem); } :host(:not(:is(:state(--with-trailing-icon), :--with-trailing-icon))) .wrapper { padding-inline-end: var(--m3e-chip-padding-end, 1rem); } ::slotted([slot="icon"]), ::slotted([slot="trailing-icon"]) { flex: none; width: 1em; font-size: var(--m3e-chip-icon-size, 1.125rem) !important; } :host(:not(:disabled):not([disabled-interactive]):not([selected])) .base { color: var(--m3e-chip-label-text-color, ${a.color.onSurface}); } :host(:not(:disabled):not([disabled-interactive]):not([selected])) ::slotted([slot="icon"]), :host(:not(:disabled):not([disabled-interactive]):not([selected])) ::slotted([slot="trailing-icon"]) { color: var(--m3e-chip-icon-color, ${a.color.primary}); } :host(:disabled) .base, :host([disabled-interactive]) .base { color: color-mix( in srgb, var(--m3e-chip-disabled-label-text-color, ${a.color.onSurface}) var(--m3e-chip-disabled-label-text-opacity, 38%), transparent ); } :host(:disabled) ::slotted([slot="icon"]), :host([disabled-interactive]) ::slotted([slot="icon"]), :host(:disabled) ::slotted([slot="trailing-icon"]), :host([disabled-interactive]) ::slotted([slot="trailing-icon"]) { color: color-mix( in srgb, var(--m3e-chip-disabled-icon-color, ${a.color.onSurface}) var(--m3e-chip-disabled-icon-opacity, 38%), transparent ); } :host([variant="elevated"]:disabled) .base, :host([variant="elevated"][disabled-interactive]) .base { background-color: color-mix( in srgb, var(--m3e-elevated-chip-disabled-container-color, ${a.color.onSurface}) var(--m3e-elevated-chip-disabled-container-opacity, 12%), transparent ); --m3e-elevation-level: var(--m3e-elevated-chip-disabled-elevation, ${a.elevation.level0}); } @media (prefers-reduced-motion) { .base { transition: none; } } @media (forced-colors: active) { .base { transition: none; } :host(:not(:disabled):not([disabled-interactive]):not([selected])) .base, :host(:not(:disabled):not([disabled-interactive]):not([selected])) ::slotted([slot="icon"]), :host(:not(:disabled):not([disabled-interactive]):not([selected])) ::slotted([slot="trailing-icon"]) { color: CanvasText; } :host(:not(:disabled):not([disabled-interactive])[variant="outlined"]) .base { outline-color: CanvasText; } :host(:disabled) .base, :host([disabled-interactive]) .base, :host(:disabled) ::slotted([slot="icon"]), :host([disabled-interactive]) ::slotted([slot="icon"]), :host(:disabled) ::slotted([slot="trailing-icon"]), :host([disabled-interactive]) ::slotted([slot="trailing-icon"]) { color: GrayText; } :host(:disabled[variant="outlined"]) .base, :host([disabled-interactive][variant="outlined"]) .base { outline-color: GrayText; } }`;h([M(".elevation")],ze.prototype,"_elevation",void 0);h([M(".focus-ring")],ze.prototype,"_focusRing",void 0);h([M(".state-layer")],ze.prototype,"_stateLayer",void 0);h([M(".ripple")],ze.prototype,"_ripple",void 0);h([b({reflect:!0})],ze.prototype,"variant",void 0);h([b()],ze.prototype,"value",null);ze=h([L("m3e-chip")],ze);var wc=class extends yt(wt(De(Be(Ze(se(W(ze,"button"))))))){_renderTrailingIcon(){return F}};wc.formAssociated=!0;wc=h([L("m3e-assist-chip")],wc);var Xa=class extends xh(P){render(){return w`<slot></slot>`}};Xa.styles=C`:host { display: inline-flex; flex-wrap: wrap; vertical-align: middle; gap: var(--m3e-chip-set-spacing, 0.5rem); outline: none; } :host([vertical]) { flex-direction: column; }`;Xa=h([L("m3e-chip-set")],Xa);var _c,fs,Su,bs=class extends gi(De(Be(Ze(se(W(ze,"radio")))))){constructor(){super(...arguments),_c.add(this),fs.set(this,e=>n(this,_c,"m",Su).call(this,e))}connectedCallback(){super.connectedCallback(),this.addEventListener("click",n(this,fs,"f"))}disconnectedCallback(){super.disconnectedCallback(),this.removeEventListener("click",n(this,fs,"f"))}update(e){super.update(e),e.has("selected")&&this.closest("m3e-filter-chip-set")?.[Z].notifySelectionChange(this)}_renderIcon(){return w`<div class="icon" aria-hidden="true"><svg class="check" viewBox="0 -960 960 960" aria-hidden="true"><path fill="currentColor" d="M382-240 154-468l57-57 171 171 367-367 57 57-424 424Z"/></svg> ${super._renderIcon()}</div>`}};fs=new WeakMap;_c=new WeakSet;Su=function(e){e.defaultPrevented||this.dispatchEvent(new Event("beforeinput",{bubbles:!0,cancelable:!0}))&&(this.selected=!this.selected,this.closest("m3e-filter-chip-set")?.[Z].notifySelectionChange(this),this.dispatchEvent(new Event("input",{bubbles:!0})),this.dispatchEvent(new Event("change",{bubbles:!0})))};bs.formAssociated=!0;bs.styles=[ze.styles,C`:host([selected]:not(:is(:state(--hide-selection), :--hide-selection))) .wrapper { padding-inline-start: var(--m3e-chip-with-icon-padding-start, 0.5rem); } .icon { display: flex; align-items: center; justify-content: center; } .check { width: 1em; font-size: var(--m3e-chip-icon-size, 1.125rem); } :host(:not(:disabled):not([disabled-interactive])) .check { color: var(--m3e-chip-selected-leading-icon-color, ${a.color.onSecondaryContainer}); } :host(:not([selected])) .check, :host(:is(:state(--hide-selection), :--hide-selection)) .check, :host(:is(:state(--hide-selection), :--hide-selection):not(:is(:state(--with-icon), :--with-icon))) .icon { display: none; } :host(:not(:is(:state(--with-icon), :--with-icon))) .icon { margin-inline-start: calc(0px - var(--m3e-chip-with-icon-padding-start, 0.5rem)); transition: margin-inline-start ${a.motion.spring.fastEffects}; } :host([selected]) .icon { margin-inline-start: 0; } :host([selected]:not(:is(:state(--hide-selection), :--hide-selection))) ::slotted([slot="icon"]) { display: none !important; } :host(:not(:disabled):not([disabled-interactive]):not([selected])) .base { color: var(--m3e-chip-unselected-label-text-color, ${a.color.onSurfaceVariant}); --m3e-ripple-color: var(--m3e-chip-unselected-ripple-color, ${a.color.onSurfaceVariant}); --m3e-state-layer-focus-color: var( --m3e-chip-unselected-state-layer-focus-color, ${a.color.onSurfaceVariant} ); --m3e-state-layer-hover-color: var( --m3e-chip-unselected-state-layer-hover-color, ${a.color.onSurfaceVariant} ); } :host(:not(:disabled):not([disabled-interactive]):not([selected])) ::slotted([slot="icon"]) { color: var(--m3e-chip-unselected-leading-icon-color, ${a.color.primary}); } :host(:not(:disabled):not([disabled-interactive]):not([selected])) ::slotted([slot="trailing-icon"]) { color: var(--m3e-chip-unselected-trailing-icon-color, ${a.color.onSurfaceVariant}); } :host(:not(:disabled):not([disabled-interactive])[selected]) .base { outline-offset: unset; outline-width: var(--m3e-chip-selected-outline-thickness, 0); color: var(--m3e-chip-selected-label-text-color, ${a.color.onSecondaryContainer}); background-color: var(--m3e-chip-selected-container-color, ${a.color.secondaryContainer}); --m3e-state-layer-hover-color: var( --m3e-chip-selected-container-hover-color, ${a.color.onSecondaryContainer} ); --m3e-state-layer-focus-color: var( --m3e-chip-selected-container-focus-color, ${a.color.onSecondaryContainer} ); --m3e-elevation-hover-level: var(--m3e-chip-selected-hover-elevation, ${a.elevation.level1}); --m3e-ripple-color: var(--m3e-chip-selected-ripple-color, ${a.color.onSecondaryContainer}); --m3e-state-layer-focus-color: var( --m3e-chip-selected-state-layer-focus-color, ${a.color.onSecondaryContainer} ); --m3e-state-layer-hover-color: var( --m3e-chip-selected-state-layer-hover-color, ${a.color.onSecondaryContainer} ); } :host(:not(:disabled):not([disabled-interactive])[selected]) ::slotted([slot="icon"]) { color: var(--m3e-chip-selected-leading-icon-color, ${a.color.onSecondaryContainer}); } :host(:not(:disabled):not([disabled-interactive]):not([selected])) ::slotted([slot="trailing-icon"]) { color: var(--m3e-chip-selected-trailing-icon-color, ${a.color.onSecondaryContainer}); } @media (prefers-reduced-motion) { .base, :host(:not(:is(:state(--with-icon), :--with-icon))) .icon { transition: none; } } @media (forced-colors: active) { :host(:not(:disabled):not([disabled-interactive]):not([selected])) .base, :host(:not(:disabled):not([disabled-interactive]):not([selected])) ::slotted([slot="icon"]), :host(:not(:disabled):not([disabled-interactive]):not([selected])) ::slotted([slot="trailing-icon"]) { color: CanvasText; } :host(:not(:disabled):not([disabled-interactive])[selected]) .base, :host(:not(:disabled):not([disabled-interactive])[selected]) ::slotted([slot="icon"]), :host(:not(:disabled):not([disabled-interactive])[selected]) ::slotted([slot="trailing-icon"]), :host(:not(:disabled):not([disabled-interactive])) .check { color: ButtonText; } :host(:not(:disabled):not([disabled-interactive])[selected]) .base { outline-offset: calc(0px - var(--m3e-outlined-chip-outline-thickness, 1px)); outline-width: var(--m3e-outlined-chip-outline-thickness, 1px); outline-color: ButtonText; } }`];bs=h([L("m3e-filter-chip")],bs);var da,cs,ku,Eu,Mu,Sc,xu,vs=class extends ph(El(Ll(Tl(se(Q(W(Xa,"radiogroup"))))))){constructor(){super(...arguments),da.add(this),cs.set(this,void 0),this[xu]=new ja().onActiveItemChange(()=>this[Z].activeItem?.focus()).withWrap().withDirectionality(G.current),this.multi=!1,this.hideSelectionIndicator=!1}get chips(){return this[Z]?.items??[]}get selected(){return this[Z]?.selectedItems??[]}get value(){let e=this.selected.filter(r=>!r.disabled).map(r=>r.value);switch(e.length){case 0:return null;case 1:return e[0];default:return e}}get[(cs=new WeakMap,da=new WeakSet,xu=Z,Dr)](){let e=this.value;if(Array.isArray(e)){let r=new FormData;for(let i of e)r.append(this.name,i);return r}return e}connectedCallback(){super.connectedCallback(),f(this,cs,G.observe(()=>this[Z].directionality=G.current),"f")}disconnectedCallback(){super.disconnectedCallback(),n(this,cs,"f")?.call(this)}update(e){super.update(e),e.has("vertical")&&(this[Z].vertical=this.vertical),e.has("disabled")&&(e.get("disabled")!==void 0||this.disabled)&&(this[Z].disabled=this.disabled),e.has("multi")&&(this.role=this.multi?"group":"radiogroup",n(this,da,"m",Sc).call(this),this[Z].multi=this.multi,this[Z].disableRovingTabIndex(this.multi)),(e.has("multi")||e.has("disabled"))&&(this.ariaDisabled=this.multi&&this.disabled?"true":null),e.has("hideSelectionIndicator")&&this.chips.forEach(r=>R(r,"--hide-selection",this.hideSelectionIndicator))}render(){return w`<slot @slotchange="${n(this,da,"m",ku)}" @keydown="${n(this,da,"m",Eu)}" @change="${n(this,da,"m",Mu)}"></slot>`}};ku=function(){let{added:e}=this[Z].setItems([...this.querySelectorAll("m3e-filter-chip")]);e.forEach(r=>R(r,"--hide-selection",this.hideSelectionIndicator)),n(this,da,"m",Sc).call(this)};Eu=function(e){this.multi||this[Z].onKeyDown(e)};Mu=function(e){e.stopPropagation(),this.dispatchEvent(new Event("change",{bubbles:!0}))};Sc=function(){this.chips.forEach(e=>e.role=this.multi?"button":"radio")};h([b({type:Boolean})],vs.prototype,"multi",void 0);h([b({attribute:"hide-selection-indicator",type:Boolean})],vs.prototype,"hideSelectionIndicator",void 0);vs=h([L("m3e-filter-chip-set")],vs);var cn,Lu,Tu,Pu,Kt=class extends Ze(se(W(ze,"row"))){constructor(){super(...arguments),cn.add(this),this.removable=!1,this.removeLabel="Remove"}connectedCallback(){super.connectedCallback(),this.removeAttribute("tabindex")}update(e){super.update(e),this.removeAttribute("tabindex"),e.has("removable")&&R(this,"--with-trailing-icon",this.removable)}render(){return w`<div class="base"><m3e-elevation class="elevation" for="cell" ?disabled="${this.disabled||this.disabledInteractive}"></m3e-elevation><m3e-state-layer class="state-layer" for="cell" ?disabled="${this.disabled||this.disabledInteractive}"></m3e-state-layer><m3e-focus-ring class="focus-ring" for="cell" ?disabled="${this.disabled}"></m3e-focus-ring><m3e-ripple class="ripple" for="cell" ?disabled="${this.disabled||this.disabledInteractive}"></m3e-ripple><div class="wrapper"><div id="cell" class="cell" role="gridcell" tabindex="${io(this.disabled?void 0:"-1")}" @keydown="${n(this,cn,"m",Pu)}"><slot name="avatar" @slotchange="${n(this,cn,"m",Lu)}"></slot>${this._renderIcon()}<div class="label">${this._renderSlot()}</div><div class="touch" aria-hidden="true"></div></div>${this._renderTrailingIcon()}</div></div>`}_renderTrailingIcon(){return this.removable?w`<span role="gridcell" class="remove"><m3e-icon-button class="remove-button" aria-label="${this.removeLabel}" size="extra-small" tabindex="-1" ?disabled="${this.disabled}" ?disabled-interactive="${this.disabledInteractive}" @click="${n(this,cn,"m",Tu)}"><slot name="remove-icon"><svg class="remove-icon" viewBox="0 -960 960 960" fill="currentColor"><path d="m256-200-56-56 224-224-224-224 56-56 224 224 224-224 56 56-224 224 224 224-56 56-224-224-224 224Z"/></svg></slot></m3e-icon-button></span>`:F}};cn=new WeakSet;Lu=function(e){R(this,"--with-avatar",he(e.target))};Tu=function(e){e.stopPropagation(),this.dispatchEvent(new Event("remove"))};Pu=function(e){if(this.removable)switch(e.key){case"Backspace":case"Delete":this.dispatchEvent(new Event("remove"));break}};Kt.formAssociated=!0;Kt.styles=[ze.styles,C`.cell { display: inline-flex; align-items: center; outline: none; column-gap: var(--m3e-chip-spacing, 0.5rem); min-width: 0; } .remove-button { --m3e-icon-button-extra-small-container-height: 1.5rem; --m3e-icon-button-extra-small-icon-size: var(--m3e-chip-icon-size, 1.125rem); width: 1.5rem; } .remove-icon { flex: none; width: var(--m3e-chip-icon-size, 1.125rem); height: var(--m3e-chip-icon-size, 1.125rem); } .touch { top: calc( 0px - calc(calc(3rem - calc(var(--m3e-chip-container-height, 2rem) + ${a.density.calc(-3)})) / 2) ); } .wrapper { height: 100%; overflow: visible; min-width: 0; } ::slotted([slot="avatar"]) { flex: none; font-size: var(--m3e-chip-avatar-size, 1.5rem); } ::slotted(m3e-avatar[slot="avatar"]) { --m3e-icon-size: var(--m3e-chip-avatar-icon-size, 1.125rem); --m3e-avatar-size: var(--m3e-chip-avatar-size, 1.5rem); --m3e-avatar-font-size: var( --m3e-chip-avatar-font-size, ${a.typescale.standard.title.small.fontSize} ); --m3e-avatar-font-weight: var( --m3e-chip-avatar-font-height, ${a.typescale.standard.title.small.fontWeight} ); --m3e-avatar-line-height: var( --m3e-chip-avatar-line-height, ${a.typescale.standard.title.small.lineHeight} ); --m3e-avatar-tracking: var(--m3e-chip-avatar-tracking, ${a.typescale.standard.title.small.tracking}); } :host(:disabled) ::slotted([slot="avatar"]), :host([disabled-interactive]) ::slotted([slot="avatar"]) { opacity: var(--m3e-chip-disabled-avatar-opacity, 38%); color: var(--m3e-chip-disabled-icon-color, ${a.color.onSurface}); } :host(:is(:state(--with-avatar), :--with-avatar)) ::slotted([slot="icon"]) { display: none; } :host(:is(:state(--with-avatar), :--with-avatar)) .wrapper { padding-inline-start: var(--m3e-chip-with-avatar-padding-start, 0.25rem); } @media (forced-colors: active) { :host(:disabled) ::slotted([slot="avatar"]), :host([disabled-interactive]) ::slotted([slot="avatar"]) { color: CanvasText; } }`];h([M(".cell")],Kt.prototype,"cell",void 0);h([M(".remove-button")],Kt.prototype,"removeButton",void 0);h([b({type:Boolean})],Kt.prototype,"removable",void 0);h([b({attribute:"remove-label"})],Kt.prototype,"removeLabel",void 0);Kt=h([L("m3e-input-chip")],Kt);var Ke,ds,gs,ys,hs,us,ms,xs,ws,yo,Ne,un,me,dn,Au,Iu,zu,Fu,Ou,Ru,Bu,Du,kc,Hu,$c=class extends yh(gh(fh(El(Ll(Tl(se(Q(W(Xa,"grid"))))))))){constructor(){super(...arguments),Ke.add(this),ds.set(this,void 0),gs.set(this,()=>n(this,Ke,"m",kc).call(this)),ys.set(this,e=>n(this,Ke,"m",Hu).call(this,e)),hs.set(this,()=>n(this,Ke,"m",Fu).call(this)),us.set(this,()=>n(this,Ke,"m",Ou).call(this)),ms.set(this,()=>n(this,Ke,"m",Ru).call(this)),xs.set(this,e=>n(this,Ke,"m",Bu).call(this,e)),ws.set(this,e=>n(this,Ke,"m",Du).call(this,e)),yo.set(this,new tn),Ne.set(this,new on().onActiveItemChange(()=>n(this,Ne,"f").activeItem?.focus()).withHomeAndEnd().withSkipPredicate(e=>!e.hasAttribute("tabindex")).withDirectionality(G.current)),un.set(this,!1),me.set(this,null),dn.set(this,0)}get chips(){return[...this.querySelectorAll("m3e-input-chip")]}get value(){let e=this.chips.filter(r=>!r.disabled).map(r=>r.value);return e.length==0?null:e}get[(ds=new WeakMap,gs=new WeakMap,ys=new WeakMap,hs=new WeakMap,us=new WeakMap,ms=new WeakMap,xs=new WeakMap,ws=new WeakMap,yo=new WeakMap,Ne=new WeakMap,un=new WeakMap,me=new WeakMap,dn=new WeakMap,Ke=new WeakSet,Dr)](){let e=this.value;if(!e)return null;let r=new FormData;for(let i of e)r.append(this.name,i);return r}get shouldLabelFloat(){return this.chips.length>0}onContainerClick(){n(this,me,"f")?.focus()}connectedCallback(){super.connectedCallback(),customElements.get("m3e-form-field")?this.closest("m3e-form-field")?.notifyControlStateChange():customElements.whenDefined("m3e-form-field").then(()=>{this.closest("m3e-form-field")?.notifyControlStateChange()}),f(this,dn,Number.parseInt(this.getAttribute("tabindex")??"0"),"f"),this.addEventListener("focus",n(this,hs,"f")),this.addEventListener("focusin",n(this,us,"f")),this.addEventListener("focusout",n(this,ms,"f")),f(this,ds,G.observe(()=>n(this,Ne,"f").directionality=G.current),"f")}disconnectedCallback(){super.disconnectedCallback(),this.removeEventListener("focus",n(this,hs,"f")),this.removeEventListener("focusin",n(this,us,"f")),this.removeEventListener("focusout",n(this,ms,"f")),n(this,ds,"f")?.call(this)}firstUpdated(e){super.firstUpdated(e),this.hasAttribute("tabindex")||this.setAttribute("tabindex",`${n(this,dn,"f")}`)}update(e){super.update(e),e.has("vertical")&&(this.ariaOrientation=null),e.has("disabled")&&(n(this,yo,"f").items.forEach(r=>r.disabled=this.disabled),n(this,me,"f")&&(n(this,me,"f").disabled=this.disabled))}render(){return w`<slot @keydown="${n(this,Ke,"m",Au)}" @slotchange="${n(this,Ke,"m",Iu)}"></slot><span role="row"><span role="gridcell"><slot name="input" @slotchange="${n(this,Ke,"m",zu)}"></slot></span></span>`}};Au=function(e){n(this,Ne,"f").onKeyDown(e)};Iu=async function(){let{added:e,removed:r}=n(this,yo,"f").setItems([...this.querySelectorAll("m3e-input-chip")]);for(let i of e)i.isUpdatePending&&await i.updateComplete,this.disabled&&(i.disabled=!0),i.addEventListener("remove",n(this,xs,"f")),i.cell.addEventListener("click",n(this,ws,"f"));r.forEach(i=>{i.removeEventListener("remove",n(this,xs,"f")),i.cell.removeEventListener("click",n(this,ws,"f"))}),n(this,Ne,"f").setItems(n(this,yo,"f").items.flatMap(i=>i.removeButton?[i.cell,i.removeButton]:[i.cell])),n(this,Ne,"f").activeItem||n(this,Ne,"f").updateActiveItem(n(this,Ne,"f").items.find(i=>i.hasAttribute("tabindex")))};zu=function(){let e=this.querySelector("input");if(n(this,me,"f")&&(n(this,me,"f").removeEventListener("change",n(this,gs,"f")),n(this,me,"f").removeEventListener("keydown",n(this,ys,"f"))),f(this,me,e,"f"),n(this,me,"f")){n(this,me,"f").disabled=this.disabled,n(this,me,"f").addEventListener("change",n(this,gs,"f")),n(this,me,"f").addEventListener("keydown",n(this,ys,"f"));let r=Object.getOwnPropertyDescriptor(HTMLInputElement.prototype,"value");Object.defineProperty(e,"value",{get:()=>r.get?.call(e),set:i=>{r.set?.call(e,i),n(this,me,"f")===e&&!n(this,un,"f")&&n(this,Ke,"m",kc).call(this)}})}};Fu=function(){setTimeout(()=>(n(this,Ne,"f").activeItem??n(this,me,"f"))?.focus())};Ou=function(){this.setAttribute("tabindex","-1")};Ru=function(){this.setAttribute("tabindex",`${n(this,dn,"f")}`)};Bu=function(e){let r=e.target,i=n(this,yo,"f").items.indexOf(r),s=n(this,yo,"f").items.find((l,c)=>c>i&&!l.disabled&&l.removable);r.remove(),n(this,Ne,"f").setActiveItem(n(this,Ne,"f").items.find(l=>l===s?.removeButton)),n(this,Ne,"f").activeItem||n(this,me,"f")?.focus(),this.dispatchEvent(new CustomEvent("change",{bubbles:!0,detail:{type:"remove",value:r.value,chip:r}}))};Du=function(e){n(this,Ne,"f").updateActiveItem(e.composedPath().find(r=>r instanceof Kt)?.cell)};kc=async function(){let e=n(this,me,"f")?.value;if(!e)return;let r=document.createElement("m3e-input-chip");if(r.removable=!0,r.appendChild(document.createTextNode(e)),this.appendChild(r),r.isUpdatePending&&await r.updateComplete,n(this,me,"f"))try{f(this,un,!0,"f"),n(this,me,"f").value=""}finally{f(this,un,!1,"f")}this.dispatchEvent(new CustomEvent("change",{bubbles:!0,detail:{type:"add",value:e,chip:r}}))};Hu=function(e){if(e.key==="Backspace"&&!n(this,me,"f")?.value){let r=[...n(this,yo,"f").items].reverse().find(i=>!i.disabled&&!i.disabledInteractive&&i.removable);r&&r.dispatchEvent(new Event("remove"))}};ho(C`m3e-input-chip-set [slot="input"]::placeholder { user-select: none; color: currentColor; transition: opacity ${a.motion.duration.extraLong1}; } m3e-input-chip-set:not(:focus-within) [slot="input"]::placeholder { opacity: 0; transition: 0s; } m3e-input-chip-set:hover [slot="input"]::placeholder { transition: 0s; } @media (prefers-reduced-motion) { m3e-input-chip-set [slot="input"]::placeholder { transition: none !important; } }`);$c.styles=[Xa.styles,C`::slotted([slot="input"]) { outline: unset; border: unset; background-color: transparent; box-shadow: none; font-family: inherit; font-size: inherit; line-height: initial; letter-spacing: inherit; color: var(--_form-field-input-color, inherit); flex: 1 1 auto; min-width: 0; padding: unset; } ::slotted(m3e-input-chip) { min-width: 0; } span[role="row"], span[role="gridcell"] { display: contents; }`];$c=h([L("m3e-input-chip-set")],$c);var Cc=class extends yt(wt(De(Be(Ze(se(W(ze,"button"))))))){_renderTrailingIcon(){return F}};Cc.formAssociated=!0;Cc=h([L("m3e-suggestion-chip")],Cc);var nb=C`:host { display: inline-block; outline: none; user-select: none; -webkit-tap-highlight-color: rgba(0, 0, 0, 0); } .base { box-sizing: border-box; vertical-align: middle; display: inline-flex; align-items: center; justify-content: center; position: relative; width: 100%; transition: ${o(`background-color ${a.motion.duration.short4} ${a.motion.easing.standard}`)}; } .touch { position: absolute; height: 3rem; left: 0; right: 0; } .wrapper { width: 100%; overflow: hidden; display: inline-flex; align-items: center; } .label { white-space: nowrap; transition: ${o(`color ${a.motion.duration.short4} ${a.motion.easing.standard}`)}; } .icon { transition: ${o(`color ${a.motion.duration.short4} ${a.motion.easing.standard}`)}; } :host(:not(:disabled):not([disabled-interactive])) { cursor: pointer; } :host([disabled-interactive]) { cursor: not-allowed; } .close-icon, ::slotted(:not([slot])), ::slotted([slot="close-icon"]) { font-size: inherit !important; flex: none; } .close-icon, ::slotted(svg:not([slot])), ::slotted(svg[slot="close-icon"]) { width: 1em; height: 1em; } .base.with-menu ::slotted([slot="label"]), .base:not(.with-menu) ::slotted([slot="close-icon"]), .base:not(.with-menu) .close-icon, :host([aria-expanded="true"]) .base.with-menu ::slotted(:not([slot])), :host([aria-expanded="false"]) .base.with-menu ::slotted([slot="close-icon"]), :host([aria-expanded="false"]) .base.with-menu .close-icon { display: none; } :host([aria-expanded="true"]) .base.with-menu { border-radius: var(--m3e-fab-menu-close-button-container-shape, ${a.shape.corner.full}); height: calc(var(--m3e-fab-menu-close-button-container-height, 3.5rem) + ${a.density.calc(-3)}); } :host([aria-expanded="true"]) .base.with-menu .wrapper { padding-inline-start: calc(var(--m3e-fab-menu-close-button-leading-space, 1rem) + ${a.density.calc(-3)}); padding-inline-end: calc(var(--m3e-fab-menu-close-button-trailing-space, 1rem) + ${a.density.calc(-3)}); } :host([aria-expanded="true"]) .base.with-menu .icon { font-size: calc(var(--m3e-fab-menu-close-button-icon-size, 1.5rem) + ${a.density.calc(-3)}); --m3e-icon-size: calc(var(--m3e-fab-menu-close-button-icon-size, 1.5rem) + ${a.density.calc(-3)}); } .base.with-menu { transition: height ${a.motion.spring.fastSpatial}; } .base.with-menu .wrapper { transition: padding ${a.motion.spring.fastSpatial}; } a { all: unset; display: block; position: absolute; top: 0px; left: 0px; right: 0px; bottom: 0px; z-index: 1; } @media (forced-colors: active) { .base, .icon { transition: none; } .base { outline-style: solid; } :host([variant]:not(:disabled):not([disabled-interactive])) .base { background-color: ButtonFace; outline-color: ButtonText; } :host([variant]:not(:disabled):not([disabled-interactive])) .label, :host([variant]:not(:disabled):not([disabled-interactive])) .icon { color: ButtonText; } :host([variant]:disabled) .base, :host([variant][disabled-interactive]) .base { outline-color: GrayText; background-color: unset; } :host([variant]:disabled) .label, :host([variant][disabled-interactive]) .label, :host([variant]:disabled) .icon, :host([variant][disabled-interactive]) .icon { color: GrayText; } :host([size="small"]) .base { outline-offset: calc(0px - var(--m3e-button-small-outline-thickness, 1px)); outline-width: var(--m3e-button-small-outline-thickness, 1px); } :host([size="medium"]) .base { outline-offset: calc(0px - var(--m3e-button-medium-outline-thickness, 1px)); outline-width: var(--m3e-button-medium-outline-thickness, 1px); } :host([size="large"]) .base { outline-offset: calc(0px - var(--m3e-button-large-outline-thickness, 2px)); outline-width: var(--m3e-button-large-outline-thickness, 2px); } } @media (prefers-reduced-motion) { .base, .base.resting, .base.pressed, .label, .icon { transition: none; } }`,Fe={small:{containerHeight:o(`calc(var(--m3e-fab-small-container-height, var(--m3e-fab-container-height, 3.5rem)) + ${a.density.calc(-3)})`),labelTextFontSize:o(`var(--m3e-fab-small-label-text-font-size, var(--m3e-fab-label-text-font-size, ${a.typescale.standard.title.medium.fontSize}))`),labelTextFontWeight:o(`var(--m3e-fab-small-label-text-font-weight, var(--m3e-fab-label-text-font-weight, ${a.typescale.standard.title.medium.fontWeight}))`),labelTextLineHeight:o(`var(--m3e-fab-small-label-text-line-height, var(--m3e-fab-label-text-line-height, ${a.typescale.standard.title.medium.lineHeight}))`),labelTextTracking:o(`var(--m3e-fab-small-label-text-tracking, var(--m3e-fab-label-text-tracking, ${a.typescale.standard.title.medium.tracking}))`),iconSize:o("var(--m3e-fab-small-icon-size, var(--m3e-fab-icon-size, 1.5rem))"),extendedIconSize:o("var(--m3e-fab-small-icon-size, var(--m3e-fab-icon-size, 1.5rem))"),shape:o(`var(--m3e-fab-small-shape, var(--m3e-fab-shape, ${a.shape.corner.large}))`),leadingSpace:o(`calc(var(--m3e-fab-small-leading-space, var(--m3e-fab-leading-space, 1rem)) + calc(${a.density.calc(-3)} / 2))`),trailingSpace:o(`calc(var(--m3e-fab-small-trailing-space, var(--m3e-fab-trailing-space, 1rem)) + calc(${a.density.calc(-3)} / 2))`),iconLabelSpace:o("var(--m3e-fab-small-icon-label-space, var(--m3e-fab-icon-label-space, 0.5rem))"),extendedLeadingSpace:o("var(--m3e-fab-small-leading-space, var(--m3e-fab-leading-space, 1rem))"),extendedTrailingSpace:o("var(--m3e-fab-small-trailing-space, var(--m3e-fab-trailing-space, 1rem))")},medium:{containerHeight:o(`calc(var(--m3e-fab-medium-container-height, var(--m3e-fab-container-height, 5rem)) + ${a.density.calc(-3)})`),labelTextFontSize:o(`var(--m3e-fab-medium-label-text-font-size, var(--m3e-fab-label-text-font-size, ${a.typescale.standard.title.large.fontSize}))`),labelTextFontWeight:o(`var(--m3e-fab-medium-label-text-font-weight, var(--m3e-fab-label-text-font-weight, ${a.typescale.standard.title.large.fontWeight}))`),labelTextLineHeight:o(`var(--m3e-fab-medium-label-text-line-height, var(--m3e-fab-label-text-line-height, ${a.typescale.standard.title.large.lineHeight}))`),labelTextTracking:o(`var(--m3e-fab-medium-label-text-tracking, var(--m3e-fab-label-text-tracking, ${a.typescale.standard.title.large.tracking}))`),iconSize:o("var(--m3e-fab-medium-icon-size, var(--m3e-fab-icon-size, 1.75rem))"),extendedIconSize:o("var(--m3e-fab-medium-icon-size, var(--m3e-fab-icon-size, 1.75rem))"),shape:o(`var(--m3e-fab-medium-shape, var(--m3e-fab-shape, ${a.shape.corner.largeIncreased}))`),leadingSpace:o(`calc(var(--m3e-fab-medium-leading-space, var(--m3e-fab-leading-space, 1.625rem)) + calc(${a.density.calc(-3)} / 2))`),trailingSpace:o(`calc(var(--m3e-fab-medium-trailing-space, var(--m3e-fab-trailing-space, 1.625rem)) + calc(${a.density.calc(-3)} / 2))`),iconLabelSpace:o("var(--m3e-fab-medium-icon-label-space, var(--m3e-fab-icon-label-space, 0.75rem))"),extendedLeadingSpace:o("var(--m3e-fab-medium-leading-space, var(--m3e-fab-leading-space, 1.625rem))"),extendedTrailingSpace:o("var(--m3e-fab-medium-trailing-space, var(--m3e-fab-trailing-space, 1.625rem))")},large:{containerHeight:o(`calc(var(--m3e-fab-large-container-height, var(--m3e-fab-container-height, 6rem)) + ${a.density.calc(-3)})`),labelTextFontSize:o(`var(--m3e-fab-large-label-text-font-size, var(--m3e-fab-label-text-font-size, ${a.typescale.standard.headline.small.fontSize}))`),labelTextFontWeight:o(`var(--m3e-fab-large-label-text-font-weight, var(--m3e-fab-label-text-font-weight, ${a.typescale.standard.headline.small.fontWeight}))`),labelTextLineHeight:o(`var(--m3e-fab-large-label-text-line-height, var(--m3e-fab-label-text-line-height, ${a.typescale.standard.headline.small.lineHeight}))`),labelTextTracking:o(`var(--m3e-fab-large-label-text-tracking, var(--m3e-fab-label-text-tracking, ${a.typescale.standard.headline.small.tracking}))`),iconSize:o("var(--m3e-fab-large-icon-size, var(--m3e-fab-icon-size, 2.25rem))"),extendedIconSize:o("var(--m3e-fab-large-icon-size, var(--m3e-fab-icon-size, 2.25rem))"),shape:o(`var(--m3e-fab-large-shape, var(--m3e-fab-shape, ${a.shape.corner.extraLarge}))`),leadingSpace:o(`calc(var(--m3e-fab-large-leading-space, var(--m3e-fab-leading-space, 1.75rem)) + calc(${a.density.calc(-3)} / 2))`),trailingSpace:o(`calc(var(--m3e-fab-large-trailing-space, var(--m3e-fab-trailing-space, 1.75rem)) + calc(${a.density.calc(-3)} / 2))`),iconLabelSpace:o("var(--m3e-fab-large-icon-label-space, var(--m3e-fab-icon-label-space, 1rem))"),extendedLeadingSpace:o("var(--m3e-fab-large-leading-space, var(--m3e-fab-leading-space, 1.75rem))"),extendedTrailingSpace:o("var(--m3e-fab-large-trailing-space, var(--m3e-fab-trailing-space, 1.75rem))")}};function Ec(t){return C`:host([size="${o(t)}"]) .base { height: ${Fe[t].containerHeight}; } :host([size="${o(t)}"]) .base { border-radius: ${Fe[t].shape}; } :host([size="${o(t)}"]) .label { font-size: ${Fe[t].labelTextFontSize}; font-weight: ${Fe[t].labelTextFontWeight}; line-height: ${Fe[t].labelTextLineHeight}; letter-spacing: ${Fe[t].labelTextTracking}; } :host([size="${o(t)}"]:not([extended])) .wrapper { padding-inline-start: ${Fe[t].leadingSpace}; padding-inline-end: ${Fe[t].trailingSpace}; } :host([size="${o(t)}"]:not([extended])) .icon { font-size: ${Fe[t].iconSize}; --m3e-icon-size: ${Fe[t].iconSize}; } :host([size="${o(t)}"][extended]) .wrapper { padding-inline-start: ${Fe[t].extendedLeadingSpace}; padding-inline-end: ${Fe[t].extendedTrailingSpace}; column-gap: ${Fe[t].iconLabelSpace}; } :host([size="${o(t)}"][extended]) .icon { font-size: ${Fe[t].extendedIconSize}; --m3e-icon-size: ${Fe[t].extendedIconSize}; }`}var ib=[Ec("small"),Ec("medium"),Ec("large")],q={primary:{labelTextColor:o(`var(--m3e-primary-fab-label-text-color, var(--m3e-fab-label-text-color, ${a.color.onPrimary}))`),iconColor:o(`var(--m3e-primary-fab-icon-color, var(--m3e-fab-icon-color, ${a.color.onPrimary}))`),containerColor:o(`var(--m3e-primary-fab-container-color, var(--m3e-fab-container-color, ${a.color.primary}))`),containerElevation:o(`var(--m3e-primary-fab-container-elevation, var(--m3e-fab-container-elevation, ${a.elevation.level3}))`),loweredContainerElevation:o(`var(--m3e-primary-fab-lowered-container-elevation, var(--m3e-fab-lowered-container-elevation, ${a.elevation.level2}))`),disabled:{containerColor:o(`var(--m3e-primary-fab-disabled-container-color, var(--m3e-fab-disabled-container-color, ${a.color.onSurface}))`),containerOpacity:o("var(--m3e-primary-fab-disabled-container-opacity, var(--m3e-fab-disabled-container-opacity, 10%))"),iconColor:o(`var(--m3e-primary-fab-disabled-icon-color, var(--m3e-fab-disabled-icon-color, ${a.color.onSurface}))`),iconOpacity:o("var(--m3e-primary-fab-disabled-icon-opacity, var(--m3e-fab-disabled-icon-opacity, 38%))"),labelTextColor:o(`var(--m3e-primary-fab-disabled-label-text-color, var(--m3e-fab-disabled-label-text-color, ${a.color.onSurface}))`),labelTextOpacity:o("var(--m3e-primary-fab-disabled-label-text-opacity, var(--m3e-fab-disabled-label-text-opacity, 38%))"),containerElevation:o(`var(--m3e-primary-fab-disabled-container-elevation, var(--m3e-fab-disabled-container-elevation, ${a.elevation.level0}))`),loweredContainerElevation:o(`var(--m3e-primary-fab-lowered-disabled-container-elevation, var(--m3e-fab-lowered-disabled-container-elevation, ${a.elevation.level0}))`)},hover:{iconColor:o(`var(--m3e-primary-fab-hover-icon-color, var(--m3e-fab-hover-icon-color, ${a.color.onPrimary}))`),labelTextColor:o(`var(--m3e-primary-fab-hover-label-text-color, var(--m3e-fab-hover-label-text-color, ${a.color.onPrimary}))`),stateLayerColor:o(`var(--m3e-primary-fab-hover-state-layer-color, var(--m3e-fab-hover-state-layer-color, ${a.color.onPrimary}))`),stateLayerOpacity:o(`var(--m3e-primary-fab-hover-state-layer-opacity, var(--m3e-fab-hover-state-layer-opacity, ${a.state.hoverStateLayerOpacity}))`),containerElevation:o(`var(--m3e-primary-fab-hover-container-elevation, var(--m3e-fab-hover-container-elevation, ${a.elevation.level4}))`),loweredContainerElevation:o(`var(--m3e-primary-fab-lowered-hover-container-elevation, var(--m3e-fab-lowered-hover-container-elevation, ${a.elevation.level3}))`)},focus:{iconColor:o(`var(--m3e-primary-fab-focus-icon-color, var(--m3e-fab-focus-icon-color, ${a.color.onPrimary}))`),labelTextColor:o(`var(--m3e-primary-fab-focus-label-text-color, var(--m3e-fab-focus-label-text-color, ${a.color.onPrimary}))`),stateLayerColor:o(`var(--m3e-primary-fab-focus-state-layer-color, var(--m3e-fab-focus-state-layer-color, ${a.color.onPrimary}))`),stateLayerOpacity:o(`var(--m3e-primary-fab-focus-state-layer-opacity, var(--m3e-fab-focus-state-layer-opacity, ${a.state.focusStateLayerOpacity}))`),containerElevation:o(`var(--m3e-primary-fab-focus-container-elevation, var(--m3e-fab-focus-container-elevation, ${a.elevation.level3}))`),loweredContainerElevation:o(`var(--m3e-primary-fab-lowered-focus-container-elevation, var(--m3e-fab-lowered-focus-container-elevation, ${a.elevation.level2}))`)},pressed:{iconColor:o(`var(--m3e-primary-fab-pressed-icon-color, var(--m3e-fab-pressed-icon-color, ${a.color.onPrimary}))`),labelTextColor:o(`var(--m3e-primary-fab-pressed-label-text-color, var(--m3e-fab-pressed-label-text-color, ${a.color.onPrimary}))`),stateLayerColor:o(`var(--m3e-primary-fab-pressed-state-layer-color, var(--m3e-fab-pressed-state-layer-color, ${a.color.onPrimary}))`),stateLayerOpacity:o(`var(--m3e-primary-fab-pressed-state-layer-opacity, var(--m3e-fab-pressed-state-layer-opacity, ${a.state.pressedStateLayerOpacity}))`),containerElevation:o(`var(--m3e-primary-fab-pressed-container-elevation, var(--m3e-fab-pressed-container-elevation, ${a.elevation.level3}))`),loweredContainerElevation:o(`var(--m3e-primary-fab-lowered-pressed-container-elevation, var(--m3e-fab-lowered-pressed-container-elevation, ${a.elevation.level2}))`)}},secondary:{labelTextColor:o(`var(--m3e-secondary-fab-label-text-color, var(--m3e-fab-label-text-color, ${a.color.onSecondary}))`),iconColor:o(`var(--m3e-secondary-fab-icon-color, var(--m3e-fab-icon-color, ${a.color.onSecondary}))`),containerColor:o(`var(--m3e-secondary-fab-container-color, var(--m3e-fab-container-color, ${a.color.secondary}))`),containerElevation:o(`var(--m3e-secondary-fab-container-elevation, var(--m3e-fab-container-elevation, ${a.elevation.level3}))`),loweredContainerElevation:o(`var(--m3e-secondary-fab-lowered-container-elevation, var(--m3e-fab-lowered-container-elevation, ${a.elevation.level2}))`),disabled:{containerColor:o(`var(--m3e-secondary-fab-disabled-container-color, var(--m3e-fab-disabled-container-color, ${a.color.onSurface}))`),containerOpacity:o("var(--m3e-secondary-fab-disabled-container-opacity, var(--m3e-fab-disabled-container-opacity, 10%))"),iconColor:o(`var(--m3e-secondary-fab-disabled-icon-color, var(--m3e-fab-disabled-icon-color, ${a.color.onSurface}))`),iconOpacity:o("var(--m3e-secondary-fab-disabled-icon-opacity, var(--m3e-fab-disabled-icon-opacity, 38%))"),labelTextColor:o(`var(--m3e-secondary-fab-disabled-label-text-color, var(--m3e-fab-disabled-label-text-color, ${a.color.onSurface}))`),labelTextOpacity:o("var(--m3e-secondary-fab-disabled-label-text-opacity, var(--m3e-fab-disabled-label-text-opacity, 38%))"),containerElevation:o(`var(--m3e-secondary-fab-disabled-container-elevation, var(--m3e-fab-disabled-container-elevation, ${a.elevation.level0}))`),loweredContainerElevation:o(`var(--m3e-secondary-fab-lowered-disabled-container-elevation, var(--m3e-fab-lowered-disabled-container-elevation, ${a.elevation.level0}))`)},hover:{iconColor:o(`var(--m3e-secondary-fab-hover-icon-color, var(--m3e-fab-hover-icon-color, ${a.color.onSecondary}))`),labelTextColor:o(`var(--m3e-secondary-fab-hover-label-text-color, var(--m3e-fab-hover-label-text-color, ${a.color.onSecondary}))`),stateLayerColor:o(`var(--m3e-secondary-fab-hover-state-layer-color, var(--m3e-fab-hover-state-layer-color, ${a.color.onSecondary}))`),stateLayerOpacity:o(`var(--m3e-secondary-fab-hover-state-layer-opacity, var(--m3e-fab-hover-state-layer-opacity, ${a.state.hoverStateLayerOpacity}))`),containerElevation:o(`var(--m3e-secondary-fab-hover-container-elevation, var(--m3e-fab-hover-container-elevation, ${a.elevation.level4}))`),loweredContainerElevation:o(`var(--m3e-secondary-fab-lowered-hover-container-elevation, var(--m3e-fab-lowered-hover-container-elevation, ${a.elevation.level3}))`)},focus:{iconColor:o(`var(--m3e-secondary-fab-focus-icon-color, var(--m3e-fab-focus-icon-color, ${a.color.onSecondary}))`),labelTextColor:o(`var(--m3e-secondary-fab-focus-label-text-color, var(--m3e-fab-focus-label-text-color, ${a.color.onSecondary}))`),stateLayerColor:o(`var(--m3e-secondary-fab-focus-state-layer-color, var(--m3e-fab-focus-state-layer-color, ${a.color.onSecondary}))`),stateLayerOpacity:o(`var(--m3e-secondary-fab-focus-state-layer-opacity, var(--m3e-fab-focus-state-layer-opacity, ${a.state.focusStateLayerOpacity}))`),containerElevation:o(`var(--m3e-secondary-fab-focus-container-elevation, var(--m3e-fab-focus-container-elevation, ${a.elevation.level3}))`),loweredContainerElevation:o(`var(--m3e-secondary-fab-lowered-focus-container-elevation, var(--m3e-fab-lowered-focus-container-elevation, ${a.elevation.level2}))`)},pressed:{iconColor:o(`var(--m3e-secondary-fab-pressed-icon-color, var(--m3e-fab-pressed-icon-color, ${a.color.onSecondary}))`),labelTextColor:o(`var(--m3e-secondary-fab-pressed-label-text-color, var(--m3e-fab-pressed-label-text-color, ${a.color.onSecondary}))`),stateLayerColor:o(`var(--m3e-secondary-fab-pressed-state-layer-color, var(--m3e-fab-pressed-state-layer-color, ${a.color.onSecondary}))`),stateLayerOpacity:o(`var(--m3e-secondary-fab-pressed-state-layer-opacity, var(--m3e-fab-pressed-state-layer-opacity, ${a.state.pressedStateLayerOpacity}))`),containerElevation:o(`var(--m3e-secondary-fab-pressed-container-elevation, var(--m3e-fab-pressed-container-elevation, ${a.elevation.level3}))`),loweredContainerElevation:o(`var(--m3e-secondary-fab-lowered-pressed-container-elevation, var(--m3e-fab-lowered-pressed-container-elevation, ${a.elevation.level2}))`)}},tertiary:{labelTextColor:o(`var(--m3e-tertiary-fab-label-text-color, var(--m3e-fab-label-text-color, ${a.color.onTertiary}))`),iconColor:o(`var(--m3e-tertiary-fab-icon-color, var(--m3e-fab-icon-color, ${a.color.onTertiary}))`),containerColor:o(`var(--m3e-tertiary-fab-container-color, var(--m3e-fab-container-color, ${a.color.tertiary}))`),containerElevation:o(`var(--m3e-tertiary-fab-container-elevation, var(--m3e-fab-container-elevation, ${a.elevation.level3}))`),loweredContainerElevation:o(`var(--m3e-tertiary-fab-lowered-container-elevation, var(--m3e-fab-lowered-container-elevation, ${a.elevation.level2}))`),disabled:{containerColor:o(`var(--m3e-tertiary-fab-disabled-container-color, var(--m3e-fab-disabled-container-color, ${a.color.onSurface}))`),containerOpacity:o("var(--m3e-tertiary-fab-disabled-container-opacity, var(--m3e-fab-disabled-container-opacity, 10%))"),iconColor:o(`var(--m3e-tertiary-fab-disabled-icon-color, var(--m3e-fab-disabled-icon-color, ${a.color.onSurface}))`),iconOpacity:o("var(--m3e-tertiary-fab-disabled-icon-opacity, var(--m3e-fab-disabled-icon-opacity, 38%))"),labelTextColor:o(`var(--m3e-tertiary-fab-disabled-label-text-color, var(--m3e-fab-disabled-label-text-color, ${a.color.onSurface}))`),labelTextOpacity:o("var(--m3e-tertiary-fab-disabled-label-text-opacity, var(--m3e-fab-disabled-label-text-opacity, 38%))"),containerElevation:o(`var(--m3e-tertiary-fab-disabled-container-elevation, var(--m3e-fab-disabled-container-elevation, ${a.elevation.level0}))`),loweredContainerElevation:o(`var(--m3e-tertiary-fab-lowered-disabled-container-elevation, var(--m3e-fab-lowered-disabled-container-elevation, ${a.elevation.level0}))`)},hover:{iconColor:o(`var(--m3e-tertiary-fab-hover-icon-color, var(--m3e-fab-hover-icon-color, ${a.color.onTertiary}))`),labelTextColor:o(`var(--m3e-tertiary-fab-hover-label-text-color, var(--m3e-fab-hover-label-text-color, ${a.color.onTertiary}))`),stateLayerColor:o(`var(--m3e-tertiary-fab-hover-state-layer-color, var(--m3e-fab-hover-state-layer-color, ${a.color.onTertiary}))`),stateLayerOpacity:o(`var(--m3e-tertiary-fab-hover-state-layer-opacity, var(--m3e-fab-hover-state-layer-opacity, ${a.state.hoverStateLayerOpacity}))`),containerElevation:o(`var(--m3e-tertiary-fab-hover-container-elevation, var(--m3e-fab-hover-container-elevation, ${a.elevation.level4}))`),loweredContainerElevation:o(`var(--m3e-tertiary-fab-lowered-hover-container-elevation, var(--m3e-fab-lowered-hover-container-elevation, ${a.elevation.level3}))`)},focus:{iconColor:o(`var(--m3e-tertiary-fab-focus-icon-color, var(--m3e-fab-focus-icon-color, ${a.color.onTertiary}))`),labelTextColor:o(`var(--m3e-tertiary-fab-focus-label-text-color, var(--m3e-fab-focus-label-text-color, ${a.color.onTertiary}))`),stateLayerColor:o(`var(--m3e-tertiary-fab-focus-state-layer-color, var(--m3e-fab-focus-state-layer-color, ${a.color.onTertiary}))`),stateLayerOpacity:o(`var(--m3e-tertiary-fab-focus-state-layer-opacity, var(--m3e-fab-focus-state-layer-opacity, ${a.state.focusStateLayerOpacity}))`),containerElevation:o(`var(--m3e-tertiary-fab-focus-container-elevation, var(--m3e-fab-focus-container-elevation, ${a.elevation.level3}))`),loweredContainerElevation:o(`var(--m3e-tertiary-fab-lowered-focus-container-elevation, var(--m3e-fab-lowered-focus-container-elevation, ${a.elevation.level2}))`)},pressed:{iconColor:o(`var(--m3e-tertiary-fab-pressed-icon-color, var(--m3e-fab-pressed-icon-color, ${a.color.onTertiary}))`),labelTextColor:o(`var(--m3e-tertiary-fab-pressed-label-text-color, var(--m3e-fab-pressed-label-text-color, ${a.color.onTertiary}))`),stateLayerColor:o(`var(--m3e-tertiary-fab-pressed-state-layer-color, var(--m3e-fab-pressed-state-layer-color, ${a.color.onTertiary}))`),stateLayerOpacity:o(`var(--m3e-tertiary-fab-pressed-state-layer-opacity, var(--m3e-fab-pressed-state-layer-opacity, ${a.state.pressedStateLayerOpacity}))`),containerElevation:o(`var(--m3e-tertiary-fab-pressed-container-elevation, var(--m3e-fab-pressed-container-elevation, ${a.elevation.level3}))`),loweredContainerElevation:o(`var(--m3e-tertiary-fab-lowered-pressed-container-elevation, var(--m3e-fab-lowered-pressed-container-elevation, ${a.elevation.level2}))`)}},"primary-container":{labelTextColor:o(`var(--m3e-primary-container-fab-label-text-color, var(--m3e-primary-container-fab-label-text-color, ${a.color.onPrimaryContainer}))`),iconColor:o(`var(--m3e-primary-container-fab-icon-color, var(--m3e-primary-container-fab-icon-color, ${a.color.onPrimaryContainer}))`),containerColor:o(`var(--m3e-primary-container-fab-container-color, var(--m3e-fab-container-color, ${a.color.primaryContainer}))`),containerElevation:o(`var(--m3e-primary-container-fab-container-elevation, var(--m3e-fab-container-elevation, ${a.elevation.level3}))`),loweredContainerElevation:o(`var(--m3e-primary-container-fab-lowered-container-elevation, var(--m3e-fab-lowered-container-elevation, ${a.elevation.level2}))`),disabled:{containerColor:o(`var(--m3e-primary-container-fab-disabled-container-color, var(--m3e-fab-disabled-container-color, ${a.color.onSurface}))`),containerOpacity:o("var(--m3e-primary-container-fab-disabled-container-opacity, var(--m3e-fab-disabled-container-opacity, 10%))"),iconColor:o(`var(--m3e-primary-container-fab-disabled-icon-color, var(--m3e-fab-disabled-icon-color, ${a.color.onSurface}))`),iconOpacity:o("var(--m3e-primary-container-fab-disabled-icon-opacity, var(--m3e-fab-disabled-icon-opacity, 38%))"),labelTextColor:o(`var(--m3e-primary-container-fab-disabled-label-text-color, var(--m3e-fab-disabled-label-text-color, ${a.color.onSurface}))`),labelTextOpacity:o("var(--m3e-primary-container-fab-disabled-label-text-opacity, var(--m3e-fab-disabled-label-text-opacity, 38%))"),containerElevation:o(`var(--m3e-primary-container-fab-disabled-container-elevation, var(--m3e-fab-disabled-container-elevation, ${a.elevation.level0}))`),loweredContainerElevation:o(`var(--m3e-primary-container-fab-lowered-disabled-container-elevation, var(--m3e-fab-lowered-disabled-container-elevation, ${a.elevation.level0}))`)},hover:{iconColor:o(`var(--m3e-primary-container-fab-hover-icon-color, var(--m3e-fab-hover-icon-color, ${a.color.onPrimaryContainer}))`),labelTextColor:o(`var(--m3e-primary-container-fab-hover-label-text-color, var(--m3e-fab-hover-label-text-color, ${a.color.onPrimaryContainer}))`),stateLayerColor:o(`var(--m3e-primary-container-fab-hover-state-layer-color, var(--m3e-fab-hover-state-layer-color, ${a.color.onPrimaryContainer}))`),stateLayerOpacity:o(`var(--m3e-primary-container-fab-hover-state-layer-opacity, var(--m3e-fab-hover-state-layer-opacity, ${a.state.hoverStateLayerOpacity}))`),containerElevation:o(`var(--m3e-primary-container-fab-hover-container-elevation, var(--m3e-fab-hover-container-elevation, ${a.elevation.level4}))`),loweredContainerElevation:o(`var(--m3e-primary-container-fab-lowered-hover-container-elevation, var(--m3e-fab-lowered-hover-container-elevation, ${a.elevation.level3}))`)},focus:{iconColor:o(`var(--m3e-primary-container-fab-focus-icon-color, var(--m3e-fab-focus-icon-color, ${a.color.onPrimaryContainer}))`),labelTextColor:o(`var(--m3e-primary-container-fab-focus-label-text-color, var(--m3e-fab-focus-label-text-color, ${a.color.onPrimaryContainer}))`),stateLayerColor:o(`var(--m3e-primary-container-fab-focus-state-layer-color, var(--m3e-fab-focus-state-layer-color, ${a.color.onPrimaryContainer}))`),stateLayerOpacity:o(`var(--m3e-primary-container-fab-focus-state-layer-opacity, var(--m3e-fab-focus-state-layer-opacity, ${a.state.focusStateLayerOpacity}))`),containerElevation:o(`var(--m3e-primary-container-fab-focus-container-elevation, var(--m3e-fab-focus-container-elevation, ${a.elevation.level3}))`),loweredContainerElevation:o(`var(--m3e-primary-container-fab-lowered-focus-container-elevation, var(--m3e-fab-lowered-focus-container-elevation, ${a.elevation.level2}))`)},pressed:{iconColor:o(`var(--m3e-primary-container-fab-pressed-icon-color, var(--m3e-fab-pressed-icon-color, ${a.color.onPrimaryContainer}))`),labelTextColor:o(`var(--m3e-primary-container-fab-pressed-label-text-color, var(--m3e-fab-pressed-label-text-color, ${a.color.onPrimaryContainer}))`),stateLayerColor:o(`var(--m3e-primary-container-fab-pressed-state-layer-color, var(--m3e-fab-pressed-state-layer-color, ${a.color.onPrimaryContainer}))`),stateLayerOpacity:o(`var(--m3e-primary-container-fab-pressed-state-layer-opacity, var(--m3e-fab-pressed-state-layer-opacity, ${a.state.pressedStateLayerOpacity}))`),containerElevation:o(`var(--m3e-primary-container-fab-pressed-container-elevation, var(--m3e-fab-pressed-container-elevation, ${a.elevation.level3}))`),loweredContainerElevation:o(`var(--m3e-primary-container-fab-lowered-pressed-container-elevation, var(--m3e-fab-lowered-pressed-container-elevation, ${a.elevation.level2}))`)}},"secondary-container":{labelTextColor:o(`var(--m3e-secondary-container-fab-label-text-color, var(--m3e-fab-label-text-color, ${a.color.onSecondaryContainer}))`),iconColor:o(`var(--m3e-secondary-container-fab-icon-color, var(--m3e-fab-icon-color, ${a.color.onSecondaryContainer}))`),containerColor:o(`var(--m3e-secondary-container-fab-container-color, var(--m3e-fab-container-color, ${a.color.secondaryContainer}))`),containerElevation:o(`var(--m3e-secondary-container-fab-container-elevation, var(--m3e-fab-container-elevation, ${a.elevation.level3}))`),loweredContainerElevation:o(`var(--m3e-secondary-container-fab-lowered-container-elevation, var(--m3e-fab-lowered-container-elevation, ${a.elevation.level2}))`),disabled:{containerColor:o(`var(--m3e-secondary-container-fab-disabled-container-color, var(--m3e-fab-disabled-container-color, ${a.color.onSurface}))`),containerOpacity:o("var(--m3e-secondary-container-fab-disabled-container-opacity, var(--m3e-fab-disabled-container-opacity, 10%))"),iconColor:o(`var(--m3e-secondary-container-fab-disabled-icon-color, var(--m3e-fab-disabled-icon-color, ${a.color.onSurface}))`),iconOpacity:o("var(--m3e-secondary-container-fab-disabled-icon-opacity, var(--m3e-fab-disabled-icon-opacity, 38%))"),labelTextColor:o(`var(--m3e-secondary-container-fab-disabled-label-text-color, var(--m3e-fab-disabled-label-text-color, ${a.color.onSurface}))`),labelTextOpacity:o("var(--m3e-secondary-container-fab-disabled-label-text-opacity, var(--m3e-fab-disabled-label-text-opacity, 38%))"),containerElevation:o(`var(--m3e-secondary-container-fab-disabled-container-elevation, var(--m3e-fab-disabled-container-elevation, ${a.elevation.level0}))`),loweredContainerElevation:o(`var(--m3e-secondary-container-fab-lowered-disabled-container-elevation, var(--m3e-fab-lowered-disabled-container-elevation, ${a.elevation.level0}))`)},hover:{iconColor:o(`var(--m3e-secondary-container-fab-hover-icon-color, var(--m3e-fab-hover-icon-color, ${a.color.onSecondaryContainer}))`),labelTextColor:o(`var(--m3e-secondary-container-fab-hover-label-text-color, var(--m3e-fab-hover-label-text-color, ${a.color.onSecondaryContainer}))`),stateLayerColor:o(`var(--m3e-secondary-container-fab-hover-state-layer-color, var(--m3e-fab-hover-state-layer-color, ${a.color.onSecondaryContainer}))`),stateLayerOpacity:o(`var(--m3e-secondary-container-fab-hover-state-layer-opacity, var(--m3e-fab-hover-state-layer-opacity, ${a.state.hoverStateLayerOpacity}))`),containerElevation:o(`var(--m3e-secondary-container-fab-hover-container-elevation, var(--m3e-fab-hover-container-elevation, ${a.elevation.level4}))`),loweredContainerElevation:o(`var(--m3e-secondary-container-fab-lowered-hover-container-elevation, var(--m3e-fab-lowered-hover-container-elevation, ${a.elevation.level3}))`)},focus:{iconColor:o(`var(--m3e-secondary-container-fab-focus-icon-color, var(--m3e-fab-focus-icon-color, ${a.color.onSecondaryContainer}))`),labelTextColor:o(`var(--m3e-secondary-container-fab-focus-label-text-color, var(--m3e-fab-focus-label-text-color, ${a.color.onSecondaryContainer}))`),stateLayerColor:o(`var(--m3e-secondary-container-fab-focus-state-layer-color, var(--m3e-fab-focus-state-layer-color, ${a.color.onSecondaryContainer}))`),stateLayerOpacity:o(`var(--m3e-secondary-container-fab-focus-state-layer-opacity, var(--m3e-fab-focus-state-layer-opacity, ${a.state.focusStateLayerOpacity}))`),containerElevation:o(`var(--m3e-secondary-container-fab-focus-container-elevation, var(--m3e-fab-focus-container-elevation, ${a.elevation.level3}))`),loweredContainerElevation:o(`var(--m3e-secondary-container-fab-lowered-focus-container-elevation, var(--m3e-fab-lowered-focus-container-elevation, ${a.elevation.level2}))`)},pressed:{iconColor:o(`var(--m3e-secondary-container-fab-pressed-icon-color, var(--m3e-fab-pressed-icon-color, ${a.color.onSecondaryContainer}))`),labelTextColor:o(`var(--m3e-secondary-container-fab-pressed-label-text-color, var(--m3e-fab-pressed-label-text-color, ${a.color.onSecondaryContainer}))`),stateLayerColor:o(`var(--m3e-secondary-container-fab-pressed-state-layer-color, var(--m3e-fab-pressed-state-layer-color, ${a.color.onSecondaryContainer}))`),stateLayerOpacity:o(`var(--m3e-secondary-container-fab-pressed-state-layer-opacity, var(--m3e-fab-pressed-state-layer-opacity, ${a.state.pressedStateLayerOpacity}))`),containerElevation:o(`var(--m3e-secondary-container-fab-pressed-container-elevation, var(--m3e-fab-pressed-container-elevation, ${a.elevation.level3}))`),loweredContainerElevation:o(`var(--m3e-secondary-container-fab-lowered-pressed-container-elevation, var(--m3e-fab-lowered-pressed-container-elevation, ${a.elevation.level2}))`)}},"tertiary-container":{labelTextColor:o(`var(--m3e-tertiary-container-fab-label-text-color, var(--m3e-fab-label-text-color, ${a.color.onTertiaryContainer}))`),iconColor:o(`var(--m3e-tertiary-container-fab-icon-color, var(--m3e-fab-icon-color, ${a.color.onTertiaryContainer}))`),containerColor:o(`var(--m3e-tertiary-container-fab-container-color, var(--m3e-fab-container-color, ${a.color.tertiaryContainer}))`),containerElevation:o(`var(--m3e-tertiary-container-fab-container-elevation, var(--m3e-fab-container-elevation, ${a.elevation.level3}))`),loweredContainerElevation:o(`var(--m3e-tertiary-container-fab-lowered-container-elevation, var(--m3e-fab-lowered-container-elevation, ${a.elevation.level2}))`),disabled:{containerColor:o(`var(--m3e-tertiary-container-fab-disabled-container-color, var(--m3e-fab-disabled-container-color, ${a.color.onSurface}))`),containerOpacity:o("var(--m3e-tertiary-container-fab-disabled-container-opacity, var(--m3e-fab-disabled-container-opacity, 10%))"),iconColor:o(`var(--m3e-tertiary-container-fab-disabled-icon-color, var(--m3e-fab-disabled-icon-color, ${a.color.onSurface}))`),iconOpacity:o("var(--m3e-tertiary-container-fab-disabled-icon-opacity, var(--m3e-fab-disabled-icon-opacity, 38%))"),labelTextColor:o(`var(--m3e-tertiary-container-fab-disabled-label-text-color, var(--m3e-fab-disabled-label-text-color, ${a.color.onSurface}))`),labelTextOpacity:o("var(--m3e-tertiary-container-fab-disabled-label-text-opacity, var(--m3e-fab-disabled-label-text-opacity, 38%))"),containerElevation:o(`var(--m3e-tertiary-container-fab-disabled-container-elevation, var(--m3e-fab-disabled-container-elevation, ${a.elevation.level0}))`),loweredContainerElevation:o(`var(--m3e-tertiary-container-fab-lowered-disabled-container-elevation, var(--m3e-fab-lowered-disabled-container-elevation, ${a.elevation.level0}))`)},hover:{iconColor:o(`var(--m3e-tertiary-container-fab-hover-icon-color, var(--m3e-fab-hover-icon-color, ${a.color.onTertiaryContainer}))`),labelTextColor:o(`var(--m3e-tertiary-container-fab-hover-label-text-color, var(--m3e-fab-hover-label-text-color, ${a.color.onTertiaryContainer}))`),stateLayerColor:o(`var(--m3e-tertiary-container-fab-hover-state-layer-color, var(--m3e-fab-hover-state-layer-color, ${a.color.onTertiaryContainer}))`),stateLayerOpacity:o(`var(--m3e-tertiary-container-fab-hover-state-layer-opacity, var(--m3e-fab-hover-state-layer-opacity, ${a.state.hoverStateLayerOpacity}))`),containerElevation:o(`var(--m3e-tertiary-container-fab-hover-container-elevation, var(--m3e-fab-hover-container-elevation, ${a.elevation.level4}))`),loweredContainerElevation:o(`var(--m3e-tertiary-container-fab-lowered-hover-container-elevation, var(--m3e-fab-lowered-hover-container-elevation, ${a.elevation.level3}))`)},focus:{iconColor:o(`var(--m3e-tertiary-container-fab-focus-icon-color, var(--m3e-fab-focus-icon-color, ${a.color.onTertiaryContainer}))`),labelTextColor:o(`var(--m3e-tertiary-container-fab-focus-label-text-color, var(--m3e-fab-focus-label-text-color, ${a.color.onTertiaryContainer}))`),stateLayerColor:o(`var(--m3e-tertiary-container-fab-focus-state-layer-color, var(--m3e-fab-focus-state-layer-color, ${a.color.onTertiaryContainer}))`),stateLayerOpacity:o(`var(--m3e-tertiary-container-fab-focus-state-layer-opacity, var(--m3e-fab-focus-state-layer-opacity, ${a.state.focusStateLayerOpacity}))`),containerElevation:o(`var(--m3e-tertiary-container-fab-focus-container-elevation, var(--m3e-fab-focus-container-elevation, ${a.elevation.level3}))`),loweredContainerElevation:o(`var(--m3e-tertiary-container-fab-lowered-focus-container-elevation, var(--m3e-fab-lowered-focus-container-elevation, ${a.elevation.level2}))`)},pressed:{iconColor:o(`var(--m3e-tertiary-container-fab-pressed-icon-color, var(--m3e-fab-pressed-icon-color, ${a.color.onTertiaryContainer}))`),labelTextColor:o(`var(--m3e-tertiary-container-fab-pressed-label-text-color, var(--m3e-fab-pressed-label-text-color, ${a.color.onTertiaryContainer}))`),stateLayerColor:o(`var(--m3e-tertiary-container-fab-pressed-state-layer-color, var(--m3e-fab-pressed-state-layer-color, ${a.color.onTertiaryContainer}))`),stateLayerOpacity:o(`var(--m3e-tertiary-container-fab-pressed-state-layer-opacity, var(--m3e-fab-pressed-state-layer-opacity, ${a.state.pressedStateLayerOpacity}))`),containerElevation:o(`var(--m3e-tertiary-container-fab-pressed-container-elevation, var(--m3e-fab-pressed-container-elevation, ${a.elevation.level3}))`),loweredContainerElevation:o(`var(--m3e-tertiary-container-fab-lowered-pressed-container-elevation, var(--m3e-fab-lowered-pressed-container-elevation, ${a.elevation.level2}))`)}},surface:{labelTextColor:o(`var(--m3e-surface-fab-label-text-color, var(--m3e-fab-label-text-color, ${a.color.primary}))`),iconColor:o(`var(--m3e-surface-fab-icon-color, var(--m3e-fab-icon-color, ${a.color.primary}))`),containerColor:o(`var(--m3e-surface-fab-container-color, var(--m3e-fab-container-color, ${a.color.surfaceContainerHigh}))`),containerElevation:o(`var(--m3e-surface-fab-container-elevation, var(--m3e-fab-container-elevation, ${a.elevation.level3}))`),loweredContainerElevation:o(`var(--m3e-surface-fab-lowered-container-elevation, var(--m3e-fab-lowered-container-elevation, ${a.elevation.level2}))`),loweredContainerColor:o(`var(--m3e-surface-fab-lowered-container-color, var(--m3e-fab-lowered-container-color, ${a.color.surfaceContainerLow}))`),disabled:{containerColor:o(`var(--m3e-surface-fab-disabled-container-color, var(--m3e-fab-disabled-container-color, ${a.color.onSurface}))`),containerOpacity:o("var(--m3e-surface-fab-disabled-container-opacity, var(--m3e-fab-disabled-container-opacity, 10%))"),iconColor:o(`var(--m3e-surface-fab-disabled-icon-color, var(--m3e-fab-disabled-icon-color, ${a.color.onSurface}))`),iconOpacity:o("var(--m3e-surface-fab-disabled-icon-opacity, var(--m3e-fab-disabled-icon-opacity, 38%))"),labelTextColor:o(`var(--m3e-surface-fab-disabled-label-text-color, var(--m3e-fab-disabled-label-text-color, ${a.color.onSurface}))`),labelTextOpacity:o("var(--m3e-surface-fab-disabled-label-text-opacity, var(--m3e-fab-disabled-label-text-opacity, 38%))"),containerElevation:o(`var(--m3e-surface-fab-disabled-container-elevation, var(--m3e-fab-disabled-container-elevation, ${a.elevation.level0}))`),loweredContainerElevation:o(`var(--m3e-surface-fab-lowered-disabled-container-elevation, var(--m3e-fab-lowered-disabled-container-elevation, ${a.elevation.level0}))`)},hover:{iconColor:o(`var(--m3e-surface-fab-hover-icon-color, var(--m3e-fab-hover-icon-color, ${a.color.primary}))`),labelTextColor:o(`var(--m3e-surface-fab-hover-label-text-color, var(--m3e-fab-hover-label-text-color, ${a.color.primary}))`),stateLayerColor:o(`var(--m3e-surface-fab-hover-state-layer-color, var(--m3e-fab-hover-state-layer-color, ${a.color.primary}))`),stateLayerOpacity:o(`var(--m3e-surface-fab-hover-state-layer-opacity, var(--m3e-fab-hover-state-layer-opacity, ${a.state.hoverStateLayerOpacity}))`),containerElevation:o(`var(--m3e-surface-fab-hover-container-elevation, var(--m3e-fab-hover-container-elevation, ${a.elevation.level4}))`),loweredContainerElevation:o(`var(--m3e-surface-fab-lowered-hover-container-elevation, var(--m3e-fab-lowered-hover-container-elevation, ${a.elevation.level3}))`)},focus:{iconColor:o(`var(--m3e-surface-fab-focus-icon-color, var(--m3e-fab-focus-icon-color, ${a.color.primary}))`),labelTextColor:o(`var(--m3e-surface-fab-focus-label-text-color, var(--m3e-fab-focus-label-text-color, ${a.color.primary}))`),stateLayerColor:o(`var(--m3e-surface-fab-focus-state-layer-color, var(--m3e-fab-focus-state-layer-color, ${a.color.primary}))`),stateLayerOpacity:o(`var(--m3e-surface-fab-focus-state-layer-opacity, var(--m3e-fab-focus-state-layer-opacity, ${a.state.focusStateLayerOpacity}))`),containerElevation:o(`var(--m3e-surface-fab-focus-container-elevation, var(--m3e-fab-focus-container-elevation, ${a.elevation.level3}))`),loweredContainerElevation:o(`var(--m3e-surface-fab-lowered-focus-container-elevation, var(--m3e-fab-lowered-focus-container-elevation, ${a.elevation.level2}))`)},pressed:{iconColor:o(`var(--m3e-surface-fab-pressed-icon-color, var(--m3e-fab-pressed-icon-color, ${a.color.primary}))`),labelTextColor:o(`var(--m3e-surface-fab-pressed-label-text-color, var(--m3e-fab-pressed-label-text-color, ${a.color.primary}))`),stateLayerColor:o(`var(--m3e-surface-fab-pressed-state-layer-color, var(--m3e-fab-pressed-state-layer-color, ${a.color.primary}))`),stateLayerOpacity:o(`var(--m3e-surface-fab-pressed-state-layer-opacity, var(--m3e-fab-pressed-state-layer-opacity, ${a.state.pressedStateLayerOpacity}))`),containerElevation:o(`var(--m3e-surface-fab-pressed-container-elevation, var(--m3e-fab-pressed-container-elevation, ${a.elevation.level3}))`),loweredContainerElevation:o(`var(--m3e-surface-fab-lowered-pressed-container-elevation, var(--m3e-fab-lowered-pressed-container-elevation, ${a.elevation.level2}))`)}}};function ha(t){return C`:host([variant="${o(t)}"]:not([lowered])) .base { background-color: ${q[t].containerColor}; --m3e-elevation-level: ${q[t].containerElevation}; --m3e-elevation-hover-level: ${q[t].hover.containerElevation}; --m3e-elevation-focus-level: ${q[t].focus.containerElevation}; --m3e-elevation-pressed-level: ${q[t].pressed.containerElevation}; } :host([variant="${o(t)}"][lowered]) .base { background-color: ${q[t].loweredContainerColor??q[t].containerColor}; --m3e-elevation-level: ${q[t].loweredContainerElevation}; --m3e-elevation-hover-level: ${q[t].hover.loweredContainerElevation}; --m3e-elevation-focus-level: ${q[t].focus.loweredContainerElevation}; --m3e-elevation-pressed-level: ${q[t].pressed.loweredContainerElevation}; } :host([variant="${o(t)}"]) .base { --m3e-state-layer-hover-color: ${q[t].hover.stateLayerColor}; --m3e-state-layer-hover-opacity: ${q[t].hover.stateLayerOpacity}; --m3e-state-layer-focus-color: ${q[t].focus.stateLayerColor}; --m3e-state-layer-focus-opacity: ${q[t].focus.stateLayerOpacity}; --m3e-ripple-color: ${q[t].pressed.stateLayerColor}; --m3e-ripple-opacity: ${q[t].pressed.stateLayerOpacity}; } :host([variant="${o(t)}"]) .label { color: ${q[t].labelTextColor}; } :host([variant="${o(t)}"]:focus) .label { color: ${q[t].focus.labelTextColor}; } :host([variant="${o(t)}"]:hover) .label { color: ${q[t].hover.labelTextColor}; } :host([variant="${o(t)}"]) .base.pressed .label { color: ${q[t].pressed.labelTextColor}; } :host([variant="${o(t)}"]) .icon { color: ${q[t].iconColor}; } :host([variant="${o(t)}"]:focus) .icon { color: ${q[t].focus.iconColor}; } :host([variant="${o(t)}"]:hover) .icon { color: ${q[t].hover.iconColor}; } :host([variant="${o(t)}"]) .base.pressed .icon { color: ${q[t].pressed.iconColor}; } :host([variant="${o(t)}"]:disabled) .base, :host([variant="${o(t)}"][disabled-interactive]) .base { --m3e-elevation-level: ${q[t].disabled.containerElevation}; background-color: color-mix( in srgb, ${q[t].disabled.containerColor} ${q[t].disabled.containerOpacity}, transparent ); } :host([variant="${o(t)}"]:disabled) .label, :host([variant="${o(t)}"][disabled-interactive]) .label { color: color-mix( in srgb, ${q[t].disabled.labelTextColor} ${q[t].disabled.labelTextOpacity}, transparent ); } :host([variant="${o(t)}"]:disabled) .icon, :host([variant="${o(t)}"][disabled-interactive]) .icon { color: color-mix( in srgb, ${q[t].disabled.iconColor} ${q[t].disabled.iconOpacity}, transparent ); }`}var sb=[ha("primary"),ha("secondary"),ha("tertiary"),ha("primary-container"),ha("secondary-container"),ha("tertiary-container"),ha("surface")],_s,Mc,st=class extends De(wt(yt(Be(Ze(se(Q(W(P,"button"),!0))))))){constructor(){super(),_s.add(this),this.variant="primary-container",this.lowered=!1,this.size="medium",this.extended=!1,new fe(this,{isPressedKey:e=>e===" ",callback:e=>{!this.disabled&&!this.disabledInteractive&&(this._base?.classList.toggle("pressed",e),this._base?.classList.toggle("resting",!e))}})}disconnectedCallback(){super.disconnectedCallback(),this._base?.classList.toggle("pressed",!1),this._base?.classList.toggle("resting",!1)}firstUpdated(e){super.firstUpdated(e),[this._elevation,this._focusRing,this._stateLayer,this._ripple].forEach(r=>r?.attach(this))}updated(e){super.updated(e),(e.has("disabled")&&this.disabled||e.has("disabledInteractive")&&this.disabledInteractive)&&(this._base?.classList.toggle("pressed",!1),this._base?.classList.toggle("resting",!1))}render(){return w`<div class="base"><m3e-elevation class="elevation" ?disabled="${this.disabled||this.disabledInteractive}"></m3e-elevation><m3e-state-layer class="state-layer" ?disabled="${this.disabled||this.disabledInteractive}"></m3e-state-layer><m3e-focus-ring class="focus-ring" ?disabled="${this.disabled}"></m3e-focus-ring><m3e-ripple class="ripple" ?centered="${!this.extended}" ?disabled="${this.disabled||this.disabledInteractive}"></m3e-ripple><div class="touch" aria-hidden="true"></div>${this[xt]()}<div class="wrapper"><slot class="icon" aria-hidden="true" @slotchange="${n(this,_s,"m",Mc)}"></slot><slot class="icon" aria-hidden="true" name="close-icon"><svg class="close-icon" viewBox="0 -960 960 960" fill="currentColor"><path d="m256-200-56-56 224-224-224-224 56-56 224 224 224-224 56 56-224 224 224 224-56 56-224-224-224 224Z"/></svg></slot><m3e-collapsible class="label-wrapper" orientation="horizontal" ?open="${this.extended}"><div class="label"><slot name="label" @slotchange="${n(this,_s,"m",Mc)}"></slot></div></m3e-collapsible></div></div>`}};_s=new WeakSet;Mc=function(){this._base?.classList.toggle("with-menu",this.querySelector("m3e-fab-menu-trigger")!==null)};st.styles=[ib,sb,nb];h([M(".base")],st.prototype,"_base",void 0);h([M(".elevation")],st.prototype,"_elevation",void 0);h([M(".focus-ring")],st.prototype,"_focusRing",void 0);h([M(".state-layer")],st.prototype,"_stateLayer",void 0);h([M(".ripple")],st.prototype,"_ripple",void 0);h([b({reflect:!0})],st.prototype,"variant",void 0);h([b({type:Boolean,reflect:!0})],st.prototype,"lowered",void 0);h([b({reflect:!0})],st.prototype,"size",void 0);h([b({type:Boolean,reflect:!0})],st.prototype,"extended",void 0);st=h([L("m3e-fab")],st);var lb=["m3e-input-chip-set","m3e-select"];function Wu(t){return t instanceof HTMLElement&&(t instanceof HTMLInputElement||t instanceof HTMLTextAreaElement||t instanceof HTMLSelectElement||lb.includes(t.tagName.toLowerCase()))}function cb(t){for(let e of t.assignedElements({flatten:!0})){if(Wu(e))return e;let r=document.createTreeWalker(e,NodeFilter.SHOW_ELEMENT);for(;r.nextNode();)if(Wu(r.currentNode))return r.currentNode}return null}var K,I,pn,$s,Cs,Ss,Pc,Ac,Ic,zc,Fc,mn,lt,et,Nu,Lc,qu,Vu,Uu,ju,Gu,Yu,Xu,Zu,Ju,ks,Oc,Tc,Rc,Bc,ke=class extends uo(Q(P)){constructor(){super(),K.add(this),I.set(this,null),pn.set(this,void 0),$s.set(this,()=>n(this,K,"m",Ju).call(this)),Cs.set(this,()=>n(this,K,"m",Xu).call(this)),Ss.set(this,new Ut(this,{target:null,config:{attributeFilter:["disabled","readonly","required"]},callback:()=>this.notifyControlStateChange()})),Pc.set(this,new we(this,{target:null,callback:()=>n(this,K,"m",ju).call(this)})),Ac.set(this,new je(this,{target:null,filter:e=>n(this,K,"m",ks).call(this,e),callback:e=>{e=e&&!(n(this,I,"f")?.disabled??!0),R(this,"--no-animate",!1),f(this,mn,e,"f"),e?R(this,"--float-label",!0):(this._invalid=!(n(this,I,"f")?.checkValidity?.()??!0),this.notifyControlStateChange())}})),Ic.set(this,new Ut(this,{target:null,config:{childList:!0,subtree:!0},callback:()=>n(this,K,"m",Rc).call(this)})),zc.set(this,new Ut(this,{target:null,config:{childList:!0,subtree:!0},callback:()=>n(this,K,"m",Bc).call(this)})),Fc.set(this,new fe(this,{target:null,filter:e=>n(this,K,"m",ks).call(this,e),callback:e=>R(this,"--pressed",e&&!(n(this,I,"f")?.disabled??!0))})),mn.set(this,!1),this._pseudoLabel="",this._required=!1,this._invalid=!1,this._validationMessage="",lt.set(this,""),et.set(this,""),this.variant="outlined",this.hideRequiredMarker=!1,this.hideSubscript="auto",this.floatLabel="auto",new Vt(this,{callback:()=>R(this,"--no-animate",!1)})}get menuAnchor(){return this._base}get control(){return n(this,I,"f")}notifyControlStateChange(e=!1){this._required=n(this,I,"f")?.required===!0,R(this,"--required",this._required),R(this,"--disabled",n(this,I,"f")?.disabled===!0),R(this,"--readonly",vh(n(this,I,"f"))&&n(this,I,"f").readOnly===!0),this.floatLabel==="auto"&&R(this,"--float-label",n(this,K,"a",Nu)||n(this,mn,"f")),e&&(this._invalid=!(n(this,I,"f")?.checkValidity?.()??!0)),R(this,"--invalid",this._invalid),this._validationMessage=n(this,I,"f")?.validationMessage??"",this.isUpdatePending||this.performUpdate()}connectedCallback(){super.connectedCallback(),R(this,"--no-animate",!0)}disconnectedCallback(){super.disconnectedCallback(),n(this,K,"m",Oc).call(this,null)}reconnectedCallback(){super.reconnectedCallback(),n(this,K,"m",Lc).call(this)}firstUpdated(e){super.firstUpdated(e),n(this,K,"m",Lc).call(this)}update(e){super.update(e),e.has("_invalid")&&n(this,I,"f")&&(n(this,I,"f").ariaInvalid=this._invalid?"true":null,n(this,et,"f")&&(this._invalid?He.describe(n(this,I,"f"),n(this,et,"f")):He.removeDescription(n(this,I,"f"),n(this,et,"f"))))}render(){return w`<div class="base" @click="${n(this,K,"m",Yu)}">${this.variant==="outlined"?w`<div class="outline" aria-hidden="true"><div class="outline-start"></div><div class="outline-notch"><div class="pseudo-label">${this._pseudoLabel} ${!this.hideRequiredMarker&&this._required?w`&nbsp;*`:F}</div></div><div class="outline-end"></div></div>`:F}<div class="prefix"><slot name="prefix" @slotchange="${n(this,K,"m",Vu)}"></slot></div><div class="content"><span class="prefix-text"><slot name="prefix-text"></slot></span><span class="input"><slot @slotchange="${n(this,K,"m",Gu)}" @change="${n(this,K,"m",Zu)}"></slot></span><span class="suffix-text"><slot name="suffix-text"></slot></span><span class="label"><slot name="label" @slotchange="${n(this,K,"m",qu)}"></slot>${!this.hideRequiredMarker&&this._required?w`<span class="required-marker" aria-hidden="true">&nbsp;*</span>`:F}</span></div><div class="suffix"><slot name="suffix" @slotchange="${n(this,K,"m",Uu)}"></slot></div></div><span class="subscript" aria-hidden="true"><span class="error"><slot name="error">${this._validationMessage}</slot></span><span class="hint"><slot name="hint"></slot></span></span>`}};I=new WeakMap;pn=new WeakMap;$s=new WeakMap;Cs=new WeakMap;Ss=new WeakMap;Pc=new WeakMap;Ac=new WeakMap;Ic=new WeakMap;zc=new WeakMap;Fc=new WeakMap;mn=new WeakMap;lt=new WeakMap;et=new WeakMap;K=new WeakSet;Nu=function(){return n(this,I,"f")?.shouldLabelFloat!==void 0?n(this,I,"f").shouldLabelFloat===!0:typeof n(this,I,"f")?.value=="string"&&n(this,I,"f").value.length>0};Lc=function(){n(this,Ac,"f").observe(this._base),n(this,Fc,"f").observe(this._base),n(this,Ic,"f").observe(this._hint),n(this,K,"m",Rc).call(this),n(this,zc,"f").observe(this._error),n(this,K,"m",Bc).call(this)};qu=function(e){let r=e.target.assignedElements({flatten:!0});R(this,"--with-label",r.length>0),this._pseudoLabel=r[0]?.textContent??""};Vu=function(e){R(this,"--with-prefix",he(e.target)),n(this,Pc,"f").observe(this._prefix)};Uu=function(e){R(this,"--with-suffix",he(e.target))};ju=function(){this.variant==="outlined"&&this._base.style.setProperty("--_prefix-width",`${this._prefix.clientWidth}px`)};Gu=function(e){n(this,K,"m",Oc).call(this,cb(e.target))};Yu=function(e){n(this,K,"m",ks).call(this,e)||n(this,I,"f")&&!n(this,mn,"f")&&!n(this,I,"f").disabled&&(n(this,I,"f").onContainerClick?n(this,I,"f").onContainerClick(e):n(this,I,"f").focus())};Xu=function(){this._invalid=!0,this.notifyControlStateChange()};Zu=function(){this._invalid=!(n(this,I,"f")?.checkValidity?.()??!0),this.notifyControlStateChange()};Ju=function(){this._invalid=!1,setTimeout(()=>this.notifyControlStateChange())};ks=function(e){return e.composed&&e.composedPath().includes(this._suffix)};Oc=function(e){if(n(this,I,"f")!==e&&(n(this,I,"f")&&(n(this,lt,"f")&&He.removeDescription(n(this,I,"f"),n(this,lt,"f")),n(this,et,"f")&&He.removeDescription(n(this,I,"f"),n(this,et,"f")),n(this,Ss,"f").unobserve(n(this,I,"f")),n(this,I,"f").removeEventListener("invalid",n(this,Cs,"f")),n(this,I,"f").form?.removeEventListener("reset",n(this,$s,"f")),n(this,pn,"f")?.call(this),f(this,pn,void 0,"f")),f(this,I,e,"f"),["INPUT","TEXTAREA"].includes(n(this,I,"f")?.tagName??"")?this._base.style.setProperty("--_form-field-cursor","text"):this._base.style.removeProperty("--_form-field-cursor"),R(this,"--with-select",n(this,I,"f")?.tagName==="M3E-SELECT"),ie(this,"--with-select")&&this._base.style.setProperty("--_form-field-cursor","pointer"),n(this,I,"f"))){n(this,Ss,"f").observe(n(this,I,"f")),n(this,I,"f").addEventListener("invalid",n(this,Cs,"f")),n(this,I,"f").form?.addEventListener("reset",n(this,$s,"f")),n(this,I,"f").removeAttribute("aria-invalid"),n(this,lt,"f")&&He.describe(n(this,I,"f"),n(this,lt,"f")),this.notifyControlStateChange();let r=n(this,I,"f").tagName.toLowerCase();r.startsWith("m3e-")&&!customElements.get(r)?customElements.whenDefined(r).then(()=>n(this,K,"m",Tc).call(this)):n(this,K,"m",Tc).call(this)}};Tc=function(){n(this,I,"f")&&f(this,pn,hh(n(this,I,"f"),"value",{set:(e,r)=>{r(e),this.notifyControlStateChange(!0)}}),"f")};Rc=function(){let e=Go(this._hint,!0);e!==n(this,lt,"f")&&(n(this,I,"f")&&n(this,lt,"f")&&He.removeDescription(n(this,I,"f"),n(this,lt,"f")),f(this,lt,e,"f"),n(this,I,"f")&&n(this,lt,"f")&&He.describe(n(this,I,"f"),n(this,lt,"f")))};Bc=function(){let e=Go(this._error,!0);e!==n(this,et,"f")&&(n(this,I,"f")&&n(this,et,"f")&&He.removeDescription(n(this,I,"f"),n(this,et,"f")),f(this,et,e,"f"),n(this,I,"f")&&n(this,et,"f")&&this._invalid&&He.describe(n(this,I,"f"),n(this,et,"f")))};ho(C`m3e-form-field input::placeholder, m3e-form-field textarea::placeholder { user-select: none; color: currentColor; transition: opacity ${a.motion.duration.extraLong1}; } m3e-form-field[float-label="auto"]:not(:is(:state(--float-label), :--float-label)):is( :state(--with-label), :--with-label ) input::placeholder, m3e-form-field[float-label="auto"]:not(:is(:state(--float-label), :--float-label)):is( :state(--with-label), :--with-label ) textarea::placeholder { opacity: 0; transition: opacity 0s; } m3e-form-field[variant="outlined"] m3e-input-chip-set { margin-block: calc(calc(3.5rem + ${a.density.calc(-3)}) / 4); } m3e-form-field[variant="outlined"] textarea { margin-block: calc( var(--m3e-form-field-label-line-height, var(--md-sys-typescale-body-small-line-height, 1rem)) / 2 ); } @media (prefers-reduced-motion) { m3e-form-field input::placeholder, m3e-form-field textarea::placeholder { transition: none !important; } }`);ke.styles=C`:host { display: inline-flex; flex-direction: column; vertical-align: middle; font-size: var(--m3e-form-field-font-size, ${a.typescale.standard.body.large.fontSize}); font-weight: var(--m3e-form-field-font-weight, ${a.typescale.standard.body.large.fontWeight}); line-height: var(--m3e-form-field-line-height, ${a.typescale.standard.body.large.lineHeight}); letter-spacing: var(--m3e-form-field-tracking, ${a.typescale.standard.body.large.tracking}); width: var(--m3e-form-field-width, 14.5rem); color: var(--_form-field-color); } :host(:not(:is(:state(--disabled), :--disabled))) .base { cursor: var(--_form-field-cursor); } .base { display: flex; align-items: center; position: relative; min-height: calc(3.5rem + ${a.density.calc(-3)}); --_form-field-label-font-size: var( --m3e-form-field-label-font-size, ${a.typescale.standard.body.small.fontSize} ); --_form-field-label-line-height: var( --m3e-form-field-label-line-height, ${a.typescale.standard.body.small.lineHeight} ); } .content { display: flex; align-items: center; position: relative; flex: 1 1 auto; min-width: 0; min-height: var(--m3e-form-field-icon-size, 1.5rem); } .prefix, .suffix { display: flex; align-items: center; position: relative; user-select: none; flex: none; font-size: var(--m3e-form-field-icon-size, 1.5rem); } .prefix-text, .suffix-text { opacity: 1; transition: opacity ${a.motion.duration.extraLong1}; user-select: none; flex: none; } .input { display: inline-flex; flex-wrap: wrap; flex: 1 1 auto; min-width: 0; } .label { display: flex; position: absolute; pointer-events: none; user-select: none; top: 0; left: 0; right: 0; font-size: var(--m3e-form-field-label-font-size, ${a.typescale.standard.body.small.fontSize}); font-weight: var(--m3e-form-field-label-font-weight, ${a.typescale.standard.body.small.fontWeight}); line-height: var(--m3e-form-field-label-line-height, ${a.typescale.standard.body.small.lineHeight}); letter-spacing: var(--m3e-form-field-label-tracking, ${a.typescale.standard.body.small.tracking}); color: var(--_form-field-label-color, inherit); transition: ${o(`top ${a.motion.duration.short4}, 
        font-size ${a.motion.duration.short4}, 
        line-height ${a.motion.duration.short4}`)}; } :host(:is(:state(--with-select), :--with-select)) .label { margin-inline-end: 1.5rem; } ::slotted([slot="label"]) { white-space: nowrap; overflow: hidden; text-overflow: ellipsis; } .subscript { display: inline-flex; width: 100%; margin-top: 0.25rem; font-size: var(--m3e-form-field-subscript-font-size, ${a.typescale.standard.body.small.fontSize}); font-weight: var(--m3e-form-field-subscript-font-weight, ${a.typescale.standard.body.small.fontWeight}); line-height: var(--m3e-form-field-subscript-line-height, ${a.typescale.standard.body.small.lineHeight}); letter-spacing: var(--m3e-form-field-subscript-tracking, ${a.typescale.standard.body.small.tracking}); min-height: var(--m3e-form-field-subscript-line-height, ${a.typescale.standard.body.small.lineHeight}); color: var(--m3e-form-field-subscript-color, ${a.color.onSurfaceVariant}); } .error, .hint { flex: 1 1 auto; } :host([hide-subscript="always"]) .subscript { display: none; } :host([hide-subscript="auto"]:not(:is(:state(--invalid), :--invalid))) .subscript { opacity: 0; margin-top: 0.25rem; transform: translateY(-0.25rem); transition: ${o(`opacity ${a.motion.duration.short4}, 
        transform ${a.motion.duration.short4}`)}; } :host([hide-subscript="auto"]:not(:is(:state(--invalid), :--invalid)):focus-within) .subscript, :host([hide-subscript="auto"]:not(:is(:state(--invalid), :--invalid)):is(:state(--pressed), :--pressed)) .subscript { opacity: 1; transform: translateY(0); } :host(:is(:state(--invalid), :--invalid)) .hint { display: none; } :host(:not(:is(:state(--invalid), :--invalid))) .error { display: none; } ::slotted(input), ::slotted(textarea), ::slotted(select) { outline: unset; border: unset; background-color: transparent; box-shadow: none; font-family: inherit; font-size: inherit; line-height: inherit; letter-spacing: inherit; color: var(--_form-field-input-color, inherit); flex: 1 1 auto; min-width: 0; padding: unset; } ::slotted(textarea) { scrollbar-width: ${a.scrollbar.thinWidth}; scrollbar-color: ${a.scrollbar.color}; } ::slotted(m3e-select), ::slotted(m3e-input-chip-set) { flex: 1 1 auto; min-width: 0; } :host([float-label="auto"]:not(:is(:state(--float-label), :--float-label)):not(:is(:state(--pressed), :--pressed))) .label { font-size: inherit; } :host([float-label="auto"]:not(:is(:state(--float-label), :--float-label)):is(:state(--with-label), :--with-label)) .prefix-text, :host([float-label="auto"]:not(:is(:state(--float-label), :--float-label)):is(:state(--with-label), :--with-label)) .suffix-text { opacity: 0; transition: opacity 0s; } .prefix { margin-inline-start: 1rem; } :host(:is(:state(--with-prefix), :--with-prefix)) .prefix { margin-inline-end: 1rem; margin-inline-start: 0.75rem; } .suffix { margin-inline-end: 1rem; } :host(:is(:state(--with-suffix), :--with-suffix)) .suffix { margin-inline-start: 0.25rem; margin-inline-end: 0.5rem; } :host(:is(:state(--with-suffix), :--with-suffix):is(:state(--with-select), :--with-select)) .suffix { margin-inline-start: unset; } :host(:is(:state(--with-select), :--with-select)) .suffix-text { display: none; } :host([variant="outlined"]) .label { margin-top: calc(0px - var(--_form-field-label-line-height) / 2); } :host([variant="outlined"]) .outline { position: absolute; display: flex; pointer-events: none; left: 0; top: 0; bottom: 0; right: 0; } :host([variant="outlined"]) .pseudo-label { visibility: hidden; margin-inline-end: 0.5rem; font-size: var(--_form-field-label-font-size); line-height: var(--_form-field-label-line-height); letter-spacing: var(--_form-field-label-tracking); max-width: 100%; transition-property: max-width, margin-inline-end; transition-duration: 1ms; } :host( :is(:state(--required), :--required):not([hide-required-marker]):not(:is(:state(--with-label), :--with-label)) ) .pseudo-label, :host( :is(:state(--required), :--required):not([hide-required-marker]):not(:is(:state(--with-label), :--with-label)) ) .required-marker { display: none; } :host([variant="outlined"]:is(:state(--required), :--required):not([hide-required-marker])) .pseudo-label { margin-inline-end: 0.25rem; } :host( [variant="outlined"][float-label="auto"]:not(:is(:state(--float-label), :--float-label)):not( :is(:state(--pressed), :--pressed) ) ) .pseudo-label { max-width: 0; margin-inline-end: 0px; transition-delay: ${a.motion.duration.short2}; } :host([variant="outlined"]) .outline-start, :host([variant="outlined"]) .outline-notch, :host([variant="outlined"]) .outline-end { box-sizing: border-box; border-width: var(--_form-field-outline-size, 1px); border-color: var(--_form-field-outline-color); transition: border-color ${a.motion.duration.short4}; } :host([variant="outlined"]:not(:is(:state(--with-label), :--with-label))) .outline-notch { display: none; } :host([variant="outlined"]) .outline-start { min-width: 0.75rem; border-top-style: solid; border-inline-start-style: solid; border-bottom-style: solid; border-start-start-radius: var(--m3e-outlined-form-field-container-shape, ${a.shape.corner.extraSmall}); border-end-start-radius: var(--m3e-outlined-form-field-container-shape, ${a.shape.corner.extraSmall}); } :host([variant="outlined"]) .outline-notch { border-bottom-style: solid; } :host([variant="outlined"]) .outline-end { flex-grow: 1; min-width: 1rem; border-top-style: solid; border-inline-end-style: solid; border-bottom-style: solid; border-start-end-radius: var(--m3e-outlined-form-field-container-shape, ${a.shape.corner.extraSmall}); border-end-end-radius: var(--m3e-outlined-form-field-container-shape, ${a.shape.corner.extraSmall}); } :host([variant="outlined"]:is(:state(--with-prefix), :--with-prefix)) .outline-start { min-width: calc(1.25rem + var(--_prefix-width, 0px) + 0.25rem); } :host([variant="outlined"]:not(:is(:state(--disabled), :--disabled))) .base:hover .outline, :host([variant="outlined"]:not(:is(:state(--disabled), :--disabled)):focus-within) .outline, :host([variant="outlined"]:not(:is(:state(--disabled), :--disabled)):is(:state(--pressed), :--pressed)) .outline { --_form-field-outline-size: 2px; } :host([variant="outlined"]) .subscript { margin-inline: 1rem; width: calc(100% - 2rem); } :host([variant="outlined"]) .content { min-height: calc(3.5rem + ${a.density.calc(-3)}); --_form-field-label-font-size: var( --m3e-form-field-label-font-size, ${a.typescale.standard.body.small.fontSize} ); } :host( [variant="outlined"][float-label="auto"]:not(:is(:state(--float-label), :--float-label)):not( :is(:state(--pressed), :--pressed) ) ) .label { margin-top: unset; line-height: calc(3.5rem + ${a.density.calc(-3)}); --_form-field-label-font-size: var( --m3e-form-field-label-font-size, ${a.typescale.standard.body.small.fontSize} ); } :host([variant="filled"]) .base { --_select-arrow-margin-top: calc( 0px - calc(1rem / max(calc(0 - calc(var(--md-sys-density-scale, 0) + var(--md-sys-density-scale, 0))), 1)) ); } :host([variant="filled"]) .base::before { content: ""; box-sizing: border-box; position: absolute; pointer-events: none; top: 0; left: 0; right: 0; bottom: 0; border-bottom-style: solid; border-width: 1px; border-radius: var(--m3e-form-field-container-shape, ${a.shape.corner.extraSmallTop}); border-color: var(--_form-field-outline-color); background-color: var(--_form-field-container-color); } :host([variant="filled"]:not(:is(:state(--disabled), :--disabled))) .base:hover::before, :host([variant="filled"]:not(:is(:state(--disabled), :--disabled)):focus-within) .base::before, :host([variant="filled"]:not(:is(:state(--disabled), :--disabled)):is(:state(--pressed), :--pressed)) .base::before { border-width: 3px; } :host([variant="filled"]) .base::after { content: ""; box-sizing: border-box; position: absolute; pointer-events: none; top: 0; left: 0; right: 0; bottom: 0; background-color: var(--_form-field-hover-container-color); transition: background-color ${a.motion.duration.short4}; } :host([variant="filled"]) .subscript { margin-inline: 1rem; width: calc(100% - 2rem); } :host([variant="filled"]) .content { padding-top: calc(1.5rem + ${a.density.calc(-3)}); margin-bottom: 0.5rem; } :host([variant="filled"]) .label { top: max(0px, calc(0.5rem + ${a.density.calc(-3)})); } :host( [variant="filled"][float-label="auto"]:not(:is(:state(--float-label), :--float-label)):not( :is(:state(--pressed), :--pressed) ) ) .label { top: 0px; line-height: calc(3.5rem + ${a.density.calc(-3)} - 0.0625rem); --_form-field-label-font-size: var( --m3e-form-field-label-font-size, ${a.typescale.standard.body.small.fontSize} ); } :host(:not(:is(:state(--disabled), :--disabled)):not(:focus-within):not(:is(:state(--pressed), :--pressed))) .base:hover { --_form-field-hover-container-color: color-mix( in srgb, var(--m3e-form-field-hover-container-color, ${a.color.onSurface}) var(--m3e-form-field-hover-container-opacity, 8%), transparent ); } :host(:not(:is(:state(--disabled), :--disabled)):not(:is(:state(--invalid), :--invalid))) { color: var(--m3e-form-field-color, ${a.color.onSurface}); } :host([variant="outlined"]:not(:is(:state(--disabled), :--disabled)):not(:is(:state(--invalid), :--invalid))) .base { --_form-field-outline-color: var(--m3e-form-field-outline-color, ${a.color.outline}); } :host([variant="filled"]:not(:is(:state(--disabled), :--disabled)):not(:is(:state(--invalid), :--invalid))) .base { --_form-field-outline-color: var(--m3e-form-field-outline-color, ${a.color.onSurfaceVariant}); } :host( [variant="outlined"]:not(:is(:state(--disabled), :--disabled)):not( :is(:state(--invalid), :--invalid) ):focus-within ) .base, :host( [variant="outlined"]:not(:is(:state(--disabled), :--disabled)):not(:is(:state(--invalid), :--invalid)):is( :state(--pressed), :--pressed ) ) .base, :host( [variant="filled"]:not(:is(:state(--disabled), :--disabled)):not( :is(:state(--invalid), :--invalid) ):focus-within ) .base, :host( [variant="filled"]:not(:is(:state(--disabled), :--disabled)):not(:is(:state(--invalid), :--invalid)):is( :state(--pressed), :--pressed ) ) .base { --_form-field-outline-color: var(--m3e-form-field-focused-outline-color, ${a.color.primary}); --_form-field-label-color: var(--m3e-form-field-focused-color, ${a.color.primary}); } :host(:not(:is(:state(--disabled), :--disabled))) .base { --_form-field-container-color: var( --m3e-form-field-container-color, ${a.color.surfaceContainerHighest} ); } :host(:not(:is(:state(--disabled), :--disabled)):is(:state(--invalid), :--invalid)) .base { --_form-field-label-color: var(--m3e-form-field-invalid-color, ${a.color.error}); --_form-field-outline-color: var(--m3e-form-field-invalid-color, ${a.color.error}); } :host(:not(:is(:state(--disabled), :--disabled)):is(:state(--invalid), :--invalid)) .subscript { color: var(--m3e-form-field-invalid-color, ${a.color.error}); } :host(:is(:state(--disabled), :--disabled)) { color: color-mix( in srgb, var(--m3e-form-field-disabled-color, ${a.color.onSurface}) var(--m3e-form-field-disabled-opacity, 38%), transparent ); } :host(:is(:state(--disabled), :--disabled)) .base { --_form-field-container-color: color-mix( in srgb, var(--m3e-form-field-disabled-container-color, ${a.color.onSurface}) var(--m3e-form-field-disabled-container-opacity, 4%), transparent ); } :host(:is(:state(--no-animate), :--no-animate)) *, :host(:is(:state(--no-animate), :--no-animate)) *::before, :host(:is(:state(--no-animate), :--no-animate)) *::after { transition: none !important; } @media (forced-colors: active) { :host([variant="filled"]) .base::after { transition: none; } :host { --_form-field-outline-color: CanvasText; } :host(:is(:state(--disabled), :--disabled)) { --_form-field-input-color: GrayText; --_form-field-color: GrayText; --_form-field-label-color: GrayText; --_form-field-outline-color: GrayText; } } @media (prefers-reduced-motion) { .base::before, .prefix-text, .suffix-text, .label, .subscript, .outline-start, .outline-notch, .outline-end, .pseudo-label { transition: none !important; } }`;h([M(".base")],ke.prototype,"_base",void 0);h([M(".prefix")],ke.prototype,"_prefix",void 0);h([M(".suffix")],ke.prototype,"_suffix",void 0);h([M(".error")],ke.prototype,"_error",void 0);h([M(".hint")],ke.prototype,"_hint",void 0);h([mt()],ke.prototype,"_pseudoLabel",void 0);h([mt()],ke.prototype,"_required",void 0);h([mt()],ke.prototype,"_invalid",void 0);h([mt()],ke.prototype,"_validationMessage",void 0);h([b({reflect:!0})],ke.prototype,"variant",void 0);h([b({attribute:"hide-required-marker",type:Boolean,reflect:!0})],ke.prototype,"hideRequiredMarker",void 0);h([b({attribute:"hide-subscript",reflect:!0})],ke.prototype,"hideSubscript",void 0);h([b({attribute:"float-label",reflect:!0})],ke.prototype,"floatLabel",void 0);ke=h([L("m3e-form-field")],ke);var Ee,Es,ua,fn,Dc,db=/^[MmLlHhVvCcSsQqTtAaZz0-9.,\s-]+$/,hb=/^-?\d+(\.\d+)?\s+-?\d+(\.\d+)?\s+-?\d+(\.\d+)?\s+-?\d+(\.\d+)?$/,ma=class{static addIcon(e,r,i){let s=typeof i.outlined=="string",l=typeof i.filled=="string";if(typeof i.outlined=="string"&&(i.outlined={viewBox:"0 -960 960 960",path:i.outlined}),typeof i.filled=="string"&&(i.filled={viewBox:"0 -960 960 960",path:i.filled}),n(this,Ee,"m",Dc).call(this,e,r,i.outlined,s),n(this,Ee,"m",Dc).call(this,e,r,i.filled,l),typeof window>"u")return;let c=n(this,Ee,"m",fn).call(this,e,r);n(this,Ee,"f",Es).set(c,{outlined:Qs`<svg viewBox="${i.outlined.viewBox}"><path d="${i.outlined.path}"/></svg>`,filled:Qs`<svg viewBox="${i.filled.viewBox}"><path d="${i.filled.path}"/></svg>`}),n(this,Ee,"f",ua).get(c)?.forEach(d=>d())}static isIconRegistered(e,r){return window!==void 0&&n(this,Ee,"f",Es).has(n(this,Ee,"m",fn).call(this,e,r))}static renderIcon(e,r,i){let s=n(this,Ee,"f",Es).get(n(this,Ee,"m",fn).call(this,e,r));return i?s?.filled:s?.outlined}static observe(e,r,i){if(window===void 0)return()=>{};let s=n(this,Ee,"m",fn).call(this,e,r);return n(this,Ee,"f",ua).has(s)?n(this,Ee,"f",ua).get(s)?.push(i):n(this,Ee,"f",ua).set(s,[i]),()=>{let l=n(this,Ee,"f",ua).get(s);if(l){let c=l.indexOf(i);c>=0&&l.splice(c,1),l.length==0&&n(this,Ee,"f",ua).delete(s)}}}};Ee=ma,fn=function(e,r){return`${r}-${e}`},Dc=function(e,r,i,s=!1){if(!s&&!hb.test(i.viewBox))throw new Error(`Unable to register icon '${e}' for variant '${r}'. Invalid viewbox data.`);if(!db.test(i.path))throw new Error(`Unable to register icon '${e}' for variant '${r}'. Invalid path data.`)};Es={value:new Map};ua={value:new Map};var Za,Ot=class extends W(P,"img"){constructor(){super(...arguments),Za.set(this,void 0),this.name="",this.variant="outlined",this.filled=!1,this.grade="medium",this.weight=400,this.opticalSize=24}connectedCallback(){!this.hasAttribute("aria-label")&&!this.hasAttribute("aria-labelledby")&&!this.hasAttribute("aria-hidden")&&(this.ariaHidden="true"),super.connectedCallback()}disconnectedCallback(){super.disconnectedCallback(),n(this,Za,"f")?.call(this)}willUpdate(e){super.willUpdate(e),e.has("name")&&!ma.isIconRegistered(this.name,this.variant)&&f(this,Za,ma.observe(this.name,this.variant,()=>{this.requestUpdate(),n(this,Za,"f")?.call(this),f(this,Za,void 0,"f")}),"f")}updated(e){super.updated(e),e.has("filled")&&this._icon?.style.setProperty("--_icon-fill",this.filled?"1":"0"),e.has("grade")&&this._icon?.style.setProperty("--_icon-grade",this.grade==="low"?"-25":this.grade==="high"?"200":"0"),e.has("weight")&&this._icon?.style.setProperty("--_icon-weight",`${this.weight}`),e.has("opticalSize")&&this._icon?.style.setProperty("--_icon-optical-size",`${this.opticalSize}`)}render(){return ma.isIconRegistered(this.name,this.variant)?ma.renderIcon(this.name,this.variant,this.filled):w`<div class="icon" aria-hidden="true" translate="no">${this.name}</div>`}};Za=new WeakMap;Ot.styles=C`:host { display: inline-block; user-select: none; font-size: var(--m3e-icon-size, 1.5rem); width: 1em; height: 1em; vertical-align: middle; overflow: hidden; } .icon { font-weight: normal; font-style: normal; line-height: 1; letter-spacing: normal; text-transform: none; white-space: nowrap; word-wrap: normal; direction: ltr; font-feature-settings: "liga"; -webkit-font-smoothing: antialiased; width: inherit; height: inherit; vertical-align: inherit; font-variation-settings: "FILL" var(--_icon-fill, 0), "wght" var(--_icon-weight, 400), "GRAD" var(--_icon-grade, 0), "opsz" var(--_icon-optical-size, 24); } :host([variant="outlined"]) .icon { font-family: "Material Symbols Outlined"; } :host([variant="rounded"]) .icon { font-family: "Material Symbols Rounded"; } :host([variant="sharp"]) .icon { font-family: "Material Symbols Sharp"; } svg { fill: currentColor; font-size: inherit; width: 1em; height: 1em; }`;h([M(".icon")],Ot.prototype,"_icon",void 0);h([b()],Ot.prototype,"name",void 0);h([b({reflect:!0})],Ot.prototype,"variant",void 0);h([b({type:Boolean,reflect:!0})],Ot.prototype,"filled",void 0);h([b()],Ot.prototype,"grade",void 0);h([b({type:Number})],Ot.prototype,"weight",void 0);h([b({attribute:"optical-size",type:Number})],Ot.prototype,"opticalSize",void 0);Ot=h([L("m3e-icon")],Ot);var Y={"extra-small":{containerHeight:o(`calc(var(--m3e-icon-button-extra-small-container-height, var(--m3e-icon-button-container-height, 2rem)) + ${a.density.calc(-3)})`),outlineThickness:o("var(--m3e-icon-button-extra-small-outline-thickness, var(--m3e-icon-button-outline-thickness, 1px))"),iconSize:o("var(--m3e-icon-button-extra-small-icon-size, var(--m3e-icon-button-icon-size, 1.25rem))"),shapeRound:o(`var(--m3e-icon-button-extra-small-shape-round, var(--m3e-icon-button-shape-round, ${a.shape.corner.full}))`),shapeSquare:o(`var(--m3e-icon-button-extra-small-shape-square, var(--m3e-icon-button-shape-square, ${a.shape.corner.medium}))`),selectedShapeRound:o(`var(--m3e-icon-button-extra-small-selected-shape-round, var(--m3e-icon-button-selected-shape-round, ${a.shape.corner.medium}))`),selectedShapeSquare:o(`var(--m3e-icon-button-extra-small-selected-shape-square, var(--m3e-icon-button-selected-shape-square, ${a.shape.corner.full}))`),shapePressedMorph:o(`var(--m3e-icon-button-extra-small-shape-pressed-morph, var(--m3e-icon-button-shape-pressed-morph, ${a.shape.corner.small}))`),narrowLeadingSpace:o(`calc(var(--m3e-icon-button-extra-small-narrow-leading-space, var(--m3e-icon-button-narrow-leading-space, 0.25rem)) + calc(${a.density.calc(-3)} / 2))`),narrowTrailingSpace:o(`calc(var(--m3e-icon-button-extra-small-narrow-trailing-space, var(--m3e-icon-button-narrow-trailing-space, 0.25rem)) + calc(${a.density.calc(-3)} / 2))`),defaultLeadingSpace:o(`calc(var(--m3e-icon-button-extra-small-default-leading-space, var(--m3e-icon-button-default-leading-space, 0.375rem)) + calc(${a.density.calc(-3)} / 2))`),defaultTrailingSpace:o(`calc(var(--m3e-icon-button-extra-small-default-trailing-space, var(--m3e-icon-button-default-trailing-space, 0.375rem)) + calc(${a.density.calc(-3)} / 2))`),wideLeadingSpace:o(`calc(var(--m3e-icon-button-extra-small-wide-leading-space, var(--m3e-icon-button-wide-leading-space, 0.625rem)) + calc(${a.density.calc(-3)} / 2))`),wideTrailingSpace:o(`calc(var(--m3e-icon-button-extra-small-wide-trailing-space, var(--m3e-icon-button-wide-trailing-space, 0.625rem)) + calc(${a.density.calc(-3)} / 2))`)},small:{containerHeight:o(`calc(var(--m3e-icon-button-small-container-height, var(--m3e-icon-button-container-height, 2.5rem)) + ${a.density.calc(-3)})`),outlineThickness:o("var(--m3e-icon-button-small-outline-thickness, var(--m3e-icon-button-outline-thickness, 1px))"),iconSize:o("var(--m3e-icon-button-small-icon-size, var(--m3e-icon-button-icon-size, 1.5rem))"),shapeRound:o(`var(--m3e-icon-button-small-shape-round, var(--m3e-icon-button-shape-round, ${a.shape.corner.full}))`),shapeSquare:o(`var(--m3e-icon-button-small-shape-square, var(--m3e-icon-button-shape-square, ${a.shape.corner.medium}))`),selectedShapeRound:o(`var(--m3e-icon-button-small-selected-shape-round, var(--m3e-icon-button-selected-shape-round, ${a.shape.corner.medium}))`),selectedShapeSquare:o(`var(--m3e-icon-button-small-selected-shape-square, var(--m3e-icon-button-selected-shape-square, ${a.shape.corner.full}))`),shapePressedMorph:o(`var(--m3e-icon-button-small-shape-pressed-morph, var(--m3e-icon-button-shape-pressed-morph, ${a.shape.corner.small}))`),narrowLeadingSpace:o(`calc(var(--m3e-icon-button-small-narrow-leading-space, var(--m3e-icon-button-narrow-leading-space, 0.25rem)) + calc(${a.density.calc(-3)} / 2))`),narrowTrailingSpace:o(`calc(var(--m3e-icon-button-small-narrow-trailing-space, var(--m3e-icon-button-narrow-trailing-space, 0.25rem)) + calc(${a.density.calc(-3)} / 2))`),defaultLeadingSpace:o(`calc(var(--m3e-icon-button-small-default-leading-space, var(--m3e-icon-button-default-leading-space, 0.5rem)) + calc(${a.density.calc(-3)} / 2))`),defaultTrailingSpace:o(`calc(var(--m3e-icon-button-small-default-trailing-space, var(--m3e-icon-button-default-trailing-space, 0.5rem)) + calc(${a.density.calc(-3)} / 2))`),wideLeadingSpace:o(`calc(var(--m3e-icon-button-small-wide-leading-space, var(--m3e-icon-button-wide-leading-space, 0.875rem)) + calc(${a.density.calc(-3)} / 2))`),wideTrailingSpace:o(`calc(var(--m3e-icon-button-small-wide-trailing-space, var(--m3e-icon-button-wide-trailing-space, 0.875rem)) + calc(${a.density.calc(-3)} / 2))`)},medium:{containerHeight:o(`calc(var(--m3e-icon-button-medium-container-height, var(--m3e-icon-button-container-height, 3.5rem)) + ${a.density.calc(-3)})`),outlineThickness:o("var(--m3e-icon-button-medium-outline-thickness, var(--m3e-icon-button-outline-thickness, 1px))"),iconSize:o("var(--m3e-icon-button-medium-icon-size, var(--m3e-icon-button-icon-size, 1.5rem))"),shapeRound:o(`var(--m3e-icon-button-medium-shape-round, var(--m3e-icon-button-shape-round, ${a.shape.corner.full}))`),shapeSquare:o(`var(--m3e-icon-button-medium-shape-square, var(--m3e-icon-button-shape-square, ${a.shape.corner.large}))`),selectedShapeRound:o(`var(--m3e-icon-button-medium-selected-shape-round, var(--m3e-icon-button-selected-shape-round, ${a.shape.corner.large}))`),selectedShapeSquare:o(`var(--m3e-icon-button-medium-selected-shape-square, var(--m3e-icon-button-selected-shape-square, ${a.shape.corner.full}))`),shapePressedMorph:o(`var(--m3e-icon-button-medium-shape-pressed-morph, var(--m3e-icon-button-shape-pressed-morph, ${a.shape.corner.medium}))`),narrowLeadingSpace:o(`calc(var(--m3e-icon-button-medium-narrow-leading-space, var(--m3e-icon-button-narrow-leading-space, 0.75rem)) + calc(${a.density.calc(-3)} / 2))`),narrowTrailingSpace:o(`calc(var(--m3e-icon-button-medium-narrow-trailing-space, var(--m3e-icon-button-narrow-trailing-space, 0.75rem)) + calc(${a.density.calc(-3)} / 2))`),defaultLeadingSpace:o(`calc(var(--m3e-icon-button-medium-default-leading-space, var(--m3e-icon-button-default-leading-space, 1rem)) + calc(${a.density.calc(-3)} / 2))`),defaultTrailingSpace:o(`calc(var(--m3e-icon-button-medium-default-trailing-space, var(--m3e-icon-button-default-trailing-space, 1rem)) + calc(${a.density.calc(-3)} / 2))`),wideLeadingSpace:o(`calc(var(--m3e-icon-button-medium-wide-leading-space, var(--m3e-icon-button-wide-leading-space, 1.5rem)) + calc(${a.density.calc(-3)} / 2))`),wideTrailingSpace:o(`calc(var(--m3e-icon-button-medium-wide-trailing-space, var(--m3e-icon-button-wide-trailing-space, 1.5rem)) + calc(${a.density.calc(-3)} / 2))`)},large:{containerHeight:o(`calc(var(--m3e-icon-button-large-container-height, var(--m3e-icon-button-container-height, 6rem)) + ${a.density.calc(-3)})`),outlineThickness:o("var(--m3e-icon-button-large-outline-thickness, var(--m3e-icon-button-outline-thickness, 2px))"),iconSize:o("var(--m3e-icon-button-large-icon-size, var(--m3e-icon-button-icon-size, 2rem))"),shapeRound:o(`var(--m3e-icon-button-large-shape-round, var(--m3e-icon-button-shape-round, ${a.shape.corner.full}))`),shapeSquare:o(`var(--m3e-icon-button-large-shape-square, var(--m3e-icon-button-shape-square, ${a.shape.corner.extraLarge}))`),selectedShapeRound:o(`var(--m3e-icon-button-large-selected-shape-round, var(--m3e-icon-button-selected-shape-round, ${a.shape.corner.extraLarge}))`),selectedShapeSquare:o(`var(--m3e-icon-button-large-selected-shape-square, var(--m3e-icon-button-selected-shape-square, ${a.shape.corner.full}))`),shapePressedMorph:o(`var(--m3e-icon-button-large-shape-pressed-morph, var(--m3e-icon-button-shape-pressed-morph, ${a.shape.corner.large}))`),narrowLeadingSpace:o(`calc(var(--m3e-icon-button-large-narrow-leading-space, var(--m3e-icon-button-narrow-leading-space, 1rem)) + calc(${a.density.calc(-3)} / 2))`),narrowTrailingSpace:o(`calc(var(--m3e-icon-button-large-narrow-trailing-space, var(--m3e-icon-button-narrow-trailing-space, 1rem)) + calc(${a.density.calc(-3)} / 2))`),defaultLeadingSpace:o(`calc(var(--m3e-icon-button-large-default-leading-space, var(--m3e-icon-button-default-leading-space, 2rem)) + calc(${a.density.calc(-3)} / 2))`),defaultTrailingSpace:o(`calc(var(--m3e-icon-button-large-default-trailing-space, var(--m3e-icon-button-default-trailing-space, 2rem)) + calc(${a.density.calc(-3)} / 2))`),wideLeadingSpace:o(`calc(var(--m3e-icon-button-large-wide-leading-space, var(--m3e-icon-button-wide-leading-space, 3rem)) + calc(${a.density.calc(-3)} / 2))`),wideTrailingSpace:o(`calc(var(--m3e-icon-button-large-wide-trailing-space, var(--m3e-icon-button-wide-trailing-space, 3rem)) + calc(${a.density.calc(-3)} / 2))`)},"extra-large":{containerHeight:o(`calc(var(--m3e-icon-button-extra-large-container-height, var(--m3e-icon-button-container-height, 8.5rem)) + ${a.density.calc(-3)})`),outlineThickness:o("var(--m3e-icon-button-extra-large-outline-thickness, var(--m3e-icon-button-outline-thickness, 3px))"),iconSize:o("var(--m3e-icon-button-extra-large-icon-size, var(--m3e-icon-button-icon-size, 2.5rem))"),shapeRound:o(`var(--m3e-icon-button-extra-large-shape-round, var(--m3e-icon-button-shape-round, ${a.shape.corner.full}))`),shapeSquare:o(`var(--m3e-icon-button-extra-large-shape-square, var(--m3e-icon-button-shape-square, ${a.shape.corner.extraLarge}))`),selectedShapeRound:o(`var(--m3e-icon-button-extra-large-selected-shape-round, var(--m3e-icon-button-selected-shape-round, ${a.shape.corner.extraLarge}))`),selectedShapeSquare:o(`var(--m3e-icon-button-extra-large-selected-shape-square, var(--m3e-icon-button-selected-shape-square, ${a.shape.corner.full}))`),shapePressedMorph:o(`var(--m3e-icon-button-extra-large-shape-pressed-morph, var(--m3e-icon-button-shape-pressed-morph, ${a.shape.corner.large}))`),narrowLeadingSpace:o(`calc(var(--m3e-icon-button-extra-large-narrow-leading-space, var(--m3e-icon-button-narrow-leading-space, 2rem)) + calc(${a.density.calc(-3)} / 2))`),narrowTrailingSpace:o(`calc(var(--m3e-icon-button-extra-large-narrow-trailing-space, var(--m3e-icon-button-narrow-trailing-space, 2rem)) + calc(${a.density.calc(-3)} / 2))`),defaultLeadingSpace:o(`calc(var(--m3e-icon-button-extra-large-default-leading-space, var(--m3e-icon-button-default-leading-space, 3rem)) + calc(${a.density.calc(-3)} / 2))`),defaultTrailingSpace:o(`calc(var(--m3e-icon-button-extra-large-default-trailing-space, var(--m3e-icon-button-default-trailing-space, 3rem)) + calc(${a.density.calc(-3)} / 2))`),wideLeadingSpace:o(`calc(var(--m3e-icon-button-extra-large-wide-leading-space, var(--m3e-icon-button-wide-leading-space, 4.5rem)) + calc(${a.density.calc(-3)} / 2))`),wideTrailingSpace:o(`calc(var(--m3e-icon-button-extra-large-wide-trailing-space, var(--m3e-icon-button-wide-trailing-space, 4.5rem)) + calc(${a.density.calc(-3)} / 2))`)}};function bn(t){return C`:host([size="${o(t)}"]) .base { height: ${Y[t].containerHeight}; } :host([size="${o(t)}"][width="default"]) .wrapper { padding-inline-start: calc( ${Y[t].defaultLeadingSpace} - calc(var(--_adjacent-shrink, 0px) / 2) ); padding-inline-end: calc( ${Y[t].defaultTrailingSpace} - calc(var(--_adjacent-shrink, 0px) / 2) ); } :host([size="${o(t)}"][width="narrow"]) .wrapper { padding-inline-start: calc( ${Y[t].narrowLeadingSpace} - calc(var(--_adjacent-shrink, 0px) / 2) ); padding-inline-end: calc( ${Y[t].narrowTrailingSpace} - calc(var(--_adjacent-shrink, 0px) / 2) ); } :host([size="${o(t)}"][width="wide"]) .wrapper { padding-inline-start: calc( ${Y[t].wideLeadingSpace} - calc(var(--_adjacent-shrink, 0px) / 2) ); padding-inline-end: calc(${Y[t].wideTrailingSpace} - calc(var(--_adjacent-shrink, 0px) / 2)); } :host([size="${o(t)}"]) .icon { font-size: ${Y[t].iconSize}; } :host([size="${o(t)}"]) .base { outline-offset: calc(0px - ${Y[t].outlineThickness}); outline-width: ${Y[t].outlineThickness}; } :host( :not(:is(:state(--connected), :--connected))[size="${o(t)}"][shape="rounded"]:not( :is(:state(--pressed), :--pressed) ) ) .base { border-radius: var(--_button-shape, ${Y[t].shapeRound}); } :host( :is(:state(--connected), :--connected)[size="${o(t)}"][shape="rounded"][toggle][selected]:not( :is(:state(--pressed), :--pressed) ) ) .base { border-radius: var(--_button-shape, ${Y[t].shapeRound}); } :host(:not(:is(:state(--connected), :--connected))[size="${o(t)}"][shape="square"]) .base { border-radius: ${Y[t].shapeSquare}; } :host( :not(:is(:state(--connected), :--connected))[size="${o(t)}"][shape="rounded"][toggle][selected]:not( :is(:state(--pressed), :--pressed) ) ) .base { border-radius: ${Y[t].selectedShapeRound}; } :host( :not(:is(:state(--connected), :--connected))[size="${o(t)}"][shape="square"][toggle][selected]:not( :is(:state(--pressed), :--pressed) ) ) .base { border-radius: var(--_button-shape, ${Y[t].selectedShapeSquare}); } :host(:not(:is(:state(--connected), :--connected))[size="${o(t)}"]:is(:state(--pressed), :--pressed)) .base { border-radius: ${Y[t].shapePressedMorph}; } :host(:is(:state(--connected), :--connected)[size="${o(t)}"][shape="rounded"]:not([toggle][selected])) .base { border-start-start-radius: var( --_button-rounded-start-shape, var(--_button-shape, ${Y[t].shapeRound}) ); border-end-start-radius: var( --_button-rounded-start-shape, var(--_button-shape, ${Y[t].shapeRound}) ); border-start-end-radius: var( --_button-rounded-end-shape, var(--_button-shape, ${Y[t].shapeRound}) ); border-end-end-radius: var( --_button-rounded-end-shape, var(--_button-shape, ${Y[t].shapeRound}) ); } :host(:is(:state(--connected), :--connected)[size="${o(t)}"][shape="square"]) .base { border-start-start-radius: var(--_button-square-start-shape, ${Y[t].shapeSquare}); border-end-start-radius: var(--_button-square-start-shape, ${Y[t].shapeSquare}); border-start-end-radius: var(--_button-square-end-shape, ${Y[t].shapeSquare}); border-end-end-radius: var(--_button-square-end-shape, ${Y[t].shapeSquare}); } :host( :is(:state(--connected), :--connected)[size="${o(t)}"][shape="square"][toggle][selected]:not( :is(:state(--pressed), :--pressed) ) ) .base { border-radius: var(--_button-shape, ${Y[t].selectedShapeSquare}); } :host(:is(:state(--connected), :--connected)[size="${o(t)}"]:is(:state(--pressed), :--pressed)) .base { border-start-start-radius: var( --_button-start-shape-pressed-morph, ${Y[t].shapePressedMorph} ); border-end-start-radius: var(--_button-start-shape-pressed-morph, ${Y[t].shapePressedMorph}); border-start-end-radius: var(--_button-end-shape-pressed-morph, ${Y[t].shapePressedMorph}); border-end-end-radius: var(--_button-end-shape-pressed-morph, ${Y[t].shapePressedMorph}); }`}var ub=[bn("extra-small"),bn("small"),bn("medium"),bn("large"),bn("extra-large")],mb=C`:host { display: inline-block; outline: none; user-select: none; -webkit-tap-highlight-color: rgba(0, 0, 0, 0); } .base { box-sizing: border-box; vertical-align: middle; display: inline-flex; align-items: center; justify-content: center; position: relative; width: 100%; transition: ${o(`background-color ${a.motion.duration.short4} ${a.motion.easing.standard}`)}; } .touch { position: absolute; aspect-ratio: 1 / 1; height: 3rem; left: auto; right: auto; } :host(:is(:state(--pressed), :--pressed)) .base, :host(:is(:state(--resting), :--resting)) .base { transition: ${o(`background-color ${a.motion.duration.short4} ${a.motion.easing.standard},
          border-radius ${a.motion.spring.fastEffects}`)}; } .wrapper { width: 100%; overflow: hidden; display: inline-flex; align-items: center; justify-content: center; transition: ${o(`padding-inline ${a.motion.spring.fastEffects}`)}; } .icon { transition: ${o(`color ${a.motion.duration.short4} ${a.motion.easing.standard}`)}; --m3e-icon-size: 1em; } :host(:not(:disabled):not([disabled-interactive])) { cursor: pointer; } :host([disabled-interactive]) { cursor: not-allowed; } ::slotted(*) { font-size: inherit !important; flex: none; transform: var(--_icon-button-icon-transform); transform-origin: center center; transition: ${o(`transform var(--_icon-button-icon-transform-transition, ${a.motion.spring.fastEffects})`)}; } ::slotted(svg) { width: 1em; height: 1em; } :host([toggle]:not([selected])) .base.with-selected-icon slot[name="selected"], :host([toggle][selected]) .base.with-selected-icon slot:not([name]) { display: none; } a { all: unset; display: block; position: absolute; top: 0px; left: 0px; right: 0px; bottom: 0px; z-index: 1; } :host(:is(:state(--grouped), :--grouped):is(:state(--connected), :--connected)) { flex: 1 1 auto; } :host(:is(:state(--grouped), :--grouped):not(:is(:state(--connected), :--connected))) { transition: ${o(`width ${a.motion.spring.fastEffects}`)}; } :host(:is(:state(--grouped), :--grouped):not(:is(:state(--connected), :--connected))) .wrapper { transition: ${o(`padding-inline ${a.motion.spring.fastEffects}`)}; } :host(:is(:state(--grouped), :--grouped):not(:is(:state(--connected), :--connected))) { flex-shrink: 0; flex-grow: 0; } :host( :is(:state(--grouped), :--grouped):not(:is(:state(--connected), :--connected)):not( :is(:state(--pressed), :--pressed, :state(--adjacent-pressed), :--adjacent-pressed) ) ) { width: var(--_button-width); } :host( :is(:state(--grouped), :--grouped):not(:is(:state(--connected), :--connected)):not( :is(:state(--pressed), :--pressed) ):is(:state(--adjacent-pressed), :--adjacent-pressed) ) { width: calc(var(--_button-width) - var(--_adjacent-shrink, 0px)); } :host( :is(:state(--grouped), :--grouped):not(:is(:state(--connected), :--connected)):is( :state(--pressed), :--pressed ):not([disabled-interactive]):not(:disabled) ) { width: calc( var(--_button-width) + calc(var(--_button-width) * var(--m3e-standard-button-group-width-multiplier, 0.15)) ); } @media (forced-colors: active) { .base, .icon { transition: none; } :host(:is(:state(--pressed), :--pressed)) .base, :host(:is(:state(--resting), :--resting)) .base { transition: border-radius ${a.motion.spring.fastEffects}; } :host([variant]:not(:disabled):not([disabled-interactive]):not([toggle])) .base { background-color: ButtonFace; outline-color: ButtonText; } :host([variant]:not(:disabled):not([disabled-interactive]):not([toggle])) .icon { color: ButtonText; } :host([variant]:not(:disabled):not([disabled-interactive])[toggle]:not([selected])) .base { background-color: ButtonFace; outline-color: ButtonText; } :host([variant]:not(:disabled):not([disabled-interactive])[toggle]:not([selected])) .icon, :host([variant]:hover:not(:disabled):not([disabled-interactive])[toggle]:not([selected])) .icon, :host([variant]:not(:disabled):not([disabled-interactive])[toggle]:not([selected]):focus) .icon { color: ButtonText; } :host([variant]:not(:disabled):not([disabled-interactive])[toggle][selected]) .base { background-color: ButtonText; outline: none; } :host([variant]:not(:disabled):not([disabled-interactive])[toggle][selected]) .icon, :host([variant]:hover:not(:disabled):not([disabled-interactive])[toggle][selected]) .icon, :host([variant]:not(:disabled):not([disabled-interactive])[toggle][selected]:focus) .icon { forced-color-adjust: none; color: ButtonFace; background-color: ButtonText; } :host([variant]:disabled) .base, :host([variant][disabled-interactive]) .base { outline-color: GrayText; background-color: unset; } :host([variant]:disabled) .icon, :host([variant][disabled-interactive]) .icon { color: GrayText; } .base { outline-style: solid; } :host([size="extra-small"]) .base { outline-offset: calc(0px - var(--m3e-icon-button-extra-small-outline-thickness, 1px)); outline-width: var(--m3e-icon-button-extra-small-outline-thickness, 1px); } :host([size="small"]) .base { outline-offset: calc(0px - var(--m3e-icon-button-small-outline-thickness, 1px)); outline-width: var(--m3e-icon-button-small-outline-thickness, 1px); } :host([size="medium"]) .base { outline-offset: calc(0px - var(--m3e-icon-button-medium-outline-thickness, 1px)); outline-width: var(--m3e-icon-button-medium-outline-thickness, 1px); } :host([size="large"]) .base { outline-offset: calc(0px - var(--m3e-icon-button-large-outline-thickness, 2px)); outline-width: var(--m3e-icon-button-large-outline-thickness, 2px); } :host([size="extra-large"]) .base { outline-offset: calc(0px - var(--m3e-icon-button-extra-large-outline-thickness, 3px)); outline-width: var(--m3e-icon-button-extra-large-outline-thickness, 3px); } } @media (prefers-reduced-motion) { :host(:is(:state(--grouped), :--grouped):not(:is(:state(--connected), :--connected))), :host(:is(:state(--grouped), :--grouped):not(:is(:state(--connected), :--connected))) .wrapper, :host(:is(:state(--pressed), :--pressed)) .base, :host(:is(:state(--resting), :--resting)) .base, .base, .wrapper, .icon { transition: none; } }`,B={elevated:{iconColor:o(`var(--m3e-elevated-icon-button-icon-color, var(--m3e-icon-button-icon-color, ${a.color.primary}))`),containerColor:o(`var(--m3e-elevated-icon-button-container-color, var(--m3e-icon-button-container-color, ${a.color.surfaceContainerLow}))`),containerElevation:o(`var(--m3e-elevated-icon-button-container-elevation, var(--m3e-icon-button-container-elevation, ${a.elevation.level1}))`),unselectedIconColor:o(`var(--m3e-elevated-icon-button-unselected-icon-color, var(--m3e-icon-button-unselected-icon-color, ${a.color.primary}))`),unselectedContainerColor:o(`var(--m3e-elevated-icon-button-unselected-container-color, var(--m3e-icon-button-unselected-container-color, ${a.color.surfaceContainerLow}))`),selectedIconColor:o(`var(--m3e-elevated-icon-button-selected-icon-color, var(--m3e-icon-button-selected-icon-color, ${a.color.onPrimary}))`),selectedContainerColor:o(`var(--m3e-elevated-icon-button-selected-container-color, var(--m3e-icon-button-selected-container-color, ${a.color.primary}))`),disabled:{containerColor:o(`var(--m3e-elevated-icon-button-disabled-container-color, var(--m3e-icon-button-disabled-container-color, ${a.color.onSurface}))`),containerOpacity:o("var(--m3e-elevated-icon-button-disabled-container-opacity, var(--m3e-icon-button-disabled-container-opacity, 10%))"),iconColor:o(`var(--m3e-elevated-icon-button-disabled-icon-color, var(--m3e-icon-button-disabled-icon-color, ${a.color.onSurface}))`),iconOpacity:o("var(--m3e-elevated-icon-button-disabled-icon-opacity, var(--m3e-icon-button-disabled-icon-opacity, 38%))"),containerElevation:o(`var(--m3e-elevated-icon-button-disabled-container-elevation, var(--m3e-icon-button-disabled-container-elevation, ${a.elevation.level0}))`)},hover:{iconColor:o(`var(--m3e-elevated-icon-button-hover-icon-color, var(--m3e-icon-button-hover-icon-color, ${a.color.primary}))`),stateLayerColor:o(`var(--m3e-elevated-icon-button-hover-state-layer-color, var(--m3e-icon-button-hover-state-layer-color, ${a.color.primary}))`),stateLayerOpacity:o(`var(--m3e-elevated-icon-button-hover-state-layer-opacity, var(--m3e-icon-button-hover-state-layer-opacity, ${a.state.hoverStateLayerOpacity}))`),containerElevation:o(`var(--m3e-elevated-icon-button-hover-container-elevation, var(--m3e-icon-button-hover-container-elevation, ${a.elevation.level2}))`),unselectedIconColor:o(`var(--m3e-elevated-icon-button-hover-unselected-icon-color, var(--m3e-icon-button-hover-unselected-icon-color, ${a.color.primary}))`),unselectedStateLayerColor:o(`var(--m3e-elevated-icon-button-hover-unselected-state-layer-color, var(--m3e-icon-button-hover-unselected-state-layer-color, ${a.color.primary}))`),selectedIconColor:o(`var(--m3e-elevated-icon-button-hover-selected-icon-color, var(--m3e-icon-button-hover-selected-icon-color, ${a.color.onPrimary}))`),selectedStateLayerColor:o(`var(--m3e-elevated-icon-button-hover-selected-state-layer-color, var(--m3e-icon-button-hover-selected-state-layer-color, ${a.color.onPrimary}))`)},focus:{iconColor:o(`var(--m3e-elevated-icon-button-focus-icon-color, var(--m3e-icon-button-focus-icon-color, ${a.color.primary}))`),stateLayerColor:o(`var(--m3e-elevated-icon-button-focus-state-layer-color, var(--m3e-icon-button-focus-state-layer-color, ${a.color.primary}))`),stateLayerOpacity:o(`var(--m3e-elevated-icon-button-focus-state-layer-opacity, var(--m3e-icon-button-focus-state-layer-opacity, ${a.state.focusStateLayerOpacity}))`),containerElevation:o(`var(--m3e-elevated-icon-button-focus-container-elevation, var(--m3e-icon-button-focus-container-elevation, ${a.elevation.level1}))`),unselectedIconColor:o(`var(--m3e-elevated-icon-button-focus-unselected-icon-color, var(--m3e-icon-button-focus-unselected-icon-color, ${a.color.primary}))`),unselectedStateLayerColor:o(`var(--m3e-elevated-icon-button-focus-unselected-state-layer-color, var(--m3e-icon-button-focus-unselected-state-layer-color, ${a.color.primary}))`),selectedIconColor:o(`var(--m3e-elevated-icon-button-focus-selected-icon-color, var(--m3e-icon-button-focus-selected-icon-color, ${a.color.onPrimary}))`),selectedStateLayerColor:o(`var(--m3e-elevated-icon-button-focus-selected-state-layer-color, var(--m3e-icon-button-focus-selected-state-layer-color, ${a.color.onPrimary}))`)},pressed:{iconColor:o(`var(--m3e-elevated-icon-button-pressed-icon-color, var(--m3e-icon-button-pressed-icon-color, ${a.color.primary}))`),stateLayerColor:o(`var(--m3e-elevated-icon-button-pressed-state-layer-color, var(--m3e-icon-button-pressed-state-layer-color, ${a.color.primary}))`),stateLayerOpacity:o(`var(--m3e-elevated-icon-button-pressed-state-layer-opacity, var(--m3e-icon-button-pressed-state-layer-opacity, ${a.state.pressedStateLayerOpacity}))`),containerElevation:o(`var(--m3e-elevated-icon-button-pressed-container-elevation, var(--m3e-icon-button-pressed-container-elevation, ${a.elevation.level1}))`),unselectedIconColor:o(`var(--m3e-elevated-icon-button-pressed-unselected-icon-color, var(--m3e-icon-button-pressed-unselected-icon-color, ${a.color.primary}))`),unselectedStateLayerColor:o(`var(--m3e-elevated-icon-button-pressed-unselected-state-layer-color, var(--m3e-icon-button-pressed-unselected-state-layer-color, ${a.color.primary}))`),selectedIconColor:o(`var(--m3e-elevated-icon-button-pressed-selected-icon-color, var(--m3e-icon-button-pressed-selected-icon-color, ${a.color.onPrimary}))`),selectedStateLayerColor:o(`var(--m3e-elevated-icon-button-pressed-selected-state-layer-color, var(--m3e-icon-button-pressed-selected-state-layer-color, ${a.color.onPrimary}))`)}},outlined:{iconColor:o(`var(--m3e-outlined-icon-button-icon-color, var(--m3e-icon-button-icon-color, ${a.color.onSurfaceVariant}))`),outlineColor:o(`var(--m3e-outlined-icon-button-outline-color, var(--m3e-icon-button-outline-color, ${a.color.outlineVariant}))`),unselectedIconColor:o(`var(--m3e-outlined-icon-button-unselected-icon-color, var(--m3e-icon-button-unselected-icon-color, ${a.color.onSurfaceVariant}))`),selectedIconColor:o(`var(--m3e-outlined-icon-button-selected-icon-color, var(--m3e-icon-button-selected-icon-color, ${a.color.inverseOnSurface}))`),selectedContainerColor:o(`var(--m3e-outlined-icon-button-selected-container-color, var(--m3e-icon-button-selected-container-color, ${a.color.inverseSurface}))`),disabled:{containerColor:o(`var(--m3e-outlined-icon-button-disabled-container-color, var(--m3e-icon-button-disabled-container-color, ${a.color.onSurface}))`),containerOpacity:o("var(--m3e-outlined-icon-button-disabled-container-opacity, var(--m3e-icon-button-disabled-container-opacity, 10%))"),iconColor:o(`var(--m3e-outlined-icon-button-disabled-icon-color, var(--m3e-icon-button-disabled-icon-color, ${a.color.onSurface}))`),iconOpacity:o("var(--m3e-outlined-icon-button-disabled-icon-opacity, var(--m3e-icon-button-disabled-icon-opacity, 38%))"),outlineColor:o(`var(--m3e-outlined-icon-button-disabled-outline-color, var(--m3e-icon-button-disabled-outline-color, ${a.color.outlineVariant}))`)},hover:{iconColor:o(`var(--m3e-outlined-icon-button-hover-icon-color, var(--m3e-icon-button-hover-icon-color, ${a.color.onSurfaceVariant}))`),outlineColor:o(`var(--m3e-outlined-icon-button-hover-outline-color, var(--m3e-icon-button-hover-outline-color, ${a.color.outlineVariant}))`),stateLayerColor:o(`var(--m3e-outlined-icon-button-hover-state-layer-color, var(--m3e-icon-button-hover-state-layer-color, ${a.color.onSurfaceVariant}))`),stateLayerOpacity:o(`var(--m3e-outlined-icon-button-hover-state-layer-opacity, var(--m3e-icon-button-hover-state-layer-opacity, ${a.state.hoverStateLayerOpacity}))`),unselectedIconColor:o(`var(--m3e-outlined-icon-button-hover-unselected-icon-color, var(--m3e-icon-button-hover-unselected-icon-color, ${a.color.onSurfaceVariant}))`),unselectedStateLayerColor:o(`var(--m3e-outlined-icon-button-hover-unselected-state-layer-color, var(--m3e-icon-button-hover-unselected-state-layer-color, ${a.color.onSurfaceVariant}))`),selectedIconColor:o(`var(--m3e-outlined-icon-button-hover-selected-icon-color, var(--m3e-icon-button-hover-selected-icon-color, ${a.color.inverseOnSurface}))`),selectedStateLayerColor:o(`var(--m3e-outlined-icon-button-hover-selected-state-layer-color, var(--m3e-icon-button-hover-selected-state-layer-color, ${a.color.inverseOnSurface}))`)},focus:{iconColor:o(`var(--m3e-outlined-icon-button-focus-icon-color, var(--m3e-icon-button-focus-icon-color, ${a.color.onSurfaceVariant}))`),outlineColor:o(`var(--m3e-outlined-icon-button-focus-outline-color, var(--m3e-icon-button-focus-outline-color, ${a.color.outlineVariant}))`),stateLayerColor:o(`var(--m3e-outlined-icon-button-focus-state-layer-color, var(--m3e-icon-button-focus-state-layer-color, ${a.color.onSurfaceVariant}))`),stateLayerOpacity:o(`var(--m3e-outlined-icon-button-focus-state-layer-opacity, var(--m3e-icon-button-focus-state-layer-opacity, ${a.state.focusStateLayerOpacity}))`),unselectedIconColor:o(`var(--m3e-outlined-icon-button-focus-unselected-icon-color, var(--m3e-icon-button-focus-unselected-icon-color, ${a.color.onSurfaceVariant}))`),unselectedStateLayerColor:o(`var(--m3e-outlined-icon-button-focus-unselected-state-layer-color, var(--m3e-icon-button-focus-unselected-state-layer-color, ${a.color.onSurfaceVariant}))`),selectedIconColor:o(`var(--m3e-outlined-icon-button-focus-selected-icon-color, var(--m3e-icon-button-focus-selected-icon-color, ${a.color.inverseOnSurface}))`),selectedStateLayerColor:o(`var(--m3e-outlined-icon-button-focus-selected-state-layer-color, var(--m3e-icon-button-focus-selected-state-layer-color, ${a.color.inverseOnSurface}))`)},pressed:{iconColor:o(`var(--m3e-outlined-icon-button-pressed-icon-color, var(--m3e-icon-button-pressed-icon-color, ${a.color.onSurfaceVariant}))`),outlineColor:o(`var(--m3e-outlined-icon-button-pressed-outline-color, var(--m3e-icon-button-pressed-outline-color, ${a.color.outlineVariant}))`),stateLayerColor:o(`var(--m3e-outlined-icon-button-pressed-state-layer-color, var(--m3e-icon-button-pressed-state-layer-color, ${a.color.onSurfaceVariant}))`),stateLayerOpacity:o(`var(--m3e-outlined-icon-button-pressed-state-layer-opacity, var(--m3e-icon-button-pressed-state-layer-opacity, ${a.state.pressedStateLayerOpacity}))`),unselectedIconColor:o(`var(--m3e-outlined-icon-button-pressed-unselected-icon-color, var(--m3e-icon-button-pressed-unselected-icon-color, ${a.color.onSurfaceVariant}))`),unselectedStateLayerColor:o(`var(--m3e-outlined-icon-button-pressed-unselected-state-layer-color, var(--m3e-icon-button-pressed-unselected-state-layer-color, ${a.color.onSurfaceVariant}))`),selectedIconColor:o(`var(--m3e-outlined-icon-button-pressed-selected-icon-color, var(--m3e-icon-button-pressed-selected-icon-color, ${a.color.inverseOnSurface}))`),selectedStateLayerColor:o(`var(--m3e-outlined-icon-button-pressed-selected-state-layer-color, var(--m3e-icon-button-pressed-selected-state-layer-color, ${a.color.inverseOnSurface}))`)}},filled:{iconColor:o(`var(--m3e-filled-icon-button-icon-color, var(--m3e-icon-button-icon-color, ${a.color.onPrimary}))`),containerColor:o(`var(--m3e-filled-icon-button-container-color, var(--m3e-icon-button-container-color, ${a.color.primary}))`),unselectedIconColor:o(`var(--m3e-filled-icon-button-unselected-icon-color, var(--m3e-icon-button-unselected-icon-color, ${a.color.onSurfaceVariant}))`),unselectedContainerColor:o(`var(--m3e-filled-icon-button-unselected-container-color, var(--m3e-icon-button-unselected-container-color, ${a.color.surfaceContainer}))`),selectedIconColor:o(`var(--m3e-filled-icon-button-selected-icon-color, var(--m3e-icon-button-selected-icon-color, ${a.color.onPrimary}))`),selectedContainerColor:o(`var(--m3e-filled-icon-button-selected-container-color, var(--m3e-icon-button-selected-container-color, ${a.color.primary}))`),disabled:{containerColor:o(`var(--m3e-filled-icon-button-disabled-container-color, var(--m3e-icon-button-disabled-container-color, ${a.color.onSurface}))`),containerOpacity:o("var(--m3e-filled-icon-button-disabled-container-opacity, var(--m3e-icon-button-disabled-container-opacity, 10%))"),iconColor:o(`var(--m3e-filled-icon-button-disabled-icon-color, var(--m3e-icon-button-disabled-icon-color, ${a.color.onSurface}))`),iconOpacity:o("var(--m3e-filled-icon-button-disabled-icon-opacity, var(--m3e-icon-button-disabled-icon-opacity, 38%))")},hover:{iconColor:o(`var(--m3e-filled-icon-button-hover-icon-color, var(--m3e-icon-button-hover-icon-color, ${a.color.onPrimary}))`),stateLayerColor:o(`var(--m3e-filled-icon-button-hover-state-layer-color, var(--m3e-icon-button-hover-state-layer-color, ${a.color.onPrimary}))`),stateLayerOpacity:o(`var(--m3e-filled-icon-button-hover-state-layer-opacity, var(--m3e-icon-button-hover-state-layer-opacity, ${a.state.hoverStateLayerOpacity}))`),unselectedIconColor:o(`var(--m3e-filled-icon-button-hover-unselected-icon-color, var(--m3e-icon-button-hover-unselected-icon-color, ${a.color.onSurfaceVariant}))`),unselectedStateLayerColor:o(`var(--m3e-filled-icon-button-hover-unselected-state-layer-color, var(--m3e-icon-button-hover-unselected-state-layer-color, ${a.color.onSurfaceVariant}))`),selectedIconColor:o(`var(--m3e-filled-icon-button-hover-selected-icon-color, var(--m3e-icon-button-hover-selected-icon-color, ${a.color.onPrimary}))`),selectedStateLayerColor:o(`var(--m3e-filled-icon-button-hover-selected-state-layer-color, var(--m3e-icon-button-hover-selected-state-layer-color, ${a.color.onPrimary}))`)},focus:{iconColor:o(`var(--m3e-filled-icon-button-focus-icon-color, var(--m3e-icon-button-focus-icon-color, ${a.color.onPrimary}))`),stateLayerColor:o(`var(--m3e-filled-icon-button-focus-state-layer-color, var(--m3e-icon-button-focus-state-layer-color, ${a.color.onPrimary}))`),stateLayerOpacity:o(`var(--m3e-filled-icon-button-focus-state-layer-opacity, var(--m3e-icon-button-focus-state-layer-opacity, ${a.state.focusStateLayerOpacity}))`),unselectedIconColor:o(`var(--m3e-filled-icon-button-focus-unselected-icon-color, var(--m3e-icon-button-focus-unselected-icon-color, ${a.color.onSurfaceVariant}))`),unselectedStateLayerColor:o(`var(--m3e-filled-icon-button-focus-unselected-state-layer-color, var(--m3e-icon-button-focus-unselected-state-layer-color, ${a.color.onSurfaceVariant}))`),selectedIconColor:o(`var(--m3e-filled-icon-button-focus-selected-icon-color, var(--m3e-icon-button-focus-selected-icon-color, ${a.color.onPrimary}))`),selectedStateLayerColor:o(`var(--m3e-filled-icon-button-focus-selected-state-layer-color, var(--m3e-icon-button-focus-selected-state-layer-color, ${a.color.onPrimary}))`)},pressed:{iconColor:o(`var(--m3e-filled-icon-button-pressed-icon-color, var(--m3e-icon-button-pressed-icon-color, ${a.color.onPrimary}))`),stateLayerColor:o(`var(--m3e-filled-icon-button-pressed-state-layer-color, var(--m3e-icon-button-pressed-state-layer-color, ${a.color.onPrimary}))`),stateLayerOpacity:o(`var(--m3e-filled-icon-button-pressed-state-layer-opacity, var(--m3e-icon-button-pressed-state-layer-opacity, ${a.state.pressedStateLayerOpacity}))`),unselectedIconColor:o(`var(--m3e-filled-icon-button-pressed-unselected-icon-color, var(--m3e-icon-button-pressed-unselected-icon-color, ${a.color.onSurfaceVariant}))`),unselectedStateLayerColor:o(`var(--m3e-filled-icon-button-pressed-unselected-state-layer-color, var(--m3e-icon-button-pressed-unselected-state-layer-color, ${a.color.onSurfaceVariant}))`),selectedIconColor:o(`var(--m3e-filled-icon-button-pressed-selected-icon-color, var(--m3e-icon-button-pressed-selected-icon-color, ${a.color.onPrimary}))`),selectedStateLayerColor:o(`var(--m3e-filled-icon-button-pressed-selected-state-layer-color, var(--m3e-icon-button-pressed-selected-state-layer-color, ${a.color.onPrimary}))`)}},tonal:{iconColor:o(`var(--m3e-tonal-icon-button-icon-color, var(--m3e-icon-button-icon-color, ${a.color.onSecondaryContainer}))`),containerColor:o(`var(--m3e-tonal-icon-button-container-color, var(--m3e-icon-button-container-color, ${a.color.secondaryContainer}))`),unselectedIconColor:o(`var(--m3e-tonal-icon-button-unselected-icon-color, var(--m3e-icon-button-unselected-icon-color, ${a.color.onSecondaryContainer}))`),unselectedContainerColor:o(`var(--m3e-tonal-icon-button-unselected-container-color, var(--m3e-icon-button-unselected-container-color, ${a.color.secondaryContainer}))`),selectedIconColor:o(`var(--m3e-tonal-icon-button-selected-icon-color, var(--m3e-icon-button-selected-icon-color, ${a.color.onSecondary}))`),selectedContainerColor:o(`var(--m3e-tonal-icon-button-selected-container-color, var(--m3e-icon-button-selected-container-color, ${a.color.secondary}))`),disabled:{containerColor:o(`var(--m3e-tonal-icon-button-disabled-container-color, var(--m3e-icon-button-disabled-container-color, ${a.color.onSurface}))`),containerOpacity:o("var(--m3e-tonal-icon-button-disabled-container-opacity, var(--m3e-icon-button-disabled-container-opacity, 10%))"),iconColor:o(`var(--m3e-tonal-icon-button-disabled-icon-color, var(--m3e-icon-button-disabled-icon-color, ${a.color.onSurface}))`),iconOpacity:o("var(--m3e-tonal-icon-button-disabled-icon-opacity, var(--m3e-icon-button-disabled-icon-opacity, 38%))")},hover:{iconColor:o(`var(--m3e-tonal-icon-button-hover-icon-color, var(--m3e-icon-button-hover-icon-color, ${a.color.onSecondaryContainer}))`),stateLayerColor:o(`var(--m3e-tonal-icon-button-hover-state-layer-color, var(--m3e-icon-button-hover-state-layer-color, ${a.color.onSecondaryContainer}))`),stateLayerOpacity:o(`var(--m3e-tonal-icon-button-hover-state-layer-opacity, var(--m3e-icon-button-hover-state-layer-opacity, ${a.state.hoverStateLayerOpacity}))`),unselectedIconColor:o(`var(--m3e-tonal-icon-button-hover-unselected-icon-color, var(--m3e-icon-button-hover-unselected-icon-color, ${a.color.onSecondaryContainer}))`),unselectedStateLayerColor:o(`var(--m3e-tonal-icon-button-hover-unselected-state-layer-color, var(--m3e-icon-button-hover-unselected-state-layer-color, ${a.color.onSecondaryContainer}))`),selectedIconColor:o(`var(--m3e-tonal-icon-button-hover-selected-icon-color, var(--m3e-icon-button-hover-selected-icon-color, ${a.color.onSecondary}))`),selectedStateLayerColor:o(`var(--m3e-tonal-icon-button-hover-selected-state-layer-color, var(--m3e-icon-button-hover-selected-state-layer-color, ${a.color.onSecondary}))`)},focus:{iconColor:o(`var(--m3e-tonal-icon-button-focus-icon-color, var(--m3e-icon-button-focus-icon-color, ${a.color.onSecondaryContainer}))`),stateLayerColor:o(`var(--m3e-tonal-icon-button-focus-state-layer-color, var(--m3e-icon-button-focus-state-layer-color, ${a.color.onSecondaryContainer}))`),stateLayerOpacity:o(`var(--m3e-tonal-icon-button-focus-state-layer-opacity, var(--m3e-icon-button-focus-state-layer-opacity, ${a.state.focusStateLayerOpacity}))`),unselectedIconColor:o(`var(--m3e-tonal-icon-button-focus-unselected-icon-color, var(--m3e-icon-button-focus-unselected-icon-color, ${a.color.onSecondaryContainer}))`),unselectedStateLayerColor:o(`var(--m3e-tonal-icon-button-focus-unselected-state-layer-color, var(--m3e-icon-button-focus-unselected-state-layer-color, ${a.color.onSecondaryContainer}))`),selectedIconColor:o(`var(--m3e-tonal-icon-button-focus-selected-icon-color, var(--m3e-icon-button-focus-selected-icon-color, ${a.color.onSecondary}))`),selectedStateLayerColor:o(`var(--m3e-tonal-icon-button-focus-selected-state-layer-color, var(--m3e-icon-button-focus-selected-state-layer-color, ${a.color.onSecondary}))`)},pressed:{iconColor:o(`var(--m3e-tonal-icon-button-pressed-icon-color, var(--m3e-icon-button-pressed-icon-color, ${a.color.onSecondaryContainer}))`),stateLayerColor:o(`var(--m3e-tonal-icon-button-pressed-state-layer-color, var(--m3e-icon-button-pressed-state-layer-color, ${a.color.onSecondaryContainer}))`),stateLayerOpacity:o(`var(--m3e-tonal-icon-button-pressed-state-layer-opacity, var(--m3e-icon-button-pressed-state-layer-opacity, ${a.state.pressedStateLayerOpacity}))`),unselectedIconColor:o(`var(--m3e-tonal-icon-button-pressed-unselected-icon-color, var(--m3e-icon-button-pressed-unselected-icon-color, ${a.color.onSecondaryContainer}))`),unselectedStateLayerColor:o(`var(--m3e-tonal-icon-button-pressed-unselected-state-layer-color, var(--m3e-icon-button-pressed-unselected-state-layer-color, ${a.color.onSecondaryContainer}))`),selectedIconColor:o(`var(--m3e-tonal-icon-button-pressed-selected-icon-color, var(--m3e-icon-button-pressed-selected-icon-color, ${a.color.onSecondary}))`),selectedStateLayerColor:o(`var(--m3e-tonal-icon-button-pressed-selected-state-layer-color, var(--m3e-icon-button-pressed-selected-state-layer-color, ${a.color.onSecondary}))`)}},standard:{iconColor:o(`var(--m3e-standard-icon-button-icon-color, var(--m3e-icon-button-icon-color, ${a.color.onSurfaceVariant}))`),unselectedIconColor:o(`var(--m3e-standard-icon-button-unselected-icon-color, var(--m3e-icon-button-unselected-icon-color, ${a.color.onSurfaceVariant}))`),selectedIconColor:o(`var(--m3e-standard-icon-button-selected-icon-color, var(--m3e-icon-button-selected-icon-color, ${a.color.primary}))`),disabled:{containerColor:o("var(--m3e-standard-icon-button-disabled-container-color, var(--m3e-icon-button-disabled-container-color, transparent))"),containerOpacity:o("var(--m3e-standard-icon-button-disabled-container-opacity, var(--m3e-icon-button-disabled-container-opacity, 10%))"),iconColor:o(`var(--m3e-standard-icon-button-disabled-icon-color, var(--m3e-icon-button-disabled-icon-color, ${a.color.onSurface}))`),iconOpacity:o("var(--m3e-standard-icon-button-disabled-icon-opacity, var(--m3e-icon-button-disabled-icon-opacity, 38%))")},hover:{iconColor:o(`var(--m3e-standard-icon-button-hover-icon-color, var(--m3e-icon-button-hover-icon-color, ${a.color.onSurfaceVariant}))`),stateLayerColor:o(`var(--m3e-standard-icon-button-hover-state-layer-color, var(--m3e-icon-button-hover-state-layer-color, ${a.color.onSurfaceVariant}))`),stateLayerOpacity:o(`var(--m3e-standard-icon-button-hover-state-layer-opacity, var(--m3e-icon-button-hover-state-layer-opacity, ${a.state.hoverStateLayerOpacity}))`),unselectedIconColor:o(`var(--m3e-standard-icon-button-hover-unselected-icon-color, var(--m3e-icon-button-hover-unselected-icon-color, ${a.color.onSurfaceVariant}))`),unselectedStateLayerColor:o(`var(--m3e-standard-icon-button-hover-unselected-state-layer-color, var(--m3e-icon-button-hover-unselected-state-layer-color, ${a.color.onSurfaceVariant}))`),selectedIconColor:o(`var(--m3e-standard-icon-button-hover-selected-icon-color, var(--m3e-icon-button-hover-selected-icon-color, ${a.color.primary}))`),selectedStateLayerColor:o(`var(--m3e-standard-icon-button-hover-selected-state-layer-color, var(--m3e-icon-button-hover-selected-state-layer-color, ${a.color.primary}))`)},focus:{iconColor:o(`var(--m3e-standard-icon-button-focus-icon-color, var(--m3e-icon-button-focus-icon-color, ${a.color.onSurfaceVariant}))`),stateLayerColor:o(`var(--m3e-standard-icon-button-focus-state-layer-color, var(--m3e-icon-button-focus-state-layer-color, ${a.color.onSurfaceVariant}))`),stateLayerOpacity:o(`var(--m3e-standard-icon-button-focus-state-layer-opacity, var(--m3e-icon-button-focus-state-layer-opacity, ${a.state.focusStateLayerOpacity}))`),unselectedIconColor:o(`var(--m3e-standard-icon-button-focus-unselected-icon-color, var(--m3e-icon-button-focus-unselected-icon-color, ${a.color.onSurfaceVariant}))`),unselectedStateLayerColor:o(`var(--m3e-standard-icon-button-focus-unselected-state-layer-color, var(--m3e-icon-button-focus-unselected-state-layer-color, ${a.color.onSurfaceVariant}))`),selectedIconColor:o(`var(--m3e-standard-icon-button-focus-selected-icon-color, var(--m3e-icon-button-focus-selected-icon-color, ${a.color.primary}))`),selectedStateLayerColor:o(`var(--m3e-standard-icon-button-focus-selected-state-layer-color, var(--m3e-icon-button-focus-selected-state-layer-color, ${a.color.primary}))`)},pressed:{iconColor:o(`var(--m3e-standard-icon-button-pressed-icon-color, var(--m3e-icon-button-pressed-icon-color, ${a.color.onSurfaceVariant}))`),stateLayerColor:o(`var(--m3e-standard-icon-button-pressed-state-layer-color, var(--m3e-icon-button-pressed-state-layer-color, ${a.color.onSurfaceVariant}))`),stateLayerOpacity:o(`var(--m3e-standard-icon-button-pressed-state-layer-opacity, var(--m3e-icon-button-pressed-state-layer-opacity, ${a.state.pressedStateLayerOpacity}))`),unselectedIconColor:o(`var(--m3e-standard-icon-button-pressed-unselected-icon-color, var(--m3e-icon-button-pressed-unselected-icon-color, ${a.color.onSurfaceVariant}))`),unselectedStateLayerColor:o(`var(--m3e-standard-icon-button-pressed-unselected-state-layer-color, var(--m3e-icon-button-pressed-unselected-state-layer-color, ${a.color.onSurfaceVariant}))`),selectedIconColor:o(`var(--m3e-standard-icon-button-pressed-selected-icon-color, var(--m3e-icon-button-pressed-selected-icon-color, ${a.color.primary}))`),selectedStateLayerColor:o(`var(--m3e-standard-icon-button-pressed-selected-state-layer-color, var(--m3e-icon-button-pressed-selected-state-layer-color, ${a.color.primary}))`)}}};function vn(t){return C`:host([variant="${o(t)}"]:not(:disabled):not([disabled-interactive])) .base { background-color: ${B[t].containerColor??o("unset")}; --m3e-state-layer-hover-color: ${B[t].hover.stateLayerColor}; --m3e-state-layer-hover-opacity: ${B[t].hover.stateLayerOpacity}; --m3e-state-layer-focus-color: ${B[t].focus.stateLayerColor}; --m3e-state-layer-focus-opacity: ${B[t].focus.stateLayerOpacity}; --m3e-ripple-color: ${B[t].pressed.stateLayerColor}; --m3e-ripple-opacity: ${B[t].pressed.stateLayerOpacity}; --m3e-elevation-level: ${B[t].containerElevation??o("unset")}; --m3e-elevation-hover-level: ${B[t].hover.containerElevation??o("unset")}; --m3e-elevation-focus-level: ${B[t].focus.containerElevation??o("unset")}; --m3e-elevation-pressed-level: ${B[t].pressed.containerElevation??o("unset")}; } :host([variant="${o(t)}"][toggle]:not([selected]):not(:disabled):not([disabled-interactive])) .base { background-color: ${B[t].unselectedContainerColor??o("unset")}; --m3e-state-layer-hover-color: ${B[t].hover.unselectedStateLayerColor}; --m3e-state-layer-focus-color: ${B[t].focus.unselectedStateLayerColor}; --m3e-ripple-color: ${B[t].pressed.unselectedStateLayerColor}; } :host([variant="${o(t)}"][toggle][selected]:not(:disabled):not([disabled-interactive])) .base { background-color: ${B[t].selectedContainerColor??o("unset")}; --m3e-state-layer-hover-color: ${B[t].hover.selectedStateLayerColor}; --m3e-state-layer-focus-color: ${B[t].focus.selectedStateLayerColor}; --m3e-ripple-color: ${B[t].pressed.selectedStateLayerColor}; } :host([variant="${o(t)}"]:not(:disabled):not([disabled-interactive])) .base { outline-color: ${B[t].outlineColor??o("unset")}; } :host([variant="${o(t)}"]:focus:not(:disabled):not([disabled-interactive])) .base { outline-color: ${B[t].focus.outlineColor??o("unset")}; } :host([variant="${o(t)}"]:hover:not(:disabled):not([disabled-interactive])) .base { outline-color: ${B[t].hover.outlineColor??o("unset")}; } :host( [variant="${o(t)}"]:is(:state(--pressed), :--pressed):not(:disabled):not([disabled-interactive]) ) .base { outline-color: ${B[t].pressed.outlineColor??o("unset")}; } :host([variant="${o(t)}"]:not(:disabled):not([disabled-interactive])) .icon { color: ${B[t].iconColor}; } :host([variant="${o(t)}"][toggle]:not([selected]):not(:disabled):not([disabled-interactive])) .icon { color: ${B[t].unselectedIconColor}; } :host([variant="${o(t)}"][toggle][selected]:not(:disabled):not([disabled-interactive])) .icon { color: ${B[t].selectedIconColor}; } :host([variant="${o(t)}"]:focus:not(:disabled):not([disabled-interactive])) .icon { color: ${B[t].focus.iconColor}; } :host([variant="${o(t)}"][toggle]:not([selected]):focus:not(:disabled):not([disabled-interactive])) .icon { color: ${B[t].focus.unselectedIconColor}; } :host([variant="${o(t)}"][toggle][selected]:focus:not(:disabled):not([disabled-interactive])) .icon { color: ${B[t].focus.selectedIconColor}; } :host([variant="${o(t)}"]:hover:not(:disabled):not([disabled-interactive])) .icon { color: ${B[t].hover.iconColor}; } :host([variant="${o(t)}"][toggle]:not([selected]):hover:not(:disabled):not([disabled-interactive])) .icon { color: ${B[t].hover.unselectedIconColor}; } :host([variant="${o(t)}"][toggle][selected]:hover:not(:disabled):not([disabled-interactive])) .icon { color: ${B[t].hover.selectedIconColor}; } :host( [variant="${o(t)}"]:is(:state(--pressed), :--pressed):not(:disabled):not([disabled-interactive]) ) .icon { color: ${B[t].pressed.iconColor}; } :host( [variant="${o(t)}"][toggle]:not([selected]):is(:state(--pressed), :--pressed):not(:disabled):not( [disabled-interactive] ) ) .icon { color: ${B[t].pressed.unselectedIconColor}; } :host( [variant="${o(t)}"][toggle][selected]:is(:state(--pressed), :--pressed):not(:disabled):not( [disabled-interactive] ) ) .icon { color: ${B[t].pressed.selectedIconColor}; } :host([variant="${o(t)}"]:disabled) .base, :host([variant="${o(t)}"][disabled-interactive]) .base { outline-color: ${B[t].disabled.outlineColor??o("unset")}; background-color: color-mix( in srgb, ${B[t].disabled.containerColor} ${B[t].disabled.containerOpacity}, transparent ); } :host([variant="${o(t)}"]:disabled) .icon, :host([variant="${o(t)}"][disabled-interactive]) .icon { color: color-mix( in srgb, ${B[t].disabled.iconColor} ${B[t].disabled.iconOpacity}, transparent ); }`}var pb=[vn("standard"),vn("outlined"),vn("filled"),vn("tonal"),vn("elevated"),C`:host([variant="outlined"]:not([toggle][selected]):not(:disabled):not([disabled-interactive])) .base { outline-style: solid; }`],Rt,Ms,Hc,Wc,Nc,Qu,Ku,$e=class extends De(wt(yt(Be(Ze(se(Q(W(P,"button"),!0))))))){constructor(){super(),Rt.add(this),this._adjacentPressedTimeout=-1,Ms.set(this,e=>n(this,Rt,"m",Qu).call(this,e)),this.variant="standard",this.shape="rounded",this.size="small",this.width="default",this.toggle=!1,this.selected=!1,new we(this,{callback:()=>this._handleResize()}),new je(this,{callback:e=>{!this.disabledInteractive&&!e&&!this.grouped&&this._base?.style.removeProperty("--_button-shape")}}),new fe(this,{isPressedKey:e=>e===" ",minPressedDuration:150,callback:e=>{!this.disabled&&!this.disabledInteractive&&(e?(n(this,Rt,"m",Hc).call(this),n(this,Rt,"m",Wc).call(this,!0)):n(this,Rt,"m",Wc).call(this,!1))}})}get grouped(){return ie(this,"--grouped")}render(){return w`<div class="base"><m3e-state-layer class="state-layer" ?disabled="${this.disabled||this.disabledInteractive}"></m3e-state-layer><m3e-elevation class="elevation" ?disabled="${this.disabled||this.disabledInteractive}"></m3e-elevation><m3e-focus-ring class="focus-ring" ?disabled="${this.disabled}"></m3e-focus-ring><m3e-ripple class="ripple" centered ?disabled="${this.disabled||this.disabledInteractive}"></m3e-ripple><div class="touch" aria-hidden="true"></div>${this[xt]()}<div class="wrapper">${this.toggle?w`<slot class="icon" name="selected" aria-hidden="true" @slotchange="${n(this,Rt,"m",Ku)}"></slot>`:F}<slot class="icon" aria-hidden="true"></slot></div></div>`}connectedCallback(){super.connectedCallback(),this.addEventListener("click",n(this,Ms,"f"))}disconnectedCallback(){super.disconnectedCallback(),["--pressed","--resting","--grouped","--connected"].forEach(e=>D(this,e)),this._base?.style.removeProperty("--_button-shape"),this.style.removeProperty("--_button-width"),this.style.removeProperty("--_adjacent-shrink"),D(this,"--adjacent-pressed"),this.removeEventListener("click",n(this,Ms,"f"))}firstUpdated(e){super.firstUpdated(e),[this._elevation,this._focusRing,this._stateLayer,this._ripple].forEach(r=>r?.attach(this))}updated(e){if(super.updated(e),(e.has("disabled")&&this.disabled||e.has("disabledInteractive")&&this.disabledInteractive)&&(D(this,"--pressed"),D(this,"--resting")),(e.has("toggle")||e.has("selected"))&&(this.ariaPressed=this.toggle?`${this.selected}`:null,this.toggle))for(let r of this.querySelectorAll("m3e-icon"))r.toggleAttribute("filled",this.selected)}_handleResize(){this.grouped&&!ie(this,"--no-resize")&&this!==document.activeElement&&(this.style.setProperty("--_button-width",`${this.getBoundingClientRect().width}px`),n(this,Rt,"m",Hc).call(this,!0))}};Ms=new WeakMap;Rt=new WeakSet;Hc=function(e=!1){if(!this._base)return;let r=parseFloat(getComputedStyle(this._base).borderRadius);if(!isNaN(r)||e){let i=this.clientHeight/2;(i<r||e)&&this._base?.style.setProperty("--_button-shape",`${i}px`)}};Wc=function(e){let r=this.getBoundingClientRect().width,i=this.closest("m3e-button-group");if(i&&i.variant==="standard"){let s=[...i.querySelectorAll("m3e-button,m3e-icon-button")];for(let c of s)clearTimeout(c._adjacentPressedTimeout),c._adjacentPressedTimeout=-1;let l=s.indexOf(this);if(e){let c=parseFloat(getComputedStyle(this).getPropertyValue("--m3e-standard-button-group-width-multiplier")||"0.15"),d=r*c;l>0&&l<s.length-1&&(d/=2);for(let u=0;u<s.length;u++)u==l-1||u==l+1?(ae(s[u],"--no-resize"),s[u].style.setProperty("--_adjacent-shrink",`${d}px`),ae(s[u],"--adjacent-pressed")):u==l?(ae(s[u],"--no-resize"),s[u].style.removeProperty("--_adjacent-shrink"),D(s[u],"--adjacent-pressed")):(D(s[u],"--no-resize"),s[u].style.removeProperty("--_adjacent-shrink"),D(s[u],"--adjacent-pressed"))}else{for(let c=0;c<s.length;c++)(c==l-1||c==l+1)&&s[c].style.setProperty("--_adjacent-shrink","0px");Ce()?n(this,Rt,"m",Nc).call(this,s):this.addEventListener("transitionend",c=>{c.propertyName==="width"&&(this._adjacentPressedTimeout=setTimeout(()=>{this._adjacentPressedTimeout>-1&&n(this,Rt,"m",Nc).call(this,s)},600))},{once:!0})}}R(this,"--pressed",e),R(this,"--resting",!e)};Nc=function(e){for(let r of e)D(r,"--adjacent-pressed"),D(r,"--no-resize"),r.style.removeProperty("--_adjacent-shrink")};Qu=function(e){(this.disabled||this.disabledInteractive)&&(e.preventDefault(),e.stopImmediatePropagation()),this.toggle&&!e.defaultPrevented&&this.dispatchEvent(new Event("beforeinput",{bubbles:!0,cancelable:!0}))&&(this.selected=!this.selected,this.dispatchEvent(new Event("input",{bubbles:!0})),this.dispatchEvent(new Event("change",{bubbles:!0})))};Ku=function(e){this._base?.classList.toggle("with-selected-icon",he(e.target))};$e.styles=[ub,pb,mb];h([M(".base")],$e.prototype,"_base",void 0);h([M(".elevation")],$e.prototype,"_elevation",void 0);h([M(".focus-ring")],$e.prototype,"_focusRing",void 0);h([M(".state-layer")],$e.prototype,"_stateLayer",void 0);h([M(".ripple")],$e.prototype,"_ripple",void 0);h([b({reflect:!0})],$e.prototype,"variant",void 0);h([b({reflect:!0})],$e.prototype,"shape",void 0);h([b({reflect:!0})],$e.prototype,"size",void 0);h([b({reflect:!0})],$e.prototype,"width",void 0);h([b({type:Boolean,reflect:!0})],$e.prototype,"toggle",void 0);h([b({type:Boolean,reflect:!0})],$e.prototype,"selected",void 0);h([vt(40)],$e.prototype,"_handleResize",null);$e=h([L("m3e-icon-button")],$e);var pa={activeIndicatorSize:o("var(--m3e-loading-indicator-size, 2.375rem)"),activeIndicatorColor:o(`var(--m3e-loading-indicator-active-indicator-color, ${a.color.primary})`),containedActiveIndicatorColor:o(`var(--m3e-loading-indicator-contained-active-indicator-color, ${a.color.onPrimaryContainer})`),containedContainerColor:o(`var(--m3e-loading-indicator-contained-container-color, ${a.color.secondaryContainer})`),containerShape:o(`var(--m3e-loading-indicator-container-shape, ${a.shape.corner.full})`),containerSize:o("var(--m3e-loading-indicator-container-size, 3rem)")},em={"4-sided-cookie":"M230.389 50.473C293.109 23.2328 356.767 86.8908 329.527 149.611L325.023 159.981C316.707 179.13 316.707 200.87 325.023 220.019L329.527 230.389C356.767 293.109 293.109 356.767 230.389 329.527L220.019 325.023C200.87 316.707 179.13 316.707 159.981 325.023L149.611 329.527C86.8908 356.767 23.2328 293.109 50.473 230.389L54.9768 220.019C63.2934 200.87 63.2934 179.13 54.9768 159.981L50.473 149.611C23.2328 86.8908 86.8908 23.2328 149.611 50.473L159.981 54.9768C179.13 63.2934 200.87 63.2934 220.019 54.9768L230.389 50.473Z","9-sided-cookie":"M154.828 43.2756C156.574 41.8498 157.448 41.1369 158.245 40.535C177.03 26.3548 202.97 26.3548 221.755 40.535C222.552 41.1369 223.425 41.8498 225.172 43.2756C225.952 43.9121 226.342 44.2303 226.727 44.5333C235.567 51.4788 246.406 55.4147 257.652 55.7636C258.143 55.7788 258.647 55.785 259.654 55.7975C261.911 55.8255 263.039 55.8395 264.037 55.8898C287.563 57.0742 307.435 73.7107 312.689 96.6205C312.912 97.5928 313.121 98.6991 313.541 100.911C313.728 101.899 313.822 102.393 313.922 102.872C316.219 113.862 321.986 123.828 330.377 131.308C330.743 131.635 331.125 131.962 331.888 132.618C333.599 134.087 334.454 134.821 335.187 135.5C352.445 151.495 356.95 176.983 346.215 197.903C345.76 198.791 345.208 199.773 344.104 201.737C343.611 202.613 343.364 203.052 343.132 203.483C337.812 213.375 335.809 224.708 337.418 235.82C337.488 236.304 337.569 236.8 337.732 237.792C338.096 240.014 338.278 241.125 338.402 242.115C341.318 265.436 328.347 287.851 306.647 296.991C305.726 297.379 304.67 297.778 302.559 298.574C301.617 298.929 301.146 299.107 300.69 299.289C290.241 303.455 281.406 310.852 275.48 320.395C275.221 320.811 274.964 321.243 274.449 322.107C273.297 324.043 272.721 325.011 272.178 325.849C259.387 345.584 235.011 354.436 212.498 347.521C211.543 347.228 210.477 346.856 208.347 346.112C207.396 345.78 206.921 345.614 206.455 345.461C195.767 341.951 184.233 341.951 173.545 345.461C173.079 345.614 172.603 345.78 171.652 346.112C169.522 346.856 168.457 347.228 167.502 347.521C144.989 354.436 120.613 345.584 107.822 325.849C107.279 325.011 106.703 324.043 105.55 322.107C105.036 321.243 104.779 320.811 104.52 320.395C98.5939 310.852 89.7583 303.455 79.3096 299.289C78.8539 299.107 78.3827 298.929 77.4404 298.574C75.3294 297.778 74.274 297.379 73.3529 296.991C51.6523 287.851 38.6819 265.436 41.598 242.115C41.7218 241.125 41.9039 240.014 42.2682 237.792C42.4308 236.8 42.5121 236.304 42.5822 235.82C44.1908 224.708 42.188 213.375 36.8675 203.483C36.6354 203.052 36.389 202.613 35.8962 201.737C34.7921 199.773 34.2401 198.791 33.7845 197.903C23.0499 176.983 27.5544 151.495 44.8128 135.5C45.5454 134.821 46.4007 134.087 48.1113 132.618C48.875 131.962 49.2568 131.635 49.6228 131.308C58.0134 123.828 63.7804 113.862 66.0777 102.872C66.1779 102.393 66.2715 101.899 66.4588 100.911C66.8783 98.699 67.088 97.5928 67.311 96.6204C72.5652 73.7107 92.4369 57.0742 115.962 55.8898C116.961 55.8395 118.089 55.8255 120.346 55.7975C121.353 55.785 121.857 55.7788 122.347 55.7636C133.594 55.4147 144.432 51.4788 153.272 44.5333C153.658 44.2303 154.048 43.9121 154.828 43.2756Z",oval:"M271.309 271.309C201.705 340.913 108.877 360.935 63.9707 316.029C19.0648 271.123 39.0867 178.295 108.691 108.691C178.295 39.0867 271.123 19.0648 316.029 63.9707C360.935 108.877 340.913 201.705 271.309 271.309Z",pentagon:"M155.064 49.459C176.093 34.1803 204.569 34.1803 225.598 49.459L322.926 120.171C343.955 135.45 352.754 162.532 344.722 187.253L307.546 301.668C299.514 326.39 276.476 343.127 250.483 343.127H130.18C104.186 343.127 81.1489 326.39 73.1164 301.668L35.9407 187.253C27.9082 162.532 36.7077 135.45 57.737 120.171L155.064 49.459Z",pill:"M116.116 71.7851C169.162 18.7383 255.168 18.7383 308.215 71.7851C361.262 124.832 361.262 210.838 308.215 263.884L263.884 308.215C210.838 361.262 124.832 361.262 71.7851 308.215C18.7383 255.168 18.7383 169.162 71.7851 116.116L116.116 71.7851Z","soft-burst":"M175.147 33.1508C181.983 22.2831 198.017 22.2831 204.853 33.1508L221.238 59.2009C225.731 66.3458 234.797 69.2506 242.692 66.0751L271.475 54.4972C283.482 49.6671 296.455 58.9613 295.507 71.7154L293.235 102.288C292.612 110.673 298.215 118.278 306.494 120.284L336.681 127.601C349.275 130.653 354.23 145.692 345.861 155.461L325.8 178.877C320.298 185.3 320.298 194.7 325.8 201.123L345.861 224.539C354.23 234.308 349.275 249.347 336.681 252.399L306.494 259.716C298.215 261.722 292.612 269.327 293.235 277.712L295.507 308.285C296.455 321.039 283.482 330.333 271.475 325.503L242.692 313.925C234.797 310.749 225.731 313.654 221.238 320.799L204.853 346.849C198.017 357.717 181.983 357.717 175.147 346.849L158.762 320.799C154.269 313.654 145.203 310.749 137.308 313.925L108.525 325.503C96.5177 330.333 83.5454 321.039 84.4931 308.285L86.7649 277.712C87.388 269.327 81.785 261.722 73.5056 259.716L43.3186 252.399C30.7252 249.347 25.7702 234.308 34.1391 224.539L54.1997 201.123C59.7018 194.7 59.7018 185.3 54.1997 178.877L34.1391 155.461C25.7702 145.692 30.7252 130.653 43.3186 127.601L73.5056 120.284C81.785 118.278 87.388 110.673 86.7649 102.288L84.4931 71.7154C83.5454 58.9613 96.5177 49.6671 108.525 54.4972L137.308 66.0751C145.203 69.2506 154.269 66.3458 158.762 59.201L175.147 33.1508Z",sunny:"M276.453 68.8118C286.405 69.4881 291.381 69.8263 295.404 71.5853C301.223 74.1305 305.87 78.7766 308.415 84.5965C310.174 88.6186 310.512 93.5948 311.188 103.547L312.732 126.259C313.005 130.284 313.142 132.296 313.579 134.219C314.212 136.997 315.31 139.648 316.827 142.059C317.877 143.728 319.203 145.248 321.856 148.288L336.824 165.438C343.384 172.954 346.663 176.712 348.263 180.8C350.579 186.715 350.579 193.285 348.263 199.2C346.663 203.288 343.384 207.046 336.824 214.562L321.856 231.712C319.203 234.752 317.877 236.272 316.827 237.941C315.31 240.352 314.212 243.003 313.579 245.781C313.142 247.704 313.005 249.716 312.732 253.741L311.188 276.453C310.512 286.405 310.174 291.381 308.415 295.404C305.87 301.223 301.223 305.87 295.404 308.415C291.381 310.174 286.405 310.512 276.453 311.188L253.741 312.732C249.716 313.005 247.704 313.142 245.781 313.579C243.003 314.212 240.352 315.31 237.941 316.827C236.272 317.877 234.752 319.203 231.712 321.856L214.562 336.824C207.046 343.384 203.288 346.663 199.2 348.263C193.285 350.579 186.715 350.579 180.8 348.263C176.712 346.663 172.954 343.384 165.438 336.824L148.288 321.856C145.248 319.203 143.728 317.877 142.059 316.827C139.648 315.31 136.997 314.212 134.219 313.579C132.296 313.142 130.284 313.005 126.259 312.732L103.547 311.188C93.5947 310.512 88.6186 310.174 84.5965 308.415C78.7766 305.87 74.1305 301.223 71.5853 295.404C69.8263 291.381 69.4881 286.405 68.8118 276.453L67.2684 253.741C66.9949 249.716 66.8581 247.704 66.4206 245.781C65.7883 243.003 64.6903 240.352 63.173 237.941C62.123 236.272 60.7965 234.752 58.1437 231.712L43.1756 214.562C36.6164 207.046 33.3369 203.288 31.7366 199.2C29.4211 193.285 29.4211 186.715 31.7366 180.8C33.3369 176.712 36.6164 172.954 43.1756 165.438L58.1437 148.288C60.7965 145.248 62.123 143.728 63.173 142.059C64.6903 139.648 65.7883 136.997 66.4206 134.219C66.8581 132.296 66.9949 130.284 67.2684 126.259L68.8118 103.547C69.4881 93.5948 69.8263 88.6186 71.5853 84.5965C74.1305 78.7766 78.7766 74.1305 84.5965 71.5853C88.6186 69.8263 93.5948 69.4881 103.547 68.8118L126.259 67.2684C130.284 66.9949 132.296 66.8581 134.219 66.4206C136.997 65.7883 139.648 64.6903 142.059 63.173C143.728 62.123 145.248 60.7966 148.288 58.1437L165.438 43.1756C172.954 36.6164 176.712 33.3369 180.8 31.7366C186.715 29.4211 193.285 29.4211 199.2 31.7366C203.288 33.3369 207.046 36.6164 214.562 43.1756L231.712 58.1437C234.752 60.7966 236.272 62.123 237.941 63.173C240.352 64.6903 243.003 65.7883 245.781 66.4206C247.704 66.8581 249.716 66.9949 253.741 67.2684L276.453 68.8118Z"},gn=new Array,tm=new Map;for(let t in em)gn.push(em[t]),tm.set(t,gn.length-1);var om={};gn=dh(gn,300);for(let t of tm)om[t[0]]=o(gn[t[1]]);var fa=om,yn=class extends uo(W(P,"progressbar")){constructor(){super(...arguments),this.variant="uncontained"}connectedCallback(){super.connectedCallback(),this.ariaValueMin=this.ariaValueMin||"0",this.ariaValueMax=this.ariaValueMax||"100"}disconnectedCallback(){super.disconnectedCallback(),this._container?.classList.toggle("animate",!1)}reconnectedCallback(){super.reconnectedCallback(),this._container?.classList.toggle("animate",!0)}firstUpdated(e){super.firstUpdated(e),this._container?.classList.toggle("animate",!0)}render(){return w`<div class="container" aria-hidden="true"><div class="active-indicator-wrapper"><div class="active-indicator"></div></div></div>`}};yn.styles=C`:host { display: inline-block; aspect-ratio: 1 / 1; contain: strict; vertical-align: middle; content-visibility: auto; } :host([variant="uncontained"]) { width: ${pa.activeIndicatorSize}; } :host([variant="contained"]) { width: ${pa.containerSize}; } :host([variant="uncontained"]) .active-indicator { background-color: ${pa.activeIndicatorColor}; } :host([variant="contained"]) .active-indicator { background-color: ${pa.containedActiveIndicatorColor}; } :host([variant="contained"]) .container { background-color: ${pa.containedContainerColor}; } .container { width: 100%; height: 100%; display: flex; align-items: center; justify-content: center; border-radius: ${pa.containerShape}; } .active-indicator { margin: auto; aspect-ratio: 1 / 1; width: calc(${pa.activeIndicatorSize} * 0.842); transform-origin: center; transition: clip-path ${a.motion.spring.slowEffects}; will-change: transform, clip-path; --_polygon-soft-burst: polygon(${fa["soft-burst"]}); --_polygon-9-sided-cookie: polygon(${fa["9-sided-cookie"]}); --_polygon-pentagon: polygon(${fa.pentagon}); --_polygon-pill: polygon(${fa.pill}); --_polygon-sunny: polygon(${fa.sunny}); --_polygon-4-sided-cookie: polygon(${fa["4-sided-cookie"]}); --_polygon-oval: polygon(${fa.oval}); } .container.animate .active-indicator-wrapper { animation: rotate-outer 4666ms linear infinite; transform-origin: center; display: flex; align-items: center; justify-content: center; will-change: transform; } @keyframes rotate-outer { 0% { transform: rotate(0deg); } 100% { transform: rotate(360deg); } } .container.animate .active-indicator { animation: rotate-inner 4666ms cubic-bezier(0.34, 0.88, 0.34, 1) infinite; } @keyframes rotate-inner { 0% { clip-path: var(--_polygon-soft-burst); transform: rotate(0deg); } 14% { clip-path: var(--_polygon-9-sided-cookie); transform: rotate(154deg) scale(1); } 29% { clip-path: var(--_polygon-pentagon); transform: rotate(309deg) scale(1); } 43% { clip-path: var(--_polygon-pill); transform: rotate(463deg) scale(1); } 57% { clip-path: var(--_polygon-sunny); transform: rotate(617deg) scale(1); } 71% { clip-path: var(--_polygon-4-sided-cookie); transform: rotate(771deg) scale(1); } 83% { clip-path: var(--_polygon-oval); transform: rotate(926deg) scale(1); } 100% { clip-path: var(--_polygon-soft-burst); transform: rotate(1080deg) scale(1); } } @media (forced-colors: active) { .active-indicator { background-color: CanvasText !important; } }`;h([M(".container")],yn.prototype,"_container",void 0);h([b({reflect:!0})],yn.prototype,"variant",void 0);yn=h([L("m3e-loading-indicator")],yn);var xo,xn,qc,am,rm,Vc,wo=class extends W(P,"group"){constructor(){super(...arguments),xo.add(this),xn.set(this,new fe(this,{target:null,capture:!0,minPressedDuration:150,isPressedKey:e=>e===" ",callback:e=>n(this,xo,"m",rm).call(this,e)})),this.variant="standard",this.size="small",this.multi=!1}connectedCallback(){super.connectedCallback(),this.hasAttribute("disable-role")&&(this.role=null)}disconnectedCallback(){super.disconnectedCallback(),this._base?.style.removeProperty("--_button-group-width"),this._base?.classList.remove("pressed")}update(e){super.update(e),(e.has("multi")||e.has("variant"))&&n(this,xo,"m",qc).call(this),e.has("variant")&&this._base?.style.removeProperty("--_button-group-width")}render(){return w`<div class="base"><slot @slotchange="${n(this,xo,"m",qc)}" @change="${n(this,xo,"m",am)}"></slot></div>`}};xn=new WeakMap;xo=new WeakSet;qc=async function(){let e=this.buttons;for(let s of n(this,xn,"f").targets)n(this,xn,"f").unobserve(s);for(let s of this.buttons)await uh(s),s.isUpdatePending&&await s.updateComplete;let r=[...e].some(s=>s.toggle);this.hasAttribute("disable-role")||(this.role=r&&!this.multi?"radiogroup":"group");let i=this.role==="radiogroup"?"radio":"button";e.forEach((s,l)=>{if(n(this,xn,"f").observe(s),R(s,"--connected",this.variant==="connected"),ae(s,"--grouped"),R(s,"--first",l==0),R(s,"--last",l==e.length-1),!this.hasAttribute("disable-role")&&s.role!==i&&s.toggle){let c=s.toggle?s.selected?"true":"false":null;s.role=i,s.role==="button"?(s.ariaPressed=c,s.ariaChecked=null):(s.ariaChecked=c,s.ariaPressed=null)}})};am=function(e){if(!(this.multi||!(e.target instanceof HTMLElement))&&(e.target.tagName==="M3E-BUTTON"||e.target.tagName==="M3E-ICON-BUTTON")){if(!kl(e.target)||!e.target.selected)return;for(let r of this.buttons)r===e.target||!r.selected||(r.selected=!1)}};rm=function(e){let r=this._base;if(r)if(!e||this.variant==="connected"){let i=this.buttons.find(s=>s===document.activeElement);!Ce()&&i?i.addEventListener("transitionend",()=>queueMicrotask(()=>{ie(i,"--pressed")||n(this,xo,"m",Vc).call(this,r)}),{once:!0}):n(this,xo,"m",Vc).call(this,r)}else r.classList.add("pressed"),r.style.setProperty("--_button-group-width",`${r.getBoundingClientRect().width}px`)};Vc=function(e){e.style.removeProperty("--_button-group-width"),e.classList.remove("pressed")};wo.styles=C`:host { display: flex; vertical-align: middle; flex-wrap: nowrap; align-items: center; } .base { display: flex; vertical-align: middle; flex-wrap: nowrap; align-items: center; } :host([variant="standard"]) { justify-content: center; } :host([variant="connected"]) .base { flex: 1 1 auto; } :host([variant="standard"]) .base { width: fit-content; flex: none; } :host([variant="standard"]) .base.pressed { justify-content: space-between; width: var(--_button-group-width); } :host([variant="standard"][size="extra-small"]) .base { column-gap: var(--m3e-standard-button-group-extra-small-spacing, 1.125rem); } :host([variant="standard"][size="small"]) .base { column-gap: var(--m3e-standard-button-group-small-spacing, 0.75rem); } :host([variant="standard"][size="medium"]).base { column-gap: var(--m3e-standard-button-group-medium-spacing, 0.5rem); } :host([variant="standard"][size="large"]) .base { column-gap: var(--m3e-standard-button-group-large-spacing, 0.5rem); } :host([variant="standard"][size="extra-large"]) .base { column-gap: var(--m3e-standard-button-group-extra-large-spacing, 0.5rem); } :host([variant="connected"]) .base { column-gap: var(--m3e-connected-button-group-spacing, 0.125rem); } :host([variant="connected"][size="extra-small"]) ::slotted(:is(:state(--first), :--first)[size="extra-small"]), :host([variant="connected"][size="extra-small"]) ::slotted(:not(:is(:state(--first), :--first)):not(:is(:state(--last), :--last))[size="extra-small"]) { --_button-rounded-end-shape: var( --m3e-connected-button-group-extra-small-inner-shape, ${a.shape.corner.small} ); --_button-square-end-shape: var( --m3e-connected-button-group-extra-small-inner-shape, ${a.shape.corner.small} ); --_button-square-end-pressed-shape: var( --m3e-connected-button-group-extra-small-inner-pressed-shape, ${a.shape.corner.extraSmall} ); } :host([variant="connected"][size="extra-small"]) ::slotted(:is(:state(--last), :--last)[size="extra-small"]), :host([variant="connected"][size="extra-small"]) ::slotted(:not(:is(:state(--first), :--first)):not(:is(:state(--last), :--last))[size="extra-small"]) { --_button-rounded-start-shape: var( --m3e-connected-button-group-extra-small-inner-shape, ${a.shape.corner.small} ); --_button-square-start-shape: var( --m3e-connected-button-group-extra-small-inner-shape, ${a.shape.corner.small} ); --_button-square-start-pressed-shape: var( --m3e-connected-button-group-extra-small-inner-pressed-shape, ${a.shape.corner.extraSmall} ); } :host([variant="connected"][size="small"]) ::slotted(:is(:state(--first), :--first)[size="small"]), :host([variant="connected"][size="small"]) ::slotted(:not(:is(:state(--first), :--first)):not(:is(:state(--last), :--last))[size="small"]) { --_button-rounded-end-shape: var( --m3e-connected-button-group-small-inner-shape, ${a.shape.corner.small} ); --_button-square-end-shape: var( --m3e-connected-button-group-small-inner-shape, ${a.shape.corner.small} ); --_button-end-shape-pressed-morph: var( --m3e-connected-button-group-small-inner-pressed-shape, ${a.shape.corner.extraSmall} ); } :host([variant="connected"][size="small"]) ::slotted(:is(:state(--last), :--last)[size="small"]), :host([variant="connected"][size="small"]) ::slotted(:not(:is(:state(--first), :--first)):not(:is(:state(--last), :--last))[size="small"]) { --_button-rounded-start-shape: var( --m3e-connected-button-group-small-inner-shape, ${a.shape.corner.small} ); --_button-square-start-shape: var( --m3e-connected-button-group-small-inner-shape, ${a.shape.corner.small} ); --_button-start-shape-pressed-morph: var( --m3e-connected-button-group-small-inner-pressed-shape, ${a.shape.corner.extraSmall} ); } :host([variant="connected"][size="medium"]) ::slotted(:is(:state(--first), :--first)[size="medium"]), :host([variant="connected"][size="medium"]) ::slotted(:not(:is(:state(--first), :--first)):not(:is(:state(--last), :--last))[size="medium"]) { --_button-rounded-end-shape: var( --m3e-connected-button-group-medium-inner-shape, ${a.shape.corner.small} ); --_button-square-end-shape: var( --m3e-connected-button-group-medium-inner-shape, ${a.shape.corner.small} ); --_button-square-end-pressed-shape: var( --m3e-connected-button-group-medium-inner-pressed-shape, ${a.shape.corner.extraSmall} ); } :host([variant="connected"][size="medium"]) ::slotted(:is(:state(--last), :--last)[size="medium"]), :host([variant="connected"][size="medium"]) ::slotted(:not(:is(:state(--first), :--first)):not(:is(:state(--last), :--last))[size="medium"]) { --_button-rounded-start-shape: var( --m3e-connected-button-group-medium-inner-shape, ${a.shape.corner.small} ); --_button-square-start-shape: var( --m3e-connected-button-group-medium-inner-shape, ${a.shape.corner.small} ); --_button-square-start-pressed-shape: var( --m3e-connected-button-group-medium-inner-pressed-shape, ${a.shape.corner.extraSmall} ); } :host([variant="connected"][size="large"]) ::slotted(:is(:state(--first), :--first)[size="large"]), :host([variant="connected"][size="large"]) ::slotted(:not(:is(:state(--first), :--first)):not(:is(:state(--last), :--last))[size="large"]) { --_button-rounded-end-shape: var( --m3e-connected-button-group-large-inner-shape, ${a.shape.corner.large} ); --_button-square-end-shape: var( --m3e-connected-button-group-large-inner-shape, ${a.shape.corner.large} ); --_button-square-end-pressed-shape: var( --m3e-connected-button-group-large-inner-pressed-shape, ${a.shape.corner.medium} ); } :host([variant="connected"][size="large"]) ::slotted(:is(:state(--last), :--last)[size="large"]), :host([variant="connected"][size="large"]) ::slotted(:not(:is(:state(--first), :--first)):not(:is(:state(--last), :--last))[size="large"]) { --_button-rounded-start-shape: var( --m3e-connected-button-group-large-inner-shape, ${a.shape.corner.large} ); --_button-square-start-shape: var( --m3e-connected-button-group-large-inner-shape, ${a.shape.corner.large} ); --_button-square-start-pressed-shape: var( --m3e-connected-button-group-large-inner-pressed-shape, ${a.shape.corner.medium} ); } :host([variant="connected"][size="extra-large"]) ::slotted(:is(:state(--first), :--first)[size="extra-large"]), :host([variant="connected"][size="extra-large"]) ::slotted(:not(:is(:state(--first), :--first)):not(:is(:state(--last), :--last))[size="extra-large"]) { --_button-rounded-end-shape: var( --m3e-connected-button-group-extra-large-inner-shape, ${a.shape.corner.largeIncreased} ); --_button-square-end-shape: var( --m3e-connected-button-group-extra-large-inner-shape, ${a.shape.corner.largeIncreased} ); --_button-square-end-pressed-shape: var( --m3e-connected-button-group-extra-large-inner-pressed-shape, ${a.shape.corner.large} ); } :host([variant="connected"][size="extra-large"]) ::slotted(:is(:state(--last), :--last)[size="extra-large"]), :host([variant="connected"][size="extra-large"]) ::slotted(:not(:is(:state(--first), :--first)):not(:is(:state(--last), :--last))[size="extra-large"]) { --_button-rounded-start-shape: var( --m3e-connected-button-group-extra-large-inner-shape, ${a.shape.corner.largeIncreased} ); --_button-square-start-shape: var( --m3e-connected-button-group-extra-large-inner-shape, ${a.shape.corner.largeIncreased} ); --_button-square-start-pressed-shape: var( --m3e-connected-button-group-extra-large-inner-pressed-shape, ${a.shape.corner.large} ); }`;h([M(".base")],wo.prototype,"_base",void 0);h([b({reflect:!0})],wo.prototype,"variant",void 0);h([b({reflect:!0})],wo.prototype,"size",void 0);h([b({type:Boolean})],wo.prototype,"multi",void 0);h([yd({slot:"",selector:"m3e-button,m3e-icon-button",flatten:!0})],wo.prototype,"buttons",void 0);wo=h([L("m3e-button-group")],wo);var ct,qe,pe,Ls,Ja,Ts,nm,im,Ps,sm,Uc,jc,Qa=class extends W(P,"group"){constructor(){super(...arguments),ct.add(this),qe.set(this,void 0),pe.set(this,void 0),Ls.set(this,!1),Ja.set(this,new fe(this,{target:null,capture:!0,minPressedDuration:150,isPressedKey:e=>e===" ",callback:(e,r,i)=>{switch(i){case n(this,qe,"f"):n(this,ct,"m",sm).call(this,e);break;case n(this,pe,"f"):n(this,ct,"m",Uc).call(this,e||n(this,Ls,"f"));break}}})),Ts.set(this,new Vt(this,{target:null,callback:(e,r)=>{switch(r){case n(this,pe,"f"):!n(this,pe,"f")?.disabled&&!n(this,pe,"f")?.disabledInteractive&&(f(this,Ls,e,"f"),n(this,ct,"m",Uc).call(this,e));break}}})),this.variant="filled",this.size="small"}update(e){super.update(e),e.has("variant")&&n(this,ct,"m",Ps).call(this)}render(){return w`<m3e-button-group class="base" disable-role variant="connected" size="${this.size}"><slot name="leading-button" @slotchange="${n(this,ct,"m",nm)}"></slot><slot name="trailing-button" @slotchange="${n(this,ct,"m",im)}"></slot></m3e-button-group>`}};qe=new WeakMap;pe=new WeakMap;Ls=new WeakMap;Ja=new WeakMap;Ts=new WeakMap;ct=new WeakSet;nm=function(e){n(this,qe,"f")&&n(this,Ja,"f").unobserve(n(this,qe,"f")),f(this,qe,e.target.assignedElements({flatten:!0}).find(r=>r instanceof Se),"f"),n(this,qe,"f")&&n(this,Ja,"f").observe(n(this,qe,"f")),n(this,ct,"m",Ps).call(this)};im=function(e){n(this,pe,"f")&&(n(this,Ja,"f").unobserve(n(this,pe,"f")),n(this,Ts,"f").unobserve(n(this,pe,"f"))),f(this,pe,e.target.assignedElements({flatten:!0}).find(r=>r instanceof $e),"f"),n(this,pe,"f")&&(n(this,Ja,"f").observe(n(this,pe,"f")),n(this,Ts,"f").observe(n(this,pe,"f"))),n(this,ct,"m",Ps).call(this)};Ps=function(){n(this,qe,"f")&&(n(this,qe,"f").variant=this.variant,n(this,qe,"f").size=this.size,n(this,qe,"f").shape="rounded"),n(this,pe,"f")&&(n(this,pe,"f").width="default",n(this,pe,"f").shape="rounded",n(this,pe,"f").setAttribute("variant",this.variant),n(this,pe,"f").size=this.size)};sm=function(e){e&&n(this,qe,"f")?n(this,ct,"m",jc).call(this,n(this,qe,"f"),"--_leading-button-shape"):this._base?.style.removeProperty("--_leading-button-shape")};Uc=function(e){e&&n(this,pe,"f")?n(this,ct,"m",jc).call(this,n(this,pe,"f"),"--_trailing-button-shape"):this._base?.style.removeProperty("--_trailing-button-shape")};jc=function(e,r){let i=e.clientHeight/2;i&&this._base?.style.setProperty(r,`${i}px`)};Qa.styles=C`:host { display: inline-flex; vertical-align: middle; } ::slotted([slot="leading-button"]) { flex: 1 1 auto; min-width: 0; --_button-start-shape-pressed-morph: var(--_leading-button-shape, ${a.shape.corner.full}); } ::slotted([slot="trailing-button"]:not([aria-expanded="true"])) { --m3e-icon-button-extra-small-default-leading-space: var( --m3e-split-button-extra-small-trailing-button-unselected-leading-space, 0.75rem ); --m3e-icon-button-extra-small-default-trailing-space: var( --m3e-split-button-extra-small-trailing-button-unselected-trailing-space, 0.875rem ); --m3e-icon-button-small-default-leading-space: var( --m3e-split-button-small-trailing-button-unselected-leading-space, 0.75rem ); --m3e-icon-button-small-default-trailing-space: var( --m3e-split-button-small-trailing-button-unselected-trailing-space, 0.875rem ); --m3e-icon-button-medium-default-leading-space: var( --m3e-split-button-medium-trailing-button-unselected-leading-space, 0.8125rem ); --m3e-icon-button-medium-default-trailing-space: var( --m3e-split-button-medium-trailing-button-unselected-trailing-space, 1.0625rem ); --m3e-icon-button-large-default-leading-space: var( --m3e-split-button-large-trailing-button-unselected-leading-space, 1.625rem ); --m3e-icon-button-large-default-trailing-space: var( --m3e-split-button-large-trailing-button-unselected-trailing-space, 2rem ); --m3e-icon-button-extra-large-default-leading-space: var( --m3e-split-button-extra-large-trailing-button-unselected-leading-space, 2.3125rem ); --m3e-icon-button-extra-large-default-trailing-space: var( --m3e-split-button-extra-large-trailing-button-unselected-trailing-space, 3.0625rem ); } ::slotted([slot="trailing-button"][aria-expanded="true"]) { --m3e-icon-button-extra-small-default-leading-space: var( --m3e-split-button-extra-small-trailing-button-selected-leading-space, 0.8125rem ); --m3e-icon-button-extra-small-default-trailing-space: var( --m3e-split-button-extra-small-trailing-button-selected-trailing-space, 0.8125rem ); --m3e-icon-button-small-default-leading-space: var( --m3e-split-button-small-trailing-button-selected-leading-space, 0.8125rem ); --m3e-icon-button-small-default-trailing-space: var( --m3e-split-button-small-trailing-button-selected-trailing-space, 0.8125rem ); --m3e-icon-button-medium-default-leading-space: var( --m3e-split-button-medium-trailing-button-selected-leading-space, 0.9375rem ); --m3e-icon-button-medium-default-trailing-space: var( --m3e-split-button-medium-trailing-button-selected-trailing-space, 0.9375rem ); --m3e-icon-button-large-default-leading-space: var( --m3e-split-button-large-trailing-button-selected-leading-space, 1.8125rem ); --m3e-icon-button-large-default-trailing-space: var( --m3e-split-button-large-trailing-button-selected-trailing-space, 1.8125rem ); --m3e-icon-button-extra-large-default-leading-space: var( --m3e-split-button-extra-large-trailing-button-selected-leading-space, 2.6875rem ); --m3e-icon-button-extra-large-default-trailing-space: var( --m3e-split-button-extra-large-trailing-button-selected-trailing-space, 2.6875rem ); } ::slotted([slot="leading-button"]:not(:hover)), ::slotted([slot="leading-button"]:disabled), ::slotted([slot="leading-button"][disabled-interactive]) { --m3e-connected-button-group-extra-small-inner-shape: var( --m3e-split-button-extra-small-inner-corner-size, ${a.shape.corner.extraSmall} ); --m3e-connected-button-group-small-inner-shape: var( --m3e-split-button-small-inner-corner-size, ${a.shape.corner.extraSmall} ); --m3e-connected-button-group-medium-inner-shape: var( --m3e-split-button-medium-inner-corner-size, ${a.shape.corner.extraSmall} ); --m3e-connected-button-group-large-inner-shape: var( --m3e-split-button-large-inner-corner-size, ${a.shape.corner.small} ); --m3e-connected-button-group-extra-large-inner-shape: var( --m3e-split-button-extra-large-inner-corner-size, ${a.shape.corner.medium} ); } ::slotted([slot="leading-button"]:hover:not(:disabled):not([disabled-interactive])), ::slotted([slot="trailing-button"]:not([aria-expanded="true"]):hover:not(:disabled):not([disabled-interactive])) { --m3e-connected-button-group-extra-small-inner-shape: var( --m3e-split-button-extra-small-inner-corner-hover-size, ${a.shape.corner.small} ); --m3e-connected-button-group-small-inner-shape: var( --m3e-split-button-small-inner-corner-hover-size, ${a.shape.corner.medium} ); --m3e-connected-button-group-medium-inner-shape: var( --m3e-split-button-medium-inner-corner-hover-size, ${a.shape.corner.medium} ); --m3e-connected-button-group-large-inner-shape: var( --m3e-split-button-large-inner-corner-hover-size, ${a.shape.corner.largeIncreased} ); --m3e-connected-button-group-extra-large-inner-shape: var( --m3e-split-button-extra-large-inner-corner-hover-size, ${a.shape.corner.largeIncreased} ); } ::slotted([slot="leading-button"]), ::slotted([slot="trailing-button"]) { --m3e-connected-button-group-extra-small-inner-pressed-shape: var( --m3e-split-button-extra-small-inner-corner-pressed-size, ${a.shape.corner.small} ); --m3e-connected-button-group-small-inner-pressed-shape: var( --m3e-split-button-small-inner-corner-pressed-size, ${a.shape.corner.medium} ); --m3e-connected-button-group-medium-inner-pressed-shape: var( --m3e-split-button-medium-inner-corner-pressed-size, ${a.shape.corner.medium} ); --m3e-connected-button-group-large-inner-pressed-shape: var( --m3e-split-button-large-inner-corner-pressed-size, ${a.shape.corner.largeIncreased} ); --m3e-connected-button-group-extra-large-inner-pressed-shape: var( --m3e-split-button-extra-large-inner-corner-pressed-size, ${a.shape.corner.largeIncreased} ); } ::slotted([slot="trailing-button"]:not([aria-expanded="true"]):not(:hover)), ::slotted([slot="trailing-button"]:disabled), ::slotted([slot="trailing-button"][disabled-interactive]) { --m3e-connected-button-group-extra-small-inner-shape: var( --m3e-split-button-extra-small-inner-corner-size, ${a.shape.corner.extraSmall} ); --m3e-connected-button-group-small-inner-shape: var( --m3e-split-button-small-inner-corner-size, ${a.shape.corner.extraSmall} ); --m3e-connected-button-group-medium-inner-shape: var( --m3e-split-button-medium-inner-corner-size, ${a.shape.corner.extraSmall} ); --m3e-connected-button-group-large-inner-shape: var( --m3e-split-button-large-inner-corner-size, ${a.shape.corner.small} ); --m3e-connected-button-group-extra-large-inner-shape: var( --m3e-split-button-extra-large-inner-corner-size, ${a.shape.corner.medium} ); } ::slotted([slot="trailing-button"][aria-expanded="true"]) { --_icon-button-icon-transform: rotate(180deg); --_button-rounded-start-shape: var(--_trailing-button-shape, ${a.shape.corner.full}); --_button-rounded-end-shape: var(--_trailing-button-shape, ${a.shape.corner.full}); } ::slotted([slot="trailing-button"]) { --_button-end-shape-pressed-morph: var(--_trailing-button-shape, ${a.shape.corner.full}); } .base { --m3e-icon-button-extra-small-icon-size: var(--m3e-spit-button-extra-small-trailing-button-icon-size, 1.375rem); --m3e-button-extra-small-icon-size: var(--m3e-spit-button-extra-small-trailing-button-icon-size, 1.375rem); --m3e-icon-button-small-icon-size: var(--m3e-spit-button-small-trailing-button-icon-size, 1.375rem); --m3e-button-small-icon-size: var(--m3e-spit-button-small-trailing-button-icon-size, 1.375rem); --m3e-icon-button-medium-icon-size: var(--m3e-spit-button-medium-trailing-button-icon-size, 1.625rem); --m3e-button-medium-icon-size: var(--m3e-spit-button-medium-trailing-button-icon-size, 1.625rem); --m3e-icon-button-large-icon-size: var(--m3e-spit-button-large-trailing-button-icon-size, 2.375rem); --m3e-button-large-icon-size: var(--m3e-spit-button-large-trailing-button-icon-size, 2.375rem); --m3e-icon-button-extra-large-icon-size: var(--m3e-spit-button-extra-large-trailing-button-icon-size, 3.125rem); --m3e-button-extra-large-icon-size: var(--m3e-spit-button-extra-large-trailing-button-icon-size, 3.125rem); } :host([size="extra-small"]) .base { --m3e-connected-button-group-spacing: var(--m3e-split-button-extra-small-between-spacing, 0.125rem); } :host([size="small"]) .base { --m3e-connected-button-group-spacing: var(--m3e-split-button-small-between-spacing, 0.125rem); } :host([size="medium"]).base { --m3e-connected-button-group-spacing: var(--m3e-split-button-medium-between-spacing, 0.125rem); } :host([size="large"]) .base { --m3e-connected-button-group-spacing: var(--m3e-split-button-large-between-spacing, 0.125rem); } :host([size="extra-large"]) .base { --m3e-connected-button-group-spacing: var(--m3e-split-button-extra-large-between-spacing, 0.125rem); }`;h([M(".base")],Qa.prototype,"_base",void 0);h([b({reflect:!0})],Qa.prototype,"variant",void 0);h([b({reflect:!0})],Qa.prototype,"size",void 0);Qa=h([L("m3e-split-button")],Qa);var As,Is,zs,lm,cm,tt=class extends uo(P){constructor(){super(...arguments),As.add(this),Is.set(this,void 0),zs.set(this,new we(this,{target:null,callback:()=>this._updatePaging()})),this._canPage=!1,this._canPageStart=!1,this._canPageEnd=!1,this.disabled=!1,this.vertical=!1,this.threshold=0,this.previousPageLabel="Previous page",this.nextPageLabel="Next page"}connectedCallback(){super.connectedCallback(),f(this,Is,G.observe(()=>this.requestUpdate()),"f")}disconnectedCallback(){super.disconnectedCallback(),n(this,Is,"f")?.call(this)}reconnectedCallback(){super.reconnectedCallback(),n(this,zs,"f").observe(this.scrollContainer)}firstUpdated(e){super.firstUpdated(e),n(this,zs,"f").observe(this.scrollContainer)}render(){let e=w`<m3e-icon-button class="prev-button" tabindex="-1" aria-label="${this.previousPageLabel}" ?disabled="${!this._canPageStart}" @click="${n(this,As,"m",lm)}"><slot name="prev-icon">${G.current==="ltr"||this.vertical?w`<svg class="icon" viewBox="0 -960 960 960" fill="currentColor"><path d="M640-80 240-480l400-400 71 71-329 329 329 329-71 71Z"/></svg>`:w`<svg class="icon" viewBox="0 -960 960 960" fill="currentColor"><path d="m321-80-71-71 329-329-329-329 71-71 400 400L321-80Z"/></svg>`}</slot></m3e-icon-button>`,r=w`<m3e-icon-button class="next-button" tabindex="-1" aria-label="${this.nextPageLabel}" ?disabled="${!this._canPageEnd}" @click="${n(this,As,"m",cm)}"><slot name="next-icon">${G.current==="ltr"||this.vertical?w`<svg class="icon" viewBox="0 -960 960 960" fill="currentColor"><path d="m321-80-71-71 329-329-329-329 71-71 400 400L321-80Z"/></svg>`:w`<svg class="icon" viewBox="0 -960 960 960" fill="currentColor"><path d="M640-80 240-480l400-400 71 71-329 329 329 329-71 71Z"/></svg>`}</slot></m3e-icon-button>`;return w`${this._canPage?e:F}<div class="content" @scroll="${this._updatePaging}"><slot></slot></div>${this._canPage?r:F}`}_updatePaging(){let e=this._canPage;this.disabled?this._canPage=!1:this.vertical?(this._canPage=Math.round(this.scrollContainer.scrollHeight)>Math.round(this.scrollContainer.clientHeight)+this.threshold,this._canPage&&(this._canPageStart=Math.round(this.scrollContainer.scrollTop)>this.threshold,this._canPageEnd=Math.round(this.scrollContainer.scrollTop)+ +this.threshold<Math.round(this.scrollContainer.scrollHeight-this.scrollContainer.clientHeight))):(this._canPage=Math.round(this.scrollContainer.scrollWidth)>Math.round(this.scrollContainer.clientWidth)+this.threshold,this._canPage&&(this._canPageStart=Math.round(this.scrollContainer.scrollLeft)>this.threshold,this._canPageEnd=Math.round(this.scrollContainer.scrollLeft)+this.threshold<Math.round(this.scrollContainer.scrollWidth-this.scrollContainer.clientWidth))),this._canPage||(this._canPageStart=this._canPageEnd=!1),e!=this._canPage&&this.dispatchEvent(new CustomEvent("pagination-changed"))}};Is=new WeakMap;zs=new WeakMap;As=new WeakSet;lm=function(){if(this.vertical){let e=this.scrollContainer.scrollTop-this.scrollContainer.clientHeight;e<=this.threshold&&(e=0),this.scrollContainer.scrollTo({top:e,behavior:"smooth"})}else{let e=this.scrollContainer.scrollLeft-this.scrollContainer.clientWidth;e<=this.threshold&&(e=0),this.scrollContainer.scrollTo({left:e,behavior:"smooth"})}};cm=function(){if(this.vertical){let e=this.scrollContainer.scrollTop+this.scrollContainer.clientHeight;e>=this.scrollContainer.scrollHeight-this.scrollContainer.clientHeight-this.threshold&&(e=this.scrollContainer.scrollHeight-this.scrollContainer.clientHeight),this.scrollContainer.scrollTo({top:e,behavior:"smooth"})}else{let e=this.scrollContainer.scrollLeft+this.scrollContainer.clientWidth;e>=this.scrollContainer.scrollWidth-this.scrollContainer.clientWidth-this.threshold&&(e=this.scrollContainer.scrollWidth-this.scrollContainer.clientWidth),this.scrollContainer.scrollTo({left:e,behavior:"smooth"})}};tt.styles=C`:host { display: flex; flex-wrap: nowrap; } :host([vertical]) { flex-direction: column; } .prev-button, .next-button { flex: none; --m3e-icon-button-small-shape-round: 0px; --m3e-icon-button-small-shape-square: 0px; --m3e-icon-button-small-shape-pressed-morph: 0px; --m3e-focus-ring-visibility: hidden; } ::slotted(prev-icon), ::slotted(next-icon), .icon { width: 1em; font-size: var(--m3e-slide-group-button-icon-size, var(--m3e-icon-button-small-icon-size, 1.5rem)) !important; } :host(:not([vertical])) .prev-button, :host(:not([vertical])) .next-button { --m3e-icon-button-small-container-height: 100%; width: var(--m3e-slide-group-button-size, 2.5rem); } :host([vertical]) .prev-button, :host([vertical]) .next-button { width: unset; --m3e-icon-button-small-container-height: var(--m3e-slide-group-button-size, 2.5rem); } :host([vertical]) .prev-button .icon, :host([vertical]) .next-button .icon { transform: rotate(90deg); } .content { contain: layout style; flex: 1 1 auto; display: inherit; flex-wrap: inherit; flex-direction: inherit; position: relative; border-top: var(--m3e-slide-group-divider-top); border-bottom: var(--m3e-slide-group-divider-bottom); scrollbar-width: none; } .content::-webkit-scrollbar { display: none; } :host([vertical]) .content { overflow-x: hidden; overflow-y: auto; } :host(:not([vertical])) .content { overflow-x: auto; overflow-y: hidden; }`;h([M(".content")],tt.prototype,"scrollContainer",void 0);h([mt()],tt.prototype,"_canPage",void 0);h([mt()],tt.prototype,"_canPageStart",void 0);h([mt()],tt.prototype,"_canPageEnd",void 0);h([b({type:Boolean,reflect:!0})],tt.prototype,"disabled",void 0);h([b({type:Boolean,reflect:!0})],tt.prototype,"vertical",void 0);h([b({type:Number})],tt.prototype,"threshold",void 0);h([b({attribute:"previous-page-label"})],tt.prototype,"previousPageLabel",void 0);h([b({attribute:"next-page-label"})],tt.prototype,"nextPageLabel",void 0);h([vt(40)],tt.prototype,"_updatePaging",null);tt=h([L("m3e-slide-group")],tt);var Yc,Fs,dm,Xc,_o=Xc=class extends gi(Xe(De(Be(se(Q(W(P,"tab"),!0)))))){constructor(){super(...arguments),Yc.add(this),Fs.set(this,e=>n(this,Yc,"m",dm).call(this,e))}attach(e){super.attach(e),e.id=e.id||`m3e-tab-panel-${Xc.__nextId++}`,oa(this,"aria-controls",e.id)}detach(){this.control&&this.control.id&&an(this,"aria-controls",this.control.id),super.detach()}connectedCallback(){super.connectedCallback(),this.addEventListener("click",n(this,Fs,"f"))}disconnectedCallback(){super.disconnectedCallback(),this.removeEventListener("click",n(this,Fs,"f"))}firstUpdated(e){super.firstUpdated(e),[this._focusRing,this._stateLayer,this._ripple].forEach(r=>r?.attach(this))}update(e){super.update(e),e.has("selected")&&this.closest("m3e-tabs")?.[Z].notifySelectionChange(this)}render(){return w`<div class="base"><m3e-state-layer class="state-layer" ?disabled="${this.disabled}"></m3e-state-layer><m3e-focus-ring class="focus-ring" inward ?disabled="${this.disabled}"></m3e-focus-ring><m3e-ripple class="ripple" ?disabled="${this.disabled}"></m3e-ripple><div class="touch" aria-hidden="true"></div><div class="wrapper"><slot name="icon" aria-hidden="true"></slot><span class="label"><slot></slot></span></div></div>`}};Fs=new WeakMap;Yc=new WeakSet;dm=function(e){this.disabled&&(e.preventDefault(),e.stopImmediatePropagation()),!(e.defaultPrevented||this.selected)&&this.dispatchEvent(new Event("beforeinput",{bubbles:!0,cancelable:!0}))&&(this.selected=!0,this.closest("m3e-tabs")?.[Z].notifySelectionChange(this),this.dispatchEvent(new Event("input",{bubbles:!0})),this.dispatchEvent(new Event("change",{bubbles:!0})))};_o.styles=C`:host { display: inline-block; outline: none; user-select: none; height: calc(var(--_tab-height) + ${a.density.calc(-3)}); font-size: var(--m3e-tab-font-size, ${a.typescale.standard.title.small.fontSize}); font-weight: var(--m3e-tab-font-weight, ${a.typescale.standard.title.small.fontWeight}); line-height: var(--m3e-tab-line-height, ${a.typescale.standard.title.small.lineHeight}); letter-spacing: var(--m3e-tab-tracking, ${a.typescale.standard.title.small.tracking}); flex-grow: var(--_tab-grow); -webkit-tap-highlight-color: rgba(0, 0, 0, 0); } :host(:not(:disabled)) { cursor: pointer; } .base { contain: layout style; box-sizing: border-box; vertical-align: middle; display: inline-flex; align-items: center; justify-content: center; position: relative; width: 100%; height: 100%; padding-inline-start: var(--m3e-tab-padding-start, 1.5rem); padding-inline-end: var(--m3e-tab-padding-end, 1.5rem); } .touch { position: absolute; height: 3rem; left: 0; right: 0; } .focus-ring { border-radius: var(--m3e-tab-focus-ring-shape, ${a.shape.corner.large}); } :host([selected]:focus-within) .focus-ring { top: var(--_tab-focus-ring-top-offset, 0); bottom: var(--_tab-focus-ring-bottom-offset, 0); } :host([selected]:not(:disabled)) .base { color: var(--m3e-tab-selected-color, var(--_tab-selected-color, ${a.color.primary})); --m3e-state-layer-hover-color: var( --m3e-tab-selected-container-hover-color, var(--_tab-selected-container-hover-color, ${a.color.primary}) ); --m3e-state-layer-focus-color: var( --_tab-selected-container-focus-color, var(--m3e-tab-selected-container-focus-color, ${a.color.primary}) ); --m3e-ripple-color: var( --_tab-selected-ripple-color, var(--m3e-tab-selected-ripple-color, ${a.color.primary}) ); } :host(:not([selected]):not(:disabled)) .base { color: var(--m3e-tab-unselected-color, ${a.color.onSurfaceVariant}); --m3e-state-layer-hover-color: var(--m3e-tab-unselected-container-hover-color, ${a.color.onSurface}); --m3e-state-layer-focus-color: var(--m3e-tab-unselected-container-focus-color, ${a.color.onSurface}); --m3e-ripple-color: var(--m3e-tab-unselected-ripple-color, ${a.color.onSurface}); } :host(:disabled) .base { color: color-mix( in srgb, var(--m3e-tab-disabled-color, ${a.color.onSurface}) var(--m3e-tab-disabled-opacity, 38%), transparent ); } .wrapper { display: inline-flex; align-items: center; white-space: nowrap; flex-direction: var(--_tab-direction); justify-content: center; column-gap: var(--m3e-tab-spacing, 0.5rem); } ::slotted([slot="icon"]) { width: 1em; font-size: var(--m3e-tab-icon-size, 1.5rem) !important; } @media (forced-colors: active) { :host([selected]:not(:disabled)) .base { color: ButtonText; } :host(:not([selected]):not(:disabled)) .base { color: ButtonText; } :host(:disabled) .base { color: GrayText; } }`;_o.__nextId=0;h([M(".focus-ring")],_o.prototype,"_focusRing",void 0);h([M(".state-layer")],_o.prototype,"_stateLayer",void 0);h([M(".ripple")],_o.prototype,"_ripple",void 0);h([M(".label")],_o.prototype,"label",void 0);_o=Xc=h([L("m3e-tab")],_o);var Zc=class extends W(P,"tabpanel"){connectedCallback(){super.connectedCallback(),this.slot="panel"}render(){return w`<slot></slot>`}};Zc.styles=C`:host { contain: layout style paint; display: block; overflow-y: auto; scrollbar-width: ${a.scrollbar.width}; scrollbar-color: ${a.scrollbar.color}; }`;Zc=h([L("m3e-tab-panel")],Zc);var J,Os,Me,ba,Jc,hm,um,mm,pm,fm,bm,vm,gm,ym,xm,wm,wn,$n,_n,_m,Gc=24,St=class extends Q(P){constructor(){super(),J.add(this),Os.set(this,void 0),this._selectedIndex=null,Me.set(this,void 0),ba.set(this,new Bo),this[_m]=new ja().onSelectedItemsChange(()=>n(this,J,"m",pm).call(this)).onActiveItemChange(()=>n(this,J,"m",fm).call(this)).withHomeAndEnd().withWrap().withDirectionality(G.current),this.headerPosition="before",this.variant="secondary",this.stretch=!1,this.previousPageLabel="Previous page",this.nextPageLabel="Next page",new we(this,{skipInitial:!0,callback:()=>{ae(this,"--no-animate");let e=this[Z].activeItem??this.selectedTab;e?n(this,J,"m",$n).call(this,e,!0):n(this,J,"m",_n).call(this)}})}get disablePagination(){switch(this.getAttribute("disable-pagination")){case"auto":return"auto";case"":case"true":return!0;default:return!1}}set disablePagination(e){switch(e){case!1:this.removeAttribute("disable-pagination");break;case!0:this.toggleAttribute("disable-pagination",!0);break;case"auto":this.setAttribute("disable-pagination","auto");break}}get tabs(){return this[Z]?.items??[]}get selectedTab(){return this._selectedIndex!==null?this.tabs[this._selectedIndex]??null:null}get selectedIndex(){return this._selectedIndex??-1}set selectedIndex(e){if(e>=0&&e<this.tabs.length)this.tabs[e].selected=!0;else{let r=this.selectedTab;r&&(r.selected=!1)}}connectedCallback(){super.connectedCallback(),ae(this,"--no-animate"),f(this,Os,G.observe(()=>{this.requestUpdate(),this[Z].directionality=G.current}),"f")}disconnectedCallback(){super.disconnectedCallback(),n(this,Os,"f")?.call(this)}updated(e){super.updated(e),(e.has("variant")||e.has("stretch"))&&this._selectedIndex!==null&&n(this,J,"m",_n).call(this)}render(){let e;return this.selectedTab?.control&&(e=[...this.querySelectorAll("[slot='panel']")].indexOf(this.selectedTab.control),e===-1&&(e=void 0)),w`${this.headerPosition==="before"?n(this,J,"m",Jc).call(this):F}<m3e-slide class="tabs" selected-index="${io(e)}" @pointerdown="${n(this,J,"m",vm)}" @pointermove="${n(this,J,"m",gm)}" @pointerup="${n(this,J,"m",ym)}" @pointercancel="${n(this,J,"m",xm)}" @lostpointercapture="${n(this,J,"m",wm)}"><slot name="panel"></slot></m3e-slide>${this.headerPosition==="after"?n(this,J,"m",Jc).call(this):F}`}};Os=new WeakMap;Me=new WeakMap;ba=new WeakMap;J=new WeakSet;_m=Z;Jc=function(){return w`<m3e-slide-group class="tablist" threshold="8" previous-page-label="${this.previousPageLabel}" next-page-label="${this.nextPageLabel}" ?disabled="${this.disablePagination==="auto"?matchMedia("(hover: none) and (pointer: coarse)").matches:this.disablePagination}" @pagination-changed="${n(this,J,"m",bm)}"><slot name="prev-icon" slot="prev-icon">${G.current==="ltr"?w`<svg class="prev icon" viewBox="0 -960 960 960" fill="currentColor"><path d="M640-80 240-480l400-400 71 71-329 329 329 329-71 71Z"/></svg>`:w`<svg class="next icon" viewBox="0 -960 960 960" fill="currentColor"><path d="m321-80-71-71 329-329-329-329 71-71 400 400L321-80Z"/></svg>`}</slot><slot name="next-icon" slot="next-icon">${G.current==="ltr"?w`<svg class="next icon" viewBox="0 -960 960 960" fill="currentColor"><path d="m321-80-71-71 329-329-329-329 71-71 400 400L321-80Z"/></svg>`:w`<svg class="prev icon" viewBox="0 -960 960 960" fill="currentColor"><path d="M640-80 240-480l400-400 71 71-329 329 329 329-71 71Z"/></svg>`}</slot><div class="header" role="tablist"><div class="tabs"><slot @slotchange="${n(this,J,"m",hm)}" @keydown="${n(this,J,"m",um)}" @change="${n(this,J,"m",mm)}"></slot></div><div class="ink-bar" aria-hidden="true"><div class="active-indicator"></div></div></div></m3e-slide-group>`};hm=function(){this[Z].setItems([...this.querySelectorAll("m3e-tab")])};um=function(e){this[Z].onKeyDown(e)};mm=function(e){e.stopPropagation(),this.dispatchEvent(new Event("change",{bubbles:!0}))};pm=function(){let e=this[Z].selectedItems[0],r=e?this.tabs.indexOf(e):null;r===-1&&(r=null),this._selectedIndex=r,e?n(this,J,"m",$n).call(this,e,ie(this,"--no-animate")):n(this,J,"m",_n).call(this)};fm=function(){this[Z].activeItem&&n(this,J,"m",$n).call(this,this[Z].activeItem,ie(this,"--no-animate"))};bm=function(){if(this.disablePagination)return;let e=this[Z].activeItem??this.selectedTab;e&&n(this,J,"m",$n).call(this,e,!0)};vm=function(e){e.pointerType==="touch"&&(e.currentTarget.setPointerCapture(e.pointerId),f(this,Me,{x:e.clientX,y:e.clientY},"f"),n(this,ba,"f").reset(),n(this,ba,"f").add(e.clientX))};gm=function(e){if(!n(this,Me,"f")||!e.currentTarget.hasPointerCapture(e.pointerId))return;let r=e.clientX-n(this,Me,"f").x,i=e.clientY-n(this,Me,"f").y;if(this.selectedIndex===0&&r>0&&(r=0),this.selectedIndex===this.tabs.length-1&&r<0&&(r=0),!n(this,Me,"f").dir)if(Math.abs(r)>10)n(this,Me,"f").dir="horizontal";else if(Math.abs(i)>10)n(this,Me,"f").dir="vertical";else return;if(n(this,Me,"f").dir==="vertical")return;n(this,ba,"f").add(e.clientX),n(this,Me,"f").currentX=r,this.shadowRoot?.querySelector("m3e-slide")?.classList.add("sliding"),this.selectedTab?.control?.style.setProperty("--_tabs-slide-offset-x",`${r}px`);let s=this.tabs[r>0?this.selectedIndex-1:this.selectedIndex+1];s?.control?.style.setProperty("--_tabs-slide-offset-x",`${r}px`),s?.control?.style.setProperty("--_tabs-slide-visibility","visible");let l=this.tabs[r>0?this.selectedIndex+1:this.selectedIndex-1];l?.control?.style.removeProperty("--_tabs-slide-offset-x"),l?.control?.style.removeProperty("--_tabs-slide-visibility")};ym=function(e){if(e.currentTarget.hasPointerCapture(e.pointerId))if(e.currentTarget.releasePointerCapture(e.pointerId),n(this,Me,"f")&&n(this,Me,"f").dir==="horizontal"&&n(this,Me,"f").currentX!==void 0){let r=n(this,Me,"f").currentX,i=this.clientWidth*.33,s=n(this,ba,"f").getVelocity(),l=e.pointerType==="touch"?1200:500;n(this,J,"m",wn).call(this),(Math.abs(r)>i||Math.abs(s)>l)&&(r>i?this.selectedIndex>0&&this.tabs.length>1&&!this.tabs[this.selectedIndex-1].disabled&&this.selectedIndex--:r<-i&&this.selectedIndex<this.tabs.length-1&&!this.tabs[this.selectedIndex+1].disabled&&this.selectedIndex++)}else n(this,J,"m",wn).call(this)};xm=function(e){e.currentTarget.hasPointerCapture(e.pointerId)&&(e.currentTarget.releasePointerCapture(e.pointerId),n(this,J,"m",wn).call(this))};wm=function(){n(this,J,"m",wn).call(this)};wn=function(){f(this,Me,void 0,"f"),n(this,ba,"f").reset();let e=this.shadowRoot?.querySelector("m3e-slide");!e||!e.classList.contains("sliding")||(e.classList.add("snap"),Ce()||e.addEventListener("transitionend",()=>e.classList.remove("snap"),{once:!0}),e.classList.remove("sliding"),this.tabs.forEach(r=>{r.control?.style.removeProperty("--_tabs-slide-offset-x"),r.control?.style.removeProperty("--_tabs-slide-visibility")}))};$n=async function(e,r){await this.updateComplete;for(let l of this.tabs)await l.updateComplete;await this._tablist?.updateComplete;let i=48,s=this._tablist?.scrollContainer;s&&(s?.scrollTo({behavior:r?"instant":"smooth",top:0,left:Math.min(e.offsetLeft-s.offsetLeft-i,Math.max(e.offsetLeft+e.offsetWidth-s.offsetWidth-s.offsetLeft+i,s.scrollLeft))}),n(this,J,"m",_n).call(this))};_n=function(){if(!this._tablist)return;let e=this[Z].selectedItems[0],r=0,i=0;if(e&&this._selectedIndex!==null){for(let s=0;s<this._selectedIndex;s++)r+=this.tabs[s].clientWidth;i=e.clientWidth,this.variant==="primary"&&e.label&&(r+=e.label.offsetLeft,i=e.label.clientWidth,i<Gc&&(r-=(Gc-i)/2,i=Gc))}this._tablist.style.setProperty("--_tabs-active-tab-position",`${r}px`),this._tablist.style.setProperty("--_tabs-active-tab-size",`${i}px`),i>0&&ie(this,"--no-animate")&&setTimeout(()=>D(this,"--no-animate"))};St.styles=C`:host { display: flex; flex-direction: column; position: relative; } .tablist { contain: layout style; position: relative; box-sizing: border-box; flex: none; } ::slotted(prev-icon), ::slotted(next-icon), .icon { width: 1em; font-size: var(--m3e-tabs-paginator-button-icon-size, var(--m3e-icon-button-icon-size, 1.5rem)) !important; } .header { display: flex; flex-direction: column; } .tabs { display: flex; flex-wrap: nowrap; align-items: center; } .ink-bar { contain: layout style paint; box-sizing: border-box; height: var(--_tabs-active-indicator-thickness); } .active-indicator { position: relative; height: var(--_tabs-active-indicator-thickness); left: calc(var(--_tabs-active-tab-position) + var(--_tabs-activate-indicator-inset, 0px)); width: calc(var(--_tabs-active-tab-size) - calc(var(--_tabs-activate-indicator-inset, 0px) * 2)); background-color: var(--m3e-tabs-active-indicator-color, ${a.color.primary}); transition: ${o(`left var(--m3e-slide-animation-duration, ${a.motion.duration.long2}) ${a.motion.easing.standard},
        width var(--m3e-slide-animation-duration, ${a.motion.duration.long2}) ${a.motion.easing.standard}`)}; } :host([header-position="after"]) .header { flex-direction: column-reverse; } :host([header-position="before"]) .ink-bar { margin-top: calc(0px - var(--_tabs-active-indicator-thickness)); } :host([header-position="before"]) .tablist { --m3e-slide-group-divider-bottom: var(--m3e-divider-thickness, 1px) solid var(--m3e-divider-color, ${a.color.outlineVariant}); } :host([header-position="after"]) .ink-bar { margin-bottom: calc(0px - var(--_tabs-active-indicator-thickness)); } :host([header-position="after"]) .tablist { --m3e-slide-group-divider-top: var(--m3e-divider-thickness, 1px) solid var(--m3e-divider-color, ${a.color.outlineVariant}); } :host([header-position="before"][variant="primary"]) .active-indicator { border-radius: var(--m3e-tabs-primary-before-active-indicator-shape, ${a.shape.corner.extraSmallTop}); } :host([header-position="after"][variant="primary"]) .active-indicator { border-radius: var(--m3e-tabs-primary-after-active-indicator-shape, ${a.shape.corner.extraSmallBottom}); } .tabs { flex: 1 1 auto; } :host([variant="primary"]) .tablist { --_tabs-activate-indicator-inset: var(--m3e-tabs-primary-active-indicator-inset, 0.125rem); --_tabs-active-indicator-thickness: var(--m3e-tabs-primary-active-indicator-thickness, 3px); --_tab-height: 4rem; } :host([header-position="before"]) .tablist { --_tab-focus-ring-bottom-offset: calc(var(--_tabs-active-indicator-thickness) + 1px); } :host([header-position="after"]) .tablist { --_tab-focus-ring-top-offset: calc(var(--_tabs-active-indicator-thickness) + 2px); } :host([header-position="before"][variant="primary"]) .tablist { --_tab-direction: column; } :host([header-position="after"][variant="primary"]) .tablist { --_tab-direction: column-reverse; } :host([variant="secondary"]) .tablist { --_tabs-active-indicator-thickness: var(--m3e-tabs-secondary-active-indicator-thickness, 2px); --_tab-height: 3rem; --_tab-selected-color: ${a.color.onSurface}; --_tab-selected-container-hover-color: ${a.color.onSurface}; --_tab-selected-container-focus-color: ${a.color.onSurface}; --_tab-selected-ripple-color: ${a.color.onSurface}; } :host([stretch]) .header { width: 100%; --_tab-grow: 1; } .tabs.sliding ::slotted([slot="panel"]) { transform: translateX(var(--_tabs-slide-offset-x)); visibility: var(--_tabs-slide-visibility, "hidden"); } .tabs.snap ::slotted([slot="panel"]) { transition: ${o(`inset-inline-start var(--m3e-slide-animation-duration, ${a.motion.duration.long2}) ${a.motion.easing.standard},
        transform var(--m3e-slide-animation-duration, ${a.motion.duration.long2}) ${a.motion.easing.standard},
        visibility var(--m3e-slide-animation-duration, ${a.motion.duration.long2}) ${a.motion.easing.standard} allow-discrete`)}; } .tabs:not(.sliding) ::slotted([slot="panel"]) { transform: translateX(0); } :host(:is(:state(--no-animate), :--no-animate)) .active-indicator { transition: none; } @media (prefers-reduced-motion) { .active-indicator { transition: none; } .tabs.snap ::slotted([slot="panel"]) { transition: none; } } @media (forced-colors: active) { .active-indicator { background-color: ButtonText; --m3e-divider-color: GrayText; } }`;h([M(".tablist")],St.prototype,"_tablist",void 0);h([mt()],St.prototype,"_selectedIndex",void 0);h([b({attribute:!1})],St.prototype,"disablePagination",null);h([b({attribute:"header-position",reflect:!0})],St.prototype,"headerPosition",void 0);h([b({reflect:!0})],St.prototype,"variant",void 0);h([b({type:Boolean,reflect:!0})],St.prototype,"stretch",void 0);h([b({attribute:"previous-page-label"})],St.prototype,"previousPageLabel",void 0);h([b({attribute:"next-page-label"})],St.prototype,"nextPageLabel",void 0);St=h([L("m3e-tabs")],St);var Ka,Bs,Ds,Rs,$m,Cm,Sm,km,va,eo=va=class extends W(P,"status"){constructor(){super(...arguments),Ka.add(this),Bs.set(this,-1),Ds.set(this,!1),Rs.set(this,e=>n(this,Ka,"m",km).call(this,e)),this.duration=3e3,this.action="",this.dismissible=!1,this.closeLabel="Close"}static get current(){return va.__current}get isActionTaken(){return n(this,Ds,"f")}connectedCallback(){super.connectedCallback(),this.addEventListener("beforetoggle",n(this,Rs,"f")),this.setAttribute("popover","manual"),this.ariaLive="polite"}disconnectedCallback(){super.disconnectedCallback(),this.removeEventListener("beforetoggle",n(this,Rs,"f"))}render(){return w`<div class="base"><span class="supporting-text"><slot></slot></span>${n(this,Ka,"m",$m).call(this)} ${n(this,Ka,"m",Cm).call(this)}</div>`}updated(e){super.updated(e),this.style.setProperty("--_snackbar-height",`${this.getBoundingClientRect().height/.8}px`)}};Bs=new WeakMap;Ds=new WeakMap;Rs=new WeakMap;Ka=new WeakSet;$m=function(){return this.action?w`<m3e-button @click="${n(this,Ka,"m",Sm)}">${this.action}</m3e-button>`:F};Cm=function(){return this.dismissible?w`<m3e-icon-button aria-label="${this.closeLabel}" @click="${this.hidePopover}"><slot name="close-icon"><svg class="close-icon" viewBox="0 -960 960 960" fill="currentColor"><path d="m256-200-56-56 224-224-224-224 56-56 224 224 224-224 56 56-224 224 224 224-56 56-224-224-224 224Z"/></svg></slot></m3e-icon-button>`:F};Sm=function(){f(this,Ds,!0,"f"),this.hidePopover()};km=function(e){e.newState=="open"?(va.__current?.hidePopover(),va.__current=this,this.duration>0&&f(this,Bs,setTimeout(()=>this.hidePopover(),this.duration),"f")):(va.__current===this&&(va.__current=null),clearTimeout(n(this,Bs,"f")))};ho(C`m3e-snackbar { margin-inline: auto; }`);eo.styles=C`:host { contain: layout style paint; position: fixed; top: calc(100vh - var(--_snackbar-height, 0px) - var(--m3e-snackbar-margin, 1rem)); display: inline-flex; align-items: center; min-width: var(--m3e-snackbar-min-width, 21.5rem); max-width: var(--m3e-snackbar-max-width, 42rem); visibility: hidden; border: none; margin: 0; padding: 0; opacity: 0; transform: scaleY(0.8); transform-origin: bottom; transition: ${o(`opacity ${a.motion.duration.short3} ${a.motion.easing.standard}, 
        transform ${a.motion.duration.short3} ${a.motion.easing.standard}, 
        overlay ${a.motion.duration.short3} ${a.motion.easing.standard} allow-discrete,
        visibility ${a.motion.duration.short3} ${a.motion.easing.standard} allow-discrete`)}; } :host::backdrop { background-color: transparent; } :host(:popover-open) { visibility: visible; opacity: 1; transform: scaleY(1); } @starting-style { :host(:popover-open) { opacity: 0; transform: scaleY(0.8); } } .base { display: inline-flex; align-items: center; flex: 1 1 auto; box-sizing: border-box; padding: var(--m3e-snackbar-padding, 0 1rem 0 1rem); border-radius: var(--m3e-snackbar-container-shape, ${a.shape.corner.extraSmall}); background-color: var(--m3e-snackbar-container-color, ${a.color.inverseSurface}); font-size: var(--m3e-snackbar-supporting-text-font-size, ${a.typescale.standard.label.large.fontSize}); font-weight: var( --m3e-snackbar-supporting-text-font-weight, ${a.typescale.standard.label.large.fontWeight} ); line-height: var( --m3e-snackbar-supporting-text-line-height, ${a.typescale.standard.label.large.lineHeight} ); letter-spacing: var( --m3e-snackbar-supporting-text-tracking, ${a.typescale.standard.label.large.tracking} ); color: var(--m3e-snackbar-supporting-text-color, ${a.color.inverseOnSurface}); --m3e-text-button-label-text-color: var(--m3e-snackbar-action-text-color, ${a.color.inversePrimary}); --m3e-text-button-hover-label-text-color: var( --m3e-snackbar-action-text-color, ${a.color.inversePrimary} ); --m3e-text-button-hover-state-layer-color: var( --m3e-snackbar-action-text-color, ${a.color.inversePrimary} ); --m3e-text-button-focus-label-text-color: var( --m3e-snackbar-action-text-color, ${a.color.inversePrimary} ); --m3e-text-button-focus-state-layer-color: var( --m3e-snackbar-action-text-color, ${a.color.inversePrimary} ); --m3e-text-button-pressed-label-text-color: var( --m3e-snackbar-action-text-color, ${a.color.inversePrimary} ); --m3e-text-button-pressed-state-layer-color: var( --m3e-snackbar-action-text-color, ${a.color.inversePrimary} ); --m3e-standard-icon-button-icon-color: var( --m3e-snackbar-close-icon-color, ${a.color.inverseOnSurface} ); --m3e-standard-icon-button-hover-icon-color: var( --m3e-snackbar-close-icon-color, ${a.color.inverseOnSurface} ); --m3e-standard-icon-button-hover-state-layer-color: var( --m3e-snackbar-close-icon-color, ${a.color.inverseOnSurface} ); --m3e-standard-icon-button-focus-icon-color: var( --m3e-snackbar-close-icon-color, ${a.color.inverseOnSurface} ); --m3e-standard-icon-button-focus-state-layer-color: var( --m3e-snackbar-close-icon-color, ${a.color.inverseOnSurface} ); --m3e-standard-icon-button-pressed-icon-color: var( --m3e-snackbar-close-icon-color, ${a.color.inverseOnSurface} ); --m3e-standard-icon-button-pressed-state-layer-color: var( --m3e-snackbar-close-icon-color, ${a.color.inverseOnSurface} ); } :host([dismissible]) .base { padding-inline-end: 0.5rem; } .supporting-text { flex: 1 1 auto; display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden; line-clamp: 2; margin-block: var(--m3e-snackbar-supporting-text-margin-block, 0.875rem); } ::slotted([slot="close-icon"]), .close-icon { width: 1em; font-size: var(--m3e-icon-button-icon-size, 1.5rem) !important; } @media (forced-colors: active) { :host { background-color: Canvas; color: CanvasText; border-radius: ${a.shape.corner.small}; box-sizing: border-box; outline: 1px solid CanvasText; } }`;eo.__current=null;h([b({type:Number})],eo.prototype,"duration",void 0);h([b()],eo.prototype,"action",void 0);h([b({type:Boolean,reflect:!0})],eo.prototype,"dismissible",void 0);h([b({attribute:"close-label"})],eo.prototype,"closeLabel",void 0);eo=va=h([L("m3e-snackbar")],eo);var Qc=class{static open(e,r,i,s){if(!1)return;let l=document.createElement("m3e-snackbar");l.append(document.createTextNode(e));let c;typeof r=="string"?l.action=r:typeof r=="boolean"?l.dismissible=r:c=r,typeof i=="boolean"?l.dismissible=i:c=i,s&&(c=s),c?.duration!==void 0&&(l.duration=c.duration),c?.closeLabel&&(l.closeLabel=c.closeLabel),l.addEventListener("toggle",d=>{d.newState==="closed"&&(Ce()?l.remove():l.addEventListener("transitionend",()=>l.remove(),{once:!0}),l.isActionTaken&&c?.actionCallback?.())}),(document.querySelector("m3e-theme")??document.body).append(l),l.showPopover()}static dismiss(){eo.current?.hidePopover()}};globalThis.M3eSnackbar=Qc;var ga=class{constructor(e){N(this,"cap");N(this,"items");N(this,"start",0);N(this,"length",0);if(e<1)throw new RangeError("RollingBuffer cap must be >= 1");this.cap=e,this.items=new Array(e)}push(e){this.length<this.cap?(this.items[(this.start+this.length)%this.cap]=e,this.length++):(this.items[this.start]=e,this.start=(this.start+1)%this.cap)}toArray(){let e=[];for(let r=0;r<this.length;r++){let i=this.items[(this.start+r)%this.cap];e.push(i)}return e}};var fb=/^(authorization|cookie|set-cookie)$/i,bb=/token|secret|key|password|auth|session/i,vb="\u2026[truncated]";function Kc(t){let e={};for(let[r,i]of Object.entries(t))e[r]=fb.test(r)?"[redacted]":i;return e}function ed(t){let e;try{e=new URL(t)}catch{return t}let r=!1;for(let[i]of e.searchParams.entries())bb.test(i)&&(e.searchParams.set(i,"[redacted]"),r=!0);return r?e.toString():t}function ya(t,e=2e3){return t.length<=e?t:t.slice(0,e)+vb}var gb={bufferSize:50,captureNetwork:!1,captureConsole:!0,captureEvents:!0,maskInputs:!1,redactSelectors:[]},yb=0;function to(){return`${Date.now()}-${++yb}`}function Em(t){if(!t)return"(unknown)";let e=[],r=t;for(;r&&r!==document.documentElement;){let i=r.tagName.toLowerCase();if(r.id){i+=`#${r.id}`,e.unshift(i);break}let s=r.parentElement?Array.from(r.parentElement.children).filter(l=>l.tagName===r.tagName):[];if(s.length>1){let l=s.indexOf(r)+1;i+=`:nth-of-type(${l})`}e.unshift(i),r=r.parentElement}return e.join(" > ")||t.tagName.toLowerCase()}function Mm(t,e={}){let r={...gb,...e},i=new ga(r.bufferSize),s=new ga(r.bufferSize),l=new ga(r.bufferSize),c=new ga(r.bufferSize),d=[];if(r.captureNetwork){let m=t.fetch,y=async(_,S)=>{let $=S?.method?.toUpperCase()??(typeof _!="string"&&!(_ instanceof URL)&&_ instanceof Request?_.method.toUpperCase():"GET"),T=typeof _=="string"?_:_ instanceof URL?_.toString():_.url,z=ed(T),O={},U=S?.headers;if(U)if(U instanceof Headers)U.forEach((j,oe)=>{O[oe]=j});else if(Array.isArray(U))for(let[j,oe]of U)j!==void 0&&oe!==void 0&&(O[j]=oe);else Object.assign(O,U);let X=Kc(O),ye;if(S?.body!=null){let j=S.body;typeof j=="string"?ye=ya(j):ye=ya("[non-string body]")}let ot=to(),Ve=Date.now(),te=performance.now(),Oe=null,Le=null,ht;try{let j=await m.call(t,_,S);Le=Math.round(performance.now()-te),Oe=j.status;let oe=j.headers.get("content-type")??"",kt=j.headers.get("content-length");if(oe.includes("text/event-stream")||oe.includes("application/octet-stream")||kt===null&&!oe.includes("application/json")&&!oe.includes("text/html")&&!oe.includes("text/plain")&&!oe.includes("application/x-www-form-urlencoded")&&!oe.includes("multipart/form-data")&&oe!=="")return i.push({id:ot,timestamp:Ve,method:$,url:z,status:Oe,durationMs:Le,headers:X,requestBody:ye,responseBody:void 0}),j;let Te=j.clone(),ut={id:ot,timestamp:Ve,method:$,url:z,status:Oe,durationMs:Le,headers:X,requestBody:ye,responseBody:void 0};return i.push(ut),Te.text().then(Ws=>{ut.responseBody=ya(Ws)},()=>{}),j}catch(j){throw Le=Math.round(performance.now()-te),i.push({id:ot,timestamp:Ve,method:$,url:z,status:null,durationMs:Le,headers:X,requestBody:ye,responseBody:void 0}),j}};t.fetch=y,d.push(()=>{t.fetch=m});let v=t.XMLHttpRequest;class x extends v{constructor(){super(...arguments);N(this,"_method","GET");N(this,"_url","");N(this,"_startTime",0);N(this,"_entryId","");N(this,"_entryTimestamp",0);N(this,"_recorded",!1);N(this,"_pendingBody")}open($,T,z,O,U){this._method=$.toUpperCase(),this._url=ed(typeof T=="string"?T:T.toString()),this._entryId=to(),this._entryTimestamp=Date.now(),this._recorded=!1,this.addEventListener("error",()=>{if(this._recorded)return;this._recorded=!0;let X=Math.round(performance.now()-this._startTime);i.push({id:this._entryId,timestamp:this._entryTimestamp,method:this._method,url:this._url,status:null,durationMs:X,headers:{},requestBody:void 0,responseBody:void 0})}),this.addEventListener("loadend",()=>{if(this._recorded)return;this._recorded=!0;let X=Math.round(performance.now()-this._startTime),ye=this.getAllResponseHeaders(),ot={};for(let Le of ye.split(`\r
`)){let ht=Le.indexOf(": ");if(ht>0){let j=Le.slice(0,ht),oe=Le.slice(ht+2);j!==void 0&&(ot[j]=oe??"")}}let Ve;typeof this.responseText=="string"&&(Ve=ya(this.responseText));let te,Oe=this._pendingBody;Oe!=null&&typeof Oe=="string"&&(te=ya(Oe)),i.push({id:this._entryId,timestamp:this._entryTimestamp,method:this._method,url:this._url,status:this.status||null,durationMs:X,headers:Kc(ot),requestBody:te,responseBody:Ve})}),z!==void 0?super.open($,T,z,O??null,U??null):super.open($,T)}send($){this._startTime=performance.now(),this._pendingBody=$;try{super.send($)}catch(T){if(!this._recorded){this._recorded=!0;let z=Math.round(performance.now()-this._startTime);i.push({id:this._entryId,timestamp:this._entryTimestamp,method:this._method,url:this._url,status:null,durationMs:z,headers:{},requestBody:void 0,responseBody:void 0})}throw T}}}t.XMLHttpRequest=x,d.push(()=>{t.XMLHttpRequest=v})}if(r.captureConsole){let m=["log","info","warn","error","debug"],y={};for(let v of m){let x=t.console[v];y[v]=x,t.console[v]=(..._)=>{let S=ya(_.map($=>{try{return typeof $=="string"?$:JSON.stringify($)}catch{return String($)}}).join(" "));s.push({id:to(),timestamp:Date.now(),level:v,message:S}),x.apply(t.console,_)}}d.push(()=>{for(let v of m){let x=y[v];x&&(t.console[v]=x)}})}if(r.captureEvents){let m=_=>{let S=_.target instanceof Element?_.target:null;l.push({id:to(),timestamp:Date.now(),type:"click",selector:Em(S)})},y=_=>{let S=_.target instanceof HTMLInputElement?_.target:null,$=Em(S),T;S&&(r.maskInputs?T="[masked]":r.redactSelectors.length>0&&r.redactSelectors.some(O=>{try{return S.matches(O)}catch{return!1}})?T="[redacted]":T=S.value);let z={id:to(),timestamp:Date.now(),type:"input",selector:$};T!==void 0&&(z.value=T),l.push(z)};t.document.addEventListener("click",m,!0),t.document.addEventListener("input",y,!0);let v=t.history.pushState.bind(t.history);t.history.pushState=(_,S,$)=>{l.push({id:to(),timestamp:Date.now(),type:"pushstate",selector:typeof $=="string"?$:$ instanceof URL?$.toString():t.location.href}),v(_,S,$)};let x=()=>{l.push({id:to(),timestamp:Date.now(),type:"popstate",selector:t.location.href})};t.addEventListener("popstate",x),d.push(()=>{t.document.removeEventListener("click",m,!0),t.document.removeEventListener("input",y,!0),t.history.pushState=v,t.removeEventListener("popstate",x)})}let u=m=>{c.push({id:to(),timestamp:Date.now(),message:m.message||"Unknown error",stack:m.error instanceof Error?m.error.stack:void 0})},p=m=>{let y=m.reason,v=y instanceof Error?y.message:typeof y=="string"?y:"Unhandled rejection",x=y instanceof Error?y.stack:void 0;c.push({id:to(),timestamp:Date.now(),message:v,stack:x})};t.addEventListener("error",u),t.addEventListener("unhandledrejection",p),d.push(()=>{t.removeEventListener("error",u),t.removeEventListener("unhandledrejection",p)});function g(){let m={url:t.location.href,referrer:t.document.referrer,viewport:{width:t.innerWidth,height:t.innerHeight},userAgent:t.navigator.userAgent};return r.ref!==void 0&&(m.ref=r.ref),m}return{snapshot(){return{environment:g(),network:i.toArray(),console:s.toArray(),events:l.toArray(),errors:c.toArray()}},uninstall(){for(let m of d)m()}}}function xb(t){let e=t.environment,r=[`**URL:** ${e.url}`,`**Referrer:** ${e.referrer||"(none)"}`,`**Viewport:** ${e.viewport.width}\xD7${e.viewport.height}`,`**User-Agent:** ${e.userAgent}`];return e.ref!==void 0&&r.push(`**Ref:** ${e.ref}`),`## Environment

${r.join(`
`)}`}function wb(t){let e=t.status!==null?String(t.status):"failed",r=t.durationMs!==null?`${t.durationMs} ms`:"unknown";return`- ${t.method} ${t.url} \u2192 ${e} (${r})`}function _b(t){return`- [${t.level}] ${t.message}`}function $b(t){let e=t.value!==void 0?` value=${t.value}`:"";return`- ${t.type} on \`${t.selector}\`${e}`}function Cb(t){let e=t.stack!==void 0?`
\`\`\`
${t.stack}
\`\`\``:"";return`- ${t.message}${e}`}function Lm(t){let e=t.includedContext,r=[t.description];if(r.push(xb(e)),e.network.length>0){let i=e.network.map(wb).join(`
`);r.push(`## Network

${i}`)}if(e.console.length>0){let i=e.console.map(_b).join(`
`);r.push(`## Console

${i}`)}if(e.events.length>0){let i=e.events.map($b).join(`
`);r.push(`## Events

${i}`)}if(e.errors.length>0){let i=e.errors.map(Cb).join(`
`);r.push(`## Errors

${i}`)}return r.join(`

`)}function Tm(t,e,r={}){let i={repo:e.repo,title:(e.titlePrefix??"")+t.title,bodyMarkdown:Lm(t)};return e.labels&&e.labels.length>0&&(i.labels=e.labels),r.screenshot&&(i.screenshot=r.screenshot),r.meta&&(i.meta=r.meta),i}async function Pm(t,e,r=fetch){let i=`${t.replace(/\/+$/,"")}/api/feedback`,s=await r(i,{method:"POST",headers:{"content-type":"application/json"},body:JSON.stringify(e)});if(!s.ok)throw new Error(`hosted submit failed: HTTP ${s.status}`);return await s.json()}function Sb(t){return{getDisplayMedia:()=>t.navigator.mediaDevices.getDisplayMedia({video:!0,audio:!1}),makeVideo:()=>t.document.createElement("video"),makeCanvas:()=>t.document.createElement("canvas")}}function kb(t){return typeof t.navigator?.mediaDevices?.getDisplayMedia=="function"}function td(t){return new Promise((e,r)=>{let i=t.document.createElement("input");i.type="file",i.accept="image/*",i.hidden=!0,i.addEventListener("change",()=>{let s=i.files?.[0];if(i.remove(),!s){r(new Error("no image selected"));return}let l=new t.FileReader;l.onload=()=>e(String(l.result)),l.onerror=()=>r(new Error("could not read the image")),l.readAsDataURL(s)}),t.document.body.appendChild(i),i.click()})}function Am(t){return kb(t)?Eb(Sb(t)):td(t)}async function Eb(t){let e=await t.getDisplayMedia();try{let r=t.makeVideo();r.srcObject=e,await r.play();let i=t.makeCanvas();i.width=r.videoWidth||1,i.height=r.videoHeight||1;let s=i.getContext("2d");if(!s)throw new Error("2D canvas context unavailable");return s.drawImage(r,0,0),i.toDataURL("image/png")}finally{for(let r of e.getTracks())r.stop()}}var Mb="bottom-right";function Im(t,e){let r=t.getAttribute(e);return r===null?!0:r.toLowerCase()!=="false"}function zm(t,e){return t.hasAttribute(e)?(t.getAttribute(e)??"").toLowerCase()!=="false":!1}function Fm(t){return t?t.split(",").map(e=>e.trim()).filter(e=>e.length>0):[]}function Lb(t){return t.replace(/\/+$/,"")}function Tb(t){try{return new URL(t).origin}catch{return null}}function Pb(t,e){if(t&&t.trim().length>0)return Lb(t.trim());if(e){let r=Tb(e);if(r)return r}}function Om(t){let e=t.getAttribute("repo");if(!e)throw new Error('<feedback-fab> requires a `repo="owner/name"` attribute');let r=t.getAttribute("buffer-size"),i=r===null?NaN:Number.parseInt(r,10),s=Number.isFinite(i)&&i>0?i:50,l=t.getAttribute("ref")??t.getAttribute("version")??void 0,c=t.getAttribute("title-prefix")??void 0,d=t.getAttribute("endpoint")??void 0,u=Pb(t.getAttribute("flightdeck-url"),t.getAttribute("endpoint")),p=t.getAttribute("poll-interval"),g=p===null?NaN:Number.parseInt(p,10),m=Number.isFinite(g)&&g>0?g*1e3:3e4,y=t.getAttribute("dashboard"),v=y!==null&&y.toLowerCase()==="false",x=u!==void 0&&!v,_={bufferSize:s,captureNetwork:zm(t,"capture-network"),captureConsole:Im(t,"capture-console"),captureEvents:Im(t,"capture-events"),maskInputs:zm(t,"mask-inputs"),redactSelectors:Fm(t.getAttribute("redact"))};l!==void 0&&(_.ref=l);let S={repo:e},$=Fm(t.getAttribute("labels"));$.length>0&&(S.labels=$),c!==void 0&&(S.titlePrefix=c);let T={repo:e,capture:_,fallback:S,position:t.getAttribute("position")??Mb,pollIntervalMs:m,dashboardEnabled:x};return d!==void 0&&(T.endpoint=d),u!==void 0&&(T.flightdeckUrl=u),T}var Rm=`
/* Icon-FOUC guard: hide icon glyphs until the Material Symbols stylesheet has
   loaded (so the @font-face exists). Before that the fallback font would render
   the ligature text ("bug_report"); after it, font-display:block covers the
   file-download window. The host removes this class on stylesheet load/timeout. */
.feedback-fab-popover.ff-fonts-loading m3e-icon { visibility: hidden; }

.feedback-fab-popover {
  position: fixed;
  inset: 0;
  /* Override the UA popover's width/height: fit-content so the stage actually
     fills the viewport and can catch outside clicks (not just where content is). */
  width: auto;
  height: auto;
  max-width: none;
  max-height: none;
  margin: 0;
  padding: 0;
  border: 0;
  background: transparent;
  overflow: visible;
  pointer-events: none;
  --ff-top: auto;
  --ff-right: 16px;
  --ff-bottom: 16px;
  --ff-left: auto;
}
.feedback-fab-popover::backdrop { background: transparent; }

/* While the sheet is open the stage catches pointer events, so a click outside
   the sheet dismisses it without falling through to the host page below. */
.feedback-fab-popover[data-open] { pointer-events: auto; }

m3e-fab {
  position: fixed;
  top: var(--ff-top);
  right: var(--ff-right);
  bottom: var(--ff-bottom);
  left: var(--ff-left);
  pointer-events: auto;
  cursor: grab;
  touch-action: none;
}
.feedback-fab-popover[data-dragging] m3e-fab { cursor: grabbing; }

m3e-bottom-sheet {
  pointer-events: auto;
  /* Cap the sheet at the SMALL viewport (URL bar shown) so it can never grow
     taller than what's actually visible on mobile \u2014 otherwise "fit" sizes to
     content against the larger layout viewport and the bottom action row is
     clipped behind the browser chrome. svh is the conservative floor; dvh (set
     below where supported) tracks the URL bar as it hides. */
  max-block-size: 100svh;
  max-block-size: 100dvh;
  /* m3e anchors the sheet with \`top: calc(100vh - var(--_bottom-sheet-height))\`,
     but \`vh\` is the LARGE viewport, so when the URL bar is shown the sheet's
     bottom (action row) sits behind it and clips. Re-anchor to \`dvh\` \u2014 the
     visible height \u2014 mirroring m3e's formula. This override wins over the shadow
     :host and reads the private inline var m3e sets on the host. */
  top: calc(100dvh - var(--_bottom-sheet-height)) !important;
}

/* The sheet's own scroll region (its shadow \`.body\`) holds our flex-column
   content: the description grows/scrolls, and the pinned action row rides at the
   end. \`env(safe-area-inset-bottom)\` keeps that row clear of the home indicator /
   gesture bar so the Hide/Cancel/Submit buttons are always fully tappable and
   never clipped at the very bottom of the viewport. */
.ff-sheet-body {
  padding-bottom: calc(1rem + env(safe-area-inset-bottom, 0px));
}

/* Chip inline count badges: slightly smaller than the default medium badge so
   they sit proportionally inside the chip trailing slot (#291). The medium badge
   size tokens are CSS custom properties on the host element \u2014 set them here on
   the m3e-badge element itself so the override is scoped to these badges only. */
.ff-sheet-body m3e-badge {
  --m3e-badge-medium-font-size: 0.625rem;
  --m3e-badge-medium-size: 1.125rem;
}

/* --- Dashboard mode (S5) -------------------------------------------------- */

/* The mergeable-PR badge on the collapsed FAB. The badge is an unattached
   m3e-badge dropped inside the m3e-fab; anchor it to the FAB's top-right corner
   so it reads as a count pill, and give it the same reduced medium-badge size as
   the in-sheet chip badges. */
m3e-fab .ff-fab-badge {
  position: absolute;
  top: -2px;
  right: -2px;
  --m3e-badge-medium-font-size: 0.625rem;
  --m3e-badge-medium-size: 1.125rem;
}

/* The mergeable-count badge that rides on the "Dashboard" tab label. Sit it
   just after the label text with a small gap, reduced to the same compact
   medium-badge size the other in-widget badges use. */
m3e-tabs .ff-tab-badge {
  margin-inline-start: 0.375rem;
  --m3e-badge-medium-font-size: 0.625rem;
  --m3e-badge-medium-size: 1.125rem;
}

/* Dashboard PR/status badges: the "mergeable" tag reads as an affirmative, so
   tint it with the M3 tertiary-container role tokens (green-family in the
   default scheme). The badge look otherwise comes straight from @m3e/web. */
.ff-dashboard m3e-badge {
  --m3e-badge-medium-font-size: 0.625rem;
  --m3e-badge-medium-size: auto;
}
.ff-dashboard .ff-badge-mergeable {
  --m3e-badge-color: var(--md-sys-color-on-tertiary-container, currentColor);
  --m3e-badge-container-color: var(--md-sys-color-tertiary-container, transparent);
}

`;var Bm=`/*! tailwindcss v4.3.2 | MIT License | https://tailwindcss.com */
@layer properties{@supports (((-webkit-hyphens:none)) and (not (margin-trim:inline))) or ((-moz-orient:inline) and (not (color:rgb(from red r g b)))){*,:before,:after,::backdrop{--tw-border-style:solid;--tw-font-weight:initial;--tw-shadow:0 0 #0000;--tw-shadow-color:initial;--tw-shadow-alpha:100%;--tw-inset-shadow:0 0 #0000;--tw-inset-shadow-color:initial;--tw-inset-shadow-alpha:100%;--tw-ring-color:initial;--tw-ring-shadow:0 0 #0000;--tw-inset-ring-color:initial;--tw-inset-ring-shadow:0 0 #0000;--tw-ring-inset:initial;--tw-ring-offset-width:0px;--tw-ring-offset-color:#fff;--tw-ring-offset-shadow:0 0 #0000;--tw-outline-style:solid;--tw-blur:initial;--tw-brightness:initial;--tw-contrast:initial;--tw-grayscale:initial;--tw-hue-rotate:initial;--tw-invert:initial;--tw-opacity:initial;--tw-saturate:initial;--tw-sepia:initial;--tw-drop-shadow:initial;--tw-drop-shadow-color:initial;--tw-drop-shadow-alpha:100%;--tw-drop-shadow-size:initial}}}@layer theme{:root,:host{--font-sans:ui-sans-serif, system-ui, sans-serif, "Apple Color Emoji", "Segoe UI Emoji", "Segoe UI Symbol", "Noto Color Emoji";--font-mono:ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, "Liberation Mono", "Courier New", monospace;--spacing:.25rem;--text-sm:.875rem;--text-sm--line-height:calc(1.25 / .875);--font-weight-medium:500;--default-transition-duration:.15s;--default-transition-timing-function:cubic-bezier(.4, 0, .2, 1);--default-font-family:var(--font-sans);--default-mono-font-family:var(--font-mono)}}@layer base{*,:after,:before,::backdrop{box-sizing:border-box;border:0 solid;margin:0;padding:0}::file-selector-button{box-sizing:border-box;border:0 solid;margin:0;padding:0}html,:host{-webkit-text-size-adjust:100%;tab-size:4;line-height:1.5;font-family:var(--default-font-family,ui-sans-serif, system-ui, sans-serif, "Apple Color Emoji", "Segoe UI Emoji", "Segoe UI Symbol", "Noto Color Emoji");font-feature-settings:var(--default-font-feature-settings,normal);font-variation-settings:var(--default-font-variation-settings,normal);-webkit-tap-highlight-color:transparent}hr{height:0;color:inherit;border-top-width:1px}abbr:where([title]){-webkit-text-decoration:underline dotted;text-decoration:underline dotted}h1,h2,h3,h4,h5,h6{font-size:inherit;font-weight:inherit}a{color:inherit;-webkit-text-decoration:inherit;-webkit-text-decoration:inherit;-webkit-text-decoration:inherit;text-decoration:inherit}b,strong{font-weight:bolder}code,kbd,samp,pre{font-family:var(--default-mono-font-family,ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, "Liberation Mono", "Courier New", monospace);font-feature-settings:var(--default-mono-font-feature-settings,normal);font-variation-settings:var(--default-mono-font-variation-settings,normal);font-size:1em}small{font-size:80%}sub,sup{vertical-align:baseline;font-size:75%;line-height:0;position:relative}sub{bottom:-.25em}sup{top:-.5em}table{text-indent:0;border-color:inherit;border-collapse:collapse}:-moz-focusring{outline:auto}progress{vertical-align:baseline}summary{display:list-item}ol,ul,menu{list-style:none}img,svg,video,canvas,audio,iframe,embed,object{vertical-align:middle;display:block}img,video{max-width:100%;height:auto}button,input,select,optgroup,textarea{font:inherit;font-feature-settings:inherit;font-variation-settings:inherit;letter-spacing:inherit;color:inherit;opacity:1;background-color:#0000;border-radius:0}::file-selector-button{font:inherit;font-feature-settings:inherit;font-variation-settings:inherit;letter-spacing:inherit;color:inherit;opacity:1;background-color:#0000;border-radius:0}:where(select:is([multiple],[size])) optgroup{font-weight:bolder}:where(select:is([multiple],[size])) optgroup option{padding-inline-start:20px}::file-selector-button{margin-inline-end:4px}::placeholder{opacity:1}@supports (not ((-webkit-appearance:-apple-pay-button))) or (contain-intrinsic-size:1px){::placeholder{color:currentColor}@supports (color:color-mix(in lab, red, red)){::placeholder{color:color-mix(in oklab, currentcolor 50%, transparent)}}}textarea{resize:vertical}::-webkit-search-decoration{-webkit-appearance:none}::-webkit-date-and-time-value{min-height:1lh;text-align:inherit}::-webkit-datetime-edit{display:inline-flex}::-webkit-datetime-edit-fields-wrapper{padding:0}::-webkit-datetime-edit{padding-block:0}::-webkit-datetime-edit-year-field{padding-block:0}::-webkit-datetime-edit-month-field{padding-block:0}::-webkit-datetime-edit-day-field{padding-block:0}::-webkit-datetime-edit-hour-field{padding-block:0}::-webkit-datetime-edit-minute-field{padding-block:0}::-webkit-datetime-edit-second-field{padding-block:0}::-webkit-datetime-edit-millisecond-field{padding-block:0}::-webkit-datetime-edit-meridiem-field{padding-block:0}::-webkit-calendar-picker-indicator{line-height:1}:-moz-ui-invalid{box-shadow:none}button,input:where([type=button],[type=reset],[type=submit]){appearance:button}::file-selector-button{appearance:button}::-webkit-inner-spin-button{height:auto}::-webkit-outer-spin-button{height:auto}[hidden]:where(:not([hidden=until-found])){display:none!important}}@layer components;@layer utilities{.collapse{visibility:collapse}.invisible{visibility:hidden}.visible{visibility:visible}.absolute{position:absolute}.fixed{position:fixed}.relative{position:relative}.container{width:100%}@media (min-width:40rem){.container{max-width:40rem}}@media (min-width:48rem){.container{max-width:48rem}}@media (min-width:64rem){.container{max-width:64rem}}@media (min-width:80rem){.container{max-width:80rem}}@media (min-width:96rem){.container{max-width:96rem}}.mx-2{margin-inline:calc(var(--spacing) * 2)}.box-content{box-sizing:content-box}.block{display:block}.contents{display:contents}.flex{display:flex}.grid{display:grid}.hidden{display:none}.inline{display:inline}.table{display:table}.field-sizing-content{field-sizing:content}.size-50{width:calc(var(--spacing) * 50);height:calc(var(--spacing) * 50)}.max-h-48{max-height:calc(var(--spacing) * 48)}.w-full{width:100%}.flex-1{flex:1}.grow{flex-grow:1}.resize{resize:both}.resize-none{resize:none}.flex-col{flex-direction:column}.flex-wrap{flex-wrap:wrap}.items-center{align-items:center}.items-stretch{align-items:stretch}.justify-end{justify-content:flex-end}.gap-1{gap:var(--spacing)}.gap-2{gap:calc(var(--spacing) * 2)}.gap-3{gap:calc(var(--spacing) * 3)}.gap-4{gap:calc(var(--spacing) * 4)}.self-center{align-self:center}.truncate{text-overflow:ellipsis;white-space:nowrap;overflow:hidden}.rounded{border-radius:.25rem}.border{border-style:var(--tw-border-style);border-width:1px}.p-1{padding:var(--spacing)}.px-4{padding-inline:calc(var(--spacing) * 4)}.px-6{padding-inline:calc(var(--spacing) * 6)}.py-2{padding-block:calc(var(--spacing) * 2)}.pt-1{padding-top:var(--spacing)}.pb-2{padding-bottom:calc(var(--spacing) * 2)}.pb-6{padding-bottom:calc(var(--spacing) * 6)}.text-sm{font-size:var(--text-sm);line-height:var(--tw-leading,var(--text-sm--line-height))}.font-medium{--tw-font-weight:var(--font-weight-medium);font-weight:var(--font-weight-medium)}.lowercase{text-transform:lowercase}.overline{text-decoration-line:overline}.opacity-70{opacity:.7}.opacity-80{opacity:.8}.shadow{--tw-shadow:0 1px 3px 0 var(--tw-shadow-color,#0000001a), 0 1px 2px -1px var(--tw-shadow-color,#0000001a);box-shadow:var(--tw-inset-shadow), var(--tw-inset-ring-shadow), var(--tw-ring-offset-shadow), var(--tw-ring-shadow), var(--tw-shadow)}.ring{--tw-ring-shadow:var(--tw-ring-inset,) 0 0 0 calc(1px + var(--tw-ring-offset-width)) var(--tw-ring-color,currentcolor);box-shadow:var(--tw-inset-shadow), var(--tw-inset-ring-shadow), var(--tw-ring-offset-shadow), var(--tw-ring-shadow), var(--tw-shadow)}.outline{outline-style:var(--tw-outline-style);outline-width:1px}.blur{--tw-blur:blur(8px);filter:var(--tw-blur,) var(--tw-brightness,) var(--tw-contrast,) var(--tw-grayscale,) var(--tw-hue-rotate,) var(--tw-invert,) var(--tw-saturate,) var(--tw-sepia,) var(--tw-drop-shadow,)}.filter{filter:var(--tw-blur,) var(--tw-brightness,) var(--tw-contrast,) var(--tw-grayscale,) var(--tw-hue-rotate,) var(--tw-invert,) var(--tw-saturate,) var(--tw-sepia,) var(--tw-drop-shadow,)}.transition{transition-property:color,background-color,border-color,outline-color,text-decoration-color,fill,stroke,--tw-gradient-from,--tw-gradient-via,--tw-gradient-to,opacity,box-shadow,transform,translate,scale,rotate,filter,-webkit-backdrop-filter,backdrop-filter,display,content-visibility,overlay,pointer-events;transition-timing-function:var(--tw-ease,var(--default-transition-timing-function));transition-duration:var(--tw-duration,var(--default-transition-duration))}}@property --tw-border-style{syntax:"*";inherits:false;initial-value:solid}@property --tw-font-weight{syntax:"*";inherits:false}@property --tw-shadow{syntax:"*";inherits:false;initial-value:0 0 #0000}@property --tw-shadow-color{syntax:"*";inherits:false}@property --tw-shadow-alpha{syntax:"<percentage>";inherits:false;initial-value:100%}@property --tw-inset-shadow{syntax:"*";inherits:false;initial-value:0 0 #0000}@property --tw-inset-shadow-color{syntax:"*";inherits:false}@property --tw-inset-shadow-alpha{syntax:"<percentage>";inherits:false;initial-value:100%}@property --tw-ring-color{syntax:"*";inherits:false}@property --tw-ring-shadow{syntax:"*";inherits:false;initial-value:0 0 #0000}@property --tw-inset-ring-color{syntax:"*";inherits:false}@property --tw-inset-ring-shadow{syntax:"*";inherits:false;initial-value:0 0 #0000}@property --tw-ring-inset{syntax:"*";inherits:false}@property --tw-ring-offset-width{syntax:"<length>";inherits:false;initial-value:0}@property --tw-ring-offset-color{syntax:"*";inherits:false;initial-value:#fff}@property --tw-ring-offset-shadow{syntax:"*";inherits:false;initial-value:0 0 #0000}@property --tw-outline-style{syntax:"*";inherits:false;initial-value:solid}@property --tw-blur{syntax:"*";inherits:false}@property --tw-brightness{syntax:"*";inherits:false}@property --tw-contrast{syntax:"*";inherits:false}@property --tw-grayscale{syntax:"*";inherits:false}@property --tw-hue-rotate{syntax:"*";inherits:false}@property --tw-invert{syntax:"*";inherits:false}@property --tw-opacity{syntax:"*";inherits:false}@property --tw-saturate{syntax:"*";inherits:false}@property --tw-sepia{syntax:"*";inherits:false}@property --tw-drop-shadow{syntax:"*";inherits:false}@property --tw-drop-shadow-color{syntax:"*";inherits:false}@property --tw-drop-shadow-alpha{syntax:"<percentage>";inherits:false;initial-value:100%}@property --tw-drop-shadow-size{syntax:"*";inherits:false}`;var Ab=["bottom-right","bottom-left","top-right","top-left"];function Dm(t){return Ab.includes(t)}function Hm(t,e=16){let r=`${e}px`;switch(t){case"bottom-right":return{right:r,bottom:r};case"bottom-left":return{left:r,bottom:r};case"top-right":return{right:r,top:r};case"top-left":return{left:r,top:r}}}function Wm(t,e,r,i,s=16){let l=Math.max(s,e-i-s),c=Math.max(s,r-i-s);return{x:Math.min(Math.max(t.x,s),l),y:Math.min(Math.max(t.y,s),c)}}function Nm(t,e,r=5){return Math.abs(e.x-t.x)>=r||Math.abs(e.y-t.y)>=r}var Ib="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined&display=block",qm="feedback-fab:position";function Vm(t){return class extends HTMLElement{constructor(){super(...arguments);N(this,"capture",null);N(this,"elm",null);N(this,"contextSent",!1);N(this,"screenshot",null);N(this,"popoverEl",null);N(this,"dragCleanup",null);N(this,"justDragged",!1);N(this,"formOpen",!1);N(this,"widgetHidden",!1);N(this,"shakeArmed",!1);N(this,"lastShake",0);N(this,"win",window);N(this,"poller",null);N(this,"onFirstInteraction",()=>this.sendContextOnce());N(this,"onPointerDown",i=>this.startDrag(i));N(this,"onClickCapture",i=>{this.justDragged&&(this.justDragged=!1,i.stopPropagation(),i.preventDefault())});N(this,"onOutsidePointerDown",i=>{if(!this.formOpen)return;let s=i.composedPath().some(c=>c instanceof Element&&c.tagName==="M3E-BOTTOM-SHEET"),l=i.composedPath().some(c=>c instanceof Element&&c.tagName==="M3E-FAB");!s&&!l&&this.elm?.ports.requestClose?.send(null)});N(this,"onDeviceMotion",i=>{if(!this.widgetHidden)return;let s=i.accelerationIncludingGravity;if(!s)return;let l=Math.abs(s.x??0)+Math.abs(s.y??0)+Math.abs(s.z??0),c=i.timeStamp;l>30&&c-this.lastShake>1e3&&(this.lastShake=c,this.elm?.ports.reopen?.send(null))})}safeOpen(i){(i.startsWith("http://")||i.startsWith("https://"))&&this.win.open(i,"_blank")}connectedCallback(){let i=Om(this);this.win=t.getWindow?.(this)??this.ownerDocument.defaultView??window;let s=this.shadowRoot??this.attachShadow({mode:"open"});if(s.querySelectorAll(".feedback-fab-popover").forEach(p=>p.remove()),!s.querySelector("style[data-feedback-fab-style]")){let p=this.ownerDocument.createElement("style");p.setAttribute("data-feedback-fab-style",""),p.textContent=`${Bm}
${Rm}`,s.appendChild(p)}let l=this.ownerDocument,c=l.querySelector("link[data-feedback-fab-font]");c||(c=l.createElement("link"),c.rel="stylesheet",c.href=Ib,c.setAttribute("data-feedback-fab-font",""),(l.head??l.documentElement).appendChild(c));let d=this.ownerDocument.createElement("div");d.setAttribute("popover","manual"),d.className="feedback-fab-popover",this.popoverEl=d,d.classList.add("ff-fonts-loading"),this.revealIconsWhenFontReady(d,c);let u=this.ownerDocument.createElement("div");if(u.setAttribute("data-feedback-fab-root",""),d.appendChild(u),s.appendChild(d),typeof d.showPopover=="function")try{d.showPopover()}catch{}this.placeInitial(i.position),d.addEventListener("pointerdown",this.onPointerDown),d.addEventListener("click",this.onClickCapture,!0),this.capture=t.installCapture(this.win,i.capture),this.elm=t.initElm({node:u}),this.elm.ports.submit.subscribe(p=>{let g={...p,...this.readTextFields(p)},m=()=>{this.clearTextFields(),this.elm?.ports.submitted?.send(null)},y=i.endpoint??this.win.location.origin,v=this.screenshot??void 0,x=Tm(g,i.fallback,{screenshot:v}),_=()=>t.submitHosted(y,x).then(S=>{t.showSnackbar("Issue created","View issue",()=>this.safeOpen(S.issueUrl))}).catch(()=>{t.showSnackbar("Couldn't file feedback","Retry",()=>{_()})});_().finally(m)}),this.elm.ports.requestScreenshot?.subscribe(()=>{t.captureScreenshot().then(p=>{this.screenshot=p,this.elm?.ports.screenshotAttached?.send(!0)}).catch(()=>this.elm?.ports.screenshotAttached?.send(!1))}),this.elm.ports.requestUpload?.subscribe(()=>{t.captureUpload().then(p=>{this.screenshot=p,this.elm?.ports.screenshotAttached?.send(!0)}).catch(()=>this.elm?.ports.screenshotAttached?.send(!1))}),this.addEventListener("click",this.onFirstInteraction),this.elm.ports.formOpened?.subscribe(p=>{this.formOpen=p,p?(this.sendContextOnce(),this.popoverEl?.setAttribute("data-open",""),this.win.document.addEventListener("pointerdown",this.onOutsidePointerDown,!0)):(this.popoverEl?.removeAttribute("data-open"),this.win.document.removeEventListener("pointerdown",this.onOutsidePointerDown,!0),this.contextSent=!1)}),this.elm.ports.setHidden?.subscribe(p=>{this.widgetHidden=p,p&&this.enableShakeToReopen()}),this.setupDashboard(i)}setupDashboard(i){let s=this.elm,l=t.flightdeck,c=i.flightdeckUrl;s?.ports.dashboardMode?.send(i.dashboardEnabled),!(!i.dashboardEnabled||!c||!l||!s)&&(s.ports.dashboardAction?.subscribe(d=>{this.runDashboardAction(l,c,i.repo,d)}),this.poller=l.createPoller({base:c,repo:i.repo,intervalMs:i.pollIntervalMs,onStatus:d=>s.ports.appStatus?.send(d),onError:()=>{}}),this.poller.start())}runDashboardAction(i,s,l,c){let d=u=>this.elm?.ports.actionResult?.send({action:c.action,pr:c.pr,ok:u});switch(c.action){case"openApp":c.url&&this.safeOpen(c.url);return;case"preview":if(c.pr===void 0)return;i.startPreview(s,l,c.pr).then(u=>{u.serveUrl&&this.safeOpen(u.serveUrl),d(!0)}).catch(()=>d(!1));return;case"merge":if(c.pr===void 0)return;i.mergePr(s,l,c.pr).then(u=>d(u.merged)).catch(()=>d(!1));return;case"restart":i.restartApp(s,l).then(u=>d(u.restarted)).catch(()=>d(!1));return}}disconnectedCallback(){this.removeEventListener("click",this.onFirstInteraction),this.popoverEl?.removeEventListener("pointerdown",this.onPointerDown),this.popoverEl?.removeEventListener("click",this.onClickCapture,!0),this.win.document.removeEventListener("pointerdown",this.onOutsidePointerDown,!0),this.win.removeEventListener("devicemotion",this.onDeviceMotion),this.dragCleanup?.(),this.dragCleanup=null,this.poller?.stop(),this.poller=null,this.capture?.uninstall(),this.capture=null,this.elm=null,this.contextSent=!1,this.screenshot=null}revealIconsWhenFontReady(i,s){let l=!1,c=()=>{l||(l=!0,i.classList.remove("ff-fonts-loading"))};this.win.setTimeout(c,2e3),s.sheet?c():(s.addEventListener("load",c,{once:!0}),s.addEventListener("error",c,{once:!0}))}readTextFields(i){let s=(l,c)=>{let d=this.popoverEl?.querySelector(`#${l}`);return d?d.value:c};return{title:s("feedback-title",i.title),description:s("feedback-description",i.description)}}clearTextFields(){for(let i of["feedback-title","feedback-description"]){let s=this.popoverEl?.querySelector(`#${i}`);s&&(s.value="",s.dispatchEvent(new Event("input",{bubbles:!0})))}}sendContextOnce(){this.contextSent||!this.capture||!this.elm||(this.contextSent=!0,this.elm.ports.context.send(this.capture.snapshot()))}enableShakeToReopen(){if(this.shakeArmed)return;this.shakeArmed=!0;let i=()=>this.win.addEventListener("devicemotion",this.onDeviceMotion),s=this.win.DeviceMotionEvent;s&&typeof s.requestPermission=="function"?s.requestPermission().then(l=>{l==="granted"&&i()}).catch(()=>{}):i()}placeInitial(i){let s=this.readStoredPosition();if(s){this.applyLeftTop(s);return}let l=Dm(i)?i:"bottom-right";this.applyInsets(Hm(l))}applyInsets(i){let s=this.popoverEl;s&&(s.style.setProperty("--ff-top",i.top??"auto"),s.style.setProperty("--ff-right",i.right??"auto"),s.style.setProperty("--ff-bottom",i.bottom??"auto"),s.style.setProperty("--ff-left",i.left??"auto"))}applyLeftTop(i){let s=this.popoverEl;s&&(s.style.setProperty("--ff-right","auto"),s.style.setProperty("--ff-bottom","auto"),s.style.setProperty("--ff-left",`${i.x}px`),s.style.setProperty("--ff-top",`${i.y}px`))}startDrag(i){let s=i.composedPath().some(x=>x instanceof Element&&x.tagName==="M3E-FAB"),l=this.popoverEl?.querySelector("m3e-fab");if(!s||!this.popoverEl||!l)return;let c=l.getBoundingClientRect(),d=Math.max(c.width,c.height)||56,u={x:i.clientX,y:i.clientY},p={x:c.left,y:c.top},g=p,m=!1,y=x=>{!m&&Nm(u,{x:x.clientX,y:x.clientY})&&(m=!0,this.popoverEl?.setAttribute("data-dragging","")),m&&(g=Wm({x:p.x+(x.clientX-u.x),y:p.y+(x.clientY-u.y)},this.win.innerWidth,this.win.innerHeight,d),this.applyLeftTop(g))},v=()=>{this.win.removeEventListener("pointermove",y),this.win.removeEventListener("pointerup",v),this.dragCleanup=null,m&&(this.justDragged=!0,this.popoverEl?.removeAttribute("data-dragging"),this.storePosition(g))};this.win.addEventListener("pointermove",y),this.win.addEventListener("pointerup",v),this.dragCleanup=v}readStoredPosition(){try{let i=this.win.localStorage.getItem(qm);if(!i)return null;let s=JSON.parse(i);if(typeof s.x=="number"&&typeof s.y=="number")return{x:s.x,y:s.y}}catch{}return null}storePosition(i){try{this.win.localStorage.setItem(qm,JSON.stringify(i))}catch{}}}}function oo(t){return typeof t=="object"&&t!==null}function dt(t,e=""){return typeof t=="string"?t:e}function er(t,e=0){return typeof t=="number"&&Number.isFinite(t)?t:e}function Cn(t,e=!1){return typeof t=="boolean"?t:e}var zb=["none","building","warm","closed"];function Um(t){return zb.includes(t)?t:"none"}function Fb(t){return oo(t)?{status:Um(t.status),url:dt(t.url)}:{status:"none",url:""}}function Ob(t){if(!oo(t))throw new Error("app-status: malformed worker");return{issue:er(t.issue),branch:dt(t.branch),status:dt(t.status)}}function Rb(t){if(!oo(t))throw new Error("app-status: malformed PR");return{number:er(t.number),title:dt(t.title),state:dt(t.state,"open"),mergeable:Cn(t.mergeable),isDraft:Cn(t.isDraft),preview:Fb(t.preview)}}function Bb(t){if(!oo(t))throw new Error("app-status: not an object");let e=t.app,r=t.counts;if(!oo(e))throw new Error("app-status: missing `app`");if(!oo(r))throw new Error("app-status: missing `counts`");let i=Array.isArray(t.workers)?t.workers.map(Ob):[],s=Array.isArray(t.prs)?t.prs.map(Rb):[];return{app:{id:typeof e.id=="string"?e.id:void 0,name:dt(e.name),running:Cn(e.running),port:er(e.port),serveUrl:dt(e.serveUrl),startedAt:dt(e.startedAt),health:dt(e.health)},counts:{openIssues:er(r.openIssues),recentFeedback:er(r.recentFeedback),workers:er(r.workers)},workers:i,prs:s}}function Hs(t){return t.replace(/\/+$/,"")}async function Db(t,e){let r=await e(t,{method:"GET"});if(!r.ok)throw new Error(`flightdeck GET failed: HTTP ${r.status}`);return r.json()}async function od(t,e,r){let i=await r(t,{method:"POST",headers:{"content-type":"application/json"},body:JSON.stringify(e)});if(!i.ok)throw new Error(`flightdeck POST failed: HTTP ${i.status}`);return i.json()}async function Hb(t,e,r=fetch){let i=`${Hs(t)}/api/app-status?repo=${encodeURIComponent(e)}`;return Bb(await Db(i,r))}async function jm(t,e,r,i=fetch){let s=await od(`${Hs(t)}/api/preview`,{repo:e,pr:r},i),l=oo(s)?s:{};return{serveUrl:dt(l.serveUrl),status:Um(l.status)}}async function Gm(t,e,r,i=fetch){let s=await od(`${Hs(t)}/api/merge`,{repo:e,pr:r},i),l=oo(s)?s:{};return{merged:Cn(l.merged),sha:dt(l.sha)}}async function Ym(t,e,r=fetch){let i=await od(`${Hs(t)}/api/restart`,{repo:e},r),s=oo(i)?i:{};return{restarted:Cn(s.restarted),serveUrl:dt(s.serveUrl)}}function Xm(t){let e=t.fetchImpl??fetch,r=t.setIntervalImpl??setInterval,i=t.clearIntervalImpl??clearInterval,s=null,l=()=>{Hb(t.base,t.repo,e).then(t.onStatus).catch(t.onError)};return{start(){s===null&&(l(),s=r(l,t.intervalMs))},stop(){s!==null&&(i(s),s=null)}}}var Zm=window.Elm?.Main;if(Zm&&typeof customElements<"u"&&!customElements.get("feedback-fab")){if(!document.querySelector("style[data-feedback-fab-guard]")){let t=document.createElement("style");t.setAttribute("data-feedback-fab-guard",""),t.textContent="feedback-fab:not(:defined){visibility:hidden}",(document.head??document.documentElement).appendChild(t)}customElements.define("feedback-fab",Vm({installCapture:Mm,submitHosted:Pm,captureScreenshot:()=>Am(window),captureUpload:()=>td(window),showSnackbar:(t,e,r)=>window.M3eSnackbar?.open(t,e,{actionCallback:r,duration:8e3}),initElm:t=>Zm.init(t),flightdeck:{createPoller:Xm,startPreview:jm,mergePr:Gm,restartApp:Ym}}))}})();
