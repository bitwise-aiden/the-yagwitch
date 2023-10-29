extends Node2D


# Private variables

var __keys : Dictionary = {}


# Lifecycle methods

func _ready() -> void:
	for key in $keys.get_children():
		__keys[key.key] = key


func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		print(event)
