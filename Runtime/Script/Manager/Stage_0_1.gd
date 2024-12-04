extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func on_body_entered(body):
	print("[Stage_0_1][on_body_entered] body.name: ", body.name)
	pass


func on_body_exited(body):
	print("[Stage_0_1][on_body_exited] body.name: ", body.name)
	pass
