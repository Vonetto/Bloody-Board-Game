class_name BaseFighter
extends CharacterBody2D

# Base fighter behavior for all pieces. Child scripts configure assets via exports or in _ready.

signal hit_landed(hurtbox_area: Area2D)
signal stamina_changed(new_stamina: float, max_stamina: float)

# --- STATS ---
@export var max_health: int = 100
@export var attack_power: int = 15
@export var defense: int = 10

# --- STAMINA ---
@export var max_stamina: float = 100.0
@export var stamina_regen_rate: float = 15.0
@export var stamina_regen_delay: float = 0.8
@export var attack_stamina_cost: float = 15.0

# --- MOVEMENT ---
@export var speed: float = 800.0
@export var jump_velocity: float = -1000.0
@export var dash_impulse: float = 1200.0
@export var acceleration: float = 3000.0
@export var deceleration: float = 3800.0
@export var turn_deceleration: float = 5200.0
@export var flip_velocity_epsilon: float = 20.0
@export var use_pixel_snap: bool = true

# --- ASSETS & ANIMATION ---
@export var idle_texture: Texture2D
@export var idle_hframes: int = 2
@export var idle_animation_name: String = ""
@export var attack_texture: Texture2D
@export var extra_freeze_ms: int = 250
@export var boxes_json_path: String = ""

# --- INTERNAL STATE ---
var current_health: int
var current_stamina: float
var stamina_delay_timer: float = 0.0
var is_exhausted: bool = false

var frame_size: Vector2 = Vector2(64, 52)
var pivot_px: Vector2 = Vector2(32, 52)
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
var is_attacking: bool = false

# --- COMBAT STATE ---
var hitbox_area: Area2D = null
var hurtbox_area: Area2D = null
var hit_shape_nodes: Array[CollisionShape2D] = []
var hurt_shape_nodes: Array[CollisionShape2D] = []
var debug_drawer: Node2D = null
var hitted_bodies: Array[Area2D] = []

# --- DATA LOADING ---
var boxes_data: Dictionary = {}
var active_frames: Array[int] = []
var attack_frames_count: int = 5

func get_boxes_data() -> Dictionary:
	return boxes_data

func set_boxes_data(data: Dictionary) -> void:
	boxes_data = data
	var fr: Array = (boxes_data.get("frames", []) as Array)
	attack_frames_count = fr.size()

# --- GODOT LIFECYCLE ---
func _ready() -> void:
	current_health = max_health
	current_stamina = max_stamina
	_load_boxes()
	_setup_areas()
	_show_idle()
	# Aplicar cajas de reposo iniciales
	_apply_frame_boxes(0, false)

func _manage_stamina(delta: float) -> void:
	if stamina_delay_timer > 0:
		stamina_delay_timer -= delta
		return

	var regen_rate = stamina_regen_rate
	if is_exhausted:
		regen_rate = 10.0 # Slower regen when exhausted as per design

	if current_stamina < max_stamina:
		current_stamina = min(current_stamina + regen_rate * delta, max_stamina)
		emit_signal("stamina_changed", current_stamina, max_stamina)
		if is_exhausted and current_stamina >= max_stamina:
			is_exhausted = false

func spend_stamina(amount: float) -> bool:
	if current_stamina < amount:
		return false
	
	current_stamina -= amount
	stamina_delay_timer = stamina_regen_delay
	emit_signal("stamina_changed", current_stamina, max_stamina)
	
	if current_stamina < 1.0:
		is_exhausted = true
	
	return true

