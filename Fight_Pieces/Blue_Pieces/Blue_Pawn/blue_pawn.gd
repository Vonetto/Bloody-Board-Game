extends "res://scripts/fight/BaseFighter.gd"

func _ready() -> void:
	# Configure assets and parameters for Blue Pawn
	idle_texture = preload("res://assets/Characters Fight/idles/blue_idles/W_pawn_idle.png")
	idle_hframes = 2
	idle_animation_name = "blue_pawn_idle"

	attack_texture = preload("res://assets/Characters Fight/Punches/blue_punches/WP_Art.png")
	attack_hframes = 5
	boxes_json_path = "res://assets/Characters Fight/Punches/blue_punches/WP_boxes_active.json"
	attack_fps = 10.0
	extra_freeze_ms = 250

	

	super._ready()
