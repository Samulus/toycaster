#
# minimapRender.nim
# Author: Samuel Vargas
#

import ../minimap
import image
import sdl2/sdl_image
import sdl2/sdl
import opengl
import easygl
import easygl.utils
import glm

const
    fragShaderPath = "./glsl/image.frag"
    vertShaderPath = "./glsl/image.vert"
    ImageUniformName = "image"
    TransformationUniformName = "transform"

var
    VAO: VertexArrayId
    VBO: BufferId
    EBO: BufferId
    Shader: ShaderProgramId
    Tex: TextureId
    Transformation = mat4f(1)
                    .scale(2.5,2.5,2.5)
                    .translate(0,0,0)

proc init*(): void =
    Shader = createAndLinkProgram(vertShaderPath, fragShaderPath)
    VAO = genVertexArray()
    VBO = genBuffer()
    EBO = genBuffer()
    Tex = genTexture()
    bindVertexArray(VAO)

proc use*(minimap: OpenGLImage): void =
    bindVertexArray(VAO)

    # Upload Transformation Matrix
    Shader.use()
    let transform = getUniformLocation(Shader, TransformationUniformName)
    assert(transform.int != -1, "Missing Uniform: " & $ImageUniformName)
    glUniformMatrix4fv(transform.GLint, 1, false, Transformation.caddr)

    # Upload minimap
    minimap.bindToTextureUnit(Tex, 0)
    minimap.copyVertexAttributesToGPU(VBO, EBO)
    minimap.pairTextureWithSampler(Shader, ImageUniformName)
    minimap.setupParameters()
    minimap.uploadToGPU()

proc render*(): void =
    Shader.use()
    bindVertexArray(VAO)
    drawElements(DrawMode.TRIANGLES, 6, IndexType.UNSIGNED_INT, 0)