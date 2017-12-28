#
# image.nim
# Author: Samuel Vargas
#

import opengl
import easygl
import sdl2/sdl_image
import sdl2/sdl
import sequtils

# https://forum.nim-lang.org/t/1188#7366
template ptrMath(body: untyped) =
    template `+`[T](p: ptr T, off: int): ptr T =
      cast[ptr type(p[])](cast[ByteAddress](p) +% off * sizeof(p[]))

    template `+=`[T](p: ptr T, off: int) =
      p = p + off

    template `-`[T](p: ptr T, off: int): ptr T =
      cast[ptr type(p[])](cast[ByteAddress](p) -% off * sizeof(p[]))

    template `-=`[T](p: ptr T, off: int) =
      p = p - off

    template `[]`[T](p: ptr T, off: int): T =
      (p + off)[]

    template `[]=`[T](p: ptr T, off: int, val: T) =
      (p + off)[] = val

    body

type RGBAImage* = ref object of RootObj
    width*: uint
    height*: uint
    bytes*: seq[uint8]

type GrayImage* = ref object of RootObj
    width*: uint
    height*: uint
    bytes*: seq[uint8]
    format*: TextureInternalFormat

# sdl2 -> OpenGL conversions
type
     ComponentSize = range[0..4]

type OpenGLImage* = ref object of RootObj
    width*: uint
    height*: uint
    vertices*: seq[float32]
    bytes*: seq[uint32]
    components*: ComponentSize
    format*: TextureInternalFormat
    pixelFormat*: PixelDataFormat
    pixelType*: PixelDataType

const
    # Each 32 bit integer is RGBA (8bits each)
    KnownPixelFormat = PIXELFORMAT_RGBA8888.uint32
    ComponentsInImage = 2.ComponentSize
    VerticesInRectangle = 4 * ComponentsInImage

proc fileToGLImage*(filepath: string, screenWidth, screenHeight: uint): OpenGLImage =
    var tmpImage = sdl_image.load(filepath.cstring)
    assert(not isNil(tmpImage), "Failure to load: " & filepath)
    let convertedImage = convertSurfaceFormat(tmpImage, KnownPixelFormat, 0)
    assert(not isNil(convertedImage), "Failure to convert to RGBA8888: " & filepath)

    result = OpenGLImage(
        width: convertedImage.w.uint,
        height: convertedImage.h.uint,
        vertices: newSeqWith(VerticesInRectangle, 0.float32),
        bytes: newSeqWith(convertedImage.pitch * convertedImage.h, 0.uint32),
        components: ComponentsInImage,
        format: TextureInternalFormat.RGBA,
        pixelFormat: PixelDataFormat.RGBA,
        pixelType: PixelDataType.UNSIGNED_INT_8_8_8_8
    )

    # Copy pixel data to internal sequence
    let size = convertedImage.pitch * convertedImage.h
    var pixelPtr: ptr uint32 = cast[ptr uint32](convertedImage.pixels)
    for px in countup(0, size - 1, 1):
        ptrMath:
            result.bytes[px] = pixelPtr[px]

    # Generate vertex coordinates from width and height
    let ndcWidth = convertedImage.w.float / screenWidth.float
    let ndcHeight = convertedImage.h.float / screenHeight.float
    result.vertices[0] = ndcWidth; result.vertices[1] = 0         # top right (x, y)
    result.vertices[2] = ndcWidth; result.vertices[3] = ndcHeight # bottom right (x, y)
    result.vertices[4] = 0;        result.vertices[5] = ndcHeight # bottom left (x, y)
    result.vertices[6] = 0;        result.vertices[7] = 0         # top left (x, y)