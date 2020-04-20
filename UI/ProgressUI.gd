extends Control

onready var game_root = get_tree().get_root().get_node("Gameplay")

onready var progress_bar = $ProgressBar
onready var progress_timer = $ProgressTimer

onready var time_elapsed = 0.0

func _ready():
    progress_bar.set_value(0)
    progress_timer.start()

func update_progress_bar() -> void:
    var value = floor(100 * time_elapsed / Globals.GAME_DURATION_SECONDS)
    progress_bar.set_value(value)
    
    if progress_bar.get_value() >= 100:
        progress_timer.stop()
        # Game win
        print("game win")

func _on_ProgressTimer_timeout():
    time_elapsed += 1
    update_progress_bar()
