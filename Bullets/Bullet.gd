extends KinematicBody2D

onready var velocity : Vector2 = Vector2()

func _ready():
    # TODO: Temporary
    velocity.x = 1
    velocity.y = 1

func set_velocity(x : float, y : float) -> void:
    velocity.x = x
    velocity.y = y

func _physics_process(delta):
    var collision = move_and_collide(velocity)
    if collision:
        velocity = velocity.bounce(collision.normal)
