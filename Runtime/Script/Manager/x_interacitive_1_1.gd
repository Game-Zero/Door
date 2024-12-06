extends "res://Runtime/Script/Manager/x_interacitive.gd"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()


func on_body_entered(body: Node2D):
	print("[x_interactive_1_1][on_body_entered] body.name: ", body)
	if (body.name == "player"):
		super.on_body_entered(body)


func on_body_exited(body: Node2D):
	print("[x_interactive_1_1][on_body_entered] body.name: ", body)
	if (body.name == "player"):
		super.on_body_entered(body)
