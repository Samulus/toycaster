#
# wallRender.nim
# Author: Samuel Vargas
#
# The wallRender module works by drawing a fullscreen quad and
# sending the map data to the GPU using a 1D texture.

#
# The horizontal width of the 1D texture passed into
# the GLSL shader should match the width of the screen
# This way in the shader we can convert gl_FragCoord.x to
# a normalized value and find the corresponding brightness /
# darkness of the wall
#

import ../map
import image
import opengl
import easygl
import easygl.utils
import sequtils
import os

const
    iResolutionName = "iResolution"
    fragShaderPath = "./glsl/wall.frag"
    vertShaderPath = "./glsl/wall.vert"

let
    OutOfBoundsColor: seq[GLfloat] = @[1.0f, 1.0f, 1.0f, 1.0f]

var VAO: VertexArrayId
var VBO: BufferId
var EBO: BufferId
var Shader: ShaderProgramId
var Tex: TextureId

let Vertices : seq[float32]  =
  @[
  1.0'f32,  1.0'f32, 0.0'f32,  # top right
  1.0'f32, -1.0'f32, 0.0'f32,  # bottom right
 -1.0'f32, -1.0'f32, 0.0'f32,  # bottom left
 -1.0'f32,  1.0'f32, 0.0'f32 ] # top left

let Indices : seq[uint32] =
  @[
  0'u32, 1'u32, 3'u32,   # first triangle
  1'u32, 2'u32, 3'u32 ]  # second triangle

proc init*(): void =
    Shader = createAndLinkProgram(vertShaderPath, fragShaderPath)
    VAO = genVertexArray()
    VBO = genBuffer()
    EBO = genBuffer()
    Tex = genTexture()
    bindVertexArray(VAO)

proc use*(screenHeight, screenWidth: uint, distances: GrayImage): void =
    # Bind VAO
    bindVertexArray(VAO)
    # Copy Vertices to GPU Buffer
    bindBuffer(BufferTarget.ARRAY_BUFFER, VBO)
    bufferData(BufferTarget.ARRAY_BUFFER, Vertices, BufferDataUsage.STATIC_DRAW)
    # Copy Element Indices to GPU Buffer
    bindBuffer(BufferTarget.ELEMENT_ARRAY_BUFFER, EBO)
    bufferData(BufferTarget.ELEMENT_ARRAY_BUFFER, Indices, BufferDataUsage.STATIC_DRAW)
    # Vertex Attribute Pointers
    vertexAttribPointer(0, 3, VertexAttribType.FLOAT, false, 3 * float32.sizeof(), 0)
    enableVertexAttribArray(0)

    # Upload `iResolution` vec2 uniform
    Shader.use()
    let uni = getUniformLocation(Shader, iResolutionName)
    assert(uni.int != -1, "Missing Uniform: " & $iResolutionName)
    glUniform2ui(uni.GLint, screenWidth.GLuint, screenHeight.GLuint)

    # Upload texture
    bindTexture(TextureTarget.TEXTURE_2D, Tex)

    texParameteri(TextureTarget.TEXTURE_2D, TextureParameter.TEXTURE_WRAP_S, GL_CLAMP_TO_BORDER)
    texParameteri(TextureTarget.TEXTURE_2D, TextureParameter.TEXTURE_WRAP_T, GL_CLAMP_TO_BORDER)
    texImage2D(TexImageTarget.TEXTURE_2D, 0.int32,
               distances.format, distances.width.int32, distances.height.int32,
               PixelDataFormat.RED_INTEGER, PixelDataType.UNSIGNED_BYTE, distances.bytes)
    glTexParameterfv(GL_TEXTURE_2D, GL_TEXTURE_BORDER_COLOR, cast[ptr GLfloat](OutOfBoundsColor[0].unsafeAddr))
    glActiveTexture(GL_TEXTURE0)

proc render*(): void =
    Shader.use()
    bindVertexArray(VAO) # Not necessary since we only have one VAO
    drawElements(DrawMode.TRIANGLES, 6, IndexType.UNSIGNED_INT, 0)
