@tool
extends Area2D

@onready var texture_rect_w = $TextureRectW
@onready var texture_rect_s = $TextureRectS
@onready var texture_rect_a = $TextureRectA
@onready var texture_rect_d = $TextureRectD

@onready var mask_perfect = $MaskPerfect
@onready var mask_accepted = $MaskAccepted
@onready var mask_missed = $MaskMissed

enum KeyType {
	W,
	S,
	A,
	D,
}

enum KeyState {
	Standby,
	Accepted,
	Perfect,
	Missed,
}

@export var value: KeyType = KeyType.W
@export var state: KeyState = KeyState.Standby

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	texture_rect_w.visible = false
	texture_rect_s.visible = false
	texture_rect_a.visible = false
	texture_rect_d.visible = false

	match (value):
		KeyType.W:
			texture_rect_w.visible = true
		KeyType.S:
			texture_rect_s.visible = true
		KeyType.A:
			texture_rect_a.visible = true
		KeyType.D:
			texture_rect_d.visible = true
	pass

	mask_perfect.visible = false
	mask_accepted.visible = false
	mask_missed.visible = false

	match (state):
		KeyState.Perfect:
			mask_perfect.visible = true
		KeyState.Accepted:
			mask_accepted.visible = true
		KeyState.Missed:
			mask_missed.visible = true
