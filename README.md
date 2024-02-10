# GM-FunctionQueue
A GameMaker data structure for calling code in order.

I use this FunctionQueue for nearly all my systems, including cutscenes, turn based combat, command patterns, and animations.

**General** Using the FunctionQueue.
* `size()` Return the current length of the FunctionQueue.
* `is_empty()` Return true if the FunctionQueue is empty.
* `reset()` Reset the FunctionQueue to the start.
* `clear()` Clear all functions and resets.
* `clear_current()` Clear the function currently being called.
* `print()` Print the contents of the FunctionQueue as a string.
* `update()` Call the functions in the FunctionQueue. Typically run in the step event.

**Queueing** Add functions to the FunctionQueue.
* `insert_pos(pos, function, [arguments], [tag])` ...
* `insert_now(function, [arguments], [tag])` ...
* `insert_next(function, [arguments], [tag])` ...
* `insert_append(function, [arguments], [tag])` ...

**Jumping** Change the position of the FunctionQueue.
* `jump_back()` Returns to the previous function in the queue.
* `jump_forward()` Skips to the next function in the queue.
* `jump_to_tag(tag)` Skips to a matching tag in the queue. Returns true if it finds a matching tag. Otherwise has no impact.

**Examples**

Setup
```javascript
//Create
my_fqueue = new FunctionQueue(id);

//Step
my_fqueue.update();
```