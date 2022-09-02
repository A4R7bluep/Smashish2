extends KinematicBody2D

var velocity = Vector2()

onready var aniPlay = $AnimationPlayer
onready var hitbox = $Hitbox

var timer = 3
var charge = 0
var direction = -1
var shooterNumber
var shooter

func setVars(owner, directionS, T3FCharge):
	shooter = owner
	shooterNumber = owner.thisPlayerNumber
	direction = directionS
	charge = T3FCharge
	position.x = shooter.position.x
	position.y = shooter.position.y

func _physics_process(_delta):
	velocity = move_and_slide(velocity, Vector2(0, -1))
	if direction == 0:
		velocity.x = 20
	elif direction == 1:
		velocity.x = -20
	timer -= _delta
	if timer <= 0:
		velocity.x = 0
		if charge == 1:
#			hitbox.damage = 6
#			hitbox.knockX = 3
#			hitbox.knockY = 3
			aniPlay.play("Explode1")
		if charge == 2:
#			hitbox.damage = 10
#			hitbox.knockX = 6
#			hitbox.knockY = 6
			aniPlay.play("Explode2")
		if charge == 3:
#			hitbox.damage = 15
#			hitbox.knockX = 9
#			hitbox.knockY = 9
			aniPlay.play("Explode3")

func die():
	queue_free()

func _on_Hitbox_body_entered(body):
	if charge == 1:
		if body != shooter and body.get_name() != "Ground" and body.get_name() != "Platform":
			body.hit(body, 6, 3, 3)
	if charge == 2:
		if body != shooter and body.get_name() != "Ground" and body.get_name() != "Platform":
			body.hit(body, 10, 6, 6)
	if charge == 3:
		if body != shooter and body.get_name() != "Ground" and body.get_name() != "Platform":
			body.hit(body, 15, 9, 9)
