
for (var i = 0; i < array_length(my_path); i++)
{
	var row = my_path[i].row;
	var col = my_path[i].col;
	draw_sprite(s_diamond, 0, col * tile_size, row * tile_size);
}