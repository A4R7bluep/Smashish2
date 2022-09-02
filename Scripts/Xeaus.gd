extends KinematicBody2D

onready var ANIMATIONPLAYER = $AnimationPlayer
onready var LABELCHOOSER = $LabelChooser
onready var STATS = $PlayerStats
onready var HURTBOX = $Hurtbox
onready var SPRITE = $Sprite
onready var INPUT = $NewInputManager

# movement variables
export var WALK_SPEED = 200
export var RUN_SPEED = 400
export var JUMP_SPEED = -1000 # negative numbers make player go up
var facing = 1 # 1 if right, -1 if left
var dashTimer = 0.5

# physics variables
export var GRAVITY = 2500
export var FRICTIONMU = 200
export var WEIGHT = 5.0
export var AIRACCELERATION = 2000

# in move variables
export var in26L = false
export var in26MH = false
export var in24M = false 

# misc variables
var velocity = Vector2()
onready var world = get_parent()
var jumps = 1
var thisPlayerNumber = -1

# Direction states
var up = false
var down = false
var left = false
var right = false

# state machine
enum {
	IDLE,
	JUMP,
	RUN,
	WALK,
	CROUCH,
	ATTACK
}

export var state = IDLE

func _on_NewInputManager_Move5():
	up = false
	down = false
	left = false
	right = false
	
	if is_on_floor() and state != ATTACK:
		state = IDLE
		dashTimer = 0.5

func _on_NewInputManager_Move6():
	up = false
	down = false
	left = false
	right = true
	
	if state != ATTACK:
		state = WALK

func _on_NewInputManager_Move4():
	up = false
	down = false
	left = true
	right = false
	
	if state != ATTACK:
		state = WALK

func _on_NewInputManager_Move2():
	up = false
	down = true
	left = false
	right = false
	
	if state != ATTACK:
		state = CROUCH

func _on_NewInputManager_Move8():
	up = true
	down = false
	left = false
	right = false

func _on_NewInputManager_Move9():
	up = true
	down = false
	left = false
	right = true

func _on_NewInputManager_Move7():
	up = true
	down = false
	left = true
	right = false

func _on_NewInputManager_Dash(delta):
	if state != ATTACK:
		if dashTimer > 0 and not is_on_floor():
			state = RUN
			dashTimer -= delta
		elif is_on_floor():
			state = RUN
		else:
			state = IDLE

func movement_actions(delta):
	if state != ATTACK:
		if up:
			if not jumps <= 0:# and is_on_floor():
				velocity.y = JUMP_SPEED
				jumps -= 1
				state = JUMP
		
		if down:
			state = CROUCH
		
		# Walk / Run
		
		if left and (state == WALK or state == JUMP):
			velocity.x = -WALK_SPEED * facing
		elif left and state == RUN and is_on_floor():
			velocity.x = -RUN_SPEED * facing

		if right and (state == WALK or state == JUMP):
			velocity.x = WALK_SPEED * facing
		elif right and state == RUN and is_on_floor():
			velocity.x = RUN_SPEED * facing
		
		# Air Dash
		if not is_on_floor() and state == RUN:
			if facing == 1:
				if right:
					velocity.x += AIRACCELERATION * delta
					velocity.y = 0
				elif left:
					velocity.x -= AIRACCELERATION * delta
					velocity.y = 0
				else:
					velocity.x += AIRACCELERATION * facing * delta
					velocity.y = 0
			
			elif facing == -1:
				if right:
					velocity.x -= AIRACCELERATION * delta
					velocity.y = 0
				elif left:
					velocity.x += AIRACCELERATION * delta
					velocity.y = 0
				else:
					velocity.x += AIRACCELERATION * facing * delta
					velocity.y = 0
		
		# velocity clipping
		if velocity.x > 0:
			velocity.x = min(velocity.x, 500)
		elif velocity.x < 0:
			velocity.x = max(velocity.x, -500)

# Attack functions
func attacks(_delta):
	if in26L and is_on_floor():
		velocity.x = 600 * facing
		
	if in26MH and is_on_floor():
		velocity.x = 600 * facing
		
	if in24M and is_on_floor():
		velocity.x += 1000 * facing
		velocity.y -= 1000

# Movement Events
func _on_NewInputManager_T1():
	if state != ATTACK:
		if is_on_floor():
			ANIMATIONPLAYER.play("5L")

func _on_NewInputManager_T2():
	if state != ATTACK:
		if is_on_floor():
			ANIMATIONPLAYER.play("5M")

func _on_NewInputManager_T3():
	if state != ATTACK:
		if is_on_floor():
			pass

func _on_NewInputManager_Normal2T2():
	if state != ATTACK:
		ANIMATIONPLAYER.play("2M")

func _on_NewInputManager_Normal6T2():
	if state != ATTACK:
		ANIMATIONPLAYER.play("6M")

func _on_NewInputManager_Normal4T2():
	if state != ATTACK:
		ANIMATIONPLAYER.play("4M")

func _on_NewInputManager_Circle24T1():
	if state != ATTACK:
		pass

func _on_NewInputManager_Normal2T1():
	if state != ATTACK:
		ANIMATIONPLAYER.play("2L")

func _on_NewInputManager_Normal6T1():
	if state != ATTACK:
		ANIMATIONPLAYER.play("6L")

func _on_NewInputManager_Circle26T1():
	if state != ATTACK:
		ANIMATIONPLAYER.play("26L")

func _on_NewInputManager_Circle26T2():
	if state != ATTACK:
		ANIMATIONPLAYER.play("26M")

func _on_NewInputManager_Circle26T3():
	if state != ATTACK:
		ANIMATIONPLAYER.play("26H")

func _on_NewInputManager_Normal4T3():
	if state != ATTACK:
		ANIMATIONPLAYER.play("4H")

func _on_NewInputManager_Dp623T3():
	if state != ATTACK:
		pass # Replace with function body.

func _on_NewInputManager_Circle24T3():
	if state != ATTACK:
		ANIMATIONPLAYER.play("24H")

func _on_NewInputManager_Circle24T2():
	if state != ATTACK:
		ANIMATIONPLAYER.play("24M")


func _physics_process(delta):
#	print("directions: {}".format({"": [up, down, left, right]}))
#	match state:
#		IDLE:
#			print("State: Idle")
#		JUMP:
#			print("State: Jump")
#		RUN:
#			print("State: Run")
#		WALK:
#			print("State: Walk")
#		CROUCH:
#			print("State: Crouch")
#		ATTACK:
#			print("State: Attack")
	
	var friction = FRICTIONMU * WEIGHT * delta
	INPUT.facing = facing
	
	velocity.y += GRAVITY * delta
	
	movement_actions(delta)
	attacks(delta)
	
	# friction
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
	
	if is_on_floor():
		jumps = 1
	
	velocity = move_and_slide(velocity, Vector2(0, -1))

