#
# window.nim
# Author: Samuel Vargas
#

import sdl2/sdl

const
    Title = "Game"
    Width = 1920
    Height = 1080
    WindowFlags = 0
    RendererFlags = sdl.RENDERER_ACCELERATED or
                    sdl.RENDERER_PRESENTVSYNC

type GameWindow* = ref object of RootObj
    window*: sdl.Window
    renderer*: sdl.Renderer

proc createGameWindow*(gameWindow: var GameWindow): bool =
    gameWindow = GameWindow()

    if sdl.init(sdl.INIT_EVERYTHING) != 0:
        stderr.writeLine("sdl.init(sdl.INIT_EVERYTHING) failed: " & $sdl.getError(), -1)
        return false

    gameWindow.window = sdl.createWindow(
        Title,
        sdl.WINDOWPOS_CENTERED,
        sdl.WINDOWPOS_CENTERED,
        Width,
        Height,
        WindowFlags)

    if gameWindow.window == nil:
        stderr.writeLine("sdl.createWindow returned nil", -1)
        return false;

    gameWindow.renderer = sdl.createRenderer(
        gameWindow.window,
        -1,
        RendererFlags
        )

    if gameWindow.renderer == nil:
        stderr.writeLine("sdl.createRenderer returned nil", -1)
        return false

    return true

proc swapBuffers*(gameWindow: var GameWindow): void =
    sdl.clearError();
    discard sdl.setRenderDrawColor(gameWindow.renderer, 0, 0, 0, 0)
    discard sdl.renderClear(gameWindow.renderer)
    sdl.renderPresent(gameWindow.renderer)
    #discard sdl.renderPresent(gameWindow.renderer)