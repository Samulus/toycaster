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
import ../raycast

const
    MaximumScreenWidth = 4096 #  4k resolution support for now
    TextureFormat = GL_RED.TextureInternalFormat
    PixelFormat = PixelDataFormat.RED
    PixelType = PixelDataType.UNSIGNED_BYTE

var
    DistanceTexture: OpenGLImage

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

   raycastEachWall(p.position, p.theta, screenWidth, mapArr, DistanceTexture.bytes)
   return DistanceTexture
