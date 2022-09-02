extends KinematicBody2D

#movement variables
export var run_speed = 350
export var jump_speed = -800 #negative numbers make player go up
export var sprintMod = 1.25
export var walkMod = 0.5
export var ACCELERATION = 1500
var frictionMod

#physics variables
export var gravity = 2500
export var frictionMu = 100
export var weight = 10.0

var direction = 0

var velocity = Vector2()

onready var animationPlayer = $AnimationPlayer
onready var labelChooser = $LabelChooser
onready var stats = $PlayerStats
onready var position2D = $Position2D
onready var visibility = $VisibilityNotifier2D
onready var hurtbox = $Hurtbox
onready var sprite = $Sprite

#Hitboxes
onready var counter = $Position2D/BlockCounter
	#Tier 1
onready var T1D = $Position2D/Tier1/T1D
onready var T1U = $Position2D/Tier1/T1U
onready var T1N = $Position2D/Tier1/T1N
onready var T1F = $Position2D/Tier1/T1F
	#Tier 2
onready var T2F = $Position2D/Tier2/T2F
onready var T2D = load("res://Scenes/XeusT2D.tscn")
	#Tier 3
onready var T3U = $Position2D/Tier3/T3U
onready var T3D = $Position2D/Tier3/T3D
onready var T3F = load("res://Scenes/XeusT3F.tscn")
	#Aerials
onready var AN = $Position2D/Aerials/AN
onready var AF = $Position2D/Aerials/AF
onready var AU = $Position2D/Aerials/AU
onready var AD = $Position2D/Aerials/AD
onready var AB = $Position2D/Aerials/AB

#onready var bat = load("res://Scenes/XeusBat.tscn")
onready var world = get_parent()

var jumps = 1

var right = "false"
var left = "false"
var jump = "false"
var down = "false"
var up = "false"
var tier1 = "false"
var tier2 = "false"
var tier3 = "false"
var rage = "false"
var shield1 = "false"
var shield2 = "false"

var doRight
var doLeft
var doJump
var doDown
var doUp
var doTier1
var doTier2
var doTier3
var doRage
var doShield1
var doShield2
var doJumpPRESSED
var doJumpRELEASED
var doDownPRESSED
var doDownRELEASED
var _doPageUp
var _doPageDown

var pageUp = "false"
var pageDown = "false"

onready var startposx = position.x
onready var startposy = position.y

var thisPlayerNumber = -1

var charState = "vampire"
var T2NMultiplyer = 1
export var T3FCharge = 1
export var T3Fdone = false

var isInT2F = false
var isInT2N = false
var isInT2D = false
var isInAD = false
var isInT3D = false
var isInT3U = false
var isInT3F = false
var isInLag = false
var isInShield2 = false

var lagTimer
var T2FTimer = 25
var T2NTimer = 10
var ADTimer = 25
var T3DTimer = 25
var T3UTimer = 20
var shield2Timer = 1

var tpDirection #Direction teleported

func _init():
	position.x = 400
	position.y = 100
	velocity.x = 0
	velocity.y = 0

func _ready():
	set_boxes()
	set_name("player" + str(thisPlayerNumber))
	if thisPlayerNumber == 0:
		right = "Player1_Right"
		left = "Player1_Left"
		jump = "Player1_Jump"
		down = "Player1_Down"
		up = "Player1_Up"
		tier1 = "Player1_T1"
		tier2 = "Player1_T2"
		tier3 = "Player1_T3"
		rage = "Player1_Rage"
		shield1 = "Player1_Shield1"
		shield2 = "Player1_Shield2"
		pageUp = "ui_page_up"
		pageDown = "ui_page_down"
	if thisPlayerNumber == 1:
		right = "Player2_Right"
		left = "Player2_Left"
		jump = "Player2_Jump"
		down = "Player2_Down"
		up = "Player2_Up"
		tier1 = "Player2_T1"
		tier2 = "Player2_T2"
		tier3 = "Player2_T3"
		rage = "Player2_Rage"
		shield1 = "Player2_Shield1"
		shield2 = "Player2_Shield2"
		pageUp = "ui_page_up"
		pageDown = "ui_page_down"
	if right == "false":
		push_error("controlls are false")

func hit(body, Sdamage, SknockX, SknockY):
	if doShield2:
		animationPlayer.play("counter")
	if not doShield1 and not doShield2 and body.get_name() != "Ground" and body.get_name() != "Platform":
		var damageDone = Sdamage * T2NMultiplyer
		var knockX = SknockX
		var knockY = SknockY
		
		if self.stats.health + damageDone >= 999:
			self.stats.health = 999
		else:
			self.stats.health += damageDone
			world.SoundPlayer.play()
			if self.global_position > self.position:
				self.velocity.x += knockX * body.stats.health / (body.weight * 0.2)
				self.velocity.y -= knockY * body.stats.health / (body.weight * 0.2)
			else:
				self.velocity.x -= knockX * body.stats.health / (body.weight * 0.2)
				self.velocity.y -= knockY * body.stats.health / (body.weight * 0.2)

