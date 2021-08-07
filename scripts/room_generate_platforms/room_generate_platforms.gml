
function room_generate_platforms(tiles, terrace_graph)
{
	var w = block_base_size * blocks_per_room_h;
	var h = block_base_size * blocks_per_room_v;
	var platforms = blank_tiles_array(w, h);
	
	// if there is a bottom exit, we need to place platforms along it
	for (var i = 0; i < w; i++)
	{
		if (!tiles[h - 1][i])
		{
			platforms[h - 1][i] = 1;
		}
	}
	
	for (var i = 0; i < ds_list_size(terrace_graph); i++)
	{
		var node = terrace_graph[| i];
		for (var j = 0; j < array_length(node.connections); j++)
		{
			var connection = node.connections[j];
			var tile1 = { row: connection.key_tile1.row - 1, col: connection.key_tile1.col };
			var tile2 = { row: connection.key_tile2.row - 1, col: connection.key_tile2.col };
			var path = rgp_find_path(tiles, tile1, tile2, false, false);
			//{
			//	var path_visualizer = instance_create_layer(0, 0, "Controllers", o_path_visualizer);
			//	with (path_visualizer)
			//	{
			//		my_path = path;
			//	}
			//}
			rgp_traverse_path(path, tiles, platforms);
		}
	}
	
	return platforms;
}

function rgp_traverse_path(path, tiles, platforms)
{
	rgp_traverse_path_part(path, tiles, platforms, 0);
	rgp_traverse_path_part(rgp_reverse_path(path), tiles, platforms, 0);
}

function rgp_traverse_path_part(path, tiles, platforms, start_pos)
{
	var w = block_base_size * blocks_per_room_h;
	var h = block_base_size * blocks_per_room_v;
	var start_row = path[start_pos].row;
	var start_col = path[start_pos].col;
	for (var i = start_pos + 1; i < array_length(path); i++)
	{
		var row = path[i].row;
		var col = path[i].col;
		if (tiles[row + 1][col] || platforms[row + 1][col])
		{
			// we're standing on a pre-existing tile or platform; start over from here
			rgp_traverse_path_part(path, tiles, platforms, i);
			break;
		}
		// figure out whether we can get here by jumping
		var bottom = max(row, start_row);
		var top = start_row - 12;
		var left = min(col, start_col);
		var right = max(col, start_col);
		var ceiling_height = (rgp_find_ceiling_height(tiles, bottom, top, left, right) - 1) * tile_size;
		var jump_height = (start_row - row) * tile_size;
		var jump_distance = abs(col - start_col) * tile_size;
		var jump = rgp_simulate_jump(ceiling_height, jump_height);
		var can_reach = jump.peak_height >= jump_height && jump.h_distance >= jump_distance;
		if (can_reach)
		{
			continue;
		}
		// we can't reach here, so we need to place a platform at an earlier step
		var step = i - 1;
		// if we started from a platform, there will be a small chance of going back 2 steps instead
		var started_on_platform = platforms[start_row + 1][start_col];
		if (started_on_platform && i > start_pos + 2 && random(1) < 0.3)
		{
			step = i - 2;
		}
		// the platform could be 1, 2, or 3 tiles wide
		var length = choose(1, 2, 2, 2, 3, 3);
		var dir = choose(1, -1);
		for (var j = 0; j < length; j++)
		{
			var r = path[step].row + 1;
			var c = path[step].col + (dir * j);
			if (r >= 0 && r < h && c >= 0 && c < w && !tiles[r][c])
			{
				platforms[@ r][@ c] = 1;
			}
		}
		// start over from this platform we've created
		rgp_traverse_path_part(path, tiles, platforms, step);
		break;
	}
}

