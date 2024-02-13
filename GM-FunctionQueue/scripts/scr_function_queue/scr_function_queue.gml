/// @func FunctionQueue():
/// @desc Constructor for FunctionQueue.
///	Last updated on February 2nd, 2024.
/// @arg	{Id.Instance} [owner]
function FunctionQueue(_owner = noone) constructor
{
	#region PRIVATE
	__items = [];
	__instance = _owner;
	__pos = -1;
	__pos_next_offset = 1;
	__length = 0;
	#endregion
	#region __Item(function, arguments, tag);
	/// @func __Item(function, arguments, tag);
	/// @arg	{Function} function
	/// @arg	{Array} arguments
	/// @arg	{String|Any} tag
	static __Item = function(_function, _arguments, _tag) constructor
	{
		func = _function;
		args = _arguments;
		tag  = _tag;
	}
	#endregion
	#region __convert_func(function);
	/// @func __convert_func(function):
	/// @returns {Function|String}
	static __convert_func = function(_function)
	{
		if (__instance != undefined && instance_exists(__instance))
		{
			return method(__instance, _function);
		}
		return _function;
	}
	#endregion
	#region __call_function_ext(function, params);
	/// @func __call_function_ext(function, params);
	/// @desc Runs a function/method with an Array of parameters.
	/// @arg	{Function} function
	/// @arg	{Array} parameters
	/// @returns {Any}
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
	#region __set_owner(instance);
	/// @func set_owner(instance);
	/// @desc Sets an instance to perform the functions.
	/// Functions queued will be called as methods attached to this instance.
	/// @arg	{Id.Instance} instance
	static set_owner = function(_instance)
	{
		__instance = _instance;
	}
	#endregion
	
	#region size();
	/// @func size():
	/// @desc Returns the current size of the queue.
	/// @returns {Real}
	static size = function()
	{
		return __length;
	}
	#endregion
	#region is_empty();
	/// @func is_empty():
	/// @desc Returns true if the FunctionQueue is empty.
	/// @returns {Bool}
	static is_empty = function()
	{
		return (__length == 0);
	}
	#endregion
	#region reset();
	/// @func reset():
	/// @desc Go to the start of the FunctionQueue without changing the contents.
	static reset = function()
	{
		__pos = -1;
		__pos_next_offset = 1;
	}
	#endregion
	#region clear();
	/// @func clear():
	/// @desc Clear all and items, and reset to the start of the queue.
	static clear = function()
	{
		__items = [];
		__length = 0;
		reset();
	}
	#endregion
	#region clear_current();
	/// @func clear_current():
	/// @desc Cancels the current item.
	static clear_current = function()
	{
		array_delete(__items, __pos, 1);
		__pos--;
		__length--;
	}
	#endregion
	#region get_position();
	/// @func get_position():
	/// @desc Returns the current position of the FunctionQueue.
	/// @returns {Real}
	static get_position = function()
	{
		return __pos;
	}
	#endregion
	#region update();
	/// @func update();
	/// @desc Run current function and update conditionally. Returns false if the FunctionQueue is empty/idle.
	/// @returns {Bool}
	static update = function()
	{
		if (is_empty())		{ return false; }
		if (__pos == -1)	{ __pos = 0; }
		__pos_next_offset = 1;
		
		var _item = __items[__pos];
		var _func = _item.func;
		var _args = _item.args;
		var _done = false;
		var _pos_init = __pos;
		
		if (!is_callable(_func))
		{
			_done = true;
		}
		else
		{
			if (__instance != noone && !instance_exists(__instance))
			{
				return false;
			}
			_done = bool(__call_function_ext(_func, _args) ?? true);
		}
		
		if (_done && __pos == _pos_init)
		{
			__pos++;
			if (__pos >= __length)
			{
				clear();
				return false;
			}
			else
			{
				update();
			}
			return true;
		}
	}
	#endregion
	
	#region insert_pos(pos, function, [arguments], [tag]);
	/// @func insert_pos(pos, function, [arguments], [tag]);
	/// @desc Inserts a function at a position.
	/// @arg	{Real} pos
	/// @arg	{Function} function
	/// @arg	{Array} [arguments]
	/// @arg	{String|Any} [tag]
	static insert_pos = function(_pos, _func, _args = undefined, _tag = undefined)
	{
		var _item = new __Item(__convert_func(_func), _args, _tag);
		array_insert(__items, _pos, _item);
		__length++;
	}
	#endregion
	#region insert_append(function, [arguments], [tag]);
	/// @func insert_append(function, [arguments], [tag]):
	/// @desc Inserts a function at the end of the FunctionQueue.
	/// @arg	{Function} function
	/// @arg	{Array} [arguments]
	/// @arg	{String|Any} [tag]
	static insert_append = function(_func, _args = undefined, _tag = undefined)
	{
		var _item = new __Item(__convert_func(_func), _args, _tag);
		array_push(__items, _item);
		__length++;
	}
	#endregion
	#region insert_now(function, [arguments], [tag]);
	/// @func insert_now(function, [arguments], [tag]):
	/// @desc Inserts a function before the current position, interrupting the current function.
	/// @arg	{Function} function
	/// @arg	{Array} [arguments]
	/// @arg	{String|Any} [tag]
	static insert_now = function(_func, _args = undefined, _tag = undefined)
	{
		var _item = new __Item(__convert_func(_func), _args, _tag);
		if (__pos == -1) { __pos = 0; }
		array_insert(__items, __pos, _item);
		__length++;
	}
	#endregion
	#region insert_next(function, [arguments], [tag]);
	/// @func insert_next(function, [arguments], [tag]):
	/// @desc Inserts a function after the current position.
	/// @arg	{Function} function
	/// @arg	{Array} [arguments]
	/// @arg	{String|Any} [tag]
	static insert_next = function(_func, _args = undefined, _tag = undefined)
	{
		var _item = new __Item(__convert_func(_func), _args, _tag);
		array_insert(__items, __pos + __pos_next_offset, _item);
		__pos_next_offset++;
		__length++;
	}
	#endregion
	
	#region jump_back();
	/// @func jump_back():
	/// @desc Moves the queue back an amount (1 by default).
	/// @arg	{Real} [amount]
	static jump_back = function(_amount = 1)
	{
		__pos = clamp(__pos - _amount, 0, __length);
	}
	#endregion
	#region jump_forward();
	/// @func jump_forward():
	/// @desc Moves the queue forwarnd an amount (1 by default).
	/// @arg	{Real} [amount]
	static jump_forward = function(_amount = 1)
	{
		__pos = clamp(__pos + _amount, 0, __length);
	}
	#endregion
	//jump_to_position()
	#region jump_to_tag(tag);
	/// @func jump_to_tag(tag):
	/// @desc Moves the FunctionQueue forward until it reaches a matching tag.
	/// It will wrap to the start at the end of the queue.
	/// Returns true if it finds a match.
	/// @arg	{String|Any} tag
	/// @returns {Bool}
	static jump_to_tag = function(_tag)
	{
		var _initial_pos = __pos;
		while (__pos < __length - 1)
		{
			__pos ++;
			var _item = __items[__pos];
			if (_item.tag == _tag)
			{
				return true;
			}
		}
		__pos = -1;
		while (__pos < _initial_pos)
		{
			__pos ++;
			var _item = __items[__pos];
			if (_item.tag == _tag)
			{
				return true;
			}
		}
		return false;
	}
	#endregion
	
	#region print();
	/// @func print();
	/// @desc Outputs the contents of the FunctionQueue as a string. For debugging purposes only.
	/// @returns {String}
	static print = function()
	{
		if (__length == 0) { return "FunctionQueue: EMPTY"; }
		
		var _output = $"FunctionQueue (Size = {__length}):\n";
		for (var i = 0; i < __length; i++)
		{
			if (i == __pos) { _output += "> "; }
			_output += string(__items[i]) + "\n";
		}
		return string_trim_end(_output);
	}
	#endregion
}