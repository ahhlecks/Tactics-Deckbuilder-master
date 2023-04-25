const outerRadius:float = 1.0
const innerRadius:float = outerRadius * 0.866025404
const innerHexScale:float = .75
const outerRadius2:float = outerRadius * innerHexScale
const innerRadius2:float = (outerRadius * 0.866025404) * innerHexScale
const center:float = outerRadius * 0.5
const height:float = 1.0
const halfHeight:float = height/2

var uv_corner1:Vector2 = Vector2(-innerRadius + center , (0.5 * outerRadius) + center)
var corner1:Vector3 = Vector3(-innerRadius, 0, 0.5 * outerRadius)
var uv_corner2:Vector2 = Vector2(-innerRadius + center, -0.5 * outerRadius + center)
var corner2:Vector3 = Vector3(-innerRadius, 0, -0.5 * outerRadius)
var uv_corner3:Vector2 = Vector2(center, -outerRadius + center)
var corner3:Vector3 = Vector3(0, 0, -outerRadius)
var uv_corner4:Vector2 = Vector2(innerRadius+center, (-0.5 * outerRadius)+center)
var corner4:Vector3 = Vector3(innerRadius, 0, -0.5 * outerRadius)
var uv_corner5:Vector2 = Vector2(innerRadius + center, (0.5 * outerRadius)+center)
var corner5:Vector3 = Vector3(innerRadius, 0, 0.5 * outerRadius)
var uv_corner6:Vector2 = Vector2(center, outerRadius+center)
var corner6:Vector3 = Vector3(0, 0, outerRadius)
var middle:Vector3 = Vector3(0, 0, 0)

var inner_uv_corner1:Vector2 = Vector2(-innerRadius2 + center , (0.5 * outerRadius2) + center)
var inner_corner1:Vector3 = Vector3(-innerRadius2, 0, 0.5 * outerRadius2)
var inner_uv_corner2:Vector2 = Vector2(-innerRadius2 + center, -0.5 * outerRadius2 + center)
var inner_corner2:Vector3 = Vector3(-innerRadius2, 0, -0.5 * outerRadius2)
var inner_uv_corner3:Vector2 = Vector2(center, -outerRadius2 + center)
var inner_corner3:Vector3 = Vector3(0, 0, -outerRadius2)
var inner_uv_corner4:Vector2 = Vector2(innerRadius2+center, (-0.5 * outerRadius2)+center)
var inner_corner4:Vector3 = Vector3(innerRadius2, 0, -0.5 * outerRadius2)
var inner_uv_corner5:Vector2 = Vector2(innerRadius2 + center, (0.5 * outerRadius2)+center)
var inner_corner5:Vector3 = Vector3(innerRadius2, 0, 0.5 * outerRadius2)
var inner_uv_corner6:Vector2 = Vector2(center, outerRadius2+center)
var inner_corner6:Vector3 = Vector3(0, 0, outerRadius2)

var topLeft:Vector2 = Vector2(0,0)
var topRight:Vector2 = Vector2(1,0)
var bottomRight:Vector2 = Vector2(1,1)
var bottomLeft:Vector2 = Vector2(0,1)

#inner top surfaces

var triangle1 = [middle, inner_corner1, inner_corner2]
var uv_triangle1 = [Vector2(center,center), inner_uv_corner1, inner_uv_corner2]
var triangle2 = [middle, inner_corner2, inner_corner3]
var uv_triangle2 = [Vector2(center,center), inner_uv_corner2, inner_uv_corner3]
var triangle3 = [middle, inner_corner3, inner_corner4]
var uv_triangle3 = [Vector2(center,center), inner_uv_corner3, inner_uv_corner4]
var triangle4 = [middle, inner_corner4, inner_corner5]
var uv_triangle4 = [Vector2(center,center), inner_uv_corner4, inner_uv_corner5]
var triangle5 = [middle, inner_corner5, inner_corner6]
var uv_triangle5 = [Vector2(center,center), inner_uv_corner5, inner_uv_corner6]
var triangle6 = [middle, inner_corner6, inner_corner1]
var uv_triangle6 = [Vector2(center,center), inner_uv_corner6, inner_uv_corner1]

