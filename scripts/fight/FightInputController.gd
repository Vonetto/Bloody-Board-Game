extends Node

signal action_attack(player: int)
signal action_block(player: int)
signal action_dash(player: int)
signal action_jump(player: int)
signal action_move(player: int, direction: Vector2)

const Logger = preload("res://scripts/Logger.gd")

var enabled: bool = false
var player1_can_act: bool = true
var player2_can_act: bool = true

const P1_CONTROLS := {
	"move_left": KEY_A, "move_right": KEY_D, "jump": KEY_W,
	"attack": KEY_J, "block": KEY_K, "dash": KEY_L
}
const P2_CONTROLS := {
	"move_left": KEY_LEFT, "move_right": KEY_RIGHT, "jump": KEY_UP,
	"attack": KEY_1, "block": KEY_2, "dash": KEY_3
}

func _ready() -> void:
	set_process(false)
	set_process_unhandled_input(false)

func enable() -> void:
	enabled = true
	player1_can_act = true
	player2_can_act = true
	set_process(true)
	set_process_unhandled_input(true)
	Logger.d("[FightInput] Enabled combat input")

func disable() -> void:
	enabled = false
	set_process(false)
	set_process_unhandled_input(false)
	Logger.d("[FightInput] Disabled combat input")

func _process(_delta: float) -> void:
	if not enabled: return
	_handle_player_movement()

func _unhandled_input(event: InputEvent) -> void:
	if not enabled: return
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		_handle_player_actions(event.physical_keycode)

func _handle_player_movement() -> void:
	# Player 1
	if player1_can_act:
		var dir_x = float(Input.is_key_pressed(P1_CONTROLS.move_right)) - float(Input.is_key_pressed(P1_CONTROLS.move_left))
		action_move.emit(1, Vector2(dir_x, 0))
	# Player 2
	if player2_can_act:
		var dir_x = float(Input.is_key_pressed(P2_CONTROLS.move_right)) - float(Input.is_key_pressed(P2_CONTROLS.move_left))
		action_move.emit(2, Vector2(dir_x, 0))

func _handle_player_actions(key: Key) -> void:
	# Player 1
	if player1_can_act:
		if key == P1_CONTROLS.jump: action_jump.emit(1)
		elif key == P1_CONTROLS.attack: action_attack.emit(1)
		elif key == P1_CONTROLS.block: action_block.emit(1)
		elif key == P1_CONTROLS.dash: action_dash.emit(1)
	# Player 2
	if player2_can_act:
		if key == P2_CONTROLS.jump: action_jump.emit(2)
		elif key == P2_CONTROLS.attack: action_attack.emit(2)
		elif key == P2_CONTROLS.block: action_block.emit(2)
		elif key == P2_CONTROLS.dash: action_dash.emit(2)

func set_player_can_act(player: int, can_act: bool) -> void:
	if player == 1: player1_can_act = can_act
	elif player == 2: player2_can_act = can_act
