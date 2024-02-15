/// LTS Compatability Script for FunctionQueue.
/// Implements is_callable();

#region is_callable(function):
/// @func is_callable(function);
/// @desc Returns true for methods or reals (may include other numbers on LTS).
/// @arg	{Any} function
/// @returns {Bool}
function is_callable(_function)
{
	return is_method(_function) || is_real(_function);
}
#endregion