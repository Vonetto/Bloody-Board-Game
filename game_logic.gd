extends Node2D

var white_pieces =[]
var black_pieces =[]

var first_target
var second_target=null

@onready var tablero = $tablero

const BoardModel = preload("res://scripts/BoardModel.gd")
var model: BoardModel
var index_map= {}
var pos1
var pos2

var turn = true #true: white, false: black
var pawn_conquerable
const BoardUtils = preload("res://utils/BoardUtils.gd")
const Types = preload("res://scripts/Types.gd")
const ViewHelpers = preload("res://scripts/ViewHelpers.gd")

@onready var selector: SelectorView = load("res://selector.tscn").instantiate()
@onready var selector2: SelectorView = load("res://selector_2.tscn").instantiate()
@onready var input_controller: InputController = preload("res://scripts/InputController.gd").new()
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
	index_map = preload("res://utils/BoardUtils.gd").generate_index_map()
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
	hover_marker = preload("res://scripts/HoverMarker.gd").new()
	add_child(hover_marker)
	# Status HUD (componente dedicado)
	var hud := preload("res://scripts/StatusHud.gd").new()
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
		# Turno blancas: habilitar selector blanco, deshabilitar negro
		selector.turn = true
		selector2.turn = false
	elif turn == false:
		# Turno negras: habilitar selector negro, deshabilitar blanco
		selector.turn = false
		selector2.turn = true
	
	if selector2.turn==true:
		selector2.position= index_map[61]
		selector2.indice = 61 
		selector2.show_neutral_black()
	elif selector2.turn==false:
		selector2.position= index_map[61]
		selector2.indice = 61 
		selector2.show_hidden()
	
	
	if selector.turn==true:
		selector.position= index_map[4]
		selector.indice = 4 
		selector.show_neutral_white()
	elif selector.turn==false:
		selector.position= index_map[4]
		selector.indice = 4 
		selector.show_hidden()

	# Reconfigura el InputController con el selector activo del turno
	is_selecting_target = false
	if turn:
		selector.visible = true
		selector2.visible = false
		selector.show_neutral_white()
		input_controller.configure(selector, index_map)
		input_controller.set_selecting_target(false)
	else:
		selector.visible = false
		selector2.visible = true
		selector2.show_neutral_black()
		input_controller.configure(selector2, index_map)
		input_controller.set_selecting_target(false)
		
	
	
	
	
