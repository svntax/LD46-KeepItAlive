extends KinematicBody2D

const WALK_SPEED = 64
const REFLECT_SPEED = 4

enum State {NORMAL, STUNNED}
onready var current_state = State.NORMAL

onready var velocity : Vector2 = Vector2()

onready var sword_angle = 0

onready var animation_player = $AnimationPlayer
onready var sword_player = $SwordPlayer
onready var stunned_timer = $StunnedTimer
onready var sword_pivot = $SwordPivot

func _ready():
    pass

func change_state(new_state):
    current_state = new_state
    match new_state:
        State.NORMAL:
            pass
        State.STUNNED:
            # TODO: stunned effect/animation
            stunned_timer.start()
            animation_player.play("stun")

func stun() -> void:
    if current_state != State.STUNNED:
        change_state(State.STUNNED)

func update_sword():
    if sword_player.current_animation != "slash":
        sword_angle = sword_pivot.global_position.angle_to_point(get_global_mouse_position())
        sword_pivot.set_global_rotation(sword_angle)

func reset_hilt():
    sword_pivot.get_node("HiltPivot").position = Vector2(0, 0)

func _physics_process(delta):
    update_sword()
    if Input.is_action_just_pressed("SLASH"):
        if !sword_player.is_playing():
            sword_player.play("slash")
    
    velocity.x = 0
    velocity.y = 0
    if Input.is_action_pressed("MOVE_LEFT"):
        velocity.x += -WALK_SPEED
    if Input.is_action_pressed("MOVE_RIGHT"):
        velocity.x += WALK_SPEED
    if Input.is_action_pressed("MOVE_UP"):
        velocity.y += -WALK_SPEED
    if Input.is_action_pressed("MOVE_DOWN"):
        velocity.y += WALK_SPEED
    
    if _can_move():
        move_and_slide(velocity)

func _can_move() -> bool:
    return current_state != State.STUNNED

func _on_StunnedTimer_timeout():
    change_state(State.NORMAL)

func _on_Hitbox_body_entered(body):
    if body.is_in_group("Bullets"):
        stun()
        body.queue_free()

func _on_SwordPlayer_animation_finished(anim_name):
    if anim_name == "slash":
        reset_hilt()

func _on_Sword_body_entered(body):
    if body.is_in_group("Bullets"):
        var push = Vector2(-1, 0).rotated(sword_angle) * REFLECT_SPEED
        body.reflect_back(push)
