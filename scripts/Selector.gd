extends Control

## Selector de casilla para ambos jugadores (vista)
## Mantiene compatibilidad con propiedades existentes: `indice`, `vul`, `turn`.

class_name SelectorView

@export var tile_size: int = 96
@export var origin: Vector2 = Vector2(48, -48)
@export var start_index: int = 1
@export var default_modulate: Color = Color(1, 1, 1, 0)

var indice: int
var vul: bool = false # false = seleccionando origen, true = seleccionando destino
var turn: bool = true # true = white, false = black
var sprite: Sprite2D

func _ready() -> void:
	sprite = Sprite2D.new()
	sprite.name = "sprite"
	sprite.texture = preload("res://assets/UI_Flat_Select_02a3.png")
	add_child(sprite)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	focus_mode = Control.FOCUS_NONE
	scale = Vector2(-3, 3)
	indice = start_index
	position = _index_to_position(indice)
	modulate = default_modulate

func set_color(color: Color) -> void:
	modulate = color
	if sprite:
		sprite.modulate = color

func invalidate() -> void:
	# Parpadeo rojo breve
	var previous: Color = sprite.modulate if is_instance_valid(sprite) else modulate
	set_color(Color(1, 0, 0))
	await get_tree().create_timer(0.6).timeout
	set_color(previous)

# API de alto nivel para la vista
func show_neutral_white() -> void:
	vul = false
	set_color(Color(1,1,1,1))

func show_neutral_black() -> void:
	vul = false
	set_color(Color(0,0,0))

func show_hidden() -> void:
	vul = false
	set_color(Color(1,1,1,0))

func show_targeting() -> void:
	vul = true
	set_color(Color(0,1,0))

func flash_invalid_and_reset(neutral_is_white: bool) -> void:
	await invalidate()
	vul = false
	if neutral_is_white:
		show_neutral_white()
	else:
		show_neutral_black()

func _input(event: InputEvent) -> void:
	# SelectorView ya no maneja teclado. Todo el input se centraliza en InputController.
	pass

func animate_confirm() -> void:
	var base := scale
	var up := Vector2(base.x * 1.1, base.y * 1.1)
	var tween := create_tween()
	tween.tween_property(self, "scale", up, 0.08).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", base, 0.08).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

func animate_cancel() -> void:
	var base := scale
	var down := Vector2(base.x * 0.9, base.y * 0.9)
	var tween := create_tween()
	tween.tween_property(self, "scale", down, 0.08).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", base, 0.08).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

func _try_move(dx: int, dy: int) -> bool:
	var col := int((indice - 1) % 8)
	var row := int((indice - 1) / 8)
	col = clamp(col + dx, 0, 7)
	row = clamp(row + dy, 0, 7)
	var new_index := row * 8 + col + 1   
	if new_index == indice:
		return false
	indice = new_index
	position = _index_to_position(indice)
	print("Selector moved -> index:", indice, " pos:", position)
	return true

func _index_to_position(index: int) -> Vector2:
	var col := int((index - 1) % 8)
	var row := int((index - 1) / 8)
	return Vector2(origin.x + col * tile_size, origin.y - row * tile_size)
