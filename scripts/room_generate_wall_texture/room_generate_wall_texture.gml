
function room_generate_wall_texture(blocks, tree)
{
	for (var i = 0; i < blocks_per_room_h; i++)
	{
		for (var j = 0; j < blocks_per_room_v; j++)
		{
			var block = blocks[# i, j];
			var safe_zone = rgwt_find_safe_zone(block, i, j, blocks, tree);
			var pseudo_safe_zone = rgwt_find_pseudo_safe_zone();
			repeat(3)
			{
				rgwt_accumulate(block, i, j, blocks, safe_zone, pseudo_safe_zone, false);
			}
			repeat(1)
			{
				rgwt_accumulate(block, i, j, blocks, safe_zone, pseudo_safe_zone, true);
			}
		}
	}
}

function rgwt_find_safe_zone(block, block_x, block_y, blocks, tree)
{	
	var safe_zone = blank_block();
	
	for (var row = 3; row < block_base_size - 3; row++)
	{
		for (var col = 3; col < block_base_size - 3; col++)
		{
			safe_zone[@ row][@ col] = 1;
		}
	}
	
	var left_border_type   = tree.h_borders[# block_x, block_y];
	var right_border_type  = tree.h_borders[# block_x + 1, block_y];
	var top_border_type    = tree.v_borders[# block_x, block_y];
	var bottom_border_type = tree.v_borders[# block_x, block_y + 1];
	
	if (left_border_type == border_types.open)
	{
		for (var row = 0; row < block_base_size; row++)
		{
			if (block[row][0] == 0)
			{
				safe_zone[@ row][@ 0] = 1;
				if (row >= 2 && row <= block_base_size - 2)
				{
					for (var col = 1; col < 3; col++)
					{
						safe_zone[@ row][@ col] = 1;
					}
				}
			}
		}
	}
	if (right_border_type == border_types.open)
	{
		for (var row = 0; row < block_base_size; row++)
		{
			if (block[row][block_base_size - 1] == 0)
			{
				safe_zone[@ row][@ block_base_size - 1] = 1;
				if (row >= 2 && row <= block_base_size - 2)
				{
					for (var col = block_base_size - 1; col > block_base_size - 4; col--)
					{
						safe_zone[@ row][@ col] = 1;
					}
				}
			}
		}
	}
	if (top_border_type == border_types.open)
	{
		for (var col = 0; col < block_base_size; col++)
		{
			if (block[0][col] == 0)
			{
				safe_zone[@ 0][@ col] = 1;
				if (col >= 2 && col <= block_base_size - 2)
				{
					for (var row = 0; row < 3; row++)
					{
						safe_zone[@ row][@ col] = 1;
					}
				}
			}
		}
	}
	if (bottom_border_type == border_types.open)
	{
		for (var col = 0; col < block_base_size; col++)
		{
			if (block[block_base_size - 1][col] == 0)
			{
				safe_zone[@ block_base_size - 1][@ col] = 1;
				if (col >= 2 && col <= block_base_size - 2)
				{
					for (var row = block_base_size - 1; row > block_base_size - 4; row--)
					{
						safe_zone[@ row][@ col] = 1;
					}
				}
			}
		}
	}
	
	return safe_zone;
}

function rgwt_find_pseudo_safe_zone()
{	
	var pseudo_safe_zone = blank_block();
	pseudo_safe_zone[@ 2][@ 3] = 1;
	pseudo_safe_zone[@ 2][@ 4] = 1;
	pseudo_safe_zone[@ 3][@ 2] = 1;
	pseudo_safe_zone[@ 3][@ 5] = 1;
	pseudo_safe_zone[@ 4][@ 2] = 1;
	pseudo_safe_zone[@ 4][@ 5] = 1;
	pseudo_safe_zone[@ 5][@ 3] = 1;
	pseudo_safe_zone[@ 5][@ 4] = 1;
	return pseudo_safe_zone;
}

function rgwt_accumulate(block, block_x, block_y, blocks, safe_zone, pseudo_safe_zone, nooks_only)
{
	var start_row = nooks_only && block_y == 0 ? 1 : 0;
	var start_col = nooks_only && block_x == 0 ? 1 : 0;
	
	var end_row = nooks_only && block_y == 2 ? block_base_size - 2 : block_base_size - 1;
	var end_col = nooks_only && block_x == 2 ? block_base_size - 2 : block_base_size - 1;
	
	for (var row = start_row; row <= end_row; row++)
	{
		for (var col = start_col; col <= end_col; col++)
		{
			if (block[row][col] == 1)
			{
				continue;
			}
			if (!nooks_only && safe_zone[row][col] == 1)
			{
				continue;
			}
			if (!nooks_only && pseudo_safe_zone[row][col] == 1 && choose(true, false))
			{
				continue;
			}
			var adjacent_tiles = 0;
			var diagonal_tiles = 0;
			// look up
			var upper_row = row > 0 ? block[row - 1] : blocks[# block_x, block_y - 1][block_base_size - 1];
			adjacent_tiles += upper_row[col];
			if (col > 0) diagonal_tiles += upper_row[col - 1];
			if (col < block_base_size - 1) diagonal_tiles += upper_row[col + 1];
			// look down
			var lower_row = row < block_base_size - 1 ? block[row + 1] : blocks[# block_x, block_y + 1][0];
			adjacent_tiles += lower_row[col];
			if (col > 0) diagonal_tiles += lower_row[col - 1];
			if (col < block_base_size - 1) diagonal_tiles += lower_row[col + 1];
			// look left
			if (col == 0)
			{
				var left_block = blocks[# block_x - 1, block_y];
				adjacent_tiles += left_block[row][block_base_size - 1];
				if (row > 0) diagonal_tiles += left_block[row - 1][block_base_size - 1];
				if (row < block_base_size - 1) diagonal_tiles += left_block[row + 1][block_base_size - 1];
			}
			else
			{
				adjacent_tiles += block[row][col - 1];
				if (row > 0) diagonal_tiles += block[row - 1][col - 1];
				if (row < block_base_size - 1) diagonal_tiles += block[row + 1][col - 1];
			}
			// look right
			if (col == block_base_size - 1)
			{
				var right_block = blocks[# block_x + 1, block_y];
				adjacent_tiles += right_block[row][0];
				if (row > 0) diagonal_tiles += right_block[row - 1][0];
				if (row < block_base_size - 1) diagonal_tiles += right_block[row + 1][0];
			}
			else
			{
				adjacent_tiles += block[row][col + 1];
				if (row > 0) diagonal_tiles += block[row - 1][col + 1];
				if (row < block_base_size - 1) diagonal_tiles += block[row + 1][col + 1];
			}
			if (adjacent_tiles == 0)
			{
				continue;
			}
			if (nooks_only)
			{
				if (adjacent_tiles >= 3)
				{
					block[@ row][@ col] = 1;
				}
			}
			else
			{
				var s = ((2 * adjacent_tiles) + diagonal_tiles) / 12;
				var probability = power(power(s, 1 / (2 * s)), 1 / wall_thickness);
				if (random(1) < probability)
				{
					block[@ row][@ col] = 1;
				}
			}
		}
	}
}