func set_boxes():
	self.hurtbox.set_collision_layer_bit(thisPlayerNumber + 3, 1)
	self.T1D.set_collision_mask_bit(thisPlayerNumber + 3, 0)
	self.T1U.set_collision_mask_bit(thisPlayerNumber + 3, 0)
	self.T1N.set_collision_mask_bit(thisPlayerNumber + 3, 0)
	self.T1F.set_collision_mask_bit(thisPlayerNumber + 3, 0)
	self.T2F.set_collision_mask_bit(thisPlayerNumber + 3, 0)
	self.T3D.set_collision_mask_bit(thisPlayerNumber + 3, 0)
	self.T3U.set_collision_mask_bit(thisPlayerNumber + 3, 0)

#Move functions
func T2F():
	var T2Fbox = T2F.get_node("CollisionShape2D")
	T2Fbox.disabled = false
	if direction == 0:
		velocity.x += 35
	elif direction == 1:
		velocity.x -= 35
	T2FTimer -= 1
	if T2FTimer <= -15:
		T2FTimer = 25
		T2Fbox.disabled = true
		isInT2F = false
		lagTimer = 10
		isInLag = true

func T2N(delta):
	T2NTimer -= 1 * delta
	if T2NTimer <= 0:
		T2NTimer = 60
		T2NMultiplyer = 1
		isInT2N = false

func T2D():
	for i in 5:
		var rng = RandomNumberGenerator.new()
		rng.randomize()
		var RADIUS = 100
		var theta = rng.randf_range(0, 6.28)
		var T2DInst = T2D.instance()
		T2DInst.position.x = position.x + RADIUS * cos(theta)
		T2DInst.position.y = position.y + RADIUS * sin(theta)
		T2DInst.setVars(thisPlayerNumber, world)
		world.add_child(T2DInst)
	isInT2D = false
	lagTimer = 0.5
	isInLag = true

func AD():
	animationPlayer.play("AD")
	velocity.y += 100
	ADTimer -= 1
#	if is_on_floor():
#		animationPlayer.stop()
	if ADTimer <= 0:
		ADTimer = 25
		isInAD = false

func T3D():
	T3DTimer -= 1
	if T3DTimer <= 0:
		isInT3D = false
		T3DTimer = 25
	elif T3DTimer >= 15:
		velocity.y -= 100
	elif T3DTimer < 15:
		animationPlayer.play("T3D")
		velocity.y += 125

func T3U():
	T3UTimer -= 1
	if T3UTimer <= 0:
		if tpDirection == "up":
			position.y -= 200
		elif tpDirection == "down":
			position.y += 200
		elif tpDirection == "right":
			position.x += 200
		elif tpDirection == "left":
			position.x -= 200
		animationPlayer.play("T3U")
		isInT3U = false
		T3UTimer = 20
	elif T3UTimer >= 10:
		if Input.is_action_pressed(up):
			tpDirection = "up"
		elif Input.is_action_pressed(down):
			tpDirection = "down"
		elif Input.is_action_pressed(right):
			tpDirection = "right"
		elif Input.is_action_pressed(left):
			tpDirection = "left"

func T3F():
	animationPlayer.play("T3F")
	if not Input.is_action_pressed(tier3) and Input.is_action_pressed(right) or not Input.is_action_pressed(tier3) and Input.is_action_pressed(left):
		T3Fdone = true
	if T3Fdone == true:
		animationPlayer.stop(true)
		var T3FInst = T3F.instance()
		T3FInst.setVars(self, direction, T3FCharge)
		world.add_child(T3FInst)
		isInT3F = false
		T3FCharge = 1
		T3Fdone = false
		lagTimer = 1
		isInLag = true

func shield2(delta):
	shield2Timer -= delta
	if shield2Timer <= 0:
		isInShield2 = true
	if shield2Timer <= 1:
		isInShield2 = false

#Input function
func get_input(delta):
	if Input.is_action_pressed("ui_end"): #for testing purposes
		stats.health += 1
	
	if doRage:
		print("enraged")
	
	#going through platforms
	if doJumpPRESSED:
		self.set_collision_layer_bit(1, 0)
	if doJumpRELEASED:
		self.set_collision_layer_bit(1, 1)
	if doDownPRESSED:
		self.set_collision_layer_bit(1, 0)
	if doDownRELEASED:
		self.set_collision_layer_bit(1, 1)
	
	#general movement
	#Jump
	if doJumpPRESSED and not jumps <= 0:
		velocity.y = jump_speed
		jumps -= 1

	#Walk
	if is_on_floor() and not doJump:
		if doRight:
			velocity.x += ACCELERATION * delta
			direction = 0
		if doLeft:
			velocity.x -= ACCELERATION * delta
			direction = 1

		if charState == "vampire":
			jumps = 1
		elif charState == "bat":
			jumps = 3

		#Shields
		if doShield2:
			shield2Timer = 1
			shield2(delta)

		#Attacks
