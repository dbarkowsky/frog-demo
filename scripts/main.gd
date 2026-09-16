extends Control

const FROG_TEMPLATE = preload("res://frog_page.tscn")
@onready var grid_container: GridContainer = $GridContainer
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Load the json data that defines frog cards
	var frog_list: Array = load_json_array("res://data/frog_data.json")
	
	# Loop directly through each dictionary inside the JSON array
	for frog_data in frog_list:
		if typeof(frog_data) == TYPE_DICTIONARY:
			# 1. Create a copy of the template
			var new_frog = FROG_TEMPLATE.instantiate()
			
			# 2. Add it to the tree so its @onready nodes initialize
			grid_container.add_child(new_frog)
			
			# 3. Send the dictionary data into the template
			new_frog.hydrate(frog_data)

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
