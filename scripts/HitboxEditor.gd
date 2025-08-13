extends Node2D

# --- CONFIGURACIÓN ---
@export var target_node_path: NodePath = NodePath()
@export var toggle_key: int = KEY_F1
@export var switch_key: int = KEY_P # Cambiar entre fighters activos (P = piece)
@export var move_speed: float = 1.0
@export var resize_speed: float = 1.0
@export var move_requires_shift: bool = true

# --- ESTADO INTERNO ---
var is_active: bool = false
var current_frame: int = 0
var current_box_type: String = "hurt" # "hit" | "hurt"
var current_box_index: int = 0

var frames_data: Array = [] # Array[Dictionary]
var selected_box_data: Dictionary = {}
var target_node: Node = null
var candidate_targets: Array[Node] = []
var current_target_index: int = 0

func _enter_tree() -> void:
	# Asegura que el editor siga recibiendo input y dibujando aunque el árbol esté en pausa
	process_mode = Node.PROCESS_MODE_ALWAYS

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not (event as InputEventKey).echo and (event as InputEventKey).keycode == toggle_key:
		is_active = not is_active
		get_tree().paused = is_active
		print("Hitbox Editor " + ("ACTIVADO" if is_active else "DESACTIVADO"))
		if is_active:
			_resolve_target()
			if not is_instance_valid(target_node):
				is_active = false
				get_tree().paused = false
				return
			load_data_from_target()
			_apply_to_target()
			queue_redraw()
		return

	# Cambiar de objetivo (p. ej., entre blue/red) mientras el editor está activo
	if is_active and event is InputEventKey and event.pressed and not (event as InputEventKey).echo and (event as InputEventKey).keycode == switch_key:
		_cycle_target()
		get_viewport().set_input_as_handled()
		queue_redraw()
		return

	if not is_active:
		return

	var handled: bool = true
	if event is InputEventKey and event.pressed and (event as InputEventKey).keycode == KEY_N:
		current_frame = int(wrap(float(current_frame + 1), 0.0, float(frames_data.size())))
		load_selected_box()
		_apply_to_target()
	elif event is InputEventKey and event.pressed and (event as InputEventKey).keycode == KEY_M:
		current_frame = int(wrap(float(current_frame - 1), 0.0, float(frames_data.size())))
		load_selected_box()
		_apply_to_target()
	elif event is InputEventKey and event.pressed and (event as InputEventKey).keycode == KEY_UP and (event as InputEventKey).shift_pressed:
		current_box_index += 1
		load_selected_box()
		_apply_to_target()
		return
	elif event is InputEventKey and event.pressed and (event as InputEventKey).keycode == KEY_DOWN and (event as InputEventKey).shift_pressed:
		current_box_index -= 1
		load_selected_box()
		_apply_to_target()
		return
	elif event is InputEventKey and (event as InputEventKey).pressed and (event as InputEventKey).keycode == KEY_SPACE:
		print_box_data()
	elif event is InputEventKey and (event as InputEventKey).pressed and (event as InputEventKey).keycode == KEY_Q:
		_add_box()
		return
	elif event is InputEventKey and (event as InputEventKey).pressed and (event as InputEventKey).keycode == KEY_E:
		_remove_box()
		return
	elif event is InputEventKey and (event as InputEventKey).pressed and (event as InputEventKey).keycode == KEY_TAB:
		current_box_type = "hit" if current_box_type == "hurt" else "hurt"
		current_box_index = 0
		load_selected_box()
		_apply_to_target()
	elif event is InputEventKey and event.pressed and event.ctrl_pressed and (event as InputEventKey).keycode == KEY_H:
		_save_data_to_file()
		handled = true
	else:
		handled = false
	
	if handled:
		get_viewport().set_input_as_handled()
		queue_redraw()

func _process(_delta: float) -> void:
	if not is_active or selected_box_data.is_empty():
		if is_active and is_instance_valid(target_node):
			var pivot := target_node.get_node_or_null("pivot") as Node2D
			if pivot:
				global_transform = pivot.global_transform
		return

	var current_move_speed = move_speed
	var current_resize_speed = resize_speed
	if Input.is_key_pressed(KEY_CTRL):
		current_move_speed *= 0.1
		current_resize_speed *= 0.1

	var move_dir := Vector2.ZERO
	var can_move_with_arrows := (not move_requires_shift) or Input.is_key_pressed(KEY_CTRL)
	if can_move_with_arrows:
		if Input.is_key_pressed(KEY_LEFT):
			move_dir.x -= 1
		if Input.is_key_pressed(KEY_RIGHT):
			move_dir.x += 1
		if Input.is_key_pressed(KEY_UP):
			move_dir.y -= 1
		if Input.is_key_pressed(KEY_DOWN):
			move_dir.y += 1
	
	var resize_dir := Vector2.ZERO
	if Input.is_key_pressed(KEY_A):
		resize_dir.x -= 1
	if Input.is_key_pressed(KEY_D):
		resize_dir.x += 1
	if Input.is_key_pressed(KEY_W) and not Input.is_key_pressed(KEY_ALT):
		resize_dir.y -= 1
	if Input.is_key_pressed(KEY_S) and not Input.is_key_pressed(KEY_ALT):
		resize_dir.y += 1

	var changed: bool = false
	if move_dir != Vector2.ZERO:
		selected_box_data["x"] = float(selected_box_data.get("x", 0)) + current_move_speed * move_dir.x
		selected_box_data["y"] = float(selected_box_data.get("y", 0)) + current_move_speed * move_dir.y
		changed = true
	if resize_dir != Vector2.ZERO:
		selected_box_data["w"] = max(1.0, float(selected_box_data.get("w", 0))) + current_resize_speed * resize_dir.x
		selected_box_data["h"] = max(1.0, float(selected_box_data.get("h", 0))) + current_resize_speed * resize_dir.y
		changed = true
	
	if changed:
		_commit_to_target()
		_apply_to_target()
		queue_redraw()

