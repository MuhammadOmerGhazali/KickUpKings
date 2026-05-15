# LeaderboardCache.gd
extends Resource
class_name LeaderboardCache

# Top leaderboard entries
@export var top_scores: Array = []

# Cache timestamp
@export var last_updated: String = ""

# NEW: Cached player info
@export var cached_player_rank: String = ""
@export var cached_player_score: int = 0
