extends Node

static var instance: UIAudioManager

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer


func _ready() -> void:
	instance = self


func register_buttons(buttons: Array) -> void:
	for button in buttons:
		button.pressed.connect(instance._on_button_pressed)


func _on_button_pressed() -> void:
	instance.audio_stream_player.play()
