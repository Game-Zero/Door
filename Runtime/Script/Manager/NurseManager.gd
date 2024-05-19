@tool
extends Node2D

enum NurseType {
	Type1 = 1,
	Type2 = 2,
}

enum NurseState {
	Standing,
	Acting,
}

@export var nurse_type: NurseType = NurseType.Type1
@export var nurse_state: NurseState = NurseState.Standing
@onready var animation_player = $AnimationPlayer

func play_animation():
	var anim_name = ""
	match(nurse_type):
		NurseType.Type1:
			anim_name = "nurse1_animation"
		NurseType.Type2:
			anim_name = "nurse2_arm_anime"
	
	if (nurse_state == NurseState.Standing):
		animation_player.play(anim_name)
		animation_player.stop()
	else:
		animation_player.play(anim_name)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	play_animation()
	pass

var body_cache
func _on_body_entered(_body):
	print("[%s][_on_body_entered] body.name == " % name, _body.name)
	body_cache = _body
	if nurse_type == NurseType.Type1 and not _body.b_has_diagnosed:
		_body.do_change_move_state(false)
		_body.do_diagnose()
		nurse_state = NurseState.Acting
	
	if nurse_type == NurseType.Type2 and not _body.b_has_mark:
		_body.do_change_move_state(false)
		_body.do_lifting_cloth()
		nurse_state = NurseState.Acting

func _on_body_exited(_body):
	print("[%s][_on_body_exited] body.name == " % name, _body.name)

func _on_animation_player_animation_finished(_anim_name):
	print("[%s][_on_animation_player_animation_finished] _anim_name == " % name, _anim_name)
	nurse_state = NurseState.Standing

	if nurse_type == NurseType.Type2:
		body_cache.do_mark()

	body_cache.do_change_move_state(true)
