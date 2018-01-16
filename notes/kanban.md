# 📥 Todo

# 🔬 Testing

# ⚡  Optimizations

# ✏️  Refactor

# 🐞 Bugs

# 🖼️  Graphics
* Scale Player icon so that it fits within a single map cell
* Player icon should keep correct aspect ratio
* Player icon should move within minimap with respect to player location

# 🔧 Mechanical

# ⏲️  In Progress

# ✔️  Done
* Minimap should keep correct aspect ratio
* DistanceTexture should use OpenGLImage
* Minimap should be scalable to arbitrary size
* Allow the player to wallk around in 2D space.
* Modify wallRender to use methods in Image.nim
* Add test for correct player movement
* Make the separation between map coordinates and player cartesian coordinates more clear
* Add test for mapCoordinate -> cartesian  (and inverse)
* Add test for finding horizontal intersection points
* Continue on simplifying getHorizontalIntersection()
* Implement the raycasting algorithm
* Combine getVerticalIntersection && getHorizontalIntersection
* Modify wall.frag so that it only draws parts of walls
* Prevent assert from happening when 360 rotations occur
* Make the separation between map coordinates and player cartesian coordinates more clear
* Map and playerIcon do not render correctly on Windows
* Unify common image related code between playerIcon, wallRender
* Remove trailing whitespace from misc files
* Split distanceTexture.nim into raycast.nim + distanceTexture.nim