function rgp_find_path(tiles, tile1, tile2, horizontal_first, is_retry)
{
	var w = block_base_size * blocks_per_room_h;
	var h = block_base_size * blocks_per_room_v;
	var path = [];
	var row = tile1.row;
	var col = tile1.col;
	var dest_row = tile2.row;
	var dest_col = tile2.col;
	var previous_dir = -1;
	var line_length = 1;
	var detour = 0;
	while (true)
	{
		array_push(path, { row: row, col: col });
		if (array_length(path) > 100)
		{
			throw "Pathfinding terminated because path was too long";
		}
		if (row == tile2.row && col == tile2.col)
		{
			// path complete
			return path;
		}
		var goal_dir = array_create(2, -1);
		// if we are going a long distance in a straight line, attempt a detour for
		// a more interesting path
		if (detour > 0)
		{
			if (previous_dir == directions.up)
			{
				row--;
			}
			if (previous_dir == directions.down)
			{
				row++;
			}
			if (previous_dir == directions.left)
			{
				col--;
			}
			if (previous_dir == directions.right)
			{
				col++;
			}
			detour--;
			continue;
		}
		if (!is_retry && line_length > 3)
		{
			if (previous_dir == directions.up || previous_dir == directions.down)
			{
				var top    = previous_dir == directions.up   ? row - 5 : row - 1;
				var bottom = previous_dir == directions.down ? row + 5 : row + 1;
				// try a left detour
				if (rgp_is_area_clear(tiles, top, bottom, col - 4, col))
				{
					col--;
					line_length = 1;
					detour = choose(0, 1, 2);
					previous_dir = directions.left;
					continue;
				}
				// try a right detour
				if (rgp_is_area_clear(tiles, top, bottom, col, col + 4))
				{
					col++;
					line_length = 1;
					detour = choose(0, 1, 2);
					previous_dir = directions.right;
					continue;
				}
			}
			if (previous_dir == directions.left || previous_dir == directions.right)
			{
				var left  = previous_dir == directions.left  ? col - 5 : col - 1;
				var right = previous_dir == directions.right ? col + 5 : col + 1;
				// try an up detour
				if (rgp_is_area_clear(tiles, row - 5, row, left, right))
				{
					row--;
					line_length = 1;
					detour = choose(0, 1, 2);
					previous_dir = directions.up;
					continue;
				}
				// try a down detour
				if (rgp_is_area_clear(tiles, row, row + 4, left, right))
				{
					row++;
					line_length = 1;
					detour = choose(0, 1, 2);
					previous_dir = directions.down;
					continue;
				}
			}
		}
		if (!horizontal_first)
		{
			// try going up
			if (row > dest_row && previous_dir != directions.down)
			{
				goal_dir[@ 0] = directions.up;
				if (rgp_tile_free(row - 1, col, tiles))
				{
					row--;
					if (previous_dir == directions.up) line_length++;
					else line_length = 1;
					previous_dir = directions.up;
					continue;
				}
			}
			// try going down
			if (row < dest_row && previous_dir != directions.up)
			{
				goal_dir[@ 0] = directions.down;
				if (rgp_tile_free(row + 1, col, tiles))
				{
					row++;
					if (previous_dir == directions.down) line_length++;
					else line_length = 1;
					previous_dir = directions.down;
					continue;
				}
			}
		}
		// try going left
		if (col > dest_col && previous_dir != directions.right)
		{
			goal_dir[@ 1] = directions.left;
			if (rgp_tile_free(row, col - 1, tiles))
			{
				col--;
				if (previous_dir == directions.left) line_length++;
				else line_length = 1;
				previous_dir = directions.left;
				continue;
			}
		}
		// try going right
		if (col < dest_col && previous_dir != directions.left)
		{
			goal_dir[@ 1] = directions.right;
			if (rgp_tile_free(row, col + 1, tiles))
			{
				col++;
				if (previous_dir == directions.right) line_length++;
				else line_length = 1;
				previous_dir = directions.right;
				continue;
			}
		}
		if (horizontal_first)
		{
			// try going up
			if (row > dest_row && previous_dir != directions.down)
			{
				goal_dir[@ 0] = directions.up;
				if (rgp_tile_free(row - 1, col, tiles))
				{
					row--;
					if (previous_dir == directions.up) line_length++;
					else line_length = 1;
					previous_dir = directions.up;
					continue;
				}
			}
			// try going down
			if (row < dest_row && previous_dir != directions.up)
			{
				goal_dir[@ 0] = directions.down;
				if (rgp_tile_free(row + 1, col, tiles))
				{
					row++;
					if (previous_dir == directions.down) line_length++;
					else line_length = 1;
					previous_dir = directions.down;
					continue;
				}
			}
		}
		// couldn't go directly toward the destination, so we'll have to go around
		if (goal_dir[0] == directions.up || goal_dir[0] == directions.down)
		{
			// try going left
			if (previous_dir != directions.right && col > 0 && rgp_tile_free(row, col - 1, tiles))
			{
				col--;
				if (previous_dir == directions.left) line_length++;
				else line_length = 1;
				previous_dir = directions.left;
				continue;
			}
			// try going right
			if (previous_dir != directions.left && col < w - 1 && rgp_tile_free(row, col + 1, tiles))
			{
				col++;
				if (previous_dir == directions.right) line_length++;
				else line_length = 1;
				previous_dir = directions.right;
				continue;
			}
		}
		if (goal_dir[1] == directions.left || goal_dir[1] == directions.right)
		{
			// try going up
			if (previous_dir != directions.down && row > 0 && rgp_tile_free(row - 1, col, tiles))
			{
				row--;
				if (previous_dir == directions.up) line_length++;
				else line_length = 1;
				previous_dir = directions.up;
				continue;
			}
			// try going down
			if (previous_dir != directions.up && row < h - 1 && rgp_tile_free(row + 1, col, tiles))
			{
				row++;
				if (previous_dir == directions.down) line_length++;
				else line_length = 1;
				previous_dir = directions.down;
				continue;
			}
		}
		if (!is_retry)
		{
			// we failed to find a path with this strategy, so try with the opposite strategy
			return rgp_find_path(tiles, tile1, tile2, !horizontal_first, true);
		}
		// both vertical first and horizontal first failed
		throw "Pathfinding failed";
	}
}

