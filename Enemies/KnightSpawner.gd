extends Node2D

var knight_enemy_scene = load("res://Enemies/KnightEnemy.tscn")

onready var spawn_pos = $SpawnPos
onready var spawn_timer = $SpawnTimer

onready var start_time = OS.get_ticks_msec()

onready var game_root = get_tree().get_root().get_node("Gameplay")

onready var GAME_DURATION_MILLIS = 8 * 60 * 1000 # 8 minutes

onready var ENEMIES_PER_MINUTE_START = 3;
onready var ENEMIES_PER_MINUTE_END = 8;

func _ready():
    spawn_timer.connect("timeout", self, "_spawn_timer_finished")
    spawn_timer.wait_time = get_spawn_time()
    spawn_timer.one_shot = true
    spawn_timer.start()

func spawn_knight_enemy() -> void:
    if game_root.game_state != game_root.State.NORMAL:
        return
    
    var knight = knight_enemy_scene.instance()
    knight.global_position = spawn_pos.global_position
    game_root.add_entity(knight)
    
func get_spawn_time() -> float:
    var seconds = 60 / get_enemies_per_minute_now()
    return rand_range(seconds * 0.75, seconds * 1.25)
    
func get_enemies_per_minute_now() -> float:
    var difference = ENEMIES_PER_MINUTE_END - ENEMIES_PER_MINUTE_START
    var progress = (OS.get_ticks_msec() - start_time) / Globals.GAME_DURATION_MILLIS
    return ENEMIES_PER_MINUTE_START + progress * difference;

func _spawn_timer_finished():
    spawn_knight_enemy()
    spawn_timer.wait_time = get_spawn_time()
    # Restart the spawn timer
    spawn_timer.start()
