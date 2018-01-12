#
# raycast.nim
# Author: Samuel Vargas
#

import map
import math
import glm
import opengl

const
    AlmostZero = 0.0001f
    Fov = 60f.degToRad()

type
    Quadrant* = enum
        I,
        II,
        III,
        IV

proc getQuadrant*(theta: float): Quadrant =
    if theta >= 0 and theta < math.Pi / 2.0:
        return Quadrant.I
    elif theta >= math.Pi / 2.0 and theta < math.Pi:
        return Quadrant.II
    elif theta >= math.Pi and theta < (3 * math.Pi) / 2:
        return Quadrant.III
    else:
        return Quadrant.IV

proc getHorizontalIntersection*(origin: Vec2f, theta: float, almostZero = AlmostZero): Vec2f =
    #if not (theta > -MaximumDifference)
    #assert(theta > -MaximumDifference, "Theta must be non-negative")
    # Prevent divsion by 0
    #echo "Theta: " & $theta
    var safeTheta = abs(theta)
    if safeTheta == 0:
        safeTheta = almostZero

    var A = vec2f(0, 0)
    case safeTheta.getQuadrant():
        of I, II:
            A.y = floor(origin.y) - almostZero
        of III, IV:
            A.y = floor(origin.y) + 1 + almostZero

    A.x = origin.x + (origin.y - A.y) / tan(safeTheta)
    return A

proc getVerticalIntersection*(origin: Vec2f, theta: float, almostZero = AlmostZero): Vec2f =
    #assert(theta > -MaximumDifference, "Theta must be non-negative")
    # Prevent divsion by 0
    var safeTheta = abs(theta)
    if safeTheta == 0:
        safeTheta = almostZero

    var B = vec2f(0, 0)
    case safeTheta.getQuadrant():
        of I, IV:
            B.x = floor(origin.x) + 1 + almostZero
        of II, III:
            B.x = floor(origin.x) - almostZero

    B.y = origin.y + (origin.x - B.x) * tan(safeTheta)
    return B

# Returns the coordinate of the first horizontal wall
# boundary. If no walls are found the extreme edge of the
# map is returnedh
proc horizontalRaycast*(position, firstIntersection: Vec2f, theta: float,
                        mapArr: LevelMap, almostZero = AlmostZero): float =

    # Prevent divsion by 0
    var
        xPos = firstIntersection.x
        yPos = firstIntersection.y
        safeTheta = theta
        Ya = 0.0f

    if safeTheta == 0:
        safeTheta = almostZero

    let
        Xa = 1.0f / tan(safeTheta)
        quadrant = safeTheta.getQuadrant()
        mapWidth  = len(mapArr[0]) # TODO Square maps supported only for right now
        mapHeight = len(mapArr)

    case quadrant:
        of I, II:
            Ya = -1.0 # If facing Up
        of III, IV:
            Ya =  1.0

    var
        xCell = 0
        yCell = 0

    #echo "Start Loop"

    while true:
        xCell = xPos.floor.int
        yCell = yPos.floor.int

        if yCell < 0 or yCell >= mapHeight or xCell < 0 or xCell >= mapWidth:
            break
        elif mapArr[yCell.int][xCell.int] == TileType.Wall:
            # TODO: Remove distortion:
            # http://www.permadi.com/tutorial/raycast/rayc8.html
            #echo "Horizontal Wall"
            #let distance = sqrt(pow(position.x - xPos.float, 2) + pow(position.y - yPos.float, 2))
            #return distance * cos(theta)
            #let beta = theta - (Fov / 2.0f)
            #return distortedDistance * cos(beta)
            return sqrt(pow(position.x - xPos, 2) + pow(position.y - yPos, 2))
        else:
            xPos = xPos + Xa
            yPos = yPos + Ya

    if xCell < 0:
      xCell = 0
    elif xCell >= mapWidth:
      xCell = mapWidth - 1
    if yCell < 0:
      yCell = 0
    elif yCell >= mapHeight:
      yCell = mapHeight - 1

    if mapArr[yCell][xCell] == TileType.Wall:
        return sqrt(pow(position.x - xPos.float, 2) + pow(position.y - yPos.float, 2))


    assert(false, "[horizontalRaycast] should not get here in a closed map")
    return 0

