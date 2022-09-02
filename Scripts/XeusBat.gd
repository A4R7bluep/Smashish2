extends KinematicBody2D

#movement variables
export var run_speed = 500
export var jump_speed = -1000 #negative numbers make player go up
export var sprintMod = 1.25
export var walkMod = 0.5
const ACCELERATION = 1500
var frictionMod

#physics variables
export var gravity = 1500
export var frictionMu = 200
export var weight = 5.0

var direction = 0

var velocity = Vector2()

onready var animationPlayer = $AnimationPlayer
onready var labelChooser = $LabelChooser
onready var stats = $PlayerStats
onready var visibility = $VisibilityNotifier2D
onready var hurtbox = $Hurtbox
onready var position2D = $Position2D
onready var sprite = $Sprite

onready var vampire = load("res://Scenes/Xeus.tscn")
onready var world = get_parent()

var jumps = 3

var right = "false"
var left = "false"
var jump = "false"
var down = "false"
var up = "false"
var tier1 = "false"
var tier2 = "false"
var tier3 = "false"
var pageUp = "false"
var pageDown = "false"

onready var startposx = position.x
onready var startposy = position.y

var thisPlayerNumber = -1

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
		pageUp = "ui_page_up"
		pageDown = "ui_page_down"
	if right == "false":
		push_error("controlls are false")
#	print(right)
#	print(left)
#	print(jump)
#	print(attack)

func set_boxes():
	self.hurtbox.set_collision_layer_bit(thisPlayerNumber + 3, 1)
#	self.hitbox.set_collision_mask_bit(thisPlayerNumber + 3, 0)
#	self.hitbox2.set_collision_mask_bit(thisPlayerNumber + 3, 0)

func get_input(delta):
	var doRight = Input.is_action_pressed(right)
	var doLeft = Input.is_action_pressed(left)
	var doUp = Input.is_action_pressed(up)
	var doDown = Input.is_action_pressed(down)
	var doJump = Input.is_action_pressed(jump)
	var doDownPressed = Input.is_action_just_pressed(down)
	var doDownReleased = Input.is_action_just_released(down)
	var doJumpPressed = Input.is_action_just_pressed(jump)
	var doJumpReleased = Input.is_action_just_released(jump)
	var doTier1 = Input.is_action_just_pressed(tier1)
	var doTier2 = Input.is_action_just_pressed(tier2)
	var doTier3 = Input.is_action_just_pressed(tier3)
	var _doPageUp = Input.is_action_pressed(pageUp)
	var _doPageDown = Input.is_action_pressed(pageDown)
	
	if Input.is_action_pressed("ui_end"): #for testing purposes
		stats.health += 1
	
	#going through platforms
	if doJumpPressed:
		self.set_collision_layer_bit(1, 0)
	if doJumpReleased:
		self.set_collision_layer_bit(1, 1)
	if doDownPressed:
		self.set_collision_layer_bit(1, 0)
	if doDownReleased:
		self.set_collision_layer_bit(1, 1)
	
	#general movement
	if doJumpPressed and not jumps <= 0:
		velocity.y = jump_speed
		jumps -= 1

	#Walk
	if is_on_floor() and not doJump:
		if doRight:
			velocity.x += ACCELERATION * delta
			direction = 0
		elif doLeft:
			velocity.x -= ACCELERATION * delta
			direction = 1
			
		if doTier2 and not doRight and not doLeft and not doUp and not doDown:
			print("Move not finished")
		elif doTier2 and doRight or doTier2 and doLeft:
			animationPlayer.play("T2F")
		elif doTier2 and doUp:
			var vampireInst = vampire.instance()
			#batInst.setDirection(self, direction)
			world.add_child(vampireInst)
			self.queue_free()
		elif doTier2 and doDown:
			print("Move not finished")

	if not is_on_floor():
	#Aerials
		if doTier1 and not doRight and not doLeft and not doUp and not doDown:
			animationPlayer.play("AN")
		elif doTier1 and doRight and direction == 0 or doTier1 and doLeft and direction == 1:
			animationPlayer.play("AF")
		elif doTier1 and doUp:
			animationPlayer.play("AU")
		elif doTier1 and doDown:
			animationPlayer.play("AD")
		elif doTier1 and doRight and direction == 1 or doTier1 and doLeft and direction == 0:
			animationPlayer.play("AB")

		if doRight:
			velocity.x += ACCELERATION * delta
		if doLeft:
			velocity.x -= ACCELERATION * delta
	if doRight:
		position2D.scale.x = 1
		sprite.scale.x = -0.25
		direction = 0
	if doLeft:
		position2D.scale.x = -1
		sprite.scale.x = 0.25
		direction = 1

# warning-ignore:unused_argument
func _physics_process(delta):
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
		velocity.y = 0
	

#hit code
func _on_Hurtbox_area_entered(area):
	if area.get_parent().get_name() == "Position2D" or not area.get_parent().shooterNumber == self.thisPlayerNumber:
		var damageDone = Global.getDamage(area.get_name())
		var knockX = Global.getKnockX(area.get_name())
		var knockY = Global.getKnockY(area.get_name())
		if stats.health + damageDone >= 999:
			stats.health = 999
		else:
			stats.health += damageDone
			world.SoundPlayer.play()
			if area.global_position < self.position:
				velocity.x += knockX * stats.health / (weight * 0.2)
				velocity.y -= knockY * stats.health / (weight * 0.2)
			else:
				velocity.x -= knockX * stats.health / (weight * 0.2)
				velocity.y -= knockY * stats.health / (weight * 0.2)
#			print("TesterPlayer Velocity: " + str(velocity.x))
