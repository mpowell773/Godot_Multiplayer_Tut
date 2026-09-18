extends Node

## Distinguishes which signals to hook into if player has decided to use ENET
## or SteamPeer multiplayer
var steam_is_chosen := false
var lobby_id: int = 0
var invite_lobby_id: int = 0
var steam_username := ""


func _process(_delta: float) -> void:
	Steam.run_callbacks()


func initialize_steam() -> void:
	var initialize_response: Dictionary = Steam.steamInitEx(480)
	print("Did Steam Initialize?: %s" % initialize_response)

	if initialize_response['status'] > Steam.STEAM_API_INIT_RESULT_OK:
		printerr("Failed to initialize Steam, shutting down: %s" % initialize_response)
		get_tree().quit()

	steam_username = Steam.getPersonaName()
