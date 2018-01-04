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

    template `[]`[T](p: ptr T, off: int): T =
      (p + off)[]

    body

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

proc generateRectangleVertices*(ndcWidth, ndcHeight: float): seq[GLfloat] =
    result = newSeqWith(VerticesInRectangle, 0.GLfloat)
    result[0] = ndcWidth; result[1] = 0;              result[2]  = 0 # top right (x, y, z)
    result[3] = ndcWidth; result[4] = ndcHeight;      result[5]  = 0 # bottom right (x, y, z)
    result[6] = 0;        result[7] = ndcHeight;      result[8]  = 0 # bottom left (x, y, z)
    result[9] = 0;        result[10] = 0;             result[11] = 0 # top left (x, y, z)
    assert(len(result) == VerticesInRectangle)

proc fileToGLImage*(filepath: string, screenWidth, screenHeight: uint): OpenGLImage =
    var tmpImage = sdl_image.load(filepath.cstring)
    assert(not isNil(tmpImage), "Failure to load: " & filepath)
    let convertedImage = convertSurfaceFormat(tmpImage, KnownPixelFormat, 0)
    assert(not isNil(convertedImage), "Failure to convert to RGBA8888: " & filepath)

    result = OpenGLImage(
        width: convertedImage.w.uint,
        height: convertedImage.h.uint,
        vertices: generateRectangleVertices(convertedImage.w.float / screenWidth.float, convertedImage.h.float / screenHeight.float),
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

proc pixelsToGLImage*(components: ComponentSize, format: TextureInternalFormat, pixelFormat: PixelDataFormat, 
                      pixelType: PixelDataType, widthPx, heightPx, screenWidth, screenHeight: uint, 
                      pixels: seq[uint8]): OpenGLImage =

    result = OpenGLImage(
        width: widthPx,
        height: heightPx,
        vertices: generateRectangleVertices(widthPx.float / screenWidth.float, heightPx.float / screenHeight.float),
        bytes: pixels,
        components: components,
        format: format,
        pixelFormat: pixelFormat,
        pixelType: pixelType
    )
