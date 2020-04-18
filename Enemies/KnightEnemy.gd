extends KinematicBody2D

const BULLET_KNOCKBACK = 64

var bullet_scene = load("res://Bullets/Bullet.tscn")
var player_scene = load("res://Player/Player.tscn")



onready var velocity : Vector2 = Vector2()
onready var knockback_velocity : Vector2 = Vector2()

onready var health = 2

onready var shoot_timer = $ShootTimer
onready var hitbox = $Hitbox
onready var movement_interval_timer = $MovementIntervalTimer
onready var movement_duration_timer = $MovementDurationTimer


onready var SPEED = 100
onready var MOVEMENT_DURATION = 1

func _ready():
    shoot_timer.connect("timeout", self, "_shoot_cooldown_finished")
    shoot_timer.one_shot = false
    shoot_timer.wait_time = 2
    shoot_timer.start()
    
    movement_interval_timer.connect("timeout", self,  "_begin_movement")
    movement_interval_timer.one_shot = false
    movement_interval_timer.wait_time = 3
    movement_interval_timer.start()
    
    movement_duration_timer.connect("timeout", self, "_end_movement")
    movement_duration_timer.one_shot = true
    
    
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
    
onready var random_offset_factor = 0.2;
    
func get_new_movement_direction() -> Vector2:
    var distance = global_position.distance_to(get_coords_of_closest_adversary())
    var go_towards_adversary
    var direction = 1 * global_position.direction_to(get_coords_of_closest_adversary())
    var random_offset = Vector2(randf(), randf()).normalized();
    return (direction + random_offset * random_offset_factor).normalized();

    
func get_coords_of_closest_adversary() -> Vector2:
    # Todo also have the monster included in this consideration
    var player = get_tree().get_nodes_in_group("Players")[0]
    return player.global_position 

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
    
func _begin_movement():
    velocity = get_new_movement_direction() * SPEED
    movement_duration_timer.wait_time = MOVEMENT_DURATION
    movement_duration_timer.start()
    
func _end_movement():
    velocity = Vector2.ZERO

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