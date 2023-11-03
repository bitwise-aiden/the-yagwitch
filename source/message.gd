class_name Message extends RichTextLabel


# Public variables

var content : String :
	set(new):
		content = new
		__update_text()


# Private constants

const __ALL : String = ""


# Private variables

var __formatting : Dictionary = {}


# Public variables

func bgcolor(
	value : Color,
	substring : String = __ALL,
) -> Message:
	format("bgcolor", value, substring)

	return self


func color(
	value : Color,
	substring : String = __ALL,
) -> Message:
	format("color", value, substring)

	return self


func contains(
	substring : String,
) -> bool:
	return content.contains(substring)


func clear_format(
	key : String = "",
	substring : String = __ALL
) -> Message:
	if !__formatting.has(substring):
		return self

	if key.is_empty():
		__formatting[substring].clear()
	else:
		__formatting[substring].erase(key)

	return self


func fgcolor(
	value : Color,
	substring : String = __ALL
) -> Message:
	format("fgcolor", value, substring)

	return self


func format(
	key : String,
	options : Variant = null,
	substring : String = __ALL,
) -> Message:
	__formatting[substring] = __formatting.get(substring, {})
	__formatting[substring][key] = options

	__update_text()

	return self


func has_format(
	key : String,
	substring : String = __ALL,
) -> bool:
	return __formatting.has(substring) && __formatting[substring].has(key)


func justify_right() -> Message:
	format("right")

	return self


func replace(
	new : String,
	substring : String = __ALL,
) -> Message:
	if substring == __ALL:
		content = new
		return self

	if !content.contains(substring):
		return self

	for key in __formatting:
		if !key.contains(substring):
			continue

		var old_key : String = key
		key.replace(substring, new)

		__formatting[key] = __formatting[old_key]
		__formatting.erase(old_key)

	content = content.replace(substring, new)

	return self


func shake(
	rate : float,
	level : float,
	substring : String = __ALL
) -> Message:
	format(
		"shake",
		{
			"rate": rate,
			"level": level,
		},
		substring
	)

	return self


func timeout(
	duration : float
) -> Message:
	await get_tree().create_timer(duration).timeout

	return self


func wave(
	amplitude : float,
	frequency : float,
	substring : String = "",
) -> Message:
	format(
		"wave",
		{
			"amp": amplitude,
			"freq": frequency
		},
		substring
	)

	return self


# Private methods

func __update_text() -> void:
	text = content

	for substring in __formatting:
		var formats : Dictionary = __formatting[substring]

		if substring == __ALL:
			substring = text

		if text.find(substring) == -1:
			assert(
				"Could not apply substring transformation for `%s` of `%s`" % [
					substring,
					text,
				]
			)


		for key in formats:
			if key == "right":
				continue

			var options : Variant = formats[key]

			var replacement : String = ""

			match typeof(options):
				TYPE_DICTIONARY:
					var options_formatted : Array[String] = [key]
					for option in options:
						var value : Variant = options[option]
						options_formatted.append("%s=%s" % [option, value])

					replacement = "[%s]%s[/%s]" % [
						" ".join(options_formatted),
						substring,
						key
					]
				TYPE_COLOR:
					replacement = "[%s=%s]%s[/%s]" % [
						key,
						options.to_html(),
						substring,
						key
					]
				TYPE_NIL:
					replacement = "[%s]%s[/%s]" % [
						key,
						substring,
						key,
					]
				_:
					replacement = "[%s=%s]%s[/%s]" % [
						key,
						str(options),
						substring,
						key
					]


			text = text.replace(substring, replacement)

	if "right" in __formatting.get("", {}):
		text = "[right]%s[/right]" % text
