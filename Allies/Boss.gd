extends KinematicBody2D

const BULLET_KNOCKBACK = 8

var bullet_scene = load("res://Bullets/Bullet.tscn")
var shockwave_scene = load("res://Allies/Shockwave.tscn")

onready var game_root = get_tree().get_root().get_node("Gameplay")

onready var velocity : Vector2 = Vector2()
onready var knockback_velocity : Vector2 = Vector2()

const MAX_HEALTH = 20
onready var health = MAX_HEALTH
onready var is_dead = false

onready var shoot_timer = $ShootTimer
onready var hitbox = $Hitbox
onready var movement_interval_timer = $MovementIntervalTimer
onready var movement_duration_timer = $MovementDurationTimer
onready var animation_player = $AnimationPlayer
onready var effects_player = $EffectsPlayer
onready var shockwave_spawn_pos = $ShockwaveSpawnPosition
onready var health_bar = $UI/HealthBar

onready var AGGRO_RANGE = 300
onready var SPEED = 500
onready var MOVEMENT_DURATION = 0.2
onready var SMASH_RANGE = 50
onready var SMASH_INTERVAL = 2
onready var SMASH_DAMAGE = 1

onready var can_attack = true

func _ready():
    shoot_timer.connect("timeout", self, "_shoot_cooldown_finished")
    shoot_timer.one_shot = false
    shoot_timer.wait_time = 2
    shoot_timer.start()
    
    movement_interval_timer.connect("timeout", self,  "_begin_movement")
    movement_interval_timer.one_shot = false
    movement_interval_timer.wait_time = 4
    movement_interval_timer.start()
    
    movement_duration_timer.connect("timeout", self, "_end_movement")
    movement_duration_timer.one_shot = true
    
    hitbox.connect("body_entered", self, "_on_body_entered")
    
    health_bar.set_value(100)

# Shoots a bullet towards the player
#func shoot_bullet() -> void:
#    var bullet = bullet_scene.instance()
#    bullet.global_position = global_position
#    get_tree().get_root().add_child(bullet)
#    var player = get_tree().get_nodes_in_group("Players")[0]
#    var bullet_vel = global_position.direction_to(player.global_position) * 3
#    bullet.set_velocity(bullet_vel.x, bullet_vel.y)

func knockback(x : float, y : float) -> void:
    knockback_velocity.x = x
    knockback_velocity.y = y
    
onready var random_offset_factor = 0.15;
    
func get_new_movement_direction() -> Vector2:
    var distance = global_position.distance_to(get_coords_of_closest_adversary())
    var go_towards_adversary = 0
    if distance < AGGRO_RANGE:
        go_towards_adversary = 1
    var direction = go_towards_adversary * global_position.direction_to(get_coords_of_closest_adversary())
    var random_offset = Vector2(randf(), randf()).normalized()
    return (direction + random_offset * random_offset_factor).normalized()

#func get_vector_to_center_screen() -> Vector2:
#    var viewport_rect = get_viewport_rect()
#    print("ViewPort Position", viewport_rect.position)
#    print("ViewPort Size", viewport_rect.size)
#    return global_position

func get_distance_from_nearest_adversary() -> float:
    return global_position.distance_to(get_coords_of_closest_adversary())    

func get_coords_of_closest_adversary() -> Vector2:
    # Todo also have the monster included in this consideration
    var enemies = get_tree().get_nodes_in_group("Enemies")
    if enemies.empty(): # Need this check in case all enemies are dead at any moment
        return Vector2(200, 160)
    var closestPosition;
    var closest = 999999;
    for i in range(0, enemies.size()):
        if enemies[i].global_position.distance_to(global_position) < closest:
            closest = enemies[i].global_position.distance_to(global_position)
            closestPosition = enemies[i].global_position
        return closestPosition
    
    # Default to middle of level


func kill() -> void:
    hide()
    is_dead = true
    # Disable collisions
    self.collision_layer = 0
    self.collision_mask = 0
    hitbox.monitoring = false
    hitbox.monitorable = false
    game_root.game_over()

func update_health_bar() -> void:
    var value = floor(100.0 * health / MAX_HEALTH)
    health_bar.set_value(value)

func damage(amount) -> void:
    if health <= 0:
        pass
    else:
        if !effects_player.is_playing():
            health -= amount
            update_health_bar()
            if health <= 0:
                # Do NOT queue_free() the boss, do a custom death handling
                kill()
            else:
                # The length of the damaged animation is the immunity time
                effects_player.play("damaged")

func spawn_shockwave() -> void:
    if game_root.game_state != game_root.State.NORMAL:
        return
    
    var shockwave = shockwave_scene.instance()
    shockwave.global_position = shockwave_spawn_pos.global_position
    get_tree().get_root().add_child(shockwave)
    
    game_root.shake_camera(0.2, 4, 30)
    
    # Also damage all enemies within hitbox
    for body in hitbox.get_overlapping_bodies():
        if body.is_in_group("Enemies"):
            body.damage(SMASH_DAMAGE)
            body.stun()

func _physics_process(delta):
    # Knockback velocity is reduced
    if knockback_velocity.length() > 0:
        knockback_velocity = knockback_velocity.linear_interpolate(Vector2.ZERO, 0.1)
        
    
    if can_attack and get_distance_from_nearest_adversary() < SMASH_RANGE:
        can_attack = false
        shoot_timer.wait_time = SMASH_INTERVAL
        shoot_timer.start()
        animation_player.play("smash_attack")
        
    if _can_move():
        move_and_slide(velocity + knockback_velocity)

func _can_move():
    return game_root.game_state == game_root.State.NORMAL

func _shoot_cooldown_finished():
    can_attack = true
    
func _begin_movement():
    velocity = get_new_movement_direction() * SPEED
    movement_duration_timer.wait_time = MOVEMENT_DURATION
    movement_duration_timer.start()
    
func _end_movement():
    velocity = Vector2.ZERO

func _on_body_entered(body):
    if body.is_in_group("Players"):
        pass
    if body.is_in_group("Bullets"):
        # Damage and knockback only from non-reflected bullets
        if !body.is_reflected:
            damage(1)
            SoundHandler.play_bullet_hit()
            var push = body.global_position.direction_to(global_position).normalized() * BULLET_KNOCKBACK
            knockback(push.x, push.y)
        body.queue_free()

func _on_AnimationPlayer_animation_finished(anim_name):
    if anim_name == "smash_attack":
        animation_player.play("rest")
