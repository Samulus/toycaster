#
# event.nim
# Author: Samuel Vargas
#

import sdl2/sdl
import options

proc getEvent*(): Option[sdl.Event] =
    sdl.clearError();
    var ev: sdl.Event;
    if sdl.waitEventTimeout(ev.addr, 0) > 0:
        return some(ev)