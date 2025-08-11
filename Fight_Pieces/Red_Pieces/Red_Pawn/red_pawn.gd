extends "res://scripts/fight/BaseFighter.gd"

func _ready() -> void:
	# Configuración temporal: reutiliza JSON del blue hasta tener assets propios
	idle_texture = preload("res://assets/Characters Fight/idles/red_idles/B_pawn_idle.png")
	idle_hframes = 2
	idle_animation_name = "r_pawn_idle"

	attack_texture = preload("res://assets/Characters Fight/Punches/red_punches/B_pawn_attack.png")
	attack_hframes = 5
	boxes_json_path = "res://assets/Characters Fight/Punches/blue_punches/WP_boxes_active.json"
	attack_fps = 10.0
	extra_freeze_ms = 250

	idle_hurt_default_x = 9
	idle_hurt_default_y = 41
	idle_hurt_default_w = 11
	idle_hurt_default_h = 24

	super._ready()
