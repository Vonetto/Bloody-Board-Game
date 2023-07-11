extends Node2D

@onready var go_back = %GoBack


func _ready():
	go_back.pressed.connect(_on_goback_pressed)

func _on_goback_pressed():
	get_tree().change_scene_to_file("res://MainMenu.tscn")
