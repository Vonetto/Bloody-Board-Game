extends CharacterBody2D


const SPEED = 800.0
const JUMP_VELOCITY = -1000.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")*3
@onready var pivot = $pivot
@onready var animation_tree = $AnimationTree
@onready var animation_player = $AnimationPlayer
@onready var playback = animation_tree.get("parameters/playback")

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	if direction>0:
		pivot.scale.x = 1
	elif direction<0:
		pivot.scale.x = -1

	move_and_slide()
	
	if Input.is_action_just_pressed("Attack"):
		_attack()
	else:
		playback.travel("red_queen_idle")
		

func _attack():
	playback.call_deferred("travel", "Attack")
