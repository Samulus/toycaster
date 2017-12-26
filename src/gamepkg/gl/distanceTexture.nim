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
import nimBMP
import opengl
import easygl

const MaximumScreenWidth = 4096
var DistanceTexture: GrayImage

proc regenerateImage*(actualScreenWidth: uint): var GrayImage =
    if isNil(DistanceTexture):
        DistanceTexture = GrayImage(
            width: actualScreenWidth,
            height: 1,
            bytes: newSeqWith(MaximumScreenWidth, 0.uint8),
            format: GL_R8UI.TextureInternalFormat
        )

    let limit = min(actualScreenWidth, MaximumScreenWidth)
    DistanceTexture.width = limit

    for px in countup(0, int(limit - 1), 1):
        # Create a banding effect for image testing
        if px mod 4 == 0:
            DistanceTexture.bytes[px] = 64

    return DistanceTexture
