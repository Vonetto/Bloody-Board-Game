extends CharacterBody2D

# Base fighter behavior for all pieces. Child scripts configure assets via exports or in _ready.

signal hit_dealt(attacking_player: int, damage: int, target: Node)

# Movement tuning
@export var speed: float = 800.0
@export var jump_velocity: float = -1000.0
@export var dash_impulse: float = 1200.0
@export var acceleration: float = 3000.0
@export var deceleration: float = 3800.0
@export var turn_deceleration: float = 5200.0
@export var flip_velocity_epsilon: float = 20.0
@export var use_pixel_snap: bool = true

# Sprites and animations
@export var idle_texture: Texture2D
@export var idle_hframes: int = 2
@export var idle_animation_name: String = ""

@export var attack_texture: Texture2D
@export var attack_hframes: int = 5
@export var attack_fps: float = 10.0
@export var extra_freeze_ms: int = 250

# Boxes JSON
@export var boxes_json_path: String = ""

# Default idle hurtbox (when not attacking)
@export var idle_hurt_default_x: int = 6
@export var idle_hurt_default_y: int = 28
@export var idle_hurt_default_w: int = 15
@export var idle_hurt_default_h: int = 24

# Pivot and frame size in pixels (from JSON or defaults)
var frame_size: Vector2 = Vector2(64, 52)
var pivot_px: Vector2 = Vector2(32, 52)

# Runtime state
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity") * 3.0
@onready var pivot: Node2D = $pivot
@onready var sprite: Sprite2D = $pivot/Sprite2D
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var anim_tree: AnimationTree = $AnimationTree

var player_id: int = 0
var desired_direction: float = 0.0
var jump_requested: bool = false
var facing: int = 1
var block_active: bool = false
var dash_cooldown: float = 0.0
var attack_cooldown: float = 0.0
var is_attacking: bool = false

# Combat areas
var hitbox_area: Area2D = null
var hurtbox_area: Area2D = null
var hit_shape_nodes: Array[CollisionShape2D] = []
var hurt_shape_nodes: Array[CollisionShape2D] = []
var hit_debug_nodes: Array[ColorRect] = []
var hurt_debug_nodes: Array[ColorRect] = []
var idle_hurtbox: CollisionShape2D = null

# Boxes data
var boxes_data: Dictionary = {}
var active_frames: Array[int] = []
var attack_frames_count: int = 5

func get_boxes_data() -> Dictionary:
    return boxes_data

func set_boxes_data(data: Dictionary) -> void:
    boxes_data = data
    var fr: Array = (boxes_data.get("frames", []) as Array)
    attack_frames_count = fr.size()

func _ready() -> void:
    _load_boxes()
    _setup_areas()
    # Sprite idle defaults
    if idle_texture:
        sprite.texture = idle_texture
    sprite.hframes = max(1, idle_hframes)
    sprite.frame = 0
    if anim_tree:
        anim_tree.active = true
    if anim_player and idle_animation_name != "":
        anim_player.play(idle_animation_name)

func _physics_process(delta: float) -> void:
    if not is_on_floor():
        velocity.y += gravity * delta

    if jump_requested and is_on_floor():
        velocity.y = jump_velocity
        jump_requested = false

    # Smooth accel/decel and controlled turn decel
    var has_input := absf(desired_direction) > 0.01
    if has_input:
        var target_velocity_x := desired_direction * speed
        var same_sign := signf(target_velocity_x) == signf(velocity.x) or absf(velocity.x) < 1.0
        var accel := acceleration if same_sign else turn_deceleration
        velocity.x = move_toward(velocity.x, target_velocity_x, accel * delta)
    else:
        velocity.x = move_toward(velocity.x, 0.0, deceleration * delta)

    # Flip visual based on real movement
    var new_facing := facing
    if absf(velocity.x) > flip_velocity_epsilon:
        new_facing = 1 if velocity.x > 0.0 else -1
    if new_facing != facing:
        facing = new_facing
        if pivot:
            pivot.scale.x = facing

    if dash_cooldown > 0.0:
        dash_cooldown = max(0.0, dash_cooldown - delta)
    if attack_cooldown > 0.0:
        attack_cooldown = max(0.0, attack_cooldown - delta)

    move_and_slide()
    if use_pixel_snap:
        position = position.round()

func set_player_id(id: int) -> void:
    player_id = id

func move(direction: Vector2) -> void:
    desired_direction = clamp(direction.x, -1.0, 1.0)

func jump() -> void:
    jump_requested = true

func attack() -> void:
    if attack_cooldown > 0.0:
        return
    var total_duration := _estimate_attack_duration()
    attack_cooldown = max(0.6, total_duration)
    await _play_attack_animation()

func block() -> void:
    if block_active:
        return
    block_active = true
    if pivot:
        var orig := pivot.modulate
        pivot.modulate = Color(0.5, 0.7, 1.0)
        await get_tree().create_timer(0.25).timeout
        pivot.modulate = orig
    block_active = false

func dash() -> void:
    if dash_cooldown > 0.0:
        return
    velocity.x += float(facing) * dash_impulse
    dash_cooldown = 0.6

