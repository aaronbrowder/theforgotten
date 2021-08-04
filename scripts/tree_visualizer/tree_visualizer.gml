
function visualize_tree(tree)
{
	// vertical borders
	for (var i = 0; i < 3; i++)
	{
		for (var j = 0; j < 4; j++)
		{
			var xx = tile_size * ((block_base_size / 2) + (block_base_size * i));
			var yy = tile_size * block_base_size * j;
			var border_type = tree.v_borders[# i, j];
			vt_create_node(xx, yy, border_type);
		}
	}
	// horizontal borders
	for (var i = 0; i < 4; i++)
	{
		for (var j = 0; j < 3; j++)
		{
			var xx = tile_size * block_base_size * i;
			var yy = tile_size * ((block_base_size / 2) + (block_base_size * j));
			var border_type = tree.h_borders[# i, j];
			vt_create_node(xx, yy, border_type);
		}
	}
}

function vt_create_node(xx, yy, border_type)
{
	var node = instance_create_layer(xx, yy, "Instances", o_tree_visualizer);
	if (border_type == border_types.open)
	{
		node.image_index = 1;
	}
	if (border_type == border_types.closed)
	{
		node.image_index = 2;
	}
}