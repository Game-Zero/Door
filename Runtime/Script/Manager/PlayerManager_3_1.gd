extends CharacterBody2D

const SPEED: float = 300.0
const EPS: int     = 6

static var player_can_move: bool = true

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
@export var b_has_pressed_button: bool = false:
	set = set_b_pressed_button
@export var b_has_eaten_medication: bool = false
@export var machine: Node2D
@export var button: Node2D
@export var be_thinner: Node2D


var machine_x_button: Node2D
var button_x_button: Node2D


var b_force_move: bool   = false
var force_move_to_x: int = 0
var force_move_finish_callback
var press_button_finish_callabck
var get_medicine_finish_callback
var b_on_destination: bool        = false
var last_played_animation: String = ""
var dialog

func play_animation() -> String:
	var animation_name: String = "protagonist_"

	match (person_state):
		PersonState.Thin:
			animation_name += "thin_"
		PersonState.VeryThin:
			animation_name += "thinner_"
	
	match (person_animation_state):
		PersonAnimationState.Standing:
			animation_name += "standing"
		PersonAnimationState.Walking:
			animation_name += "walking"
		PersonAnimationState.ButtonPressing:
			animation_name += "button_to press"
		PersonAnimationState.MedicineGetting:
			animation_name += "medicine_to get"

	if animation_player != null and animation_player.has_animation(animation_name):
		animation_player.play(animation_name)

	if (last_played_animation != animation_name):
		print("[Person(%s)][play_animation] animation_name: " % name + animation_name)
		last_played_animation = animation_name
	return animation_name

func _ready() -> void:
	if Engine.is_editor_hint():
		return

	camera = get_node_or_null("../camera")
	button_x_button = button.get_node("x")
	machine_x_button = machine.get_node("x")
	self.load_state()
	dialog = AcceptDialog.new()
	add_child(dialog)
	dialog.size.x = 300
	dialog.dialog_text = "GameOver."
	dialog.title = "提示"
	dialog.get_ok_button().pressed.connect(func():get_tree().reload_current_scene())


func _physics_process(_delta) -> void:
	play_animation()
	if Engine.is_editor_hint():
		return

	if self.b_force_move:
		var dx: float = self.force_move_to_x - global_position.x
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
		var direction: float = Input.get_axis("player_left", "player_right")
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
		
		if (Input.is_action_just_pressed("player_fire") and self.b_on_destination):
			if (self.person_state == PersonState.VeryThin):
				get_tree().change_scene_to_file("res://Runtime/Scene/Stage_4_1.tscn")
			else:
				be_thinner.get_node("AnimationPlayer").play("be_thinner")
	move_and_slide()

	var x: float = global_position.x
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

func do_press_button(callback = null):
	press_button_finish_callabck = callback
	self.do_change_move_state(false)
	self.person_animation_state = PersonAnimationState.ButtonPressing

func do_get_medicine(callback = null):
	get_medicine_finish_callback = callback
	self.do_change_move_state(false)
	self.save_state()
	self.person_animation_state = PersonAnimationState.MedicineGetting

func save_state():
	var share_instance: Node = get_node("/root/SharedInstance")
	share_instance.shared_data_map["s3_1"] = {
		"player_can_move": true,
		"person_state": self.person_state,
		"person_animation_state": self.person_animation_state,
		"b_has_pressed_button": self.b_has_pressed_button,
		"b_has_eaten_medication": self.b_has_eaten_medication,
		"player_global_position": self.global_position
	}

func load_state():
	var share_instance: Node = get_node("/root/SharedInstance")
	if share_instance != null and share_instance.shared_data_map.has("s3_1"):
		var data_map = share_instance.shared_data_map["s3_1"]
		player_can_move = data_map["player_can_move"]
		person_state = data_map["person_state"]
		person_animation_state = data_map["person_animation_state"]
		b_has_pressed_button = data_map["b_has_pressed_button"]
		b_has_eaten_medication = data_map["b_has_eaten_medication"]
		global_position = data_map["player_global_position"]
		button_x_button.change_pressed(b_has_pressed_button)
		machine_x_button.change_pressed(b_has_eaten_medication)
		if not (b_has_eaten_medication) and machine:
			self.do_change_move_state(false)
			var make_medicine_finish = func():
				self.do_change_move_state(true)
			machine.do_make_medicine(make_medicine_finish)
	else:
		button_x_button.reset_pressed()
		machine_x_button.set_pressed()

		
func set_b_pressed_button(value: bool):
	if (not b_has_pressed_button and value):
		machine_x_button.reset_pressed()
	b_has_pressed_button = value

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
		self.do_change_move_state(true)
		if (press_button_finish_callabck != null):
			press_button_finish_callabck.call()

	if person_animation_state == PersonAnimationState.MedicineGetting:
		person_animation_state = PersonAnimationState.Standing
		self.do_change_move_state(true)
		if (get_medicine_finish_callback != null):
			get_medicine_finish_callback.call()


func _on_destination_body_entered(body):
	self.b_on_destination = true


func _on_destination_body_exited(body):
	self.b_on_destination = false
