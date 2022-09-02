extends Node

#var state
#
#var move = ["236", "214", "41236", "63214", "412364"]
#
#enum {
#	THING,
#	SSDd,
#	SSAa
#}
#
#var lastMoves = ""
#var lastInput = ""
#
#var resetTimerLength = 0.1
#var resetTimer = resetTimerLength
#
#var inputTimerLenght = 0.1
#var inputTimer = inputTimerLenght
#
##SPECAIL INPUT SIGNALS
#signal Circle24T1
#signal Circle26T1
#signal Circle426T1
#signal Circle624T1
#
#signal Circle24T2
#signal Circle26T2
#signal Circle426T2
#signal Circle624T2
#
#signal Circle24T3
#signal Circle26T3
#signal Circle426T3
#signal Circle624T3

#func keyPress(key, type):
#	resetTimer = 1
#	#print(key.to_upper())
#
#	if key != lastInput:
#		match type:
#			"attack":
#				var finalMove
#				#print("Attack button pressed")
#				for i in move:
#					if lastMoves.find(i) != -1: #and lastMoves.ends_with(i):
#						#print("Input: " + i + key)
#						finalMove = i + key
#
#				match finalMove:
#					#try inputs with vectors instead of keeping values in a string
#					"236T1":
#						emit_signal("Circle26T1")
#					"236T2":
#						emit_signal("Circle26T2")
#					"236T3":
#						emit_signal("Circle26T3")
#					"214T1":
#						emit_signal("Circle24T1")
#					"214T2":
#						emit_signal("Circle24T2")
#					"214T3":
#						emit_signal("Circle24T3")
#					"41236T1":
#						emit_signal("Circle426T1")
#					"41236T2":
#						emit_signal("Circle426T2")
#					"41236T3":
#						emit_signal("Circle426T3")
#					"63214T1":
#						emit_signal("Circle624T1")
#					"63214T2":
#						emit_signal("Circle624T2")
#					"63214T3":
#						emit_signal("Circle624T3")
#				print(lastMoves + key)
#				lastMoves = ""
#				finalMove = ""
#			"movement":
#				#print("Movement button pressed")
#				lastMoves = lastMoves + key#.to_upper()
#				resetTimer = resetTimerLength
#	lastInput = key
#	print(lastMoves)
#
##func keyRelease(key):
##	lastMoves = lastMoves + key.to_lower()
##	resetTimer = 1
##	#print(key.to_lower())
##	print(lastMoves)
#
#func _process(delta):
#	if Input.is_action_just_pressed("ui_left") and Input.is_action_just_pressed("ui_down"):
#		keyPress("1", "movement")
#	elif Input.is_action_just_pressed("ui_right") and Input.is_action_just_pressed("ui_down"):
#		keyPress("3", "movement")
#	elif Input.is_action_just_pressed("ui_left") and Input.is_action_just_pressed("ui_up"):
#		keyPress("7", "movement")
#	elif Input.is_action_just_pressed("ui_right") and Input.is_action_just_pressed("ui_down"):
#		keyPress("9", "movement")
#
#	elif Input.is_action_just_pressed("ui_left"):
#		keyPress("4", "movement")
#	elif Input.is_action_just_pressed("ui_down"):
#		keyPress("2", "movement")
#	elif Input.is_action_just_pressed("ui_right"):
#		keyPress("6", "movement")
#	elif Input.is_action_just_pressed("ui_up"):
#		keyPress("8", "movement")
#
#	if Input.is_action_pressed("Player1_T1"):
#		keyPress("T1", "attack")
#	elif Input.is_action_pressed("Player1_T2"):
#		keyPress("T2", "attack")
#	elif Input.is_action_pressed("Player1_T3"):
#		keyPress("T3", "attack")
#
#	resetTimer -= delta
#
#	if resetTimer <= 0:
#		lastMoves = ""
#		resetTimer = resetTimerLength
#		#print("inputs reset")
#
##func _on_inputManager_Circle26T1():
##	print("SIGNAL RECIEVED")

#var playerNumber = get_parent().thisPlayerNumber

var playerNumber = 1
var inputList = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
var maxBufferLength = 16
var lastInput = 0
var lastAttack = ""
var resetTimerLength = 0.5
var resetTimer = resetTimerLength

#SPECAIL INPUT SIGNALS
signal Circle24T1
signal Circle26T1
signal Circle426T1
signal Circle624T1

signal Circle24T2
signal Circle26T2
signal Circle426T2
signal Circle624T2

signal Circle24T3
signal Circle26T3
signal Circle426T3
signal Circle624T3

