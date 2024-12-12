@tool
extends Sprite2D


@onready var light = $light_image
@onready var point_light: PointLight2D = $PointLight2D
@export var NormalLightColor: Color = Color(0, 1, 0, 0.3)
@export var FailedLightColor: Color = Color(1, 0, 0, 0.3)


var player                             = null


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (player && player.b_is_game_over):
		self.light.modulate = FailedLightColor
		self.point_light.color = FailedLightColor
	else:
		self.light.modulate = NormalLightColor
		self.point_light.color = NormalLightColor
	pass


func turn_off():
	self.light.visible = false


func _on_body_entered(player):
	if (player.person_type == player.PersonType.Player):
		self.player = player


func _on_body_exited(player):
	if (player.person_type == player.PersonType.Player):
		self.player = null
