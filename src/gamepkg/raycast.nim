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

proc findFirstIntersection*(origin: Vec2f, theta: float, 
                            orientation: Orientation, 
                            almostZero = AlmostZero): Vec2f =
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
        Xa = 1.0f / tan(safeSweeping)
    else:
        Ya = 1.0f * tan(safeSweeping)
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

    #echo "xPos: " & $xPos & " " & "yPos: " & $yPos
    #return 0
    let
        distortedDistance = sqrt(pow(position.x - xPos.float, 2) + pow(position.y - yPos.float, 2))
        beta = sweeping - theta
    return distortedDistance * cos(beta)

proc raycastEachWall*(position: Vec2f, theta: float, screenWidth: uint, mapArr: LevelMap, heights: var seq[GLfloat], wallColors: var seq[uint8]): void =
    var
        angle = theta + Fov/2
        angleBetweenRays = Fov / screenWidth.float
        y = 0

    while y < screenWidth.int:
        let
            horizontalCell = findFirstIntersection(position, angle, Horizontal)
            verticalCell = findFirstIntersection(position, angle, Vertical)
            horizontalDistance = raycast(position, horizontalCell, theta, angle, mapArr, Horizontal)
            verticalDistance = raycast(position, verticalCell, theta, angle, mapArr, Vertical)

        let isVertical = verticalDistance < horizontalDistance
        var distance = min(verticalDistance, horizontalDistance)

        heights[y] = (1 / distance) * ((screenWidth.float / 2.0f) / tan(Fov/2))
        wallColors[y] = if isVertical: high(uint8) else: 0.uint8
        angle -= angleBetweenRays # Should DECREASE If we start at far left and go toward right
        y = y + 1
