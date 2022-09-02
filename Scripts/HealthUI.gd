extends Control

#setting variables
var max_hearts = 999

onready var label = load("res://Scenes/HealthInfo.tscn")
onready var player_playerstats = null
onready var dummy_playerstats = null

onready var labelNumbers = len(Global.playerNumbers)

var deathsNeeded = len(Global.playerNumbers) - 1
#end settng variables

var labels = {}
var players = {}

func _ready():
	make_labels()

#dynamically making health UI for players
func make_labels():
	for i in range(labelNumbers):
		var myLabel = label.instance()
		myLabel.labelNumber = i
		self.add_child(myLabel)
		labels["label" + str(i)] = get_node(str(i))
#		set_meta("label" + str(i), get_node(str(i)))
#		print(get_meta("label" + str(i)))

#dynamically making player variables
func get_players():
	for i in range(labelNumbers):
		players["player" + str(i)] = get_node("/root/World/player" + str(i))
#		set_meta("player" + str(i), get_node("/root/World/player" + str(i)))

#setting the HP and STOCKS for players
func set_health(_value):
	for i in range(labelNumbers):
		var currentPlayer = players["player" + str(i)]
		var currentPlayerStats = currentPlayer.stats
		var currentLabel = labels["label" + str(i)]
		if currentPlayerStats != null:
			if currentLabel != null and currentPlayer != null:
				currentLabel.text = "HP = " + str(currentPlayer.stats.health) + "\nStocks = " + str(currentPlayer.stats.stocks)
			else:
				print("Current Label or Player is null")
		else:
			if currentPlayerStats != null:
				currentPlayerStats.connect("health_changed", self, "set_health")
				currentPlayerStats.connect("no_stocks", self, "no_stocks")

#Checking for end of game
func no_stocks():
	deathsNeeded -= 1
	if deathsNeeded <= 0:
		get_tree().change_scene("res://Scenes/GameOver.tscn")

#running the set health function every frame
func _process(_delta):
	#set_health(0)
	pass
