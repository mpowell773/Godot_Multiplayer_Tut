extends Node

const SERVER_ID: int = 1

func _ready() -> void:
	peer_ready.rpc_id(SERVER_ID)


@rpc("any_peer", "call_local", "reliable")
func peer_ready() -> void:
	print("peer %s ready" % multiplayer.get_remote_sender_id() )
