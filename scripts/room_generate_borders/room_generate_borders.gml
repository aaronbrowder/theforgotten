
function room_generate_borders(region, room_x, room_y, blocks, tree)
{
	var done = ds_grid_create(3, 3);
	ds_grid_clear(done, 0);
	
	for (var i = 0; i < blocks_per_room_h; i++)
	{
		for (var j = 0; j < blocks_per_room_v; j++)
		{
			var left_border_type   = tree.h_borders[# i, j];
			var right_border_type  = tree.h_borders[# i + 1, j];
			var top_border_type    = tree.v_borders[# i, j];
			var bottom_border_type = tree.v_borders[# i, j + 1];
			rgb_generate_border(
				region, room_x, room_y, blocks, i, j, done,
				left_border_type, top_border_type, bottom_border_type, sides.left
			);
			rgb_generate_border(
				region, room_x, room_y, blocks, i, j, done,
				right_border_type, top_border_type, bottom_border_type, sides.right
			);
			rgb_generate_border(
				region, room_x, room_y, blocks, i, j, done,
				top_border_type, left_border_type, right_border_type, sides.top
			);
			rgb_generate_border(
				region, room_x, room_y, blocks, i, j, done,
				bottom_border_type, left_border_type, right_border_type, sides.bottom
			);
			done[# i, j] = 1;
		}
	}
	
	ds_grid_destroy(done);
}

function rgb_generate_border(
	region, room_x, room_y, blocks, block_x, block_y, done,
	border_type, low_border_type, high_border_type, side)
{	
	var block = blocks[# block_x, block_y];
	
	var is_interior = false;
	var adjacent_block = 0;
	
	switch (side)
	{
		case sides.top:
			is_interior = block_y > 0;
			adjacent_block = rgb_find_upper_block(region, room_x, room_y, blocks, block_x, block_y, done);
		break;
		case sides.bottom:
			is_interior = block_y < blocks_per_room_v - 1;
			adjacent_block = rgb_find_lower_block(region, room_x, room_y, blocks, block_x, block_y, done);
		break;
		case sides.left:
			is_interior = block_x > 0;
			adjacent_block = rgb_find_left_block(region, room_x, room_y, blocks, block_x, block_y, done);
		break;
		case sides.right:
			is_interior = block_x < blocks_per_room_h;
			adjacent_block = rgb_find_right_block(region, room_x, room_y, blocks, block_x, block_y, done);
		break;
	}
	
	if (adjacent_block == 0)
	{
		// the border is not defined, so we get to define it
		var open_low = low_border_type == border_types.open;
		var open_high = high_border_type == border_types.open;
		
		var data = border_type == border_types.open 
			? rgb_open_border_data(is_interior, open_low, open_high)
			: rgb_closed_border_data();
			
		rgb_assign_border(block, side, data);
	}
	else
	{
		// The border is already defined by the adjacent block.
		// For borders interior to the room, we don't need to do anything.
		// For room borders, we need to match the border of the adjacent room.
		if (!is_interior)
		{
			var data = rgb_read_opposite_border(adjacent_block, side);
			rgb_assign_border(block, side, data);
		}
	}
}

function rgb_find_left_block(region, room_x, room_y, blocks, block_x, block_y, done)
{
	var adjacent_room = room_x > 0 ? region[# room_x - 1, room_y] : 0;
	
	if (block_x == 0 && adjacent_room != 0)
	{
		return adjacent_room.blocks[# blocks_per_room_h - 1, block_y];
	}
	else if (block_x > 0 && done[# block_x - 1, block_y] == 1)
	{
		return blocks[# block_x - 1, block_y];
	}
	return 0;
}

function rgb_find_right_block(region, room_x, room_y, blocks, block_x, block_y, done)
{
	var adjacent_room = room_x < region_width - 1 ? region[# room_x + 1, room_y] : 0;
	
	if (block_x == blocks_per_room_h - 1 && adjacent_room != 0)
	{
		return adjacent_room.blocks[# 0, block_y];
	}
	else if (block_x < blocks_per_room_h - 1 && done[# block_x + 1, block_y] == 1)
	{
		return blocks[# block_x + 1, block_y];
	}
	return 0;
}

function rgb_find_upper_block(region, room_x, room_y, blocks, block_x, block_y, done)
{
	var adjacent_room = room_y > 0 ? region[# room_x, room_y - 1] : 0;
	
	if (block_y == 0 && adjacent_room != 0)
	{
		return adjacent_room.blocks[# block_x, blocks_per_room_v - 1];
	}
	else if (block_y > 0 && done[# block_x, block_y - 1] == 1)
	{
		return blocks[# block_x, block_y - 1];
	}
	return 0;
}

function rgb_find_lower_block(region, room_x, room_y, blocks, block_x, block_y, done)
{
	var adjacent_room = room_y < region_height - 1 ? region[# room_x, room_y + 1] : 0;
	
	if (block_y == blocks_per_room_v - 1 && adjacent_room != 0)
	{
		return adjacent_room.blocks[# block_x, 0];
	}
	else if (block_y < blocks_per_room_v - 1 && done[# block_x, block_y + 1] == 1)
	{
		return blocks[# block_x, block_y + 1];
	}
	return 0;
}

function rgb_assign_border(block, side, data)
{
	for (var i = 0; i < array_length(data); i++)
	{
		if (side == sides.top)
		{
			rgb_set_tile(block, 0, i, data[i]);
		}
		if (side == sides.bottom)
		{
			rgb_set_tile(block, block_base_size - 1, i, data[i]);
		}
		if (side == sides.left)
		{
			rgb_set_tile(block, i, 0, data[i]);
		}
		if (side == sides.right)
		{
			rgb_set_tile(block, i, block_base_size - 1, data[i]);
		}
	}
}

function rgb_set_tile(block, row, col, value)
{
	if (block[row][col] != 1)
	{
		block[@ row][@ col] = value;
	}
}

function rgb_read_opposite_border(block, side)
{
	var data;
	for (var i = block_base_size - 1; i >= 0; i--)
	{
		if (side == sides.bottom)
		{
			data[@ i] = block[0][i];
		}
		if (side == sides.top)
		{
			data[@ i] = block[block_base_size - 1][i];
		}
		if (side == sides.right)
		{
			data[@ i] = block[i][0];
		}
		if (side == sides.left)
		{
			data[@ i] = block[i][block_base_size - 1];
		}
	}
	return data;
}

function rgb_closed_border_data()
{
	var data;
	for (var i = block_base_size - 1; i >= 0; i--)
	{
		data[i] = 1;
	}
	return data;
}

function rgb_open_border_data(is_interior, open_low, open_high)
{
	var data = rgb_closed_border_data();
	var min_width = is_interior ? 4 : 3;
	var max_width = is_interior ? block_base_size : block_base_size - 2;
	var min_x = is_interior ? 0 : 1;
	var max_x = is_interior ? block_base_size - 1 : block_base_size - 2;
	var width = irandom_range(min_width, max_width);
	var center = irandom_range(1, block_base_size - 2);
	if (is_interior)
	{
		if (open_low && open_high)
		{
			width = max_width;
		}
		else if (open_low || open_high)
		{
			width = max(width, irandom_range(min_width, max_width));
			if (open_low)
			{
				center = 1;
			}
			else
			{
				center = block_base_size - 2;
			}
		}
	}
	var dir = choose(-1, 1);
	var distance = 0;
	var open_tiles = 0;
	while (open_tiles < width)
	{
		var xx = center + (distance * dir);
		if (xx < min_x || xx > max_x)
		{
			dir = -dir;
			continue;
		}
		if (data[@ xx] == 0)
		{
			dir = -dir;
			distance++;
			continue;
		}
		data[@ xx] = 0;
		open_tiles++;
		dir = -dir;
	}
	return data;
}
