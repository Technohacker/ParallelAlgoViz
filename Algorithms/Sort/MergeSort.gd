extends ArrayAlgorithm
class_name MergeSort

static func merge(
	slice_lo: ArraySlice,
	slice_lo_start: int,
	slice_lo_end: int,
	slice_hi: ArraySlice,
	slice_hi_start: int,
	slice_hi_end: int) -> Array[int]:
	var i = slice_lo_start
	var j = slice_hi_start

	var values: Array[int] = []
	while i < slice_lo_end and j < slice_hi_end:
		var el_1 = await slice_lo.read(i)
		var el_2 = await slice_hi.read(j)
		
		if el_1 < el_2:
			values.append(el_1)
			i += 1
		else:
			values.append(el_2)
			j += 1

	while i < slice_lo_end:
		var el_1 = await slice_lo.read(i)
		
		values.append(el_1)
		i += 1

	while j < slice_hi_end:
		var el_2 = await slice_hi.read(j)
		
		values.append(el_2)
		j += 1

	return values

static func merge_sort(slice: ArraySlice, low: int, high: int):
	if high - low <= 1:
		return

	var m: int = (low + high) / 2
	await merge_sort(slice, low, m)
	await merge_sort(slice, m, high)

	var values = await merge(slice, low, m, slice, m, high)
	var i = 0
	for k in range(low, high):
		await slice.write(k, values[i])
		i += 1
