extends KinematicBody2D

const WALK_SPEED = 64

onready var velocity : Vector2 = Vector2()

func _ready():
	pass

func _physics_process(delta):
	velocity.x = 0
	velocity.y = 0
	if(Input.is_action_pressed("MOVE_LEFT")):
		velocity.x += -WALK_SPEED
	if(Input.is_action_pressed("MOVE_RIGHT")):
		velocity.x += WALK_SPEED
	if(Input.is_action_pressed("MOVE_UP")):
		velocity.y += -WALK_SPEED
	if(Input.is_action_pressed("MOVE_DOWN")):
		velocity.y += WALK_SPEED
	
	move_and_slide(velocity)
