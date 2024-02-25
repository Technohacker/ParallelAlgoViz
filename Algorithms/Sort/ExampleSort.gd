extends ArrayAlgorithm

func main_logic():
	await viz.in_parallel(func(processor: ArrayProcessor):
		var values: Array[int] = []
		for i in viz.num_elements_per_processor:
			var value = await processor.slice.read(randi_range(0, viz.num_elements_per_processor - 1))
			values.append(value)

		await processor.write_comm_buf(values)
	)

	await viz.broadcast(0)

	await self.viz.in_parallel(func(processor: ArrayProcessor):
		for i in range(processor.comm_buf.size()):
			await processor.comm_buf.read(i)

		for i in range(processor.slice.size()):
			await processor.slice.write(i, (viz.num_elements_per_processor * processor.rank + i))
	)
