# Quaternions

 http://www.opengl-tutorial.org/intermediate-tutorials/tutorial-17-quaternions/#how-do-i-create-a-quaternion-in-c-


```
x = RotationAxis.x * sin(RotationAngle / 2)
y = RotationAxis.y * sin(RotationAngle / 2)
z = RotationAxis.z * sin(RotationAngle / 2)
w = cos(RotationAngle / 2)
```

When one is utilizing quaternions to achieve gimbal lock-free
rotations they should adhere to this formula.

If you want to rotate something along a given rotation axis (which is a 3D vector
representing the direction we want to rotate along.) You need:

A vector pointing in the direction to rotate
A rotation amount to sweep


* Rotation Axis (Vector3)
* Rotation Angle (Theta)