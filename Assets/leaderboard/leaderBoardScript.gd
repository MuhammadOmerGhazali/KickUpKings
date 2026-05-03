extends Control

@onready var list = $TextureRect/TextureRect/ScrollContainer/ScoreList
@onready var my_score = $"TextureRect/TextureRect/my rank/HBoxContainer/score"
@onready var my_rank = $"TextureRect/TextureRect/my rank/HBoxContainer/rank"
@onready var Rank_container = $"TextureRect/TextureRect/my rank"
var row_scene = preload("res://Scenes/leader_board_row.tscn")


func _ready():
	print("Leaderboard script running")

	SilentWolf.configure({
		"api_key": "fxepuBliX74t2a15POEtS4wzewVAMbhH8rJ1diqd",
		"game_id": "soccergame1",
		"log_level": 1
	})

	#await SilentWolf.Scores.save_score("Salman", 20)
	#await SilentWolf.Scores.save_score("ali", 200)
	#await SilentWolf.Scores.save_score("usman", 50)
	#await SilentWolf.Scores.save_score("asad", 300)
	#await SilentWolf.Scores.save_score("afan", 120)
	#await SilentWolf.Scores.save_score("asghar", 400)
	#await SilentWolf.Scores.save_score("juniad", 120)
	#await SilentWolf.Scores.save_score("sarab", 120)
	#await SilentWolf.Scores.save_score("sqib", 230)
	#await SilentWolf.Scores.save_score("baby", 170)
	#await SilentWolf.Scores.save_score("Omer", 500)
	var sw_result = await SilentWolf.Scores.get_scores_by_player("asad",0).sw_get_player_scores_complete

	var player_scores = sw_result.scores
	print(player_scores)
	my_score.text = str(player_scores[0].score)
	#var score_data = player_scores[0] 

	#var player_score = int(player_scores[0].score)
	#var pos_result = await SilentWolf.Scores.get_score_position(player_scores[0].score).sw_get_position_complete
	var pos_result = await SilentWolf.Scores.get_score_position(player_scores[0].score_id).sw_get_position_complete

	var rank = pos_result.position
	#if(rank<=12):
		#Rank_container.visible = false
	
	my_rank.text = "My # : " + str(rank)
	
	
	await get_tree().create_timer(1.0).timeout

	load_leaderboard()


# -----------------------------
# LOAD LEADERBOARD (OFFICIAL METHOD)
# -----------------------------
func load_leaderboard():
	print("Fetching leaderboard...")

	var sw_result = await SilentWolf.Scores.get_scores(0).sw_get_scores_complete
	#var sw_result = await SilentWolf.Scores.get_scores()
	#print("RAW RESULT:", sw_result)

	if sw_result == null:
		print("No data received")
		return

	var scores = sw_result.scores

	if scores == null or scores.size() == 0:
		print("Empty leaderboard")
		return

	build_leaderboard(scores)


# -----------------------------
# UI
# -----------------------------
func build_leaderboard(scores):

	for child in list.get_children():
		child.queue_free()

	print("Building leaderboard:", scores.size())

	for i in range(scores.size()):
		var row = row_scene.instantiate()

		var pos_label = row.get_node("bg/TextureRect/position")
		var name_label = row.get_node("bg/name")
		var score_label = row.get_node("bg/score")

		pos_label.text = str(i + 1)
		#print(pos_label.text)
		name_label.text = scores[i].player_name
		score_label.text = str(int(scores[i].score))

		list.add_child(row)
