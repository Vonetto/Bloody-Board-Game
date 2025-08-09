extends Node

class_name Logger

@export var enabled: bool = true
@export var level: int = 0 # 0=debug, 1=info, 2=warn, 3=error

static func d(msg: String) -> void:
    if ProjectSettings.get_setting("application/run/low_processor_mode"):
        return
    print("[DEBUG] ", msg)

static func i(msg: String) -> void:
    if ProjectSettings.get_setting("application/run/low_processor_mode"):
        return
    print("[INFO] ", msg)

static func w(msg: String) -> void:
    print("[WARN] ", msg)

static func e(msg: String) -> void:
    push_error(msg)


