# DataManager.gd
extends Node

const SAVE_PATH = "user://kickup_save.res"
const ENCRYPTION_PASS = "kickupthesavefile"

var save_data: SaveData

func _ready() -> void:
	load_game()

# --- Core Saving/Loading Logic ---

func save_game() -> void:
	# 1. Open an encrypted file for writing
	var file = FileAccess.open_encrypted_with_pass(SAVE_PATH, FileAccess.WRITE, ENCRYPTION_PASS)
	if file:
		# 2. Store the resource data as a variable
		file.store_var(save_data)
		file.close()
	else:
		push_error("Failed to save game data!")

func load_game() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open_encrypted_with_pass(SAVE_PATH, FileAccess.READ, ENCRYPTION_PASS)
		if file:
			var data = file.get_var()
			if data is SaveData:
				save_data = data
				return
	
	# If no file exists or loading fails, initialize fresh data
	save_data = SaveData.new()

# --- Helper Functions for Gameplay ---

func add_coins(amount: int) -> void:
	save_data.coins += amount
	save_game()

func update_high_score(new_score: int) -> bool:
	if new_score > save_data.high_score:
		save_data.high_score = new_score
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
