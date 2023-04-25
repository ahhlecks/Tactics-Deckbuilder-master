const outerRadius:float = 1.0
const innerRadius:float = outerRadius * 0.866025404
const outerRadius2:float = 1.0 * .8
const innerRadius2:float = (outerRadius * 0.866025404) * .8
const center:float = outerRadius * 0.5 
const height:float = 1.0

var corner12:Vector3 = Vector3(-innerRadius, height, 0.5 * outerRadius)
var uvcorner12:Vector2 = Vector2(-innerRadius + center , (0.5 * outerRadius) + center)
var corner11:Vector3 = Vector3(-innerRadius, 0, 0.5 * outerRadius)
var corner10:Vector3 = Vector3(-innerRadius, height, -0.5 * outerRadius)
var uvcorner10:Vector2 = Vector2(-innerRadius + center, -0.5 * outerRadius + center)
var corner9:Vector3 = Vector3(-innerRadius, 0, -0.5 * outerRadius)
var corner8:Vector3 = Vector3(0, height, -outerRadius)
var uvcorner8:Vector2 = Vector2(center, -outerRadius + center)
var corner7:Vector3 = Vector3(0, 0, -outerRadius)
var corner6:Vector3 = Vector3(innerRadius, height, -0.5 * outerRadius)
var uvcorner6:Vector2 = Vector2(innerRadius+center, (-0.5 * outerRadius)+center)
var corner5:Vector3 = Vector3(innerRadius, 0, -0.5 * outerRadius)
var corner4:Vector3 = Vector3(innerRadius, height, 0.5 * outerRadius)
var uvcorner4:Vector2 = Vector2(innerRadius + center, (0.5 * outerRadius)+center)
var corner3:Vector3 = Vector3(innerRadius, 0, 0.5 * outerRadius)
var corner2:Vector3 = Vector3(0, height, outerRadius)
var uvcorner2:Vector2 = Vector2(center, outerRadius+center)
var corner1:Vector3 = Vector3(0, 0, outerRadius)
var topMid:Vector3 = Vector3(0, height, 0)

var inner_corner12:Vector3 = Vector3(-innerRadius2, height, 0.5 * outerRadius2)
var uvinner_corner12:Vector2 = Vector2(-innerRadius2 + center , (0.5 * outerRadius2) + center)
var inner_corner11:Vector3 = Vector3(-innerRadius2, 0, 0.5 * outerRadius2)
var inner_corner10:Vector3 = Vector3(-innerRadius2, height, -0.5 * outerRadius2)
var uvinner_corner10:Vector2 = Vector2(-innerRadius2 + center, -0.5 * outerRadius2 + center)
var inner_corner9:Vector3 = Vector3(-innerRadius2, 0, -0.5 * outerRadius2)
var inner_corner8:Vector3 = Vector3(0, height, -outerRadius2)
var uvinner_corner8:Vector2 = Vector2(center, -outerRadius2 + center)
var inner_corner7:Vector3 = Vector3(0, 0, -outerRadius2)
var inner_corner6:Vector3 = Vector3(innerRadius2, height, -0.5 * outerRadius2)
var uvinner_corner6:Vector2 = Vector2(innerRadius2+center, (-0.5 * outerRadius2)+center)
var inner_corner5:Vector3 = Vector3(innerRadius2, 0, -0.5 * outerRadius2)
var inner_corner4:Vector3 = Vector3(innerRadius2, height, 0.5 * outerRadius2)
var uvinner_corner4:Vector2 = Vector2(innerRadius2 + center, (0.5 * outerRadius2)+center)
var inner_corner3:Vector3 = Vector3(innerRadius2, 0, 0.5 * outerRadius2)
var inner_corner2:Vector3 = Vector3(0, height, outerRadius2)
var uvinner_corner2:Vector2 = Vector2(center, outerRadius2+center)
var inner_corner1:Vector3 = Vector3(0, 0, outerRadius2)

