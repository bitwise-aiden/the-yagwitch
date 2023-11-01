extends Node2D


# Signals

signal message_sent(message)
signal continue_sent()


# Private constants

const __MESSAGE : Resource = preload("res://source/message.tscn")


# Private variables

var __keys : Dictionary = {}

@onready var __messages : VBoxContainer = $screen/scroll/messages
@onready var __text : RichTextLabel = $screen/text
@onready var __scroll : ScrollContainer = $screen/scroll

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

	__text.text = text_template % __current_text


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

		if key == "enter" && !__current_text.is_empty():
			var raw_message : String = __current_text
			__current_text = ""

			__send_message(raw_message, false)


# Private methods


func __send_message(message : String, left : bool = true) -> Message:
	var instance : Message = __MESSAGE.instantiate()

	var template = "%s" if left else "[right]%s[/right]"
	instance.text = template % message.to_lower()

	__messages.add_child(instance)

	__show_message(instance)

	emit_signal("message_sent", instance)

	return instance


func __show_message(message : Message) -> void:
	await get_tree().process_frame
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
	__strip_formatting(message)

	message.text = "[color=#fba333]%s[/color]" % message.text
	await get_tree().create_timer(0.1).timeout
	message.queue_free()


func __replace_message(message : Message, from : String, to: String) -> void:
	if message.text.find(from) == -1:
		return

	print(message.text)

	var from_t : String = "[color=#fba333]%s[/color]" % from
	message.text = message.text.replace(from, from_t)
	await get_tree().create_timer(0.1).timeout
	print(message.text)

	var to_t : String = "[color=#fba333]%s[/color]" % to
	message.text = message.text.replace(from_t, to_t)
	await get_tree().create_timer(0.1).timeout
	print(message.text)

	message.text = message.text.replace(to_t, to)


func __strip_formatting(message : Message, include_just : bool = false) -> void:
	message.text = __without_formatting(message.text, include_just)


func __without_formatting(message : String, include_just : bool = false) -> String:
	var format : String = "\\[((?!(right|/right)).*?)\\]"
	if include_just:
		format = "\\[.*?\\]"

	var re : RegEx = RegEx.new()
	re.compile(format)

	message = re.sub(message, "", true)

	return message



func __game() -> void:
	__delete_all()

	await continue_sent

	__send_message("What is your name?")
	__input = true

	var pm: Message = await message_sent
	__player_name = __without_formatting(pm.text, true)
	__input = false

	var a : Message = __send_message("Haha!")
	await get_tree().create_timer(0.5).timeout
	var b : Message = __send_message("%s is it?" % __player_name)
	await get_tree().create_timer(0.5).timeout
	var c : Message = __send_message("... I don't think so!")
	await get_tree().create_timer(1.0).timeout
	var d : Message = __send_message("From now on, you're Fred")
	await get_tree().create_timer(1.0).timeout
	__replace_message(pm, __player_name, "Fred")
	__player_name = "Fred"

	await get_tree().create_timer(1.0).timeout
	__delete_messages([a, b, c, d])
	await get_tree().create_timer(0.5).timeout

	__send_message("Hello %s!" % __player_name)
	await get_tree().create_timer(0.5).timeout
	__send_message("I am...")
	await get_tree().create_timer(0.5).timeout
	__send_message("...")
	await get_tree().create_timer(1.0).timeout
	__send_message(" ")
	__send_message("[wave amp=15 freq=5][color=#b874f1]The YagWitch[/color][/wave]")
	__send_message(" ")
	await get_tree().create_timer(1.0).timeout
	__send_message("I have taken over your")
	__send_message("computer!")

	await self.continue_sent

	__delete_all()
	await get_tree().create_timer(1.0).timeout

	__send_message("To get your precious computer")
	await get_tree().create_timer(0.5).timeout
	__send_message("back, you must defeat my gauntlet!")
	await get_tree().create_timer(0.5).timeout

	__send_message(" ")
	__send_message("All you have to do is")
	__send_message("repeat after me...")
	await get_tree().create_timer(1.0).timeout

	__send_message("Lets begin!")
	await get_tree().create_timer(1.0).timeout

	__send_message(" ")
	__input = true
	var count : int = await __prompt("well good thing is works")
	__input = false

	await get_tree().create_timer(1.0).timeout

	if count > 3:
		__send_message("Ugh! Took your time...")
	else:
		__send_message("Very good!")
	await get_tree().create_timer(1.0).timeout

	__delete_all()


func __wave(message : String, freq : int = 5, color : String = "#b874f1") -> String:
	return "[wave amp=15 freq=%d][color=%s]%s[/color][/wave]" % [
		freq,
		color,
		message,
	]

func __prompt(message : String) -> int:
	var prev : Message = __send_message(__wave(message))

	var response : String = __without_formatting(
		(await message_sent).text,
		true
	)
	var count : int = 0
	while response != message:
		__send_message(" ")
		__send_message("%s Lets try again..." % __wave("Wrong!", 10, "#ff5050"))
		await get_tree().create_timer(1.0).timeout

		__send_message(" ")
		prev = __send_message(__wave(message))

		response = __without_formatting(
			(await message_sent).text,
			true
		)

	return count


