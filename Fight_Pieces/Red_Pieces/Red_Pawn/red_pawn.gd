extends CharacterBody2D

const Logger = preload("res://scripts/Logger.gd")

const SPEED: float = 800.0
const JUMP_VELOCITY: float = -1000.0
const DASH_IMPULSE: float = 1200.0
# Movimiento
const ACCELERATION: float = 3000.0
const DECELERATION: float = 3800.0
const TURN_DECELERATION: float = 5200.0
const FLIP_VEL_EPSILON: float = 20.0
const PIXEL_SNAP: bool = true

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity") * 3.0
@onready var pivot: Node2D = $pivot
@onready var sprite: Sprite2D = $pivot/Sprite2D
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var anim_tree: AnimationTree = $AnimationTree

var player_id: int = 0
var desired_direction: float = 0.0
var jump_requested: bool = false
var facing: int = 1
var block_active: bool = false
var dash_cooldown: float = 0.0
var attack_cooldown: float = 0.0

var hitbox_area: Area2D = null
var hurtbox_area: Area2D = null
var hit_shape_nodes: Array[CollisionShape2D] = []
var hurt_shape_nodes: Array[CollisionShape2D] = []

signal hit_dealt(attacking_player: int, damage: int, target: Node)

# MODIFICADO: Rutas para los sprites del Peón Rojo
const IDLE_TEXTURE := preload("res://assets/Characters Fight/idles/red_idles/B_pawn_idle.png")
const ATTACK_TEXTURE := preload("res://assets/Characters Fight/Punches/red_punches/B_pawn_attack.png")

const LAYER_HURTBOX: int = 1 << 2
const LAYER_HITBOX: int = 1 << 3

# MODIFICADO: Usando el JSON del peón azul. Crea uno nuevo si las animaciones son diferentes.
const BOXES_JSON_PATH := "res://assets/Characters Fight/Punches/blue_punches/WP_boxes_active.json"
var boxes_data: Dictionary = {}
var frame_size: Vector2 = Vector2(64, 52)
var pivot_px: Vector2 = Vector2(32, 52)
var active_frames: Array = []
var attack_fps: float = 10.0
var attack_frames_count: int = 5
var extra_freeze_ms: int = 250

func get_boxes_data() -> Dictionary:
	return boxes_data

func set_boxes_data(data: Dictionary) -> void:
	boxes_data = data
	var fr: Array = (boxes_data.get("frames", []) as Array)
	attack_frames_count = fr.size()

func _ready() -> void:
	_load_boxes()
	_setup_areas()
	sprite.texture = IDLE_TEXTURE
	sprite.hframes = 2
	sprite.frame = 0

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

	if jump_requested and is_on_floor():
		velocity.y = JUMP_VELOCITY
		jump_requested = false

	# Aceleración/desaceleración suave y giro controlado
	var has_input := absf(desired_direction) > 0.01
	if has_input:
		var target_velocity_x := desired_direction * SPEED
		var same_sign := signf(target_velocity_x) == signf(velocity.x) or absf(velocity.x) < 1.0
		var accel := ACCELERATION if same_sign else TURN_DECELERATION
		velocity.x = move_toward(velocity.x, target_velocity_x, accel * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, DECELERATION * delta)

	# Flip visual basado en movimiento real (evita salto al invertir)
	var new_facing := facing
	if absf(velocity.x) > FLIP_VEL_EPSILON:
		new_facing = 1 if velocity.x > 0.0 else -1
	if new_facing != facing:
		facing = new_facing
		pivot.scale.x = facing

	if dash_cooldown > 0.0:
		dash_cooldown = max(0.0, dash_cooldown - delta)
	if attack_cooldown > 0.0:
		attack_cooldown = max(0.0, attack_cooldown - delta)

	move_and_slide()
	if PIXEL_SNAP:
		position = position.round()

func set_player_id(id: int) -> void:
	player_id = id

func move(direction: Vector2) -> void:
	desired_direction = clamp(direction.x, -1.0, 1.0)

func jump() -> void:
	jump_requested = true

func attack() -> void:
	if attack_cooldown > 0.0:
		return
	var total_duration := _estimate_attack_duration()
	attack_cooldown = max(0.6, total_duration)
	await _play_attack_animation()
	Logger.d("[PawnRed] P%d attack" % player_id)

