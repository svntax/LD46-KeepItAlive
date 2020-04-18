extends Area2D

func _ready():
    self.connect("body_entered", self, "_on_body_entered")

func _on_body_entered(body):
    if body.is_in_group("Players"):
        # TODO: what should happen when an enemy's DamageArea touches the player
        pass
