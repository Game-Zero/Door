@tool
extends Area2D

@onready var texture_rect_w = $TextureRectW
@onready var texture_rect_s = $TextureRectS
@onready var texture_rect_a = $TextureRectA
@onready var texture_rect_d = $TextureRectD

enum KeyType {
	W,
	S,
	A,
	D,
}

enum KeyState {
	Standby,
	Active,
	Accepted,
	Perfect,
	Missed,
}

@export var value: KeyType = KeyType.W
@export var state: KeyState = KeyState.Standby

@export var standby_color: Color = Color8(255, 206,101)
@export var accepted_color: Color = Color8(255, 240, 207)
@export var perfect_color: Color = Color8(0, 253, 32)
@export var missed_color: Color = Color8(255, 76, 71)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var original_material = load("res://Runtime/Shader/button_2_1.material")
	texture_rect_w.material = original_material.duplicate()
	texture_rect_s.material = original_material.duplicate()
	texture_rect_a.material = original_material.duplicate()
	texture_rect_d.material = original_material.duplicate()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	texture_rect_w.visible = false
	texture_rect_s.visible = false
	texture_rect_a.visible = false
	texture_rect_d.visible = false

	var now_key = null

	match (value):
		KeyType.W:
			texture_rect_w.visible = true
			now_key = texture_rect_w
		KeyType.S:
			texture_rect_s.visible = true
			now_key = texture_rect_s
		KeyType.A:
			texture_rect_a.visible = true
			now_key = texture_rect_a
		KeyType.D:
			texture_rect_d.visible = true
			now_key = texture_rect_d

	var b_outglow_on = false
	match (state):
		KeyState.Standby:
			now_key.self_modulate = self.standby_color
		KeyState.Active:
			now_key.self_modulate = self.standby_color
			b_outglow_on = true
		KeyState.Perfect:
			now_key.self_modulate = self.perfect_color
		KeyState.Accepted:
			now_key.self_modulate = self.accepted_color
		KeyState.Missed:
			now_key.self_modulate = self.missed_color

	now_key.material.set_shader_parameter("modulate_color", now_key.self_modulate)
	now_key.material.set_shader_parameter("b_outglow_on", b_outglow_on)
