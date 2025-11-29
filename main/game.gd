extends Node2D
class_name Game

signal state_changed(new_state)

const PORT = 7000
const DEFAULT_SERVER_IP = "127.0.0.1" # IPv4 localhost
const MAX_CONNECTIONS = 20

enum State {
	NOTHING,
	INITIAL,
	
	HOSTING,
	
	CONNECTING,
	CONNECTED
}

var state : State = State.NOTHING:
	set(new_state):
		state = new_state
		$ui.get_node("%state_label").text = State.find_key(new_state)
		emit_signal("state_changed", new_state)

var lobby_info: LobbyInfo
# var local_peer:Peer

func _ready() -> void:
	state = State.INITIAL
	_connect_network_callbacks()
	
	# _clear_peer_list()
	# local_peer = _add_peer(0, Samples.new().sample_player_name())
	
	# cosas temporarias
	randomize()
	get_window().position = Vector2(420, 0)
	
#func _clear_peer_list():
	#for c in %peer_list.get_children():
		#if c != local_peer:
			#c.free()
	#
	#for c in %peer_list.get_children():
		#%peer_list.remove_child(c)

#func _add_peer(peer_id, player_name):
	## %peer_list/peer.player_name = player_name
	#var new_peer_node:Peer = preload("res://network/peer.tscn").instantiate()
	#new_peer_node.peer_id = 1
	##new_peer_node.name = "peer_%s" % peer_id
	#new_peer_node.player_name = player_name
	#
	#%peer_list.add_child(new_peer_node)
	#
	#return new_peer_node
###

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_left"):
		$offset/camera.position.x += 100
	elif event.is_action_pressed("ui_right"):
		$offset/camera.position.x -= 100
	elif event.is_action_pressed("fullscreen"):
		var before = DisplayServer.window_get_mode()
		if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		
		print("%s -> %s" % [before, DisplayServer.window_get_mode()])

### Network callbacks

func _on_peer_connected(id):
	print("%s: peer_connected %s" % [multiplayer.get_unique_id(), id])
	if state == State.HOSTING:
		assert(id != 1)
		print("1. spawning remote peer %s" % [id])
		
		#var new_peer_node:Peer = preload("res://network/peer.tscn").instantiate()
		#new_peer_node.peer_id = id
		#new_peer_node.player_name = '-'
		#
		#%peer_list.add_child(new_peer_node)
		
	elif state == State.CONNECTING and id == 1:
		state = State.CONNECTED
		
		# var new_player_name = %peer_list.get_children()[0].player_name
		# var new_player_name = 'Cliente'
		
		#_clear_peer_list()
		
		# TODO: aqui se decide tener un propio player (deberia ser solo si no arranco el partido)
		# set_initial_name.rpc_id(1, local_peer.player_name)

func _on_peer_disconnected(id):
	print("%s: peer_disconnected %s" % [multiplayer.get_unique_id(), id])

func _on_connected_to_server():
	print("%s: connected_to_server" % [multiplayer.get_unique_id()])

func _on_connection_failed():
	print("%s: connection_failed" % [multiplayer.get_unique_id()])

func _on_server_disconnected():
	print("server_disconnected")

### Network start

func _try_to_create_server() -> int:
	if state != State.INITIAL:
		return FAILED
	
	local_peer.peer_id = 1
	
	var new_peer = ENetMultiplayerPeer.new()
	var error = new_peer.create_server(PORT, MAX_CONNECTIONS)
	
	print("create_server -> ", error_string(error))

	#var new_peer_node:Peer = preload("res://network/peer.tscn").instantiate()
	#new_peer_node.name = "player1"
	#new_peer_node.player_name = %peer_list.get_children()[0].player_name
	#new_peer_node.peer_id = 1
	#
	#_clear_peer_list()
	#
	#%peer_list.add_child(new_peer_node)
	
	if error:
		local_peer.peer_id = 0
		return error
	
	lobby_info = LobbyInfo.new()
	lobby_info.map_name = 'Isla'
	var new_peer_data: PeerInfo = PeerInfo.new()
	var new_player_data: PlayerInfo = PlayerInfo.new()
	new_player_data.player_name = 'Jorgito'
	new_player_data.team = 1
	new_peer_data.peer_name = Samples.new().sample_player_name()
	new_peer_data.players = [new_player_data]
	lobby_info.peers = [new_peer_data]
	
	multiplayer.multiplayer_peer = new_peer
	state = State.HOSTING

	return OK

func _try_to_connect_as_client() -> int:
	if state != State.INITIAL:
		return FAILED
	
	local_peer.peer_id = 0
	
	var new_peer = ENetMultiplayerPeer.new()
	var error = new_peer.create_client(DEFAULT_SERVER_IP, PORT)
	
	print("create_client -> ", error_string(error))
	
	if error:
		return error
	
	multiplayer.multiplayer_peer = new_peer
	state = State.CONNECTING
	print(%peer_list.get_children().map(func(c:Peer): return [c.peer_id, c.name, c.get_instance_id()]))
	# _clear_peer_list()
	
	return OK

#func add_player(player_name):
#@rpc("any_peer", "call_remote", "reliable", 0)
#func set_initial_name(player_name):
	#print("%s requests adding '%s'" % [multiplayer.get_remote_sender_id(), player_name])
	
	#var new_peer_node:Peer = preload("res://network/peer.tscn").instantiate()
	#new_peer_node.name = "player%s" % [%peer_list.get_child_count() + 1]
	#new_peer_node.player_name = player_name
	#new_peer_node.peer_id = multiplayer.get_remote_sender_id()
	#
	#%peer_list.add_child(new_peer_node)
	
	var id = multiplayer.get_remote_sender_id()
	
	print("2. spawning remote peer %s" % [id])
	
	var new_peer_node:Peer = preload("res://network/peer.tscn").instantiate()
	new_peer_node.peer_id = id
	new_peer_node.player_name = player_name
	
	%peer_list.add_child(new_peer_node)
	
	#%peer_list.get_node("player_%s" % id).player_name = player_name
	pass 

### Private misc

func _connect_network_callbacks() -> void:
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

### UI callbacks

func _on_create_server_button_pressed() -> void:
	call_deferred("_try_to_create_server")

func _on_connect_button_pressed() -> void:
	call_deferred("_try_to_connect_as_client")

func _on_peer_add_player(peer_id: int, player_name: String) -> void:
	print("%s: Add player %s (%s)" % [multiplayer.get_unique_id(), player_name, peer_id])
