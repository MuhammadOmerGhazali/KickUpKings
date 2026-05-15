# DataManager.gd
extends Node

const SAVE_PATH = "user://kickup_save.res"
const LEADERBOARD_CACHE_PATH = "user://leaderboard_cache.res"
const ENCRYPTION_PASS = "kickupthesavefile"

var save_data: SaveData
var leaderboard_cache: LeaderboardCache

func _ready() -> void:
	load_game()
	load_leaderboard_cache()

# --- Core Saving/Loading Logic ---

func save_game() -> void:
	var file = FileAccess.open_encrypted_with_pass(SAVE_PATH, FileAccess.WRITE, ENCRYPTION_PASS)
	if file:
		# ADDED 'true' HERE to allow saving objects
		file.store_var(save_data, true) 
		file.close()
		print("Game Saved! Highscore: ", save_data.high_score) # Helpful for debugging
	else:
		push_error("Failed to save game data!")

func load_game() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open_encrypted_with_pass(SAVE_PATH, FileAccess.READ, ENCRYPTION_PASS)
		if file:
			# ADDED 'true' HERE to allow loading objects
			var data = file.get_var(true) 
			
			if data is SaveData:
				save_data = data
				print("Save loaded! Highscore: ", save_data.high_score) # Helpful for debugging
				return
			else:
				push_warning("Save file found, but data is corrupted or outdated. Creating new save.")
	
	print("No save found. Creating new save.")
	save_data = SaveData.new()

# --- Helper Functions for Gameplay ---

func add_coins(amount: int) -> void:
	save_data.coins += amount
	save_game()

func update_high_score(new_score: int) -> bool:
	if new_score > save_data.high_score:
		save_data.high_score = new_score
		upload_score_to_silentwolf()
		save_game()
		return true
	return false

func unlock_skin(index: int) -> void:
	if not save_data.unlocked_skins.has(index):
		save_data.unlocked_skins.append(index)
		save_game()

func unlock_ball(index: int) -> void:
	if not save_data.unlocked_balls.has(index):
		save_data.unlocked_balls.append(index)
		save_game()

func unlock_shoes(index: int) -> void:
	if not save_data.unlocked_shoes.has(index):
		save_data.unlocked_shoes.append(index)
		save_game()

func unlock_place(index: int) -> void:
	if not save_data.unlocked_places.has(index):
		save_data.unlocked_places.append(index)
		save_game()



func load_leaderboard_cache():
	if FileAccess.file_exists(LEADERBOARD_CACHE_PATH):
		leaderboard_cache = ResourceLoader.load(LEADERBOARD_CACHE_PATH)
	else:
		leaderboard_cache = LeaderboardCache.new()

func save_leaderboard_cache(scores_array: Array):
	var simplified_scores = []
	for s in scores_array:
		simplified_scores.append({"player_name": s.player_name, "score": s.score})
	
	leaderboard_cache.top_scores = simplified_scores
	ResourceSaver.save(leaderboard_cache, LEADERBOARD_CACHE_PATH)

func upload_score_to_silentwolf():
	var p_name = save_data.player_name
	var p_score = save_data.high_score
	
	if p_name == "" or p_name == null:
		print("Cannot upload: Player name is empty")
		return

	print("Uploading to SilentWolf...")
	# This sends the score to the server
	await SilentWolf.Scores.save_score(p_name, p_score).sw_save_score_complete
	print("Upload Successful!")

func get_player_name() ->String:
	return save_data.player_name

func set_player_name(new_name : String) -> void:
	save_data.player_name = new_name
	save_game()
