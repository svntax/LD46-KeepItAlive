extends KinematicBody2D

const BULLET_KNOCKBACK = 64

var bullet_scene = load("res://Bullets/Bullet.tscn")
var blood_scene = load("res://Enemies/BloodSplatter.tscn")

enum State {NORMAL, STUNNED}
onready var current_state = State.NORMAL

onready var direction = 1 # 1 = right, -1 = left
onready var player = get_tree().get_nodes_in_group("Players")[0]
onready var boss = get_tree().get_nodes_in_group("Boss")[0]
onready var game_root = get_tree().get_root().get_node("Gameplay")

onready var velocity : Vector2 = Vector2()
onready var knockback_velocity : Vector2 = Vector2()

onready var health = 1
onready var has_stun_immunity = false

onready var shoot_timer = $ShootTimer
onready var hitbox = $Hitbox
onready var movement_interval_timer = $MovementIntervalTimer
onready var movement_duration_timer = $MovementDurationTimer
onready var sprite = $Body/Sprite
onready var attack_sprite = $Body/AttackSprite
onready var bullet_sprite = $BulletSprite
onready var bullet_particles = $Particles2D
onready var spawn_high_pos = $SpawnHigh
onready var spawn_low_pos = $SpawnLow
onready var bullet_area = $SpawnHigh/BulletAreaCheck
onready var animation_player = $AnimationPlayer
onready var effects_player = $EffectsPlayer
onready var stunned_timer = $StunnedTimer
onready var stun_immunity_timer = $StunImmunityTimer

onready var PREFERRED_DISTANCE_FROM_CLOSEST_ADVERSARY = 200
onready var SPEED = 500
onready var MOVEMENT_DURATION = 0.2

func _ready():
    shoot_timer.connect("timeout", self, "_shoot_cooldown_finished")
    shoot_timer.one_shot = true
    shoot_timer.wait_time = 2
    shoot_timer.start()
    
    movement_interval_timer.connect("timeout", self,  "_begin_movement")
    movement_interval_timer.one_shot = false
    movement_interval_timer.wait_time = 5
    movement_interval_timer.start()
    
    movement_duration_timer.connect("timeout", self, "_end_movement")
    movement_duration_timer.one_shot = true
    
    stunned_timer.connect("timeout", self, "_stunned_timer_finished")
    
    stun_immunity_timer.connect("timeout", self, "_stun_immunity_finished")
    stun_immunity_timer.wait_time = 2
    
    hitbox.connect("body_entered", self, "_on_body_entered")
    
    sprite.hide()
    animation_player.play("teleport_in")

func change_state(new_state):
    current_state = new_state
    match new_state:
        State.NORMAL:
            # What should happen when entering the NORMAL state
            effects_player.stop()
            effects_player.play("rest")
        State.STUNNED:
            # What should happen when entering the STUNNED state
            effects_player.play("stun")
            stunned_timer.start()
            has_stun_immunity = true
            stun_immunity_timer.start()
            if animation_player.is_playing() and animation_player.current_animation == "attack":
                # Cancel the attack
                shoot_timer.start()
                animation_player.stop()
                animation_player.play("rest")

func _can_move() -> bool:
    return current_state != State.STUNNED

func stun() -> void:
    if current_state != State.STUNNED and !has_stun_immunity:
        change_state(State.STUNNED)

# Shoots a bullet towards the boss
func shoot_bullet() -> void:
    if boss != null and is_instance_valid(boss):
        var bullet = bullet_scene.instance()
        bullet.global_position = bullet_sprite.global_position
        get_tree().get_root().add_child(bullet)
        var bullet_vel = global_position.direction_to(boss.global_position) * 3
        bullet.set_velocity(bullet_vel.x, bullet_vel.y)

func knockback(x : float, y : float) -> void:
    knockback_velocity.x = x
    knockback_velocity.y = y
    
onready var random_offset_factor = 0.2;
    
func get_new_movement_direction() -> Vector2:
    var distance = global_position.distance_to(get_coords_of_closest_adversary())
    var go_towards_adversary
    if distance <= PREFERRED_DISTANCE_FROM_CLOSEST_ADVERSARY:
        go_towards_adversary = -1
    else:
        go_towards_adversary = 1
    var direction = go_towards_adversary * global_position.direction_to(get_coords_of_closest_adversary())
    var random_offset = Vector2(randf(), randf()).normalized();
    return (direction + random_offset * random_offset_factor).normalized();

    
func get_coords_of_closest_adversary() -> Vector2:
    # Todo also have the monster included in this consideration
    #var player = get_tree().get_nodes_in_group("Players")[0]
    return player.global_position 

func blood_splatter(source) -> void:
    var blood = blood_scene.instance()
    blood.global_position = global_position
    game_root.add_blood_splatter(blood)
    if source == null:
        blood.splat_effect(0)
    else:
        if source.global_position.x > global_position.x:
            blood.splat_effect(-1)
        else:
            blood.splat_effect(1)

func damage(amount, source = null) -> void:
    health -= amount
    if health <= 0:
        SoundHandler.mageDeath.play()
        blood_splatter(source)
        queue_free()

func _physics_process(delta):
    # Knockback velocity is reduced
    if knockback_velocity.length() > 0:
        knockback_velocity = knockback_velocity.linear_interpolate(Vector2.ZERO, 0.1)
    
    if _can_move():
        move_and_slide(velocity + knockback_velocity)
    
    # Face the boss
    if boss != null and is_instance_valid(boss):
        if boss.global_position.x > global_position.x:
            direction = 1
        else:
            direction = -1
        sprite.scale.x = direction
        attack_sprite.scale.x = direction

func _shoot_cooldown_finished():
    if game_root.game_state != game_root.State.NORMAL:
        return
    
    var top_area_free = true
    for body in bullet_area.get_overlapping_bodies():
        if not body.is_in_group("Players"):
            top_area_free = false
    
    if top_area_free:
        bullet_sprite.global_position = spawn_high_pos.global_position
    else:
        bullet_sprite.global_position = spawn_low_pos.global_position
    bullet_particles.global_position = bullet_sprite.global_position + Vector2(0, -6)
    
    animation_player.play("attack")
    
func _begin_movement():
    if game_root.game_state != game_root.State.NORMAL:
        return
    
    velocity = get_new_movement_direction() * SPEED
    
    if animation_player.current_animation == "attack":
        # Fix for making sure a mage doesn't move upwards close to a wall while
        # in the middle of spawning a bullet, which would cause the bullet to spawn
        # inside the wall and bug out.
        if velocity.y < 0:
            velocity.y *= -1
    
    movement_duration_timer.wait_time = MOVEMENT_DURATION
    movement_duration_timer.start()
    
func _end_movement():
    velocity = Vector2.ZERO

func _stunned_timer_finished():
    change_state(State.NORMAL)

func _stun_immunity_finished():
    has_stun_immunity = false

func _on_body_entered(body):
    if body.is_in_group("Players"):
        pass
    if body.is_in_group("Bullets"):
        # Damage the enemy
        damage(1, body)
        stun()
        var push = body.global_position.direction_to(global_position).normalized() * BULLET_KNOCKBACK
        knockback(push.x, push.y)
        #body.queue_free()

func _on_AnimationPlayer_animation_finished(anim_name):
    if anim_name == "attack":
        shoot_timer.start()
        animation_player.play("rest")
