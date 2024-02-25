extends Control
class_name ArrayViz

var num_processors: int
var num_elements_per_processor: int
var array_script: ArrayAlgorithm

const array_processor: PackedScene = preload("./ArrayProcessor/ArrayProcessor.tscn")

@onready var processors = $AspectRatioContainer/Nodes
var max_value: int

func _ready():
	if num_processors < processors.columns:
		processors.columns = num_processors

	max_value = num_processors * num_elements_per_processor

	var global_elements: Array[int] = []
	for i in max_value:
		global_elements.append(randi_range(0, max_value))
	#global_elements.assign(range(0, max_value))
	global_elements.shuffle()

	for i in num_processors:
		var child = array_processor.instantiate()

		child.rank = i
		child.viz = self
		processors.add_child(child)

		await child.initialize(global_elements.slice(num_elements_per_processor * i, num_elements_per_processor * (i + 1)))

	array_script.viz = self
	await array_script.main_logic()

func in_parallel(fn: Callable):
	var waits = []
	for child in processors.get_children():
		waits.append(func(): await child.run_func(fn))
	await Delays.await_all(waits)

# Collective comms

func shuffle_buffers(rank_map: Dictionary):
	var rank_values = {}

	var waits = []
	for src in num_processors:
		var source: ArrayProcessor = processors.get_child(src)
		waits.append(func(): rank_values[src] = await source.read_comm_buf())

	await Delays.await_all(waits)

	waits = []
	for src in num_processors:
		waits.append(
			func():
				var target: ArrayProcessor = processors.get_child(rank_map[src])
				await target.write_comm_buf(rank_values[src])
				await Delays.communication()
		)

	await Delays.await_all(waits)

func broadcast(from_rank: int, to_ranks = []):
	var values = await processors.get_child(from_rank).read_comm_buf()
	
	if to_ranks.is_empty():
		to_ranks = []
		to_ranks.assign(range(0, processors.get_child_count()))

	var waits = []
	for target_rank in to_ranks:
		var target = processors.get_child(target_rank)
		waits.append(
			func():
				await target.write_comm_buf(values)
				await Delays.communication()
		)

	await Delays.await_all(waits)

func scatter(from_rank: int):
	var values = await processors.get_child(from_rank).read_comm_buf()
	var count_per_process = values.size() / num_processors

	var waits = []
	for target in num_processors:
		waits.append(
			func():
				var slice = values.slice(target * count_per_process, (target + 1) * count_per_process)

				await processors.get_child(target).write_comm_buf(slice)
				await Delays.communication()
		)

	await Delays.await_all(waits)

func gather(to_rank: int):
	var values = []
	values.resize(num_processors)

	var waits = []
	for src in num_processors:
		waits.append(
			func():
				values[src] = await processors.get_child(src).read_comm_buf()
				await Delays.communication()
		)
	await Delays.await_all(waits)

	var final_arr: Array[int] = []
	for arr in values:
		final_arr.append_array(arr)

	await processors.get_child(to_rank).write_comm_buf(final_arr)

func _on_back_button_pressed():
	queue_free()
	get_tree().change_scene_to_file("res://Main.tscn")
