#
# raycast.nim
# Author: Samuel Vargas
#

import map
import math
import glm
import opengl
import fenv

const
    Fov = 60f.degToRad()

let
   AlmostZero = 0.0001

type
    Quadrant* = enum
        I,
        II,
        III,
        IV

proc getQuadrant*(theta: float): Quadrant =
    if theta >= 0 and theta < (math.Pi / 2.0f):
        return Quadrant.I
    elif theta >= (math.Pi / 2.0) and theta < math.Pi:
        return Quadrant.II
    elif theta >= math.Pi and theta < (3 * math.Pi) / 2:
        return Quadrant.III
    else:
        return Quadrant.IV

type
    Orientation* = enum
        Vertical,
        Horizontal,

proc findFirstIntersection*(origin: Vec2f, sweeping: float,
                            orientation: Orientation,
                            almostZero = AlmostZero): Vec2f =
    var safeSweep = abs(sweeping)
    if safeSweep == 0:
        safeSweep = almostZero

    let quadrant = safeSweep.getQuadrant()
    var point = vec2f(0, 0)

    if orientation == Horizontal:
        if quadrant == Quadrant.I or quadrant == Quadrant.II:
            point.y = floor(origin.y) - almostZero
        else:
            point.y = floor(origin.y) + 1 + almostZero
        point.x = origin.x + (origin.y - point.y) / tan(safeSweep)
    else:
        if quadrant == Quadrant.I or quadrant == Quadrant.IV:
            point.x = floor(origin.x) + 1 + almostZero
        else:
            point.x = floor(origin.x) - almostZero
        point.y = origin.y + (origin.x - point.x) * tan(safeSweep)

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

    var
        Ya = 0.0f
        Xa = 0.0f

    # Calculate Y offset / X offset for subsequent map cell checks
    # Determine cell check direction based off orientation + safeSweeping quadrant

    # SOHCAHTOA
    # sin(x) == opp/hyp
    # cos(x) == adj/hyp
    # tan(x) == opp/adj
    let quadrant = safeSweeping.getQuadrant()
    if orientation == Horizontal:
        Ya = if quadrant == Quadrant.I or quadrant == Quadrant.II: -1.0f else: 1.0f
        Xa = 1.0f / tan(safeSweeping)
        case quadrant:
            of I, IV: Xa = abs(Xa)
            of II, III: Xa = -1 * abs(Xa)
    else:
        Ya = tan(safeSweeping)
        Xa = if quadrant == Quadrant.II or quadrant == Quadrant.III: -1.0f else: 1.0f
        case quadrant:
            of I, II: Ya = -1 * abs(Ya)
            of III, IV: Ya = abs(Ya)

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

        xPos = xPos + Xa
        yPos = yPos + Ya

    return high(GLfloat)

proc raycastEachWall*(position: Vec2f, theta: float, screenWidth: uint, mapArr: LevelMap, heights: var seq[GLfloat], wallColors: var seq[uint8]): void =
    var
        angle = theta + Fov/2
        angleBetweenRays = Fov / screenWidth.float
        x = 0

    while x < screenWidth.int:
        let
            horizontalCell = findFirstIntersection(position, angle, Horizontal)
            verticalCell = findFirstIntersection(position, angle, Vertical)
            horizontalDistance = raycast(position, horizontalCell, theta, angle, mapArr, Horizontal)
            verticalDistance = raycast(position, verticalCell, theta, angle, mapArr, Vertical)

        let isVertical = verticalDistance < horizontalDistance
        var distance = min(verticalDistance, horizontalDistance)

        heights[x] = (1 / distance) * ((screenWidth.float / 2.0f) / tan(Fov/2))
        wallColors[x] = if isVertical: high(uint8) else: 0.uint8
        angle -= angleBetweenRays
        x = x + 1
