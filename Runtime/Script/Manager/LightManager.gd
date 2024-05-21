extends TextureRect

@export var player: CharacterBody2D
var light

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if player == null:
		return

	var x = player.global_position.x
	if x <= 1408:
		light = get_node("light1")
	elif 1408 < x and x <= 2688:
		light = get_node("light2")
	elif 2688 < x:
		light = get_node("light3")
	
	var v = player.global_position - light.global_position
	light.rotation_degrees = rad_to_deg(-atan(v.x / v.y))