func block() -> void:
	if block_active:
		return
	block_active = true
	if pivot:
		var orig := pivot.modulate
		pivot.modulate = Color(0.5, 0.7, 1.0)
		await get_tree().create_timer(0.25).timeout
		pivot.modulate = orig
	block_active = false
	Logger.d("[PawnRed] P%d block" % player_id)

func dash() -> void:
	if dash_cooldown > 0.0:
		return
	velocity.x += float(facing) * DASH_IMPULSE
	dash_cooldown = 0.6
	Logger.d("[PawnRed] P%d dash" % player_id)

func set_attack_frame(frame_index: int) -> void:
	if anim_tree and anim_tree.is_active():
		anim_tree.active = false
	if anim_player and anim_player.is_playing():
		anim_player.stop()
	if sprite == null:
		return
	sprite.texture = ATTACK_TEXTURE
	sprite.hframes = attack_frames_count
	var idx: int = clamp(frame_index, 0, max(0, attack_frames_count - 1))
	var max_index: int = max(0, int(sprite.vframes * sprite.hframes) - 1)
	sprite.frame = clamp(idx, 0, max_index)

func _load_boxes() -> void:
	var file: FileAccess = FileAccess.open(BOXES_JSON_PATH, FileAccess.READ)
	if file:
		var parsed: Variant = JSON.parse_string(file.get_as_text())
		if typeof(parsed) == TYPE_DICTIONARY:
			boxes_data = parsed as Dictionary
			attack_fps = float(boxes_data.get("fps", 10))
			var fs: Dictionary = (boxes_data.get("frame_size", {}) as Dictionary)
			frame_size = Vector2(float(fs.get("w", 64)), float(fs.get("h", 52)))
			var pv: Dictionary = (boxes_data.get("pivot", {}) as Dictionary)
			pivot_px = Vector2(float(pv.get("x", 32)), float(pv.get("y", 52)))
			active_frames = (boxes_data.get("active_frames", []) as Array)
			var fr: Array = (boxes_data.get("frames", []) as Array)
			attack_frames_count = fr.size()
		else:
			Logger.w("[PawnRed] Boxes JSON malformed, using defaults")
	else:
		Logger.w("[PawnRed] Could not open boxes JSON at %s" % BOXES_JSON_PATH)

func _setup_areas() -> void:
	if not hitbox_area:
		hitbox_area = Area2D.new()
		hitbox_area.name = "HitboxArea"
		hitbox_area.collision_layer = LAYER_HITBOX
		hitbox_area.collision_mask = LAYER_HURTBOX
		pivot.add_child(hitbox_area)
		hitbox_area.area_entered.connect(_on_hitbox_area_entered)
	if not hurtbox_area:
		hurtbox_area = Area2D.new()
		hurtbox_area.name = "HurtboxArea"
		hurtbox_area.collision_layer = LAYER_HURTBOX
		hurtbox_area.collision_mask = LAYER_HITBOX
		pivot.add_child(hurtbox_area)

	var idle_hurtbox_shape = RectangleShape2D.new()
	idle_hurtbox_shape.size = Vector2(11, 24)
	var idle_hurtbox = CollisionShape2D.new()
	idle_hurtbox.name = "IdleHurtbox"
	idle_hurtbox.shape = idle_hurtbox_shape
	var hurtbox_pos_x = 9 - pivot_px.x + (11 * 0.5)
	var hurtbox_pos_y = 41 - pivot_px.y + (24 * 0.5)
	idle_hurtbox.position = Vector2(hurtbox_pos_x, hurtbox_pos_y)
	hurtbox_area.add_child(idle_hurtbox)
	hitbox_area.monitoring = false

func _clear_shapes(nodes: Array[CollisionShape2D]) -> void:
	for n in nodes:
		if is_instance_valid(n):
			n.queue_free()
	nodes.clear()

func _ensure_shapes(area: Area2D, nodes: Array[CollisionShape2D], count: int) -> void:
	while nodes.size() < count:
		var cs: CollisionShape2D = CollisionShape2D.new()
		area.add_child(cs)
		nodes.append(cs)
	while nodes.size() > count:
		var last: CollisionShape2D = nodes.pop_back() as CollisionShape2D
		if is_instance_valid(last):
			last.queue_free()

