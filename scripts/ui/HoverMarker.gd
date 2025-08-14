extends Sprite2D

class_name HoverMarker

func _ready() -> void:
    texture = preload("res://assets/UI_Flat_Select_02a3.png")
    modulate = Color(1, 1, 0, 0.5)
    scale = Vector2(-3, 3)
    visible = false

func set_index(idx: int, index_map: Dictionary) -> void:
    if idx == 0 or not index_map.has(idx):
        visible = false
        return
    visible = true
    position = index_map[idx]

func hide_marker() -> void:
    visible = false

