extends Node2D

@onready var ground: TileMapLayer = $TileMap/Ground




# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	ground.use_kinematic_bodies = true 


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	#area_2d.area_entered.connect(_on_area_2d_area_entered)
	


func _on_area_2d_area_entered(area: Area2D) -> void:
	print("collision")
	