var inner_top_surface = [triangle1, triangle2, triangle3, triangle4, triangle5, triangle6]
var inner_uv_top_surface = [uv_triangle1, uv_triangle2, uv_triangle3, uv_triangle4, uv_triangle5, uv_triangle6]

# outer top surfaces

#  West                18 v    19 v         20 v
var triangle7 = [inner_corner1,corner1,inner_corner2]
var uv_triangle7 = [inner_uv_corner1,uv_corner1,inner_uv_corner2]
#  West                21 v    22 v    23 v
var triangle8 = [inner_corner2,corner1,corner2]
var uv_triangle8 = [inner_uv_corner2,uv_corner1,uv_corner2]
#  NW              24           25v
var triangle9 = [inner_corner2,corner2,inner_corner3]
var uv_triangle9 = [inner_uv_corner2,uv_corner2,inner_uv_corner3]
#  NW                           28 v    29 v
var triangle10 = [inner_corner3,corner2,corner3]
var uv_triangle10 = [inner_uv_corner3,uv_corner2,uv_corner3]
#  NE                           31 v
var triangle11 = [inner_corner3,corner3,inner_corner4]
var uv_triangle11 = [inner_uv_corner3,uv_corner3,inner_uv_corner4]
#  NE                           34 v    35 v
var triangle12 = [inner_corner4,corner3,corner4]
var uv_triangle12 = [inner_uv_corner4,uv_corner3,uv_corner4]
#  E                            37 v
var triangle13 = [inner_corner4,corner4,inner_corner5]
var uv_triangle13 = [inner_uv_corner4,uv_corner4,inner_uv_corner5]
#  E                            40 v    41 v
var triangle14 = [inner_corner5,corner4,corner5]
var uv_triangle14 = [inner_uv_corner5,uv_corner4,uv_corner5]
#  SE                           43 v
var triangle15 = [inner_corner5,corner5,inner_corner6]
var uv_triangle15 = [inner_uv_corner5,uv_corner5,inner_uv_corner6]
#  SE                           46 v    47 v
var triangle16 = [inner_corner6,corner5,corner6]
var uv_triangle16 = [inner_uv_corner6,uv_corner5,uv_corner6]
#  SW                           49 v
var triangle17 = [inner_corner6,corner6,inner_corner1]
var uv_triangle17 = [inner_uv_corner6,uv_corner6,inner_uv_corner1]
#  SW                           52 v    53 v
var triangle18 = [inner_corner1,corner6,corner1]
var uv_triangle18 = [inner_uv_corner1,uv_corner6,uv_corner1]

var outer_top_surface = [triangle7, triangle8, triangle9, triangle10,
 triangle11, triangle12, triangle13, triangle14,
 triangle15, triangle16, triangle17, triangle18,]
var outer_uv_top_surface = [uv_triangle7, uv_triangle8, uv_triangle9, uv_triangle10,
 uv_triangle11, uv_triangle12, uv_triangle13, uv_triangle14,
 uv_triangle15, uv_triangle16, uv_triangle17, uv_triangle18,]

#side surfaces
# W                1 v                                3 v
var triangle19 = [corner1, corner1 - Vector3(0,height,0), corner2]
var uv_triangle19 = [topRight, bottomRight, topLeft]
# W                4 v                                6 v
var triangle20 = [corner2, corner1 - Vector3(0,height,0), corner2 - Vector3(0,height,0)]
var uv_triangle20 = [topLeft, bottomRight, bottomLeft]
# NW               7 v                                9 v
var triangle21 = [corner2, corner2 - Vector3(0,height,0), corner3]
var uv_triangle21 = [topRight, bottomRight, topLeft]
# NW              10 v                               12 v
var triangle22 = [corner3, corner2 - Vector3(0,height,0), corner3 - Vector3(0,height,0)]
var uv_triangle22 = [topLeft, bottomRight, bottomLeft]
# NE              13 v                               15 v
var triangle23 = [corner3, corner3 - Vector3(0,height,0), corner4]
var uv_triangle23 = [topRight, bottomRight, topLeft]
# NE              16 v                               18 v
var triangle24 = [corner4, corner3 - Vector3(0,height,0), corner4 - Vector3(0,height,0)]
var uv_triangle24 = [topLeft, bottomRight, bottomLeft]
# E
var triangle25 = [corner4, corner4 - Vector3(0,height,0), corner5]
var uv_triangle25 = [topRight, bottomRight, topLeft]
# E
var triangle26 = [corner5, corner4 - Vector3(0,height,0), corner5 - Vector3(0,height,0)]
var uv_triangle26 = [topLeft, bottomRight, bottomLeft]
# SE
var triangle27 = [corner5, corner5 - Vector3(0,height,0), corner6]
var uv_triangle27 = [topRight, bottomRight, topLeft]
# SE
var triangle28 = [corner6, corner5 - Vector3(0,height,0), corner6 - Vector3(0,height,0)]
var uv_triangle28 = [topLeft, bottomRight, bottomLeft]
# SW
var triangle29= [corner6, corner6 - Vector3(0,height,0), corner1]
var uv_triangle29 = [topRight, bottomRight, topLeft]
# SW
var triangle30 = [corner1, corner6 - Vector3(0,height,0), corner1 - Vector3(0,height,0)]
var uv_triangle30 = [topLeft, bottomRight, bottomLeft]

