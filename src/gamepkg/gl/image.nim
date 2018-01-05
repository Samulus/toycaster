#
# image.nim
# Author: Samuel Vargas
#

import opengl
import easygl
import easygl.utils
import sdl2/sdl_image
import sdl2/sdl
import sequtils

let ImageTextureCoordinates : seq[GLfloat]  =
  @[
  1f, 1f, # top right
  1f, 0f, # bottom right
  0f, 0f, # bottom left
  0f, 1f, # top left
  ]

let Indices : seq[GLuint] =
  @[
  0'u32, 1'u32, 3'u32,   # first triangle
  1'u32, 2'u32, 3'u32 ]  # second triangle

let
    OutOfBoundsColor: seq[GLfloat] = @[0.0f, 0.89803f, 1.0f, 1.0f]

# https://forum.nim-lang.org/t/1188#7366
template ptrMath(body: untyped) =
    template `+`[T](p: ptr T, off: int): ptr T =
      cast[ptr type(p[])](cast[ByteAddress](p) +% off * sizeof(p[]))

    template `[]`[T](p: ptr T, off: int): T =
      (p + off)[]

    body

type
     ComponentSize = range[0..4]

const
    KnownPixelFormat = PIXELFORMAT_RGBA8888.uint32
    ComponentsInImage = 3.ComponentSize
    VerticesInRectangle = 4 * ComponentsInImage

type OpenGLImage* = ref object of RootObj
    width*: uint
    height*: uint
    vertices*: seq[GLfloat]
    indices*: seq[GLuint]
    textureCoordinates*: seq[GLfloat]
    bytes*: seq[uint8]
    components*: ComponentSize
    format*: TextureInternalFormat
    pixelFormat*: PixelDataFormat
    pixelType*: PixelDataType

method bindToTextureUnit*(this: OpenGLImage, tex: TextureId, index: uint): void {.base.} =
    activeTexture((TextureUnit.TEXTURE0.uint + index).TextureUnit)
    bindTexture(TextureTarget.TEXTURE_2D, tex)

method copyVertexAttributesToGPU*(this: OpenGLImage, vbo: BufferId, ebo: BufferId): void {.base.} =
    let vertexByteCount = len(this.vertices) * GLfloat.sizeof
    let textureByteCount = len(this.textureCoordinates) * GLfloat.sizeof
    # Copy Vertex + Texture coordinates into GPU
    bindBuffer(BufferTarget.ARRAY_BUFFER, vbo)
    bufferData(BufferTarget.ARRAY_BUFFER, vertexByteCount + textureByteCount, BufferDataUsage.DYNAMIC_DRAW)
    bufferSubData(BufferTarget.ARRAY_BUFFER, 0, vertexByteCount, this.vertices)
    bufferSubData(BufferTarget.ARRAY_BUFFER, vertexByteCount, textureByteCount, this.textureCoordinates)
    # Indices (EBO)
    bindBuffer(BufferTarget.ELEMENT_ARRAY_BUFFER, ebo)
    bufferData(BufferTarget.ELEMENT_ARRAY_BUFFER, Indices, BufferDataUsage.DYNAMIC_DRAW)
    # Vertices (XYZ)
    vertexAttribPointer(0, 3, VertexAttribType.FLOAT, false, 3 * GLfloat.sizeof(), 0)
    enableVertexAttribArray(0)
    # Textures (ST)
    vertexAttribPointer(1, 2, VertexAttribType.FLOAT, false, 2 * GLfloat.sizeof(), 12 * GLfloat.sizeof())
    enableVertexAttribArray(1)

method pairTextureWithSampler*(this: OpenGLImage, shader: ShaderProgramId, uniform: string): void {.base.} =
    shader.use()
    let uni = getUniformLocation(shader, uniform)
    assert(uni.int != -1, "Missing Uniform: " & uniform)
    glUniform1i(uni.GLint, 0.GLint)

method setupParameters*(this: OpenGLImage): void {.base.} =
    # Setup Clamping / Filtering
    texParameteri(TextureTarget.TEXTURE_2D, TextureParameter.TEXTURE_WRAP_S, GL_CLAMP_TO_BORDER)
    texParameteri(TextureTarget.TEXTURE_2D, TextureParameter.TEXTURE_WRAP_T, GL_CLAMP_TO_BORDER)
    glTexParameterfv(GL_TEXTURE_2D, GL_TEXTURE_BORDER_COLOR, cast[ptr GLfloat](OutOfBoundsColor[0].unsafeAddr))
    texParameteri(TextureTarget.TEXTURE_2D, TextureParameter.TEXTURE_MIN_FILTER, GL_NEAREST);
    texParameteri(TextureTarget.TEXTURE_2D, TextureParameter.TEXTURE_MAG_FILTER, GL_NEAREST);

method uploadToGPU*(this: OpenGLImage): void {.base.} =
    texImage2D(TexImageTarget.TEXTURE_2D, 0.int32,
               this.format, this.width.int32, this.height.int32,
               this.pixelFormat, this.pixelType, this.bytes)

proc generateRectangleVertices*(ndcWidth, ndcHeight: float): seq[GLfloat] =
    result = newSeqWith(VerticesInRectangle, 0.GLfloat)
    result[0] = ndcWidth; result[1] = 0;              result[2]  = 0 # top right (x, y, z)
    result[3] = ndcWidth; result[4] = ndcHeight;      result[5]  = 0 # bottom right (x, y, z)
    result[6] = 0;        result[7] = ndcHeight;      result[8]  = 0 # bottom left (x, y, z)
    result[9] = 0;        result[10] = 0;             result[11] = 0 # top left (x, y, z)

proc fileToGLImage*(filepath: string, screenWidth, screenHeight: uint): OpenGLImage =
    var tmpImage = sdl_image.load(filepath.cstring)
    assert(not isNil(tmpImage), "Failure to load: " & filepath)
    let convertedImage = convertSurfaceFormat(tmpImage, KnownPixelFormat, 0)
    assert(not isNil(convertedImage), "Failure to convert to RGBA8888: " & filepath)

    result = OpenGLImage(
        width: convertedImage.w.uint,
        height: convertedImage.h.uint,
        vertices: generateRectangleVertices(convertedImage.w.float / screenWidth.float, convertedImage.h.float / screenHeight.float),
        indices: Indices,
        textureCoordinates: ImageTextureCoordinates,
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
        indices: Indices,
        textureCoordinates: ImageTextureCoordinates,
        bytes: pixels,
        components: components,
        format: format,
        pixelFormat: pixelFormat,
        pixelType: pixelType
    )
