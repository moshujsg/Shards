class_name Utils extends Node

static func bitmask_to_int(bitmask: PackedByteArray) -> int:
	var result : int = 0
	for i in range(bitmask.size()):
		result |= bitmask[i] << (8 * i)  # Shift each byte into position
	return result
