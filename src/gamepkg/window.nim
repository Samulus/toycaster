#
# window.nim
# Author: Samuel Vargas
#

import sdl2/sdl
import easygl
import opengl

const
    Title = "Game"
    Width = 1280
    Height = 720
    WindowFlags = sdl.WINDOW_ALLOW_HIGHDPI or
                  sdl.WINDOW_RESIZABLE or
                  sdl.WINDOW_OPENGL

const Attributes = @[
    (name: GLAttr.GL_CONTEXT_MAJOR_VERSION, value: 3),
    (name: GLAttr.GL_CONTEXT_MINOR_VERSION, value: 2),
    (name: GLAttr.GL_ACCELERATED_VISUAL, value: 1),
    (name: GLattr.GL_DOUBLEBUFFER, value: 1),
]

type GameWindow* = ref object of RootObj
    window*: sdl.Window
    glContext*: sdl.GLContext

proc createGameWindow*(gameWindow: var GameWindow): bool =
    sdl.clearError()
    gameWindow = GameWindow()

    # Setup SDL2 Window
    if sdl.init(sdl.InitVideo) != 0:
        sdl.logError(sdl.LOG_CATEGORY_APPLICATION, "sdl.init(sdl.INIT_EVERYTHING) failed: ")
        sdl.logError(sdl.LOG_CATEGORY_APPLICATION, sdl.getError())
        return false

    gameWindow.window = sdl.createWindow(
        Title,
        sdl.WINDOWPOS_CENTERED,
        sdl.WINDOWPOS_CENTERED,
        Width,
        Height,
        WindowFlags)

    if gameWindow.window == nil:
        sdl.logError(sdl.LOG_CATEGORY_VIDEO, "Failure to create SDL2 Window")
        sdl.logError(sdl.LOG_CATEGORY_VIDEO, sdl.getError())
        return false

    # Setup OpenGL
    for attrib in Attributes:
        if sdl.glSetAttribute(attrib.name, attrib.value) == -1:
            sdl.logError(sdl.LOG_CATEGORY_VIDEO, "glSetAttribute failed: %s = %d could not be set.",
                         attrib.name, attrib.value)
            sdl.logError(sdl.LOG_CATEGORY_VIDEO, sdl.getError())
            return false

    if sdl.glMakeCurrent(gameWindow.window, gameWindow.glContext) < 0:
        sdl.logError(sdl.LOG_CATEGORY_VIDEO, "glMakeCurrent failed:")
        sdl.logError(sdl.LOG_CATEGORY_VIDEO, sdl.getError())
        return false

    gameWindow.glContext = sdl.glCreateContext(gameWindow.window)
    if gameWindow == nil:
        sdl.logError(sdl.LOG_CATEGORY_VIDEO, "glCreateContext failed:")
        sdl.logError(sdl.LOG_CATEGORY_VIDEO, sdl.getError())
        return false

    if sdl.glSetSwapInterval(1) < 0:
        sdl.logError(sdl.LOG_CATEGORY_VIDEO, "glSetSwapInterval failed:")
        sdl.logError(sdl.LOG_CATEGORY_VIDEO, sdl.getError())
        return false

    loadExtensions()
    easygl.enable(Capability.DEPTH_TEST)
    return true

proc paintBlack*(gameWindow: var GameWindow): void =
    easygl.clearColor(0,0,0,1)
    easygl.clear(BufferMask.COLOR_BUFFER_BIT)
    sdl.glSwapWindow(gameWindow.window)