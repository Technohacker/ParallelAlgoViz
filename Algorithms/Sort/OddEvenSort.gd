extends ArrayAlgorithm
class_name OddEvenSort

var MergeSort = preload("res://Algorithms/Sort/MergeSort.gd").new()

func main_logic():
	await viz.in_parallel(
		func(processor):
			await MergeSort.merge_sort(processor.slice, 0, viz.num_elements_per_processor)
			
			var values: Array[int] = []
			for i in viz.num_elements_per_processor:
				values.append(await processor.slice.read(i))
			
			await processor.write_comm_buf(values)
	)

	# Stages
	for i in viz.num_processors:
		var shuffle_map = {}

		if i % 2 == 0:
			# Even Phase
			for j in viz.num_processors:
				shuffle_map[j] = j + 1 if j % 2 == 0 else j - 1
		else:
			# Odd Phase
			for j in viz.num_processors:
				shuffle_map[j] = j - 1 if j % 2 == 0 else j + 1

		if shuffle_map[0] == -1:
			shuffle_map[0] = 0
		if shuffle_map[viz.num_processors - 1] == viz.num_processors:
			shuffle_map[viz.num_processors - 1] = viz.num_processors - 1

		await viz.shuffle_buffers(shuffle_map)
		
		await viz.in_parallel(func(processor):
			if shuffle_map[processor.rank] == processor.rank:
				return

			var merge_result = await MergeSort.merge(
				processor.slice, 0, viz.num_elements_per_processor,
				processor.comm_buf, 0, viz.num_elements_per_processor,
			)

			var merge_start = 0 if shuffle_map[processor.rank] > processor.rank else viz.num_elements_per_processor
			var new_slice: Array[int] = merge_result.slice(merge_start, merge_start + viz.num_elements_per_processor)

			#print(processor.rank, " ", merge_start)
			await processor.write_comm_buf(new_slice)
			for k in viz.num_elements_per_processor:
				await processor.slice.write(k, new_slice[k])
		)
