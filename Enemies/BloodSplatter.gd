extends Node2D

onready var animation_player = $AnimationPlayer
onready var blood_right = $BloodRight
onready var blood_left = $BloodLeft

# direction will be -1, 1, or 0
func splat_effect(direction : int) -> void:
    if direction == -1:
        animation_player.play("splash_left")
    elif direction == 1:
        animation_player.play("splash_right")
    else:
        # Just randomly pick either sprite
        if randf() < 0.5:
            blood_right.show()
            blood_left.hide()
        else:
            blood_right.hide()
            blood_left.show()
