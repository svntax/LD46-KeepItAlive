extends Node2D

var mage_enemy_scene = load("res://Enemies/BasicEnemy.tscn")

onready var spawn_pos = $SpawnPos
onready var spawn_timer = $SpawnTimer
onready var animation_player = $AnimationPlayer

onready var game_root = get_tree().get_root().get_node("Gameplay")

func _ready():
    spawn_timer.connect("timeout", self, "_spawn_timer_finished")
    spawn_timer.wait_time = 5
    spawn_timer.one_shot = true
    spawn_timer.start()

func spawn_mage_enemy() -> void:
    var mage = mage_enemy_scene.instance()
    mage.global_position = spawn_pos.global_position
    game_root.add_entity(mage)

func _spawn_timer_finished():
    if !animation_player.is_playing():
        animation_player.play("active")

func _on_AnimationPlayer_animation_finished(anim_name):
    if anim_name == "active":
        animation_player.play("rest")
        # Restart the spawn timer
        spawn_timer.start()
