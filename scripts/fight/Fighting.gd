extends Node

# Autoload or singleton orchestrator for fighting mode

const Types = preload("res://scripts/Types.gd")
const FightInputController = preload("res://scripts/fight/FightInputController.gd")
const FightHud = preload("res://scripts/fight/FightHud.gd")

var round_time_sec: float = 45.0 # MVP timeout (set to 45.0 later)
# Usar la escena existente del proyecto como arena inicial
var arena_scene := preload("res://Floor.tscn")

var arena: Node = null
var attacker_node: Node = null
var defender_node: Node = null
var input_controller: FightInputController = null
var fight_hud: FightHud = null
var round_timer: Timer = null
var time_left: float = 0.0

func _ready() -> void:
	# Enable fighting feature in Game
	var game = get_node_or_null("/root/Game")
	if game:
		game.fighting_enabled = true
		game.fight_requested.connect(_on_fight_requested)
		Logger.d("[Fighting] Enabled fighting mode and connected to Game.fight_requested")

func _on_fight_requested(attacker, defender, from_idx: int, to_idx: int) -> void:
	# Build arena and spawn corresponding characters
	Logger.d("[Fighting] Requested: %s %s vs %s %s (from %d -> %d)" % [
		("White" if attacker.ficha.team == Types.Team.White else "Black"), attacker.ficha.id,
		("White" if defender.ficha.team == Types.Team.White else "Black"), defender.ficha.id,
		from_idx, to_idx
	])
	if arena:
		arena.queue_free()
		arena = null
	arena = arena_scene.instantiate()
	get_tree().root.add_child(arena)
	# Ensure arena is on top
	if arena is CanvasItem:
		arena.z_index = 10000

	# Si no hay cámara en la arena, crear una por defecto
	var cam: Camera2D = arena.get_node_or_null("Camera2D") as Camera2D
	if cam == null:
		cam = Camera2D.new()
		cam.name = "Camera2D"  # ¡IMPORTANTE! Asignar el nombre
		arena.add_child(cam)
		cam.make_current()
		Logger.d("[Fighting] Fallback Camera2D created for arena")
	else:
		cam.make_current()

	# Ocultar y deshabilitar colisiones de piezas instanciadas por Floor para evitar duplicación
	for child in arena.get_children():
		if child is CharacterBody2D and (str(child.name).begins_with("red_") or str(child.name).begins_with("blue_")):
			child.visible = false
			# Desactivar TODAS las formas de colisión para que no actúen como muros invisibles
			var collision_shapes: Array = child.find_children("*CollisionShape*", "CollisionShape2D", true)
			for shape in collision_shapes:
				shape.set_deferred("disabled", true)
				Logger.d("[Fighting] Disabled collision on pre-placed piece: %s" % shape.get_path())

	# Ocultar la escena principal mientras dura la pelea
	var main := get_tree().current_scene
	if main:
		main.visible = false
		# Si tiene HUD de tablero (StatusHud), ocultarlo para que no muestre mensajes encima
		var status_hud := main.get_node_or_null("StatusHud")
		if status_hud and status_hud is CanvasItem:
			status_hud.visible = false

	# Spawn positions (crear si no existen)
	var spawn_a := arena.get_node_or_null("spawn_a")
	var spawn_b := arena.get_node_or_null("spawn_b")
	
	if spawn_a == null:
		spawn_a = Node2D.new()
		spawn_a.name = "spawn_a"
		spawn_a.position = Vector2(300, 500)
		arena.add_child(spawn_a)
		Logger.d("[Fighting] Created spawn_a at %s" % str(spawn_a.position))
	
	if spawn_b == null:
		spawn_b = Node2D.new()
		spawn_b.name = "spawn_b"
		spawn_b.position = Vector2(900, 500)
		arena.add_child(spawn_b)
		Logger.d("[Fighting] Created spawn_b at %s" % str(spawn_b.position))

	attacker_node = _instantiate_fighter(attacker.ficha.team, attacker.ficha.id)
	defender_node = _instantiate_fighter(defender.ficha.team, defender.ficha.id)
	if attacker_node:
		arena.add_child(attacker_node)
		attacker_node.global_position = spawn_a.global_position
		if attacker_node is CanvasItem:
			attacker_node.z_index = 10
		Logger.d("[Fighting] Attacker spawned at %s" % str(attacker_node.global_position))
	if defender_node:
		arena.add_child(defender_node)
		defender_node.global_position = spawn_b.global_position
		if defender_node is CanvasItem:
			defender_node.z_index = 10
		Logger.d("[Fighting] Defender spawned at %s" % str(defender_node.global_position))
	Logger.d("[Fighting] Arena ready. Fighters spawned: attacker=%s defender=%s" % [str(attacker_node), str(defender_node)])
	
	# Llamar _recenter_camera inmediatamente para debug
	Logger.d("[Fighting] About to call _recenter_camera...")
	_recenter_camera()
	Logger.d("[Fighting] _recenter_camera called")
	
	# También llamar en el siguiente frame
	call_deferred("_recenter_camera")
	
	# Setup input controller
	if input_controller:
		input_controller.queue_free()
	input_controller = FightInputController.new()
	add_child(input_controller)
	input_controller.enable()

	# Conectar señales de input a los fighters
	# Asegurarse de que cada handler reciba la referencia al nodo correcto (atacante o defensor)
	input_controller.action_move.connect(func(p, dir): _on_player_move(p, dir))
	input_controller.action_jump.connect(func(p): _on_player_jump(p))
	input_controller.action_attack.connect(func(p): _on_player_attack(p))
	input_controller.action_block.connect(func(p): _on_player_block(p))
	input_controller.action_dash.connect(func(p): _on_player_dash(p))

	# Setup HUD
	if fight_hud:
		fight_hud.queue_free()
	fight_hud = FightHud.new()
	add_child(fight_hud)
	
	var p1_name := _get_piece_display_name(attacker.ficha.team, attacker.ficha.id)
	var p2_name := _get_piece_display_name(defender.ficha.team, defender.ficha.id)
	fight_hud.setup_fight(p1_name, 100, p2_name, 100) # MVP: 100 HP for all

	# Start timer for MVP: defender survives by timeout
	if round_timer:
		round_timer.queue_free()
	round_timer = Timer.new()
	round_timer.one_shot = false
	round_timer.wait_time = 0.1 # Update every 100ms
	arena.add_child(round_timer)
	round_timer.timeout.connect(_on_round_tick)
	round_timer.start()
	
	time_left = round_time_sec
	Logger.d("[Fighting] Round timer started (%.2f s)" % round_time_sec)
	
	# Store references for cleanup
	set_meta("attacker", attacker)
	set_meta("defender", defender)
	set_meta("from_idx", from_idx)
	set_meta("to_idx", to_idx)

