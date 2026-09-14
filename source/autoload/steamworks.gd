extends Node


func _ready() -> void:
	initialize_steam()


func _process(_delta: float) -> void:
	Steam.run_callbacks()


func initialize_steam() -> void:
	var initialize_response: Dictionary = Steam.steamInitEx(480)
	print("Did Steam Initialize?: %s" % initialize_response)

	if initialize_response['status'] > Steam.STEAM_API_INIT_RESULT_OK:
		printerr("Failed to initialize Steam, shutting down: %s" % initialize_response)
		get_tree().quit()
