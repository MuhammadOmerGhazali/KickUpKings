extends Control

@onready var list = $TextureRect/TextureRect/ScrollContainer/ScoreList
@onready var my_score_label = $"TextureRect/TextureRect/my rank/HBoxContainer/score"
@onready var my_rank_label = $"TextureRect/TextureRect/my rank/HBoxContainer/TextureRect/rank"
@onready var rank_container = $"TextureRect/TextureRect/my rank"

var row_scene = preload("res://Assets/leaderboard/leader_board_row.tscn")

func _ready():
	print("Leaderboard script running")

	# 1. Setup SilentWolf
	SilentWolf.configure({
		"api_key": "fxepuBliX74t2a15POEtS4wzewVAMbhH8rJ1diqd",
		"game_id": "soccergame1",
		"log_level": 1
	})

	# 2. Load Local Data Immediately (Responsive UI)
	DataManager.load_leaderboard_cache()
	
	# Show player's local highscore while we wait for the server
	#my_score_label.text = str(DataManager.save_data.high_score)
	my_score_label.text = str(DataManager.leaderboard_cache.cached_player_score)
	my_rank_label.text = str(DataManager.leaderboard_cache.cached_player_rank)
	$"TextureRect/TextureRect/my rank/HBoxContainer/Name".text = DataManager.get_player_name()
	
	# Build the list from cache if it exists
	if DataManager.leaderboard_cache.top_scores.size() > 0:
		print("Displaying cached leaderboard...")
		build_leaderboard(DataManager.leaderboard_cache.top_scores)
	
	# 3. Sync with Server in the background
	sync_leaderboard_data()

# -----------------------------
# DATA SYNCING (OFFLINE PROOF)
# -----------------------------
func sync_leaderboard_data():
	var p_name = DataManager.save_data.player_name
	
	# 1. If we have a local score but might not be on the server yet, 
	# let's try to upload it once just in case.
	if DataManager.save_data.high_score > 0:
		await DataManager.upload_score_to_silentwolf()

	# 2. Now ask for the player's scores
	var sw_result = await SilentWolf.Scores.get_scores_by_player(p_name, 0).sw_get_player_scores_complete
	
	if sw_result != null and sw_result.scores.size() > 0:
		var top_score_obj = sw_result.scores[0]
		my_score_label.text = str(int(top_score_obj.score))
		
		# 3. Use the score value instead of score_id (often more reliable for position)
		#var pos_result = await SilentWolf.Scores.get_score_position(top_score_obj.score).sw_get_position_complete
		var pos_result = await SilentWolf.Scores.get_score_position(top_score_obj.score_id).sw_get_position_complete
		
		if pos_result != null:
			my_rank_label.text = str(pos_result.position)
			# Cache player data
			DataManager.leaderboard_cache.cached_player_rank = str(pos_result.position)
			DataManager.leaderboard_cache.cached_player_score = int(top_score_obj.score)

			# Save cache
			#DataManager.save_leaderboard_cache(
			#DataManager.leaderboard_cache.top_scores	)
		else:
			my_rank_label.text = " "
	else:
		my_rank_label.text = " "

	load_leaderboard_online()

func load_leaderboard_online():
	print("Fetching fresh leaderboard from SilentWolf...")
	# Fetch top 100
	var sw_result = await SilentWolf.Scores.get_scores(100).sw_get_scores_complete

	if sw_result != null and sw_result.scores.size() > 0:
		# Update the local cache file
		DataManager.save_leaderboard_cache(sw_result.scores)
		# Refresh UI with fresh data
		build_leaderboard(sw_result.scores)
	else:
		print("Network error: Staying with cached data.")

# -----------------------------
# UI BUILDING
# -----------------------------
func build_leaderboard(scores):
	# Clear existing rows
	for child in list.get_children():
		child.queue_free()

	print("Building leaderboard UI with ", scores.size(), " entries.")

	for i in range(scores.size()):
		var row = row_scene.instantiate()
		
		# Note: We use .get() because cached data is a Dictionary, 
		# but SilentWolf data is an Object. This handles both.
		var p_name = scores[i].player_name if "player_name" in scores[i] else scores[i].get("player_name", "Unknown")
		var p_score = scores[i].score if "score" in scores[i] else scores[i].get("score", 0)

		row.get_node("bg/TextureRect/position").text = str(i + 1)
		row.get_node("bg/name").text = str(p_name)
		row.get_node("bg/score").text = str(int(p_score))

		list.add_child(row)


func _on_label_text_submitted(new_text: String) -> void:
	if new_text.strip_edges() != "":
		DataManager.set_player_name(new_text)
		DataManager.save_game()
		# Hide the keyboaupscale this to 4k dont change aspect ratio or add or remove elementsrd
		$"../StartMenu/Name/Label".release_focus()
	$"../StartMenu/Name".visible =false