function rgp_tile_free(row, col, tiles)
{
	return !tiles[row][col] && (row == 0 || !tiles[row - 1][col]);
}

function rgp_find_ceiling_height(tiles, bottom, top, left, right)
{
	for (var row = bottom - 2; row >= top && row >= 0; row--)
	{
		for (var col = left; col <= right; col++)
		{
			if (tiles[row][col])
			{
				return bottom - row;
			}
		}
	}
	return bottom - top;
}

function rgp_is_area_clear(tiles, top, bottom, left, right)
{
	var w = block_base_size * blocks_per_room_h;
	var h = block_base_size * blocks_per_room_v;
	
	if (top < 0 || bottom >= h || left < 0 || right >= w)
	{
		return false;
	}
	for (var row = top; row <= bottom; row++)
	{
		for (var col = left; col <= right; col++)
		{
			if (tiles[row][col])
			{
				return false;
			}
		}
	}
	return true;
}

function rgp_simulate_jump(ceiling_height, land_height)
{
	var height = 0;
	var peak_height = 0;
	var steps = 0;
	var vsp = player_jump_speed;
	while (vsp > 0 && height < ceiling_height)
	{
		steps++;
		height += vsp;
		vsp -= player_gravity;
		if (height > ceiling_height)
		{
			height = ceiling_height;
			vsp = 0;
		}
	}
	peak_height = height;
	while (height > land_height)
	{
		steps++;
		height += vsp;
		vsp -= player_gravity;
	}
	return {
		peak_height: peak_height,
		h_distance: steps * player_walk_speed
	};
}

function rgp_reverse_path(path)
{
	var length = array_length(path);
	var reversed = array_create(length);
	for (var i = 0; i < length; i++)
	{
		reversed[@ i] = path[length - i - 1];
	}
	return reversed;
}