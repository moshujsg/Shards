class_name InputActionProperties extends Resource

signal internal_event_fire(object: InputObject)

enum TriggerPhase {
	TRIGGERED, # Condition was met
	STARTED, # On key down no matter what
	COMPLETED, # Mostly on key up
	CANCELLED, # Condition wasn't met
	ONGOING # Event is still going but condition to trigger was not met
}

# This is an internal state that determines  
enum State {
	PRESS,
	ONGOING,
	SUCCEED,
	RELEASE,
	FAILED,
	NONE
}

# This state determines the condition to fire triggered
enum Trigger {
	DOWN,
	HOLD,
	HOLD_AND_RELEASE, # Not implemented
	PRESSED,
	PULSE, # Not implemented
	RELEASED,
	TAP
}	

enum ValueType {
	BOOL,
	AXIS,
	VECTOR2
}

enum Modifier {
	NEGATE
}

enum AxisOrder {
	XY,
	YX
}

var object : InputObject
@export var event : InputEvent
@export var trigger : Trigger = Trigger.DOWN
@export var value_type : ValueType
@export var modifiers : Array[Modifier]
@export var axis_order : AxisOrder
var met_trigger_condition := false

@export var hold_threshold_ms := 300
@export var tap_threshold_ms := 150

@export var one_shot : bool = false
var one_shot_triggered := false

var current_state : State = State.NONE
var next_state : State = State.NONE

var press_time : int

var state_trigger_map : Dictionary[Trigger, Dictionary] = {
	Trigger.DOWN: {
		State.PRESS: [TriggerPhase.STARTED, TriggerPhase.TRIGGERED],
		State.ONGOING: [],
		State.SUCCEED: [],
		State.RELEASE: [TriggerPhase.COMPLETED],
		State.FAILED: [],
		State.NONE: []
	},
	Trigger.HOLD: {
		State.PRESS: [TriggerPhase.STARTED],
		State.ONGOING: [TriggerPhase.ONGOING],
		State.SUCCEED: [TriggerPhase.TRIGGERED], 
		State.RELEASE: [TriggerPhase.COMPLETED],  
		State.FAILED: [TriggerPhase.CANCELLED],
		State.NONE: [] 
	},
	Trigger.HOLD_AND_RELEASE: {
		State.PRESS: [TriggerPhase.STARTED],
		State.ONGOING: [],
		State.SUCCEED: [],
		State.RELEASE: [TriggerPhase.COMPLETED],
		State.FAILED: [TriggerPhase.CANCELLED],
		State.NONE: []
	},
	Trigger.PRESSED: {
		State.PRESS: [TriggerPhase.STARTED],
		State.ONGOING: [TriggerPhase.TRIGGERED],
		State.SUCCEED: [TriggerPhase.TRIGGERED],
		State.RELEASE: [TriggerPhase.COMPLETED],
		State.FAILED: [TriggerPhase.CANCELLED],
		State.NONE: [] 
	},
	Trigger.PULSE: {
		State.PRESS: [TriggerPhase.STARTED],
		State.ONGOING: [],
		State.SUCCEED: [],
		State.RELEASE: [TriggerPhase.COMPLETED],
		State.FAILED: [TriggerPhase.CANCELLED],
		State.NONE: []
	},
	Trigger.RELEASED: {
		State.PRESS: [TriggerPhase.STARTED],
		State.ONGOING: [],
		State.SUCCEED: [],
		State.RELEASE: [TriggerPhase.TRIGGERED, TriggerPhase.COMPLETED],
		State.FAILED: [TriggerPhase.CANCELLED],
		State.NONE: []
	},
	Trigger.TAP: {
		State.PRESS: [TriggerPhase.STARTED],
		State.ONGOING: [],
		State.SUCCEED: [],
		State.RELEASE: [TriggerPhase.TRIGGERED, TriggerPhase.COMPLETED],
		State.FAILED: [TriggerPhase.CANCELLED],
		State.NONE: []
	}
}

var met_trigger_condition_initial_state : Dictionary[Trigger, bool] = {
	Trigger.DOWN: true,
	Trigger.HOLD: false,
	Trigger.HOLD_AND_RELEASE: false,
	Trigger.PRESSED: true,
	Trigger.PULSE: false,
	Trigger.RELEASED: true,
	Trigger.TAP: true
}

func _setup() -> void:
	object = InputObject.new()
	object.axis_order = axis_order
	object.modifiers = modifiers

			
# Gets called every frame from playercontroller if it's active
# Can be made for each input action to keep track of itself instead.
func update() -> void:
	var delta_time := Time.get_ticks_msec() - press_time
	if trigger == Trigger.HOLD and delta_time > hold_threshold_ms:
		met_trigger_condition = true
	if trigger == Trigger.TAP and delta_time > tap_threshold_ms:
		met_trigger_condition = false

	current_state = next_state
	

	if current_state == State.PRESS:
		next_state = State.ONGOING
		press_time = Time.get_ticks_msec()
		met_trigger_condition = met_trigger_condition_initial_state[trigger]
	
	var phases_to_fire : Array[TriggerPhase]
	var state_to_check : State = current_state

	if current_state == State.ONGOING and met_trigger_condition:
		state_to_check = State.SUCCEED

	elif current_state == State.RELEASE and not met_trigger_condition:
		state_to_check = State.FAILED

	phases_to_fire.assign(state_trigger_map[trigger][state_to_check] as Array[TriggerPhase])
	if state_to_check == State.SUCCEED:
		if one_shot:
			if one_shot_triggered:
				phases_to_fire = []
			else:
				one_shot_triggered = true
		
	if not phases_to_fire.is_empty():
		for phase in phases_to_fire:
			object._set_value(get_value(phase), phase)
			internal_event_fire.emit(object)

	if current_state == State.RELEASE:
		reset()

func get_value(phase : TriggerPhase) -> float:
	if event is InputEventKey:
		if phase in [TriggerPhase.STARTED, TriggerPhase.TRIGGERED, TriggerPhase.ONGOING]:
			return 1
		return 0
	return 1

func is_being_processed() -> bool:
	if current_state != State.NONE:
		return true
	return false

func reset() -> void:
	current_state = State.NONE
	next_state = State.NONE
	one_shot_triggered = false

#func load_action() -> void:
	#if InputMap.has_action(name):
		#
