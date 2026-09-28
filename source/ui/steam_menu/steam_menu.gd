extends MarginContainer

var main_scene: PackedScene = preload("uid://cxgeu56nx8jw0")

@onready var host_button: Button = %HostButton
@onready var join_button: Button = %JoinButton
@onready var back_button: Button = %BackButton

@onready var main_menu_scene: PackedScene = load("uid://cptovqnmaae8k")
@onready var steam_lobby_host_scene: PackedScene = load("uid://7jk1ysfnpkud")
@onready var steam_lobby_join_scene: PackedScene = load("uid://clk8y8t2olfqb")


func _ready() -> void:
	host_button.pressed.connect(_on_host_button_pressed)
	join_button.pressed.connect(_on_join_button_pressed)
	back_button.pressed.connect(_on_back_button_pressed)

	Steam.lobby_joined.connect(_on_lobby_joined)

	if Steamworks.invite_lobby_id > 0:
		Steam.joinLobby(Steamworks.invite_lobby_id)
		# Reset invite_lobby_id in the case of switching to new lobby
		Steamworks.invite_lobby_id = 0


func _on_lobby_joined(
	lobby_id: int,
	_permissions: int,
	_locked: int,
	response: Steam.ChatRoomEnterResponse
) -> void:

	if response == Steam.ChatRoomEnterResponse.CHAT_ROOM_ENTER_RESPONSE_SUCCESS:
		print("Lobby %s joined successfully" % lobby_id)
		Steamworks.lobby_id = lobby_id

		#TODO: Implement multiplayer peer networking here
		get_tree().change_scene_to_packed(main_scene)

	else:
		match response:
			Steam.ChatRoomEnterResponse.CHAT_ROOM_ENTER_RESPONSE_DOESNT_EXIST:
				printerr("Failed joining lobby %s, this lobby no longer exists.")
			Steam.ChatRoomEnterResponse.CHAT_ROOM_ENTER_RESPONSE_NOT_ALLOWED:
				printerr("Failed joining lobby %s, you don't have permission to join this Lobbies.")
			Steam.ChatRoomEnterResponse.CHAT_ROOM_ENTER_RESPONSE_FULL:
				printerr("Failed joining lobby %s, the lobby is now full.")
			Steam.ChatRoomEnterResponse.CHAT_ROOM_ENTER_RESPONSE_ERROR:
				printerr("Failed joining lobby %s, something unexpected happened!")
			Steam.ChatRoomEnterResponse.CHAT_ROOM_ENTER_RESPONSE_BANNED:
				printerr("Failed joining lobby %s, you are banned from this lobby.")
			Steam.ChatRoomEnterResponse.CHAT_ROOM_ENTER_RESPONSE_LIMITED:
				printerr("Failed joining lobby %s, you cannot join due to having a limited account.")
			Steam.ChatRoomEnterResponse.CHAT_ROOM_ENTER_RESPONSE_CLAN_DISABLED:
				printerr("Failed joining lobby %s, this lobby is locked or disabled.")
			Steam.ChatRoomEnterResponse.CHAT_ROOM_ENTER_RESPONSE_COMMUNITY_BAN:
				printerr("Failed joining lobby %s, this lobby is community locked.")
			Steam.ChatRoomEnterResponse.CHAT_ROOM_ENTER_RESPONSE_MEMBER_BLOCKED_YOU:
				printerr("Failed joining lobby %s, a user in the lobby has blocked you from joining.")
			Steam.ChatRoomEnterResponse.CHAT_ROOM_ENTER_RESPONSE_YOU_BLOCKED_MEMBER:
				printerr("Failed joining lobby %s, a user you have blocked is in the lobby.")
			Steam.ChatRoomEnterResponse.CHAT_ROOM_ENTER_RESPONSE_RATE_LIMIT_EXCEEDED:
				printerr("Failed joining lobby %s, you have exceeded the rate limit.")


func _on_host_button_pressed() -> void:
	get_tree().change_scene_to_packed(steam_lobby_host_scene)


func _on_join_button_pressed() -> void:
	get_tree().change_scene_to_packed(steam_lobby_join_scene)


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_packed(main_menu_scene)
	Steam.steamShutdown()
