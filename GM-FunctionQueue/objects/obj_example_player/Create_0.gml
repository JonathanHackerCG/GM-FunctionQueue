/// Example Player: Create
my_fqueue = new FunctionQueue(id, true, false);

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