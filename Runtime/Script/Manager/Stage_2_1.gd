extends Node2D
var bHasSurgeryDone: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func on_doll_body_entered(body: Node2D) -> void:
	print("[Stage_2_1][on_doll_body_entered] body.name: ", body.name)
	if (self.bHasSurgeryDone):
		return
	
	self.bHasSurgeryDone = true
	body.set_can_move(false)
	body.person_state = body.PersonState.Medium
	body.person_animation_state = body.PersonAnimationState.Lie
	body.set_global_position(Vector2(1280, 570))


func on_door_body_entered(body: Node2D) -> void:
	print("[Stage_2_1][on_door_body_entered] body.name: ", body.name)
	
