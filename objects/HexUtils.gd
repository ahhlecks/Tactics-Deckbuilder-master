extends Spatial

# direction[0] = E
# direction[1] = SE
# direction[2] = SW
# direction[3] = W
# direction[4] = NW
# direction[5] = NE
const directions:Array = [
	Vector3(1,-1,0), Vector3(1,0,-1), Vector3(0,1,-1), 
	Vector3(-1,1,0), Vector3(-1,0,1), Vector3(0,-1,1), 
]

static func cubeDirection(direction):
	return directions[direction]

static func cubeNeighbor(cube, direction):
	return (cube + cubeDirection(direction))

static func cubeToAxial(cube:Vector3):
	var x = cube.x
	var y = cube.z
	return Vector2(x,y)

static func axialToCube(axial:Vector2):
	var x = axial.x
	var z = axial.y
	var y = -x-z
	return Vector3(x,y,z)

static func axialToCubeFloat(axial:Vector2):
	var x:float = axial.x
	var z:float = axial.y
	var y:float = -x-z
	return Vector3(x,y,z)

static func cubeToOddR(cube:Vector3):
# warning-ignore:narrowing_conversion
	var col:float = cube.x + (float(cube.z) - oddROffset(cube.z)) / 2
	var row:float = cube.z
	return Vector2(col, row)

static func cubeToOddRFloat(cube:Vector3):
# warning-ignore:narrowing_conversion
	var col:float = cube.x + (float(cube.z) - oddROffset(cube.z)) / 2
	var row:float = cube.z
	return Vector2(col, row)

static func oddRToCube(oddR:Vector2):
# warning-ignore:narrowing_conversion
	var x = oddR.x - (oddR.y - oddROffset(oddR.y)) / 2
	var z = oddR.y
	var y = -x-z
	return Vector3(x,y,z)

static func axialToPixel(axial:Vector2,size):
	var x = size * (sqrt(3) * axial.x +  sqrt(3)/2 * axial.y)
	var y = size * (                         3.0/2 * axial.y)
	return Vector2(x, y)

static func oddRToPixel(oddR:Vector2,size):
# warning-ignore:narrowing_conversion
	var x = (size * sqrt(3)) * (oddRToCube(oddR).x + 0.5 * oddROffset(oddR.y))
	var y = size * oddR.y * 3 / 2
	return Vector2(x, y)

static func oddROffset(y:int):
	var offset:int
	if int(y) % 2 == 0:
		offset = 0
	else:
		offset = 1
	return offset

static func pixelToHex(point:Vector2, size):
	var q = (sqrt(3)/3 * point.x  -  1.0/3 * point.y) / size
	var r = (                        2.0/3 * point.y) / size
	return hexRound(Vector2(q,r))
	

static func cubeRound(cube:Vector3):
	var rx = round(cube.x)
	var ry = round(cube.y)
	var rz = round(cube.z)

	var x_diff:float = abs(rx - cube.x)
	var y_diff:float = abs(ry - cube.y)
	var z_diff:float = abs(rz - cube.z)

	if x_diff > y_diff and x_diff > z_diff:
		rx = -ry-rz
	elif y_diff > z_diff:
		ry = -rx-rz
	else:
		rz = -rx-ry
	return Vector3(rx, ry, rz)

static func hexRound(hex:Vector2):
	return cubeToAxial(cubeRound(axialToCubeFloat(hex)))
