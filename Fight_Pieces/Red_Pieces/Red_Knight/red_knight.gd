extends CharacterBody2D


const SPEED = 800.0
const JUMP_VELOCITY = -1000.0
const IMPULSO_ATACK = 2500

var health = 5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")*3
@onready var pivot = $pivot
@onready var animation_player = $AnimationPlayer
@onready var animation_tree = $AnimationTree
@onready var playback = animation_tree.get("parameters/playback")
@onready var area_2d = $pivot/Area2D

func _ready():
	animation_tree.active = true
	area_2d.body_entered.connect(_on_body_entered)
	
func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("red_jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("red_left", "red_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	if direction>0:
		pivot.scale.x = 1
	elif direction<0:
		pivot.scale.x = -1

	move_and_slide()
	
	
	if Input.is_action_just_pressed("Red_Attack"):
		_attack()
	else:
		playback.travel("red_knight_idle")
		
func _attack():
	playback.call_deferred("travel", "attack")
	
func _on_body_entered(body: Node):
	if body.has_method("take_damage"):
		body.take_damage()
	if body is CharacterBody2D:
		var character = body as CharacterBody2D
		character.velocity = (character.global_position - global_position).normalized()*IMPULSO_ATACK
		
func take_damage():
	health -= health 
	print("-1 red")
