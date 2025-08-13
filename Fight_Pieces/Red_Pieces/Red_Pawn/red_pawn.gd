extends "res://scripts/fight/BaseFighter.gd"

func _ready() -> void:
	# Configuración temporal: reutiliza JSON del blue hasta tener assets propios
	idle_texture = preload("res://assets/Characters Fight/idles/red_idles/B_pawn_idle.png")
	idle_hframes = 4
	idle_animation_name = "r_pawn_idle"

	attack_texture = preload("res://assets/Characters Fight/Punches/red_punches/B_pawn_attack.png")
	attack_hframes = 5
	boxes_json_path = "res://assets/Characters Fight/Punches/red_punches/B_pawn_boxes_active.json"
	attack_fps = 10.0
	extra_freeze_ms = 250

	

	super._ready()
