
function room_fill_cavities(blocks, exits, tree)
{
	var exit_places = rfc_get_exit_places(exits);
	
	for (var i = 0; i < blocks_per_room_h; i++)
	{
		for (var j = 0; j < blocks_per_room_v; j++)
		{
			var block = blocks[# i, j];
			var is_dead_end = rfc_is_block_dead_end(i, j, tree);
			if (is_dead_end && choose(true, true, false))
			{
				rfc_fill_block(block);
				continue;
			}
			var is_cavity = rfc_is_block_cavity(block, i, j, tree, exit_places);
			if (is_cavity)
			{
				rfc_fill_block(block);
			}
		}
	}
}

function rfc_get_exit_places(exits)
{
	var exit_places = [];
	if (exits.top.exit_type != exit_types.no_exit)
	{
		array_push(exit_places, { xx: exits.top.xx, yy: 0 });
	}
	if (exits.bottom.exit_type != exit_types.no_exit)
	{
		array_push(exit_places, { xx: exits.bottom.xx, yy: 2 });
	}
	if (exits.left.exit_type != exit_types.no_exit)
	{
		array_push(exit_places, { xx: 0, yy: exits.left.yy });
	}
	if (exits.right.exit_type != exit_types.no_exit)
	{
		array_push(exit_places, { xx: 2, yy: exits.right.yy });
	}
	return exit_places;
}

function rfc_is_block_cavity(block, block_x, block_y, tree, exit_places)
{
	for (var i = 0; i < array_length(exit_places); i++)
	{
		var exit_place = exit_places[i];
		var path = room_find_path(tree, block_x, block_y, exit_place.xx, exit_place.yy, 9);
		if (path != -1)
		{
			return false;
		}
	}
	return true;
}

function rfc_is_block_dead_end(block_x, block_y, tree)
{	
	var left_open   = tree.h_borders[# block_x,     block_y] == border_types.open;
	var right_open  = tree.h_borders[# block_x + 1, block_y] == border_types.open;
	var top_open    = tree.v_borders[# block_x,     block_y] == border_types.open;
	var bottom_open = tree.v_borders[# block_x, block_y + 1] == border_types.open;
	
	var open_count = 0;
	if (left_open)   open_count++;
	if (right_open)  open_count++;
	if (top_open)    open_count++;
	if (bottom_open) open_count++;
	
	return open_count <= 1;
}

function rfc_fill_block(block)
{
	for (var row = 0; row < block_base_size; row++)
	{
		for (var col = 0; col < block_base_size; col++)
		{
			block[@ row][@ col] = 1;
		}
	}
}