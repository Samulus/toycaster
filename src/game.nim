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
import gamepkg/gl/playerIcon
import gamepkg/gl/wallRender
import gamepkg/gl/distanceTexture

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

# Init renderers
mapRender.init()
wallRender.init()
playerIcon.init(gameWindow.width(), gameWindow.height())

# Generate 1D texture with wall heights
var distances = distanceTexture.regenerateImage(gameWindow.width())
wallRender.use(gameWindow.width(), gameWindow.height(), distances)

# Generate minimap texture
let minimapImage = minimap.toOpenGLImage(mapArr.get(), gameWindow.width(), gameWindow.height())

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
          let width = gameWindow.width()
          let height = gameWindow.height()
          distances = distanceTexture.regenerateImage(gameWindow.width())
          window.resize(width, height)
          wallRender.use(width, height, distances)

      else:
        discard

  # Update Game
  while tick.hasLag():
    p.update(dt)

  # Render Game
  window.clear()
  mapRender.use(minimapImage)
  playerIcon.render()
  mapRender.render()
  wallRender.use(gameWindow.width().uint, gameWindow.height().uint, distances)
  wallRender.render()
  window.swap(gameWindow)
