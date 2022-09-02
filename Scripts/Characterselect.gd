extends Control

onready var button = $Button
onready var button2 = $Button2
onready var playbutton = $PlayButton

#var player1 = null
#var player2 = null

func _ready():
	button.text = "Set Player to Player1"
	button2.text = "Set Dummy to Player2"
	playbutton.text = "PLAY"
	button.connect("pressed", self, "_button_pressed")
	button2.connect("pressed", self, "_button2_pressed")
	playbutton.connect("pressed", self, "_playbutton_pressed")

func _button_pressed():
	print('_button_pressed()')
	Global.playerNumbers[0] = "TesterPlayer" #sets Player1 to TesterPlayer
	#print("player #1 is: " + str(player1))
	print(Global.playerNumbers)

func _button2_pressed():
	print('_button2_pressed()')
	Global.playerNumbers[1] = "Dummy" #sets player2 to Dummy
	#print("player #2 is: " + str(player2))
	print(Global.playerNumbers)

func _playbutton_pressed():
# warning-ignore:return_value_discarded
	Global.playerNumbers[0] = "Xeus"
	Global.playerNumbers[1] = "TesterPlayer"
	Global.playerNumbers[2] = "Dummy"
	get_tree().change_scene("res://Scenes/World.tscn")
#	get_current_scene().add_child(self)

func _process(delta):
	if Input.is_action_pressed("ui_accept"):
		Global.playerNumbers[0] = "Xeus"
		Global.playerNumbers[1] = "TesterPlayer"
		Global.playerNumbers[2] = "Dummy"
		get_tree().change_scene("res://Scenes/World.tscn")
