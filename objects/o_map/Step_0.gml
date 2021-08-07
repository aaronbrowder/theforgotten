
function map_move_room(dir)
{
	transition = true;
	transition_step = 0;
	transition_direction = dir;
	needs_generation = false;
	
	map_update_open_exits();
	
	//room1_surface = surface_create(1024, 1024);
	//surface_copy(room1_surface, 0, 0, application_surface);
	
	map_assign_room();
	
	//room2_surface = surface_create(1024, 1024);
	//surface_copy(room2_surface, 0, 0, application_surface);
	
	map_move_player();
}

function map_update_open_exits()
{
	var rm = region.rooms[# posx, posy];
	var ex = -1;
	if (transition_direction == directions.right)
	{
		ex = rm.exits.right;
	}
	else if (transition_direction == directions.left)
	{
		ex = rm.exits.left;
	}
	else if (transition_direction == directions.down)
	{
		ex = rm.exits.bottom;
	}
	else if (transition_direction == directions.up)
	{
		ex = rm.exits.top;
	}
	if (ex.exit_type == exit_types.open)
	{
		ex.exit_type = exit_types.fixed;
		region.open_exits--;
	}
}

function map_assign_room()
{
	if (transition_direction == directions.right)
	{
		posx++;
	}
	else if (transition_direction == directions.left)
	{
		posx--;
	}
	else if (transition_direction == directions.down)
	{
		posy++;
	}
	else if (transition_direction == directions.up)
	{
		posy--;
	}
	var rm = region.rooms[# posx, posy];
	needs_generation = rm == 0;
	if (rm == 0)
	{
		rm = instance_create_layer(0, 0, "Controllers", o_room);
		rm._room = room_duplicate(rm_template);
		region.rooms[# posx, posy] = rm;
		region.room_count++;
	}
	room_goto(rm._room);
}

function map_get_entrance_side(dir)
{
	if (dir == directions.right) return sides.left;
	if (dir == directions.left)  return sides.right;
	if (dir == directions.up)    return sides.bottom;
	if (dir == directions.down)  return sides.top;
}

function map_move_player()
{
	if (transition_direction == directions.right)
	{
		o_player.x = 1 - o_player.sprite_width;
	}
	else if (transition_direction == directions.left)
	{
		o_player.x = room_w - 1;
	}
	else if (transition_direction == directions.down)
	{
		o_player.y = 1 - o_player.sprite_height;
	}
	else if (transition_direction == directions.up)
	{
		o_player.y = room_h - 1;
	}
}

if (transition)
{
	if (needs_generation)
	{
		// we can't do this in the same step that the room transition happens
		needs_generation = false;
		room_generate(region, posx, posy, map_get_entrance_side(transition_direction));
	}
	transition = false;
}

if (!transition)
{	
	if (o_player.x < 0 - o_player.sprite_width)
	{
		map_move_room(directions.left);
	}
	else if (o_player.x > room_w)
	{
		map_move_room(directions.right);
	}
	if (o_player.y < 0 - o_player.sprite_height)
	{
		map_move_room(directions.up);
	}
	else if (o_player.y > room_h)
	{
		map_move_room(directions.down);
	}
}