#
# player.nim
# Author: Samuel Vargas
#

import glm
import units
import options

const
    WalkingSpeed: Meter = 1.4

type Player = ref object of RootObj
    position: Vec3f
    forward: Vec3f
    rotation: Vec3f
    direction: Option[Direction]

proc ctor*(): Player =
    result = Player();
    result.position = vec3f(0, 0, 0)
    result.forward = vec3f(0, 0, -1)
    result.rotation = vec3f(0, 0, 0)

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
        else:
            discard
    this.direction = none(Direction)