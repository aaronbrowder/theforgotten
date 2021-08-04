
function room_place_objects(rm)
{
	var w = block_base_size * blocks_per_room_h;
	var h = block_base_size * blocks_per_room_v;
	
	var merged = ds_grid_create(w, h);
	ds_grid_clear(merged, 0);
	
	var done = ds_grid_create(w, h);
	ds_grid_clear(done, 0);
	
	for (var block_x = 0; block_x < blocks_per_room_h; block_x++)
	{
		for (var block_y = 0; block_y < blocks_per_room_v; block_y++)
		{
			var block = rm.blocks[# block_x, block_y];
			for (var row = 0; row < block_base_size; row++)
			{
				for (var col = 0; col < block_base_size; col++)
				{
					var value = block[row][col];
					merged[# col + (block_x * block_base_size), row + (block_y * block_base_size)] = value;
				}
			}
		}
	}
	
	var tilemap = layer_tilemap_get_id(layer_get_id("Tiles"));
	var decorations_front_tilemap = layer_tilemap_get_id(layer_get_id("Decorations_Front"));
	
	for (var xx = 0; xx < w; xx++)
	{
		for (var yy = 0; yy < h; yy++)
		{
			rpo_place_tile(xx, yy, merged, tilemap, decorations_front_tilemap, w, h);
			if (merged[# xx, yy] == 1 && done[# xx, yy] == 0)
			{
				rpo_place_wall_object(xx, yy, merged, done, w, h);
			}
		}
	}
	
	ds_grid_destroy(merged);
	ds_grid_destroy(done);
}

function rpo_place_wall_object(xx, yy, merged, done, w, h)
{
	// find out how far to the right it goes
	var end_x = xx;
	for (var i = xx + 1; i < w; i++)
	{
		if (merged[# i, yy] == 1)
		{
			end_x = i;
		}
		else
		{
			break;
		}
	}
	// find out how far down it goes
	var end_y = yy;
	for (var j = yy + 1; j < h; j++)
	{
		// terminate as soon as any tile on this row is empty
		var terminate = false;
		for (var i = xx; i <= end_x; i++)
		{
			if (merged[# i, j] == 0)
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
			end_y = j;
		}
	}
	// create the wall object
	{
		var wall = instance_create_layer(xx * tile_size, yy * tile_size, "Instances", o_wall);
		wall.image_xscale = 1 + (end_x - xx);
		wall.image_yscale = 1 + (end_y - yy);
	}
	// update the "done" array
	for (var i = xx; i < end_x; i++)
	{
		for (var j = yy; j < end_y; j++)
		{
			done[# i, j] = 1;
		}
	}
}

function rpo_place_tile(xx, yy, merged, tilemap, decorations_front_tilemap, w, h)
{
	var data = rpo_get_tile_data(xx, yy, merged, w, h);
	tilemap_set(tilemap, data, xx, yy);
	
	//data = rpo_get_decorations_front_tile_data(xx, yy, merged, w, h);
	//tilemap_set(decorations_front_tilemap, data, xx, yy);
}

function rpo_get_tile_data(xx, yy, merged, w, h)
{
	var me = merged[# xx, yy];
	
	var nn = (yy == 0)     ? 1 : merged[# xx, yy - 1];
	var ss = (yy == h - 1) ? 1 : merged[# xx, yy + 1];
	var ww = (xx == 0)     ? 1 : merged[# xx - 1, yy];
	var ee = (xx == w - 1) ? 1 : merged[# xx + 1, yy];
	
	var nw = (yy == 0 || xx == 0)         ? 1 : merged[# xx - 1, yy - 1];
	var ne = (yy == 0 || xx == w - 1)     ? 1 : merged[# xx + 1, yy - 1];
	var sw = (yy == h - 1 || xx == 0)     ? 1 : merged[# xx - 1, yy + 1];
	var se = (yy == h - 1 || xx == w - 1) ? 1 : merged[# xx + 1, yy + 1];
	
	if (!me)
	{
		if (!ss || yy == h - 1)
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

function rpo_get_decorations_front_tile_data(xx, yy, merged, w, h)
{
	if (merged[# xx, yy])
	{
		return 0;
	}
	
	//var nn = (yy == 0)     ? 1 : merged[# xx, yy - 1];
	var ss = (yy == h - 1) ? 1 : merged[# xx, yy + 1];
	//var ww = (xx == 0)     ? 1 : merged[# xx - 1, yy];
	//var ee = (xx == w - 1) ? 1 : merged[# xx + 1, yy];
	
	if (!ss)
	{
		return 0;
	}
	
	//var nw = (yy == 0 || xx == 0)         ? 1 : merged[# xx - 1, yy - 1];
	//var ne = (yy == 0 || xx == w - 1)     ? 1 : merged[# xx + 1, yy - 1];
	//var sw = (yy == h - 1 || xx == 0)     ? 1 : merged[# xx - 1, yy + 1];
	//var se = (yy == h - 1 || xx == w - 1) ? 1 : merged[# xx + 1, yy + 1];

	var start_frame = irandom_range(1, 8);

	return start_frame;
}