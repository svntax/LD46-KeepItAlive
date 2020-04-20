extends Node2D

onready var animation_player = $AnimationPlayer

func _ready():
    animation_player.play("spread")

func _on_AnimationPlayer_animation_finished(anim_name):
    queue_free()
    
onready var DAMAGE_AMOUNT = 1

# Connected to both damage areas
func _on_DamageArea_body_entered(body):
    if body.is_in_group("Enemies"):
        body.damage(DAMAGE_AMOUNT)
        body.stun()