proc verticalRaycast*(position, firstIntersection: Vec2f, theta: float,
                        mapArr: LevelMap, almostZero = AlmostZero): float =
    var
        xPos = firstIntersection.x
        yPos = firstIntersection.y
        safeTheta = theta
        Xa = 0.0f

    if safeTheta == 0:
        safeTheta = almostZero

    let
        Ya = 1 * tan(safeTheta)
        mapWidth  = len(mapArr[0]).int
        mapHeight = len(mapArr).int

    case safeTheta.getQuadrant():
        of I, IV:
            Xa = 1.0 # Facing Right
        of II, III:
            Xa = -1.0

    var
        xCell = 0
        yCell = 0

    while true:
        xCell = xPos.floor.int
        yCell = yPos.floor.int

        if yPos < 0 or yPos >= mapHeight.float or xPos < 0 or xPos >= mapWidth.float:
            break
        elif mapArr[yCell.int][xCell.int] == TileType.Wall:
            # TODO: Remove distortion:
            # http://www.permadi.com/tutorial/raycast/rayc8.html
            #echo "Vertical Wall"
            #let distortedDistance = sqrt(pow(position.x - xPos.float, 2) + pow(position.y - yPos.float, 2))
            #let beta = theta - Fov / 2
            #return distortedDistance * cos(beta)
            #let distance = sqrt(pow(position.x - xPos.float, 2) + pow(position.y - yPos.float, 2))
            #return distance * cos(theta)
            return sqrt(pow(position.x - xPos.float, 2) + pow(position.y - yPos.float, 2))
        else:
            xPos = xPos + Xa
            yPos = yPos + Ya

    if xCell < 0:
      xCell = 0
    elif xCell >= mapWidth:
      xCell = mapWidth - 1
    if yCell < 0:
      yCell = 0
    elif yCell >= mapHeight:
      yCell = mapHeight - 1

    if mapArr[yCell][xCell] == TileType.Wall:
        return sqrt(pow(position.x - xPos.float, 2) + pow(position.y - yPos.float, 2))


    assert(false, "[verticalRaycast] should not get here in a closed map")
    return 0

proc raycastEachWall*(position: Vec2f, theta: float, screenWidth: uint, mapArr: LevelMap, heights: var seq[GLfloat]): void =

    var
        angle = theta + Fov/2
        angleBetweenRays = Fov / screenWidth.float
        y = 0

    while y < screenWidth.int:
        let
            horizontalCell = getHorizontalIntersection(position, angle)
            verticalCell = getVerticalIntersection(position, angle)
            horizontalDistance = horizontalRaycast(position, horizontalCell, angle, mapArr)
            verticalDistance = verticalRaycast(position, verticalCell, angle, mapArr)
            distance = min(verticalDistance, horizontalDistance)

        #echo angle.radToDeg()

        # Take the distance in meters from the wall
        #heights[y] = scale(distance, 0.0, len(mapArr).float, 0.0, high(uint8).float).uint8
        heights[y] = (1 / distance) * ((screenWidth.float / 2.0f) / tan(Fov/2))
        #echo heights[y]
        angle -= angleBetweenRays # Should DECREASE If we start at far left and go toward right
        #if (angle < 58f.degToRad()):
            #assert (angle >= 58f.degToRad())
        y = y + 1

proc heightOfWall*(distance: float): void =
    discard

    # Width / height are in pixels
    # Dimension of Projection Plane (screenWidth x screenHeight)
    # Center of Projection Plane (screenWidth / 2, x screenHeight /2)
    # Distance to Projection Plane ((screenWidth / 2)) / tan(fov/2)
    # Angle Between Subsequent Rays = (fov / screenWidth)

    # ( Later )

    # 0 meters away -> slice should take up entire screen
    # 10 meters away --> slice should be invisible

    # In the tutorial, the height of each wall is 64 Px but the height
    # of the projection plane is 200 px

    # The ratio
    # (WallHeight?  / DistancekkToSlice) * DistanceToProjectionPlane
