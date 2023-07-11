extends Control

@onready var play = %Play
@onready var exit = %Exit
@onready var credits = %Credits

func _ready():
	play.pressed.connect(_on_play_pressed)
	exit.pressed.connect(_on_exit_pressed)
	credits.pressed.connect(_on_credits_pressed)
	
func _on_play_pressed():
	get_tree().change_scene_to_file("res://main.tscn")

func _on_exit_pressed():
	get_tree().quit()

func _on_credits_pressed():
	get_tree().change_scene_to_file("res://credits.tscn")
