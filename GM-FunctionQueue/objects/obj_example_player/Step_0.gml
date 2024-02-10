/// Example Player: Step

if (mouse_check_button_pressed(mb_left))
{
	my_fqueue.insert_append(step_towards_point, [mouse_x, mouse_y, 4]);
}
my_fqueue.update();