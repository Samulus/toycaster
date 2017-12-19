#
# mapRender.nim
# Author: Samuel Vargas
#

import ../minimap
import opengl
import easygl
import easygl.utils

# Set up vertex data
let vertices : seq[float32]  =
  @[
  0.5'f32,  0.5'f32, 0.0'f32,  # top right
  0.5'f32, -0.5'f32, 0.0'f32,  # bottom right
 -0.5'f32, -0.5'f32, 0.0'f32,  # bottom left
 -0.5'f32,  0.5'f32, 0.0'f32 ] # top left

let indices : seq[uint32] =
  @[
  0'u32, 1'u32, 3'u32,   # first triangle
  1'u32, 2'u32, 3'u32 ]  # second triangle

const
    fragShaderPath = "./glsl/hello_triangle.frag"
    vertShaderPath = "./glsl/hello_triangle.vert"

var VAO: VertexArrayId
var VBO: BufferId
var EBO: BufferId
var Shader: ShaderProgramId

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
    bufferData(BufferTarget.ARRAY_BUFFER, vertices, BufferDataUsage.STATIC_DRAW)
    # Copy Element Indices to GPU Buffer
    bindBuffer(BufferTarget.ELEMENT_ARRAY_BUFFER, EBO)
    bufferData(BufferTarget.ELEMENT_ARRAY_BUFFER, indices, BufferDataUsage.STATIC_DRAW)
    # Vertex Attribute Pointers
    vertexAttribPointer(0, 3, VertexAttribType.FLOAT, false, 3 * float32.sizeof(), 0)
    enableVertexAttribArray(0)

proc render*(): void =
    Shader.use()
    bindVertexArray(VAO) # Not necessary since we only have one VAO
    drawElements(DrawMode.TRIANGLES, 6, IndexType.UNSIGNED_INT, 0)