func _rect_center_local(rect: Dictionary) -> Vector2:
	var w := float(rect.get("w", 0))
	var h := float(rect.get("h", 0))
	var x := float(rect.get("x", 0))
	var y := float(rect.get("y", 0))
	return Vector2(x - pivot_px.x + w * 0.5, y - pivot_px.y + h * 0.5)

func _estimate_attack_duration() -> float:
	var base := 1.0 / attack_fps
	return base * float(attack_frames_count) + float(extra_freeze_ms) / 1000.0

func _apply_frame_boxes(frame_index: int, _show_hit_debug: bool) -> void:
	var frames: Array = boxes_data.get("frames", []) as Array
	if frame_index < 0 or frame_index >= frames.size():
		return
	var f: Dictionary = frames[frame_index]
	var hit_rects: Array = f.get("hit", []) as Array
	var hurt_rects: Array = f.get("hurt", []) as Array
	
	_ensure_shapes(hitbox_area, hit_shape_nodes, hit_rects.size())
	for i in range(hit_rects.size()):
		var r: Dictionary = hit_rects[i]
		var cs: CollisionShape2D = hit_shape_nodes[i]
		var rect := RectangleShape2D.new()
		rect.size = Vector2(float(r.get("w", 0)), float(r.get("h", 0)))
		cs.shape = rect
		cs.position = _rect_center_local(r)
	
	_ensure_shapes(hurtbox_area, hurt_shape_nodes, hurt_rects.size())
	for j in range(hurt_rects.size()):
		var rr: Dictionary = hurt_rects[j]
		var cs2: CollisionShape2D = hurt_shape_nodes[j]
		var rect2 := RectangleShape2D.new()
		rect2.size = Vector2(float(rr.get("w", 0)), float(rr.get("h", 0)))
		cs2.shape = rect2
		cs2.position = _rect_center_local(rr)

func _play_attack_animation() -> void:
	velocity.x = 0.0

	var base := 1.0 / attack_fps
	var durations: Array = []
	for _i in range(attack_frames_count):
		durations.append(base)
	durations[durations.size() - 1] = base + float(extra_freeze_ms) / 1000.0
	
	if anim_tree:
		anim_tree.active = false
	if anim_player:
		anim_player.stop()

	sprite.texture = ATTACK_TEXTURE
	sprite.hframes = attack_frames_count
	sprite.frame = 0

	var idle_hurtbox = hurtbox_area.get_node_or_null("IdleHurtbox")
	if idle_hurtbox:
		idle_hurtbox.disabled = true

	var hit_once: bool = false
	var max_index: int = max(0, int(sprite.vframes * sprite.hframes) - 1)
	
	for i in range(attack_frames_count):
		if i > max_index:
			Logger.w("[PawnRed] Attack frame %d is out of bounds for sprite (max: %d). Check JSON vs Texture." % [i, max_index])
			break

		var is_active: bool = active_frames.has(i)
		_apply_frame_boxes(i, true)
		hitbox_area.monitoring = is_active
		sprite.frame = i
		if is_active and not hit_once:
			await get_tree().process_frame
			var overlaps: Array = hitbox_area.get_overlapping_areas()
			for a in overlaps:
				var other: Area2D = a as Area2D
				if other and other.name == "HurtboxArea":
					var target_pivot := other.get_parent()
					var target_root := target_pivot.get_parent() if target_pivot else null
					if target_root and target_root.has_method("set_player_id"):
						var damage := 18
						hit_dealt.emit(player_id, damage, target_root)
						Logger.d("[PawnRed] Overlap hit %s for %d damage at frame %d" % [target_root.name, damage, i])
						hit_once = true
						break
		await get_tree().create_timer(float(durations[i])).timeout
	
	_clear_shapes(hit_shape_nodes)
	_clear_shapes(hurt_shape_nodes)
	if idle_hurtbox:
		idle_hurtbox.disabled = false

	sprite.texture = IDLE_TEXTURE
	sprite.hframes = 2
	sprite.frame = 0
	if anim_tree:
		anim_tree.active = true
	if anim_player:
		anim_player.play("red_pawn_idle")

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area == null or area.name != "HurtboxArea":
		return
	var fighter := area.get_parent()
	if fighter and fighter.get_parent() and fighter.get_parent().has_method("set_player_id"):
		var target: Node = fighter.get_parent()
		var damage := 18
		hit_dealt.emit(player_id, damage, target)
		Logger.d("[PawnRed] Hit %s for %d damage (area)" % [target.name, damage])
