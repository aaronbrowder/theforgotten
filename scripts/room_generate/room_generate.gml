
function room_generate(region, room_x, room_y, entrance_side)
{	
	var rm = region.rooms[# room_x, room_y];
	
	rm.exits = room_generate_exits(region, room_x, room_y, entrance_side);
	
	var tree = room_generate_tree(rm.exits);

	room_generate_borders(region, room_x, room_y, rm.blocks, tree);
	
	room_fill_cavities(rm.blocks, rm.exits, tree);
	
	room_generate_wall_texture(rm.blocks, tree);
	
	var tiles = merge_blocks(rm.blocks);
	
	var terrace_graph = room_build_terrace_graph(tiles, tree);
	
	var platforms = room_generate_platforms(tiles, terrace_graph);
	
	room_place_objects(tiles, platforms);
	
	ds_grid_destroy(tree.h_borders);
	ds_grid_destroy(tree.v_borders);
	ds_list_destroy(terrace_graph);

	return rm;
}