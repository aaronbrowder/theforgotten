
function room_generate_tree(exits)
{
	var h_borders = ds_grid_create(blocks_per_room_h + 1, blocks_per_room_v);
	var v_borders = ds_grid_create(blocks_per_room_h, blocks_per_room_v + 1);
	
	ds_grid_clear(h_borders, border_types.blank);
	ds_grid_clear(v_borders, border_types.blank);
	
	var tree = {
		h_borders: h_borders,
		v_borders: v_borders
	};
	
	rgt_initialize_exits(exits, tree);
	
	var entrance = rgt_find_entrance(exits);
	
	for (var i = 0; i < blocks_per_room_h; i++)
	{
		for (var j = 0; j < blocks_per_room_v; j++)
		{
			rgt_process_block(i, j, entrance, exits, tree);
		}
	}
	
	return tree;
}

function rgt_process_block(xx, yy, entrance, exits, tree)
{
	var borders = rgt_find_block_borders(xx, yy, tree);
	if (borders.top == border_types.blank)
	{
		rgt_process_block_side(xx, yy, sides.top, borders, entrance, exits, tree);
	}
	if (borders.bottom == border_types.blank)
	{
		rgt_process_block_side(xx, yy, sides.bottom, borders, entrance, exits, tree);
	}
	if (borders.left == border_types.blank)
	{
		rgt_process_block_side(xx, yy, sides.left, borders, entrance, exits, tree);
	}
	if (borders.right == border_types.blank)
	{
		rgt_process_block_side(xx, yy, sides.right, borders, entrance, exits, tree);
	}
}

function rgt_process_block_side(xx, yy, side, borders, entrance, exits, tree)
{
	// a block cannot have more than 2 closed borders
	var must_be_open = rgt_count_closed_block_borders(borders) >= 2;
	
	if (!must_be_open)
	{
		// simulate closing the border
		rgt_set_block_border(xx, yy, side, border_types.closed, tree);
		// if closing the border violates a condition, we have to leave it open
		var must_be_open = rgt_violates_condition(entrance, exits, tree);
	}
	
	var border_type = must_be_open
		? border_types.open
		: (random(1) <= room_openness ? border_types.open : border_types.closed);
		
	rgt_set_block_border(xx, yy, side, border_type, tree);
}

function rgt_violates_condition(entrance, exits, tree)
{
	if (exits.top.exit_type != exit_types.no_exit)
	{
		if (!rgt_find_path(entrance, exits.top.xx, 0, tree))
		{
			return true;
		}
	}
	if (exits.bottom.exit_type != exit_types.no_exit)
	{
		if (!rgt_find_path(entrance, exits.bottom.xx, 2, tree))
		{
			return true;
		}
	}
	if (exits.left.exit_type != exit_types.no_exit)
	{
		if (!rgt_find_path(entrance, 0, exits.left.yy, tree))
		{
			return true;
		}
	}
	if (exits.right.exit_type != exit_types.no_exit)
	{
		if (!rgt_find_path(entrance, 2, exits.right.yy, tree))
		{
			return true;
		}
	}
	return false;
}

function rgt_find_block_borders(xx, yy, tree)
{
	return {
		top: tree.v_borders[# xx, yy],
		bottom: tree.v_borders[# xx, yy + 1],
		left: tree.h_borders[# xx, yy],
		right: tree.h_borders[# xx + 1, yy]
	};
}

function rgt_count_closed_block_borders(borders)
{
	var count = 0;
	if (borders.top    == border_types.closed) count++;
	if (borders.bottom == border_types.closed) count++;
	if (borders.left   == border_types.closed) count++;
	if (borders.right  == border_types.closed) count++;
	return count;
}

function rgt_set_block_border(xx, yy, side, border_type, tree)
{
	if (side == sides.top)
	{
		tree.v_borders[# xx, yy] = border_type;
	}
	if (side == sides.bottom)
	{
		tree.v_borders[# xx, yy + 1] = border_type;
	}
	if (side == sides.left)
	{
		tree.h_borders[# xx, yy] = border_type;
	}
	if (side == sides.right)
	{
		tree.h_borders[# xx + 1, yy] = border_type;
	}
}

function rgt_find_path(entrance, end_x, end_y, tree)
{
	var path = room_find_path(tree, entrance.xx, entrance.yy, end_x, end_y, 9);
	return path != -1;
}

function rgt_find_entrance(exits)
{
	if (exits.top.exit_type == exit_types.entrance)
	{
		return {
			xx: exits.top.xx,
			yy: 0
		};
	}
	if (exits.bottom.exit_type == exit_types.entrance)
	{
		return {
			xx: exits.bottom.xx,
			yy: blocks_per_room_v - 1
		};
	}
	if (exits.left.exit_type == exit_types.entrance)
	{
		return {
			xx: 0,
			yy: exits.left.yy
		};
	}
	// must be right
	return {
		xx: blocks_per_room_h - 1,
		yy: exits.right.yy
	};
}

function rgt_initialize_exits(exits, tree)
{
	for (var i = 0; i < blocks_per_room_h; i++)
	{
		tree.v_borders[# i, 0] = border_types.closed;
		tree.v_borders[# i, blocks_per_room_v] = border_types.closed;
	}
	
	for (var j = 0; j < blocks_per_room_v; j++)
	{
		tree.h_borders[# 0, j] = border_types.closed;
		tree.h_borders[# blocks_per_room_h, j] = border_types.closed;
	}
	
	if (exits.top.exit_type != exit_types.no_exit)
	{
		tree.v_borders[# exits.top.xx, 0] = border_types.open;
	}
	if (exits.bottom.exit_type != exit_types.no_exit)
	{
		tree.v_borders[# exits.bottom.xx, blocks_per_room_v] = border_types.open;
	}
	if (exits.left.exit_type != exit_types.no_exit)
	{
		tree.h_borders[# 0, exits.left.yy] = border_types.open;
	}
	if (exits.right.exit_type != exit_types.no_exit)
	{
		tree.h_borders[# blocks_per_room_h, exits.right.yy] = border_types.open;
	}
}


