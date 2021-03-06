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
import imageFloat
import opengl
import easygl
import easygl.utils
import sequtils
import os
import glm

let Vertices : seq[float32]  =
  @[
  1.0'f32,  1.0'f32, 0.0'f32,  # top right
  1.0'f32, -1.0'f32, 0.0'f32,  # bottom right
 -1.0'f32, -1.0'f32, 0.0'f32,  # bottom left
 -1.0'f32,  1.0'f32, 0.0'f32 ] # top left

const
    iResolutionName = "iResolution"
    WallDataName = "wallData"
    WallColorName = "wallColor"
    fragShaderPath = "./glsl/wall.frag"
    vertShaderPath = "./glsl/wall.vert"

var
    VAO: VertexArrayId
    VBO: BufferId
    EBO: BufferId
    Shader: ShaderProgramId
    DistanceTextureId: TextureId
    WallColorTextureId: TextureId

proc init*(): void =
    Shader = createAndLinkProgram(vertShaderPath, fragShaderPath)
    VAO = genVertexArray()
    VBO = genBuffer()
    EBO = genBuffer()
    DistanceTextureId = genTexture()
    WallColorTextureId = genTexture()
    bindVertexArray(VAO)

proc use*(screenWidth, screenHeight: uint, distances: var OpenGLImageFloat, wallColors: var OpenGLImage): void =
    bindVertexArray(VAO)

    # Setup distanceTexture each frame
    distances.width = screenWidth
    distances.bindToTextureUnit(DistanceTextureId, 1)
    distances.copyVertexAttributesToGPU(VBO, EBO, Vertices)
    distances.pairTextureWithSampler(Shader, WallDataName, 1)
    distances.setupParameters()
    distances.uploadToGPU()

    # Setup wallColors each frame
    wallColors.width = screenWidth
    wallColors.bindToTextureUnit(WallColorTextureId, 2)
    wallColors.pairTextureWithSampler(Shader, WallColorName, 2)
    wallColors.setupParameters()
    wallColors.uploadToGPU()

    # Upload `iResolution` vec2 uniform
    Shader.use()
    let iResolution = getUniformLocation(Shader, iResolutionName)
    assert(iResolution.int != -1, "Missing Uniform: " & $iResolutionName)
    glUniform2ui(iResolution.GLint, screenWidth.GLuint, screenHeight.GLuint)

proc render*(): void =
    Shader.use()
    bindVertexArray(VAO)
    drawElements(DrawMode.TRIANGLES, 6, IndexType.UNSIGNED_INT, 0)
