# res://combo/ComboAttackNode.gd
class_name RComboNode extends Resource

@export var input_action: InputAction
@export var next_attacks: Array[RComboNode] = []
@export var combo_window: float = 0.6
@export var cancelable: bool = false
@export var ability_data: RAbilityData