func _physics_process(delta: float) -> void:
	_manage_stamina(delta)
	if not is_on_floor():
		velocity.y += gravity * delta

	if jump_requested and is_on_floor():
		velocity.y = jump_velocity
		jump_requested = false

	var has_input := absf(desired_direction) > 0.01
	if has_input:
		var target_velocity_x := desired_direction * speed
		var same_sign := signf(target_velocity_x) == signf(velocity.x) or absf(velocity.x) < 1.0
		var accel := acceleration if same_sign else turn_deceleration
		velocity.x = move_toward(velocity.x, target_velocity_x, accel * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, deceleration * delta)

	var new_facing := facing
	if absf(velocity.x) > flip_velocity_epsilon:
		new_facing = 1 if velocity.x > 0.0 else -1
	if new_facing != facing:
		facing = new_facing
		if pivot:
			pivot.scale.x = facing

	if dash_cooldown > 0.0: dash_cooldown = max(0.0, dash_cooldown - delta)
	if attack_cooldown > 0.0: attack_cooldown = max(0.0, attack_cooldown - delta)

	move_and_slide()
	if use_pixel_snap: position = position.round()

# --- PUBLIC API ---
func set_player_id(id: int) -> void:
	player_id = id

func configure_collision_layers() -> void:
	print("[" + name + "] Configuring collision layers for player id: ", player_id)
	if player_id == 1:
		hurtbox_area.collision_layer = 1 << 4
		hurtbox_area.collision_mask = 0
		hitbox_area.collision_layer = 1 << 6
		hitbox_area.collision_mask = 1 << 5
	elif player_id == 2:
		hurtbox_area.collision_layer = 1 << 5
		hurtbox_area.collision_mask = 0
		hitbox_area.collision_layer = 1 << 7
		hitbox_area.collision_mask = 1 << 4
	print("[" + name + "] Configured: hurt_layer=", hurtbox_area.collision_layer, ", hit_layer=", hitbox_area.collision_layer, ", hit_mask=", hitbox_area.collision_mask)

func move(direction: Vector2) -> void:
	desired_direction = clamp(direction.x, -1.0, 1.0)

func jump() -> void:
	jump_requested = true

func attack() -> void:
	if attack_cooldown > 0.0 or is_attacking:
		return
	
	# Spend stamina to initiate the attack
	if not spend_stamina(attack_stamina_cost):
		# TODO: Add feedback for "not enough stamina" (e.g., sound effect)
		return

	var total_duration := _estimate_attack_duration()
	attack_cooldown = max(0.6, total_duration)
	await _play_attack_animation()

func take_damage(amount: int) -> void:
	current_health -= amount
	print("%s took %d damage, %d HP left" % [name, amount, current_health])
	# TODO: Play hurt animation, check for death, etc.

# --- HITBOX/HURTBOX LOGIC ---
func _on_hitbox_area_entered(area: Area2D) -> void:
	if not is_attacking or area == null or area.name != "HurtboxArea":
		return
	if hitted_bodies.has(area):
		return
	hitted_bodies.append(area)
	hit_landed.emit(area)

func _play_attack_animation() -> void:
	velocity.x = 0.0
	is_attacking = true
	hitted_bodies.clear()

	var base := 1.0 / float(boxes_data.get("fps", 10.0))
	var durations: Array = []
	for _i in range(attack_frames_count): durations.append(base)
	durations[durations.size() - 1] = base + float(extra_freeze_ms) / 1000.0

	if anim_tree: anim_tree.active = false
	if anim_player: anim_player.stop()

	if attack_texture: sprite.texture = attack_texture
	sprite.hframes = max(1, attack_frames_count)
	sprite.frame = 0

	var max_index: int = max(0, int(sprite.vframes * sprite.hframes) - 1)
	for i in range(attack_frames_count):
		if i > max_index: break
		_apply_frame_boxes(i, true)
		hitbox_area.monitoring = active_frames.has(i)
		sprite.frame = i
		await get_tree().create_timer(float(durations[i])).timeout

	is_attacking = false
	hitbox_area.monitoring = false
	_apply_frame_boxes(0, false)
	_show_idle()

