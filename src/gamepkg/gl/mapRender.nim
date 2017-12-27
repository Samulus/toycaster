#
# mapRender.nim
# Author: Samuel Vargas
#

import ../minimap
import image
import opengl
import easygl
import easygl.utils

# Set up vertex data
let vertices : seq[float32]  =
  @[
  # Vertex Locations (XYZ)
  0.5'f32,  0.5'f32, 0.0'f32,  # top right
  0.5'f32, -0.5'f32, 0.0'f32,  # bottom right
 -0.5'f32, -0.5'f32, 0.0'f32,  # bottom left
 -0.5'f32,  0.5'f32, 0.0'f32,  # top left
  # Texture Coordinate Locations (ST)
  1'f32, 1'f32, # top right
  1'f32, 0'f32, # bottom right
  0'f32, 0'f32, # bottom left
  0'f32, 1'f32, # top left
  ]

let indices : seq[uint32] =
  @[
  0'u32, 1'u32, 3'u32,   # first triangle
  1'u32, 2'u32, 3'u32 ]  # second triangle

const
    fragShaderPath = "./glsl/hello_triangle.frag"
    vertShaderPath = "./glsl/hello_triangle.vert"
    MinimapUniformName = "minimapImage"

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

proc use*(mapImage: RGBAImage): void =
    # Bind VAO
    bindVertexArray(VAO)
    # Copy Vertices to GPU Buffer
    bindBuffer(BufferTarget.ARRAY_BUFFER, VBO)
    bufferData(BufferTarget.ARRAY_BUFFER, vertices, BufferDataUsage.DYNAMIC_DRAW)
    # Copy Element Indices to GPU Buffer
    bindBuffer(BufferTarget.ELEMENT_ARRAY_BUFFER, EBO)
    bufferData(BufferTarget.ELEMENT_ARRAY_BUFFER, indices, BufferDataUsage.DYNAMIC_DRAW)
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
    let minimap = getUniformLocation(Shader, MinimapUniformName)
    assert(minimap.int != -1, "Missing Uniform: " & $MinimapUniformName)
    Shader.use()
    glUniform1i(minimap.GLint, 0.GLint)

    # Setup Clamping / Filtering
    texParameteri(TextureTarget.TEXTURE_2D, TextureParameter.TEXTURE_WRAP_S, GL_CLAMP_TO_BORDER)
    texParameteri(TextureTarget.TEXTURE_2D, TextureParameter.TEXTURE_WRAP_T, GL_CLAMP_TO_BORDER)
    glTexParameterfv(GL_TEXTURE_2D, GL_TEXTURE_BORDER_COLOR, cast[ptr GLfloat](OutOfBoundsColor[0].unsafeAddr))

    texParameteri(TextureTarget.TEXTURE_2D, TextureParameter.TEXTURE_MIN_FILTER, GL_NEAREST);
    texParameteri(TextureTarget.TEXTURE_2D, TextureParameter.TEXTURE_MAG_FILTER, GL_NEAREST);

    # Upload to GPU
    texImage2D(TexImageTarget.TEXTURE_2D, 0.int32,
               GL_RGBA8.TextureInternalFormat, mapImage.width.int32, mapImage.height.int32,
               PixelDataFormat.RGBA, PixelDataType.UNSIGNED_BYTE, mapImage.bytes)

proc render*(): void =
    Shader.use()
    bindVertexArray(VAO) # Not necessary since we only have one VAO
    activeTexture(TextureUnit.TEXTURE0)
    bindTexture(TextureTarget.TEXTURE_2D, Tex)
    drawElements(DrawMode.TRIANGLES, 6, IndexType.UNSIGNED_INT, 0)
