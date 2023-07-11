extends Node2D

@onready var main = %main


func _ready():
	main.pressed.connect(_on_main_pressed)


func _on_main_pressed():
	get_tree().change_scene_to_file("res://MainMenu.tscn")
