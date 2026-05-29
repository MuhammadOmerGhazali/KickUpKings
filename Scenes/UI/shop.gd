extends Control

class_name  ShopUi
@export var main :Main
@export var ui_manager :UIManager

# price labels
@onready var very_tiny_label = $Fade/CoinpackBackRect/CoinPacks/TopRow/verytinypack/VeryTinyButton/Label
@onready var tiny_label = $Fade/CoinpackBackRect/CoinPacks/TopRow/tinypack/TinyButton/Label
@onready var small_label = $Fade/CoinpackBackRect/CoinPacks/TopRow/smallpack/SmallButton/Label
@onready var medium_label = $Fade/CoinpackBackRect/CoinPacks/BottomRow/mediumpack/MediumButton/Label
@onready var large_label = $Fade/CoinpackBackRect/CoinPacks/BottomRow/largepack/LargeButton/Label
@onready var very_large_label = $Fade/CoinpackBackRect/CoinPacks/BottomRow/verylargepack/VeryLargeButton/Label

func _ready() -> void:
	IapStoreManager.coins_awarded.connect(_on_iap_coins_awarded)
	IapStoreManager.ads_removed.connect(_on_iap_ads_removed)
	IapStoreManager.prices_loaded.connect(_on_iap_prices_loaded)

func _on_iap_prices_loaded(prices: Dictionary) -> void:
	if prices.has("com.kickupkings.kickupkings.verytinycoinpack"):
		very_tiny_label.text = prices["com.kickupkings.kickupkings.verytinycoinpack"]
		
	if prices.has("com.kickupkings.kickupkings.tinycoinpack"):
		tiny_label.text = prices["com.kickupkings.kickupkings.tinycoinpack"]
		
	if prices.has("com.kickupkings.kickupkings.smallcoinpack"):
		small_label.text = prices["com.kickupkings.kickupkings.smallcoinpack"]
		
	if prices.has("com.kickupkings.kickupkings.mediumcoinpack"):
		medium_label.text = prices["com.kickupkings.kickupkings.mediumcoinpack"]
		
	if prices.has("com.kickupkings.kickupkings.largecoinpack"):
		large_label.text = prices["com.kickupkings.kickupkings.largecoinpack"]
		
	if prices.has("com.kickupkings.kickupkings.verylargecoinpack"):
		very_large_label.text = prices["com.kickupkings.kickupkings.verylargecoinpack"]
		
func _on_reward_add_button_pressed() -> void:
	give_reward()
	
func give_reward() -> void:
	var success: bool = AdManager.show_rewarded_ad()
	if success:
		await get_tree().create_timer(0.2).timeout
		main.add_coins(50)
		ui_manager.reward_msg()
	if !success:
		print("Ad not available")
		ui_manager._ad_failed()
		
func reward_success() -> void:
	print("reward coin given")
	main.add_coins(50)
	
func _on_iap_coins_awarded(amount: int) -> void:
	print("IAP reward received: granting ", amount, " coins.")
	main.add_coins(amount)
	ui_manager.reward_msg()

func _on_iap_ads_removed() -> void:
	pass
	
func _on_very_tiny_button_pressed() -> void:
#	IapStoreManager.buy_item("com.kickupkings.kickupkings.verytinycoinpack")
	IapStoreManager.buy_item("android.test.purchased")

func _on_tiny_button_pressed() -> void:
	IapStoreManager.buy_item("com.kickupkings.kickupkings.tinycoinpack")

func _on_small_button_pressed() -> void:
	IapStoreManager.buy_item("com.kickupkings.kickupkings.smallcoinpack") 

func _on_medium_button_pressed() -> void:
	IapStoreManager.buy_item("com.kickupkings.kickupkings.mediumcoinpack")

func _on_large_button_pressed() -> void:
	IapStoreManager.buy_item("com.kickupkings.kickupkings.largecoinpack")

func _on_very_large_button_pressed() -> void:
	IapStoreManager.buy_item("com.kickupkings.kickupkings.verylargecoinpack")
