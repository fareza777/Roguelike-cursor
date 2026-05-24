extends Node
## Global event bus — decouple systems for long-term maintenance.

signal player_damaged(amount: float, source: Node)
signal enemy_damaged(enemy: Node, amount: float, source: Node)
signal enemy_killed(enemy: Node, killer: Node)
signal item_picked_up(item_data: Dictionary)
signal room_cleared
signal run_started
signal run_ended(victory: bool)
signal gold_changed(amount: int)
signal floor_changed(floor_num: int)
