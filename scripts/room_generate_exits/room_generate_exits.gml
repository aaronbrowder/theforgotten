
function room_generate_exits(region, room_x, room_y, entrance_side)
{
	var exits = {
		top: {
			exit_type: -1,
			xx: -1
		},
		bottom: {
			exit_type: -1,
			xx: -1
		},
		left: {
			exit_type: -1,
			yy: -1
		},
		right: {
			exit_type: -1,
			yy: -1
		},
	};
	
	// check pre-existing adjacent rooms
	// check above
	if (room_y > 0)
	{
		var other_room = region.rooms[# room_x, room_y - 1];
		if (other_room)
		{
			if (other_room.exits.bottom.exit_type == exit_types.no_exit)
			{
				exits.top.exit_type = exit_types.no_exit;
			}
			else
			{
				exits.top.exit_type = exit_types.fixed;
				exits.top.xx = other_room.exits.bottom.xx;
			}
		}
	}
	// check below
	if (room_y < region_height - 1)
	{
		var other_room = region.rooms[# room_x, room_y + 1];
		if (other_room)
		{
			if (other_room.exits.top.exit_type == exit_types.no_exit)
			{
				exits.bottom.exit_type = exit_types.no_exit;
			}
			else
			{
				exits.bottom.exit_type = exit_types.fixed;
				exits.bottom.xx = other_room.exits.top.xx;
			}
		}
	}
	// check left
	if (room_x > 0)
	{
		var other_room = region.rooms[# room_x - 1, room_y];
		if (other_room)
		{
			if (other_room.exits.right.exit_type == exit_types.no_exit)
			{
				exits.left.exit_type = exit_types.no_exit;
			}
			else
			{
				exits.left.exit_type = exit_types.fixed;
				exits.left.yy = other_room.exits.right.yy;
			}
		}
	}
	// check right
	if (room_x < region_width - 1)
	{
		var other_room = region.rooms[# room_x + 1, room_y];
		if (other_room)
		{
			if (other_room.exits.left.exit_type == exit_types.no_exit)
			{
				exits.right.exit_type = exit_types.no_exit;
			}
			else
			{
				exits.right.exit_type = exit_types.fixed;
				exits.right.yy = other_room.exits.left.yy;
			}
		}
	}
	
	// assign entrance
	if (entrance_side == sides.top)
	{
		exits.top.exit_type = exit_types.entrance;
		if (exits.top.xx == -1)
		{
			exits.top.xx = 1;
		}
	}
	if (entrance_side == sides.top)
	{
		exits.bottom.exit_type = exit_types.entrance;
		if (exits.bottom.xx == -1)
		{
			exits.bottom.xx = 1;
		}
	}
	if (entrance_side == sides.left)
	{
		exits.left.exit_type = exit_types.entrance;
		if (exits.left.yy == -1)
		{
			exits.left.yy = 1;
		}
	}
	if (entrance_side == sides.right)
	{
		exits.right.exit_type = exit_types.entrance;
		if (exits.right.yy == -1)
		{
			exits.right.yy = 1;
		}
	}
	
	// decide preferred number of open exits
	var min_open_exits = max(0, 3 - region.open_exits);
	var preferred_open_exits = max(min_open_exits, choose(0, 1, 1, 2, 2, 3));
	
	// assign open exits
	var open_exits = 0;
	var options = [sides.top, sides.bottom, sides.left, sides.right];
	while (open_exits < preferred_open_exits && array_length(options) > 0)
	{
		var index = irandom(array_length(options) - 1);
		var side = options[index];
		if (side == sides.top && exits.top.exit_type == -1)
		{
			open_exits++;
			exits.top.exit_type = exit_types.open;
			var x_options = [1];
			if (exits.left.yy != 0)
			{
				array_push(x_options, 0);
			}
			if (exits.right.yy != 0)
			{
				array_push(x_options, 2);
			}
			exits.top.xx = x_options[irandom(array_length(x_options) - 1)];
		}
		if (side == sides.bottom && exits.bottom.exit_type == -1)
		{
			open_exits++;
			exits.bottom.exit_type = exit_types.open;
			var x_options = [1];
			if (exits.left.yy != 2)
			{
				array_push(x_options, 0);
			}
			if (exits.right.yy != 2)
			{
				array_push(x_options, 2);
			}
			exits.bottom.xx = x_options[irandom(array_length(x_options) - 1)];
		}
		if (side == sides.left && exits.left.exit_type == -1)
		{
			open_exits++;
			exits.left.exit_type = exit_types.open;
			var y_options = [1];
			if (exits.top.xx != 0)
			{
				array_push(y_options, 0);
			}
			if (exits.bottom.xx != 0)
			{
				array_push(y_options, 2);
			}
			exits.left.yy = y_options[irandom(array_length(y_options) - 1)];
		}
		if (side == sides.right && exits.right.exit_type == -1)
		{
			open_exits++;
			exits.right.exit_type = exit_types.open;
			var y_options = [1];
			if (exits.top.xx != 2)
			{
				array_push(y_options, 0);
			}
			if (exits.bottom.xx != 2)
			{
				array_push(y_options, 2);
			}
			exits.right.yy = y_options[irandom(array_length(y_options) - 1)];
		}
		array_delete(options, index, 1);
	}
	
	return exits;
}