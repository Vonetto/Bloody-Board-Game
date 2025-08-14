extends Node2D

var white_pieces =[]
var black_pieces =[]

var first_target
var second_target=null

@onready var tablero = $tablero

const BoardModel = preload("res://scripts/game_logic/BoardModel.gd")
var model: BoardModel
var index_map= {}
var pos1
var pos2

var turn = true #true: white, false: black
var pawn_conquerable
const BoardUtils = preload("res://scripts/game_logic/BoardUtils.gd")
const Types = preload("res://scripts/game_logic/Types.gd")
const ViewHelpers = preload("res://scripts/ui/ViewHelpers.gd")
const SelectorController = preload("res://scripts/ui/SelectorController.gd")

@onready var selector: SelectorView = load("res://selector.tscn").instantiate()
@onready var selector2: SelectorView = load("res://selector_2.tscn").instantiate()
@onready var input_controller: InputController = preload("res://scripts/systems/InputController.gd").new()
var hover_marker: Sprite2D
var status_layer: CanvasLayer
var status_label: Label
var turn_banner_delay_ms: float = 0.0

var full_map
signal selector_index
var is_selecting_target: bool = false


func _ready():
	#tablero.pieces_created.connect(_on_pieces_created)
	model = BoardModel.new()
	add_child(model)
	# Inicializamos tras instanciar piezas (se llena en _on_pieces_created)
	index_map = preload("res://scripts/game_logic/BoardUtils.gd").generate_index_map()
	selector_index.emit()
	
	# Ensure mouse_left action exists for mouse support (safe-guard)
	if not InputMap.has_action("mouse_left"):
		Logger.d("[InputMap] registering mouse_left action")
		InputMap.add_action("mouse_left")
		var ev := InputEventMouseButton.new()
		ev.button_index = MOUSE_BUTTON_LEFT
		InputMap.action_add_event("mouse_left", ev)
	
	selector.vul=false
	selector2.vul=false
	
	
	set_process_input(true)
	
	
	add_child(selector)
	add_child(selector2)
	add_child(input_controller)
	# Hover marker visual (componente dedicado)
	hover_marker = preload("res://scripts/ui/HoverMarker.gd").new()
	add_child(hover_marker)
	# Status HUD (componente dedicado)
	var hud := preload("res://scripts/ui/StatusHud.gd").new()
	add_child(hud)
	status_layer = hud
	status_label = hud.label
	
	turn_handler()
	# Configurar input controller con el selector activo al inicio
	input_controller.configure(selector, index_map)
	input_controller.select_origin.connect(_on_select_origin)
	input_controller.select_destination.connect(_on_select_destination)
	input_controller.hover_index_changed.connect(_on_hover_index)
	input_controller.cancel_selection.connect(_on_cancel_selection)
	
	
	
	_on_pieces_created()
	get_node("/root/Game").initialize(white_pieces, black_pieces)
	get_node("/root/Game").move_applied.connect(_on_move_applied)
	get_node("/root/Game").invalid_move.connect(_on_invalid_move)
	get_node("/root/Game").turn_changed.connect(_on_turn_changed)
	get_node("/root/Game").capture_made.connect(_on_capture_made)
	
	
	

# Called when the node enters the scene tree for the first time.
	

	
func _on_pieces_created():
	for piece in white_pieces:
		piece.invalid_movement.connect(selector.invalidate)
	for piece in black_pieces:
		piece.invalid_movement.connect(selector2.invalidate)
	# Inicializar modelo con el estado real de piezas
	model.initialize(white_pieces, black_pieces)
	index_map = model.index_map
	
	

	

func turn_handler():
	if turn == true:
		selector.turn = true
		selector2.turn = false
	elif turn == false:
		selector.turn = false
		selector2.turn = true
	
	if selector2.turn==true:
		selector2.position = index_map[61]
		selector2.indice = 61 
		selector2.show_neutral_black()
	else:
		selector2.position = index_map[61]
		selector2.indice = 61 
		selector2.show_hidden()
	if selector.turn==true:
		selector.position = index_map[4]
		selector.indice = 4 
		selector.show_neutral_white()
	else:
		selector.position = index_map[4]
		selector.indice = 4 
		selector.show_hidden()

	# Reconfigura el InputController con el selector activo del turno
	is_selecting_target = false
	SelectorController.show_turn(selector, selector2, turn, index_map)
	input_controller.configure(selector if turn else selector2, index_map)
	input_controller.set_selecting_target(false)
		
	
	
	
	
func _input(_event):
	# Toda la entrada (teclado y mouse) está centralizada en InputController._unhandled_input
	return
				
				
			
			


			
