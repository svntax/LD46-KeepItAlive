extends Node2D

onready var ysort_group = $YSort
onready var camera = $Camera2D

onready var screenshake_active = false

onready var GAME_DURATION_MILLIS = 8 * 60 * 1000 # 8 minutes

# Used to add entities that need to be y-sorted, like enemies
func add_entity(entity) -> void:
    ysort_group.add_child(entity)

func shake_camera(duration, magnitude, frequency):
    if not screenshake_active:
        screenshake_active = true
        var start_time = OS.get_ticks_msec()
        var _time = start_time
        
        while _time < start_time + (duration * 1000):
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