func getAttackButtons():
	var tier1
	var tier2
	var tier3
	
	match playerNumber:
		1:
			tier1 = Input.get_action_strength("Player1_T1")
			tier2 = Input.get_action_strength("Player1_T2")
			tier3 = Input.get_action_strength("Player1_T3")
		2:
			tier1 = Input.get_action_strength("Player2_T1")
			tier2 = Input.get_action_strength("Player2_T2")
			tier3 = Input.get_action_strength("Player2_T3")
	
	if tier1:
		return "A"
	if tier2:
		return "B"
	if tier3:
		return "C"

func movement_vector():
	var directionX = 0.0
	var directionY = 0.0
	
	var movementVector = Vector2()
	
	movementVector = Vector2(directionX, directionY)
	
	match playerNumber:
		1:
			directionX = Input.get_action_strength("Player1_Right") - Input.get_action_strength("Player1_Left")
			directionY = Input.get_action_strength("Player1_Up") - Input.get_action_strength("Player1_Down")
		2:
			directionX = Input.get_action_strength("Player2_Right") - Input.get_action_strength("Player2_Left")
			directionY = Input.get_action_strength("Player2_Up") - Input.get_action_strength("Player2_Down")
	
	movementVector = Vector2(directionX, directionY)
	if movementVector.length() < 0.2:
		return 5
	
	movementVector = Vector2(directionX, directionY).normalized()
	
	var angleMovement = movementVector.angle()
	
	#print(angleMovement)
	
	if directionY >= 0:
		if angleMovement < PI/5.0:
			return 6
		if angleMovement < 2.0*PI/5.0:
			return 9
		if angleMovement < 3.0*PI/5.0:
			return 8
		if angleMovement < 4.0*PI/5.0:
			return 7
		else:
			return 4
	
#	if angleMovement < PI/5.0:
#		return 6
	if angleMovement < -3.0*PI/5.0:
		return 1
	if angleMovement < -2.0*PI/5.0:
		return 2
	if angleMovement < -1.0*PI/5.0:
		return 3
#	if angleMovement < PI:
#		return 4
	
#	return 6
	
	#printt(directionX, directionY, movementVector, angleMovement)

func listMove():
	for i in range(maxBufferLength - 1):
		inputList[i] = inputList[i + 1]

func listString():
	var string = ""
	for i in range(maxBufferLength - 1):
		string = string + str(inputList[i])
	return string

func resetList():
	inputList = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]

func checkMoves(lastAttack):
	var stringMoves = listString()
	
	if stringMoves.find("41236") > -1:
		print("426 Inputed")
		match lastAttack:
			"A":
				emit_signal("Circle426T1")
			"B":
				emit_signal("Circle426T2")
			"C":
				emit_signal("Circle426T3")
		print("Circle426" + lastAttack)
	
	elif stringMoves.find("63214") > -1:
		print("624 Inputed")
		match lastAttack:
			"A":
				emit_signal("Circle624T1")
			"B":
				emit_signal("Circle624T2")
			"C":
				emit_signal("Circle624T3")
		print("Circle624" + lastAttack)
	
	elif stringMoves.find("236") > -1:
		print("26 Inputed")
		match lastAttack:
			"A":
				emit_signal("Circle26T1")
			"B":
				emit_signal("Circle26T2")
			"C":
				emit_signal("Circle26T3")
		print("Circle26" + lastAttack)
	
	elif stringMoves.find("214") > -1:
		print("24 Inputed")
		match lastAttack:
			"A":
				emit_signal("Circle24T1")
			"B":
				emit_signal("Circle24T2")
			"C":
				emit_signal("Circle24T3")
		print("Circle24" + lastAttack)

func _process(delta):
	lastInput = movement_vector()
	if lastAttack == null:
		lastAttack = getAttackButtons()
	
	checkMoves("z")
	
	#Interpret stick vector
	if lastInput == 5:
		pass
	elif inputList[-1] != lastInput:
		listMove()
		inputList[-1] = lastInput
		resetTimer = resetTimerLength
		print(listString())
	
	#Interpret attack buttons
	if lastAttack != null:
		checkMoves(lastAttack)
		#print(listString() + lastAttack)
#		print(lastAttack)
		#listMove()
		#inputList[-1] = lastAttack
		#listString()
		#print(listString())
		lastAttack = null
		resetTimer = 0
	
	#Input timeout
	resetTimer -= delta
	if resetTimer <= 0:
		resetList()
		resetTimer = resetTimerLength
		#print("inputs reset")
