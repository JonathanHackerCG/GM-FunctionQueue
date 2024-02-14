/// @func FunctionQueue():
/// @desc Constructor for FunctionQueue.
///	Version: February 13nd, 2024.
/// @arg	{Id.Instance|Struct} [owner] Instance or Struct. Context/scope to call functions. Default: undefined.
/// @arg	{Bool} [persistent] If the queue automatically clears when it reaches the end. Default: false.
/// @arg	{Bool} [temporary] If the queue clears items by default when they are finished. Default: false.
function FunctionQueue(_owner = undefined, _persistent = false, _temporary = false) constructor
{
	#region PRIVATE
	__items = [];
	__pos = -1;
	__pos_next = -1;
	__pos_interrupt = -1;
	__size = 0;
	
	__owner				= _owner;
	__persistent	= _persistent;
	__temporary		= _temporary;
	#endregion
	#region __Item(function, arguments, owner, temporary, tag);
	/// @func __Item(function, arguments, owner, temporary, tag);
	/// @arg	{Function}						function
	/// @arg	{Array}								arguments
	/// @arg	{ID.Instance|Struct}	owner
	/// @arg	{Bool}								temporary
	/// @arg	{String}							tag
	/// @returns {Struct.__Item}
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
	/// @func __convert_func(function, owner):
	/// @arg	{Function} function
	/// @arg	{Id.Instance|Struct} owner
	/// @returns {Function}
	static __convert_func = function(_function, _owner)
	{
		_owner ??= __owner;
		if (!is_callable(_function))	{ return _function; }
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
	
	#region set_owner(owner);
	/// @func set_owner(owner);
	/// @desc Sets an instance or struct to perform the functions.
	/// Functions queued will be called as methods attached to this instance or struct.
	/// Returns true if there is a valid owner.
	/// @arg	{Id.Instance|Struct} owner
	/// @returns {Bool}
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
	/// @func set_persistent(persistent):
	/// @desc Set if the queue automatically clears when it reaches the end.
	/// @arg	{Bool} persistent
	static set_persistent = function(_persistent)
	{
		__persistent = _persistent;
	}
	#endregion
	#region set_temporary(temporary);
	/// @func set_temporary(temporary):
	/// @desc Sets if the queue clears items by default when they are finished.
	/// @arg	{Bool} temporary
	function set_temporary(_temporary)
	{
		__temporary = _temporary;
	}
	#endregion
	
	#region size();
	/// @func size():
	/// @desc Returns the current size of the queue.
	/// @returns {Real}
	static size = function()
	{
		return __size;
	}
	#endregion
	#region empty();
	/// @func empty():
	/// @desc Returns true if the FunctionQueue is empty.
	/// @returns {Bool}
	static empty = function()
	{
		return (__size == 0);
	}
	#endregion
	#region reset();
	/// @func reset():
	/// @desc Go to the start of the FunctionQueue without changing the contents.
	static reset = function()
	{
		__pos = -1;
	}
	#endregion
	#region clear();
	/// @func clear():
	/// @desc Clear all and items, and reset to the start of the queue.
	static clear = function()
	{
		__items = [];
		__size = 0;
		reset();
	}
	#endregion
	#region print();
	/// @func print();
	/// @desc Outputs the contents of the FunctionQueue as a string. For debugging purposes only.
	/// @returns {String}
	static print = function()
	{
		if (__size == 0) { return "FunctionQueue: EMPTY"; }
		
		var _output = $"FunctionQueue (Size = {__size}):\n";
		for (var i = 0; i < __size; i++)
		{
			if (i == __pos) { _output += "> "; }
			_output += string(__items[i]) + "\n";
		}
		return string_trim_end(_output);
	}
	#endregion
	#region position();
	/// @func position():
	/// @desc Returns the current position of the FunctionQueue.
	/// @returns {Real}
	static position = function()
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
		if (__size <= 0)			{ return false; }
		if (__pos >= __size)	{ return false; }
		if (__pos == -1)			{ __pos = 0; }
		
		var _item = __items[__pos];
		var _func = _item.func;
		var _args = _item.args;
		var _pos_init = __pos;
		var _done = false;
		
		if (!is_callable(_func))
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
				if (_pos_init < __pos)
				{
					__pos--;
				}
			}
			else if (__pos == _pos_init)
			{
				__pos++;
			}
			
			if (__pos >= __size)
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
	
	#region insert(position, function, [arguments], [owner], [temporary], [tag]);
	/// @func insert(position, function, [arguments], [owner], [temporary], [tag]):
	/// @arg	{Real}								position
	/// @arg	{Function}						function
	/// @arg	{Array}								arguments
	/// @arg	{ID.Instance|Struct}	owner
	/// @arg	{Bool}								temporary
	/// @arg	{String}							tag
	static insert = function(_pos, _func, _args = undefined, _owner = undefined, _temporary = undefined, _tag = undefined)
	{
		var _func_new = __convert_func(_func, _owner);
		var _item = new __Item(_func_new, _args, _owner, _temporary, _tag);
		array_insert(__items, _pos, _item); __size++;
		if (_pos <= __pos) { __pos++; }
		return _item;
	}
	#endregion
	#region push(function, [arguments], [owner], [temporary], [tag]);
	/// @func push(function, [arguments], [owner], [temporary], [tag]):
	/// @arg	{Function}						function
	/// @arg	{Array}								arguments
	/// @arg	{ID.Instance|Struct}	owner
	/// @arg	{Bool}								temporary
	/// @arg	{String}							tag
	static push = function(_func, _args = undefined, _owner = undefined, _temporary = undefined, _tag = undefined)
	{
		var _func_new = __convert_func(_func, _owner);
		var _item = new __Item(_func_new, _args, _owner, _temporary, _tag);
		array_push(__items, _item); __size++;
		return _item;
	}
	#endregion
	//next(function, [arguments], [tag], [owner], [tag]);
		//Within the same step, next will be added incrementally?
	//interrupt(function, [arguments], [tag], [owner]);
		//Within the same step, interrupt will be added incrementally?
		
	#region goto(tag);
	/// @func goto(tag):
	/// @desc Moves the FunctionQueue forward until it reaches a matching tag.
	/// It will wrap to the start at the end of the queue.
	/// Returns true if it finds a match.
	/// @arg	{String|Any} tag
	/// @returns {Bool}
	static goto = function(_tag)
	{
		var _initial_pos = __pos;
		while (__pos < __size - 1)
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
	#region jump_back();
	/// @func jump_back():
	/// @desc Moves the queue back an amount.
	/// @arg	{Real} [amount] Default: 1
	static jump_back = function(_amount = 1)
	{
		__pos = clamp(__pos - _amount, 0, __size);
	}
	#endregion
	#region jump_forward();
	/// @func jump_forward():
	/// @desc Moves the queue forwarnd an amount.
	/// @arg	{Real} [amount] Default: 1
	static jump_forward = function(_amount = 1)
	{
		__pos = clamp(__pos + _amount, 0, __size);
	}
	#endregion

	#region ? insert_pos(pos, function, [arguments], [tag]); !
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
		__size++;
	}
	#endregion
	#region ? insert_now(function, [arguments], [tag]); !
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
		__size++;
	}
	#endregion
	#region ? insert_next(function, [arguments], [tag]); !
	/// @func insert_next(function, [arguments], [tag]):
	/// @desc Inserts a function after the current position.
	/// @arg	{Function} function
	/// @arg	{Array} [arguments]
	/// @arg	{String|Any} [tag]
	static insert_next = function(_func, _args = undefined)
	{
		var _item = new __Item(__convert_func(_func), _args, _tag);
		array_insert(__items, __pos + 1, _item);
		__size++;
	}
	#endregion
	

}