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


proc isMovementKey*(key: KeyboardEventObj, direction: var Direction): bool =
    if key.keysym.scancode == ForwardKey:
        direction = Direction.Forward
    elif key.keysym.scancode == BackwardKey:
        direction = Direction.Backward
    elif key.keysym.scancode == LeftTurnKey:
        direction = Direction.Left
    elif key.keysym.scancode == RightTurnKey:
        direction = Direction.Right
    else:
        return false
    return true