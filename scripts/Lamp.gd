extends Light2D

var probability = 0.5

var desired_state

func _ready():
	desired_state = is_enabled()

func turn_off():
	desired_state = false

func turn_on():
	desired_state = true

func set_state(input_state):
	set_enabled(input_state)
	desired_state = input_state

func _process(delta):
	if not desired_state == is_enabled():
		if delta*probability > randf():
			set_enabled(desired_state)
			for child in get_children():
				child.set_state(desired_state)
