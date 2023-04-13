extends Node

enum Side {
	FRONT,
	RIGHT,
	BACK,
	LEFT,
	BOTTOM,
	TOP,
}

const TRIANGLE_VERTEX_COUNT: int = 3
const FACE_TRIANGLE_COUNT: int = 2

const FACE_VERTEX_COUNT: int = (
		TRIANGLE_VERTEX_COUNT * FACE_TRIANGLE_COUNT
)

const SIDE_VERTEX_COUNT: int = 4

var sides_vertices: Array[PackedVector3Array] = [
	PackedVector3Array([
		Vector3(0, 0, 0),
		Vector3(1, 0, 0),
		Vector3(1, 1, 0),
		Vector3(0, 1, 0),
	]),

	PackedVector3Array([
		Vector3(1, 0, 0),
		Vector3(1, 0, 1),
		Vector3(1, 1, 1),
		Vector3(1, 1, 0),
	]),

	PackedVector3Array([
		Vector3(1, 0, 1),
		Vector3(0, 0, 1),
		Vector3(0, 1, 1),
		Vector3(1, 1, 1),
	]),

	PackedVector3Array([
		Vector3(0, 0, 1),
		Vector3(0, 0, 0),
		Vector3(0, 1, 0),
		Vector3(0, 1, 1),
	]),

	PackedVector3Array([
		Vector3(0, 0, 1),
		Vector3(1, 0, 1),
		Vector3(1, 0, 0),
		Vector3(0, 0, 0),
	]),

	PackedVector3Array([
		Vector3(0, 1, 0),
		Vector3(1, 1, 0),
		Vector3(1, 1, 1),
		Vector3(0, 1, 1),
	]),
]

var vertices_indices: Array[int] = [
	0, 1, 3,
	1, 2, 3,
]

var sides_normals: Array[Vector3] = [
	Vector3(0, 0, -1),
	Vector3(1, 0, 0),
	Vector3(0, 0, 1),
	Vector3(-1, 0, 0),
	Vector3(0, -1, 0),
	Vector3(0, 1, 0),
]
