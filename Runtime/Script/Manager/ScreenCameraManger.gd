extends Camera2D

# Camera script follwing a target (usually the player)
# This camera is snapped to a grid, therefore only moves when the character exits a screen.

@export var target : NodePath
#@export var align_time : float = 0.6
@export var screen_size := Vector2(1920, 1080)

@onready var Target = get_node_or_null(target)

func _physics_process(_delta: float) -> void:
	if not is_instance_valid(Target):
		var targets: Array = get_tree().get_nodes_in_group("player")
		if targets: Target = targets[0]
	if not is_instance_valid(Target):
		return
	
	var half_screen_height = screen_size.y / 2

	if half_screen_height <= Target.global_position.y and Target.global_position.y <= half_screen_height * 3:
		global_position.y = Target.global_position.y	
	
	# Actual movement
	#var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
	#tween.tween_property(self, "global_position", desired_position(), align_time)

# Calculating the gridnapped position
#func desired_position() -> Vector2:
	#var ret = (Target.global_position / screen_size).floor() * screen_size + screen_size/2
	#return ret
