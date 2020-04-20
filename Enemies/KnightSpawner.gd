extends Node2D

var knight_enemy_scene = load("res://Enemies/KnightEnemy.tscn")

onready var spawn_pos = $SpawnPos
onready var spawn_timer = $SpawnTimer

onready var game_root = get_tree().get_root().get_node("Gameplay")

func _ready():
    spawn_timer.connect("timeout", self, "_spawn_timer_finished")
    spawn_timer.wait_time = get_spawn_time()
    spawn_timer.one_shot = true
    spawn_timer.start()

func spawn_knight_enemy() -> void:
    var knight = knight_enemy_scene.instance()
    knight.global_position = spawn_pos.global_position
    game_root.add_entity(knight)
    
func get_spawn_time() -> float:
    return rand_range(4, 8)

func _spawn_timer_finished():
    spawn_knight_enemy()
    spawn_timer.wait_time = get_spawn_time()
    # Restart the spawn timer
    spawn_timer.start()
