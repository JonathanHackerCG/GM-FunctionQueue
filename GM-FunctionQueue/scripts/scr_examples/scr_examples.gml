function step_towards_point(_x, _y, _speed)
{
	var _dir = point_direction(x, y, _x, _y);
	var _disx = min(_speed, abs(_x - x));
	var _disy = min(_speed, abs(_y - y));
	
	x += lengthdir_x(_disx, _dir);
	y += lengthdir_y(_disy, _dir);
	
	return (_disx < _speed && _disy < _speed);
}