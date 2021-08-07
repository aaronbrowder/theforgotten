
function room_place_objects(tiles, platforms)
{
	var w = block_base_size * blocks_per_room_h;
	var h = block_base_size * blocks_per_room_v;
	
	var used_tiles = blank_tiles_array(w, h);
	var used_platforms = blank_tiles_array(w, h);
	
	var tilemap = layer_tilemap_get_id(layer_get_id("Tiles"));
	var platforms_tilemap = layer_tilemap_get_id(layer_get_id("Platforms"));
	var decorations_front_tilemap = layer_tilemap_get_id(layer_get_id("Decorations_Front"));
	var decorations_back_tilemap = layer_tilemap_get_id(layer_get_id("Decorations_Back"));
	
	for (var col = 0; col < w; col++)
	{
		for (var row = 0; row < h; row++)
		{
			rpo_place_tile(row, col, w, h, tiles, platforms,
				tilemap, platforms_tilemap, decorations_front_tilemap, decorations_back_tilemap
			);
			if (tiles[row][col] == 1 && used_tiles[row][col] == 0)
			{
				rpo_place_object(row, col, tiles, used_tiles, w, h, o_wall);
			}
			if (platforms[row][col] == 1 && used_platforms[row][col] == 0)
			{
				rpo_place_object(row, col, platforms, used_platforms, w, h, o_platform);
			}
		}
	}
}

function rpo_place_object(row, col, tiles, used_tiles, w, h, obj_index)
{
	// find out how far to the right it goes
	var end_col = col;
	for (var i = col + 1; i < w; i++)
	{
		if (tiles[row][i] == 1)
		{
			end_col = i;
		}
		else
		{
			break;
		}
	}
	// find out how far down it goes
	var end_row = row;
	for (var j = row + 1; j < h; j++)
	{
		// terminate as soon as any tile on this row is empty
		var terminate = false;
		for (var i = col; i <= end_col; i++)
		{
			if (tiles[j][i] == 0)
			{
				terminate = true;
				break;
			}
		}
		if (terminate)
		{
			break;
		}
		else
		{
			end_row = j;
		}
	}
	{
		var obj = instance_create_layer(col * tile_size, row * tile_size, "Instances", obj_index);
		obj.image_xscale = 1 + (end_col - col);
		obj.image_yscale = 1 + (end_row - row);
	}
	for (var i = col; i < end_col; i++)
	{
		for (var j = row; j < end_row; j++)
		{
			used_tiles[j][i] = 1;
		}
	}
}

function rpo_place_tile(row, col, w, h, tiles, platforms,
	tilemap, platforms_tilemap, decorations_front_tilemap, decorations_back_tilemap)
{
	var tile_data = rpo_get_tile_data(row, col, tiles, w, h);
	tilemap_set(tilemap, tile_data, col, row);
	
	if (platforms[row][col] && !tilemap_get(platforms_tilemap, col, row))
	{
		rpo_place_platform_tiles(row, col, w, h, tiles, platforms,
			platforms_tilemap, decorations_back_tilemap
		);
	}
	
	//data = rpo_get_decorations_front_tile_data(xx, yy, merged, w, h);
	//tilemap_set(decorations_front_tilemap, data, xx, yy);
}

function rpo_place_platform_tiles(row, col, w, h, tiles, platforms,
	platforms_tilemap, decorations_back_tilemap)
{
	// find out how far to the right the platform goes
	var width = 0;
	while (col + width < w && platforms[row][col + width])
	{
		width++;
	}
	// find out how far down the platform goes
	var height = 0;
	while (true)
	{
		height++;
		var r = row + height;
		var any = false;
		for (var i = 0; i < width; i++)
		{
			var c = col + i;
			if (r < h - 1 && !tiles[r][c])
			{
				any = true;
			}
		}
		if (!any)
		{
			break;
		}
	}
	for (var i = 0; i < width; i++)
	{
		var r = row;
		var c = col + i;
		// draw the platform top
		if (row == h - 1)
		{
			// use a faded version for the platform over a bottom exit
			tilemap_set(platforms_tilemap, 2, c, row);
		}
		else
		{
			tilemap_set(platforms_tilemap, 1, c, row);
			// draw the cosmetic dirt above the platform
			var dirt_data = 5;
			var connect_left  = c > 0     && (tiles[r - 1][c - 1] || platforms[r][c - 1] || platforms[r - 1][c - 1]);
			var connect_right = c < w - 1 && (tiles[r - 1][c + 1] || platforms[r][c + 1] || platforms[r - 1][c + 1]);
			if (connect_left && connect_right)
			{
				dirt_data = 4;
			}
			else if (connect_left)
			{
				dirt_data = 2;
			}
			else if (connect_right)
			{
				dirt_data = 1;
			}
			tilemap_set(decorations_back_tilemap, dirt_data, c, r - 1);
		}
		// draw platforms all the way down
		for (var j = 0; j < height; j++)
		{
			r = row + j;
			if (r < h - 1 && !tiles[r][c] && !platforms[r][c])
			{
				tilemap_set(platforms_tilemap, 3, c, r);
			}
		}
	}
}

