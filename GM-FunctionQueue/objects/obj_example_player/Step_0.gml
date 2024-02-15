/// Example Player: Step

#region FunctionQueue Controls (Debug)
if (keyboard_check_pressed(ord("R")))
{
	my_fqueue.clear();
}
if (keyboard_check_pressed(vk_left))
{
	my_fqueue.change_index(-1);
}
if (keyboard_check_pressed(vk_right))
{
	my_fqueue.change_index(1);
}
#endregion

//Instance
if (mouse_check_button_pressed(mb_left))
{
	my_fqueue.push(step_towards_point, [mouse_x, mouse_y, 4]);
}

if (keyboard_check_pressed(vk_space))
{
	my_fqueue.interrupt(show_debug_message, ["Paused..."], undefined, true);
	my_fqueue.next(function()
	{
		timer = 60;
	}, undefined, undefined, true);
	my_fqueue.next(function()
	{
		timer--;
		return (timer == 0);
	}, undefined, undefined, true);
	my_fqueue.next(show_debug_message, ["Resume!"], undefined, true);
}

if (!my_fqueue.update())
{
	my_fqueue.reset();
}

//Struct
global.struct_fqueue.update();