var corners:PoolVector3Array = [corner1, corner2, corner3, corner4, corner5, corner6, corner7, corner8, corner9, corner10, corner11, corner12, corner1, corner2]
#bottom surface
var triangle1 = [Vector3.ZERO, corner1, corner3]
var uvtriangle1 = [Vector2(center,center), uvcorner2, uvcorner4]
var triangle2 = [Vector3.ZERO, corner3, corner5]
var uvtriangle2 = [Vector2(center,center), uvcorner4, uvcorner6]
var triangle3 = [Vector3.ZERO, corner5, corner7]
var uvtriangle3 = [Vector2(center,center), uvcorner6, uvcorner8]
var triangle4 = [Vector3.ZERO, corner7, corner9]
var uvtriangle4 = [Vector2(center,center), uvcorner8, uvcorner10]
var triangle5 = [Vector3.ZERO, corner9, corner11]
var uvtriangle5 = [Vector2(center,center), uvcorner10, uvcorner12]
var triangle6 = [Vector3.ZERO, corner11, corner1]
var uvtriangle6 = [Vector2(center,center), uvcorner12, uvcorner2]
var bottom_surface = [triangle1, triangle2, triangle3, triangle4, triangle5, triangle6]
var uv_bottom_surface = [uvtriangle2, uvtriangle4, uvtriangle3, uvtriangle4, uvtriangle5, uvtriangle6]
var bottom_surface_fan:PoolVector3Array = [Vector3.ZERO, corner1, corner3, corner5, corner7, corner9, corner11, corner1]
var uvbottom_surface_fan:PoolVector2Array = [Vector2(center,center), uvcorner2, uvcorner4, uvcorner6, uvcorner8, uvcorner10, uvcorner12, uvcorner2]

#top surface
var triangle19 = [topMid, corner4, corner2]
var uv_triangle19 = [Vector2(center,center), uvcorner4, uvcorner2]
var triangle20 = [topMid, corner6, corner4]
var uv_triangle20 = [Vector2(center,center), uvcorner6, uvcorner4]
var triangle21 = [topMid, corner8, corner6]
var uv_triangle21 = [Vector2(center,center), uvcorner8, uvcorner6]
var triangle22 = [topMid, corner10, corner8]
var uv_triangle22 = [Vector2(center,center), uvcorner10, uvcorner8]
var triangle23 = [topMid, corner12, corner10]
var uv_triangle23 = [Vector2(center,center), uvcorner12, uvcorner10]
var triangle24 = [topMid, corner2, corner12]
var uv_triangle24 = [Vector2(center,center), uvcorner2, uvcorner12]

var top_rim_surface = [
inner_corner2, corner2, inner_corner12, 
corner2, corner12, inner_corner12,

inner_corner12, corner12, inner_corner10,
corner12, corner10, inner_corner10,

inner_corner10, corner10, inner_corner8,
corner10, corner8, inner_corner8,

inner_corner8, corner8, inner_corner6,
corner8, corner6, inner_corner6,

inner_corner6, corner6, inner_corner4,
corner6, corner4, inner_corner4,

inner_corner4, corner4, inner_corner2,
corner4, corner2, inner_corner2]
var top_surface = [triangle19, triangle20, triangle21, triangle22, triangle23, triangle24]
var uv_top_surface = [uv_triangle19, uv_triangle20, uv_triangle21, uv_triangle22, uv_triangle23, uv_triangle24]
var top_surface_loop:PoolVector3Array = [corner2, corner4, corner6, corner8, corner10, corner12, corner2]
var top_surface_fan:PoolVector3Array = [topMid, corner12, corner10, corner8, corner6, corner4, corner2, corner12]
var uv_top_surface_fan:PoolVector2Array = [Vector2(center,center), uvcorner12, uvcorner10, uvcorner8, uvcorner6, uvcorner4, uvcorner2, uvcorner12]
var normal_surface_fan:PoolVector3Array = [Vector3(0,1,0), Vector3(0,1,0), Vector3(0,1,0), Vector3(0,1,0), Vector3(0,1,0), Vector3(0,1,0), Vector3(0,1,0), Vector3(0,1,0)]
var normal_bottom_surface_fan:PoolVector3Array = [Vector3(0,-1,0), Vector3(0,-1,0), Vector3(0,-1,0), Vector3(0,-1,0), Vector3(0,-1,0), Vector3(0,-1,0), Vector3(0,-1,0), Vector3(0,-1,0)]