var side_surfaces = [triangle29, triangle30]
var uv_side_surfaces = [uv_triangle19, uv_triangle20]

# 8 O'Clock
# Verts Down 0 - 5; Verts Up 6 - 11
var triangle31 = [#corner1, corner1 - Vector3(0,halfHeight,0), inner_corner1,
 #corner1, inner_corner1, corner1 - Vector3(0,halfHeight,0),]
 corner1, corner1 + Vector3(0,halfHeight,0), inner_corner1,
 corner1, inner_corner1, corner1 + Vector3(0,halfHeight,0)]
var uv_triangle31 = [#topRight, bottomRight, topLeft, topLeft, topRight, bottomLeft,]
 bottomRight, topRight, bottomLeft, bottomLeft, bottomRight, topLeft]

# 10 O'Clock
# Verts Down 12 - 17; Verts Up 18 - 23
var triangle32 = [#corner2, corner2 - Vector3(0,halfHeight,0), inner_corner2,
 #corner2, inner_corner2, corner2 - Vector3(0,halfHeight,0),]
 corner2, corner2 + Vector3(0,halfHeight,0), inner_corner2,
 corner2, inner_corner2, corner2 + Vector3(0,halfHeight,0)]

# 12 O'Clock
# Verts Down 24 - 29; Verts Up 30 - 35
var triangle33 = [#corner3, corner3 - Vector3(0,halfHeight,0), inner_corner3,
 #corner3, inner_corner3, corner3 - Vector3(0,halfHeight,0),]
 corner3, corner3 + Vector3(0,halfHeight,0), inner_corner3,
 corner3, inner_corner3, corner3 + Vector3(0,halfHeight,0)]

# 2 O'Clock
# Verts Down 36 - 41; Verts Up 42 - 47
var triangle34 = [#corner4, corner4 - Vector3(0,halfHeight,0), inner_corner4,
 #corner4, inner_corner4, corner4 - Vector3(0,halfHeight,0),]
 corner4, corner4 + Vector3(0,halfHeight,0), inner_corner4,
 corner4, inner_corner4, corner4 + Vector3(0,halfHeight,0)]

# 4 O'Clock
# Verts Down 48 - 53; Verts Up 54 - 59
var triangle35 = [#corner5, corner5 - Vector3(0,halfHeight,0), inner_corner5,
 #corner5, inner_corner5, corner5 - Vector3(0,halfHeight,0),]
 corner5, corner5 + Vector3(0,halfHeight,0), inner_corner5,
 corner5, inner_corner5, corner5 + Vector3(0,halfHeight,0)]

# 6 O'Clock
# Verts Down 60 - 65; Verts Up 66 - 71
var triangle36 = [#corner6, corner6 - Vector3(0,halfHeight,0), inner_corner6,
 #corner6, inner_corner6, corner6 - Vector3(0,halfHeight,0),]
 corner6, corner6 + Vector3(0,halfHeight,0), inner_corner6,
 corner6, inner_corner6, corner6 + Vector3(0,halfHeight,0)]

var inner_side_surfaces = [triangle36]
var uv_inner_side_surfaces = [uv_triangle31]
