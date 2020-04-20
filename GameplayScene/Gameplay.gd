extends Node2D

onready var ysort_group = $YSort
onready var camera = $Camera2D
onready var game_over_menu = $UILayer/GameOverMenu

onready var screenshake_active = false

enum State {NORMAL, GAME_OVER, WIN}
onready var game_state = State.NORMAL

func _ready():
    SoundHandler.gameplaySong1.play()

func win_game() -> void:
    game_state = State.WIN
    SoundHandler.gameplaySong1.stop()
    SoundHandler.victorySound.play()

func game_over() -> void:
    game_state = State.GAME_OVER
    SoundHandler.gameplaySong1.stop()
    SoundHandler.deathSound.play()
    game_over_menu.show()

# Used to add entities that need to be y-sorted, like enemies
func add_entity(entity) -> void:
    ysort_group.add_child(entity)

func shake_camera(duration, magnitude, frequency):
    if game_state != State.NORMAL:
        return
    
    if not screenshake_active:
        screenshake_active = true
        var start_time = OS.get_ticks_msec()
        var _time = start_time
        
        while _time < start_time + (duration * 1000) and game_state == State.NORMAL:
            # Update _time to current ticks
            _time = OS.get_ticks_msec()
            
            var offset = Vector2()
            offset.x = rand_range(-magnitude, magnitude)
            offset.y = rand_range(-magnitude, magnitude)
            camera.offset = offset
            
            # Pause the loop based on frequency.
            yield(get_tree().create_timer(1 / float(frequency)), "timeout")
        
        camera.offset = Vector2()
        screenshake_active = false
