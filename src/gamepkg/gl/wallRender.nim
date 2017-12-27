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
    WallDataName = "wallData"
    fragShaderPath = "./glsl/wall.frag"
    vertShaderPath = "./glsl/wall.vert"

let
    OutOfBoundsColor: seq[GLfloat] = @[0.0f, 0.89803f, 1.0f, 1.0f]

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
    bufferData(BufferTarget.ARRAY_BUFFER, Vertices, BufferDataUsage.DYNAMIC_DRAW)
    # Copy Element Indices to GPU Buffer
    bindBuffer(BufferTarget.ELEMENT_ARRAY_BUFFER, EBO)
    bufferData(BufferTarget.ELEMENT_ARRAY_BUFFER, Indices, BufferDataUsage.DYNAMIC_DRAW)
    # Vertex Attribute Pointers
    vertexAttribPointer(0, 3, VertexAttribType.FLOAT, false, 3 * float32.sizeof(), 0)
    enableVertexAttribArray(0)

    # Upload `iResolution` vec2 uniform
    Shader.use()
    let iResolution = getUniformLocation(Shader, iResolutionName)
    assert(iResolution.int != -1, "Missing Uniform: " & $iResolutionName)
    glUniform2ui(iResolution.GLint, screenWidth.GLuint, screenHeight.GLuint)

    # Activate and Bind Texture
    activeTexture(TextureUnit.TEXTURE0)
    bindTexture(TextureTarget.TEXTURE_2D, Tex)

    # Tell GPU to this sampler2d belongs to Texture Unit 0
    let wallData = getUniformLocation(Shader, WallDataName)
    Shader.use()
    glUniform1i(wallData.GLint, 0.GLint)

    # Setup Clamping / Filtering
    texParameteri(TextureTarget.TEXTURE_2D, TextureParameter.TEXTURE_WRAP_S, GL_CLAMP_TO_BORDER)
    texParameteri(TextureTarget.TEXTURE_2D, TextureParameter.TEXTURE_WRAP_T, GL_CLAMP_TO_BORDER)
    glTexParameterfv(GL_TEXTURE_2D, GL_TEXTURE_BORDER_COLOR, cast[ptr GLfloat](OutOfBoundsColor[0].unsafeAddr))

    texParameteri(TextureTarget.TEXTURE_2D, TextureParameter.TEXTURE_MIN_FILTER, GL_NEAREST);
    texParameteri(TextureTarget.TEXTURE_2D, TextureParameter.TEXTURE_MAG_FILTER, GL_NEAREST);

    # Upload to GPU
    texImage2D(TexImageTarget.TEXTURE_2D, 0.int32,
               GL_RED.TextureInternalFormat, distances.width.int32, distances.height.int32,
               PixelDataFormat.RED, PixelDataType.UNSIGNED_BYTE, distances.bytes)


proc render*(): void =
    Shader.use()
    bindVertexArray(VAO) # Not necessary since we only have one VAO
    activeTexture(TextureUnit.TEXTURE0)
    bindTexture(TextureTarget.TEXTURE_2D, Tex)
    drawElements(DrawMode.TRIANGLES, 6, IndexType.UNSIGNED_INT, 0)
