# GM-FunctionQueue
A GameMaker data structure for calling code in order.

`size()` Returns the current length of the FunctionQueue.
`is_empty()` Returns true if the FunctionQueue is empty.
`reset()` Reset the FunctionQueue to the start.
`clear()` Clear all functions and resets.
`clear_current()` Clear the function currently being called.

`update()` Call the functions in the FunctionQueue. Typically run in the step event.
`insert_...` etc

`jump_back()` Returns to the previous function in the queue.
`jump_forward()` Skips to the next function in the queue.
`jump_to_tag(tag)` Skips to a matching tag in the queue. Returns true if it finds a matching tag. Otherwise has no impact.

`print()` Print the contents of the FunctionQueue. Only for debugging.