extends Area2D

var dialog

@export var cross_door: Node2D
@export var hud: CanvasLayer

# Called when the node enters the scene tree for the first time.
func _ready():
	self.body_entered.connect(self.on_body_entered)
	self.body_exited.connect(self.on_body_exited)


var cached_player
func on_body_entered(_body):
	if _body.person_type == _body.PersonType.Player:
		cached_player = _body
#		dialog.popup_centered()
	else:
		_body.destroy()


func on_body_exited(_body):
	if _body.person_type == _body.PersonType.Player:
		cached_player = null


var b_locked: bool = false
func _process(delta: float) -> void:
	if (cached_player != null and cached_player.player_can_move and Input.is_action_just_pressed("player_fire")):
		b_locked = true
		cached_player.do_change_move_state(false)
		cross_door.global_position.x = cached_player.camera.global_position.x
		var cross_door_anim_player: AnimationPlayer = cross_door.get_node("AnimationPlayer")
		cross_door_anim_player.play("s1_2_cross_door")
		cross_door.visible = true
		cross_door_anim_player.animation_finished.connect(self.animation_finished)

	if (b_locked):
		cached_player.do_change_move_state(false)


func animation_finished(anim_name: String):
	hud.change_scene_to_file("res://Runtime/Scene/Stage_2_1.tscn")
