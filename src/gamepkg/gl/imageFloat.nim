#
# imageFloat.nim
# Author: Samuel Vargas
#
# TODO: Use generics

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

type
     ComponentSize = range[0..4]

const
    ComponentsInImage = 3.ComponentSize
    VerticesInRectangle = 4 * ComponentsInImage
    #KnownPixelFormat = PIXELFORMAT_RGBA8888.uint32

type OpenGLImageFloat* = ref object of RootObj
    width*: uint
    height*: uint
    vertices*: seq[GLfloat]
    bytes*: seq[GLfloat]
    components*: ComponentSize
    format*: TextureInternalFormat
    pixelFormat*: PixelDataFormat
    pixelType*: PixelDataType

method bindToTextureUnit*(this: OpenGLImageFloat, tex: TextureId, index: uint): void {.base.} =
    activeTexture((TextureUnit.TEXTURE0.uint + index).TextureUnit)
    bindTexture(TextureTarget.TEXTURE_2D, tex)

method copyVertexAttributesToGPU*(this: OpenGLImageFloat, vbo: BufferId, ebo: BufferId): void {.base.} =
    let vertexByteCount = len(this.vertices) * GLfloat.sizeof
    let textureByteCount = len(ImageTextureCoordinates) * GLfloat.sizeof
    # Copy Vertex + Texture coordinates into GPU
    bindBuffer(BufferTarget.ARRAY_BUFFER, vbo)
    bufferData(BufferTarget.ARRAY_BUFFER, vertexByteCount + textureByteCount, BufferDataUsage.DYNAMIC_DRAW)
    bufferSubData(BufferTarget.ARRAY_BUFFER, 0, vertexByteCount, this.vertices)
    bufferSubData(BufferTarget.ARRAY_BUFFER, vertexByteCount, textureByteCount, ImageTextureCoordinates)
    # Indices (EBO)
    bindBuffer(BufferTarget.ELEMENT_ARRAY_BUFFER, ebo)
    bufferData(BufferTarget.ELEMENT_ARRAY_BUFFER, Indices, BufferDataUsage.DYNAMIC_DRAW)
    # Vertices (XYZ)
    vertexAttribPointer(0, 3, VertexAttribType.FLOAT, false, 3 * GLfloat.sizeof(), 0)
    enableVertexAttribArray(0)
    # Textures (ST)
    vertexAttribPointer(1, 2, VertexAttribType.FLOAT, false, 2 * GLfloat.sizeof(), 12 * GLfloat.sizeof())
    enableVertexAttribArray(1)

method copyVertexAttributesToGPU*(this: OpenGLImageFloat, vbo: BufferId, ebo: BufferId, vertices: seq[GLFloat]): void {.base.} =
    this.vertices = vertices
    this.copyVertexAttributesToGPU(vbo, ebo)

method pairTextureWithSampler*(this: OpenGLImageFloat, shader: ShaderProgramId, uniform: string, index: int): void {.base.} =
    shader.use()
    let uni = getUniformLocation(shader, uniform)
    assert(uni.int != -1, "Missing Uniform: " & uniform)
    glUniform1i(uni.GLint, index.GLint)

method setupParameters*(this: OpenGLImageFloat): void {.base.} =
    # Setup Clamping / Filtering
    texParameteri(TextureTarget.TEXTURE_2D, TextureParameter.TEXTURE_WRAP_S, GL_CLAMP_TO_BORDER)
    texParameteri(TextureTarget.TEXTURE_2D, TextureParameter.TEXTURE_WRAP_T, GL_CLAMP_TO_BORDER)
    glTexParameterfv(GL_TEXTURE_2D, GL_TEXTURE_BORDER_COLOR, cast[ptr GLfloat](OutOfBoundsColor[0].unsafeAddr))
    texParameteri(TextureTarget.TEXTURE_2D, TextureParameter.TEXTURE_MIN_FILTER, GL_NEAREST);
    texParameteri(TextureTarget.TEXTURE_2D, TextureParameter.TEXTURE_MAG_FILTER, GL_NEAREST);

method uploadToGPU*(this: OpenGLImageFloat): void {.base.} =
    #echo this.width
    texImage2D(TexImageTarget.TEXTURE_2D, 0.int32,
               this.format, this.width.int32, this.height.int32,
               this.pixelFormat, this.pixelType, this.bytes)

proc generateRectangleVertices*(ndcWidth, ndcHeight: float): seq[GLfloat] =
    result = newSeqWith(VerticesInRectangle, 0.GLfloat)
    result[0] = ndcWidth; result[1] = 0;              result[2]  = 0 # top right (x, y, z)
    result[3] = ndcWidth; result[4] = ndcHeight;      result[5]  = 0 # bottom right (x, y, z)
    result[6] = 0;        result[7] = ndcHeight;      result[8]  = 0 # bottom left (x, y, z)
    result[9] = 0;        result[10] = 0;             result[11] = 0 # top left (x, y, z)
