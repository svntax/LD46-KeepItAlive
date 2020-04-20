extends Node

onready var knightHitsBoss = $KnightHitsBoss
onready var playerSwingsSword = $PlayerSwingsSword
onready var bossSlam = $BossSlam
onready var rumble = $Rumble
onready var mageDeath = $MageDeath
onready var bulletHit = $MageProjectileHit
onready var reflectSound = $ReflectSound
onready var reflectSound2 = $ReflectSound2
onready var wallHit = $WallHit

onready var gameplaySong1 = $GameSong1
onready var mainMenuSong = $MainMenuSong
onready var deathSound = $DeathSound
onready var victorySound = $VictorySound

func play_bullet_hit() -> void:
    bulletHit.pitch_scale = 1.0 + rand_range(-0.1, 0.1)
    bulletHit.play()

func play_sword_hit() -> void:
    bulletHit.pitch_scale = 1.0 + rand_range(-0.1, 0.1)
    bulletHit.play()

func play_reflect_sound() -> void:
    if randf() < 0.5:
        reflectSound.play()
    else:
        reflectSound2.play()
