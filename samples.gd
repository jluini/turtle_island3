extends Node
class_name Samples

const PLAYER_NAMES = [
	"Jorge",
	"Carlos",
	"Alicia",
	"Jack",
	"Robinson Crusoe",
	"Roberto",
	"Bob",
]

func sample_player_name():
	return sample(PLAYER_NAMES)

func sample(from:Array):
	return from[randi() % from.size()]
