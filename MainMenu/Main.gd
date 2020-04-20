extends Node2D

onready var animation_player = $AnimationPlayer

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
