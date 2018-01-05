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

# Handling Player Rotations
The player is an XY point with a theta that corresponds to how much
we've rotated. The quadrant that the angle that theta is sweeping out
corresponds to how much we should 

Q1 -> Increment X, Decrement Y 
Q2 -> Decrement X, Decrement Y 
Q3 -> Decrement X, Increment Y
Q4 -> Increment X, Increment Y

It's basically an inverted cartesian plane to match the layout of the map.

The next step is to calculate the rate of change that we should increment or
decrement by for each vertex. 
If Theta is 45, 135, 225, 315 degrees X and Y should vary at the same rate.
We can use sin + cos to calculate it

position.x += WalkingSpeed * velocityX
position.y += WalkingSpeed * velocityY