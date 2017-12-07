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
import gamepkg/tick
import gamepkg/units
import gamepkg/map

var gameWindow: GameWindow;

if not createGameWindow(gameWindow):
  sdl.logCritical(LOG_CATEGORY_VIDEO, "Failure to create GameWindow", -1)
  quit(QuitFailure)

var running = true;

let p = player.ctor();

let level = mapToArray("levels/001.txt")
if level.isNone:
  sdl.logCritical(LOG_CATEGORY_APPLICATION, "Unable to open %s", "levels/001.txt")
  quit(QuitFailure)

while running:
  # Tick gameloop every frame
  let dt = tick.update();

  # Handle Input
  let event = getEvent()
  if event.isSome():
    case event.get().kind:
      # Application Quit Events
      of EventKind.QUIT:
        running = false;
      # Keyboard Events
      of EventKind.KEYDOWN, EventKind.KEYUP:
        var direction: Direction
        if input.isMovementKey(event.get().key, direction):
          p.move(direction, event.get().key.state == sdl.PRESSED)
      else:
        discard

  # Update Game
  while tick.hasLag():
    p.update(dt)

  # Render Game
  echo repr(p)
  paintBlack(gameWindow)
