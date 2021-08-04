
function room_find_path(tree, x1, y1, x2, y2, max_distance)
{
	return rfp_find_path_recursive(tree, [], x1, y1, x2, y2, max_distance);
}

function rfp_find_path_recursive(tree, path, x1, y1, x2, y2, max_distance)
{	
	if (x1 == -1 || x2 == -1 || y1 == -1 || y2 == -1)
	{
		// no path
		return -1;
	}
	
	var length = array_length(path);
	if (max_distance != -1 && length > max_distance)
	{
		// no path within max distance
		return -1;
	}
	
	var my_path = array_create(length);
	array_copy(my_path, 0, path, 0, length);
	array_push(my_path, { xx: x1, yy: y1 });
	
	if (x1 == x2 && y1 == y2)
	{
		// path complete
		return my_path;
	}
	
	var can_go_up = y1 > 0
		&& !rfp_path_contains_coords(path, x1, y1 - 1)
		&& tree.v_borders[# x1, y1] != border_types.closed;
	
	var can_go_down = y1 < 2
		&& !rfp_path_contains_coords(path, x1, y1 + 1)
		&& tree.v_borders[# x1, y1 + 1] != border_types.closed;
	
	var can_go_left = x1 > 0
		&& !rfp_path_contains_coords(path, x1 - 1, y1)
		&& tree.h_borders[# x1, y1] != border_types.closed;
	
	var can_go_right = x1 < 2
		&& !rfp_path_contains_coords(path, x1 + 1, y1)
		&& tree.h_borders[# x1 + 1, y1] != border_types.closed;
		
	var randy = choose(true, false);
	
	// first, try to find the shortest path by moving in the direction of the end
	if (can_go_up && y2 < y1 && randy)
	{
		var result = rfp_find_path_recursive(tree, my_path, x1, y1 - 1, x2, y2, max_distance);
		if (result != -1) return result;
		else can_go_up = false;
	}
	if (can_go_down && y2 > y1)
	{
		var result = rfp_find_path_recursive(tree, my_path, x1, y1 + 1, x2, y2, max_distance);
		if (result != -1) return result;
		else can_go_down = false;
	}
	if (can_go_up && y2 < y1)
	{
		var result = rfp_find_path_recursive(tree, my_path, x1, y1 - 1, x2, y2, max_distance);
		if (result != -1) return result;
		else can_go_up = false;
	}
	if (can_go_left && x2 < x1 && randy)
	{
		var result = rfp_find_path_recursive(tree, my_path, x1 - 1, y1, x2, y2, max_distance);
		if (result != -1) return result;
		else can_go_left = false;
	}
	if (can_go_right && x2 > x1)
	{
		var result = rfp_find_path_recursive(tree, my_path, x1 + 1, y1, x2, y2, max_distance);
		if (result != -1) return result;
		else can_go_right = false;
	}
	if (can_go_left && x2 < x1)
	{
		var result = rfp_find_path_recursive(tree, my_path, x1 - 1, y1, x2, y2, max_distance);
		if (result != -1) return result;
		else can_go_left = false;
	}
	
	// couldn't move in the direction of the end, so just go somewhere
	if (can_go_up && randy)
	{
		var result = rfp_find_path_recursive(tree, my_path, x1, y1 - 1, x2, y2, max_distance);
		if (result != -1) return result;
		else can_go_up = false;
	}
	if (can_go_down)
	{
		var result = rfp_find_path_recursive(tree, my_path, x1, y1 + 1, x2, y2, max_distance);
		if (result != -1) return result;
		else can_go_down = false;
	}
	if (can_go_up)
	{
		var result = rfp_find_path_recursive(tree, my_path, x1, y1 - 1, x2, y2, max_distance);
		if (result != -1) return result;
		else can_go_up = false;
	}
	if (can_go_left && randy)
	{
		var result = rfp_find_path_recursive(tree, my_path, x1 - 1, y1, x2, y2, max_distance);
		if (result != -1) return result;
		else can_go_left = false;
	}
	if (can_go_right)
	{
		var result = rfp_find_path_recursive(tree, my_path, x1 + 1, y1, x2, y2, max_distance);
		if (result != -1) return result;
		else can_go_right = false;
	}
	if (can_go_left)
	{
		var result = rfp_find_path_recursive(tree, my_path, x1 - 1, y1, x2, y2, max_distance);
		if (result != -1) return result;
		else can_go_right = false;
	}
	
	// no path could be found
	return -1;
}

function rfp_path_contains_coords(path, xx, yy)
{
	for (var i = array_length(path) - 1; i >= 0; i--)
	{
		var part = path[i];
		if (part.xx == xx && part.yy == yy)
		{
			return true;
		}
	}
	return false;
}

function path_to_string(path)
{
	if (path == -1)
	{
		return "NO PATH";
	}
	var str = "";
	for (var i = 0; i < array_length(path); i++)
	{
		var part = path[i];
		str += "(" + string(part.xx) + "," + string(part.yy) + ") ";
	}
	return str;
}

