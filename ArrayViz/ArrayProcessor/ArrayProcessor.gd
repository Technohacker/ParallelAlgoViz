extends Control
class_name ArrayProcessor

# Parts used by the sorting algo
@onready var slice: ArraySlice = $VBoxContainer/ArraySlice
@onready var comm_buf: ArraySlice = $VBoxContainer/CommBuffer

var rank: int

func read_comm_buf() -> Array[int]:
	var values: Array[int] = []

	var waits = []
	for i in range(comm_buf.size()):
		waits.append(
			func():
				values.append(await comm_buf.read(i))
		)
	
	await Delays.await_all(waits)
	return values

func write_comm_buf(values: Array[int]):
	await comm_buf.regen_elements(values, viz.max_value)

	var waits = []
	for i in values.size():
		waits.append(
			func():
				await comm_buf.write(i, values[i])
		)
	
	await Delays.await_all(waits)

# Parts used by the visualiser itself
var viz: ArrayViz

func initialize(elements: Array[int]):
	slice.sound_base_pitch = float(rank) / viz.num_processors
	comm_buf.sound_base_pitch = float(rank) / viz.num_processors

	await slice.regen_elements(elements, viz.max_value)
	await comm_buf.regen_elements([], viz.max_value)

func run_func(fn: Callable):
	await fn.call(self)
