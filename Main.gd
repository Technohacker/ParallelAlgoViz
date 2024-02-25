extends Control

const array_viz_scene: PackedScene = preload("res://ArrayViz/ArrayViz.tscn")

func load_array_script(path: String):
	var script: ArrayAlgorithm = load(path).new()

	var arr_viz: ArrayViz = array_viz_scene.instantiate()
	arr_viz.num_processors = int($VBoxContainer/NumProcessors.text)
	arr_viz.num_elements_per_processor = int($VBoxContainer/ElementsPerProcessor.text)
	arr_viz.array_script = script

	queue_free()
	get_tree().root.add_child(arr_viz)

func load_array_script_serial(path: String):
	var script: ArrayAlgorithm = load(path).new()

	var arr_viz: ArrayViz = array_viz_scene.instantiate()
	arr_viz.num_processors = 1
	arr_viz.num_elements_per_processor = int($VBoxContainer/ElementsPerProcessor.text) * int($VBoxContainer/NumProcessors.text)
	arr_viz.array_script = script

	queue_free()
	get_tree().root.add_child(arr_viz)