func _draw() -> void:
	if not is_active or not is_instance_valid(target_node) or frames_data.is_empty():
		return
	
	# Alinear el editor con el pivot del pawn
	var pivot := target_node.get_node_or_null("pivot") as Node2D
	if pivot:
		global_transform = pivot.global_transform
	
	# Offset por pivote del spritesheet (top-left -> origen pivot)
	var pivot_px: Vector2 = _get_pivot_px()
	var frame_boxes: Dictionary = frames_data[current_frame]
	_draw_boxes(frame_boxes.get("hurt", []) as Array, Color(0, 0, 1, 0.35), pivot_px)
	_draw_boxes(frame_boxes.get("hit", []) as Array, Color(1, 0, 0, 0.35), pivot_px)
	
	if not selected_box_data.is_empty():
		var sx := float(selected_box_data.get("x", 0)) - pivot_px.x
		var sy := float(selected_box_data.get("y", 0)) - pivot_px.y
		var sw := float(selected_box_data.get("w", 0))
		var sh := float(selected_box_data.get("h", 0))
		draw_rect(Rect2(Vector2(sx, sy), Vector2(sw, sh)), Color(1, 1, 0, 0.7), false, 2.0)

func _draw_boxes(boxes: Array, color: Color, pivot_px: Vector2) -> void:
	for box in boxes:
		var dx := float((box as Dictionary).get("x", 0)) - pivot_px.x
		var dy := float((box as Dictionary).get("y", 0)) - pivot_px.y
		var dw := float((box as Dictionary).get("w", 0))
		var dh := float((box as Dictionary).get("h", 0))
		draw_rect(Rect2(Vector2(dx, dy), Vector2(dw, dh)), color, true)

func load_data_from_target() -> void:
	if not is_instance_valid(target_node) or not target_node.has_method("get_boxes_data"):
		print("Editor Error: El nodo objetivo no es válido o no tiene el método 'get_boxes_data'.")
		is_active = false
		return
	var data: Dictionary = target_node.get_boxes_data()
	frames_data = (data.get("frames", []) as Array).duplicate(true) # Deep copy
	current_frame = 0
	current_box_index = 0
	current_box_type = "hurt"
	load_selected_box()

func load_selected_box() -> void:
	if current_frame >= frames_data.size():
		selected_box_data = {}
		return
	var frame_boxes: Dictionary = frames_data[current_frame]
	var boxes_of_type: Array = (frame_boxes.get(current_box_type, []) as Array)
	if boxes_of_type.is_empty():
		selected_box_data = {}
		current_box_index = 0
	else:
		current_box_index = int(wrap(float(current_box_index), 0.0, float(boxes_of_type.size())))
		selected_box_data = boxes_of_type[current_box_index]
	
	if is_instance_valid(target_node) and target_node.has_method("set_attack_frame"):
		target_node.set_attack_frame(current_frame)
	
	queue_redraw()

func print_box_data() -> void:
	if selected_box_data.is_empty():
		print("No hay caja seleccionada para imprimir.")
		return
	var x: float = snapped(float(selected_box_data.get("x", 0)), 1.0)
	var y: float = snapped(float(selected_box_data.get("y", 0)), 1.0)
	var w: float = snapped(float(selected_box_data.get("w", 0)), 1.0)
	var h: float = snapped(float(selected_box_data.get("h", 0)), 1.0)
	var output := '{\n"x": %s,\n"y": %s,\n"w": %s,\n"h": %s\n}' % [str(x), str(y), str(w), str(h)]
	print("--- Coordenadas de la Caja (Redondeado) ---")
	print(output)
	print("-----------------------------------------")

func _apply_to_target() -> void:
	if is_instance_valid(target_node) and target_node.has_method("_apply_frame_boxes"):
		target_node.call("_apply_frame_boxes", current_frame, true)

func _commit_to_target() -> void:
	if not is_instance_valid(target_node):
		return
	if target_node.has_method("get_boxes_data"):
		var data: Dictionary = target_node.get_boxes_data()
		data["frames"] = frames_data
		if target_node.has_method("set_boxes_data"):
			target_node.set_boxes_data(data)

