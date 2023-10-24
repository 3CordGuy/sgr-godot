extends TileMap

@onready var player = $Player


# Called when the node enters the scene tree for the first time.
func _ready():
	var all_milestone_cells = self.get_used_cells_by_id(1,2,Vector2i(2,1))
	var milestone = preload("res://milestone.tscn")
	
	for i in all_milestone_cells:
		var mile = milestone.instantiate()
		var mile_pos = self.map_to_local(i)
		self.erase_cell(1, i)
		mile.position = mile_pos
		
		mile.connect("milestone_collected", Callable(player, "_on_milestone_collected"))

		
		self.add_child(mile)
		
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
