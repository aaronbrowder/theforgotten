
function room_build_terrace_graph(blocks, tree)
{
	var tiles = merge_blocks(blocks);
	var standable_tiles = rbtg_find_standable_tiles(tiles);
	var terraces = rbtg_build_terraces(standable_tiles);
	var graph = rbtg_build_terrace_graph(terraces, tree);
	ds_list_destroy(terraces);
	return graph;
}

function rbtg_find_standable_tiles(tiles)
{
	// A standable tile is a solid tile that has at least 2 empty tiles above it.
	
	var w = block_base_size * blocks_per_room_h;
	var h = block_base_size * blocks_per_room_v;
	var standable_tiles = blank_tiles_array(w, h);
	
	for (var row = 2; row < h; row++)
	{
		for (var col = 0; col < w; col++)
		{
			if (tiles[row][col] == 1 && tiles[row - 1][col] == 0 && tiles[row - 2][col] == 0)
			{
				standable_tiles[@ row][@ col] = 1;
			}
		}
	}
	return standable_tiles;
}

function rbtg_build_terraces(standable_tiles)
{
	// A terrace is a contiguous group of standable tiles. The tiles can be adjacent horizontally
	// (as in a flat walkable area) or diagonally (as in stairsteps). The idea is that we can be
	// certain that any tile on a terrace can be reached from any other tile on the terrace.
	
	var terraces = ds_list_create();

	var w = block_base_size * blocks_per_room_h;
	var h = block_base_size * blocks_per_room_v;

	for (var row = 2; row < h; row++)
	{
		for (var col = 0; col < w; col++)
		{
			if (standable_tiles[row][col] == 1)
			{
				var terrace = array_create(1);
				terrace[0] = { row: row, col: col };
				standable_tiles[@ row][@ col] = 0;
				ds_list_add(terraces, terrace);
				
				// All terraces are a one-dimensional objects; they can continue indefinitely
				// to the left or right, but can never branch and can never be more than 1 tile tall.
				// We will take advantage of this fact by using recursion to follow the terrace
				// to the left and separately follow it to the right until we reach the end.
				rbtg_build_terrace(row, col, terrace, standable_tiles, -1);
				rbtg_build_terrace(row, col, terrace, standable_tiles, 1);
				
				// now sort so that the tiles are in order from left to right
				array_sort(terrace, function(elm1, elm2) {
					return elm1.col - elm2.col;
			    });
			}
		}
	}
	
	return terraces;
}

function rbtg_build_terrace(row, col, terrace, standable_tiles, dir)
{
	var new_col = col + dir;
	if (new_col < 0 || new_col >= block_base_size * blocks_per_room_h)
	{
		return;
	}
	for (var vstep = -1; vstep <= 1; vstep++)
	{
		var new_row = row + vstep;
		if (new_row < 0 || new_row >= block_base_size * blocks_per_room_v)
		{
			continue;
		}
		var tile = standable_tiles[new_row][new_col];
		if (tile)
		{
			array_push(terrace, { row: new_row, col: new_col });
			standable_tiles[@ new_row][@ new_col] = 0;
			rbtg_build_terrace(new_row, new_col, terrace, standable_tiles, dir);
			break;
		}
	}
}

function rbtg_build_terrace_graph(terraces, tree)
{
	// We want to make sure that every terrace is connected to every other terrace by a path.
	// However, trying to draw a path from every terrace to every other terrace could be a huge
	// amount of work if there are a lot of terraces. Instead, we'll create a graph with each
	// node representing a terrace and one or more connections to other nodes. Then we only have
	// to make sure that every terrace is connected to the graph.
	var graph = ds_list_create();
	ds_list_add(graph, { 
		terrace: terraces[| 0],
		connections: []
	});
	
	for (var max_tree_distance = 0; max_tree_distance < 9; max_tree_distance++)
	{
		for (var i = 0; i < ds_list_size(terraces); i++)
		{
			var terrace = terraces[| i];
			if (rbtg_graph_contains_terrace(graph, terrace))
			{
				continue;
			}
			// We can only add this terrace to the graph by connecting it to an existing node.
			// In order to minimize the path distance between nodes, for now we will only permit
			// connections that have a specified tree distance. So we need to check if there are
			// any nodes currently in the graph that are exactly this distance away from this
			// terrace. If there are multiple options, choose the one with the lowest straight
			// line distance.
			var best_node = -1;
			var best_result = -1;
			var best_distance = 1000;
			for (var j = 0; j < ds_list_size(graph); j++)
			{
				var node = graph[| j];
				var result = rbtg_measure_distance_between_terraces(
					terrace, node.terrace, tree, max_tree_distance
				);
				if (result != -1 && result.distance < best_distance)
				{
					best_node = node;
					best_result = result;
					best_distance = result.distance;
				}
			}
			if (best_node != -1)
			{
				var new_node = { 
					terrace: terrace,
					connections: []
				};
				ds_list_add(graph, new_node);
				array_push(new_node.connections, {
					node: best_node,
					distance: best_distance,
					key_tile1: best_result.key_tile1,
					key_tile2: best_result.key_tile2
				});
			}
			if (ds_list_size(graph) == ds_list_size(terraces))
			{
				return graph;
			}
		}
	}
	
	throw "Failed to connect all terraces to graph";
}

