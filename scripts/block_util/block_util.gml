
function blank_block()
{
	return blank_tiles_array(block_base_size, block_base_size);
}

function blank_tiles_array(w, h)
{
	var tiles = array_create(h);
	for (var row = 0; row < array_length(tiles); row++)
	{
		tiles[row] = array_create(w);
	}
	return tiles;
}

function merge_blocks(blocks)
{
	var w = block_base_size * blocks_per_room_h;
	var h = block_base_size * blocks_per_room_v;
	var tiles = blank_tiles_array(w, h);

	for (var i = 0; i < blocks_per_room_h; i++)
	{
		for (var j = 0; j < blocks_per_room_v; j++)
		{
			var block = blocks[# i, j];
			for (var row = 0; row < block_base_size; row++)
			{
				for (var col = 0; col < block_base_size; col++)
				{
					var rr = (j * block_base_size) + row;
					var cc = (i * block_base_size) + col;
					tiles[@ rr][@ cc] = block[row][col];
				}
			}
		}
	}
	return tiles;
}