function rpo_get_tile_data(row, col, tiles, w, h)
{
	var me = tiles[row][col];
	
	var nn = (row == 0)     ? 1 : tiles[row - 1][col];
	var ss = (row == h - 1) ? 1 : tiles[row + 1][col];
	var ww = (col == 0)     ? 1 : tiles[row][col - 1];
	var ee = (col == w - 1) ? 1 : tiles[row][col + 1];
	
	var nw = (row == 0 || col == 0)         ? 1 : tiles[row - 1][col - 1];
	var ne = (row == 0 || col == w - 1)     ? 1 : tiles[row - 1][col + 1];
	var sw = (row == h - 1 || col == 0)     ? 1 : tiles[row + 1][col - 1];
	var se = (row == h - 1 || col == w - 1) ? 1 : tiles[row + 1][col + 1];
	
	if (!me)
	{
		if (!ss || row == h - 1)
		{
			return 0;	
		}
		if (!ww && !sw && !ee && !se)
		{
			return 72;
		}
		if (!ww && !sw)
		{
			return 61;
		}
		if (!ee && !se)
		{
			return 62;
		}
		return 71;
	}
	
	// top edge
	if (!nn && ss && ww && ee)
	{
		// both opposite corners solid
		if (sw && se)
		{
			return 12;
		}
		// both opposite corners empty
		if (!sw && !se)
		{
			return 58;
		}
		// only left opposite corner solid
		if (sw && !se)
		{
			return 39;
		}
		// only right opposite corner solid
		if (!sw && se)
		{
			return 18;
		}
	}
	// bottom edge
	if (nn && !ss && ww && ee)
	{
		// both opposite corners solid
		if (nw && ne)
		{
			return 32;
		}
		// both opposite corners empty
		if (!nw && !ne)
		{
			return 69;
		}
		// only left opposite corner solid
		if (nw && !ne)
		{
			return 29;
		}
		// only right opposite corner solid
		if (!nw && ne)
		{
			return 48;
		}
	}
	// left edge
	if (nn && ss && !ww && ee)
	{
		// both opposite corners solid
		if (ne && se)
		{
			return 21;
		}
		// both opposite corners empty
		if (!ne && !se)
		{
			return 56;
		}
		// only upper opposite corner solid
		if (ne && !se)
		{
			return 28;
		}
		// only lower opposite corner solid
		if (!ne && se)
		{
			return 38;
		}
	}
	// right edge
	if (nn && ss && ww && !ee)
	{
		// both opposite corners solid
		if (nw && sw)
		{
			return 23;
		}
		// both opposite corners empty
		if (!nw && !sw)
		{
			return 67;
		}
		// only upper opposite corner solid
		if (nw && !sw)
		{
			return 49;
		}
		// only lower opposite corner solid
		if (!nw && sw)
		{
			return 19;
		}
	}
	// top-left corner
	if (!nn && ss && !ww && ee)
	{
		if (se)
		{
			return 11;	
		}
		else
		{
			return 54;
		}
	}
	// top-right corner
	if (!nn && ss && ww && !ee)
	{
		if (sw)
		{
			return 13;	
		}
		else
		{
			return 55;
		}
	}
	// bottom-left corner
	if (nn && !ss && !ww && ee)
	{
		if (ne)
		{
			return 31;	
		}
		else
		{
			return 64;
		}
	}
	// bottom-right corner
	if (nn && !ss && ww && !ee)
	{
		if (nw)
		{
			return 33;	
		}
		else
		{
			return 65;
		}
	}
	// full adjacency
	if (nn && ss && ww && ee)
	{
		// fully surrounded
		if (nw && ne && sw && se)
		{
			return 22;
		}
		// inverted top-left corner
		if (!nw && ne && sw && se)
		{
			return 14;
		}
		// inverted top-right corner
		if (nw && !ne && sw && se)
		{
			return 15;
		}
		// inverted bottom-left corner
		if (nw && ne && !sw && se)
		{
			return 24;
		}
		// inverted bottom-right corner
		if (nw && ne && sw && !se)
		{
			return 25;
		}
		// inverted top-left / bottom-right corners
		if (!nw && ne && sw && !se)
		{
			return 34;
		}
		// inverted top-right / bottom-left corners
		if (nw && !ne && !sw && se)
		{
			return 35;
		}
		// bottom-right fork
		if (nw && !ne && !sw && !se)
		{
			return 16;
		}
		// bottom-left fork
		if (!nw && ne && !sw && !se)
		{
			return 17;
		}
		// top-right fork
		if (!nw && !ne && sw && !se)
		{
			return 26;
		}
		// top-left fork
		if (!nw && !ne && !sw && se)
		{
			return 27;
		}
		// top limb support
		if (!nw && !ne && sw && se)
		{
			return 44;
		}
		// bottom limb support
		if (nw && ne && !sw && !se)
		{
			return 36;
		}
		// left limb support
		if (!nw && ne && !sw && se)
		{
			return 37;
		}
		// right limb support
		if (nw && !ne && sw && !se)
		{
			return 45;
		}
		// 4-way fork
		if (!nw && !ne && !sw && !se)
		{
			return 46;
		}
	}
	// horizontal bar
	if (!nn && !ss && ww && ee)
	{
		return 53;
	}
	// vertical bar
	if (nn && ss && !ww && !ee)
	{
		return 43;
	}
	// top limb
	if (!nn && ss && !ww && !ee)
	{
		return 41;
	}
	// bottom limb
	if (nn && !ss && !ww && !ee)
	{
		return 51;
	}
	// left limb
	if (!nn && !ss && !ww && ee)
	{
		return 42;
	}
	// right limb
	if (!nn && !ss && ww && !ee)
	{
		return 52;
	}
	
	return 22;
}

function rpo_get_decorations_front_tile_data(row, col, tiles, w, h)
{
	if (tiles[row][col])
	{
		return 0;
	}
	
	var ss = (row == h - 1) ? 1 : tiles[row + 1][col];
	
	if (!ss)
	{
		return 0;
	}

	var start_frame = irandom_range(1, 8);

	return start_frame;
}