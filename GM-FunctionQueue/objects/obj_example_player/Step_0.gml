/// Example Player: Step

if (mouse_check_button_pressed(mb_left))
{
	var _pos = my_fqueue.get_position();
	my_fqueue.insert_pos(_pos, step_towards_point, [mouse_x, mouse_y, 4]);
	if (my_fqueue.size() == 1)
	{
		my_fqueue.insert_append(function()
		{
			my_fqueue.reset();
		});
	}
}

if (mouse_check_button_pressed(mb_right))
{
	var _pos = my_fqueue.get_position();
	my_fqueue.insert_pos(_pos, function()
	{
		timer = 60;
		my_fqueue.clear_current();
	});
	my_fqueue.insert_pos(_pos + 1, function()
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