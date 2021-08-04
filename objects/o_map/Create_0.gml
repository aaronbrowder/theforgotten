
region = ds_grid_create(region_width, region_height);

ds_grid_clear(region, 0);

posx = floor(region_width / 2);
posy = floor(region_height / 2);

map_test(region, posx, posy);