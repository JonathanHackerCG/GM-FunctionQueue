/// Feather ignore all

/// @func FunctionQueue():
/// @desc Constructor for FunctionQueue.
///	Version: February 15, 2024. https://github.com/JonathanHackerCG/GM-FunctionQueue
/// @arg	{Id.Instance|Struct} [owner] Instance or Struct. Context/scope to call functions. Default: undefined.
/// @arg	{Bool} [persistent]	If persistent, the queue will not automatically clear when it reaches the end. Default: false.
/// @arg	{Bool} [temporary]	If temporary, the items in the queue will be cleared by default when they finish. Default: false.
function FunctionQueue(_owner = undefined, _persistent = false, _temporary = false) constructor
{
	#region PRIVATE
	__items = [];
	__index = -1;
	__index_next = 0;
	__size = 0;
	
	__owner				= _owner;
	__persistent	= _persistent;
	__temporary		= _temporary;
	#endregion
	#region __Item(function, arguments, owner, temporary, tag);
	/// @arg	{Function}						function
	/// @arg	{Array}								arguments
	/// @arg	{ID.Instance|Struct}	owner
	/// @arg	{Bool}								temporary
	/// @arg	{String}							tag
	/// @returns {Struct.__Item}
	/// @context FunctionQueue
	static __Item = function(_function, _arguments, _owner, _temporary, _tag) constructor
	{
		func	= _function;
		args	= _arguments;
		owner	= _owner;
		temp	= _temporary;
		tag		= _tag;
	}
	#endregion
	#region __convert_func(function, owner);
	/// @arg	{Function} function
	/// @arg	{Id.Instance|Struct} owner
	/// @returns {Function}
	/// @context FunctionQueue
	static __convert_func = function(_function, _owner)
	{
		_owner ??= __owner;
		try
		{
			if (is_undefined(_function))	{ return _function; }
			if (_owner == undefined)			{ return _function; }
			if (instance_exists(_owner))
			{
				return method(_owner, _function);
			}
			if (is_struct(_owner))
			{
				return method(_owner, _function);
			}
			return _function;
		}
		catch (_exception)
		{
			show_error("FunctionQueue invalid function \"" + string(_function) + "\"\nExpected a callable function, method, or undefined.", true);
		}
	}
	#endregion
	#region __call_function_ext(function, params);
	/// @desc Runs a function/method with an Array of parameters.
	/// @arg	{Function} function
	/// @arg	{Array} parameters
	/// @returns {Any}
	/// @context FunctionQueue
	function __call_function_ext(_function, _args)
	{
		if (is_undefined(_args))
		{
			return _function();
		}
	
		var _size = array_length(_args);
		switch(_size)
		{
			case 0:  return _function();
			case 1:  return _function(_args[0]);
			case 2:  return _function(_args[0], _args[1]);
			case 3:  return _function(_args[0], _args[1], _args[2]);
			case 4:  return _function(_args[0], _args[1], _args[2], _args[3]);
			case 5:  return _function(_args[0], _args[1], _args[2], _args[3], _args[4]);
			case 6:  return _function(_args[0], _args[1], _args[2], _args[3], _args[4], _args[5]);
			case 7:  return _function(_args[0], _args[1], _args[2], _args[3], _args[4], _args[5], _args[6]);
			case 8:  return _function(_args[0], _args[1], _args[2], _args[3], _args[4], _args[5], _args[6], _args[7]);
			case 9:  return _function(_args[0], _args[1], _args[2], _args[3], _args[4], _args[5], _args[6], _args[7], _args[8]);
			case 10: return _function(_args[0], _args[1], _args[2], _args[3], _args[4], _args[5], _args[6], _args[7], _args[8], _args[9]);
			case 11: return _function(_args[0], _args[1], _args[2], _args[3], _args[4], _args[5], _args[6], _args[7], _args[8], _args[9], _args[10]);
			case 12: return _function(_args[0], _args[1], _args[2], _args[3], _args[4], _args[5], _args[6], _args[7], _args[8], _args[9], _args[10], _args[11]);
			default: show_error("Too many parameters for __call_function_ext.", false); return false;
		}
	}
	#endregion
	#region __wrap(value, min, max);
	/// @desc Returns a value, wrapping it between two values.
	/// CREDIT: GMLscripts.com/license
	/// @arg	{Real} value
	/// @arg	{Real} min
	/// @arg	{Real} max
	/// @returns {Real}
	/// @context FunctionQueue
	function __wrap(_value, _min, _max)
	{
		if (_max - _min == 0) { return _min; }
		var _mod = (_value - _min) % (_max - _min);
		if (_mod < 0) { return _mod + _max }
		else { return _mod + _min };
	}
	#endregion
	
	#region update();
	/// @desc Run current function and update conditionally. Returns false if the FunctionQueue is empty/idle.
	/// @returns {Bool}
	/// @context FunctionQueue
	static update = function()
	{
		if (__size <= 0)				{ return false; }
		if (__index >= __size)	{ return false; }
		if (__index == -1)			{ __index = 0;  }
		
		var _item = __items[__index];
		var _func = _item.func;
		var _args = _item.args;
		var _pos_init = __index;
		var _done = false;
		
		if (is_undefined(_func))
		{
			_done = true;
		}
		else
		{
			if (!is_undefined(__owner) && !instance_exists(__owner))
			{
				return false;
			}
			_done = bool(__call_function_ext(_func, _args) ?? true);
		}
		
		if (_done)
		{
			if (_item.temp ?? __temporary)
			{
				array_delete(__items, _pos_init, 1);
				__size--;
				if (_pos_init < __index)
				{
					__index--;
				}
			}
			else if (__index == _pos_init)
			{
				__index++;
				__index_next = 0;
			}
			
			if (__index >= __size)
			{
				if (!__persistent) { clear(); }
				return false;
			}
			else
			{
				update();
			}
		}
		return true;
	}
	#endregion
	
	#region set_owner(owner);
	/// @desc Sets an instance or struct to perform the functions.
	/// Functions queued will be called as methods attached to this instance or struct.
	/// Returns true if there is a valid owner.
	/// @arg	{Id.Instance|Struct} owner
	/// @returns {Bool}
	/// @context FunctionQueue
	static set_owner = function(_owner)
	{
		var _owner_previous = __owner;
		
		var _valid = false;
		if (instance_exists(_owner))
		{
			__owner = _owner;
			_valid = true;
		}
		else if (is_struct(_owner) && !is_method(_owner))
		{
			__owner = _owner;
			_valid = true;
		}
		
		if (_valid && __owner != _owner_previous)
		{
			for (var i = 0; i < __size; i++)
			{
				var _item = __items[i];
				if (is_undefined(_item.owner))
				{
					_item.func = __convert_func(_item.func, __owner);
				}
			}
		}
		return _valid;
	}
	#endregion
	#region set_persistent(persistent);
	/// @desc Set if the queue automatically clears when it reaches the end.
	/// @arg	{Bool} persistent
	/// @context FunctionQueue
	static set_persistent = function(_persistent)
	{
		__persistent = _persistent;
	}
	#endregion
	#region set_temporary(temporary);
	/// @desc Sets if the queue clears items by default when they are finished.
	/// @arg	{Bool} temporary
	/// @context FunctionQueue
	function set_temporary(_temporary)
	{
		__temporary = _temporary;
	}
	#endregion
	
	#region size();
	/// @desc Returns the current size of the FunctionQueue.
	/// @returns {Real}
	/// @context FunctionQueue
	static size = function()
	{
		return __size;
	}
	#endregion
	#region empty();
	/// @desc Returns true if the FunctionQueue is empty.
	/// @returns {Bool}
	/// @context FunctionQueue
	static empty = function()
	{
		return (__size == 0);
	}
	#endregion
	#region reset();
	/// @desc Go to the start of the FunctionQueue without changing the contents.
	/// @context FunctionQueue
	static reset = function()
	{
		__index = -1;
	}
	#endregion
	#region clear();
	/// @desc Clear all and items, and reset to the start of the queue.
	/// @context FunctionQueue
	static clear = function()
	{
		__items = [];
		__size = 0;
		reset();
	}
	#endregion
	#region print();
	/// @desc Outputs the contents of the FunctionQueue as a string. For debugging purposes only.
	/// @returns {String}
	/// @context FunctionQueue
	static print = function()
	{
		if (__size == 0) { return "FunctionQueue: EMPTY"; }
		
		var _output = "FunctionQueue (Size = " + string(__size) + "):\n";
		for (var i = 0; i < __size; i++)
		{
			if (i == __index) { _output += "> "; }
			_output += string(__items[i]) + "\n";
		}
		if (__index == __size)
		{
			_output += "> Waiting...";
		}
		return string_trim_end(_output);
	}
	#endregion
	
	#region get_index();
	/// @desc Returns the current index of the FunctionQueue.
	/// @returns {Real}
	/// @context FunctionQueue
	static get_index = function()
	{
		return __index;
	}
	#endregion
	#region set_index(index);
	/// @desc Sets the current index of the FunctionQueue.
	/// An index of -1 will reset the queue from the beginning.
	/// @arg	{Real} index
	/// @context FunctionQueue
	static set_index = function(_index)
	{
		if (_index == __index) { exit; }
		
		__index = clamp(_index, -1, __size);
		__index_next = 0;
	}
	#endregion
	#region change_index(amount, [wrap]);
	/// @desc Changes the current index in the FunctionQueue by an amount.
	/// @arg	{Real} amount
	/// @arg	{Bool} [wrap]		Default: true
	/// @context FunctionQueue
	static change_index = function(_amount, _wrap = true)
	{
		if (_amount == 0) { exit; }
		if (_wrap)
		{
			__index = __wrap(__index + _amount, 0, __size);
		}
		else
		{
			__index = clamp(__index + _amount, 0, __size);
		}
		__index_next = 0;
	}
	#endregion
	#region goto(tag, [loop]);
	/// @desc Moves the FunctionQueue forward until it reaches a matching tag.
	/// If set to loop, it will wrap to the start at the end of the queue.
	/// Returns true if it finds a match.
	/// @arg	{String|Any} tag
	/// @arg	{Bool} [loop] Default: false
	/// @returns {Bool}
	/// @context FunctionQueue
	static goto = function(_tag, _loop = false)
	{
		var _initial_pos = __index;
		while (__index < __size - 1)
		{
			__index ++;
			var _item = __items[__index];
			if (_item.tag == _tag)
			{
				return true;
			}
		}
		if (_loop)
		{
			__index = -1;
			while (__index < _initial_pos)
			{
				__index ++;
				var _item = __items[__index];
				if (_item.tag == _tag)
				{
					return true;
				}
			}
		}
		return false;
	}
	#endregion
	
	#region insert(index, function, [arguments], [owner], [temporary], [tag]);
	/// @desc Insert an item into the FunctionQueue at a index.
	/// @arg	{Real}								index
	/// @arg	{Function}						function
	/// @arg	{Array}								arguments
	/// @arg	{ID.Instance|Struct}	owner
	/// @arg	{Bool}								temporary
	/// @arg	{String}							tag
	/// @context FunctionQueue
	static insert = function(_pos, _func, _args = undefined, _owner = undefined, _temporary = undefined, _tag = undefined)
	{
		var _func_new = __convert_func(_func, _owner);
		var _item = new __Item(_func_new, _args, _owner, _temporary, _tag);
		array_insert(__items, _pos, _item); __size++;
		if (_pos <= __index) { __index++; }
		return _item;
	}
	#endregion
	#region push(function, [arguments], [owner], [temporary], [tag]);
	/// @desc Insert an item at the end of the FunctionQueue.
	/// @arg	{Function}						function
	/// @arg	{Array}								arguments
	/// @arg	{ID.Instance|Struct}	owner
	/// @arg	{Bool}								temporary
	/// @arg	{String}							tag
	/// @context FunctionQueue
	static push = function(_func, _args = undefined, _owner = undefined, _temporary = undefined, _tag = undefined)
	{
		var _item = insert(__size, _func, _args, _owner, _temporary, _tag);
		return _item;
	}
	#endregion
	#region interrupt(function, [arguments], [owner], [temporary], [tag]);
	/// @desc Interrupt the current item with a new one. The original item will resume after this one.
	/// @arg	{Function}						function
	/// @arg	{Array}								arguments
	/// @arg	{ID.Instance|Struct}	owner
	/// @arg	{Bool}								temporary
	/// @arg	{String}							tag
	/// @context FunctionQueue
	static interrupt = function(_func, _args = undefined, _owner = undefined, _temporary = undefined, _tag = undefined)
	{
		var _item = insert(get_index(), _func, _args, _owner, _temporary, _tag);
		change_index(-1);
		return _item;
	}
	#endregion
	#region next(function, [arguments], [owner], [temporary], [tag]);
	/// @desc Insert an item immediately after the current item.
	/// Calling this method repeatedly will add each new item after the previous, until the index changes.
	/// @arg	{Function}						function
	/// @arg	{Array}								arguments
	/// @arg	{ID.Instance|Struct}	owner
	/// @arg	{Bool}								temporary
	/// @arg	{String}							tag
	/// @context FunctionQueue
	static next = function(_func, _args = undefined, _owner = undefined, _temporary = undefined, _tag = undefined)
	{
		var _item = insert(__index + 1 + __index_next, _func, _args, _owner, _temporary, _tag);
		__index_next++;
		return _item;
	}
	#endregion
	#region get_item(index);
	/// @desc Returns an item (Struct.__Item) at an index in the FunctionQueue.
	/// This feature is not officially supported. It's available if you want to do something weird.
	/// @returns {Struct.__Item}
	/// @context FunctionQueue
	static get_item = function(_index)
	{
		return __items[_index];
	}
	#endregion
}