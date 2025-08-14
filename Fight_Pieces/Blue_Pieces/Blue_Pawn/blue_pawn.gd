extends "res://scripts/fighters/BaseFighter.gd"

func _ready() -> void:
	# Configure assets and parameters for Blue Pawn
	idle_texture = preload("res://assets/Characters Fight/idles/blue_idles/W_pawn_idle.png")
	idle_hframes = 2
	idle_animation_name = "blue_pawn_idle"

	attack_texture = preload("res://assets/Characters Fight/Punches/blue_punches/WP_Art.png")
	
	boxes_json_path = "res://assets/Characters Fight/Punches/blue_punches/WP_boxes_active.json"
	
	extra_freeze_ms = 250

	

	super._ready()
