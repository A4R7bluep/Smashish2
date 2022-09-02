extends KinematicBody2D

#physics variables
var gravity = 2500
var frictionMu = 100
var weight = 10.0
var frictionMod

var velocity = Vector2()

onready var labelChooser = $LabelChooser
onready var stats = $PlayerStats
onready var visibility = $VisibilityNotifier2D
onready var hurtbox = $HurtBox

onready var startposx = position.x
onready var startposy = position.y

onready var world = get_parent()

var thisPlayerNumber = -2

func _init():
	position.x = 200
	position.y = 100


func _ready():
	set_boxes()
	set_name("player" + str(thisPlayerNumber))
	if thisPlayerNumber == 2:
		position.x = 300

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
	hurtbox.set_collision_layer_bit(thisPlayerNumber + 3, 1)

func _physics_process(delta):
	velocity.y += gravity * delta
	var friction = frictionMu * weight * delta
	if not is_on_floor():
		frictionMod = 3
	else:
		frictionMod = 1
	if velocity.x > 0:
		velocity.x -= friction / frictionMod
		velocity.x = max(velocity.x, 0)
	elif velocity.x < 0:
		velocity.x += friction / frictionMod
		velocity.x = min(velocity.x, 0)
	velocity = move_and_slide(velocity, Vector2(0, -1))
	if not visibility.is_on_screen():
		stats.notifyRespawned(thisPlayerNumber)
		position.x = startposx
		position.y = startposy
		velocity.x = 0

# warning-ignore:unused_argument
#func _on_Hitbox_area_entered(area):
#	var damageDone = area.damage
#	var knockX = area.knockX
#	var knockY = area.knockY
#	if stats.health + damageDone >= 999:
#		stats.health = 999
#	else:
#		stats.health += damageDone
#		world.SoundPlayer.play()
#		if area.global_position < self.position:
#			velocity.x += knockX * stats.health / (weight * 0.2)
#			velocity.y -= knockY * stats.health / (weight * 0.2)
#		else:
#			velocity.x -= knockX * stats.health / (weight * 0.2)
#			velocity.y -= knockY * stats.health / (weight * 0.2)

func commandGrab():
	print(self, " grabbed")
