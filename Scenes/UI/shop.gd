extends Control

class_name  ShopUi
@export var main :Main
@export var ui_manager :UIManager



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
	
	
