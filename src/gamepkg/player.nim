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
    WalkingSpeed: Meter = 2.5
    FullRevolution = degToRad(360f)
    RotationSpeed* = degToRad(120f)
    DefaultTheta* = degToRad(90f)

type Player* = ref object of RootObj
    position*: Vec2f
    velocity*: Vec2f
    rotation*: Option[Rotation]
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
        rotation: none(Rotation),
        direction: none(Direction),
        theta: DefaultTheta
    )

method move*(this: Player, direction: Direction): void {.base.} =
    this.direction = some(direction)

method rotate*(this: Player, rotation: Rotation): void {.base.} =
    this.rotation = some(rotation)

method update*(this: Player, dt: float, walkSpeed = WalkingSpeed, rotateSpeed = RotationSpeed): void {.base.} =
    if not this.rotation.isNone:
        case this.rotation.get():
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

    if not this.direction.isNone:
        echo repr(this)
        case this.direction.get():
            of Forward:
                this.position.x += walkSpeed * this.velocity.x * dt
                this.position.y -= walkSpeed * this.velocity.y * dt
            of Backward:
                this.position.x -= walkSpeed * this.velocity.x * dt
                this.position.y += walkSpeed * this.velocity.y * dt

    this.rotation = none(Rotation)
    this.direction = none(Direction)
