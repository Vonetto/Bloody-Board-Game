extends CanvasLayer

class_name StatusHud

var label: Label
var _queue: Array = []
var _busy: bool = false

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
	_queue.append({"text": text, "color": color, "fade": fade_sec})
	if not _busy:
		await _dequeue_and_show()

func _dequeue_and_show() -> void:
	if _queue.is_empty():
		_busy = false
		return
	_busy = true
	if label == null:
		_ready()
	var item = _queue.pop_front()
	var text: String = item.text
	var color: Color = item.color
	var fade_sec: float = float(item.fade)
	label.text = text
	var c := color
	c.a = 1.0
	label.modulate = c
	var tween := create_tween()
	tween.tween_property(label, "modulate:a", 0.0, fade_sec).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	await tween.finished
	await _dequeue_and_show()
