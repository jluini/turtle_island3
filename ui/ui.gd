extends CanvasLayer

signal create_server
signal connect_as_client

func _on_game_state_changed(new_state):
	match new_state:
		Game.State.HOSTING:
			$menu.hide()
		Game.State.CONNECTING:
			$menu.switch_to("connecting")

###

func _on_create_server_button_pressed() -> void:
	emit_signal("create_server")

func _on_connect_button_pressed() -> void:
	emit_signal("connect_as_client")
