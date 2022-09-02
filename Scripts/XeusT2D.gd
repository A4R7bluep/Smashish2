extends KinematicBody2D

var timer = 5
var shooterNumber
var target
var targetOBJ
var world
var isReady = false
var velocity = Vector2()
const batVelNorm = 100

onready var hitbox = $Hitbox

func _ready():
	self.hitbox.set_collision_mask_bit(shooterNumber + 3, 0)

func hit(body, Sdamage, SknockX, SknockY):
	if body != self and body.get_name() != "Ground" and body.get_name() != "Platform" and body.get_name() != "player" + str(shooterNumber):
		var damageDone = Sdamage
		var knockX = SknockX
		var knockY = SknockY
		
		if body.stats.health + damageDone >= 999:
			body.stats.health = 999
		else:
			body.stats.health += damageDone
			world.SoundPlayer.play()
			if body.global_position > self.position:
				body.velocity.x += knockX * body.stats.health / (body.weight * 0.2)
				body.velocity.y -= knockY * body.stats.health / (body.weight * 0.2)
			else:
				body.velocity.x -= knockX * body.stats.health / (body.weight * 0.2)
				body.velocity.y -= knockY * body.stats.health / (body.weight * 0.2)

func setVars(sentPlayerNumber, sentWorld):
	shooterNumber = sentPlayerNumber
	world = sentWorld
	chooseTarget()

func chooseTarget():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var targetNum = rng.randi_range(0, Global.playerNumbers.size() - 1)
	if targetNum == shooterNumber:
		chooseTarget()
	else:
		target = "player" + str(targetNum)
		targetOBJ = world.get_node(target)
		isReady = true

func _physics_process(delta):
	velocity = move_and_slide(velocity, Vector2(0, 0))
	if isReady:
		var direction = (targetOBJ.position - self.position)
		velocity = direction.normalized() * batVelNorm
	timer -= delta
	if timer <= 1:
		queue_free()


func _on_Hitbox_body_entered(body):
	if body.get_name() != "player" + str(shooterNumber) and body.get_name() != "Ground" and body.get_name() != "Platform":
		hit(body, 2, 0, 0)
