extends Node2D

onready var HealthUI = $HealthUI
onready var SoundPlayer = $AudioStreamPlayer

onready var Dummyscene = load("res://Scenes/Dummy.tscn")
onready var TesterPlayerscene = load("res://Scenes/TesterPlayer.tscn")
onready var XeuxBatscene = load("res://Scenes/XeusBat.tscn")
onready var Xeusscene = load("res://Scenes/Xeus.tscn")
onready var XeausScene = load("res://Scenes/Xeaus.tscn")

func _ready():
	for i in range(len(Global.playerNumbers)):
		var player = Global.playerNumbers[i]
		
		if player == "TesterPlayer":
			var myTesterPlayer = TesterPlayerscene.instance()
			myTesterPlayer.thisPlayerNumber = i
			self.add_child(myTesterPlayer)
			
		elif player == "Dummy":
			var myDummy = Dummyscene.instance()
			myDummy.thisPlayerNumber = i
			self.add_child(myDummy)
			
#		elif player == "XeusBat":
#			var myXeusBat = XeuxBatscene.instance()
#			myXeusBat.thisPlayerNumber = i
#			self.add_child(myXeusBat)

		elif player == "Xeus":
			var myXeus = Xeusscene.instance()
			myXeus.thisPlayerNumber = i
			self.add_child(myXeus)
			
		elif player == "Xeaus":
			var myXeaus = XeausScene.instance()
			myXeaus.thisPlayerNumber = i
			self.add_child(myXeaus)
		
		elif player == "Thing":
			pass
		
		else:
			push_error('Unknown player type: ' + str(player))
			
	#HealthUI.get_players()
