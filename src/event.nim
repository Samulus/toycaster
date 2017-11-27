#
# event.nim
# Author: Samuel Vargas
#

import sdl2/sdl

proc has_event(event: sdl.Event): bool =
    return true