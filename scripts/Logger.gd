extends Node

class_name Logger

@export var enabled: bool = true

static func d(msg: String) -> void:
    if ProjectSettings.get_setting("application/run/low_processor_mode") == false:
        print(msg)


