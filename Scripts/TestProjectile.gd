extends KinematicBody2D

onready var timer = $Timer
onready var visibility = $VisibilityNotifier2D

var velocity = Vector2()
var direction = -1
var shooter = null
var shooterNumber = null
var timeAliveSec = 0
const lifetimeSec = 3.0

#physics variables
export var gravity = 300
export var frictionMu = 50
export var weight = 1.0

func hit(body, Sdamage, SknockX, SknockY):
	velocity.x = velocity.x * -1

func setDirection(sender, sentDirection):
	Global.numOfProjectiles += 1
	shooter = sender
	position.x = shooter.position.x
	position.y = shooter.position.y
	direction = sentDirection
	shooterNumber = sender.thisPlayerNumber
	start()

func start():
	self.set_name("TestProjectile" + str(Global.numOfProjectiles))
	if direction == 0:
		velocity.x = 250 + shooter.velocity.x
	if direction == 1:
		velocity.x = -250 + shooter.velocity.x
	if direction == -1:
		push_error("Projectile direction undefined!")
	timeAliveSec = 0

func _process(delta):
	timeAliveSec += delta
	if timeAliveSec > lifetimeSec:
		queue_free()

	move_and_slide(velocity, Vector2(0, -1))
	velocity.y += gravity * delta
	var friction = frictionMu * weight * delta
	if velocity.x > 0:
		velocity.x -= friction
		velocity.x = max(velocity.x, 0)
	elif velocity.x < 0:
		velocity.x += friction
		velocity.x = min(velocity.x, 0)
	if is_on_floor():
		velocity.y = velocity.y * -1 * 0.8
		if velocity.y <= 1 and velocity.y > 0:
			velocity.y = 0
	if visibility.is_on_screen() == false:
		queue_free()


func _on_ProjectileHit_body_entered(body):
	if body != self and body != shooter and body.get_name() != "Ground" and body.get_name() != "Platform":
		body.hit(body, 10, 0, 0)
