@tool
extends Node2D

@onready var liquid = $liquid
@onready var animation_player = $AnimationPlayer
@onready var h = liquid.texture.get_size().y
@onready var delta_h = h * 0.1

enum DoctorState {
	Standing,
	Acting,
}

@export var doctor_state: DoctorState = DoctorState.Standing

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	match(doctor_state):
		DoctorState.Standing:
			animation_player.play("doctor_lipo")
			animation_player.stop()
		DoctorState.Acting:
			animation_player.play("doctor_lipo")
	pass

func _on_liquid_up():
	liquid.scale += Vector2(0, delta_h / h)
	liquid.position -= Vector2(0, delta_h / 2)