#		if charState == "vampire":
#			if doTier1 and not doRight and not doLeft and not doUp and not doDown:
#				animationPlayer.play("T1N")
#			elif doTier1 and doRight or doTier1 and doLeft:
#				animationPlayer.play("T1F")
#			elif doTier1 and doUp:
#				animationPlayer.play("T1U")
#			elif doTier1 and doDown:
#				animationPlayer.play("T1D")
#
#			elif doTier3 and doRight or doTier3 and doLeft:
#				isInT3F = true
#			elif doTier3 and doUp:
#				isInT3U = true
#			elif doTier3 and doDown:
#				isInT3D = true

	if not is_on_floor():
	#Aerials
#		if charState == "bat":
#			if doTier1 and not doRight and not doLeft and not doUp and not doDown:
#				animationPlayer.play("AN")
#			elif doTier1 and doRight and direction == 0 or doTier1 and doLeft and direction == 1:
#				animationPlayer.play("AF")
#			elif doTier1 and doUp:
#				animationPlayer.play("AU")
#			elif doTier1 and doDown:
#				isInAD = true
#			elif doTier1 and doRight and direction == 1 or doTier1 and doLeft and direction == 0:
#				animationPlayer.play("AB")
		
		#Air Drift
		if doRight:
			velocity.x += ACCELERATION * delta
		if doLeft:
			velocity.x -= ACCELERATION * delta
	if direction == 0:
		position2D.scale.x = 1
		sprite.set_flip_h(false)
	if direction == 1:
		position2D.scale.x = -1
		sprite.set_flip_h(true)

	#Tier 2 attacks
#	if doTier2 and not doRight and not doLeft and not doUp and not doDown:
#		if isInT2N == false:
#			T2NMultiplyer = 2
#			isInT2N = true
#	elif doTier2 and doRight or doTier2 and doLeft:
#		isInT2F = true
#	elif doTier2 and doUp:
#		if charState == "vampire":
#			charState = "bat"
#			run_speed = 500
#			jump_speed = -1000
#			sprintMod = 1.25
#			walkMod = 0.5
#			ACCELERATION = 1500
#			gravity = 1500
#			frictionMu = 200
#			weight = 5.0
#			jumps += 2
#		elif charState == "bat":
#			charState = "vampire"
#			run_speed = 350
#			jump_speed = -800 #negative numbers make player go up
#			sprintMod = 1.25
#			walkMod = 0.5
#			ACCELERATION = 1500
#			gravity = 2500
#			frictionMu = 100
#			weight = 10.0
#			jumps -= 2
#		print(charState)
#	elif doTier2 and doDown:
#		isInT2D = true

# warning-ignore:unused_argument
func _physics_process(delta):
	#Set inputs
	doRight = Input.is_action_pressed(right)
	doLeft = Input.is_action_pressed(left)
	doUp = Input.is_action_pressed(up)
	doDown = Input.is_action_pressed(down)
	doJump = Input.is_action_pressed(jump)
	doDownPRESSED = Input.is_action_just_pressed(down)
	doDownRELEASED = Input.is_action_just_released(down)
	doJumpPRESSED = Input.is_action_just_pressed(jump)
	doJumpRELEASED = Input.is_action_just_released(jump)
	doTier1 = Input.is_action_just_pressed(tier1)
	doTier2 = Input.is_action_just_pressed(tier2)
	doTier3 = Input.is_action_just_pressed(tier3)
	_doPageUp = Input.is_action_pressed(pageUp)
	_doPageDown = Input.is_action_pressed(pageDown)
	doRage = Input.is_action_pressed(rage)
	doShield1 = Input.is_action_pressed(shield1)
	doShield2 = Input.is_action_pressed(shield2)
	
	if isInT2N:
		T2N(delta)
