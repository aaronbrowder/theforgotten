
#macro block_base_size 8
#macro tile_size 32
#macro blocks_per_room_h 3
#macro blocks_per_room_v 3
#macro region_width 16
#macro region_height 12

#macro room_openness 0.5
#macro wall_thickness 1

#macro player_gravity 0.55
#macro player_walk_speed 3.8
#macro player_jump_speed 10.5

enum sides
{
	top,
	bottom,
	left,
	right
}

enum directions
{
	up,
	down,
	left,
	right
}

enum border_types
{
	closed,
	open,
	blank
}

enum exit_types
{
	no_exit,
	entrance,
	fixed,
	open,
	locked
}