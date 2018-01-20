#
# input.nim
# Author: Samuel Vargas
#

import sdl2/sdl
import units

const
    # Exit
    QuitKey = sdl.SCANCODE_ESCAPE

    # WASD
    W_ForwardKey = sdl.SCANCODE_W
    S_BackwardKey = sdl.SCANCODE_S
    A_LeftTurnKey = sdl.SCANCODE_A
    D_RightTurnKey = sdl.SCANCODE_D

    # Arrow Keys
    Up_ForwardKey = sdl.SCANCODE_UP
    Down_BackwardKey = sdl.SCANCODE_DOWN
    Left_LeftTurnKey = sdl.SCANCODE_LEFT
    Right_RightTurnkey = sdl.SCANCODE_RIGHT

proc isQuitKey*(keyboardState: ptr array[NUM_SCANCODES.int, uint8]): bool =
    return keyboardState[QuitKey] > 0


proc isRotationKey*(keyboardState: ptr array[NUM_SCANCODES.int, uint8],
                    rotation: var Rotation): bool =
    if keyboardState[A_LeftTurnKey] > 0 or keyboardState[Left_LeftTurnKey] > 0:
        rotation = Rotation.Left
    elif keyboardState[D_RightTurnKey] > 0 or keyboardState[Right_RightTurnkey] > 0:
        rotation = Rotation.Right
    else:
        return false
    return true

proc isDirectionKey*(keyboardState: ptr array[NUM_SCANCODES.int, uint8],
                    direction: var Direction): bool =
    if keyboardState[W_ForwardKey] > 0 or keyboardState[Up_ForwardKey] > 0:
        direction = Direction.Forward
    elif keyboardState[S_BackwardKey] > 0 or keyboardState[Down_BackwardKey] > 0:
        direction = Direction.Backward
    else:
        return false
    return true
