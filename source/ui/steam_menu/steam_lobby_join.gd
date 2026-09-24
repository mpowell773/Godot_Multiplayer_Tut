extends Node

const LOBBY_ENTRY = preload("uid://gcn2mfeiyhq")

var main_scene: PackedScene = preload("uid://cxgeu56nx8jw0")

@onready var displayed_lobbies: VBoxContainer = %DisplayedLobbies
@onready var filter_button: Button = %FilterButton
@onready var refresh_button: Button = %RefreshButton
@onready var back_button: Button = %BackButton
@onready var lobby_filters: Control = %LobbyFilters
@onready var distance_option: OptionButton = %DistanceOption
@onready var open_slots_spin_box: SpinBox = %OpenSlotsSpinBox
@onready var max_lobbies_spin_box: SpinBox = %MaxLobbiesSpinBox
@onready var search_terms_edit: LineEdit = %SearchTermsEdit
@onready var close_filters_button: Button = %CloseFiltersButton

@onready var steam_menu_scene: PackedScene = load("uid://cu8s3te846lb")

#
func _ready() -> void:
	filter_button.pressed.connect(_on_filter_button_pressed)
	refresh_button.pressed.connect(_on_refresh_button_pressed)
	back_button.pressed.connect(_on_back_button_pressed)
	close_filters_button.pressed.connect(_on_close_filters_button_pressed)

	Steam.lobby_match_list.connect(_on_lobby_match_list)

	lobby_filters.visible = false


func add_request_lobby_filters() -> void:
	Steam.addRequestLobbyListDistanceFilter(\
		distance_option.selected as Steam.LobbyDistanceFilter
	)
	Steam.addRequestLobbyListFilterSlotsAvailable(int(open_slots_spin_box.value))
	Steam.addRequestLobbyListResultCountFilter(int(max_lobbies_spin_box.value))

	var these_terms: PackedStringArray = search_terms_edit.text.split(",", false)
	if these_terms.size() > 0:
		for this_term in these_terms:
			var data_key_value: PackedStringArray = this_term.split(":", false, 1)
			if data_key_value.size() == 2:
				if data_key_value[0].length() > Steam.MAX_LOBBY_KEY_LENGTH:
					printerr("Invalid term passed, too long: %s" % this_term)
					return
			Steam.addRequestLobbyListStringFilter(\
				data_key_value[0],
				data_key_value[1],
				Steam.LOBBY_COMPARISON_EQUAL
			)


func _on_filter_button_pressed() -> void:
	lobby_filters.visible = true


func _on_refresh_button_pressed() -> void:
	add_request_lobby_filters()
	Steam.requestLobbyList()


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_packed(steam_menu_scene)


func _on_close_filters_button_pressed() -> void:
	lobby_filters.visible = false


func _on_lobby_match_list(these_lobbies: Array) -> void:
	if these_lobbies.size() == 0:
		print("No lobbies were found")
		return

	for this_lobby in these_lobbies:
		var lobby_object := LOBBY_ENTRY.instantiate()
		lobby_object.name = "Lobby%s" % this_lobby
		lobby_object.set_lobby_id(this_lobby)
		lobby_object.joining_lobby.connect(_on_joining_lobby)
		displayed_lobbies.call_deferred("add_child", lobby_object)


func _on_joining_lobby() -> void:
	pass
