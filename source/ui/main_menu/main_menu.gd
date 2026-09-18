extends Control

var main_scene: PackedScene = preload("uid://cxgeu56nx8jw0")
var options_menu_scene: PackedScene = preload("uid://bo5x5clqnyoui")
var steam_menu_scene: PackedScene = preload("uid://cu8s3te846lb")

@onready var single_player_button: Button = $VBoxContainer/SinglePlayerButton
@onready var multiplayer_button: Button = $VBoxContainer/MultiplayerButton
@onready var quit_button: Button = $VBoxContainer/QuitButton
@onready var options_button: Button = $VBoxContainer/OptionsButton
@onready var steam_button: Button = $VBoxContainer/SteamButton

@onready var multiplayer_menu_scene: PackedScene = load("uid://b7ek2hamlcwdo")


func _ready() -> void:
	single_player_button.pressed.connect(_on_single_player_button_pressed)
	multiplayer_button.pressed.connect(_on_multiplayer_button_pressed)
	quit_button.pressed.connect(_on_quit_button_pressed)
	options_button.pressed.connect(_on_options_buttons_pressed)
	steam_button.pressed.connect(_on_steam_button_pressed)

	UIAudioManager.register_buttons(
		[
			single_player_button,
			multiplayer_button,
			options_button,
			quit_button
		]
	)


func _on_single_player_button_pressed() -> void:
	get_tree().change_scene_to_packed(main_scene)
	Cursor.change_cursor(true)


func _on_multiplayer_button_pressed() -> void:
	get_tree().change_scene_to_packed(multiplayer_menu_scene)


func _on_steam_button_pressed() -> void:
	Steamworks.steam_is_chosen = true
	Steamworks.initialize_steam()
	get_tree().change_scene_to_packed(steam_menu_scene)


func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_options_buttons_pressed() -> void:
	var options_menu := options_menu_scene.instantiate()
	add_child(options_menu)
