#
# event.nim
# Author: Samuel Vargas
#

import sdl2/sdl

proc hasEvent*(gameEvent: var sdl.Event): bool =
    sdl.clearError();

    var maybeEvent: ptr sdl.Event;
    if (sdl.waitEventTimeout(maybeEvent, 0)) < 0:
        return false;

    gameEvent = (maybeEvent)[]
    return true