#	if isInLag:
#		lagTimer -= delta
#		self.velocity.x = 0
#		velocity.y += gravity * delta
#		if lagTimer <= 0:
#			isInLag = false
#			lagTimer = 0
	elif doShield1:
		pass
	elif isInShield2:
		pass
	elif isInT2F:
		T2F()
	elif isInT2D:
		T2D()
	elif isInAD:
		AD()
	elif isInT3D:
		T3D()
	elif isInT3U:
		T3U()
	elif isInT3F:
		T3F()
		velocity.x = 0

	else:
		#friction code
		if not is_on_floor():
			frictionMod = 3
		else:
			frictionMod = 1
		velocity.y += gravity * delta
		var friction = frictionMu * weight * delta / frictionMod
		if velocity.x > 0:
			var frictionDone = velocity.x - friction
			
			if frictionDone < 0:
				frictionDone = 0
			velocity.x = frictionDone
		elif velocity.x < 0:
			var frictionDone = velocity.x + friction
			
			if frictionDone > 0:
				frictionDone = 0
			velocity.x = frictionDone

		if velocity.x < run_speed * -1:
			velocity.x = run_speed * -1
			
		if velocity.x > run_speed:
			velocity.x = run_speed
			
		get_input(delta)
	velocity = move_and_slide(velocity, Vector2(0, -1))
	#move_and_slide(velocity, Vector2(0, -1))
	if not visibility.is_on_screen():
		stats.notifyRespawned(thisPlayerNumber)
		position.x = startposx
		position.y = startposy
		velocity.x = 0
		lagTimer = 0
		isInLag = false

#hit code
func _on_T1D_body_entered(body):
	if body != self and body.get_name() != "Ground" and body.get_name() != "Platform":
		body.hit(body, 4, 3, 2)
		lagTimer = 1
		isInLag = true

func _on_T1U_body_entered(body):
	if body != self and body.get_name() != "Ground" and body.get_name() != "Platform":
		body.hit(body, 13, 6, 15)
		lagTimer = 0.3
		isInLag = true

func _on_T1N_body_entered(body):
	if body != self and body.get_name() != "Ground" and body.get_name() != "Platform":
		body.hit(body, 3, 4, 1)
		lagTimer = 0.2
		isInLag = true

func _on_T1F_body_entered(body):
	if body != self and body.get_name() != "Ground" and body.get_name() != "Platform":
		body.hit(body, 8, 6, 2)
		lagTimer = 0.7
		isInLag = true

func _on_T2F_body_entered(body):
	if body != self and body.get_name() != "Ground" and body.get_name() != "Platform":
		body.hit(body, 21, 5, 10)
	if body != self:
		body.commandGrab()
		self.velocity = Vector2.ZERO
		T2FTimer = -100

func _on_T3U_body_entered(body):
	if body != self and body.get_name() != "Ground" and body.get_name() != "Platform":
		body.hit(body, 20, 1, 15)
		lagTimer = 1.5
		isInLag = true

func _on_T3D_body_entered(body):
	if body != self and body.get_name() != "Ground" and body.get_name() != "Platform":
		body.hit(body, 13, 0, -7)
		lagTimer = 2
		isInLag = true

func _on_AN_body_entered(body):
	if body != self and body.get_name() != "Ground" and body.get_name() != "Platform":
		body.hit(body, 6, 0, 0)
		lagTimer = 0.2
		isInLag = true

func _on_AF_body_entered(body):
	if body != self and body.get_name() != "Ground" and body.get_name() != "Platform":
		body.hit(body, 6, 6, -1)
		lagTimer = 0.3
		isInLag = true

func _on_AU_body_entered(body):
	if body != self and body.get_name() != "Ground" and body.get_name() != "Platform":
		body.hit(body, 14, 1, 7)
		lagTimer = 0.4
		isInLag = true

func _on_AD_body_entered(body):
	if body != self and body.get_name() != "Ground" and body.get_name() != "Platform":
		body.hit(body, 15, 0, 0)
		lagTimer = 0.4
		isInLag = true

func _on_AB_body_entered(body):
	if body != self and body.get_name() != "Ground" and body.get_name() != "Platform":
		body.hit(body, 17, -10, 4)
		lagTimer = 1
		isInLag = true

func _on_BlockCounter_body_entered(body):
	if body != self and body.get_name() != "Ground" and body.get_name() != "Platform":
		body.hit(body, 1, 5, 5)

func _on_inputManager_Circle24T1():
	print("Circle24T1")

func _on_inputManager_Circle24T2():
	print("Circle24T2")

func _on_inputManager_Circle24T3():
	print("Circle24T3")

func _on_inputManager_Circle26T1():
	print("Circle26T1")

func _on_inputManager_Circle26T2():
	print("Circle26T2")

func _on_inputManager_Circle26T3():
	print("Circle26T3")

func _on_inputManager_Circle426T1():
	print("Circle426T1")

func _on_inputManager_Circle426T2():
	print("Circle426T2")

func _on_inputManager_Circle426T3():
	print("Circle426T3")

func _on_inputManager_Circle624T1():
	print("Circle624T1")

func _on_inputManager_Circle624T2():
	print("Circle624T2")

func _on_inputManager_Circle624T3():
	print("Circle624T3")
