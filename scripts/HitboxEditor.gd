extends Node2D

# --- CONFIGURACIÓN ---
@export var target_node_path: NodePath = NodePath()
@export var toggle_key: int = KEY_F1
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
	elif event.is_action_pressed("ui_up"):
		current_box_index += 1
		load_selected_box()
	elif event.is_action_pressed("ui_down"):
		current_box_index -= 1
		load_selected_box()
	elif event is InputEventKey and (event as InputEventKey).pressed and (event as InputEventKey).keycode == KEY_SPACE:
		print_box_data()
	elif event is InputEventKey and (event as InputEventKey).pressed and (event as InputEventKey).keycode == KEY_TAB:
		current_box_type = "hit" if current_box_type == "hurt" else "hurt"
		current_box_index = 0
		load_selected_box()
		_apply_to_target()
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
	if Input.is_key_pressed(KEY_W):
		resize_dir.y -= 1
	if Input.is_key_pressed(KEY_S):
		resize_dir.y += 1

	var changed: bool = false
	if move_dir != Vector2.ZERO:
		selected_box_data["x"] = float(selected_box_data.get("x", 0)) + current_move_speed * move_dir.x
		selected_box_data["y"] = float(selected_box_data.get("y", 0)) + current_move_speed * move_dir.y
		changed = true
	if resize_dir != Vector2.ZERO:
		selected_box_data["w"] = max(1.0, float(selected_box_data.get("w", 0)) + current_resize_speed * resize_dir.x)
		selected_box_data["h"] = max(1.0, float(selected_box_data.get("h", 0)) + current_resize_speed * resize_dir.y)
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
	var pivot_px: Vector2 = Vector2(32, 52)
	if is_instance_valid(target_node):
		var p: Variant = target_node.get("pivot_px")
		if typeof(p) == TYPE_VECTOR2:
			pivot_px = p
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
	frames_data = (data.get("frames", []) as Array)
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
	
	# MODIFICADO: Llamar a la nueva función para actualizar el sprite
	if is_instance_valid(target_node) and target_node.has_method("set_attack_frame"):
		target_node.set_attack_frame(current_frame)
	
	queue_redraw()

func print_box_data() -> void:
	if selected_box_data.is_empty():
		print("No hay caja seleccionada para imprimir.")
		return
	var x := int(selected_box_data.get("x", 0))
	var y := int(selected_box_data.get("y", 0))
	var w := int(selected_box_data.get("w", 0))
	var h := int(selected_box_data.get("h", 0))
	var output := '{\n"x": %d,\n"y": %d,\n"w": %d,\n"h": %d\n}' % [x, y, w, h]
	print("--- Coordenadas de la Caja ---")
	print(output)
	print("-----------------------------")

func _apply_to_target() -> void:
	if is_instance_valid(target_node) and target_node.has_method("_apply_frame_boxes"):
		target_node.call("_apply_frame_boxes", current_frame, true)

func _commit_to_target() -> void:
	if not is_instance_valid(target_node):
		return
	# Solo actualizamos el array de frames dentro del diccionario de boxes
	if target_node.has_method("get_boxes_data"):
		var data: Dictionary = target_node.get_boxes_data()
		data["frames"] = frames_data
		if target_node.has_method("set_boxes_data"):
			target_node.set_boxes_data(data)

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
		var candidates: Array[Node] = []
		_collect_nodes_with_method(root, "get_boxes_data", candidates)
		if candidates.size() > 0:
			target_node = candidates[0]
			print("HitboxEditor: candidatos encontrados:")
			for c in candidates:
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
