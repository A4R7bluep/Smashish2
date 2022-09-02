extends Node

var facing

var playerNumber = 1
var directionX = 0.0
var directionY = 0.0

var directions = "5"
var lastDirection = 0
var inputTimer = 0.1

signal Dp623T1
signal Dp623T2
signal Dp623T3

signal Circle26T1
signal Circle26T2
signal Circle26T3

signal Circle24T1
signal Circle24T2
signal Circle24T3

signal Normal6T1
signal Normal6T2
signal Normal6T3

signal Normal2T1
signal Normal2T2
signal Normal2T3

signal Normal4T1
signal Normal4T2
signal Normal4T3

signal T1
signal T2
signal T3

signal Move5
signal Move6
signal Move9
signal Move8
signal Move7
signal Move4
signal Move1
signal Move2
signal Move3

signal Dash


func movement_vector():
	var value = 0
	
	var movementVector = Vector2(directionX, directionY)
	
	
	directionX = Input.get_action_strength("Player{}_Right".format({"": playerNumber})) - Input.get_action_strength("Player{}_Left".format({"": playerNumber}))
	
	directionY = Input.get_action_strength("Player{}_Up".format({"": playerNumber})) - Input.get_action_strength("Player{}_Down".format({"": playerNumber}))
	
	movementVector = Vector2(directionX, directionY)
	
	if movementVector.length() > 0.2:
		value = (int((round(atan2(movementVector.y, movementVector.x) / (2 * PI / 8))) + 8) % 8) + 1
	
	else:
		value = 0
	
	match facing:
		1:
			match value:
				1:
					return 6
				2:
					return 9
				3:
					return 8
				4:
					return 7
				5:
					return 4
				6:
					return 1
				7:
					return 2
				8:
					return 3
				0:
					return 5
					
		-1:
			match value:
				1:
					return 4
				2:
					return 7
				3:
					return 8
				4:
					return 9
				5:
					return 6
				6:
					return 3
				7:
					return 2
				8:
					return 1
				0:
					return 5


func findMove(button):
	if directions.find_last("623") != -1:
		#print("623")
		emit_signal("Dp623" + button)
	
	elif directions.find_last("236") != -1:
		#print("236")
		emit_signal("Circle26" + button)
		
	elif directions.find_last("214") != -1:
		#print("214")
		emit_signal("Circle24" + button)
		
	elif directions.find_last("6") != -1:
		#print("6")
		emit_signal("Normal6" + button)
		
	elif directions.find_last("2") != -1:
		#print("2")
		emit_signal("Normal2" + button)
		
	elif directions.find_last("4") != -1:
		#print("4")
		emit_signal("Normal4" + button)
		
	else:
		emit_signal(button)


func _process(delta):
	
	lastDirection = str(movement_vector())
	
	if directions[-1] != lastDirection:
		directions += lastDirection
		inputTimer = 0.1
	
	emit_signal("Move" + lastDirection)
	
	if Input.is_action_pressed("Player{}_Dash".format({"": playerNumber})):
		emit_signal("Dash", delta)
	
	if Input.is_action_pressed("Player{}_T1".format({"": playerNumber})):
		findMove("T1")
	
	if Input.is_action_pressed("Player{}_T2".format({"": playerNumber})):
		findMove("T2")
		
	if Input.is_action_pressed("Player{}_T3".format({"": playerNumber})):
		findMove("T3")
		
	
	inputTimer -= delta
	
	if inputTimer <= 0:
		#print("Timer Reset!")
		inputTimer = 0.1
		directions = "5"
