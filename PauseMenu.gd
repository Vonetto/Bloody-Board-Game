extends MarginContainer

@onready var resume = %Resume
@onready var retry = %Retry
@onready var main_menu = %MainMenu

func _ready():
	resume.pressed.connect(_on_resume_pressed)
	retry.pressed.connect(_on_retry_pressed)
	main_menu.pressed.connect(_on_main_menu_pressed)
	hide()
	
func _on_resume_pressed():
	get_tree().paused = false
	hide()
	
func _on_retry_pressed():
	get_tree().reload_current_scene()
	get_tree().paused = false
	
func _on_main_menu_pressed():
	get_tree().change_scene_to_file("res://MainMenu.tscn")
	get_tree().paused = false

func _input(event):
	if event.is_action_pressed("Pause"):
		show()
		get_tree().paused = true