#side surfaces
var triangle7 = [corner1, corner2, corner3]
var triangle8 = [corner3, corner2, corner4]
var triangle9 = [corner3, corner4, corner5]
var triangle10 = [corner5, corner4, corner6]
var triangle11 = [corner5, corner6, corner7]
var triangle12 = [corner7, corner6, corner8]
var triangle13 = [corner7, corner8, corner9]
var triangle14 = [corner9, corner8, corner10]
var triangle15 = [corner9, corner10, corner11]
var triangle16 = [corner11, corner10, corner12]
var triangle17 = [corner11, corner12, corner1]
var triangle18 = [corner1, corner12, corner2]
var side_surfaces = [triangle7, triangle8, triangle9, triangle10, triangle11, triangle12, triangle13, triangle14, triangle15, triangle16, triangle17, triangle18]

var side_surface1:PoolVector3Array = [corner1, corner2, corner3, corner2, corner4, corner3]
var side_surface1_strip:PoolVector3Array = [corner1, corner2, corner3, corner4]
var midpoint_side1:Vector3 = Vector3.ZERO.direction_to((corner1 + corner3) / 2) 
var normal_side_surface1:PoolVector3Array = [midpoint_side1, midpoint_side1, midpoint_side1, midpoint_side1]
var side_surface2:PoolVector3Array = [corner3, corner4, corner5, corner4, corner6, corner5]
var side_surface2_strip:PoolVector3Array = [corner3, corner4, corner5, corner6]
var midpoint_side2:Vector3 = Vector3.ZERO.direction_to((corner3 + corner5) / 2)
var normal_side_surface2:PoolVector3Array = [midpoint_side2, midpoint_side2, midpoint_side2, midpoint_side2]
var side_surface3:PoolVector3Array = [corner5, corner6, corner7, corner6, corner8, corner7]
var side_surface3_strip:PoolVector3Array = [corner5, corner6, corner7, corner8]
var midpoint_side3:Vector3 = Vector3.ZERO.direction_to((corner5 + corner7) / 2)
var normal_side_surface3:PoolVector3Array = [midpoint_side3, midpoint_side3, midpoint_side3, midpoint_side3]
var side_surface4:PoolVector3Array = [corner7, corner8, corner9, corner8, corner10, corner9]
var side_surface4_strip:PoolVector3Array = [corner7, corner8, corner9, corner10]
var midpoint_side4:Vector3 = Vector3.ZERO.direction_to((corner7 + corner9) / 2)
var normal_side_surface4:PoolVector3Array = [midpoint_side4, midpoint_side4, midpoint_side4, midpoint_side4]
var side_surface5:PoolVector3Array = [corner9, corner10, corner11, corner10, corner12, corner11]
var side_surface5_strip:PoolVector3Array = [corner9, corner10, corner11, corner12]
var midpoint_side5:Vector3 = Vector3.ZERO.direction_to((corner9 + corner11) / 2)
var normal_side_surface5:PoolVector3Array = [midpoint_side5, midpoint_side5, midpoint_side5, midpoint_side5]
var side_surface6:PoolVector3Array = [corner11, corner12, corner1, corner12, corner2, corner1]
var side_surface6_strip:PoolVector3Array = [corner11, corner12, corner1, corner2]
var midpoint_side6:Vector3 = Vector3.ZERO.direction_to((corner11 + corner1) / 2)
var normal_side_surface6:PoolVector3Array = [midpoint_side6, midpoint_side6, midpoint_side6, midpoint_side6]
var uv_side_surface:PoolVector2Array = [Vector2(0,1), Vector2(0,0), Vector2(1,1), Vector2(0,0), Vector2(1,0), Vector2(1,1)]
