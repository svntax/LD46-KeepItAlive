extends KinematicBody2D

onready var velocity : Vector2 = Vector2()
onready var reflected_velocity : Vector2 = Vector2()
onready var is_reflected = false
onready var max_reflect_count = 5

onready var animation_player = $AnimationPlayer

func _ready():
    animation_player.play("rest")

func reflect_back(vec : Vector2) -> void:
    reflected_velocity = vec * 2
    set_velocity(vec.x, vec.y)
    animation_player.play("reflect")
    is_reflected = true
    max_reflect_count += 1
    SoundHandler.reflectSound.play()

func set_velocity(x : float, y : float) -> void:
    velocity.x = x
    velocity.y = y

func _physics_process(delta):
    var collision = move_and_collide(velocity + reflected_velocity)
    if collision:
        velocity = velocity.bounce(collision.normal)
        max_reflect_count -= 1
        if max_reflect_count <= 0:
            queue_free()
    if reflected_velocity.length() > 0:
        reflected_velocity = reflected_velocity.linear_interpolate(Vector2.ZERO, 0.12)

func _on_VisibilityNotifier2D_screen_exited():
    if not is_queued_for_deletion():
        queue_free()
