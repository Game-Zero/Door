extends Node2D

@export var end_1: Node2D
@export var end_2: Node2D
@export var end_3: Node2D
@export var end_4: Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	end_1.visible = true
	end_2.visible = false
	end_3.visible = false
	end_4.visible = false
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if (end_1 != null && (Input.is_action_just_pressed("player_fire") or 
		Input.is_action_just_pressed("player_jump") or
		Input.is_action_just_pressed("ui_accept"))):
		end_1.queue_free()
		end_2.visible = true



func _on_area_2d_body_entered(_body):
	end_2.queue_free()
	end_3.visible = true
	var end3_finish_callback = func(state):
		if state == end_3.EndAnimationState.End32:
			end_3.queue_free()
			end_4.visible = true
	end_3.play(end_3.EndAnimationState.End31, end3_finish_callback)
