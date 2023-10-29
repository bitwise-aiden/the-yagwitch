extends Node2D


# Public variables

export var key : String
export var override_texture : Texture


# Private variables

onready var __animation : AnimationPlayer = $animation
onready var __name : Label = $name
onready var __sprite : Sprite = $sprite


# Lifecyle methods

func _ready() -> void:
	__name.text = key

	if override_texture:
		__sprite.texture = override_texture


# Public methods

func press() -> void:
	__animation.play("press")
