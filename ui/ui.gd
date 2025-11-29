extends CanvasLayer

#signal create_server
#signal connect_as_client

# signal add_player(peer_id:int, player_name:String)

func _ready() -> void:
	$menu.switch_to("initial")

func _on_game_state_changed(new_state):
	match new_state:
		Game.State.HOSTING:
			# $menu.hide()
			$menu.switch_to("lobby")
		Game.State.CONNECTING:
			$menu.switch_to("connecting")
		Game.State.CONNECTED:
			$menu.switch_to("lobby")

###

#func _on_create_server_button_pressed() -> void:
	#emit_signal("create_server")
#
#func _on_connect_button_pressed() -> void:
	#emit_signal("connect_as_client")

func _on_peer_spawner_spawned(_node: Node) -> void:
	print("%s: Spawned a peer: %s / %s (%s)" % [multiplayer.get_unique_id(), _node.peer_id, _node.name, _node.player_name])