func _finish_fight(result: String) -> void:
	# Get stored references
	var attacker = get_meta("attacker", null)
	var defender = get_meta("defender", null)
	var from_idx: int = get_meta("from_idx", -1)
	var to_idx: int = get_meta("to_idx", -1)
	
	var game = get_node_or_null("/root/Game")
	if game:
		game.resolve_fight(result)
	
	# Cleanup
	Logger.d("[Fighting] Fight finished with result=%s" % result)
	
	if round_timer:
		round_timer.queue_free()
		round_timer = null
	
	if input_controller:
		input_controller.disable()
		input_controller.queue_free()
		input_controller = null
	
	if fight_hud:
		fight_hud.hide_hud()
		fight_hud.queue_free()
		fight_hud = null
	
	if arena:
		arena.queue_free()
		arena = null
		attacker_node = null
		defender_node = null
	
	# Mostrar nuevamente la escena principal
	var main := get_tree().current_scene
	if main:
		main.visible = true
		var status_hud := main.get_node_or_null("StatusHud")
		if status_hud and status_hud is CanvasItem:
			status_hud.visible = true

func _on_round_tick() -> void:
	time_left -= round_timer.wait_time
	if fight_hud:
		fight_hud.update_timer(time_left)
	
	if time_left <= 0:
		round_timer.stop()
		if fight_hud:
			fight_hud.show_message("TIME OUT!", Color.YELLOW)
		await get_tree().create_timer(1.0).timeout
		_finish_fight("defender_survives")

func _get_piece_display_name(team: int, piece_type: int) -> String:
	var team_str := "White" if team == Types.Team.White else "Black"
	var piece_str := ""
	match piece_type:
		Types.PieceType.P: piece_str = "Pawn"
		Types.PieceType.N: piece_str = "Knight"
		Types.PieceType.B: piece_str = "Bishop"
		Types.PieceType.R: piece_str = "Rook"
		Types.PieceType.Q: piece_str = "Queen"
		Types.PieceType.K: piece_str = "King"
		_: piece_str = "Piece"
	return "%s %s" % [team_str, piece_str]

func _on_player_move(player: int, direction: Vector2) -> void:
	var fighter = attacker_node if player == 1 else defender_node
	if fighter and fighter.has_method("move"):
		fighter.move(direction)

