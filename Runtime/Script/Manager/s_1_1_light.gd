extends Sprite2D


@onready var light = $Polygon2D
@export var NormalLightColor: Color = Color(0, 1, 0, 0.3)
@export var FailedLightColor: Color = Color(1, 0, 0, 0.3)


var b_player_colliding: bool           = false
var player                             = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (player && player.b_is_game_over):
		self.light.color = FailedLightColor
	else:
		self.light.color = NormalLightColor
	pass


func turn_off():
	self.light.visible = false


func _on_body_entered(player):
	self.b_player_colliding = true
	self.player = player


func _on_body_exited(player):
	self.b_player_colliding = false
	self.player = null
