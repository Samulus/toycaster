# 📥 Todo

# 🔬 Testing
* Add test for mapCoordinate -> cartesian  (and inverse)

# ⚡  Optimizations

# ✏️  Refactor
* Unify common image related code between playerIcon, wallRender
* Remove trailing whitespace from misc files

# 🐞 Bugs
* Map and playerIcon do not render correctly on Windows
* Make the separation between map coordinates and player cartesian coordinates more clear

# 🖼️  Graphics
* Scale Player icon so that it fits within a single map cell
* Player icon should keep correct aspect ratio
* Player icon should move within minimap with respect to player location

# 🔧 Mechanical

# ⏲️  In Progress
> Add test for finding horizontal intersection points
* Implement the raycasting algorithm
* Make the separation between map coordinates and player cartesian coordinates more clear

# ✔️  Done
* Minimap should keep correct aspect ratio
* DistanceTexture should use OpenGLImage
* Minimap should be scalable to arbitrary size
* Allow the player to wallk around in 2D space.
* Modify wallRender to use methods in Image.nim
* Add test for correct player movement