func search_in(sq,selector):
	return get_node("/root/Game").piece_at_selector_index(selector)


func end_game():
	get_tree().quit()

func _nearest_index_from_mouse(mouse_pos: Vector2) -> int:
	return ViewHelpers.nearest_index_from_world(model.index_map, mouse_pos)

func _screen_to_world(screen_pos: Vector2) -> Vector2:
	return ViewHelpers.screen_to_world(self, screen_pos)

func _on_select_origin(idx: int) -> void:
	# Marca origen (modo destino) usando estado único
	if turn:
		var pos: Vector2 = index_map[idx]
		pos1 = Vector2(int(pos.x), int(pos.y))
		first_target = search_in(pos1, selector)
		if first_target == null or first_target.ficha.team != Types.Team.White:
			selector.invalidate(); return
		is_selecting_target = true
		input_controller.set_selecting_target(true)
		selector2.visible = false
		if selector.has_method("set_color"): selector.set_color(Color(0,1,0))
	else:
		var pos: Vector2 = index_map[idx]
		pos1 = Vector2(int(pos.x), int(pos.y))
		first_target = search_in(pos1, selector2)
		if first_target == null or first_target.ficha.team != Types.Team.Black:
			selector2.invalidate(); return
		is_selecting_target = true
		input_controller.set_selecting_target(true)
		selector.visible = false
		if selector2.has_method("set_color"): selector2.set_color(Color(0,1,0))

func _on_select_destination(idx: int) -> void:
	if first_target == null:
		return
	var pos: Vector2 = index_map[idx]
	pos2 = Vector2(int(pos.x), int(pos.y))
	get_node("/root/Game").request_move(first_target, pos1, pos2, index_map, false)
	is_selecting_target = false
	input_controller.set_selecting_target(false)
	if turn:
		if selector.has_method("animate_confirm"): selector.animate_confirm()
		if selector.has_method("set_color"): selector.set_color(Color(1,1,1,1))
		selector2.visible = false
		selector.visible = true
	else:
		if selector2.has_method("animate_confirm"): selector2.animate_confirm()
		if selector2.has_method("set_color"): selector2.set_color(Color(0,0,0))
		selector.visible = false
		selector2.visible = true

func _on_cancel_selection() -> void:
	is_selecting_target = false
	input_controller.set_selecting_target(false)
	if turn:
		if selector.has_method("animate_cancel"): selector.animate_cancel()
	else:
		if selector2.has_method("animate_cancel"): selector2.animate_cancel()
	SelectorController.reset_after_cancel(selector, selector2, turn)

func _on_move_applied(piece, from_idx: int, to_idx: int) -> void:
	turn = not turn
	turn_handler()

func _on_invalid_move(reason: String) -> void:
	is_selecting_target = false
	input_controller.set_selecting_target(false)
	if turn:
		await selector.invalidate()
		selector.show_neutral_white()
	else:
		await selector2.invalidate()
		selector2.show_neutral_black()
	_flash_status("Movimiento inválido", Color(1,0.3,0.3,1), 0.9)

func _on_capture_made(attacker_team: String, attacker_id: String, victim_team: String, victim_id: String) -> void:
	var equipos := {
		"White": "Blanco",
		"Black": "Negro"
	}
	var piezas := {
		"P": "Peón",
		"N": "Caballo",
		"B": "Alfil",
		"R": "Torre",
		"Q": "Reina",
		"K": "Rey"
	}
	var msg := "%s %s come %s %s" % [piezas.get(attacker_id, attacker_id), equipos.get(attacker_team, attacker_team), piezas.get(victim_id, victim_id), equipos.get(victim_team, victim_team)]
	_flash_status(msg, Color(1,1,0.6,1), 1.4)
	turn_banner_delay_ms = 1.2

func _on_turn_changed(is_white: bool) -> void:
	turn = is_white
	is_selecting_target = false
	input_controller.set_selecting_target(false)
	turn_handler()
	if turn_banner_delay_ms > 0.0:
		await get_tree().create_timer(turn_banner_delay_ms).timeout
		turn_banner_delay_ms = 0.0
	_flash_status(("Turno Blancas" if turn else "Turno Negras"), Color(1,1,1,1), 1.0)

func _flash_status(text: String, color: Color, fade: float = 1.2) -> void:
	if status_layer and status_layer.has_method("show_message"):
		status_layer.show_message(text, color, fade)

func _on_hover_index(idx: int) -> void:
	if hover_marker and hover_marker.has_method("set_index"):
		hover_marker.set_index(idx, index_map)
