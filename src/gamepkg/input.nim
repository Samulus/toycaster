#
# input.nim
# Author: Samuel Vargas
#

import sdl2/sdl

const
    Forward = sdl.SCANCODE_W
    Backward = sdl.SCANCODE_S
    LeftTurn = sdl.SCANCODE_A
    RightTurn = sdl.SCANCODE_D

proc keyboardState*(): ptr array[NUM_SCANCODES.int, uint8] =
    return sdl.getKeyboardState(nil)

proc isForwardKeyDown*(keyboardState: ptr array[NUM_SCANCODES.int, uint8]): bool =
    if keyboardState == nil:
        sdl.logCritical(LOG_CATEGORY_ERROR, "isForwardKeyDown called with null keyboard state")
        return false;
    return keyboardState[Forward] == 1

proc isBackwardKeyDown*(keyboardState: ptr array[NUM_SCANCODES.int, uint8]): bool =
    if keyboardState == nil:
        sdl.logCritical(LOG_CATEGORY_ERROR, "isBackwardKeyDown called with null keyboard state")
        return false;
    return keyboardState[Backward] == 1

proc isLeftTurnKeyDown*(keyboardState: ptr array[NUM_SCANCODES.int, uint8]): bool =
    if keyboardState == nil:
        sdl.logCritical(LOG_CATEGORY_ERROR, "isLeftTurnKeyDown called with null keyboard state")
        return false;
    return keyboardState[LeftTurn] == 1

proc isRightTurnKeyDown*(keyboardState: ptr array[NUM_SCANCODES.int, uint8]): bool =
    if keyboardState == nil:
        sdl.logCritical(LOG_CATEGORY_ERROR, "isRightTurnKeyDown called with null keyboard state")
        return false;
    return keyboardState[RightTurn] == 1