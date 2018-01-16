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
import imageFloat
import opengl
import easygl
import glm
import math
import ../player
import ../map
import ../raycast

const
    MaximumScreenWidth = 4096 #  4k resolution support for now
    TextureFormat = GL_R16F.TextureInternalFormat
    PixelFormat = GL_RED.PixelDataFormat
    PixelType = PixelDataType.FLOAT

var
    DistanceTexture: OpenGLImageFloat

proc regenerateImage*(p: player.Player, mapArr: LevelMap, screenWidth, screenHeight: uint, wallColors: var seq[uint8]): var OpenGLImageFloat =

   let
      widthPx = min(screenWidth, MaximumScreenWidth)
      heightPx = uint(1)

   assert(widthPx < len(wallColors).uint)

   if isNil(DistanceTexture):
        DistanceTexture = OpenGLImageFloat(
            width: widthPx,
            height: heightPx,
            vertices: imageFloat.generateRectangleVertices(widthPx.float / screenWidth.float, heightPx.float / screenHeight.float),
            bytes: newSeqWith(MaximumScreenWidth, 0.GLFloat),
            components: 1,
            format: TextureFormat,
            pixelFormat: PixelFormat,
            pixelType: PixelType)

   raycastEachWall(p.position, p.theta, screenWidth, mapArr, DistanceTexture.bytes, wallColors)
   return DistanceTexture
