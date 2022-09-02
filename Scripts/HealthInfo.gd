extends Label

var labelNumber = -9

func _ready():
	self.set_name(str(labelNumber))
	self.text = str(labelNumber)
	rect_position.x = 100*labelNumber + 100
