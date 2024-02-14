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
	my_fqueue.insert(my_fqueue.position() - 1, step_towards_point, [mouse_x, mouse_y, 8]);
	my_fqueue.jump_back();
}

if (!my_fqueue.update())
{
	my_fqueue.reset();
}