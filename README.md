# GM-FunctionQueue
A GameMaker data structure for calling code in order.

I use this FunctionQueue for many systems, including cutscenes, turn based combat, command patterns, items/abilities, and animations.

### General
Using the FunctionQueue.
* `size()` Return the current length of the FunctionQueue.
* `is_empty()` Return true if the FunctionQueue is empty.
* `reset()` Reset the FunctionQueue to the start.
* `clear()` Clear all functions and resets.
* `clear_current()` Clear the function currently being called.
* `print()` Print the contents of the FunctionQueue as a string.
* `update()` Call the functions in the FunctionQueue. Typically run in the step event.

### Queueing
Add functions to the FunctionQueue.
* `insert_pos(pos, function, [arguments], [tag])` ...
* `insert_now(function, [arguments], [tag])` ...
* `insert_next(function, [arguments], [tag])` ...
* `insert_append(function, [arguments], [tag])` ...

### Jumping
Change the position of the FunctionQueue.
* `jump_back()` Returns to the previous function in the queue.
* `jump_forward()` Skips to the next function in the queue.
* `jump_to_tag(tag)` Skips to a matching tag in the queue. Returns true if it finds a matching tag.

### Example
Setup
```javascript
//Create
my_fqueue = new FunctionQueue(id);

//Step
my_fqueue.update();
```

### Example
Following Points (I)
```javascript
//Script
//Defining a function to handle movement. Notice it returns true when it reaches the specified point.
function step_towards_point(_x, _y, _speed)
{
	var _dir = point_direction(x, y, _x, _y);
	var _disx = min(_speed, abs(_x - x));
	var _disy = min(_speed, abs(_y - y));
	
	x += lengthdir_x(_disx, _dir);
	y += lengthdir_y(_disy, _dir);
	
	return (_disx < _speed && _disy < _speed);
}

//Step
//Queueing step_towards_point when clicking the mouse. The instance will travel to each mouse click in order, no matter when the click happened.
if (mouse_check_button_pressed(mb_left))
{
	my_fqueue.insert_append(step_towards_point, [mouse_x, mouse_y, 4]);
}
```