extends Control

@onready var sound: AudioStreamPlayer = $FrogSound
@onready var image: TextureButton = $FrogPic
@onready var title: RichTextLabel = $FrogText
@onready var latin: RichTextLabel = $FrogLatin
@onready var click: Sprite2D = $Click
@onready var wave: TextureRect = $Waveform

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Connect the button click signal to our play function
	image.pressed.connect(_on_frog_pic_pressed)
	
func _on_frog_pic_pressed() -> void:
	if sound.stream:
		sound.play()
	else:
		print("No sound stream loaded for this frog!")

func hydrate(frog: Dictionary) -> void:
	sound.stream = load(frog.get("audio"))
	image.texture_normal = load(frog.get("img"))
	title.text = frog.get("name")
	latin.text = frog.get("latin")
	print(frog.get("wave"))
	wave.texture = load(frog.get("wave")) as Texture2D
	
func stop_audio() -> void:
	if sound and sound.playing:
		sound.stop()
