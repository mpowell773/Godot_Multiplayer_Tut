class_name LobbyManager
extends Node

signal all_peers_readied
signal self_peer_readied
signal lobby_closed


var ready_peer_ids: Array[int] = []
## Added to MultiplayerSynchronizer so that player who join late have value 
## adjusted accordingly.
var _is_lobby_closed := false
var is_lobby_closed: bool:
	get:
		return _is_lobby_closed
	set(value):
		_is_lobby_closed = value
		if _is_lobby_closed:
			lobby_closed.emit()


func _ready() -> void:
	if is_multiplayer_authority():
		multiplayer.peer_disconnected.connect(on_peer_disconnected)

	# Singleplayer instance does not need readied logic.
	if multiplayer.multiplayer_peer is OfflineMultiplayerPeer:
		all_peers_readied.emit.call_deferred()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("lobby_ready"):
		request_peer_ready.rpc_id(MultiplayerPeer.TARGET_PEER_SERVER)
		get_viewport().set_input_as_handled()


func close_lobby() -> void:
	is_lobby_closed = true


@rpc("authority", "call_local", "reliable")
func set_peer_ready(peer_id: int) -> void:
	if peer_id == multiplayer.get_unique_id():
		self_peer_readied.emit()
		
	if not ready_peer_ids.has(peer_id):
		ready_peer_ids.append(peer_id)


@rpc("any_peer", "call_local", "reliable")
func request_peer_ready() -> void:
	if not is_multiplayer_authority() or is_lobby_closed:
		return
		
	var sender_id := multiplayer.get_remote_sender_id()
	set_peer_ready.rpc(sender_id)
	
	try_all_peers_ready()


# While it may not be necessary in this case to have check_all_peers_ready()
# and try_all_peers_ready() to be split, there may be cases where having the
# the bool function may be useful.
func try_all_peers_ready() -> void:
	if check_all_peers_ready():
		all_peers_readied.emit()


func check_all_peers_ready() -> bool:
	var all_peers := multiplayer.get_peers()
	all_peers.append(MultiplayerPeer.TARGET_PEER_SERVER)
	
	for peer_id in all_peers:
		if not ready_peer_ids.has(peer_id):
			return false
	return true

func on_peer_disconnected(_peer_id: int) -> void:
	try_all_peers_ready()
