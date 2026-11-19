class_name ChampionRegistry
extends Resource

@export var champions: Array[ChampionData] = []


# Busca un campeón por su identificador estable.
func get_champion_by_id(champion_id: String) -> ChampionData:
	var normalized_id: String = champion_id.strip_edges().to_lower()

	if normalized_id.is_empty():
		return null

	for champion: ChampionData in champions:
		if champion == null:
			continue

		if champion.champion_id.strip_edges().to_lower() == normalized_id:
			return champion

	return null


# Devuelve una copia de la lista para evitar modificar el registro accidentalmente.
func get_all_champions() -> Array[ChampionData]:
	return champions.duplicate()


func get_champion_count() -> int:
	return champions.size()


# Comprueba recursos nulos, identificadores repetidos y datos incompletos.
func get_validation_errors() -> PackedStringArray:
	var errors: PackedStringArray = []
	var registered_ids: Dictionary = {}

	for index in range(champions.size()):
		var champion: ChampionData = champions[index]

		if champion == null:
			errors.append("ChampionRegistry: la entrada %d está vacía." % (index + 1))
			continue

		var champion_id: String = champion.champion_id.strip_edges().to_lower()

		if champion_id.is_empty():
			errors.append("ChampionRegistry: el campeón '%s' no tiene identificador." % champion.display_name)
		elif registered_ids.has(champion_id):
			errors.append("ChampionRegistry: identificador duplicado '%s'." % champion_id)
		else:
			registered_ids[champion_id] = true

		var champion_errors: PackedStringArray = champion.get_validation_errors()

		for validation_error: String in champion_errors:
			errors.append("%s: %s" % [champion.display_name, validation_error])

	return errors


func is_valid() -> bool:
	return get_validation_errors().is_empty()
