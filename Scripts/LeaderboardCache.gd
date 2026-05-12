# LeaderboardCache.gd
extends Resource
class_name LeaderboardCache

# We store scores as an Array of Dictionaries to make saving/loading simple
@export var top_scores: Array = [] 
@export var last_updated: String = ""
