extends KinematicBody2D

#movement variables
export var run_speed = 350
export var jump_speed = -800 #negative numbers make player go up
export var sprintMod = 1.25
export var walkMod = 0.5
const ACCELERATION = 1500
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
onready var visibility = $VisibilityNotifier2D
onready var animationPlayer2 = $AnimationPlayer2
onready var hurtbox = $Hurtbox
onready var hitbox = $Position2D/Hitbox
onready var hitbox2 = $Position2D/Hitbox2
onready var position2D = $Position2D

onready var testProjectile = load("res://Scenes/TestProjectile.tscn")
onready var world = get_parent()

var right = "false"
var left = "false"
var jump = "false"
var down = "false"
var attack = "false"
var attack2 = "false"
var pageUp = "false"
var pageDown = "false"

onready var startposx = position.x
onready var startposy = position.y

var thisPlayerNumber = -1

func _init():
	position.x = 100
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
		attack = "Player1_T1"
		attack2 = "Player1_T2"
		pageUp = "ui_page_up"
		pageDown = "ui_page_down"
	if thisPlayerNumber == 1:
		right = "Player2_Right"
		left = "Player2_Left"
		jump = "Player2_Jump"
		down = "Player2_Down"
		attack = "Player2_T1"
		attack2 = "Player2_T2"
		pageUp = "ui_page_up"
		pageDown = "ui_page_down"
	if right == "false":
		push_error("controlls are false")
#	print(right)
#	print(left)
#	print(jump)
#	print(attack)

func hit(body, Sdamage, SknockX, SknockY):
	if body.get_name() != "Ground" and body.get_name() != "Platform":
		var damageDone = Sdamage
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
	self.hitbox.set_collision_mask_bit(thisPlayerNumber + 3, 0)
	self.hitbox2.set_collision_mask_bit(thisPlayerNumber + 3, 0)

func get_input(delta):
	var doRight = Input.is_action_pressed(right)
	var doLeft = Input.is_action_pressed(left)
	var doJump = Input.is_action_pressed(jump)
	var doDownPressed = Input.is_action_just_pressed(down)
	var doDownReleased = Input.is_action_just_released(down)
	var doJumpPressed = Input.is_action_just_pressed(jump)
	var doJumpReleased = Input.is_action_just_released(jump)
	var doAttack = Input.is_action_just_pressed(attack)
	var doAttack2 = Input.is_action_just_pressed(attack2)
	var _doPageUp = Input.is_action_pressed(pageUp)
	var _doPageDown = Input.is_action_pressed(pageDown)
	var doDown = Input.is_action_pressed(down)
	
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
	if is_on_floor() and doJump:
		velocity.y = jump_speed
	if is_on_floor() and not doJump:
		if doRight:
			velocity.x += ACCELERATION * delta
			direction = 0
		if doLeft:
			velocity.x -= ACCELERATION * delta
			direction = 1
		if doRight and direction == 0:
			if doDown and doRight:
				if doDown:
					if doAttack:
						animationPlayer.play("HitRight")
		elif doLeft and doAttack:
			animationPlayer.play("HitLeft")
		if doAttack2:
			var projectileInst = testProjectile.instance()
			projectileInst.setDirection(self, direction)
			world.add_child(projectileInst)
	if not is_on_floor():
		if doRight:
			velocity.x += ACCELERATION * delta
		if doLeft:
			velocity.x -= ACCELERATION * delta
	if direction == 0:
		position2D.scale.x = 1
	if direction == 1:
		position2D.scale.x = -1

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

#hit code
#func _on_Hurtbox_area_entered(area):
#	if area.get_parent().get_parent().get_name() == "Position2D" or not area.get_parent().shooterNumber == self.thisPlayerNumber:
#		var damageDone = area.damage
#		var knockX = area.knockX
#		var knockY = area.knockY
#		if stats.health + damageDone >= 999:
#			stats.health = 999
#		else:
#			stats.health += damageDone
#			world.SoundPlayer.play()
#			if area.global_position < self.position:
#				velocity.x += knockX * stats.health / (weight * 0.2)
#				velocity.y -= knockY * stats.health / (weight * 0.2)
#			else:
#				velocity.x -= knockX * stats.health / (weight * 0.2)
#				velocity.y -= knockY * stats.health / (weight * 0.2)
#			print("TesterPlayer Velocity: " + str(velocity.x))

func commandGrab():
	print(self, " grabbed")


func _on_Hitbox_body_entered(body):
	if body != self and body.get_name() != "Ground" and body.get_name() != "Platform":
		body.hit(body, 7 , 4, 4)
