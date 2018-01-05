#
# player.nim
# Author: Samuel Vargas
#

import glm
import math
import units
import options

const
    WalkingSpeed: Meter = 1.4
    FullRevolution = degToRad(360f)
    RotationSpeed = degToRad(90f)

type Player = ref object of RootObj
    position*: Vec2f
    snap*: Vec2f
    velocity*: Vec2f
    direction*: Option[Direction]
    theta*: float

proc ctor*(): Player =
    return Player(
        position: vec2f(0, 0),
        snap: vec2f(0, 0),
        velocity: vec2f(0, 1),
        direction: none(Direction),
        theta: degToRad(90f)
    );

method move*(this: Player, direction: Direction, pressed: bool): void {.base.} =
    if not pressed:
        this.direction = none(Direction)
    else:
        this.direction = some(direction)

method update*(this: Player, dt: float): void {.base.} =
    if this.direction.isNone:
        return
    case this.direction.get():
        of Forward:
            this.position.x -= WalkingSpeed * this.velocity.x * dt
            this.position.y -= WalkingSpeed * this.velocity.y * dt
            this.snap.x = floor(this.position.x)
            this.snap.y = floor(this.position.y)
        of Backward:
            this.position.x += WalkingSpeed * this.velocity.x * dt
            this.position.y += WalkingSpeed * this.velocity.y * dt
            this.snap.x = floor(this.position.x)
            this.snap.y = floor(this.position.y)
        of Left:
            this.theta += degToRad(RotationSpeed) * 1 # dt
            if this.theta > FullRevolution:
                this.theta = 0
            this.velocity.x = math.cos(this.theta)
            this.velocity.y = math.sin(this.theta)
        of Right:
            if this.theta < 0:
                this.theta = FullRevolution
            this.theta -= degToRad(RotationSpeed) * 1 # dt
            this.velocity.x = math.cos(this.theta)
            this.velocity.y = math.sin(this.theta)

    echo repr(this)
    echo this.theta.radToDeg
    this.direction = none(Direction)