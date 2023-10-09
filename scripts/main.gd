extends Node2D

@export_range(0.0, 1.0) var threshold: float = .1
@onready var character = $Character
@onready var blink_timer = $Character/BlinkTimer

var blinking = false
var mouth_opened = false
var record_bus = null

func _ready():
	record_bus = AudioServer.get_bus_index('record')

func _process(_delta):
	# Process audio
	var sample = AudioServer.get_bus_peak_volume_left_db(record_bus, 0)
	var linear = snappedf(db_to_linear(sample), 0.01)
	
	mouth_opened = linear > threshold
		
	#Manage animations
	if mouth_opened:
		if blinking:
			character.play("mouth_open_eye_closed")
		else:
			character.play("mouth_open_eye_open")
	else:
		if blinking:
			character.play("mouth_closed_eye_closed")
		else:
			character.play("mouth_closed_eye_open")

func _on_blink_timer_timeout():
	blinking = true


func _on_character_animation_finished():
	if blinking:
		await get_tree().create_timer(.01).timeout
		blinking = false
