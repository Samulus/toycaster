#
# tick.nim
# Author: Samuel Vargas
#

import sdl2/sdl
import units

const
    MsPerUpdate: float = 0.016

var
    LastTime: float = 0
    Lag: float = 0
    TickingStarted = false

func update*(): float =
    if not TickingStarted:
        TickingStarted = true
        LastTime = sdl.getPerformanceCounter().float
    let frequency = sdl.getPerformanceFrequency().float
    let now = sdl.getPerformanceCounter().float
    let elapsed = (now - LastTime) / frequency
    LastTime = now
    Lag += elapsed
    return elapsed


func hasLag*(): bool =
    if Lag >= MsPerUpdate:
        Lag -= MsPerUpdate
        return true
    return false
