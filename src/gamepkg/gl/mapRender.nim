#
# mapRender.nim
# Author: Samuel Vargas
#

import ../minimap
import image
import sdl2/sdl_image
import sdl2/sdl
import opengl
import easygl
import easygl.utils

var TextureCoordinates : seq[GLfloat]  =
  @[
  1f, 1f, # top right
  1f, 0f, # bottom right
  0f, 0f, # bottom left
  0f, 1f, # top left
  ]

let Indices : seq[uint32] =
  @[
  0'u32, 1'u32, 3'u32,   # first triangle
  1'u32, 2'u32, 3'u32 ]  # second triangle

const
    fragShaderPath = "./glsl/image.frag"
    vertShaderPath = "./glsl/image.vert"
    ImageUniformName = "image"

let
    OutOfBoundsColor: seq[GLfloat] = @[0.0f, 0.89803f, 1.0f, 1.0f]

var
    VAO: VertexArrayId
    VBO: BufferId
    EBO: BufferId
    Shader: ShaderProgramId
    Tex: TextureId

proc init*(): void =
    Shader = createAndLinkProgram(vertShaderPath, fragShaderPath)
    VAO = genVertexArray()
    VBO = genBuffer()
    EBO = genBuffer()
    Tex = genTexture()
    bindVertexArray(VAO)

proc use*(mapImage: OpenGLImage): void =

    bindVertexArray(VAO)

    # Load vertex / texture coordinate data into GPU
    let vertexByteCount = len(mapImage.vertices) * GLfloat.sizeof
    let textureByteCount = len(TextureCoordinates) * GLfloat.sizeof
    bindBuffer(BufferTarget.ARRAY_BUFFER, VBO)
    bufferData(BufferTarget.ARRAY_BUFFER, vertexByteCount + textureByteCount,
               BufferDataUsage.DYNAMIC_DRAW)
    bufferSubData(BufferTarget.ARRAY_BUFFER, 0, vertexByteCount, mapImage.vertices)
    bufferSubData(BufferTarget.ARRAY_BUFFER, vertexByteCount, textureByteCount, TextureCoordinates)

    # Setup EBO
    bindBuffer(BufferTarget.ELEMENT_ARRAY_BUFFER, EBO)
    bufferData(BufferTarget.ELEMENT_ARRAY_BUFFER, Indices, BufferDataUsage.DYNAMIC_DRAW)

    # Vertex (XYZ) vertexAttribPointer
    vertexAttribPointer(0, 3, VertexAttribType.FLOAT, false, 3 * float32.sizeof(), 0)
    enableVertexAttribArray(0)
    # Texture (ST) vertexAttribPointer
    vertexAttribPointer(1, 2, VertexAttribType.FLOAT, false, 2 * float32.sizeof(), 12 * float32.sizeof())
    enableVertexAttribArray(1)

    # Upload `mapImage` data
    activeTexture(TextureUnit.TEXTURE0)
    bindTexture(TextureTarget.TEXTURE_2D, Tex)

    # Tell GPU to this sampler2d belongs to Texture Unit 0
    Shader.use()
    let minimap = getUniformLocation(Shader, ImageUniformName)
    assert(minimap.int != -1, "Missing Uniform: " & $ImageUniformName)
    glUniform1i(minimap.GLint, 0.GLint)

    # Setup Clamping / Filtering
    texParameteri(TextureTarget.TEXTURE_2D, TextureParameter.TEXTURE_WRAP_S, GL_CLAMP_TO_BORDER)
    texParameteri(TextureTarget.TEXTURE_2D, TextureParameter.TEXTURE_WRAP_T, GL_CLAMP_TO_BORDER)
    glTexParameterfv(GL_TEXTURE_2D, GL_TEXTURE_BORDER_COLOR, cast[ptr GLfloat](OutOfBoundsColor[0].unsafeAddr))

    texParameteri(TextureTarget.TEXTURE_2D, TextureParameter.TEXTURE_MIN_FILTER, GL_NEAREST);
    texParameteri(TextureTarget.TEXTURE_2D, TextureParameter.TEXTURE_MAG_FILTER, GL_NEAREST);

    # Upload to GPU
    texImage2D(TexImageTarget.TEXTURE_2D, 0.int32,
               mapImage.format, mapImage.width.int32, mapImage.height.int32,
               mapImage.pixelFormat, mapImage.pixelType, mapImage.bytes)

proc render*(): void =
    Shader.use()
    bindVertexArray(VAO)
    activeTexture(TextureUnit.TEXTURE0)
    bindTexture(TextureTarget.TEXTURE_2D, Tex)
    drawElements(DrawMode.TRIANGLES, 6, IndexType.UNSIGNED_INT, 0)