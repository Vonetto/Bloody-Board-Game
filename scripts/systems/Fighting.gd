extends Node

# Autoload or singleton orchestrator for fighting mode

const Types = preload("res://scripts/game_logic/Types.gd")
const FightInputController = preload("res://scripts/systems/FightInputController.gd")
const FightHud = preload("res://scripts/ui/FightHud.gd")
const FightingModel = preload("res://scripts/systems/FightingModel.gd")
const FightResolver = preload("res://scripts/systems/FightResolver.gd")
const HitboxEditor = preload("res://scripts/tools/HitboxEditor.gd")

var round_time_sec: float = 45.0
var arena_scene := preload("res://Floor.tscn")

var arena: Node = null
var attacker_node: Node = null
var defender_node: Node = null
var input_controller: FightInputController = null
var fight_hud: FightHud = null
var round_timer: Timer = null
var time_left: float = 0.0
var model: FightingModel = null
var fight_resolver: FightResolver = null # << NUEVO

func _ready() -> void:
	var game = get_node_or_null("/root/Game")
	if game:
		game.fighting_enabled = true
		game.fight_requested.connect(_on_fight_requested)
		Logger.d("[Fighting] Enabled fighting mode and connected to Game.fight_requested")

func _on_fight_requested(attacker, defender, from_idx: int, to_idx: int) -> void:
	Logger.d("[Fighting] Requested: %s vs %s" % [attacker.ficha.id, defender.ficha.id])
	
	if arena:
		arena.queue_free()
	arena = arena_scene.instantiate()
	get_tree().root.add_child(arena)
	if arena is CanvasItem:
		arena.z_index = 10000

	var cam: Camera2D = arena.get_node_or_null("Camera2D") as Camera2D
	if cam == null:
		cam = Camera2D.new()
		cam.name = "Camera2D"
		arena.add_child(cam)
	cam.make_current()
	
	# Ocultar y deshabilitar colisiones de piezas instanciadas por Floor para evitar duplicación
	for child in arena.get_children():
		if child is CharacterBody2D and (str(child.name).begins_with("red_") or str(child.name).begins_with("blue_")):
			child.visible = false
			var collision_shapes: Array = child.find_children("*CollisionShape*", "CollisionShape2D", true)
			for shape in collision_shapes:
				shape.set_deferred("disabled", true)
	
	var main := get_tree().current_scene
	if main:
		main.visible = false
		var status_hud := main.get_node_or_null("StatusHud")
		if status_hud and status_hud is CanvasItem:
			status_hud.visible = false

	var spawn_a := arena.get_node_or_null("spawn_a")
	var spawn_b := arena.get_node_or_null("spawn_b")
	
	if spawn_a == null: spawn_a = Node2D.new(); spawn_a.name = "spawn_a"; spawn_a.position = Vector2(300, 500); arena.add_child(spawn_a)
	if spawn_b == null: spawn_b = Node2D.new(); spawn_b.name = "spawn_b"; spawn_b.position = Vector2(900, 500); arena.add_child(spawn_b)

	attacker_node = _instantiate_fighter(attacker.ficha.team, attacker.ficha.id)
	defender_node = _instantiate_fighter(defender.ficha.team, defender.ficha.id)
	
	if attacker_node: arena.add_child(attacker_node); attacker_node.global_position = spawn_a.global_position
	if defender_node: arena.add_child(defender_node); defender_node.global_position = spawn_b.global_position

	call_deferred("_recenter_camera")
	
	if input_controller: input_controller.queue_free()
	input_controller = FightInputController.new()
	add_child(input_controller)
	input_controller.enable()

	if attacker_node.has_method("set_player_id"): attacker_node.set_player_id(1)
	if defender_node.has_method("set_player_id"): defender_node.set_player_id(2)
	
	# Configurar capas de colisión ahora que los IDs están asignados
	print("[Fighting] Configuring layers for attacker...")
	if attacker_node.has_method("configure_collision_layers"): attacker_node.configure_collision_layers()
	print("[Fighting] Configuring layers for defender...")
	if defender_node.has_method("configure_collision_layers"): defender_node.configure_collision_layers()

	# Forzar al motor de físicas a procesar los cambios de capa antes de continuar.
	await get_tree().physics_frame
	
	input_controller.action_move.connect(func(p, dir): _on_player_move(p, dir))
	input_controller.action_jump.connect(func(p): _on_player_jump(p))
	input_controller.action_attack.connect(func(p): _on_player_attack(p))
	input_controller.action_block.connect(func(p): _on_player_block(p))
	input_controller.action_dash.connect(func(p): _on_player_dash(p))

	if fight_hud: fight_hud.queue_free()
	fight_hud = FightHud.new()
	add_child(fight_hud)
	
	var p1_name := _get_piece_display_name(attacker.ficha.team, attacker.ficha.id)
	var p2_name := _get_piece_display_name(defender.ficha.team, defender.ficha.id)
	
	if model: model.queue_free()
	model = FightingModel.new()
	add_child(model)
	model.setup(attacker.ficha.team, attacker.ficha.id, defender.ficha.team, defender.ficha.id, attacker, defender)
	fight_hud.setup_fight(p1_name, model.get_hp(1), p2_name, model.get_hp(2))
	
	# --- NUEVA LÓGICA DE CONEXIÓN DE DAÑO ---
	if fight_resolver: fight_resolver.queue_free()
	fight_resolver = FightResolver.new()
	add_child(fight_resolver)
	fight_resolver.connect_fighters(attacker_node, defender_node)
	# Conectamos la señal de daño del modelo al HUD
	# (Asumiendo que el modelo ahora manejará el estado de la vida)
	# model.hp_changed.connect(fight_hud.update_hp)

	if round_timer: round_timer.queue_free()
	round_timer = Timer.new()
	round_timer.one_shot = false
	round_timer.wait_time = 0.1
	arena.add_child(round_timer)
	round_timer.timeout.connect(_on_round_tick)
	round_timer.start()
	
	time_left = round_time_sec

	var editor = HitboxEditor.new()
	editor.name = "HitboxEditor"
	arena.add_child(editor)
	editor.target_node = attacker_node
	
	set_meta("attacker", attacker)
	set_meta("defender", defender)
	set_meta("from_idx", from_idx)
	set_meta("to_idx", to_idx)

