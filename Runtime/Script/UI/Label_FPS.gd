extends Label

var deltaTime = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	self.text = "FPS: 0"
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (deltaTime > 0.1):
		self.text = " FPS: " + str(Performance.get_monitor(Performance.TIME_FPS))
	deltaTime += delta
	pass
