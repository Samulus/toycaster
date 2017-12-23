#
# game.nim
# Author: Samuel Vargas
#

import sdl2/sdl
import easygl
import opengl
import options

# Core Modules
import gamepkg/window
import gamepkg/event
import gamepkg/player
import gamepkg/input
import gamepkg/tick
import gamepkg/units
import gamepkg/map
import gamepkg/minimap

# OpenGL Modules
import gamepkg/gl/mapRender
import gamepkg/gl/wallRender

# Create the main application window
var gameWindow: GameWindow;
if not createGameWindow(gameWindow):
  sdl.logCritical(LOG_CATEGORY_VIDEO, "Failure to create GameWindow", -1)
  quit(QuitFailure)

# Load map from disk into memory
let mapArr = mapToArray("levels/001.txt")
if mapArr.isNone:
  sdl.logCritical(LOG_CATEGORY_APPLICATION, "Unable to open %s", "levels/001.txt")
  quit(QuitFailure)

# Init mapRenders
mapRender.init()
wallRender.init()

# Upload map to wall renderer
#wallRender.uploadMap(mapArr.get())

# Create game entities && start main loop
let p = player.ctor();
var running = true;

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
        break;

      # Keyboard Events
      of EventKind.KEYDOWN, EventKind.KEYUP:
        var direction: Direction
        if input.isMovementKey(event.get().key, direction):
          p.move(direction, event.get().key.state == sdl.PRESSED)

      # Window Resize Event
      of EventKind.WINDOWEVENT:
        if event.get().window.event == WINDOWEVENT_RESIZED:
          let width = event.get().window.data1
          let height = event.get().window.data2
          window.resize(width, height)

      else:
        discard

  # Update Game
  while tick.hasLag():
    p.update(dt)

  # Render Game
  window.clear()
  mapRender.use()
  mapRender.render()
  wallRender.use()
  wallRender.render()
  window.swap(gameWindow)