func _finish_fight(result: String) -> void:
	var game = get_node_or_null("/root/Game")
	if game:
		game.resolve_fight(result)
	
	if round_timer: round_timer.queue_free(); round_timer = null
	if input_controller: input_controller.queue_free(); input_controller = null
	if fight_hud: fight_hud.queue_free(); fight_hud = null
	if fight_resolver: fight_resolver.queue_free(); fight_resolver = null
	if arena: arena.queue_free(); arena = null
	
	attacker_node = null
	defender_node = null
	
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
	return "%s %s" % [team_str, piece_str]

func _on_player_move(player: int, direction: Vector2) -> void:
	var fighter = attacker_node if player == 1 else defender_node
	if fighter: fighter.move(direction)

func _on_player_jump(player: int) -> void:
	var fighter = attacker_node if player == 1 else defender_node
	if fighter: fighter.jump()

func _on_player_attack(player: int) -> void:
	var fighter = attacker_node if player == 1 else defender_node
	if fighter: fighter.attack()

func _on_player_block(player: int) -> void:
	var fighter = attacker_node if player == 1 else defender_node
	if fighter: fighter.block()

func _on_player_dash(player: int) -> void:
	var fighter = attacker_node if player == 1 else defender_node
	if fighter: fighter.dash()

func _instantiate_fighter(team: int, piece_type: int) -> Node:
	var path := _fighter_scene_path(team, piece_type)
	if path.is_empty(): return null
	var ps: PackedScene = load(path)
	if ps == null: return null
	return ps.instantiate()

func _recenter_camera() -> void:
	if arena == null: return
	var cam: Camera2D = arena.get_node_or_null("Camera2D") as Camera2D
	if cam == null: return
	cam.global_position = Vector2(600, 400)
	cam.zoom = Vector2.ONE
	cam.make_current()

func _fighter_scene_path(team: int, piece_type: int) -> String:
	var base := "res://Fight_Pieces/%s/%s/%s.tscn"
	var color_dir := ("Blue_Pieces" if team == Types.Team.White else "Red_Pieces")
	var piece_name := ""
	var scene_name := ""
	match piece_type:
		Types.PieceType.P: piece_name = "Pawn"; scene_name = "pawn"
		Types.PieceType.N: piece_name = "Knight"; scene_name = "knight"
		Types.PieceType.B: piece_name = "Bishop"; scene_name = "bishop"
		Types.PieceType.R: piece_name = "Rook"; scene_name = "rook"
		Types.PieceType.Q: piece_name = "Queen"; scene_name = "queen"
		Types.PieceType.K: piece_name = "King"; scene_name = "king"
		_: return ""
	
	var color_prefix = "blue_" if team == Types.Team.White else "red_"
	
	return base % [color_dir, color_dir.substr(0, color_dir.find("_")) + "_" + piece_name, color_prefix + scene_name]

# La función _on_hit_dealt() ha sido eliminada ya que es obsoleta.
