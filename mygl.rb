class MyGl

  class << self

    # Define a display list for drawing a square.
    def init_square_display_list(gl)
      squarelist = gl.glGenLists(1)               # create and reserve a display list name

      gl.glNewList(squarelist, GL::GL_COMPILE)    # create display list

      gl.glBegin(GL::GL_POLYGON)
      gl.glTexCoord2f(0, 0);  gl.glVertex2f(-0.5, -0.5)
      gl.glTexCoord2f(1, 0);  gl.glVertex2f( 0.5, -0.5)
      gl.glTexCoord2f(1, 1);  gl.glVertex2f( 0.5,  0.5)
      gl.glTexCoord2f(0, 1);  gl.glVertex2f(-0.5,  0.5)
      gl.glEnd

      gl.glEndList                                # end display list

      squarelist
    end

    # Render an image that was previously set with g.bindTexture().
    def render_image(gl, displaylist, position, diameter, color)
      gl.glPushMatrix

      gl.glTranslatef(position.x, position.y, position.z)
      gl.glScalef(diameter, diameter, diameter)
      gl.glColor3f(color[:r], color[:g], color[:b])
      gl.glCallList(displaylist)

      gl.glPopMatrix
    end

  end

end
