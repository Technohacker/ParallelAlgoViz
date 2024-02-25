extends ArrayAlgorithm
class_name QuickSort

static func swap(slice: ArraySlice, i: int, j: int):
	var lo = await slice.read(i)
	var hi = await slice.read(j)
	await slice.write(i, hi)
	await slice.write(j, lo)

static func partition(slice: ArraySlice, low: int, high: int, piv: int) -> int:
	var i = low
	var j = high
	while i < j:
		while i <= high - 1:
			var lo_el = await slice.read(i)
			if lo_el > piv:
				break
			i += 1

		while j >= low + 1:
			var hi_el = await slice.read(j)
			if hi_el <= piv:
				break
			j -= 1

		if i < j:
			await swap(slice, i, j)

	return j

static func quick_sort(slice: ArraySlice, low: int, high: int):
	if low >= high:
		return

	var piv = await slice.read(low)
	var part_pos: int = await partition(slice, low, high, piv)

	await swap(slice, low, part_pos)

	await quick_sort(slice, low, part_pos - 1)
	await quick_sort(slice, part_pos + 1, high)

func main_logic():
	var num_stages = int(log(viz.num_processors)/log(2))

	#for i in range(num_stages, 0, -1):
		#var group_rank_mask = (1 << i) - 1
		#var group_mask = ~group_rank_mask
#
		#var group = func(rank):
			#return (rank & group_mask) >> i
		#var group_rank = func(rank):
			#return rank & group_rank_mask
#
		#await viz.in_parallel(func(p: ArrayProcessor):
			#if group_rank.call(p.rank) == 0:
				#await p.write_comm_buf([await p.slice.read(0)])
		#)
		#
		#var groups = {}
		#var half_shuffle = {}
		#for j in viz.num_processors:
			#var g = group.call(j)
			#if !groups.has(g):
				#groups[g] = []
#
			#groups[g].append(j)
			#
			#half_shuffle[j] = j ^ (num_stages - i)
#
		#for j in groups:
			#await viz.broadcast(j << i, groups[j])
#
		#await viz.in_parallel(
			#func(processor):
				#var pivot = await processor.comm_buf.read(0)
				#await partition(processor.slice, 0, viz.num_elements_per_processor - 1, pivot)
				#
				#var start
				#var end
				#
				#if half_shuffle[processor.rank] < processor.rank:
					#start = 0
					#end = pivot
				#else:
					#start = pivot
					#end = viz.num_elements_per_processor
				#
				#var values: Array[int] = []
				#for j in range(start, end):
					#values.append(await processor.slice.read(j))
				#
				#await processor.write_comm_buf(values)
		#)

	await viz.in_parallel(
		func(processor):
			await quick_sort(processor.slice, 0, viz.num_elements_per_processor - 1)
	)
