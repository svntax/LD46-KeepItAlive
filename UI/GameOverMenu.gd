extends Control

func _ready():
    hide()

func _on_ReturnButton_pressed():
    get_tree().paused = false
    get_tree().change_scene("res://MainMenu/Main.tscn")
