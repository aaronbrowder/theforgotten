
for (var i = 0; i < ds_list_size(graph); i++)
{
	var node = graph[| i];
	
	for (var j = 0; j < array_length(node.terrace); j++)
	{
		var tile = node.terrace[j];
		draw_sprite(s_dot, 0, tile.col * tile_size, tile.row * tile_size);
	}
	
	for (var j = 0; j < array_length(node.connections); j++)
	{
		var connection = node.connections[j];
		
		var tile1 = connection.key_tile1;
		var tile2 = connection.key_tile2;
		
		var tile1_x = (tile1.col * tile_size) + (tile_size / 2);
		var tile1_y = (tile1.row * tile_size) + (tile_size / 2);
		var tile2_x = (tile2.col * tile_size) + (tile_size / 2);
		var tile2_y = (tile2.row * tile_size) + (tile_size / 2);
		
		draw_primitive_begin(pr_linelist);
		draw_vertex_color(tile1_x, tile1_y, c_white, 1);
		draw_vertex_color(tile2_x, tile2_y, c_white, 1);
		draw_primitive_end();
		
		//var text_x = (tile2_x + tile1_x) / 2;
		//var text_y = (tile2_y + tile1_y) / 2;
		//var c = c_white;
		//draw_set_halign(fa_center);
		//draw_set_valign(fa_middle);
		//draw_text_color(text_x, text_y, string(connection.distance), c, c, c, c, 1);
	}
}