function rbtg_measure_distance_between_terraces(terrace1, terrace2, tree, max_tree_distance)
{
	// This function tries to draw a path between two terraces using the tree.
	// The function will fail if the tree distance between the terraces is greater than the
	// max distance specified by the parameter. Therefore, if we have checked all possible
	// paths within the max tree distance and not found a successful path, we can stop
	// looking. Once a tree path has been established, we return the straight line distance
	// from the block entrance to the target terrace.
	
	// It is possible for a terrace to span multiple blocks. This means, for example, the left
	// edge of a terrace can be 1 tree distance away from the target, while its right edge is
	// only 0 tree distance away. In this case we would want to use the right edge to represent
	// the terrace's position. If the terrace is very long, we would also want to check the
	// terrace's center tile.
	
	var key_tiles1 = rbtg_get_terrace_key_tiles(terrace1);
	var key_tiles2 = rbtg_get_terrace_key_tiles(terrace2);
	
	var best_result = -1;
	var best_distance = 1000;
	
	for (var i = 0; i < array_length(key_tiles1); i++)
	{
		var key_tile1 = key_tiles1[i];
		for (var j = 0; j < array_length(key_tiles2); j++)
		{
			var key_tile2 = key_tiles2[j];
			var distance = rbtg_measure_distance_between_key_tiles(key_tile1, key_tile2, tree, max_tree_distance);
			if (distance != -1 && distance < best_distance)
			{
				best_result = {
					distance: distance,
					key_tile1: key_tile1,
					key_tile2: key_tile2
				};
				best_distance = distance;
			}
		}
	}
	
	return best_result;
}

function rbtg_measure_distance_between_key_tiles(key_tile1, key_tile2, tree, max_tree_distance)
{
	var x1 = floor((key_tile1.col)     / block_base_size);
	var y1 = floor((key_tile1.row - 1) / block_base_size);
	var x2 = floor((key_tile2.col)     / block_base_size);
	var y2 = floor((key_tile2.row - 1) / block_base_size);
	
	var path = room_find_path(tree, x1, y1, x2, y2, max_tree_distance);
	if (path == -1)
	{
		return -1;
	}
	
	// subtract 1 because the path includes the starting block
	var path_length = array_length(path) - 1;
	
	if (path_length = 0)
	{
		// the key tiles are both in the same block
		return get_line_distance(key_tile1, key_tile2);
	}
	
	// check the end of the path
	var distance = rbtg_measure_distance_between_key_tile_and_block_boundary(
		key_tile2,
		path[path_length],
		path[path_length - 1]
	);
	
	// check the beginning of the path
	distance += rbtg_measure_distance_between_key_tile_and_block_boundary(
		key_tile1,
		path[0],
		path[1]
	);
	
	return ((path_length - 1) * 7) + distance;
}

function rbtg_measure_distance_between_key_tile_and_block_boundary(key_tile, block, adjacent_block)
{
	var measurement_point = -1;
	
	if (block.xx == adjacent_block.xx)
	{
		// vertical adjacency
		var col = (block.xx * block_base_size) + ((block_base_size - 1) / 2);
		if (block.yy < adjacent_block.yy)
		{
			// going up
			measurement_point = {
				row: (block.yy * block_base_size) + (block_base_size - 1),
				col: col
			};
		}
		else
		{
			// going down
			measurement_point = {
				row: (block.yy * block_base_size),
				col: col
			};
		}
	}
	else
	{
		// horizontal adjacency
		var row = (block.yy * block_base_size) + ((block_base_size - 1) / 2);
		if (block.xx < adjacent_block.xx)
		{
			// going left
			measurement_point = {
				row: row,
				col: (block.xx * block_base_size) + (block_base_size - 1)
			};
		}
		else
		{
			// going right
			measurement_point = {
				row: row,
				col: (block.xx * block_base_size)
			};
		}
	}
	
	return get_line_distance(measurement_point, key_tile);
}

function get_line_distance(tile1, tile2)
{
	return sqrt(
		sqr(abs(tile1.row - tile2.row)) +
		sqr(abs(tile1.col - tile2.col))
	);
}

function rbtg_get_terrace_key_tiles(terrace)
{
	var length = array_length(terrace);
	
	var key_tiles = [terrace[0]];
	
	if (length >= 2)
	{
		array_push(key_tiles, terrace[length - 1]);
	}
	
	if (length >= 13)
	{
		array_push(key_tiles, terrace[floor(length / 3)]);
		array_push(key_tiles, terrace[floor(length / 3) * 2]);
	}
	else if (length >= 9)
	{
		array_push(key_tiles, terrace[floor(length / 2)]);
	}
	
	return key_tiles;
}

function rbtg_graph_contains_terrace(graph, terrace)
{
	for (var i = 0; i < ds_list_size(graph); i++)
	{
		var node = graph[| i];
		if (node.terrace == terrace)
		{
			return true;
		}
	}
	return false;
}
