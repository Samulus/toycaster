#
# playerIcon.nim
# Author: Samuel Vargas
#

import image
import opengl
import easygl
import easygl.utils
import glm

let TextureCoordinates : seq[GLfloat]  =
  @[
  1'f32, 1'f32, # top right
  1'f32, 0'f32, # bottom right
  0'f32, 0'f32, # bottom left
  0'f32, 1'f32, # top left
  ]

let Indices : seq[uint32] =
  @[
  0'u32, 1'u32, 3'u32,   # first triangle
  1'u32, 2'u32, 3'u32 ]  # second triangle

const
    fragShaderPath = "./glsl/image.frag"
    vertShaderPath = "./glsl/image.vert"
    PlayerIconPath = "./images/player.png"
    ImageUniformName = "image"
    TransformationUniformName = "transform"

let
    OutOfBoundsColor: seq[GLfloat] = @[0.0f, 0.89803f, 1.0f, 1.0f]

var
    VAO: VertexArrayId
    VBO: BufferId
    EBO: BufferId
    Shader: ShaderProgramId
    Tex: TextureId
    PlayerImage: OpenGLImage
    Transformation = mat4f(1)
                    .scale(1.5,1.5,1.5)
                    .translate(0,0,0)

proc init*(screenWidth, screenHeight: uint): void =
    PlayerImage = fileToGLImage(PlayerIconPath, screenWidth, screenHeight)
    Shader = createAndLinkProgram(vertShaderPath, fragShaderPath)
    VAO = genVertexArray()
    VBO = genBuffer()
    EBO = genBuffer()
    Tex = genTexture()
    bindVertexArray(VAO)

    # Load vertex / texture coordinate data into GPU
    let vertexByteCount = len(PlayerImage.vertices) * GLfloat.sizeof
    let textureByteCount = len(TextureCoordinates) * GLfloat.sizeof
    bindBuffer(BufferTarget.ARRAY_BUFFER, VBO)
    bufferData(BufferTarget.ARRAY_BUFFER, vertexByteCount + textureByteCount,
               BufferDataUsage.DYNAMIC_DRAW)
    bufferSubData(BufferTarget.ARRAY_BUFFER, 0, vertexByteCount, PlayerImage.vertices)
    bufferSubData(BufferTarget.ARRAY_BUFFER, vertexByteCount, textureByteCount, TextureCoordinates)

    # Setup EBO
    bindBuffer(BufferTarget.ELEMENT_ARRAY_BUFFER, EBO)
    bufferData(BufferTarget.ELEMENT_ARRAY_BUFFER, Indices, BufferDataUsage.DYNAMIC_DRAW)

    # Vertex Pointer, Texture Pointer
    vertexAttribPointer(0, PlayerImage.components, VertexAttribType.FLOAT, false, 0, 0)
    enableVertexAttribArray(0)
    vertexAttribPointer(1, 2, VertexAttribType.FLOAT, false, 0, vertexByteCount)
    enableVertexAttribArray(1)

    # Upload `playerIcon` to GPU
    activeTexture(TextureUnit.TEXTURE0)
    bindTexture(TextureTarget.TEXTURE_2D, Tex)

    Shader.use()
    let img = getUniformLocation(Shader, ImageUniformName)
    assert(img.int != -1, "Missing Uniform: " & $ImageUniformName)
    glUniform1i(img.GLint, 0.GLint)

    # Upload Transformation Matrix
    let transform = getUniformLocation(Shader, TransformationUniformName)
    assert(transform.int != -1, "Missing Uniform: " & $ImageUniformName)
    glUniformMatrix4fv(transform.GLint, 1, false, Transformation.caddr)

    # Setup Clamping / Filtering
    texParameteri(TextureTarget.TEXTURE_2D, TextureParameter.TEXTURE_WRAP_S, GL_CLAMP_TO_BORDER)
    texParameteri(TextureTarget.TEXTURE_2D, TextureParameter.TEXTURE_WRAP_T, GL_CLAMP_TO_BORDER)
    glTexParameterfv(GL_TEXTURE_2D, GL_TEXTURE_BORDER_COLOR, cast[ptr GLfloat](OutOfBoundsColor[0].unsafeAddr))

    texParameteri(TextureTarget.TEXTURE_2D, TextureParameter.TEXTURE_MIN_FILTER, GL_LINEAR);
    texParameteri(TextureTarget.TEXTURE_2D, TextureParameter.TEXTURE_MAG_FILTER, GL_LINEAR);

    # Upload to GPU
    texImage2D(TexImageTarget.TEXTURE_2D, 0.int32,
               PlayerImage.format, PlayerImage.width.int32, PlayerImage.height.int32,
               PlayerImage.pixelFormat, PlayerImage.pixelType, PlayerImage.bytes)

proc render*(): void =
    Shader.use()
    bindVertexArray(VAO)
    activeTexture(TextureUnit.TEXTURE0)
    bindTexture(TextureTarget.TEXTURE_2D, Tex)
    drawElements(DrawMode.TRIANGLES, 6, IndexType.UNSIGNED_INT, 0)