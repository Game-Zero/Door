@tool
extends CharacterBody2D

const SPEED = 300.0
const EPS = 6

static var player_can_move = true

var camera

enum PersonState {
	Thin,
	VeryThin,
}

enum PersonAnimationState {
	Standing,
	Walking,
	ButtonPressing,
	MedicineGetting,
}

@onready var animation_player = $AnimationPlayer
@export var person_animation_state: PersonAnimationState
@export var person_state: PersonState
@export var b_has_pressed_button = false
@export var b_has_eaten_medication = false

var b_force_move = false
var force_move_to_x = 0
var force_move_finish_callback

var last_played_animation = ""
var dialog

func play_animation():
	var animation_name = "protagonist_"

	match (person_state):
		PersonState.Thin:
			animation_name += "thin_"
		PersonState.VeryThin:
			animation_name += "thinner_"
	
	match (person_animation_state):
		PersonAnimationState.Standing:
			animation_name += "standing"
			pass
			
		PersonAnimationState.Walking:
			animation_name += "walking"
			pass
			
		PersonAnimationState.ButtonPressing:
			animation_name += "button_to press"
			pass
			
		PersonAnimationState.MedicineGetting:
			animation_name += "medicine_to get"
			pass

	if animation_player != null and animation_player.has_animation(animation_name):
		animation_player.play(animation_name)

	if (last_played_animation != animation_name):
		print("[Person(%s)][play_animation] animation_name: " % name + animation_name)
		last_played_animation = animation_name
	return animation_name

func _ready():
	if Engine.is_editor_hint():
		return

	camera = get_node_or_null("../camera")
	dialog = AcceptDialog.new()
	add_child(dialog)
	dialog.size.x = 300
	dialog.dialog_text = "GameOver."
	dialog.title = "提示"
	dialog.get_ok_button().pressed.connect(func():get_tree().reload_current_scene())


func _physics_process(_delta):
	play_animation()
	if Engine.is_editor_hint():
		return

	if self.b_force_move:
		var dx = self.force_move_to_x - global_position.x
		#print("self.force_move_to_x == ", self.force_move_to_x, ", global_position.x == ", global_position.x, ", dx == ", dx)
		if abs(dx) <= EPS:
			var tween: Tween = get_tree().create_tween()
			tween.set_trans(Tween.TRANS_QUAD) # warning-ignore:return_value_discarded
			tween.tween_property(self, "global_position:x", self.force_move_to_x, 0.1)
			#global_position.x = self.force_move_to_x
			self.b_force_move = false
			self.do_change_move_state(true)
			self.person_animation_state = PersonAnimationState.Standing
			if transform.x.x < 0:
				transform.x.x *= -1
			velocity.x = move_toward(velocity.x, 0, SPEED)
			if self.force_move_finish_callback:
				force_move_finish_callback.call()
		else:
			self.person_animation_state = PersonAnimationState.Walking
			velocity.x = dx / abs(dx) * SPEED
			if velocity.x * transform.x.x < 0:
				transform.x.x *= -1
	else:
		var direction = Input.get_axis("player_left", "player_right")
		if direction and player_can_move:
			velocity.x = direction * SPEED
			person_animation_state = PersonAnimationState.Walking
			
			if velocity.x * transform.x.x < 0:
				transform.x.x *= -1
		else:
			if transform.x.x < 0:
				transform.x.x *= -1
			velocity.x = move_toward(velocity.x, 0, SPEED)
			if person_animation_state == PersonAnimationState.Walking:
				person_animation_state = PersonAnimationState.Standing

	move_and_slide()

	var x = global_position.x
	if camera and 960 <= x and x <= 1910:
		#var tween: Tween = get_tree().create_tween()
		#tween.set_trans(Tween.TRANS_QUAD) # warning-ignore:return_value_discarded
		#tween.tween_property(camera, "global_position:x", x, 0.1)
		camera.global_position.x = x

func do_move_to(to_x, callback = null):
	self.force_move_to_x = to_x
	if abs(to_x - global_position.x) <= EPS:
		#global_position.x = to_x
		var tween: Tween = get_tree().create_tween()
		tween.set_trans(Tween.TRANS_QUAD) # warning-ignore:return_value_discarded
		tween.tween_property(self, "global_position:x", to_x, 0.1)
		self.person_animation_state = PersonAnimationState.Standing
		self.b_force_move = false
		self.do_change_move_state(true)
		if callback:
			callback.call()
	else:
		self.force_move_finish_callback = callback
		self.force_move_to_x = to_x
		self.person_animation_state = PersonAnimationState.Walking
		self.do_change_move_state(false)
		self.b_force_move = true	


func do_change_move_state(b_can_move):
	if not b_can_move and person_animation_state == PersonAnimationState.Walking:
		person_animation_state = PersonAnimationState.Standing

	player_can_move = b_can_move

func destroy():
	queue_free()

func _on_animation_player_animation_finished(anim_name):
	print("[Person(%s)][animation_finished]: anim_name == " % name, anim_name)
	if person_animation_state == PersonAnimationState.ButtonPressing:
		person_animation_state = PersonAnimationState.Standing
		
	if person_animation_state == PersonAnimationState.MedicineGetting:
		person_animation_state = PersonAnimationState.Standing


