class_name FightHud
extends CanvasLayer

# HUD for fighting mode
# Displays HP bars, timer, and combat messages

const Logger = preload("res://scripts/systems/Logger.gd")

@onready var p1_hp_bar: ProgressBar = $P1HpBar
@onready var p2_hp_bar: ProgressBar = $P2HpBar
@onready var p1_stamina_bar: ProgressBar = $P1StaminaBar
@onready var p2_stamina_bar: ProgressBar = $P2StaminaBar
@onready var p1_name: Label = $P1Name
@onready var p2_name: Label = $P2Name
@onready var timer_label: Label = $TimerLabel
@onready var message_label: Label = $MessageLabel
@onready var message_timer: Timer = $MessageTimer

var p1_max_hp: int = 100
var p2_max_hp: int = 100

func _ready() -> void:
	# Create UI elements if they don't exist (scene might be empty)
	if not is_instance_valid(p1_hp_bar):
		_create_ui_elements()
	# Re-resolve in case they were created now
	p1_hp_bar = get_node_or_null("P1HpBar")
	p2_hp_bar = get_node_or_null("P2HpBar")
	p1_stamina_bar = get_node_or_null("P1StaminaBar")
	p2_stamina_bar = get_node_or_null("P2StaminaBar")
	p1_name = get_node_or_null("P1Name")
	p2_name = get_node_or_null("P2Name")
	timer_label = get_node_or_null("TimerLabel")
	message_label = get_node_or_null("MessageLabel")
	message_timer = get_node_or_null("MessageTimer")

	if is_instance_valid(message_timer):
		message_timer.timeout.connect(_on_message_timeout)
	visible = false

func _create_ui_elements() -> void:
	# Player 1 HP Bar (left side)
	p1_hp_bar = ProgressBar.new()
	p1_hp_bar.name = "P1HpBar"
	p1_hp_bar.position = Vector2(50, 50)
	p1_hp_bar.size = Vector2(300, 30)
	p1_hp_bar.max_value = 100
	p1_hp_bar.value = 100
	p1_hp_bar.show_percentage = false
	add_child(p1_hp_bar)
	_apply_hp_style(p1_hp_bar)

	# Player 1 Stamina Bar
	p1_stamina_bar = ProgressBar.new()
	p1_stamina_bar.name = "P1StaminaBar"
	p1_stamina_bar.position = Vector2(50, 85)
	p1_stamina_bar.size = Vector2(250, 15)
	p1_stamina_bar.max_value = 100
	p1_stamina_bar.value = 100
	p1_stamina_bar.show_percentage = false
	add_child(p1_stamina_bar)
	_apply_stamina_style(p1_stamina_bar)
	
	# Player 1 Name
	p1_name = Label.new()
	p1_name.name = "P1Name"
	p1_name.position = Vector2(50, 20)
	p1_name.text = "Player 1"
	p1_name.add_theme_font_size_override("font_size", 20)
	add_child(p1_name)
	
	# Player 2 HP Bar (right side)
	p2_hp_bar = ProgressBar.new()
	p2_hp_bar.name = "P2HpBar"
	p2_hp_bar.position = Vector2(850, 50)
	p2_hp_bar.size = Vector2(300, 30)
	p2_hp_bar.max_value = 100
	p2_hp_bar.value = 100
	p2_hp_bar.show_percentage = false
	add_child(p2_hp_bar)
	_apply_hp_style(p2_hp_bar)

	# Player 2 Stamina Bar
	p2_stamina_bar = ProgressBar.new()
	p2_stamina_bar.name = "P2StaminaBar"
	p2_stamina_bar.position = Vector2(900, 85)
	p2_stamina_bar.size = Vector2(250, 15)
	p2_stamina_bar.max_value = 100
	p2_stamina_bar.value = 100
	p2_stamina_bar.show_percentage = false
	add_child(p2_stamina_bar)
	_apply_stamina_style(p2_stamina_bar)
	
	# Player 2 Name
	p2_name = Label.new()
	p2_name.name = "P2Name"
	p2_name.position = Vector2(850, 20)
	p2_name.text = "Player 2"
	p2_name.add_theme_font_size_override("font_size", 20)
	add_child(p2_name)
	
	# Timer Background Panel
	var timer_bg := Panel.new()
	timer_bg.name = "TimerBackground"
	timer_bg.position = Vector2(540, 25)
	timer_bg.size = Vector2(120, 40)
	var stylebox := StyleBoxFlat.new()
	stylebox.bg_color = Color(0.1, 0.1, 0.1, 0.7)
	stylebox.corner_radius_top_left = 8
	stylebox.corner_radius_top_right = 8
	stylebox.corner_radius_bottom_left = 8
	stylebox.corner_radius_bottom_right = 8
	timer_bg.add_theme_stylebox_override("panel", stylebox)
	add_child(timer_bg)

	# Timer Label (center top)
	timer_label = Label.new()
	timer_label.name = "TimerLabel"
	timer_label.position = Vector2(550, 30)
	timer_label.size = Vector2(100, 30)
	timer_label.text = "0:00"
	timer_label.add_theme_font_size_override("font_size", 28)
	timer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	timer_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	add_child(timer_label)
	
	# Message Label (center)
	message_label = Label.new()
	message_label.name = "MessageLabel"
	message_label.position = Vector2(400, 350)
	message_label.size = Vector2(400, 100)
	message_label.text = ""
	message_label.add_theme_font_size_override("font_size", 48)
	message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	message_label.visible = false
	add_child(message_label)
	
	# Message Timer
	message_timer = Timer.new()
	message_timer.name = "MessageTimer"
	message_timer.one_shot = true
	message_timer.wait_time = 2.0
	add_child(message_timer)

