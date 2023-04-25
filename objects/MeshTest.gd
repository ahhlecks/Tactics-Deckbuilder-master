extends MeshInstance

var Topology = preload("res://objects/HexTopology.gd")

var world_coordinates:Vector3
var center:Vector3 = Vector3.ZERO
var mat = preload("res://resources/materials/grass.material")
var mat2 = preload("res://resources/materials/dirt_side.material")
var brown = Color("bd8f21")
var tempVertArray:PoolVector3Array
var tempUVArray:PoolVector2Array

# Called when the node enters the scene tree for the first time.
func _ready():
	#var startt = float(OS.get_ticks_msec())
	var topology = Topology.new()

	var st = SurfaceTool.new()
	var arr_mesh = ArrayMesh.new()
	var arrays = []

	#TOP
	#st.begin(Mesh.PRIMITIVE_TRIANGLES)
	#st.set_material(mat)
	#for s in topology.inner_uv_top_surface.size():
	#	for verts in range(3):
	#		st.add_uv(topology.inner_uv_top_surface[s][verts])
	#		st.add_uv2(topology.inner_uv_top_surface[s][verts])
	#		st.add_vertex(topology.inner_top_surface[s][verts])
	#for s in topology.outer_uv_top_surface.size():
	#	for verts in range(3):
	#		st.add_uv(topology.outer_uv_top_surface[s][verts])
	#		st.add_uv2(topology.outer_uv_top_surface[s][verts])
	#		st.add_vertex(topology.outer_top_surface[s][verts])
	#st.generate_normals()
	#st.generate_tangents()
	#st.commit(arr_mesh)
	#st.clear()
	
	#ResourceSaver.save("res://resources/HexagonTop.tres", mesh, 32)

	#Sides
	#st.begin(Mesh.PRIMITIVE_TRIANGLES)
	#st.set_material(mat2)
	#for s in topology.side_surfaces.size():
	#	for verts in range(3):
	#		st.add_uv(topology.uv_side_surfaces[s][verts])
	#		st.add_uv2(topology.uv_side_surfaces[s][verts])
	#		st.add_vertex(topology.side_surfaces[s][verts])
	#st.generate_normals()
	#st.generate_tangents()
	#st.commit(arr_mesh)
	#st.clear()

	#mesh = arr_mesh
	
	#ResourceSaver.save("res://resources/HexagonSideTest.tres", mesh, 32)

	#InnerSides
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_material(mat2)
	for s in topology.side_surfaces.size():
		for verts in topology.side_surfaces[s].size(): # Double-Sided Faces
			st.add_uv(topology.uv_side_surfaces[s][verts])
			st.add_uv2(topology.uv_side_surfaces[s][verts])
			st.add_vertex(topology.side_surfaces[s][verts])
	st.generate_normals()
	st.generate_tangents()
	st.commit(arr_mesh)
	st.clear()

	mesh = arr_mesh
	
	ResourceSaver.save("res://resources/hexagon/HexagonSideSW.tres", mesh, 32)

	#var endtt = float(OS.get_ticks_msec())
	#print("Execution time: %.2f" % ((endtt - startt)/1000))
