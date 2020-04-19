extends Node2D

var mage_enemy_scene = load("res://Enemies/BasicEnemy.tscn")

onready var spawn_pos = $SpawnPos
onready var spawn_timer = $SpawnTimer
onready var animation_player = $AnimationPlayer

onready var game_root = get_tree().get_root().get_node("Gameplay")

onready var TOO_CLOSE_RANGE = 100

func _ready():
    spawn_timer.connect("timeout", self, "_spawn_timer_finished")
    spawn_timer.wait_time = get_spawn_time()
    spawn_timer.one_shot = true
    spawn_timer.start()

func spawn_mage_enemy() -> void:
    if are_players_too_close():
        return;
    var mage = mage_enemy_scene.instance()
    mage.global_position = spawn_pos.global_position
    game_root.add_entity(mage)
    
func are_players_too_close() -> bool:
    var boss = get_tree().get_nodes_in_group("Boss")[0]
    var player = get_tree().get_nodes_in_group("Players")[0]
    var boss_distance = global_position.distance_to(boss.global_position)
    var player_distance = global_position.distance_to(player.global_position)
    return min(boss_distance, player_distance) <= TOO_CLOSE_RANGE
    
func get_spawn_time() -> float:
    return rand_range(8, 16)
    

func _spawn_timer_finished():
    if !animation_player.is_playing():
        animation_player.play("active")

func _on_AnimationPlayer_animation_finished(anim_name):
    if anim_name == "active":
        animation_player.play("rest")
        spawn_timer.wait_time = get_spawn_time()
        # Restart the spawn timer
        spawn_timer.start()
