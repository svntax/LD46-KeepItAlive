extends Node2D

onready var ysort_group = $YSort
onready var camera = $Camera2D
onready var game_over_menu = $UILayer/GameOverMenu
onready var game_win_menu = $UILayer/GameWinMenu
onready var cutscene_player = $CutscenePlayer
onready var blood_layer = $BloodLayer

onready var screenshake_active = false

enum State {NORMAL, GAME_OVER, WIN, INTRO}
onready var game_state = State.INTRO

func _ready():
    cutscene_player.play("fade_in")

func win_game() -> void:
    game_state = State.WIN
    SoundHandler.gameplaySong1.stop()
    
    # Kill all enemies
    var boss = get_tree().get_nodes_in_group("Boss")[0]
    for enemy in get_tree().get_nodes_in_group("Enemies"):
        enemy.damage(99, boss)
    
    yield(get_tree().create_timer(1.5), "timeout")
    SoundHandler.victorySound.play()
    yield(get_tree().create_timer(3.8), "timeout")
    cutscene_player.play("game_win")
    game_win_menu.show()

func game_over() -> void:
    game_state = State.GAME_OVER
    SoundHandler.gameplaySong1.stop()
    SoundHandler.deathSound.play()
    game_over_menu.show()

# Used to add entities that need to be y-sorted, like enemies
func add_entity(entity) -> void:
    ysort_group.add_child(entity)

func add_blood_splatter(entity) -> void:
    blood_layer.add_child(entity)

func shake_camera(duration, magnitude, frequency):
    if game_state != State.NORMAL:
        camera.offset = Vector2()
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

func _on_CutscenePlayer_animation_finished(anim_name):
    if anim_name == "fade_in":
        SoundHandler.gameplaySong1.play()
        game_state = State.NORMAL
    elif anim_name == "game_win":
        pass
