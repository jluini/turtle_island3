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
}

var state : State = State.NOTHING:
	set(new_state):
		state = new_state
		$ui.get_node("%state_label").text = State.find_key(new_state)
		emit_signal("state_changed", new_state)

func _ready() -> void:
	get_window().position = Vector2(420, 0)
	state = State.INITIAL
	_connect_network_callbacks()
	
	var player_name = Samples.new().sample_player_name()
	$ui.get_node("%player_list/peer").player_name = player_name

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
	if state == State.CONNECTING and id == 1:
		var new_player_name = $ui.get_node("%player_list").get_children()[0].player_name
		
		for c in $ui.get_node("%player_list").get_children():
			c.free()
		
		# TODO: aqui se decide tener un propio player (deberia ser solo si no arranco el partido)
		add_player.rpc_id(1, new_player_name)

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
	
	var new_peer = ENetMultiplayerPeer.new()
	var error = new_peer.create_server(PORT, MAX_CONNECTIONS)
	
	print("create_server -> ", error_string(error))

	var new_peer_node:Peer = preload("res://network/peer.tscn").instantiate()
	new_peer_node.name = "player1"
	new_peer_node.player_name = $ui.get_node("%player_list").get_children()[0].player_name
	new_peer_node.peer_id = 1
	
	for c in $ui.get_node("%player_list").get_children():
		c.free()
	
	$ui.get_node("%player_list").add_child(new_peer_node)
	
	if error:
		return error
	
	multiplayer.multiplayer_peer = new_peer
	state = State.HOSTING

	return OK

func _try_to_connect_as_client() -> int:
	if state != State.INITIAL:
		return FAILED
	
	var new_peer = ENetMultiplayerPeer.new()
	var error = new_peer.create_client(DEFAULT_SERVER_IP, PORT)
	
	print("create_client -> ", error_string(error))
	
	if error:
		return error
	
	multiplayer.multiplayer_peer = new_peer
	state = State.CONNECTING
	
	return OK

@rpc("any_peer", "call_remote", "reliable", 0)
func add_player(player_name):
	print("%s requests adding '%s'" % [multiplayer.get_remote_sender_id(), player_name])
	
	var new_peer_node:Peer = preload("res://network/peer.tscn").instantiate()
	new_peer_node.name = "player%s" % [$ui.get_node("%player_list").get_child_count() + 1]
	new_peer_node.player_name = player_name
	new_peer_node.peer_id = multiplayer.get_remote_sender_id()
	
	$ui.get_node("%player_list").add_child(new_peer_node)
	

### Private misc

func _connect_network_callbacks() -> void:
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

### UI callbacks

func _on_ui_connect_as_client() -> void:
	call_deferred("_try_to_connect_as_client")


func _on_ui_create_server() -> void:
	call_deferred("_try_to_create_server")
