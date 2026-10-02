extends Node

## Distinguishes which signals to hook into if player has decided to use ENET
## or SteamPeer multiplayer
var steam_is_chosen := false
var lobby_id: int = 0
var invite_lobby_id: int = 0
var steam_username := ""

@onready var steam_menu_scene: PackedScene = load("uid://cu8s3te846lb")


func _ready() -> void:
	Steam.join_requested.connect(_on_lobby_join_requested)


func _process(_delta: float) -> void:
	Steam.run_callbacks()


func initialize_steam() -> void:
	var initialize_response: Dictionary = Steam.steamInitEx(480)
	print("Did Steam Initialize?: %s" % initialize_response)

	if initialize_response['status'] > Steam.STEAM_API_INIT_RESULT_OK:
		printerr("Failed to initialize Steam, shutting down: %s" % initialize_response)
		get_tree().quit()

	steam_username = Steam.getPersonaName()


func player_exit_lobby(peer_id: int) -> void:
	if lobby_id != 0 and peer_id == multiplayer.get_unique_id():
		Steam.leaveLobby(lobby_id)
		lobby_id = 0
		print("Player %s has exited the lobby" % peer_id)


func invite_player() -> void:
	Steam.activateGameOverlayInviteDialog(lobby_id)


func _on_lobby_join_requested(_lobby_id: int, friend_id: int) -> void:
	var friend_joining: String = Steam.getFriendPersonaName(friend_id)
	print("Joining lobby with %s" % friend_joining)

	invite_lobby_id = _lobby_id
	get_tree().change_scene_to_packed(steam_menu_scene)
