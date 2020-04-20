extends Node2D

func _ready():
    SoundHandler.mainMenuSong.play()

func _process(delta):
    if Input.is_action_just_pressed("ui_accept"):
        SoundHandler.mainMenuSong.stop()
        get_tree().change_scene("res://GameplayScene/Gameplay.tscn")
