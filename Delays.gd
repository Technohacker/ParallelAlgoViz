extends Node

const DELAY_SCALE: float = 0.05

const LOCAL_ACCESS_DELAY: float = DELAY_SCALE
const COMMUNICATION_DELAY: float = 10 * DELAY_SCALE

func local_array_access():
	await get_tree().create_timer(LOCAL_ACCESS_DELAY).timeout

func communication():
	await get_tree().create_timer(COMMUNICATION_DELAY).timeout

# Utility to simultaneous await

func await_all(list: Array):
	var counter = {
		value = list.size()
	}

	for el in list:
		if el is Signal:
			el.connect(count_down.bind(counter), CONNECT_ONE_SHOT)
		elif el is Callable:
			func_wrapper(el, count_down.bind(counter))
	
	while counter.value > 0:
		await get_tree().process_frame

func count_down(dict):
	dict.value -= 1

func func_wrapper(call: Callable, call_back: Callable):
	await call.call()
	call_back.call()
