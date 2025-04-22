extends Node3D
class_name TerrainGenerator

### CONFIGURACIÓN PRINCIPAL ###
@export var size: Vector2 = Vector2(1000, 1000)
@export var max_height: float = 60.0
@export var mesh_resolution: int = 2
@export var smoothness: float = 0.5

### MATERIAL DEL TERRENO ###
@export var terrain_material: Material = preload("res://procedural_terrain/materials/terrain_material.tres")

### VEGETACIÓN ###
@export var tree_scene: PackedScene = preload("res://assets/tree.tscn")
@export var grass_scene: PackedScene = preload("res://assets/grass.tscn")
@export var tree_count: int = 100
@export var grass_density: float = 0.5

### CONFIGURACIÓN DE RUIDO ###
@export var noise: FastNoiseLite
@export var frequency: float = 0.008
@export var noise_seed: int = 0

### RESTRICCIONES DE VEGETACIÓN ###
@export var min_veg_height: float = 0.5
@export var max_tree_slope: float = 0.25
@export var max_grass_slope: float = 0.35

func _ready():
	_setup_noise()
	generate_terrain()

func _setup_noise():
	if noise == null:
		noise = FastNoiseLite.new()
	
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	noise.frequency = frequency
	noise.fractal_octaves = 3
	noise.fractal_gain = 0.3
	noise.seed = noise_seed if noise_seed != 0 else randi()

func generate_terrain():
	### 1. CONFIGURAR MALLA BASE ###
	var plane_mesh = PlaneMesh.new()
	plane_mesh.size = size
	plane_mesh.subdivide_width = size.x * mesh_resolution
	plane_mesh.subdivide_depth = size.y * mesh_resolution
	plane_mesh.material = terrain_material  # Asignar material personalizado

	### 2. GENERAR GEOMETRÍA ###
	var surface = SurfaceTool.new()
	surface.create_from(plane_mesh, 0)
	
	var mesh_data = surface.commit()
	var data_tool = MeshDataTool.new()
	data_tool.create_from_surface(mesh_data, 0)
	
	### 3. APLICAR RUIDO ###
	for i in range(data_tool.get_vertex_count()):
		var vertex = data_tool.get_vertex(i)
		var noise_value = noise.get_noise_2d(vertex.x * 0.5, vertex.z * 0.5)
		vertex.y = smoothstep(0.0, 1.0, abs(noise_value)) * max_height * smoothness
		data_tool.set_vertex(i, vertex)
	
	### 4. RECONSTRUIR MALLA ###
	mesh_data.clear_surfaces()
	data_tool.commit_to_surface(mesh_data)
	
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	surface.create_from(mesh_data, 0)
	surface.generate_normals()
	
	### 5. CREAR TERRENO FINAL ###
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.mesh = surface.commit()
	mesh_instance.create_trimesh_collision()
	
	# Asegurar que el material se mantiene
	mesh_instance.mesh.surface_set_material(0, terrain_material)
	
	add_child(mesh_instance)

	### 6. GENERAR VEGETACIÓN ###
	generate_vegetation(mesh_instance)

func generate_vegetation(terrain: MeshInstance3D):
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	# Contenedores organizados
	var trees_parent = Node3D.new()
	trees_parent.name = "Trees"
	add_child(trees_parent)
	
	var grass_parent = Node3D.new()
	grass_parent.name = "Grass"
	add_child(grass_parent)
	
	### GENERAR ÁRBOLES ###
	for i in range(tree_count):
		var pos = find_valid_spot(rng, max_tree_slope)
		if pos:
			var tree = tree_scene.instantiate()
			trees_parent.add_child(tree)
			tree.global_position = pos
			tree.rotation.y = rng.randf_range(0, TAU)
			tree.scale = Vector3.ONE * rng.randf_range(0.9, 1.1)
	
	### GENERAR HIERBA ###
	for i in range(tree_count * 10 * grass_density):
		var pos = find_valid_spot(rng, max_grass_slope)
		if pos:
			var grass = grass_scene.instantiate()
			grass_parent.add_child(grass)
			grass.global_position = pos
			grass.rotation.y = rng.randf_range(0, TAU)
			grass.scale = Vector3.ONE * rng.randf_range(0.8, 1.2)

func find_valid_spot(rng: RandomNumberGenerator, max_slope: float) -> Vector3:
	for _attempt in range(50):
		var pos = Vector3(
			rng.randf_range(-size.x/2, size.x/2),
			0,
			rng.randf_range(-size.y/2, size.y/2)
		)
		pos.y = get_height_at(pos.x, pos.z)
		
		if pos.y > min_veg_height and _get_slope_at(pos) < max_slope:
			return pos
	return Vector3.ZERO

func _get_slope_at(pos: Vector3) -> float:
	var sample_dist = 1.0
	var h_x = get_height_at(pos.x + sample_dist, pos.z) - get_height_at(pos.x - sample_dist, pos.z)
	var h_z = get_height_at(pos.x, pos.z + sample_dist) - get_height_at(pos.x, pos.z - sample_dist)
	return Vector2(h_x, h_z).length() / (sample_dist * 2)

func get_height_at(x: float, z: float) -> float:
	var noise_value = noise.get_noise_2d(x * 0.5, z * 0.5)
	return smoothstep(0.0, 1.0, abs(noise_value)) * max_height * smoothness

func smoothstep(edge0: float, edge1: float, x: float) -> float:
	x = clamp((x - edge0) / (edge1 - edge0), 0.0, 1.0)
	return x * x * (3.0 - 2.0 * x)
