extends Control
class_name ArraySlice

@export
var read_color: Color = Color.RED
@export
var write_color: Color = Color.GREEN
@export
var clear_color: Color = Color.WHITE

var sound_base_pitch: float

@onready var elements = $Elements

const Element = preload("./Element.tscn")

func regen_elements(values: Array[int], global_max_value: int):
	for child in elements.get_children():
		child.queue_free()

	await get_tree().process_frame

	for val in values:
		var child: ProgressBar = Element.instantiate()

		child.max_value = global_max_value
		child.value = val

		elements.add_child(child)

func size() -> int:
	return elements.get_child_count()

func read(index: int) -> int:
	var child: ProgressBar = elements.get_child(index)
	child.modulate = read_color

	await Delays.local_array_access()

	var tween = create_tween()
	tween.tween_property(child, "modulate", clear_color, Delays.LOCAL_ACCESS_DELAY)
	play_tone(index)

	return child.value

func write(index: int, value: int):
	var child: ProgressBar = elements.get_child(index)

	child.modulate = write_color

	var tween: Tween = child.create_tween()
	tween.tween_property(child, "value", value, Delays.LOCAL_ACCESS_DELAY)
	tween.tween_property(child, "modulate", clear_color, Delays.LOCAL_ACCESS_DELAY)
	play_tone(index)

	await Delays.local_array_access()

func play_tone(index: int):
	$AudioStreamPlayer.pitch_scale = remap(index, 0, elements.get_child_count(), 0.5 + sound_base_pitch, 1.5 + sound_base_pitch)
	$AudioStreamPlayer.play()
