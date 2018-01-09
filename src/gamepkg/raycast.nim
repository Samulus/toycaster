#
# raycast.nim
# Author: Samuel Vargas
#

import map
import math
import glm

const
    MaximumDifference = 0.0001
    AlmostOne = 0.99999999
    AlmostZero = 0.0001f
    MaximumScreenWidth = 4096 #  4k resolution support for now

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
    assert(theta > -MaximumDifference, "Theta must be non-negative")
    # Prevent divsion by 0
    var safeTheta = theta
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
    assert(theta > -MaximumDifference, "Theta must be non-negative")
    # Prevent divsion by 0
    var safeTheta = theta
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
        Xa = 1 / tan(safeTheta)
        quadrant = safeTheta.getQuadrant()
        mapWidth  = len(mapArr[0]).float
        mapHeight = len(mapArr).float

    case quadrant:
        of I, II:
            Ya = -1.0 # If facing UP
        of III, IV:
            Ya =  1.0

    while true:
        let
            xCell = xPos.floor
            yCell = yPos.floor
        if yPos < 0 or yPos >= mapHeight or xPos < 0 or xPos >= mapWidth:
            break
        elif mapArr[yCell.int][xCell.int] == TileType.Wall:
            return sqrt(pow(position.x - xCell, 2) + pow(position.y - yCell, 2))
        else:
            xPos = xPos + Xa
            yPos = yPos + Ya

    return -666

proc verticalRaycast*(origin: Vec2f, xGap, yGap: float, mapArr: LevelMap): Vec2f =
    discard

proc heightOfWall*(): void =
    discard