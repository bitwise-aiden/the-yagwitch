extends Node2D


# Signals

signal message_sent(message)
signal continue_sent()


# Private constants

const __MESSAGE : Resource = preload("res://source/message.tscn")


# Private variables

var __keys : Dictionary = {}

onready var __messages : VBoxContainer = $screen/scroll/messages
onready var __text : RichTextLabel = $screen/text
onready var __scroll : ScrollContainer = $screen/scroll

var __current_text : String = ""
var __cursor_elapsed : float = 0.0

var __input : bool = false
var __limit : int = 25

var __player_name : String = ""


# Lifecycle methods

func _ready() -> void:
	for key in $keys.get_children():
		__keys[key.key.to_lower()] = key

	__game()


func _process(delta: float) -> void:
	__cursor_elapsed += delta * 5.0

	var text_template : String = "%s[img=10x15]res://assets/cursor.png[/img]"

	if sin(__cursor_elapsed) < 0.0:
		text_template = "%s"

	__text.bbcode_text = text_template % __current_text


func _input(event: InputEvent) -> void:
	if event is InputEventKey && event.pressed:
		var key : String = event.as_text().to_lower()

		if !__input:
			emit_signal("continue_sent")
			return

		if key.find("+") != -1:
			key = key.rsplit("+", true, 1)[1]

		if key == "space":
			key = " "

		if key in __keys && __current_text.length() < __limit:
			__keys[key].press()

			__current_text += key

		if key == "backspace":
			__current_text = __current_text.left(__current_text.length() - 1)

		if key == "enter" && !__current_text.empty():
			var raw_message : String = __current_text
			__current_text = ""

			__send_message(raw_message, false)

			emit_signal("message_sent", raw_message.to_lower())


# Private methods


func __send_message(message : String, left : bool = true) -> Message:
	var instance : Message = __MESSAGE.instance()

	var template = "%s" if left else "[right]%s[/right]"
	instance.bbcode_text = template % message.to_lower()

	__messages.add_child(instance)

	__show_message(instance)

	return instance


func __show_message(message : Message) -> void:
	yield(get_tree(), "idle_frame")
	__scroll.ensure_control_visible(message)


func __replace_all(from : String, to: String) -> void:
	for message in __messages.get_children():
		__replace_message(message, from, to)


func __delete_all() -> void:
	for message in __messages.get_children():
		__delete_message(message)

	__send_message("")
	__send_message("")


func __delete_messages(messages : Array) -> void:
	for message in messages:
		__delete_message(message)


func __delete_message(message : Message) -> void:
	message.bbcode_text = "[color=#fba333]%s[/color]" % message.bbcode_text
	yield(get_tree().create_timer(0.1), "timeout")
	message.queue_free()


func __replace_message(message : Message, from : String, to: String) -> void:
	if message.bbcode_text.find(from) == -1:
		return

	var from_t : String = "[color=#fba333]%s[/color]" % from
	message.bbcode_text = message.bbcode_text.replace(from, from_t)
	yield(get_tree().create_timer(0.1), "timeout")

	var to_t : String = "[color=#fba333]%s[/color]" % to
	message.bbcode_text = message.bbcode_text.replace(from_t, to_t)
	yield(get_tree().create_timer(0.1), "timeout")

	message.bbcode_text = message.bbcode_text.replace(to_t, to)


func __game() -> void:
	__delete_all()

	yield(self, "continue_sent")

	__send_message("What is your name?")
	__input = true

	__player_name = yield(self, "message_sent")
	__input = false

	var a : Message = __send_message("Haha!")
	yield(get_tree().create_timer(0.5), "timeout")
	var b : Message = __send_message("%s is it?" % __player_name)
	yield(get_tree().create_timer(0.5), "timeout")
	var c : Message = __send_message("... I don't think so!")
	yield(get_tree().create_timer(1.0), "timeout")
	var d : Message = __send_message("From now on, you're Fred")
	yield(get_tree().create_timer(1.0), "timeout")
	__replace_all(__player_name, "Fred")
	__player_name = "Fred"

	yield(get_tree().create_timer(1.0), "timeout")
	__delete_messages([a, b, c, d])
	yield(get_tree().create_timer(0.5), "timeout")

	__send_message("Hello %s!" % __player_name)
	yield(get_tree().create_timer(0.5), "timeout")
	__send_message("I am...")
	yield(get_tree().create_timer(0.5), "timeout")
	__send_message("...")
	yield(get_tree().create_timer(1.0), "timeout")
	__send_message(" ")
	__send_message("[wave amp=15 freq=5][color=#b874f1]The YagWitch[/color][/wave]")
	__send_message(" ")
	yield(get_tree().create_timer(1.0), "timeout")
	__send_message("I have taken over your")
	__send_message("computer!")

	yield(self, "continue_sent")

	__delete_all()
	yield(get_tree().create_timer(1.0), "timeout")

	__send_message("To get your precious computer")
	yield(get_tree().create_timer(0.5), "timeout")
	__send_message("back, you must defeat my gauntlet!")
	yield(get_tree().create_timer(0.5), "timeout")

	__send_message(" ")
	__send_message("All you have to do is")
	__send_message("repeat after me...")
	yield(get_tree().create_timer(1.0), "timeout")

	__send_message("Lets begin!")
	yield(get_tree().create_timer(1.0), "timeout")

	__send_message(" ")
	__input = true
	var count : int = yield(__prompt("well good thing is works"), "completed")
	__input = false

	yield(get_tree().create_timer(1.0), "timeout")

	if count > 3:
		__send_message("Ugh! Took your time...")
	else:
		__send_message("Very good!")
	yield(get_tree().create_timer(1.0), "timeout")

	__delete_all()


func __wave(message : String, freq : int = 5, color : String = "#b874f1") -> String:
	return "[wave amp=15 freq=%d][color=%s]%s[/color][/wave]" % [
		freq,
		color,
		message,
	]

func __prompt(message : String) -> int:
	var prev : Message = __send_message(__wave(message))

	var response : String = yield(self, "message_sent")
	var count : int = 0
	while response != message:
		__send_message(" ")
		__send_message("%s Lets try again..." % __wave("Wrong!", 10, "#ff5050"))
		yield(get_tree().create_timer(1.0), "timeout")

		__send_message(" ")
		prev = __send_message(__wave(message))

		response = yield(self, "message_sent")

	return count