func _on_player_jump(player: int) -> void:
	var fighter = attacker_node if player == 1 else defender_node
	if fighter and fighter.has_method("jump"):
		fighter.jump()
		var piece_name := _get_piece_display_name_from_node(fighter)
		Logger.d("[Fighting] %s jumped" % piece_name)

func _on_player_attack(player: int) -> void:
	var fighter = attacker_node if player == 1 else defender_node
	if fighter and fighter.has_method("attack"):
		fighter.attack()
		var piece_name := _get_piece_display_name_from_node(fighter)
		Logger.d("[Fighting] %s attacked" % piece_name)

func _on_player_block(player: int) -> void:
	var fighter = attacker_node if player == 1 else defender_node
	if fighter and fighter.has_method("block"):
		fighter.block()
		var piece_name := _get_piece_display_name_from_node(fighter)
		Logger.d("[Fighting] %s blocked" % piece_name)

func _on_player_dash(player: int) -> void:
	var fighter = attacker_node if player == 1 else defender_node
	if fighter and fighter.has_method("dash"):
		fighter.dash()
		var piece_name := _get_piece_display_name_from_node(fighter)
		Logger.d("[Fighting] %s dashed" % piece_name)

func _instantiate_fighter(team: int, piece_type: int) -> Node:
	var path := _fighter_scene_path(team, piece_type)
	if path == "":
		return null
	var ps: PackedScene = load(path)
	if ps == null:
		if Engine.has_singleton("Logger"):
			Logger.w("[Fighting] Could not load fighter scene: %s" % path)
		return null
	return ps.instantiate()

func _recenter_camera() -> void:
	Logger.d("[Fighting] _recenter_camera START")
	if arena == null:
		Logger.d("[Fighting] _recenter_camera: arena is null, returning")
		return
	var cam: Camera2D = arena.get_node_or_null("Camera2D") as Camera2D
	if cam == null:
		Logger.d("[Fighting] _recenter_camera: camera is null, returning")
		return
	
	# El Floor.tscn tiene contenido alrededor de (600, 400) en coordenadas del mundo
	# Centrar la cámara en el centro del escenario de pelea
	var arena_center := Vector2(600, 400)
	cam.global_position = arena_center
	cam.zoom = Vector2.ONE
	cam.offset = Vector2.ZERO
	cam.make_current()
	
	Logger.d("[Fighting] Camera centered at arena: pos=%s zoom=%s" % [str(cam.global_position), str(cam.zoom)])

func _fighter_scene_path(team: int, piece_type: int) -> String:
	var base := "res://Fight_Pieces/%s/%s/%s.tscn"
	var color_dir := ("Blue_Pieces" if team == Types.Team.White else "Red_Pieces")
	match piece_type:
		Types.PieceType.P:
			return base % [color_dir, ("Blue_Pawn" if team == Types.Team.White else "Red_Pawn"), ("blue_pawn" if team == Types.Team.White else "red_pawn")]
		Types.PieceType.N:
			return base % [color_dir, ("Blue_Knight" if team == Types.Team.White else "Red_Knight"), ("blue_knight" if team == Types.Team.White else "red_knight")]
		Types.PieceType.B:
			return base % [color_dir, ("Blue_Bishop" if team == Types.Team.White else "Red_Bishop"), ("blue_bishop" if team == Types.Team.White else "red_bishop")]
		Types.PieceType.R:
			# Nota: el archivo azul es blue_rock.tscn (nombre histórico)
			if team == Types.Team.White:
				return "res://Fight_Pieces/Blue_Pieces/Blue_Rook/blue_rock.tscn"
			else:
				return base % [color_dir, "Red_Rook", "red_rook"]
		Types.PieceType.Q:
			return base % [color_dir, ("Blue_Queen" if team == Types.Team.White else "Red_Queen"), ("blue_queen" if team == Types.Team.White else "red_queen")]
		Types.PieceType.K:
			return base % [color_dir, ("Blue_King" if team == Types.Team.White else "Red_King"), ("blue_king" if team == Types.Team.White else "red_king")]
	return ""

func _get_piece_display_name_from_node(fighter: Node) -> String:
	if fighter == attacker_node:
		var attacker = get_meta("attacker", null)
		if attacker: return _get_piece_display_name(attacker.ficha.team, attacker.ficha.id)
	elif fighter == defender_node:
		var defender = get_meta("defender", null)
		if defender: return _get_piece_display_name(defender.ficha.team, defender.ficha.id)
	return "Unknown Piece"