func _apply_hp_style(bar: ProgressBar) -> void:
	var fill := StyleBoxFlat.new()
	fill.bg_color = Color(0.18, 0.8, 0.22) # green
	fill.corner_radius_top_left = 6
	fill.corner_radius_top_right = 6
	fill.corner_radius_bottom_left = 6
	fill.corner_radius_bottom_right = 6

	var bg := StyleBoxFlat.new()
	bg.bg_color = Color(0.18, 0.18, 0.18) # dark grey container
	bg.corner_radius_top_left = 6
	bg.corner_radius_top_right = 6
	bg.corner_radius_bottom_left = 6
	bg.corner_radius_bottom_right = 6

	bar.add_theme_stylebox_override("fill", fill)
	bar.add_theme_stylebox_override("background", bg)

func _apply_stamina_style(bar: ProgressBar) -> void:
	var fill := StyleBoxFlat.new()
	fill.bg_color = Color(0.9, 0.8, 0.2) # yellow
	fill.corner_radius_top_left = 4
	fill.corner_radius_top_right = 4
	fill.corner_radius_bottom_left = 4
	fill.corner_radius_bottom_right = 4

	var bg := StyleBoxFlat.new()
	bg.bg_color = Color(0.18, 0.18, 0.18) # dark grey container
	bg.corner_radius_top_left = 4
	bg.corner_radius_top_right = 4
	bg.corner_radius_bottom_left = 4
	bg.corner_radius_bottom_right = 4

	bar.add_theme_stylebox_override("fill", fill)
	bar.add_theme_stylebox_override("background", bg)


func setup_fight(p1_piece_name: String, p1_hp: int, p1_max_hp_val: int, p1_max_stamina: float, p2_piece_name: String, p2_hp: int, p2_max_hp_val: int, p2_max_stamina: float) -> void:
	p1_name.text = p1_piece_name
	p2_name.text = p2_piece_name
	
	p1_max_hp = p1_max_hp_val
	p1_hp_bar.max_value = p1_max_hp
	p1_hp_bar.value = p1_hp
	p1_stamina_bar.max_value = p1_max_stamina
	p1_stamina_bar.value = p1_max_stamina
	
	p2_max_hp = p2_max_hp_val
	p2_hp_bar.max_value = p2_max_hp
	p2_hp_bar.value = p2_hp
	p2_stamina_bar.max_value = p2_max_stamina
	p2_stamina_bar.value = p2_max_stamina
	
	visible = true
	Logger.d("[FightHud] Setup: %s (%d/%d HP) vs %s (%d/%d HP)" % [p1_piece_name, p1_hp, p1_max_hp, p2_piece_name, p2_hp, p2_max_hp])

func update_hp(player: int, new_hp: int) -> void:
	if player == 1:
		p1_hp_bar.value = max(0, new_hp)
		if new_hp <= 0:
			show_message("K.O.!", Color.RED)
	elif player == 2:
		p2_hp_bar.value = max(0, new_hp)
		if new_hp <= 0:
			show_message("K.O.!", Color.RED)

func update_stamina(player: int, new_stamina: float) -> void:
	if player == 1:
		p1_stamina_bar.value = new_stamina
	elif player == 2:
		p2_stamina_bar.value = new_stamina

func update_timer(time_left: float) -> void:
	var minutes := int(time_left) / 60
	var seconds := int(time_left) % 60
	timer_label.text = "%d:%02d" % [minutes, seconds]
	
	# Flash timer when low on time
	if time_left <= 10:
		timer_label.modulate = Color.RED if int(time_left * 2) % 2 == 0 else Color.WHITE
	else:
		timer_label.modulate = Color.WHITE

func show_message(text: String, color: Color = Color.WHITE) -> void:
	message_label.text = text
	message_label.modulate = color
	message_label.visible = true
	message_timer.start()

func _on_message_timeout() -> void:
	message_label.visible = false

func hide_hud() -> void:
	visible = false
