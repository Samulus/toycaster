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

const 
    MaximumScreenWidth = 4096 #  4k resolution support for now
    TextureFormat = GL_RED.TextureInternalFormat
    PixelFormat = PixelDataFormat.RED
    PixelType = PixelDataType.UNSIGNED_BYTE

var DistanceTexture: OpenGLImage

proc regenerateImage*(screenWidth, screenHeight: uint): var OpenGLImage =
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

   # Generate banding effect for debugging
   for px in countup(0, int(widthPx - 1), 1):
       if px mod 4 == 0:
           DistanceTexture.bytes[px] = 64

   return DistanceTexture
