#
# game.nim
# Author: Samuel Vargas
#

import sdl2/sdl
import options
import gamepkg/window
import gamepkg/event
import gamepkg/player
import gamepkg/input

var gameWindow: GameWindow;

if not createGameWindow(gameWindow):
  stderr.writeLine("Failure to create GameWindow", -1)

var running = true;

let p = player.ctor();

while running:
  paintBlack(gameWindow)

  let keyboard = keyboardState()

  let event = getEvent()
  if event.isSome():
    case event.get().kind:
      of EventKind.QUIT:
        running = false;
      else:
        discard