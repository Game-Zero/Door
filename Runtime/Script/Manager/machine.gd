extends Area2D

var b_player_colliding = false
var player = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if player == null or !self.b_player_colliding or player.b_has_pressed_button or !player.player_can_move:
		return
	
	
	if Input.is_action_just_pressed("player_fire"):
		var callback = func():
			pass
		player.do_move_to(1320, callback)


func _on_body_entered(player):
	self.b_player_colliding = true
	self.player = player
	pass


func _on_body_exited(player):
	self.b_player_colliding = false
	self.player = null
	pass
