class_name ChampionData
extends Resource

@export var display_name: String
@export_multiline var description: String
@export var portrait: Texture2D
@export var stats: CharacterStats
@export var skills: Array[Skill] = []
@export var passive_ability: PassiveAbility