func _add_box() -> void:
	if frames_data.is_empty():
		return
	var frame_boxes: Dictionary = frames_data[current_frame]
	var boxes_of_type: Array = (frame_boxes.get(current_box_type, []) as Array)
	var pp := _get_pivot_px()
	var new_box := {"x": pp.x, "y": pp.y, "w": 10, "h": 10}
	boxes_of_type.append(new_box)
	frame_boxes[current_box_type] = boxes_of_type
	frames_data[current_frame] = frame_boxes
	current_box_index = boxes_of_type.size() - 1
	selected_box_data = boxes_of_type[current_box_index]
	_commit_to_target()
	_apply_to_target()
	queue_redraw()

func _remove_box() -> void:
	if frames_data.is_empty():
		return
	var frame_boxes: Dictionary = frames_data[current_frame]
	var boxes_of_type: Array = (frame_boxes.get(current_box_type, []) as Array)
	if boxes_of_type.is_empty():
		return
	boxes_of_type.remove_at(current_box_index)
	current_box_index = max(0, current_box_index - 1)
	frame_boxes[current_box_type] = boxes_of_type
	frames_data[current_frame] = frame_boxes
	if boxes_of_type.is_empty():
		selected_box_data = {}
	else:
		selected_box_data = boxes_of_type[current_box_index]
	_commit_to_target()
	_apply_to_target()
	queue_redraw()

func _save_data_to_file() -> void:
	if not is_instance_valid(target_node):
		print("Editor Error: No target node to save for.")
		return

	if not target_node.has_method("get_boxes_data") or not target_node.has_method("get"):
		print("Editor Error: Target node is not a valid fighter.")
		return

	var path: String = target_node.get("boxes_json_path")
	if path.is_empty():
		print("Editor Error: 'Boxes Json Path' is not set on the target fighter's inspector.")
		print("Cannot save. Please set the path on node: %s" % target_node.get_path())
		return

	var full_data: Dictionary = target_node.get_boxes_data()
	full_data["frames"] = frames_data

	var json_string := JSON.stringify(full_data, "\t")
	
	var file := FileAccess.open(path, FileAccess.WRITE)
	if not file:
		var error_code = FileAccess.get_open_error()
		print("Editor Error: Failed to open file for writing at path: %s. Error: %s" % [path, error_string(error_code)])
		return
	
	file.store_string(json_string)
	file.close()
	print("Successfully saved boxes to: %s" % path)

# --- Resolución robusta del target ---
func _resolve_target() -> void:
	# 1) Usar el path si existe
	target_node = get_node_or_null(target_node_path)
	# 2) Si apunta a un hijo (p.ej., pivot/Sprite2D), subir hasta encontrar el método
	var cur := target_node
	var steps := 0
	while cur != null and not cur.has_method("get_boxes_data") and steps < 6:
		cur = cur.get_parent()
		steps += 1
	if cur and cur.has_method("get_boxes_data"):
		target_node = cur
	# 3) Si aún no lo encontramos, buscar en todo el árbol (root)
	if target_node == null or not target_node.has_method("get_boxes_data"):
		var root := get_tree().root
		candidate_targets.clear()
		_collect_nodes_with_method(root, "get_boxes_data", candidate_targets)
		if candidate_targets.size() > 0:
			current_target_index = clamp(current_target_index, 0, candidate_targets.size() - 1)
			target_node = candidate_targets[current_target_index]
			print("HitboxEditor: candidatos encontrados:")
			for c in candidate_targets:
				print(" - ", c.get_path())
	# 4) Log de resultado
	if target_node and target_node.has_method("get_boxes_data"):
		print("HitboxEditor: Target resuelto -> %s" % str(target_node.get_path()))
	else:
		print("Editor Error: No encontré un nodo con 'get_boxes_data'. Asigna 'Target Node' en el inspector.")

func _collect_nodes_with_method(node: Node, method_name: String, out: Array[Node]) -> void:
	if node.has_method(method_name):
		out.append(node)
	for child in node.get_children():
		_collect_nodes_with_method(child, method_name, out)

func _cycle_target() -> void:
	if candidate_targets.is_empty():
		# Recolectar si aún no lo hemos hecho
		var root := get_tree().root
		_collect_nodes_with_method(root, "get_boxes_data", candidate_targets)
	if candidate_targets.size() <= 1:
		print("HitboxEditor: No hay más de un candidato para alternar.")
		return
	current_target_index = int(wrap(float(current_target_index + 1), 0.0, float(candidate_targets.size())))
	target_node = candidate_targets[current_target_index]
	print("HitboxEditor: Switch -> %s" % str(target_node.get_path()))
	load_data_from_target()
	_apply_to_target()

func _get_pivot_px() -> Vector2:
	var pivot_px := Vector2(32, 52)
	if is_instance_valid(target_node):
		var p: Variant = target_node.get("pivot_px")
		if typeof(p) == TYPE_VECTOR2:
			pivot_px = p
	return pivot_px
