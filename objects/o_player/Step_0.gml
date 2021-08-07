
function player_find_platform()
{
	if (vsp < 0 || keyboard_check(vk_down))
	{
		return noone;
	}
	var platform = noone;
	var sim_vsp = max(1, vsp);
	with (o_platform)
	{
		if ((platform == noone || y > platform.y) &&
			y >= o_player.y + o_player.sprite_height - 1 &&
			place_meeting(x, y - sim_vsp, o_player))
		{
			platform = self;
		}
	}
	return platform;
}

var key_left = keyboard_check(vk_left);
var key_right = keyboard_check(vk_right);
var key_jump = keyboard_check(vk_space);
var key_jump_pressed = keyboard_check_pressed(vk_space);

var _move = key_right - key_left;

hsp = _move * walk_speed;

// short hop
if (vsp < 0 && !key_jump)
{
	vsp = vsp / 2;
}

vsp = vsp + grv;

var platform = player_find_platform();

// jump
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
if (jump_start && (platform != noone || place_meeting(x, y + 1, o_wall)))
{
	vsp = -jump_speed;
	jump_start = false;
}

// vertical collision with wall
var wall = instance_place(x, y + vsp, o_wall);
if (wall != noone)
{
	while (!place_meeting(x, y + sign(vsp), wall))
	{
		y = y + sign(vsp);
	}
	if (y < wall.y)
	{
		y = wall.y - sprite_height;
	}
	vsp = 0;
}

// vertical collision with platform
if (platform != noone && place_meeting(x, y + vsp, platform))
{
	while (!place_meeting(x, y + sign(vsp), platform))
	{
		y = y + sign(vsp);
	}
	y = platform.y - sprite_height;
	vsp = 0;
}

y = y + vsp;

// horizontal collision
if (place_meeting(x + hsp, y, o_wall))
{
	while (!place_meeting(x + sign(hsp), y, o_wall))
	{
		x = x + sign(hsp);
	}
	hsp = 0;
}
x = x + hsp;
