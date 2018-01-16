#
# colorTexture.nim
# Author: Samuel Vargas
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
    TextureFormat = GL_RED.TextureInternalFormat
    PixelFormat = PixelDataFormat.RED
    PixelType = PixelDataType.UNSIGNED_BYTE

var
    ColorTexture: OpenGLImage

proc getColorTexture*(screenWidth, screenHeight: uint): var OpenGLImage =
   let
      widthPx = min(screenWidth, MaximumScreenWidth)
      heightPx = uint(1)

   if isNil(ColorTexture):
       ColorTexture = OpenGLImage(
           width: widthPx,
           height: heightPx,
           vertices: imageFloat.generateRectangleVertices(widthPx.float / screenWidth.float, heightPx.float / screenHeight.float),
           bytes: newSeqWith(MaximumScreenWidth, 0.uint8),
           components: 1,
           format: TextureFormat,
           pixelFormat: PixelFormat,
           pixelType: PixelType)

   return ColorTexture
