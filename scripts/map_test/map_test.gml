
function map_test(region, room_x, room_y)
{	
	var rm = instance_create_layer(0, 0, "Controllers", o_room);
	
	region[# room_x, room_y] = rm;
	
	rm.exits = {
		top: {
			exit_type: exit_types.open,
			xx: 0
		},
		bottom: {
			exit_type: exit_types.no_exit,
			xx: -1
		},
		left: {
			exit_type: exit_types.entrance,
			yy: 2
		},
		right: {
			exit_type: exit_types.open,
			yy: 1
		},
	};

	randomise();
	random_set_seed(6);
	
	var t0 = get_timer();

	var tree = room_generate_tree(rm.exits);
	var t1 = get_timer();

	room_generate_borders(region, room_x, room_y, rm.blocks, tree);
	var t2 = get_timer();
	
	room_fill_cavities(rm.blocks, rm.exits, tree);
	var t3 = get_timer();
	
	room_generate_wall_texture(rm.blocks, tree);
	var t4 = get_timer();
	
	var terrace_graph = room_build_terrace_graph(rm.blocks, tree);
	var t5 = get_timer();
	
	room_generate_platforms(rm.blocks, terrace_graph);
	var t6 = get_timer();
	
	room_place_objects(rm);
	var t7 = get_timer();
	
	//show_debug_message("");
	//show_debug_message("path | left -> right: "    + path_to_string(room_find_path(tree, 0, rm.exits.left.yy, 2, rm.exits.right.yy, 9)));
	//show_debug_message("path | right -> left: "    + path_to_string(room_find_path(tree, 2, rm.exits.right.yy, 0, rm.exits.left.yy, 9)));

	//visualize_tree(tree);
	ds_grid_destroy(tree.h_borders);
	ds_grid_destroy(tree.v_borders);
	
	var terrace_graph_visualizer = instance_create_layer(0, 0, "Controllers", o_terrace_graph_visualizer);
	with (terrace_graph_visualizer)
	{
		graph = terrace_graph;
	}
	//ds_list_destroy(terrace_graph);
	
	show_debug_message("");
	show_debug_message("///// BENCHMARKS /////");
	show_debug_message("generate tree: " + string(t1 - t0));
	show_debug_message("generate borders: " + string(t2 - t1));
	show_debug_message("fill cavities: " + string(t3 - t2));
	show_debug_message("generate wall texture: " + string(t4 - t3));
	show_debug_message("build terrace graph: " + string(t5 - t4));
	show_debug_message("generate platforms: " + string(t6 - t5));
	show_debug_message("place objects: " + string(t7 - t6));
	show_debug_message("");
}