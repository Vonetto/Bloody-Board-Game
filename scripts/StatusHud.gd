extends CanvasLayer

class_name StatusHud

var label: Label

func _ready() -> void:
	if label == null:
		label = Label.new()
		label.name = "StatusLabel"
		label.text = ""
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		label.anchor_left = 0.0
		label.anchor_right = 1.0
		label.anchor_top = 0.0
		label.anchor_bottom = 0.0
		label.position = Vector2(0, 10)
		label.modulate = Color(1, 1, 1, 0)
		label.add_theme_font_size_override("font_size", 28)
		add_child(label)

func show_message(text: String, color: Color = Color.WHITE, fade_sec: float = 1.2) -> void:
	if label == null:
		_ready()
	label.text = text
	var c := color
	c.a = 1.0
	label.modulate = c
	var tween := create_tween()
	tween.tween_property(label, "modulate:a", 0.0, fade_sec).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
