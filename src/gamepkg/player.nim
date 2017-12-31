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
    UpAxis = vec3f(0, 1, 0)

type Player = ref object of RootObj
    position: Vec3f
    forward: Vec3f
    rotation: Quatf
    direction: Option[Direction]
    theta: float

proc ctor*(): Player =
    result = Player();
    result.position = vec3f(0, 0, 0)
    result.forward = vec3f(0, 0, -1)
    result.rotation = quatf(0,0,0,1)
    result.theta = 0

method position*(this: Player): Vec3f {.base.} =
    this.position

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
            this.position.z += WalkingSpeed * dt
        of Backward:
            this.position.z -= WalkingSpeed * dt
        of Left:
            this.theta -= degToRad(1.0)
            this.rotation = quatf(UpAxis, this.theta)
        of Right:
            this.theta += degToRad(1.0)
            this.rotation = quatf(UpAxis, this.theta)
        else:
            discard
    this.direction = none(Direction)