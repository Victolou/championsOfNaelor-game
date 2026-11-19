class_name ChampionFactory
extends RefCounted


# Instancia un campeón a partir de su escena y su recurso de datos.
# El padre se asigna antes de initialize para garantizar que los componentes
# y las referencias @onready de Entity ya estén disponibles.
static func create_champion(
	champion_scene: PackedScene,
	champion_data: ChampionData,
	parent: Node,
	grid_manager: GridManager,
	red_team: bool,
	projectile_manager: ProjectileManager
) -> Entity:
	if champion_scene == null:
		push_error("ChampionFactory: falta asignar la escena del campeón.")
		return null

	if champion_data == null:
		push_error("ChampionFactory: falta asignar ChampionData.")
		return null

	if parent == null:
		push_error("ChampionFactory: hace falta un nodo padre.")
		return null

	if grid_manager == null:
		push_error("ChampionFactory: falta GridManager.")
		return null

	if projectile_manager == null:
		push_error("ChampionFactory: falta ProjectileManager.")
		return null

	var champion_instance: Node = champion_scene.instantiate()
	var champion: Entity = champion_instance as Entity

	if champion == null:
		champion_instance.free()
		push_error("ChampionFactory: la escena debe tener un nodo raíz que herede de Entity.")
		return null

	champion.champion_data = champion_data
	parent.add_child(champion)
	champion.initialize(grid_manager, red_team, projectile_manager)

	return champion
