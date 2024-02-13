# GM-FunctionQueue
GM-FunctionQueue is a GameMaker data structure for calling code in order. Whenever the `update()` method is called, the FunctionQueue will call the current function in the list. If this call returns `true` or `undefined` (no return), it will immediately call the next function in the list. If instead the call returns `false` the FunctionQueue will call that function again the next time `update()` is called.

I use this FunctionQueue as a core for many systems, including cutscenes, turn based combat, command patterns, items/abilities, and animations.

# Methods

### General
Using the FunctionQueue.
* `size()` Return the current length of the FunctionQueue.
* `is_empty()` Return true if the FunctionQueue is empty.
* `reset()` Reset the FunctionQueue to the start.
* `clear()` Clear all functions and resets.
* `clear_current()` Clear the function currently being called.
* `print()` Print the contents of the FunctionQueue as a string.
* `position()` Returns the current position of the FunctionQueue.
* `update()` Call the functions in the FunctionQueue. Typically run in the step event.

### Queueing
Add functions to the FunctionQueue. The `_pos` and `_append` methods are absolute. The `_now` and `_next` methods are relative to the current position of the queue, and are usually called from within the queue itself.
* PROTOTYPE `insert_pos(pos, function, [arguments], [tag])` Insert a function at a specific position.
* `insert_append(function, [arguments], [tag])` Insert a function at the end of the queue.
* PROTOTYPE `insert_now(function, [arguments], [tag])` Insert a function at the current position, interrupting the current function.
* PROTOTYPE `insert_next(function, [arguments], [tag])` Insert a function after the current position.

### Jumping
Change the position of the FunctionQueue.
* PROTOTYPE `jump_back()` Returns to the previous function in the queue.
* PROTOTYPE `jump_forward()` Skips to the next function in the queue.
* PROTOTYPE `jump_to_tag(tag)` Skips to a matching tag in the queue. Returns true if it finds a matching tag.

# Examples

### Setup
```javascript
//CREATE
my_fqueue = new FunctionQueue(id);
```
```javascript
//STEP
my_fqueue.update();
```

### Following Points (I)
```javascript
//SCRIPT
//Defining a function to handle movement.
//Notice it returns true when it reaches the specified point.
function step_towards_point(_x, _y, _speed)
{
	var _dir = point_direction(x, y, _x, _y);
	var _disx = min(_speed, abs(_x - x));
	var _disy = min(_speed, abs(_y - y));
	
	x += lengthdir_x(_disx, _dir);
	y += lengthdir_y(_disy, _dir);
	
	return (_disx < _speed && _disy < _speed);
}
```
```javascript
//STEP
//Queueing step_towards_point when clicking the mouse.
//The instance will travel to each mouse click in order.
if (mouse_check_button_pressed(mb_left))
{
	my_fqueue.insert_append(step_towards_point, [mouse_x, mouse_y, 4]);
}
```

### Following Points (II)
This will queue a position like above, but will also wait for 60 frames once it reaches that point.
```javascript
if (mouse_check_button_pressed(mb_right))
{
	my_fqueue.insert_append(step_towards_point, [mouse_x, mouse_y, 4]);
	my_fqueue.insert_append(function() {
		timer = 60;
	});
	my_fqueue.insert_append(function() {
		timer --;
		return (timer == 0);
	});
}
```
If you have a timer system, it might look something like this. However, timers are beyond the scope of this library.
```javascript
if (mouse_check_button_pressed(mb_right))
{
	my_fqueue.insert_append(step_towards_point, [mouse_x, mouse_y, 4]);
	my_fqueue.insert_append(my_timer.start, [60]);
	my_fqueue.insert_append(my_timer.is_finished);
}
```