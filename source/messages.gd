class_name Messages extends VBoxContainer

# Signals

signal message_sent(message : Message)


# Exports

@export_category("Colors")
@export_color_no_alpha var default_color : Color
@export_color_no_alpha var delete_color : Color
@export_color_no_alpha var replace_color : Color


# Private constants

const __MESSAGE : Resource = preload("res://source/message.tscn")

# Public variables

var messages : Array[Message] = []


# Public methods

func send(
	content : String,
) -> Message:
	var message : Message = __MESSAGE.instantiate()

	message.content = content

	messages.append(message)
	add_child(message)

	message_sent.emit(message)

	return message


func delete(
	message : Message,
) -> void:
	var justify_right : bool = message.has_format("right")

	message \
		.clear_format() \
		.color(delete_color)

	if justify_right:
		message.justify_right()

	await message.timeout(0.2)

	messages.erase(message)
	message.queue_free()


func delete_multiple(
	messages : Array[Message],
) -> void:
	for message in messages:
		delete(message)


func clear() -> void:
	delete_multiple(messages)


func replace(
	from : String,
	to : String,
) -> void:
	for message in messages:
		replace_message(message, from, to)


func replace_message(
	message : Message,
	from : String,
	to : String,
) -> void:
	if !message.contains(from):
		return

	await message \
		.color(replace_color.to_html(), from) \
		.timeout(0.2)

	message \
		.replace(to, from) \
		.clear_format("color", to)
