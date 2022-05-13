extends Camera2D

onready var topLeft = $Limits/Topleft
onready var bottomRight = $Limits/BottomRlght

# Called when the node enters the scene tree for the first time.
func _ready():
	limit_top = topLeft.position.y
	limit_left = topLeft.position.x
	limit_bottom = bottomRight.position.y
	limit_right = bottomRight.position.x
