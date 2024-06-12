extends Area2D

var b_player_colliding = false
var player = null
@onready var animation_player = $AnimationPlayer
@export var machine: Node2D
var button_press_finish_callback

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func do_press_button(callback = null):
	button_press_finish_callback = callback
	animation_player.play("button_pressed")

var count = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if player == null or !self.b_player_colliding or player.b_has_pressed_button or !player.player_can_move:
		return
	
	
	if Input.is_action_just_pressed("player_fire"):
		var move_finish_callback = func():
			player.do_change_move_state(false)
			var press_button_finish_callback = func():
				player.do_change_move_state(false)
				count = count + 1
				if (count >= 2):
					var make_medicine_finish = func():
						player.do_change_move_state(true)
					player.b_has_pressed_button = true
					machine.do_make_medicine(make_medicine_finish)
			count = 0
			player.do_press_button(press_button_finish_callback)
			self.do_press_button(press_button_finish_callback)
		player.do_move_to(722, move_finish_callback)


func _on_body_entered(player):
	self.b_player_colliding = true
	self.player = player


func _on_body_exited(player):
	self.b_player_colliding = false
	self.player = null


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "button_pressed":
		animation_player.play("button_still")
		if (button_press_finish_callback != null):
			button_press_finish_callback.call()
