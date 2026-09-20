extends Control

@onready var sound: AudioStreamPlayer = $FrogSound
@onready var image: TextureButton = $FrogPic
@onready var title: RichTextLabel = $FrogText
@onready var latin: RichTextLabel = $FrogLatin
@onready var click: Sprite2D = $Click
@onready var wave: TextureRect = $Waveform
@onready var stick: Sprite2D = $Waveform/Stick

var tween: Tween

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Connect the button click signal to our play function
	image.pressed.connect(_on_frog_pic_pressed)
	
func _on_frog_pic_pressed() -> void:
	if sound.stream:
		if not sound.playing:
			start_audio()
		else:
			stop_audio()
			start_audio() # just reset basically
	else:
		print("No sound stream loaded for this frog!")

func hydrate(frog: Dictionary) -> void:
	sound.stream = load(frog.get("audio"))
	image.texture_normal = load(frog.get("img"))
	title.text = frog.get("name")
	latin.text = frog.get("latin")
	wave.texture = load(frog.get("wave")) as Texture2D

func start_audio() -> void:
	tween = create_tween()
	# End value depends on where end of audio wave is.
	# Time to get there depends on length of audio...
	var startX = wave.position.x
	var endX = startX + wave.size.x
	var length = sound.stream.get_length()
	var half_width = stick.texture.get_width() * stick.scale.x * 2
	startX -= half_width
	endX -= half_width
	# Set the stick to the start in case it isn't there
	stick.position.x = startX
	# And move stick to end
	tween.tween_property(stick, "position:x", endX, length)
	sound.play()
			
func stop_audio() -> void:
	if sound and sound.playing:
		sound.stop()
	if tween and tween.is_valid():
		tween.kill()
		var startX = wave.position.x
		var half_width = stick.texture.get_width() * stick.scale.x * 2
		startX -= half_width
		stick.position.x = startX	
