extends KinematicBody2D

const BULLET_KNOCKBACK = 64

var bullet_scene = load("res://Bullets/Bullet.tscn")

onready var velocity : Vector2 = Vector2()
onready var knockback_velocity : Vector2 = Vector2()

onready var health = 2

onready var shoot_timer = $ShootTimer
onready var hitbox = $Hitbox

func _ready():
    shoot_timer.connect("timeout", self, "_shoot_cooldown_finished")
    shoot_timer.one_shot = false
    shoot_timer.wait_time = 2
    shoot_timer.start()
    
    hitbox.connect("body_entered", self, "_on_body_entered")

# Shoots a bullet towards the player
func shoot_bullet() -> void:
    var bullet = bullet_scene.instance()
    bullet.global_position = global_position
    get_tree().get_root().add_child(bullet)
    var player = get_tree().get_nodes_in_group("Players")[0]
    var bullet_vel = global_position.direction_to(player.global_position) * 3
    bullet.set_velocity(bullet_vel.x, bullet_vel.y)

func knockback(x : float, y : float) -> void:
    knockback_velocity.x = x
    knockback_velocity.y = y

func damage() -> void:
    health -= 1
    if health <= 0:
        queue_free()

func _physics_process(delta):
    # Knockback velocity is reduced
    if knockback_velocity.length() > 0:
        knockback_velocity = knockback_velocity.linear_interpolate(Vector2.ZERO, 0.1)
    
    move_and_slide(velocity + knockback_velocity)

func _shoot_cooldown_finished():
    shoot_bullet()

func _on_body_entered(body):
    if body.is_in_group("Players"):
        # TODO: what should happen if player touches an enemy
        pass
    if body.is_in_group("Bullets"):
        # Damage the enemy and remove the bullet
        damage()
        var push = body.global_position.direction_to(global_position).normalized() * BULLET_KNOCKBACK
        knockback(push.x, push.y)
        body.queue_free()
