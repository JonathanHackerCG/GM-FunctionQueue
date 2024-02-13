/// Example Player: Step

//Instance
if (mouse_check_button_pressed(mb_left))
{
	my_fqueue.push(step_towards_point, [mouse_x, mouse_y, 4]);
	if (my_fqueue.size() == 1)
	{
		my_fqueue.push(my_fqueue.reset, undefined, undefined, my_fqueue);
	}
}

if (mouse_check_button_pressed(mb_right))
{
	my_fqueue.push(step_towards_point, [mouse_x, mouse_y, 4]);
	my_fqueue.push(function()
	{
		timer = 60;
		my_fqueue.clear_current();
	});
	my_fqueue.push(function()
	{
		timer --;
		if (timer == 0)
		{
			my_fqueue.clear_current();
		}
		return false;
	});
}

my_fqueue.update();

//Struct
if (keyboard_check_pressed(vk_space))
{
	my_struct.fqueue.push(function()
	{
		timer = 30;
	});
	my_struct.fqueue.push(function()
	{
		timer --;
		return (timer == 0);
	});
	my_struct.fqueue.push(show_debug_message, ["Timer Up!"]);
}

my_struct.fqueue.update();