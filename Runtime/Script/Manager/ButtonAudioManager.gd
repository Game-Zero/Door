extends TextureButton

@export var on_button_down_audio: AudioStream = null
@export var on_button_hover_audio: AudioStream = null

var audio_stream_player: AudioStreamPlayer2D = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.audio_stream_player = AudioStreamPlayer2D.new()
	self.add_child(self.audio_stream_player)
	self.button_down.connect(self.on_button_down)
	self.mouse_entered.connect(self.on_mouse_entered)
	self.focus_entered.connect(self.on_mouse_entered)


func play_button_down_audio():
	audio_stream_player.stream = on_button_down_audio
	audio_stream_player.play()


func on_button_down() -> void:
	print("[ButtonAudioManager][on_button_down]")
	self.play_button_down_audio()


func on_mouse_entered() -> void:
	print("[ButtonAudioManager][on_button_hover]")
	audio_stream_player.stream = on_button_hover_audio
	audio_stream_player.play()
