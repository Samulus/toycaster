#
# input.nim
# Author: Samuel Vargas
#

import sdl2/sdl
import units

const
    ForwardKey = sdl.SCANCODE_W
    BackwardKey = sdl.SCANCODE_S
    LeftTurnKey = sdl.SCANCODE_A
    RightTurnKey = sdl.SCANCODE_D

proc isRotationKey*(keyboardState: ptr array[NUM_SCANCODES.int, uint8], 
                    rotation: var Rotation): bool =
    if keyboardState[LeftTurnKey] > 0:
        rotation = Rotation.Left
    elif keyboardState[RightTurnKey] > 0:
        rotation = Rotation.Right
    else:
        return false
    return true

proc isDirectionKey*(keyboardState: ptr array[NUM_SCANCODES.int, uint8], 
                    direction: var Direction): bool =
    if keyboardState[ForwardKey] > 0:
        direction = Direction.Forward
    elif keyboardState[BackwardKey] > 0:
        direction = Direction.Backward
    else:
        return false
    return true