extends Node

var max_health = 999
onready var health = 0 setget set_health
onready var stocks = 3

signal health_changed(value)

func set_health(value):
	health = value
	emit_signal("health_changed", health)

func notifyRespawned(_playerNumber):
	stocks -= 1
	health = 0
	emit_signal("health_changed", stocks)
	if stocks <= 0:
		get_node("/root/World/HealthUI").no_stocks()
