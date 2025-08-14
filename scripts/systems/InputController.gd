extends Node

## InputController: traduce mouse/teclado a señales de movimiento

class_name InputController

signal select_origin(index: int)
signal select_destination(index: int)
signal hover_index_changed(index: int)
signal cancel_selection

const BoardUtils = preload("res://scripts/game_logic/BoardUtils.gd")

var active_selector	# referencia al selector del turno (para actualizar índice/pos)
var index_map: Dictionary
var selecting_target: bool = false

var last_hover_index: int = -1

func configure(selector, idx_map: Dictionary) -> void:
	active_selector = selector
	index_map = idx_map
	# Normalizar estado visual al configurar
	if active_selector:
		active_selector.vul = false
	selecting_target = false
	last_hover_index = -1

func set_selecting_target(flag: bool) -> void:
	selecting_target = flag

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var world: Vector2 = get_viewport().get_canvas_transform().affine_inverse() * event.position
		var idx: int = _nearest_index(world)
		if idx == 0:
			return
		if active_selector and not selecting_target:
			active_selector.position = index_map[idx]
			active_selector.indice = idx
			emit_signal("select_origin", idx)
		elif active_selector and selecting_target:
			active_selector.position = index_map[idx]
			active_selector.indice = idx
			emit_signal("select_destination", idx)
	elif event is InputEventMouseMotion:
		var world: Vector2 = get_viewport().get_canvas_transform().affine_inverse() * event.position
		var idx: int = _nearest_index(world)
		if idx != 0 and idx != last_hover_index:
			last_hover_index = idx
			emit_signal("hover_index_changed", idx)
	elif event is InputEventKey and event.pressed and not event.echo:
		if active_selector == null:
			return
		var dx := 0
		var dy := 0
		if event.is_action_pressed("ui_left"):
			dx = -1
		elif event.is_action_pressed("ui_right"):
			dx = 1
		elif event.is_action_pressed("ui_up"):
			dy = 1
		elif event.is_action_pressed("ui_down"):
			dy = -1
		if dx != 0 or dy != 0:
			var col := int((active_selector.indice - 1) % 8)
			var row := int((active_selector.indice - 1) / 8)
			col = clamp(col + dx, 0, 7)
			row = clamp(row + dy, 0, 7)
			var new_index := row * 8 + col + 1
			if new_index != active_selector.indice:
				active_selector.indice = new_index
				active_selector.position = index_map[new_index]
				emit_signal("hover_index_changed", new_index)
				return
		if event.is_action_pressed("ui_accept"):
			var current_idx: int = active_selector.indice
			if not selecting_target:
				emit_signal("select_origin", current_idx)
			else:
				emit_signal("select_destination", current_idx)
		elif event.is_action_pressed("ui_cancel"):
			selecting_target = false
			emit_signal("cancel_selection")

func _nearest_index(world_pos: Vector2) -> int:
	var best: int = 0
	var best_d: float = INF
	for k in index_map.keys():
		var d: float = index_map[k].distance_to(world_pos)
		if d < best_d:
			best_d = d
			best = k
	return best
