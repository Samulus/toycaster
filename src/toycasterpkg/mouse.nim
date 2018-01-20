#
# mouse.nim
# Author: Samuel Vargas
#

import sdl2/sdl
import opengl
import easygl
import math

const
    iMouseUniformName = "iMouse"
    RotateSpeed = 10f.degToRad()

proc getMouseRotation*(screenWidth, screenHeight: uint): float =
    var x, y: cint
    discard sdl.getRelativeMouseState(x.addr, y.addr)
    if x < 0:
        return -RotateSpeed
    elif x > 0:
        return RotateSpeed

    return 0