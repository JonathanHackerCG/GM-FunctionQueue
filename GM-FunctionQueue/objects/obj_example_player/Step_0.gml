/// Example Player: Step

//Struct
global.struct_fqueue.update();

//Instance
if (mouse_check_button_pressed(mb_left))
{
	my_fqueue.push(step_towards_point, [mouse_x, mouse_y, 4]);
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

if (!my_fqueue.update())
{
	my_fqueue.reset();
}