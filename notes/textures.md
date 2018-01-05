URL: https://stackoverflow.com/questions/14231391/what-is-the-function-of-glactivetexture-and-gl-texture0-in-opengl

# Creating a Texture
``
glGenTextures(1, &tex)
``

# Specifying which "photo frame" to use 
``
let maximumTextures = GL_MAX_COMBINED_TEXTURE_IMAGE_UNITS - 1
glActiveTexture(GL_TEXTURE0 + n) // n = frame
``

# Associating our photo ID with the photo frame
glBindTexture

# Uploading ImageData
glTexImage2D