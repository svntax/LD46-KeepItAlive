extends KinematicBody2D

const WALK_SPEED = 64

enum State {NORMAL, STUNNED}
onready var current_state = State.NORMAL

onready var velocity : Vector2 = Vector2()

onready var animation_player = $AnimationPlayer
onready var stunned_timer = $StunnedTimer

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

func _physics_process(delta):
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
