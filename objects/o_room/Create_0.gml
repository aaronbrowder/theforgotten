
exits = {
	top: {
		exit_type: exit_types.no_exit,
		x1: -1,
		x2: -1
	},
	bottom: {
		exit_type: exit_types.no_exit,
		x1: -1,
		x2: -1
	},
	left: {
		exit_type: exit_types.no_exit,
		y1: -1,
		y2: -1
	},
	right: {
		exit_type: exit_types.no_exit,
		y1: -1,
		y2: -1
	},
};

blocks = ds_grid_create(blocks_per_room_h, blocks_per_room_v);

for (var i = 0; i < blocks_per_room_h; i++)
{
	for (var j = 0; j < blocks_per_room_v; j++)
	{
		blocks[# i, j] = blank_block();
	}
}
