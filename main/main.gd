extends Node2D

enum State {
	NOTHING,
	INITIAL
}

var state : State = State.NOTHING:
	set(new_state):
		state = new_state
		$ui.get_node("%state_label").text = State.find_key(new_state)
		

func _ready() -> void:
	get_window().position = Vector2(420, 0)
	state = State.INITIAL

func _set_state(new_state:State) -> void:
	state = new_state
	

##

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
			
		
