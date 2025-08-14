extends Node

class_name SelectorController

static func show_turn(selector_white, selector_black, is_white: bool, index_map: Dictionary) -> void:
	if is_white:
		selector_white.visible = true
		selector_black.visible = false
		if selector_white.has_method("show_neutral_white"):
			selector_white.show_neutral_white()
	else:
		selector_white.visible = false
		selector_black.visible = true
		if selector_black.has_method("show_neutral_black"):
			selector_black.show_neutral_black()

static func reset_after_cancel(selector_white, selector_black, is_white: bool) -> void:
	if is_white:
		if selector_white.has_method("show_neutral_white"):
			selector_white.show_neutral_white()
		selector_black.visible = false
		selector_white.visible = true
	else:
		if selector_black.has_method("show_neutral_black"):
			selector_black.show_neutral_black()
		selector_white.visible = false
		selector_black.visible = true
