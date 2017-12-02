#
# game.nim
# Author: Samuel Vargas
#

import sdl2/sdl
import options
import gamepkg/window
import gamepkg/event

var gameWindow: GameWindow;

if not createGameWindow(gameWindow):
  stderr.writeLine("Failure to create GameWindow", -1)

var running = true;

while running:
  paintBlack(gameWindow)
  let event = getEvent()
  if event.isSome():
    case event.get().kind:
      of EventKind.QUIT:
        running = false;
      else:
        discard