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
    vertices*: seq[GLfloat]
    bytes*: seq[uint8]
    components*: ComponentSize
    format*: TextureInternalFormat
    pixelFormat*: PixelDataFormat
    pixelType*: PixelDataType

const
    # Each 32 bit integer is RGBA (8bits each)
    KnownPixelFormat = PIXELFORMAT_RGBA8888.uint32
    ComponentsInImage = 3.ComponentSize
    VerticesInRectangle = 4 * ComponentsInImage # 4 points * components per point

proc fileToGLImage*(filepath: string, screenWidth, screenHeight: uint): OpenGLImage =
    var tmpImage = sdl_image.load(filepath.cstring)
    assert(not isNil(tmpImage), "Failure to load: " & filepath)
    let convertedImage = convertSurfaceFormat(tmpImage, KnownPixelFormat, 0)
    assert(not isNil(convertedImage), "Failure to convert to RGBA8888: " & filepath)

    result = OpenGLImage(
        width: convertedImage.w.uint,
        height: convertedImage.h.uint,
        vertices: newSeqWith(VerticesInRectangle, 0.float32),
        bytes: newSeqWith(convertedImage.pitch * convertedImage.h, 0.uint8),
        components: ComponentsInImage,
        format: TextureInternalFormat.RGBA,
        pixelFormat: PixelDataFormat.RGBA,
        pixelType: PixelDataType.UNSIGNED_INT_8_8_8_8
    )

    # Copy pixel data to internal sequence
    let size = convertedImage.pitch * convertedImage.h
    var pixelPtr: ptr uint8 = cast[ptr uint8](convertedImage.pixels)

    for px in countup(0, size - 1, 1):
        ptrMath:
            result.bytes[px] = pixelPtr[px]

    # Generate vertex coordinates from width and height
    let ndcWidth = convertedImage.w.float / screenWidth.float
    let ndcHeight = convertedImage.h.float / screenHeight.float

    result.vertices[0] = ndcWidth; result.vertices[1] = 0;         result.vertices[2]  = 0 # top right (x, y, z)
    result.vertices[3] = ndcWidth; result.vertices[4] = ndcHeight; result.vertices[5]  = 0 # bottom right (x, y, z)
    result.vertices[6] = 0;        result.vertices[7] = ndcHeight; result.vertices[8]  = 0 # bottom left (x, y, z)
    result.vertices[9] = 0;        result.vertices[10] = 0;        result.vertices[11] = 0 # top left (x, y, z)

proc pixelsToGLImage*(components: ComponentSize, format: TextureInternalFormat, pixelFormat: PixelDataFormat, pixelType: PixelDataType, widthPx, heightPx, screenWidth, screenHeight: uint, pixels: seq[uint8]): OpenGLImage =
    result = OpenGLImage(
        width: widthPx,
        height: heightPx,
        vertices: newSeqWith(VerticesInRectangle, 0.float32),
        bytes: newSeqWith(len(pixels), 0.uint8),
        components: components,
        format: format,
        pixelFormat: pixelFormat,
        pixelType: pixelType
    )

    # Copy pixel data to internal result 
    let size = len(pixels)
    for px in countup(0, size - 1, 1):
        result.bytes[px] = pixels[px]
    
    # Generate vertex coordinates from width and height
    let ndcWidth = widthPx.float / screenWidth.float
    let ndcHeight = heightPx.float / screenHeight.float
    result.vertices[0] = ndcWidth; result.vertices[1] = 0;         result.vertices[2]  = 0 # top right (x, y, z)
    result.vertices[3] = ndcWidth; result.vertices[4] = ndcHeight; result.vertices[5]  = 0 # bottom right (x, y, z)
    result.vertices[6] = 0;        result.vertices[7] = ndcHeight; result.vertices[8]  = 0 # bottom left (x, y, z)
    result.vertices[9] = 0;        result.vertices[10] = 0;        result.vertices[11] = 0 # top left (x, y, z)
