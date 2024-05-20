#@tool
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
func _process(_delta):
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


var cached_body
func _on_body_entered(_body):
	print("[%s][_on_body_entered] body.name == " % name, _body.name)
	if _body.person_state == _body.PersonState.Medium:
		_body.z_index = 20
		return

	cached_body = _body
	_body.do_change_move_state(false)
	doctor_state = DoctorState.Acting

func _on_body_exited(_body):
	print("[%s][_on_body_exited] body.name == " % name, _body.name)
	_body.z_index = 0

func _on_body_becoming_thin():
	cached_body.do_becoming_thin()
	cached_body.z_index = 20

func _on_animation_player_animation_finished(_anim_name):
	print("[%s][_on_animation_player_animation_finished] _anim_name == " % name, _anim_name)
	doctor_state = DoctorState.Standing
	cached_body.do_change_move_state(true)
