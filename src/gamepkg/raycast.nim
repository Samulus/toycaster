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

type
    Orientation* = enum
        Vertical,
        Horizontal,

proc findFirstIntersection*(origin: Vec2f, theta: float, orientation: Orientation, almostZero = AlmostZero): Vec2f =
    var safeTheta = abs(theta)
    if safeTheta == 0:
        safeTheta = almostZero

    let quadrant = safeTheta.getQuadrant()
    var point = vec2f(0, 0)

    if orientation == Horizontal:
        if quadrant == Quadrant.I or quadrant == Quadrant.II:
            point.y = floor(origin.y) - almostZero
        else:
            point.y = floor(origin.y) + 1 + almostZero
        point.x = origin.x + (origin.y - point.y) / tan(safeTheta)
    else:
        if quadrant == Quadrant.I or quadrant == Quadrant.IV:
            point.x = floor(origin.x) + 1 + almostZero
        else:
            point.x = floor(origin.x) - almostZero
        point.y = origin.y + (origin.x - point.x) * tan(safeTheta)

    return point


proc raycast*(position, firstIntersection: Vec2f,
              theta: float,
              sweeping: float, mapArr: LevelMap,
              orientation: Orientation,
              almostZero = AlmostZero): float =

    let
        mapWidth  = len(mapArr[0])
        mapHeight = len(mapArr)

    var
        xPos = firstIntersection.x
        yPos = firstIntersection.y
        safeTheta = theta
        safeSweeping = sweeping

    # Prevent divison by 0
    if safeTheta == 0:
        safeTheta = almostZero

    if safeSweeping == 0:
        safeSweeping = almostZero

    let quadrant = safeTheta.getQuadrant()
    var
        Ya = 0.0f
        Xa = 0.0f

    # Calculate Y offset / X offset for subsequent map cell checks
    # Determine cell check direction based off orientation + safeTheta quadrant
    if orientation == Horizontal:
        Ya = if quadrant == Quadrant.I or quadrant == Quadrant.II: -1.0f else: 1.0f
        Xa = 1.0f / tan(safeTheta)
    else:
        Ya = 1.0f * tan(safeTheta)
        Xa = if quadrant == Quadrant.I or quadrant == Quadrant.IV: 1.0f else: -1.0f

    # Calculate distance from player to closest wall intersection
    var
        xCell = 0
        yCell = 0

    while true:
        xCell = xPos.floor.int
        yCell = yPos.floor.int

        if yPos < 0 or yPos >= mapHeight.float or xPos < 0 or xPos >= mapWidth.float:
            break
        elif mapArr[yCell.int][xCell.int] == TileType.Wall:
            let
                distortedDistance = sqrt(pow(position.x - xPos.float, 2) + pow(position.y - yPos.float, 2))
                beta = safeSweeping - safeTheta
            return distortedDistance * cos(beta)
        else:
            xPos = xPos + Xa
            yPos = yPos + Ya

    let
        distortedDistance = sqrt(pow(position.x - xPos.float, 2) + pow(position.y - yPos.float, 2))
        beta = sweeping - theta

    return distortedDistance * cos(beta)

# Returns the coordinate of the first horizontal wall
# boundary. If no walls are found the extreme edge of the
# map is returnedh
proc horizontalRaycast*(position, firstIntersection: Vec2f, sweep, theta: float,
                        mapArr: LevelMap, almostZero = AlmostZero): float =

    # Prevent divsion by 0
    var
        xPos = firstIntersection.x
        yPos = firstIntersection.y
        safeSweep = sweep
        Ya = 0.0f

    if safeSweep == 0:
        safeSweep = almostZero

    let
        Xa = 1.0f / tan(safeSweep)
        quadrant = safeSweep.getQuadrant()
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

    while true:
        xCell = xPos.floor.int
        yCell = yPos.floor.int

        if yCell < 0 or yCell >= mapHeight or xCell < 0 or xCell >= mapWidth:
            break
        elif mapArr[yCell.int][xCell.int] == TileType.Wall:
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

proc verticalRaycast*(position, firstIntersection: Vec2f, sweep, theta: float,
                        mapArr: LevelMap, almostZero = AlmostZero): float =
    var
        xPos = firstIntersection.x
        yPos = firstIntersection.y
        safeSweep = sweep
        Xa = 0.0f

    if safeSweep == 0:
        safeSweep = almostZero

    let
        Ya = 1 * tan(safeSweep)
        mapWidth  = len(mapArr[0]).int
        mapHeight = len(mapArr).int

    case safeSweep.getQuadrant():
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
            horizontalCell = findFirstIntersection(position, angle, Horizontal)
            verticalCell = findFirstIntersection(position, angle, Vertical)
            horizontalDistance = horizontalRaycast(position, horizontalCell, angle, theta, mapArr)
            verticalDistance = verticalRaycast(position, verticalCell, angle, theta, mapArr)
            #horizontalDistance = raycast(position, horizontalCell, theta, angle, mapArr, Horizontal)
            #verticalDistance = raycast(position, verticalCell, theta, angle, mapArr, Vertical)
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
