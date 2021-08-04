
key_left = keyboard_check(vk_left);
key_right = keyboard_check(vk_right);
key_jump = keyboard_check(vk_space);
key_jump_pressed = keyboard_check_pressed(vk_space);

var _move = key_right - key_left;

hsp = _move * walk_speed;

vsp = vsp + grv;

// Jump
if (!key_jump)
{
	jump_start = false;
}
if (jump_start)
{
	jump_timer--;
	if (jump_timer <= 0)
	{
		jump_start = false;
	}
}
if (key_jump_pressed)
{
	jump_start = true;
	jump_timer = jump_timer_max;
}
if (place_meeting(x, y + 1, o_wall) && jump_start)
{
	vsp -= jump_speed;
}

// Short hop
if (vsp < 0 && !key_jump)
{
	vsp = vsp / 2;
}

// Horizontal collision
if (place_meeting(x + hsp, y, o_wall))
{
	while (!place_meeting(x + sign(hsp), y, o_wall))
	{
		x = x + sign(hsp);
	}
	hsp = 0;
}
x = x + hsp;

// Vertical collision
if (place_meeting(x, y + vsp, o_wall))
{
	while (!place_meeting(x, y + sign(vsp), o_wall))
	{
		y = y + sign(vsp);
	}
	vsp = 0;
}

y = y + vsp;