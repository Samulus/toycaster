#
# player.nim
# Author: Samuel Vargas
#
# Notes:
#   Player.position.x is the COLUMN the player is in.
#   Player.position.y is the ROW the player is in.
#   The coordinate system is row-major (not cartesian)

import glm
import math
import units
import options
import map

const
    WalkingSpeed: Meter = 1.4
    FullRevolution = degToRad(360f)
    RotationSpeed* = degToRad(60f)
    DefaultTheta* = degToRad(90f)

type Player* = ref object of RootObj
    position*: Vec2f
    velocity*: Vec2f
    direction*: Option[Direction]
    theta*: float

proc ctor*(mapArr: LevelMap): Player =
    var
       spawnX = -1
       spawnY = -1

    for y in countup(0, len(mapArr) - 1, 1):
        for x in countup(0, len(mapArr[y]) - 1, 1):
            if mapArr[y][x] == TileType.Player:
                spawnX = x
                spawnY = y

    assert(spawnX != -1 and spawnY != -1, "Missing Player Spawn")

    return Player(
        position: vec2f(spawnX.float + 0.5, spawnY.float + 0.5),
        velocity: vec2f(cos(DefaultTheta), sin(DefaultTheta)),
        direction: none(Direction),
        theta: DefaultTheta
    )

method move*(this: Player, direction: Direction, pressed: bool): void {.base.} =
    if not pressed:
        this.direction = none(Direction)
    else:
        this.direction = some(direction)

method update*(this: Player, dt: float, walkSpeed = WalkingSpeed, rotateSpeed = RotationSpeed): void {.base.} =
    if this.direction.isNone:
        return
    case this.direction.get():
        of Forward:
            this.position.x += walkSpeed * this.velocity.x * dt
            this.position.y += walkSpeed * this.velocity.y * dt
        of Backward:
            this.position.x -= walkSpeed * this.velocity.x * dt
            this.position.y -= walkSpeed * this.velocity.y * dt
        of Left:
            this.theta += rotateSpeed * dt
            if this.theta >= FullRevolution:
                this.theta = 0
            this.velocity.x = math.cos(this.theta)
            this.velocity.y = math.sin(this.theta)
        of Right:
            if this.theta <= 0:
                this.theta = FullRevolution
            this.theta -= rotateSpeed * dt
            this.velocity.x = math.cos(this.theta)
            this.velocity.y = math.sin(this.theta)

    this.direction = none(Direction)
