# SaveData.gd
extends Resource
class_name SaveData

@export var player_id: String = ""
@export var player_name: String = ""

@export_group("Stats")
@export var high_score: int = 0
@export var coins: int = 0


@export_group("Character Customization")
@export var current_skin_index: int = 0
@export var unlocked_skins: Array[int] = [0] 

@export_group("Ball Customization")
@export var current_ball_index: int = 0
@export var unlocked_balls: Array[int] = [0] 

@export_group("Shoe Customization")
@export var current_shoe_index: int = 0
@export var unlocked_shoes: Array[int] = [0]

@export_group("Place Customization")
@export var current_place_index: int = 0
@export var unlocked_places: Array[int] = [0]
