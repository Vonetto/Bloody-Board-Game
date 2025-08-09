extends Node

class_name ViewHelpers

static func screen_to_world(node: Node, screen_pos: Vector2) -> Vector2:
	var xform := node.get_viewport().get_canvas_transform()
	return xform.affine_inverse() * screen_pos

static func nearest_index_from_world(index_map: Dictionary, world_pos: Vector2) -> int:
	var best_index: int = 0
	var best_dist := INF
	for i in index_map.keys():
		var p: Vector2 = index_map[i]
		var d := p.distance_to(world_pos)
		if d < best_dist:
			best_dist = d
			best_index = i
	return best_index
