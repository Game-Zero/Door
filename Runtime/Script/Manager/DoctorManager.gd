extends Node2D

@onready var liquid = $liquid
@onready var h = liquid.texture.get_size().y
@onready var delta_h = h * 0.1

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func on_liquid_up():
	print("on_liquid_up")
	liquid.apply_scale(liquid.scale + Vector2(0, delta_h / h))
	liquid.position = liquid.position - Vector2(0, delta_h / 2)