# ---- Boxes setup and helpers ----
func _load_boxes() -> void:
    if boxes_json_path == "":
        return
    var file: FileAccess = FileAccess.open(boxes_json_path, FileAccess.READ)
    if file:
        var parsed: Variant = JSON.parse_string(file.get_as_text())
        if typeof(parsed) == TYPE_DICTIONARY:
            boxes_data = parsed as Dictionary
            attack_fps = float(boxes_data.get("fps", attack_fps))
            var fs: Dictionary = (boxes_data.get("frame_size", {}) as Dictionary)
            frame_size = Vector2(float(fs.get("w", frame_size.x)), float(fs.get("h", frame_size.y)))
            var pv: Dictionary = (boxes_data.get("pivot", {}) as Dictionary)
            pivot_px = Vector2(float(pv.get("x", pivot_px.x)), float(pv.get("y", pivot_px.y)))
            var act: Array = (boxes_data.get("active_frames", []) as Array)
            active_frames.clear()
            for a in act:
                active_frames.append(int(a))
            var fr: Array = (boxes_data.get("frames", []) as Array)
            attack_frames_count = fr.size()

func _create_idle_hurtbox() -> void:
    if idle_hurtbox:
        return
    idle_hurtbox = CollisionShape2D.new()
    idle_hurtbox.name = "IdleHurtbox"
    var rect := RectangleShape2D.new()
    rect.size = Vector2(float(idle_hurt_default_w), float(idle_hurt_default_h))
    idle_hurtbox.shape = rect
    var cx := float(idle_hurt_default_x) - pivot_px.x + rect.size.x * 0.5
    var cy := float(idle_hurt_default_y) - pivot_px.y + rect.size.y * 0.5
    idle_hurtbox.position = Vector2(cx, cy)
    hurtbox_area.add_child(idle_hurtbox)

func _setup_areas() -> void:
    if not hitbox_area:
        hitbox_area = Area2D.new()
        hitbox_area.name = "HitboxArea"
        hitbox_area.collision_layer = 1 << 3
        hitbox_area.collision_mask = 1 << 2
        pivot.add_child(hitbox_area)
        hitbox_area.area_entered.connect(_on_hitbox_area_entered)
    if not hurtbox_area:
        hurtbox_area = Area2D.new()
        hurtbox_area.name = "HurtboxArea"
        hurtbox_area.collision_layer = 1 << 2
        hurtbox_area.collision_mask = 1 << 3
        pivot.add_child(hurtbox_area)
    _create_idle_hurtbox()
    _apply_frame_boxes(0, false)
    hitbox_area.monitoring = false

func _clear_shapes(nodes: Array[CollisionShape2D]) -> void:
    for n in nodes:
        if is_instance_valid(n):
            n.queue_free()
    nodes.clear()

func _ensure_shapes(area: Area2D, nodes: Array[CollisionShape2D], count: int) -> void:
    while nodes.size() < count:
        var cs: CollisionShape2D = CollisionShape2D.new()
        area.add_child(cs)
        nodes.append(cs)
    while nodes.size() > count:
        var last: CollisionShape2D = nodes.pop_back() as CollisionShape2D
        if is_instance_valid(last):
            last.queue_free()

func _ensure_debug_rects(count: int, nodes_array: Array, color: Color, parent: Node) -> void:
    while nodes_array.size() < count:
        var r: ColorRect = ColorRect.new()
        r.color = color
        r.mouse_filter = Control.MOUSE_FILTER_IGNORE
        r.z_index = 0
        parent.add_child(r)
        nodes_array.append(r)
    while nodes_array.size() > count:
        var last: ColorRect = nodes_array.pop_back() as ColorRect
        if is_instance_valid(last):
            last.queue_free()

func _set_hit_debug_visible(visible: bool) -> void:
    for r in hit_debug_nodes:
        (r as ColorRect).visible = visible

func _rect_center_local(rect: Dictionary) -> Vector2:
    var w := float(rect.get("w", 0))
    var h := float(rect.get("h", 0))
    var x := float(rect.get("x", 0))
    var y := float(rect.get("y", 0))
    return Vector2(x - pivot_px.x + w * 0.5, y - pivot_px.y + h * 0.5)

