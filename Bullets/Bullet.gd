extends KinematicBody2D

onready var velocity : Vector2 = Vector2()
onready var reflected_velocity : Vector2 = Vector2() 

onready var animation_player = $AnimationPlayer

func _ready():
    #animation_player.play("rest")
    # TODO: Temporary
    velocity.x = 1
    velocity.y = 1

func reflect_back(vec : Vector2) -> void:
    reflected_velocity = vec * 2
    set_velocity(vec.x, vec.y)
    animation_player.play("reflect")

func set_velocity(x : float, y : float) -> void:
    velocity.x = x
    velocity.y = y

func _physics_process(delta):
    var collision = move_and_collide(velocity + reflected_velocity)
    if collision:
        velocity = velocity.bounce(collision.normal)
    if reflected_velocity.length() > 0:
        reflected_velocity = reflected_velocity.linear_interpolate(Vector2.ZERO, 0.15)
