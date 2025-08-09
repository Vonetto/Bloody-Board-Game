extends CharacterBody2D

const Logger = preload("res://scripts/Logger.gd")

const SPEED: float = 800.0
const JUMP_VELOCITY: float = -1000.0
const DASH_IMPULSE: float = 1200.0

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity") * 3.0
@onready var pivot: Node2D = $pivot

var player_id: int = 0
var desired_direction: float = 0.0
var jump_requested: bool = false
var facing: int = 1
var block_active: bool = false
var dash_cooldown: float = 0.0

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

	if jump_requested and is_on_floor():
		velocity.y = JUMP_VELOCITY
		jump_requested = false

	if absf(desired_direction) > 0.01:
		velocity.x = desired_direction * SPEED
		facing = 1 if desired_direction > 0.0 else -1
		pivot.scale.x = facing
	else:
		velocity.x = move_toward(velocity.x, 0.0, SPEED)

	if dash_cooldown > 0.0:
		dash_cooldown = max(0.0, dash_cooldown - delta)

	move_and_slide()

func set_player_id(id: int) -> void:
	player_id = id

func move(direction: Vector2) -> void:
	desired_direction = clamp(direction.x, -1.0, 1.0)

func jump() -> void:
	jump_requested = true

func attack() -> void:
	if pivot:
		var orig := pivot.modulate
		pivot.modulate = Color(1.0, 0.9, 0.3)
		await get_tree().create_timer(0.12).timeout
		pivot.modulate = orig
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
