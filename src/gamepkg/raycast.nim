#
# raycast.nim
# Author: Samuel Vargas
#

import map
import math
import glm

const
    MaximumDifference = 0.0001
    AlmostZero = 0.0001f
    Fov = 60f.degToRad()

    # Projected Slice Height = (Actual Height / Distance to Slice) * Distance to Projection Plane


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
            Ya = -1.0 # If facing Up
        of III, IV:
            Ya =  1.0

    while true:
        let
            xCell = xPos.floor
            yCell = yPos.floor
        if yPos < 0 or yPos >= mapHeight or xPos < 0 or xPos >= mapWidth:
            break
        elif mapArr[yCell.int][xCell.int] == TileType.Wall:
            # TODO: Remove distortion:
            # http://www.permadi.com/tutorial/raycast/rayc8.html
            return sqrt(pow(position.x - xCell, 2) + pow(position.y - yCell, 2))
        else:
            xPos = xPos + Xa
            yPos = yPos + Ya

    return 1337

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
        mapWidth  = len(mapArr[0]).float
        mapHeight = len(mapArr).float

    case safeTheta.getQuadrant():
        of I, IV:
            Xa = 1.0 # Facing Right
        of II, III:
            Xa = -1.0

    while true:
        let
            xCell = xPos.floor
            yCell = yPos.floor
        if yPos < 0 or yPos >= mapHeight or xPos < 0 or xPos >= mapWidth:
            break
        elif mapArr[yCell.int][xCell.int] == TileType.Wall:
            # TODO: Remove distortion:
            # http://www.permadi.com/tutorial/raycast/rayc8.html
            return sqrt(pow(position.x - xCell, 2) + pow(position.y - yCell, 2))    
        else:
            xPos = xPos + Xa
            yPos = yPos + Ya

    return 1337

proc scale(x, inMin, inMax, outMin, outMax: float): float =
    return (x - inMin) * (outMax - outMin) / (inMax - inMin) + outMin

proc raycastEachWall*(position: Vec2f, theta: float, screenWidth: uint, mapArr: LevelMap, heights: var seq[uint8]): void =

    var 
        angle = theta - Fov/2
        angleBetweenRays = Fov / screenWidth.float
        y = 0
    
    while y < len(heights):
        let 
            horizontalCell = getHorizontalIntersection(position, angle)
            verticalCell = getVerticalIntersection(position, angle)
            horizontalDistance = horizontalRaycast(position, horizontalCell, angle, mapArr)
            verticalDistance = verticalRaycast(position, verticalCell, angle, mapArr)
            distance = min(verticalDistance, horizontalDistance)

        heights[y] = scale(distance, 0.0, len(mapArr).float, 0.0, high(uint8).float).uint8
        angle += angleBetweenRays
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