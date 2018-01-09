#
# distanceTexture.nim
# Author: Samuel Vargas
#
# Generates a grayscale 1D texture where the brightness
# of each pixel corresponds to each height of each vertical
# column on screen.
#

import sequtils
import colors
import image
import opengl
import easygl
import glm
import math
import ../player
import ../map

const
    MaximumDifference = 0.0001
    AlmostOne = 0.99999999
    AlmostZero = 0.0001f
    MaximumScreenWidth = 4096 #  4k resolution support for now
    TextureFormat = GL_RED.TextureInternalFormat
    PixelFormat = PixelDataFormat.RED
    PixelType = PixelDataType.UNSIGNED_BYTE
    GridSize = 64
    Fov = 60.0.degToRad

var
    DistanceTexture: OpenGLImage

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

proc horizontalRaycast*(origin: Vec2f, xGap, yGap: float, mapArr: LevelMap): Vec2f =
    discard

proc verticalRaycast*(origin: Vec2f, xGap, yGap: float, mapArr: LevelMap): Vec2f =
    discard

proc heightOfWall*(): void =
    discard

# Implementation of: http://www.permadi.com/tutorial/raycast/rayc7.html
proc raycast(p: player.Player, mapArr: LevelMap, width: uint, heights: var seq[uint8]): void =

   var theta: float = p.theta + (Fov / 2)
   let 
       angleBetweenRays: float = (Fov / width.float).degToRad
       velocityX = cos(theta)
       velocityY = sin(theta)

   # .x is ROW, .y is COL (opposite of cartesi) 
   proc findHorizontalIntersection(): Vec2f =
       let opposite = (p.position.x) * velocityX

   #let velocityX = cos(theta)
   #let velocityY = sin(theta)
   #var stepY = (ceil(velocityX)).int 
   #var stepX = (-1 * ceil(velocityY)).int
   #var cellX = floor(p.position.arr[0]).int + stepX # Always start ±1 horizontal cell
   #var cellY = floor(p.position.arr[1]).int

   for col in countup(0, int(width - 1), 1):
      let quadrant = getQuadrant(theta)
      if quadrant == Quadrant.I:
        discard

   #for col in countup(0, int(width - 1), 1):
    #discard
        # Cartesian -> Map Coordinates
        #stepY = (ceil(velocityX)).int
        #stepX = (-1 * ceil(velocityY)).int

        #cellX = floor(p.position.arr[0]).int + stepX # Always start ±1 horizontal cell
        #cellY = floor(p.position.arr[1]).int + stepY

        # Find the horizontal intersection that the ray with angle theta would sweep out

        #let opposite = abs(p.position.arr[0] - cellx.float)

        #let horizontalGap = 0 # Between [p.position.arr[1], p.position.arr[1] + 1]

        #var tmpX = cellX
        #var tmpY = cellY
        #var dst = 0.0f

       # Check horizontal boundaries for collisions
       #block horizontalBoundaryCheck:
           #while (tmpX >= 0 and tmpX < mapHeight and tmpY >= 0 and tmpY < mapWidth):
              #if (mapArr[tmpX][tmpY] == TileType.Wall):
                  #needCheckVertical = false
                  #let distance = abs(p.position.arr[0] - tmpX.float) # Height of a wall is mapped between [0 -> 1024 (screenHeight)]
                  #echo distance
                  #DistanceTexture.bytes[col] = uint8(abs(p.position.arr[0] - tmpX.float) / 255.0f)
                  #DistanceTexture.bytes[col] = min(distance, high(uint8).float).uint8
                  #DistanceTexture.bytes[col] = 255
                  #echo DistanceTexture.bytes[col]
                  #break horizontalBoundaryCheck
              #tmpX += stepX
              #tmpY += stepY
        
       #theta += angleBetweenRays

proc regenerateImage*(p: player.Player, mapArr: LevelMap, screenWidth, screenHeight: uint): var OpenGLImage =
   let
      widthPx = min(screenWidth, MaximumScreenWidth)
      heightPx = uint(1)

   if isNil(DistanceTexture):
        DistanceTexture = OpenGLImage(
            width: widthPx,
            height: heightPx,
            vertices: generateRectangleVertices(widthPx.float / screenWidth.float, heightPx.float / screenHeight.float),
            bytes: newSeqWith(MaximumScreenWidth, 0.uint8),
            components: 1,
            format: TextureFormat,
            pixelFormat: PixelFormat,
            pixelType: PixelType)
    
   raycast(p, mapArr, widthPx, DistanceTexture.bytes)
   return DistanceTexture
