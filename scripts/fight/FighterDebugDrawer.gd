extends Node2D

var hit_rects: Array[Rect2] = []
var hurt_rects: Array[Rect2] = []
var show_hit: bool = false
var show_hurt: bool = false
var hit_color: Color = Color(1, 0, 0, 0.35)
var hurt_color: Color = Color(0, 0, 1, 0.35)

func update_rects(new_hit: Array, new_hurt: Array, show_hit_debug: bool, show_hurt_debug: bool) -> void:
    hit_rects.clear()
    for r in new_hit:
        if r is Rect2:
            hit_rects.append(r)
    hurt_rects.clear()
    for r2 in new_hurt:
        if r2 is Rect2:
            hurt_rects.append(r2)
    show_hit = show_hit_debug
    show_hurt = show_hurt_debug
    queue_redraw()

func _draw() -> void:
    if show_hurt:
        for r in hurt_rects:
            draw_rect(r, hurt_color, true)
    if show_hit:
        for r2 in hit_rects:
            draw_rect(r2, hit_color, true)

