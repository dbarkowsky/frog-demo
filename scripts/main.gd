extends Control

const FROG_TEMPLATE = preload("res://frog_page.tscn")

var swipe_start: Vector2 = Vector2.ZERO
var minimum_drag: float = 100.0

var frog_list: Array # list of all frog page instances
# For all the following arrays,
# it's intended that 0 = left, 1 = centre, 2 = right
var instanceArray: Array
var positionArray: Array
var centreFrogIndex = 0 # Which frog is in the centre currently?
	
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
							# User is trying to pan left							
							# Delete left frog
							remove_child(instanceArray[0])
							# Animate frogs moving
							tween.tween_property(instanceArray[1], "global_position:x", positionArray[0].x, 0.5)
							tween.tween_property(instanceArray[2], "global_position:x", positionArray[1].x, 0.5)
							# Assign new array indexes
							instanceArray[0] = instanceArray[1]
							instanceArray[1] = instanceArray[2]
							centreFrogIndex = (centreFrogIndex + 1) % frog_list.size()
							# Populate right frog
							var next_frog_index = (centreFrogIndex + 1) % frog_list.size()
							var frog_data = frog_list[next_frog_index]
							var new_frog = FROG_TEMPLATE.instantiate()
							new_frog.global_position = positionArray[2]
							add_child(new_frog)
							new_frog.hydrate(frog_data)
							instanceArray[2] = new_frog
						else:
							print("Swiped Left")
							# User is trying to pan right
							# Delete left frog
							remove_child(instanceArray[2])
							# Animate frogs moving
							tween.tween_property(instanceArray[1], "global_position:x", positionArray[2].x, 0.5)
							tween.tween_property(instanceArray[0], "global_position:x", positionArray[1].x, 0.5)
							# Assign new array indexes
							instanceArray[2] = instanceArray[1]
							instanceArray[1] = instanceArray[0]
							centreFrogIndex -= 1
							# Populate right frog
							if centreFrogIndex < 0:
								centreFrogIndex = frog_list.size() - 1
							var next_frog_index = centreFrogIndex
							var frog_data = frog_list[next_frog_index]
							var new_frog = FROG_TEMPLATE.instantiate()
							new_frog.global_position = positionArray[0]
							add_child(new_frog)
							new_frog.hydrate(frog_data)
							instanceArray[0] = new_frog

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