func _apply_frame_boxes(frame_index: int, show_hit_debug: bool) -> void:
	var frames: Array = boxes_data.get("frames", []) as Array
	if frame_index < 0 or frame_index >= frames.size():
		_clear_shapes(hit_shape_nodes)
		_clear_shapes(hurt_shape_nodes)
		return
	
	var f: Dictionary = frames[frame_index]
	var hit_rects: Array = (f.get("hit", []) as Array).duplicate()
	var hurt_rects: Array = (f.get("hurt", []) as Array).duplicate()

	if not is_attacking:
		hit_rects.clear()

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

func _setup_areas() -> void:
	if not hitbox_area:
		hitbox_area = Area2D.new()
		hitbox_area.name = "HitboxArea"
		hitbox_area.z_index = 1000
		hitbox_area.z_as_relative = false
		pivot.add_child(hitbox_area)
		hitbox_area.area_entered.connect(_on_hitbox_area_entered)
	if not hurtbox_area:
		hurtbox_area = Area2D.new()
		hurtbox_area.name = "HurtboxArea"
		hurtbox_area.z_index = 1000
		hurtbox_area.z_as_relative = false
		pivot.add_child(hurtbox_area)

# --- HELPERS ---
func _load_boxes() -> void:
	if boxes_json_path.is_empty(): return
	var file: FileAccess = FileAccess.open(boxes_json_path, FileAccess.READ)
	if file:
		var parsed: Variant = JSON.parse_string(file.get_as_text())
		if typeof(parsed) == TYPE_DICTIONARY:
			boxes_data = parsed as Dictionary
			var fs: Dictionary = (boxes_data.get("frame_size", {}) as Dictionary)
			frame_size = Vector2(float(fs.get("w", frame_size.x)), float(fs.get("h", frame_size.y)))
			var pv: Dictionary = (boxes_data.get("pivot", {}) as Dictionary)
			pivot_px = Vector2(float(pv.get("x", pivot_px.x)), float(pv.get("y", pivot_px.y)))
			var generic_active_frames: Array = boxes_data.get("active_frames", []) as Array
			active_frames.clear()
			for frame in generic_active_frames:
				active_frames.append(int(frame))
			attack_frames_count = (boxes_data.get("frames", []) as Array).size()

func _clear_shapes(nodes: Array[CollisionShape2D]) -> void:
	for n in nodes:
		if is_instance_valid(n): n.queue_free()
	nodes.clear()

func _ensure_shapes(area: Area2D, nodes: Array[CollisionShape2D], count: int) -> void:
	while nodes.size() < count:
		var cs: CollisionShape2D = CollisionShape2D.new()
		area.add_child(cs)
		nodes.append(cs)
	while nodes.size() > count:
		var last: CollisionShape2D = nodes.pop_back() as CollisionShape2D
		if is_instance_valid(last): last.queue_free()

func _rect_center_local(rect: Dictionary) -> Vector2:
	var w := float(rect.get("w", 0))
	var h := float(rect.get("h", 0))
	var x := float(rect.get("x", 0))
	var y := float(rect.get("y", 0))
	return Vector2(x - pivot_px.x + w * 0.5, y - pivot_px.y + h * 0.5)

func _estimate_attack_duration() -> float:
	var fps = float(boxes_data.get("fps", 10.0))
	var base: float = 1.0 / fps
	return base * float(attack_frames_count) + float(extra_freeze_ms) / 1000.0

func set_attack_frame(frame_index: int) -> void:
	if anim_tree: anim_tree.active = false
	if anim_player: anim_player.stop()
	if sprite == null: return
	if attack_texture: sprite.texture = attack_texture
	sprite.hframes = max(1, attack_frames_count)
	var idx: int = clamp(frame_index, 0, max(0, attack_frames_count - 1))
	var max_index: int = max(0, int(sprite.vframes * sprite.hframes) - 1)
	sprite.frame = clamp(idx, 0, max_index)

func _show_idle() -> void:
	if idle_texture:
		sprite.texture = idle_texture
	sprite.hframes = max(1, idle_hframes)
	sprite.frame = 0
	if anim_tree: anim_tree.active = true
	if anim_player and idle_animation_name != "":
		anim_player.play(idle_animation_name)
