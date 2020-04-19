extends Node2D

onready var animation_player = $AnimationPlayer

func _ready():
    animation_player.play("spread")

func _on_AnimationPlayer_animation_finished(anim_name):
    queue_free()

# Connected to both damage areas
func _on_DamageArea_body_entered(body):
    if body.is_in_group("Enemies"):
        body.damage()
        body.stun()
