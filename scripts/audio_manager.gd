extends Node2D

var listeners = []

func on_sound(node):
	if node != null:
		for listener in listeners:
			listener.on_sound(node)

func add_listener(listener):
	listeners.append(listener)

func remove_listener(listener):
	var index = listeners.find(listener)
	if index != -1:
		listeners.remove(index)
