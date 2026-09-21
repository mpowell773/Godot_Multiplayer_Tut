extends MarginContainer

@onready var host_button: Button = %HostButton
@onready var join_button: Button = %JoinButton
@onready var back_button: Button = %BackButton
@onready var host_pop_up: Panel = $HostPopUp
@onready var max_players_spin_box: SpinBox = %MaxPlayersSpinBox
@onready var visibility_option_button: OptionButton = %VisibilityOptionButton
@onready var data_list_line_edit: LineEdit = %DataListLineEdit
@onready var create_button: Button = %CreateButton
@onready var host_back_button: Button = %HostBackButton

@onready var main_menu_scene: PackedScene = load("uid://cptovqnmaae8k")


func _ready() -> void:
	host_button.pressed.connect(_on_host_button_pressed)
	join_button.pressed.connect(_on_join_button_pressed)
	back_button.pressed.connect(_on_back_button_pressed)

	create_button.pressed.connect(_on_create_button_pressed)

	Steam.lobby_joined.connect(_on_lobby_joined)
	Steam.lobby_created.connect(_on_lobby_created)

	initialize_base_settings()


func initialize_base_settings() -> void:
	host_pop_up.visible = false


func _on_host_button_pressed() -> void:
	host_pop_up.visible = true


func _on_join_button_pressed() -> void:
	pass


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_packed(main_menu_scene)
	Steam.steamShutdown()


func _on_create_button_pressed() -> void:
	var lobby_type: Steam.LobbyType = visibility_option_button.selected as Steam.LobbyType
	Steam.createLobby(lobby_type, int(max_players_spin_box.value))


func _on_lobby_joined() -> void:
	pass


func _on_lobby_created(connect_status: Steam.Result, lobby_id: int) -> void:
	if connect_status == Steam.Result.RESULT_OK:
		print("Succesfully created lobby %s" % lobby_id)
		Steamworks.lobby_id = lobby_id

	var lobby_name := "%s's lobby" % Steamworks.steam_username
	if not Steam.setLobbyData(Steamworks.lobby_id, "lobby_name", lobby_name):
		printerr("Failed to set lobby name")

	var data_sets: PackedStringArray = data_list_line_edit.text.split(",", false)
	for this_data in data_sets:
		var data_key_value: PackedStringArray = this_data.split(":", false, 1)
		if data_key_value.size() == 2:
			if not Steam.setLobbyData(Steamworks.lobby_id, data_key_value[0], data_key_value[1]):
				printerr("Failed to set lobby %s data [%s : %s]" % [Steamworks.lobby_id, data_key_value[0], data_key_value[1]])
