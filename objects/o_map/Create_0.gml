
//randomise();
random_set_seed(0);

transition = false;

room_w  = blocks_per_room_h * block_base_size * tile_size;
room_h  = blocks_per_room_v * block_base_size * tile_size;

region = instance_create_layer(0, 0, "Controllers", o_region);

posx = floor(region_width / 2);
posy = floor(region_height / 2);

var rm = instance_create_layer(0, 0, "Controllers", o_room);
region.rooms[# posx, posy] = rm;
region.room_count++;

//map_test(region, posx, posy);
room_generate(region, posx, posy, sides.top);