func _apply_frame_boxes(frame_index: int, show_hit_debug: bool) -> void:
    var frames: Array = boxes_data.get("frames", []) as Array
    if frame_index < 0 or frame_index >= frames.size():
        return
    var f: Dictionary = frames[frame_index]
    var hit_rects: Array = f.get("hit", []) as Array
    var hurt_rects: Array = f.get("hurt", []) as Array

    _ensure_shapes(hitbox_area, hit_shape_nodes, hit_rects.size())
    for i in range(hit_rects.size()):
        var r: Dictionary = hit_rects[i]
        var cs: CollisionShape2D = hit_shape_nodes[i]
        var rect := RectangleShape2D.new()
        rect.size = Vector2(float(r.get("w", 0)), float(r.get("h", 0)))
        cs.shape = rect
        cs.position = _rect_center_local(r)

    if is_attacking:
        _ensure_shapes(hurtbox_area, hurt_shape_nodes, hurt_rects.size())
        for j in range(hurt_rects.size()):
            var rr: Dictionary = hurt_rects[j]
            var cs2: CollisionShape2D = hurt_shape_nodes[j]
            var rect2 := RectangleShape2D.new()
            rect2.size = Vector2(float(rr.get("w", 0)), float(rr.get("h", 0)))
            cs2.shape = rect2
            cs2.position = _rect_center_local(rr)
    else:
        _clear_shapes(hurt_shape_nodes)

    _ensure_debug_rects(hit_rects.size(), hit_debug_nodes, Color(1, 0, 0, 0.35), hitbox_area)
    for k in range(hit_rects.size()):
        var dr: ColorRect = hit_debug_nodes[k]
        var rr2: Dictionary = hit_rects[k]
        var size := Vector2(float(rr2.get("w", 0)), float(rr2.get("h", 0)))
        var center := _rect_center_local(rr2)
        dr.size = size
        dr.position = center - size * 0.5
        dr.visible = show_hit_debug

    if is_attacking:
        _ensure_debug_rects(hurt_rects.size(), hurt_debug_nodes, Color(0, 0, 1, 0.35), hurtbox_area)
        for k2 in range(hurt_rects.size()):
            var dr2: ColorRect = hurt_debug_nodes[k2]
            var rrh: Dictionary = hurt_rects[k2]
            var size_h := Vector2(float(rrh.get("w", 0)), float(rrh.get("h", 0)))
            var center_h := _rect_center_local(rrh)
            dr2.size = size_h
            dr2.position = center_h - size_h * 0.5
            dr2.visible = true
    else:
        for r2 in hurt_debug_nodes:
            (r2 as ColorRect).visible = false

# ---- Attack animation ----
func _estimate_attack_duration() -> float:
    var base := 1.0 / attack_fps
    return base * float(attack_frames_count) + float(extra_freeze_ms) / 1000.0

func _play_attack_animation() -> void:
    velocity.x = 0.0

    var base := 1.0 / attack_fps
    var durations: Array = []
    for _i in range(attack_frames_count):
        durations.append(base)
    durations[durations.size() - 1] = base + float(extra_freeze_ms) / 1000.0

    if anim_tree:
        anim_tree.active = false
    if anim_player:
        anim_player.stop()

    if attack_texture:
        sprite.texture = attack_texture
    sprite.hframes = max(1, attack_hframes)
    sprite.frame = 0

    if idle_hurtbox:
        idle_hurtbox.set_deferred("disabled", true)
    is_attacking = true

    var hit_once: bool = false
    var max_index: int = max(0, int(sprite.vframes * sprite.hframes) - 1)
    for i in range(attack_frames_count):
        if i > max_index:
            break
        var is_active: bool = active_frames.has(i)
        _apply_frame_boxes(i, true)
        hitbox_area.monitoring = is_active
        sprite.frame = i
        if is_active and not hit_once:
            await get_tree().process_frame
            var overlaps: Array = hitbox_area.get_overlapping_areas()
            for a in overlaps:
                var other: Area2D = a as Area2D
                if other and other.name == "HurtboxArea":
                    var target_pivot := other.get_parent()
                    var target_root := target_pivot.get_parent() if target_pivot else null
                    if target_root and target_root.has_method("set_player_id"):
                        var damage := 18
                        hit_dealt.emit(player_id, damage, target_root)
                        hit_once = true
                        break
        await get_tree().create_timer(float(durations[i])).timeout

    _clear_shapes(hit_shape_nodes)
    _clear_shapes(hurt_shape_nodes)
    if idle_hurtbox:
        idle_hurtbox.set_deferred("disabled", false)
    is_attacking = false
    hitbox_area.monitoring = false
    _apply_frame_boxes(0, false)

    if idle_texture:
        sprite.texture = idle_texture
    sprite.hframes = max(1, idle_hframes)
    sprite.frame = 0
    if anim_tree:
        anim_tree.active = true
    if anim_player and idle_animation_name != "":
        anim_player.play(idle_animation_name)

func set_attack_frame(frame_index: int) -> void:
    if anim_tree:
        anim_tree.active = false
    if anim_player:
        anim_player.stop()
    if sprite == null:
        return
    if attack_texture:
        sprite.texture = attack_texture
    sprite.hframes = max(1, attack_hframes)
    var idx: int = clamp(frame_index, 0, max(0, attack_frames_count - 1))
    var max_index: int = max(0, int(sprite.vframes * sprite.hframes) - 1)
    sprite.frame = clamp(idx, 0, max_index)

func _on_hitbox_area_entered(area: Area2D) -> void:
    if area == null or area.name != "HurtboxArea":
        return
    var fighter := area.get_parent()
    if fighter and fighter.get_parent() and fighter.get_parent().has_method("set_player_id"):
        var target: Node = fighter.get_parent()
        var damage := 18
        hit_dealt.emit(player_id, damage, target)