func _input(_event):
	# Toda la entrada (teclado y mouse) está centralizada en InputController._unhandled_input
	return
	
	if turn == true :
		
		if (Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("ui_select")) and selector.vul== false :
		
			var x=int(selector.position.x)
			var y=int(selector.position.y)
			
			
			pos1= Vector2(x,y)
			Logger.d("Select origin -> pos:" + str(pos1) + " index:" + str(selector.indice))
			
			

			var _piece=search_in(pos1,selector)

			
			
			
			first_target=_piece
			# Entramos en modo destino
			selector.vul = true
			if selector.has_method("set_color"):
				selector.set_color(Color(0,1,0))
			else:
				selector.modulate = Color(0,1,0)
		#if (event is InputEventMouseButton):
			#if (event.pressed):
				#var x=int((event.position.x - 243)/$tablero.square_size.x)
				#var y=8-int((event.position.y)/$tablero.square_size.x)
				#var sq=get_square(x, y)
				#var piece=search_in(sq)
				
			if (first_target !=null):
				if (_piece != null):
					first_target=_piece

					
					#first_target.move_piece(sq)
				else:
					pass
			#else: #assign first target
				#if (piece==null):
						#return
				#if (turn):
						# piece.ficha.team == Types.Team.White
						#first_target=piece
				#else:
						# piece.ficha.team == Types.Team.Black
						#first_target=piece
			#else:
				#pass
		
		
						
		
	#func get_square(x, y):
			#var charini=65
			#var pos=char(charini+x-1)+str(y)
			#return pos
		
		elif (Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("ui_select")) and selector.vul== true :
		
			# Salimos de modo destino al confirmar
			selector.vul = false
			if selector.has_method("set_color"):
				selector.set_color(Color(1,1,1,1))
			else:
				selector.modulate = Color(1,1,1,1)
		
			var x=int(selector.position.x)
			var y=int(selector.position.y)
			
			pos2=Vector2(x,y)
			Logger.d("Confirm destination -> pos:" + str(pos2) + " index:" + str(selector.indice))
			
			
			var piece_2=search_in(pos2,selector)
			
			if pos1 == pos2:
				return
			
		
			if (first_target != null):
				var road_map1 = []
				
				var road_aux = []
				
				var road_map2=[]
				
				if first_target.ficha.id == Types.PieceType.P:
					road_map2.append_array(road_aux)
					road_map2.append_array(road_map1)
				
				
				
				var pieces_index_list = []
				var pieces_index_list2 = []
				
				var white_obs_pieces_list = []
				var black_obs_pieces_list = []
				
				
				for i in road_map1:
					if i in model.full_map:
						pieces_index_list.append(i)
				
				for i in road_map2:
					if i in model.full_map:
						pieces_index_list2.append(i)
						
		
			
						
						
				for j in pieces_index_list:
					for piece in white_pieces:
						if piece.ficha.index ==j:
							white_obs_pieces_list.append(piece)
					
					
					for piece in black_pieces:
						if piece.ficha.index ==j:
							black_obs_pieces_list.append(piece)	
		
						
				
				if (first_target.ficha.team == Types.Team.White and first_target.ficha.id != Types.PieceType.P) :#Si a una pieza blanca (no peon porque esos comen distinto):
					if len(white_obs_pieces_list)>0: # La obstruye otra pieza blanca:
						print("Invalid Movement")
						if first_target.ficha.team == Types.Team.White:
							selector.invalidate()
						else:
							selector2.invalidate()
							return
					
					elif (len(black_obs_pieces_list)>0 and len(white_obs_pieces_list)==0): #No la obstruye una pieza blanca pero si la obstruye una negra
						print("ÑOM")
						get_node("/root/Game").request_move(first_target, pos1, pos2, index_map, false)
						var captured: Node = piece_2
						piece_2 = null
						if captured:
							captured.queue_free()
					# Eliminación de colecciones manejada por Game/BoardModel ahora
					model.remove_piece_index(piece_2.ficha.index)
					if (piece_2.ficha.id == Types.PieceType.K):
						end_game()
							
						turn = not(turn)		
						turn_handler()
						
					
					elif (len(black_obs_pieces_list)==0 and len(white_obs_pieces_list)==0):
						get_node("/root/Game").request_move(first_target, pos1, pos2, index_map, false)
						if first_target.global_position == Vector2(pos2.x-48, pos2.y+50):
							turn = not(turn)
							turn_handler()
								
							
				
				elif (first_target.ficha.team == Types.Team.White and first_target.ficha.id == Types.PieceType.P) :
								
					
					if piece_2 != null:
						if piece_2 in white_pieces:
							selector.invalidate()
							return
					
						elif piece_2 in black_pieces:
							var list = []
							for j in road_aux :
								list.append(index_map[j])
								
							
							if pos2 in list:
								get_node("/root/Game").request_move(first_target, pos1, pos2, index_map, true)
								print("ÑOM")
								var captured: Node = piece_2
								piece_2 = null
								if captured:
									captured.queue_free()
								# Eliminación de colecciones manejada por Game/BoardModel ahora
								model.remove_piece_index(piece_2.ficha.index)
								if (piece_2.ficha.id == Types.PieceType.K):
									end_game()
								turn = not(turn)
								turn_handler()
								
							else:
								selector.invalidate()
								print("Invalid Movement")
								return
					
					else: #No la obstruye nada
						get_node("/root/Game").request_move(first_target, pos1, pos2, index_map, false)
						if first_target.global_position == Vector2(pos2.x-48, pos2.y+50):
							turn = not(turn)
							turn_handler()
					
			
				
				elif (first_target.ficha.team == Types.Team.Black):
					Logger.d("NOT YOUR PIECE")
					
					selector.invalidate()
					
		
			
			

	elif turn == false:
		if (Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("ui_select")) and selector2.vul== false :
		
			var x=int(selector2.position.x)
			var y=int(selector2.position.y)
			
			
			pos1= Vector2(x,y)
			Logger.d("(Black) Select origin -> pos:" + str(pos1) + " index:" + str(selector2.indice))
			
			
			
			var piece=search_in(pos1,selector2)
			first_target=piece
			# Entramos en modo destino
			selector2.vul = true
			if selector2.has_method("set_color"):
				selector2.set_color(Color(0,1,0))
			else:
				selector2.modulate = Color(0,1,0)
		#if (event is InputEventMouseButton):
			#if (event.pressed):
				#var x=int((event.position.x - 243)/$tablero.square_size.x)
				#var y=8-int((event.position.y)/$tablero.square_size.x)
				#var sq=get_square(x, y)
				#var piece=search_in(sq)
				
			if (first_target !=null):
				if (piece != null):
					first_target=piece
					pawn_conquerable = first_target.pawn_eat(pos1, index_map, selector2)
					
					#first_target.move_piece(sq)
				else:
					pass
			#else: #assign first target
				#if (piece==null):
						#return
				#if (turn):
						# piece.ficha.team == Types.Team.White
						#first_target=piece
				#else:
						# piece.ficha.team == Types.Team.Black
						#first_target=piece
			#else:
				#pass
		
		
						
		
	#func get_square(x, y):
			#var charini=65
			#var pos=char(charini+x-1)+str(y)
			#return pos
		
		elif (Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("ui_select")) and selector2.vul== true :
		
			# Salimos de modo destino al confirmar (volverá a ajustarse con turn_handler)
			selector2.vul = false
			if selector2.has_method("set_color"):
				selector2.set_color(Color(0,0,0))
			else:
				selector2.modulate = Color(0,0,0)
		
			var x=int(selector2.position.x)
			var y=int(selector2.position.y)
			
			pos2=Vector2(x,y)
			Logger.d("(Black) Confirm destination -> pos:" + str(pos2) + " index:" + str(selector2.indice))
			
			if pos1 == pos2:
				return
			
			var piece_2=search_in(pos2,selector2)
			
			var road_map1 = []
				
			var road_aux = []
				
			var road_map2=[]
				
			if first_target.ficha.id == Types.PieceType.P:
					road_map2.append_array(road_aux)
					road_map2.append_array(road_map1)
			
		
			if (first_target != null):
				
				
				var pieces_index_list = []
				var white_obs_pieces_list = []
				var black_obs_pieces_list = []
				var white_pawn_eat_obs= []
				var black_pawn_eat_obs= []
				
				var white_pawn_eat_obs_pieces= []
				var black_pawn_eat_obs_pieces= []
				
				for i in road_map1:
					if i in model.full_map:
						pieces_index_list.append(i)
						
					
						
				for j in pieces_index_list:
					for piece in white_pieces:
						if piece.ficha.index ==j:
							white_obs_pieces_list.append(piece)
					
					
					for piece in black_pieces:
						if piece.ficha.index ==j:
							black_obs_pieces_list.append(piece)	
							
							
			
				
				
		
						
				
				if (first_target.ficha.team == Types.Team.White):
					Logger.d("NOT YOUR PIECE")
					selector2.invalidate()
					turn_handler()
					
			
				
				elif (first_target.ficha.team == Types.Team.Black and first_target.ficha.id != Types.PieceType.P):
					if len(black_obs_pieces_list)>0: 
						print("Invalid Movement")
						if first_target.ficha.team == Types.Team.White:
							selector.invalidate()
						else:
							selector2.invalidate()
						return
					
					elif (len(white_obs_pieces_list)>0 and len(black_obs_pieces_list)==0): 
						print("ÑOM")
						get_node("/root/Game").request_move(first_target, pos1, pos2, index_map, false)
						var captured2: Node = piece_2
						piece_2 = null
						if captured2:
							captured2.queue_free()
						# Eliminación de colecciones manejada por Game/BoardModel ahora
						model.remove_piece_index(piece_2.ficha.index)
						if (piece_2.ficha.id == Types.PieceType.K):
									end_game()
						turn = not(turn)		
						turn_handler()
						
					elif (len(white_obs_pieces_list)==0 and len(black_obs_pieces_list)==0):
						get_node("/root/Game").request_move(first_target, pos1, pos2, index_map, false)
						
						if first_target.global_position == Vector2(pos2.x-48, pos2.y+50):
							turn = not(turn)		
							turn_handler()
					
				elif (first_target.ficha.team == Types.Team.Black and first_target.ficha.id == Types.PieceType.P) :
					
					
					if piece_2 != null:
						if piece_2 in black_pieces:
							selector2.invalidate()
							return
					
						elif piece_2 in white_pieces:
							var list = []
							for j in road_aux :
								list.append(index_map[j])
								
							
							if pos2 in list:
								
								get_node("/root/Game").request_move(first_target, pos1, pos2, index_map, true)
								print("ÑOM")
								var captured3: Node = piece_2
								piece_2 = null
								if captured3:
									captured3.queue_free()
								# Eliminación de colecciones manejada por Game/BoardModel ahora
								model.remove_piece_index(piece_2.ficha.index)
								if (piece_2.ficha.id == Types.PieceType.K):
									end_game()
								
								turn = not(turn)
								turn_handler()
								
								
				
								
							else:
								selector.invalidate()
								print("Invalid Movement")
								return
					
					else: #No la obstruye nada
						get_node("/root/Game").request_move(first_target, pos1, pos2, index_map, false)
						if first_target.global_position == Vector2(pos2.x-48, pos2.y+50):
							turn = not(turn)
							turn_handler()	
				
				
			
			


			
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
		if selector.has_method("set_color"): selector.set_color(Color(1,1,1,1))
		selector2.visible = false
		selector.visible = true
	else:
		if selector2.has_method("set_color"): selector2.set_color(Color(0,0,0))
		selector.visible = false
		selector2.visible = true

func _on_cancel_selection() -> void:
	is_selecting_target = false
	input_controller.set_selecting_target(false)
	if turn:
		selector.show_neutral_white()
		selector2.visible = false
		selector.visible = true
	else:
		selector2.show_neutral_black()
		selector.visible = false
		selector2.visible = true

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
	_flash_status("Movimiento inválido", Color(1,0.3,0.3,1))

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
	_flash_status(msg, Color(1,1,0.6,1))
	turn_banner_delay_ms = 1.2

func _on_turn_changed(is_white: bool) -> void:
	turn = is_white
	is_selecting_target = false
	input_controller.set_selecting_target(false)
	turn_handler()
	if turn_banner_delay_ms > 0.0:
		await get_tree().create_timer(turn_banner_delay_ms).timeout
		turn_banner_delay_ms = 0.0
	_flash_status(("Turno Blancas" if turn else "Turno Negras"), Color(1,1,1,1))

func _flash_status(text: String, color: Color) -> void:
	if status_layer and status_layer.has_method("show_message"):
		status_layer.show_message(text, color, 1.2)

func _on_hover_index(idx: int) -> void:
	if hover_marker and hover_marker.has_method("set_index"):
		hover_marker.set_index(idx, index_map)
