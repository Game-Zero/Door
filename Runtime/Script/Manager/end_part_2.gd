extends Node2D
@onready var animation_player = $AnimationPlayer
var b_is_played = false
# Called when the node enters the scene tree for the first time.
func _ready():
	animation_player.stop()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if self.visible and !b_is_played:
		animation_player.play("end3_3")
		b_is_played = true
