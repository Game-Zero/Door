extends Area2D

var b_player_colliding = false
var player = null
var make_medicine_finish_callback = null
var take_medicine_finish_callback = null
var count = 0

@export var bridge_anime: Node2D
@onready var animation_player = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func do_make_medicine(callback):
	make_medicine_finish_callback = callback
	animation_player.play("machine_made_medicine")

func do_take_medicine(callback):
	take_medicine_finish_callback = callback
	animation_player.play("machine_medicine_taken")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if player == null or !self.b_player_colliding or !player.b_has_pressed_button or player.b_has_eaten_medication or !player.player_can_move:
		return
	
	if Input.is_action_just_pressed("player_fire"):
		var callback = func():
			count = 0
			var finish_callabck = func():
				count = count + 1
				if (count >= 2):
					player.player_can_move = false
					bridge_anime.visible = true
					bridge_anime.play()
			player.player_can_move = false
			player.b_has_eaten_medication = true
			player.do_get_medicine(finish_callabck)
			self.do_take_medicine(finish_callabck)
		player.do_move_to(1320, callback)


func _on_body_entered(player):
	self.b_player_colliding = true
	self.player = player
	pass


func _on_body_exited(player):
	self.b_player_colliding = false
	self.player = null
	pass


func _on_animation_player_animation_finished(anim_name):
	if (anim_name == "machine_made_medicine"):
		if (make_medicine_finish_callback != null):
			make_medicine_finish_callback.call()

	if (anim_name == "machine_medicine_taken"):
		if (take_medicine_finish_callback != null):
			take_medicine_finish_callback.call()
