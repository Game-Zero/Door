extends Sprite2D

@onready var light = $Polygon2D
var b_player_colliding = false
var player = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (player && player.b_is_game_over):
		light.color = Color(1, 0, 0, 0.3)
	else:
		light.color = Color(0, 1, 0, 0.3)
	pass

func _on_body_entered(player):
	self.b_player_colliding = true
	self.player = player

func _on_body_exited(player):
	self.b_player_colliding = false
	self.player = null
