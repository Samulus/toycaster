#
# minimap.nim
# Author: Samuel Vargas
#

import map
import units
import sequtils
import colors
import nimBMP

const
    BlockSize = 24.Pixels
    ColorChannels = 4

const
    Black = rgb(0, 0, 0)
    White = rgb(255,255,255)

type RGBAImage = ref object of RootObj
    width: uint
    height: uint
    bytes: seq[uint8]

proc maxColLength(map: LevelMap): int =
    var max = 0
    for row in map:
        if row.len > max:
            max = row.len
    return max

proc mapToBitmap*(map: LevelMap): RGBAImage =
    # Dimensions of the generated image
    let imageWidthPixels = BlockSize * map.maxColLength
    let imageHeightPixels = BlockSize * map.len

    # Actual number of bytes in the image
    let imageWidthBytes = imageWidthPixels * ColorChannels
    var pixelBytes = newSeqWith(imageWidthBytes * imageHeightPixels, 0.uint8)

    # Convenience wrapper to avoid extra nesting when iterating over tiles
    iterator iter(map: LevelMap): TileType =
        for row in map:
            for tile in row:
                yield tile

    var row = 0
    var col = 0

    # For each tile in the map
    for tile in map.iter:
        # Paint it the appropriate color
        let color = (if tile == TileType.Empty: Black else: White).extractRGB()

        # Write BlockSize * BlockSize bytes starting at the given row and column
        for horizontalRow in countup(row, row + BlockSize - 1, 1):
            for verticalByte in countup(col, (col + BlockSize * ColorChannels) - (ColorChannels), 4):
                let index = imageWidthBytes * horizontalRow + verticalByte
                pixelBytes[index + 0]  = color.r
                pixelBytes[index + 1]  = color.g
                pixelBytes[index + 2]  = color.b
                pixelBytes[index + 3]  = 255

        # Update col / row to the correct starting byte position
        col += BlockSize * ColorChannels
        if col >= imageWidthBytes:
            col = 0
            row += BlockSize
            if row >= imageHeightPixels:
                break

    # Return the generated image
    result = RGBAImage()
    result.width = imageWidthPixels.uint8
    result.height = imageHeightPixels.uint8
    result.bytes = pixelBytes