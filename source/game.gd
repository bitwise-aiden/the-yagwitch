extends Node2D


# Signals

signal message_sent(message)
signal continue_sent()


# Private constants

const __MESSAGE : Resource = preload("res://source/message.tscn")


# Private variables

var __keys : Dictionary = {}

@onready var __messages : Messages = $screen/scroll/messages
@onready var __text : RichTextLabel = $screen/text
@onready var __scroll : ScrollContainer = $screen/scroll

var __current_text : String = ""
var __cursor_elapsed : float = 0.0

var __input : bool = false
var __limit : int = 25

var __player_name : String = ""


# Lifecycle methods

func _ready() -> void:
	__messages.message_sent.connect(
		func(message: Message) -> void:
			await get_tree().process_frame
			__scroll.ensure_control_visible(message)
	)

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
			var raw_message : String = __current_text.strip_edges()
			__current_text = ""

			__messages.send(raw_message) \
				.justify_right()


# Private methods


func __game() -> void:
	var m : Messages = __messages

	m.clear()

	await continue_sent

	m.send("What is your name?")
	__input = true

	var pm : Message = await m.message_sent
	__player_name = pm.content
	__input = false

	var d : Array[Message] = [
		await m.send("Haha!").timeout(0.5),
		await m.send("%s is it?" % __player_name).timeout(0.5),
		await m.send("... I don't think so!").timeout(1.0),
		await m.send("From now on, you're Fred").timeout(0.5),
	]

	__player_name = "Fred"
	m.replace_message(pm, pm.content, __player_name)

	await __timeout(0.5)
	m.delete_multiple(d)
	await __timeout(0.5)

	await m.send("Hello %s" % __player_name).timeout(0.5)
	await m.send("I am...").timeout(0.5)
	m.send(" ")
	await m.send("The YagWitch!") \
		.color(Color("#b874f1")) \
		.shake(5.0, 5.0) \
		.timeout(1.0)
	m.send(" ")
	m.send("I have taken over your computer!")

	await continue_sent
	m.clear()
	await __timeout(1.0)

	await m.send("To get it back, you must").timeout(0.5)
	await m.send("defeat my gauntlet!").timeout(0.5)
	m.send(" ")
	await m.send("all you have to do is").timeout(0.5)
	await m.send("repeat after me...").timeout(1.0)

	m.send(" ")
	await m.send("Let's begin!").timeout(1.0)

	m.send("well good thing is works") \
		.color(Color("#b874f1")) \
		.wave(10.0, 5.0)
	__input = true

	while (await m.message_sent).content != "well good thing is works":
		await m.send(" ").timeout(0.5)
		m.send("Wrong! Let's try again...") \
			.color(Color("#ff5050"), "Wrong!") \
			.shake(10.0, 10.0, "Wrong!")

	await m.send(" ").timeout(0.5)
	await m.send("About time!").timeout(1.5)

	m.clear()

func __timeout(duration : float) -> void:
	await get_tree().create_timer(duration).timeout
