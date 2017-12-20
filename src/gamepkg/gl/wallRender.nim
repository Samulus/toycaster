#
# wallRender.nim
# Author: Samuel Vargas
#
# The wallRender module works by drawing a fullscreen quad and
# sending the map data to the GPU using a uniform.
#
# In OpenGL land the negative Z axis is going into the screen away
# from you and the positive Z axis is coming out of the screen poking
# you in the chest
#
# This module assigns the first row of the map data a Z value of 0 and
# then increments each Z position by 1
#

#
# Data to upload:
#   Map Data
#   Player Position
#

import ../map

import opengl
import easygl
import easygl.utils
import sequtils
import os

const
    MapDataUniformName = "mapData"
    ExpectedRows = 9
    ExpectedColumns = 7

var VAO: VertexArrayId
var VBO: BufferId
var EBO: BufferId
var Shader: ShaderProgramId

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

var FlatMapData: seq[uint32]

const
    fragShaderPath = "./glsl/wall.frag"
    vertShaderPath = "./glsl/wall.vert"

proc init*(): void =
    Shader = createAndLinkProgram(vertShaderPath, fragShaderPath)
    VAO = genVertexArray()
    VBO = genBuffer()
    EBO = genBuffer()
    bindVertexArray(VAO)

proc use*(): void =
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

# OpenGL version < 4 doesn't support 2D arrays as uniforms so we convert
# the 2D map into a 1D map and upload that
proc uploadMap*(map: LevelMap): void =
    Shader.use()
    let mapDataLocation = getUniformLocation(Shader, MapDataUniformName)

    FlatMapData = newSeq[uint32]()

    var size = 0
    for row in map:
        for tile in row:
            FlatMapData.add(tile.uint32)
            inc(size)

    # TODO: Submit a pull request to easygl to add 'Uniform1iv' procedure calls
    opengl.glUniform1uiv(mapDataLocation.GLint, size.GLsizei, cast[ptr GLuint](FlatMapData[0].unsafeAddr))

proc render*(): void =
    Shader.use()
    bindVertexArray(VAO) # Not necessary since we only have one VAO
    drawElements(DrawMode.TRIANGLES, 6, IndexType.UNSIGNED_INT, 0)