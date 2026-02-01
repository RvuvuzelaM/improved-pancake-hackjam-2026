extends Area2D

## The ability ID this pickup grants. Valid values: "d-jump", "dash", "ledge-grab"
@export var ability_id: String = "d-jump"

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	# Check if player already has this ability - hide if so
	if GameData.has_ability(ability_id):
		_hide_pickup()
	else:
		body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_collect()


func _collect() -> void:
	# Grant the ability to the player
	GameData.unlock_ability(ability_id)
	print("Ability unlocked: ", ability_id)

	# Hide the pickup
	_hide_pickup()


func _hide_pickup() -> void:
	visible = false
	collision.set_deferred("disabled", true)
