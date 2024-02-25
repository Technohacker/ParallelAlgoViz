extends ArrayAlgorithm

func main_logic():
	var search = randi_range(0, viz.max_value)
	var radius: int = randf_range(0, 0.25) * viz.max_value

	await viz.in_parallel(func(processor: ArrayProcessor):
		for i in viz.num_elements_per_processor:
			var value = await processor.slice.read(i)
			if value < (search - radius) or value > (search + radius):
				await processor.slice.write(i, 0)
	)

	#await viz.gather(0)
	#await viz.in_parallel(func(processor: ArrayProcessor):
		#if processor.rank != 0:
			#await processor.write_comm_buf([])
	#)
