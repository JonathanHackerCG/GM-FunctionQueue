# GM-FunctionQueue
FunctionQueue is a GameMaker data structure for calling code in a sequence. It can be used as a core for many systems, including cutscenes, turn based combat, command patterns, items/abilities, and animations.

The `update()` method will call the current function in the queue.
* If this call returns `true` or `undefined` (no return), it will immediately call the next function.
* If the call returns `false` the queue will call that function again the next time `update()` is called. This allows the queue to wait until certain conditions are met.

The FunctionQueue can be attached to any scope, store functions for future use, clear functions when no longer needed, traversed freely, skipped, reset, or interrupted. Any of this can even happen from within the queue itself, though you should be careful of causing infinite loops.
# Setup
* Download the latest `.yymps` from Packages and import `FunctionQueue` into your project.
* Tested for support on IDE `v2022.0.2.51` (LTS) and IDE `v2023.11.1.129` (monthly).
* If you'd like to see the examples in action, clone this repo and open the `GM-FunctionQueue.yyp` in IDE `v2023.11.1.129` (monthly).
# Methods
### FunctionQueue
* `FunctionQueue(owner, persistent, temporary)` Constructor for a new FunctionQueue.
	* `owner` Instance or Struct. The context/scope to call items. Every function in the queue will called as a method of the owner. Default: undefined.
	* `persistent` If persistent, the queue will not automatically clear when it reaches the end. Default: false.
	* `temporary` If temporary, the items in the queue will be cleared by default when they finish. Default: false.
* `update()` Call the functions in the queue. Often called in the step event.
### Properties
* `set_owner(owner)` Change the owner. Will affect items currently in the queue.
* `set_persistent(persistent)` Change if the queue is persistent. (See above).
* `set-temporary(temporary)` Change if the queue is temporary. (See above).
### General
Using the FunctionQueue.
* `size()` Return the current length of the queue.
* `empty()` Returns true if the queue is empty.
* `reset()` Go to the start of the queue without changing the contents.
* `clear()` Clear all and items, and reset to the start of the queue.
* `print()` Outputs the contents of the FunctionQueue as a string. For debugging purposes only.
### Index
* `get_index()` Returns the current index of the queue.
* `set_index(index)` Sets the current index of the queue. An index of -1 will reset the queue.
* `change_index(amount, [wrap])` Changes the current index by an amount. Can either wrap or clamp the index.
* `goto(tag, [loop])` Moves the queue forward until it reaches an item with a matching tag. If set to loop, it will wrap to the start of the queue. Returns true if it finds a match.
### Items
The following methods allow adding items into the queue. There are shared parameters for items, though the only required one is what function to call.
* `function` Function or method to call. If this is set to `undefined` the queue will skip this item.
* `[arguments]` Array of arguments to pass into the called function.
* `[owner]` Override the owner of the queue. Default: `undefined`.
* `[temporary]` Override the temporary status of the queue. Default: `undefined`.
* `[tag]` String tag to check against when calling `goto`.

<hr>

* `insert(index, function, [arguments], [owner], [temporary], [tag])` Insert item at specified index.
* `push(index, function, [arguments], [owner], [temporary], [tag])` Add item at the end of the queue.
* `interrupt(index, function, [arguments], [owner], [temporary], [tag])` Interrupt the current item with a new one. The original item will resume after this one.
* `next(index, function, [arguments], [owner], [temporary], [tag])` Insert an item immediately after the current item. Calling this method repeatedly will add each new item after the previous, until the index changes.
* `get_item(index)` Return the item (`FunctionQueue$$__Item()`) at a specified index. The above methods will also return the item as they insert them. This feature is not officially supported, but is available if you'd like finer control over your queue.
# Examples
### Basic Setup
```js
//CREATE
//Create a new FunctionQueue, bound to this instance.
//It is persistent, and not temporary.
my_fqueue = new FunctionQueue(id, true, false);
```

```js
//STEP
//Update the FunctionQueue in the step event.
my_fqueue.update();
```
### Following Points
```js
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
We can insert a point to our queue using the following code. If we want new points to be inserted immediately instead of going at the end, we'd use `interrupt` instead of `push`.
```js
//STEP
//Queueing step_towards_point when clicking the mouse.
//The instance will travel to each mouse click in order.
if (mouse_check_button_pressed(mb_left))
{
	my_fqueue.push(step_towards_point, [mouse_x, mouse_y, 4]);
}
```
Because our FunctionQueue is persistent, we can have the queue reset when it reaches the end. This way, the instance will follow all the points in a loop. To do this, we change our update call.
```js
//STEP
if (!my_fqueue.update())
{
	my_fqueue.reset();
}
```
### Interrupt Timer
We can interrupt the loop of points using `interrupt` and `next`. This will interrupt the current movement with setting the timer, then wait until that timer completes to continue. We set the `temporary` override to `true` for these two, so the delay will only happen once.
```js
if (keyboard_check_pressed(vk_space))
{
	my_fqueue.next(function()
	{
		timer = 60;
	}, undefined, undefined, true);
	my_fqueue.next(function()
	{
		timer--;
		return (timer == 0);
	}, undefined, undefined, true);
}
```
If you have a timer system, this example might look something like this. However, timers are beyond the scope of this library. However, notice we set the `owner` override for these items, so the FunctionQueue can access the scope of the timer struct.
```js
if (mouse_check_button_pressed(mb_right))
{
	my_fqueue.insert_append(my_timer.start, [60], my_timer, true);
	my_fqueue.insert_append(my_timer.is_finished, undefined, my_timer, true);
}
```
### Struct Owners
Here, we create two structs, and set one of them as the owner of a persistent global FunctionQueue. Then, after a delay, the queue prints the struct's name, sets the owner to the other struct, and resets itself. This way, the structs share the same FunctionQueue and take turns using it.
```js
///CREATE
structA = { name: "A" };
structB = { name: "B" };
structA.next = structB;
structB.next = structA;

global.struct_fqueue = new FunctionQueue(structA, true);
with (global.struct_fqueue)
{
	push(function()
	{
		timer = 60;
	});
	push(function()
	{
		timer--;
		return (timer == 0);
	});
	push(function()
	{
		show_debug_message(name);
		global.struct_fqueue.set_owner(next);
		global.struct_fqueue.reset();
	});
}
```

```js
///STEP
global.struct_fqueue.update();
```