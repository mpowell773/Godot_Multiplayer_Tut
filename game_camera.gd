class_name GameCamera
extends Camera2D

const NOISE_GROWTH := 750.0
const SHAKE_STRENGTH := 12.0
const SHAKE_DECAY_RATE := 10.0

@export var noise_texture: FastNoiseLite

static var instance: GameCamera

var noise_offset_x: float
var noise_offset_y: float

var current_shake_percentage: float


func _ready() -> void:
	instance = self


func _process(delta: float) -> void:
	if current_shake_percentage == 0:
		return
	
	noise_offset_x += NOISE_GROWTH * delta
	noise_offset_y += NOISE_GROWTH * delta
	
	var offset_sample_x := noise_texture.get_noise_2d(noise_offset_x, 0.0)
	var offset_sample_y := noise_texture.get_noise_2d(0.0, noise_offset_y)
	
	offset = Vector2(offset_sample_x, offset_sample_y)\
		* SHAKE_STRENGTH * pow(current_shake_percentage, 2.0)

	current_shake_percentage = maxf(current_shake_percentage - (SHAKE_DECAY_RATE * delta), 0)

static func shake(shake_percent: float) -> void:
	instance.current_shake_percentage = clampf(shake_percent, 0.0, 1.0)
