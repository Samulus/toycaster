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

const
    MaximumScreenWidth = 4096

var
    DistanceTexture: GrayImage
    Created = false

proc regenerateImage*(actualScreenWidth: uint): var GrayImage =
    if not Created:
        Created = true
        DistanceTexture = GrayImage()
        DistanceTexture.width = actualScreenWidth
        DistanceTexture.height = 1
        # We always allocate the maximum size even if the screen
        # is smaller to prevent reallocations on window resizing
        DistanceTexture.bytes = newSeqWith(MaximumScreenWidth, 0.uint8)

    let limit = min(actualScreenWidth, MaximumScreenWidth)
    for px in countup(0, int(limit - 1), 1):
        # Create a banding effect for image testing
        if px mod 4 == 0:
            DistanceTexture.bytes[px] = high(uint8)

    return DistanceTexture
