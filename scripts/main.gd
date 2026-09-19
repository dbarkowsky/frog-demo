extends Control

const FROG_TEMPLATE = preload("res://frog_page.tscn")

var swipe_start: Vector2 = Vector2.ZERO
var minimum_drag: float = 100.0

var frog_list: Array
# For all the following arrays,
# it's intended that 0 = left, 1 = centre, 2 = right
var instanceArray: Array
var positionArray: Array
	
func _input(event: InputEvent) -> void:
		if event is InputEventScreenTouch:
			if event.pressed:
				swipe_start = event.position
			else:
				var swipe_vector = event.position - swipe_start
				if swipe_vector.length() >= minimum_drag:
					if abs(swipe_vector.x) > abs(swipe_vector.y):
						var tween = create_tween()
						tween.set_parallel()
						tween.set_trans(Tween.TRANS_QUAD)
						tween.set_ease(Tween.EASE_OUT)
						if swipe_vector.x > 0:
							print("Swiped Right")
							#tween.tween_property(scroll, "scroll_horizontal", 0, 0.5)
						else:
							print("Swiped Left")
							#tween.tween_property(scroll, "scroll_horizontal", 450, 0.5)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Set up positions based on screen size
	var screen_width = get_viewport_rect().size.x
	positionArray.append(Vector2(-screen_width * 1.5, 0)) # Left
	positionArray.append(Vector2(0, 0)) # Centre
	positionArray.append(Vector2(screen_width * 1.5, 0)) # Right
	
	# Load the json data that defines frog cards
	frog_list = load_json_array("res://data/frog_data.json")
	# Loop directly through each dictionary inside the JSON array
	var positionIndex = 0
	var frog_index = frog_list.size() - 1 # left is last frog in data
	for i in range(3):
		var frog_data = frog_list[frog_index]
		frog_index = (frog_index + 1) % frog_list.size()
		if typeof(frog_data) == TYPE_DICTIONARY:
			# 1. Create a copy of the template
			var new_frog = FROG_TEMPLATE.instantiate()
			new_frog.global_position = positionArray[positionIndex]
			positionIndex += 1
			# 2. Add it to the tree so its @onready nodes initialize
			add_child(new_frog)
			
			# 3. Send the dictionary data into the template
			new_frog.hydrate(frog_data)
			instanceArray.append(new_frog)

func load_json_array(file_path: String) -> Array:
	if not FileAccess.file_exists(file_path):
		print("Error: File not found at " + file_path)
		return []
		
	var file = FileAccess.open(file_path, FileAccess.READ)
	var json_string = file.get_as_text()
	file.close()
	
	var data = JSON.parse_string(json_string)
	
	if typeof(data) == TYPE_ARRAY:
		return data
	else:
		print("Error: JSON root is not formatted as an Array.")
		return []
