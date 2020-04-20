extends Node2D

onready var animation_player = $AnimationPlayer
onready var eyes_player = $EyesPlayer
onready var blink_timer = $BlinkTimer

func _ready():
    SoundHandler.mainMenuSong.play()
#    OS.set_window_size(Vector2(800, 640))
#    var screen_size = OS.get_screen_size()
#    var window_size = OS.get_window_size()
#
#    OS.set_window_position(screen_size*0.5 - window_size*0.5)

func _process(delta):
    pass

func _on_StartButton_pressed():
    SoundHandler.mainMenuSong.stop()
    animation_player.play("fade_out")

func _on_ExitButton_pressed():
    get_tree().quit()

func _on_AnimationPlayer_animation_finished(anim_name):
    if anim_name == "fade_out":
        get_tree().change_scene("res://GameplayScene/Gameplay.tscn")

func _on_BlinkTimer_timeout():
    var blink_speed = 2.5
    eyes_player.play("blink", -1, blink_speed)
    blink_timer.wait_time = rand_range(1, 6)
    blink_timer.start()
