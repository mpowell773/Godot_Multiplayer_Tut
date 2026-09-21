extends MarginContainer

@onready var host_button: Button = %HostButton
@onready var join_button: Button = %JoinButton
@onready var back_button: Button = %BackButton
@onready var host_pop_up: Panel = $HostPopUp

@onready var main_menu_scene: PackedScene = load("uid://cptovqnmaae8k")


func _ready() -> void:
	host_button.pressed.connect(_on_host_button_pressed)
	join_button.pressed.connect(_on_join_button_pressed)
	back_button.pressed.connect(_on_back_button_pressed)


func _on_host_button_pressed() -> void:
	host_pop_up.visible = true


func _on_join_button_pressed() -> void:
	pass


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_packed(main_menu_scene)
	Steam.steamShutdown()
