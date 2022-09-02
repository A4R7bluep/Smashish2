extends Control

onready var choices = [null, $Sprite1, $Sprite8, $Sprite7, $Sprite6, $Sprite5, $Sprite4, $Sprite3, $Sprite2]

onready var selected1 = load("res://TestProjectile.png")
onready var selected2 = load("res://icon.png")
onready var selectedBoth = load("res://Xeus_Walking-1.png")
onready var default = load("res://Box.png")

func _process(_delta):
	var selection = [[null, null],
		[false, false], [false, false], [false, false], [false, false],
		[false, false], [false, false], [false, false], [false, false]
	]
	
	var inputVector1 = Vector2.ZERO
	var inputVector2 = Vector2.ZERO
	
	var directionX1 = Input.get_action_strength("Player1_Right") - Input.get_action_strength("Player1_Left")
	var directionY1 = Input.get_action_strength("Player1_Up") - Input.get_action_strength("Player1_Down")
	var directionX2 = Input.get_action_strength("Player2_Right") - Input.get_action_strength("Player2_Left")
	var directionY2 = Input.get_action_strength("Player2_Up") - Input.get_action_strength("Player2_Down")
	
	inputVector1 = Vector2(directionX1, directionY1).normalized()
	inputVector2 = Vector2(directionX2, directionY2).normalized()
	
	var compass1 = 0
	var compass2 = 0
	
	if inputVector1.length() > 0.2:
		compass1 = (int((round(atan2(inputVector1.y, inputVector1.x) / (2 * PI / 8))) + 8) % 8) + 1
		selection[compass1][0] = true
	
	if inputVector2.length() > 0.2:
		compass2 = (int((round(atan2(inputVector2.y, inputVector2.x) / (2 * PI / 8))) + 8) % 8) + 1
		selection[compass2][1] = true
		
	# player 1 selection
	if selection[compass1][0] and not selection[compass2][1]:
		for i in range(1, len(selection)):
			selection[i][0] = false
		
		for i in range(1, len(choices)):
			choices[i].texture = default
			
		choices[compass1].texture = selected1
	
	# player 2 selection
	elif not selection[compass1][0] and selection[compass2][1]:
		for i in range(1, len(selection)):
			selection[i][1] = false
		
		for i in range(1, len(choices)):
			choices[i].texture = default
			
		choices[compass2].texture = selected2
	
	# Both are selecting the same one
	elif selection[compass1][0] and selection[compass2][1] and inputVector1 == inputVector2:
		for i in range(1, len(selection)):
			selection[i][0] = false
		
		for i in range(1, len(selection)):
			selection[i][1] = false
		
		for i in range(1, len(choices)):
			choices[i].texture = default
		
		if compass1 != 0 and compass2 != 0:
			choices[compass1].texture = selectedBoth
