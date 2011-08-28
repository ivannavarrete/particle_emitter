class Particle

  def initialize(position, velocity, options)
    @diameter = $app.random(10, 40)
    @position = Vec3D.new(position)
    @velocity = Vec3D.new(velocity)
    @trail = Array.new(@diameter / 3)   # trail length depends on size of particle

    @age = 0                            # goes from 0 to @lifespan
    @age_countdown =  1.0               # goes from 1.0 to 0.0 as particle ages
    @lifespan = @diameter.to_i          # the bigger you are the longer you live
    @is_dead = false

    # randomize starting position so that particles don't all start on the same pixel
    @position = position.add(Vec3D.randomVector.scaleSelf($app.random(5.0)))

    # randomize starting velocity so that particles don't all move at the same speed
    # in the same direction (scale down the original velocity by 0.5 to calm things down a bit)
    @velocity = velocity.scale(0.5).addSelf(Vec3D.randomVector.scaleSelf($app.random(10.0)))

    # copy options
    @options = options.clone

    # initialize trail
    @trail.map! { Vec3D.new(@position) }
  end

  def draw(gl, squarelist)
    set_velocity
    set_position

    # as the particle ages it will gain blue but will loose red and green
    color = {:r => @age_countdown,
             :g => @age_countdown * 0.75,
             :b => 1.0 - @age_countdown}

    # it will also get smaller with age
    diameter = @diameter * @age_countdown

    MyGl.render_image(gl, squarelist, @position, diameter, color)

    draw_trail(gl) if @options[:allow_trails]

    set_age
  end

  def is_dead?
    @age >= @lifespan || @position.x < 0 || @position.x > $app.width ||
                         @position.y < 0 || @position.y > $app.height
  end

private

  def set_velocity
    @velocity.addSelf(GRAVITY) if @options[:allow_gravity]
  end

  def set_position
    @position.addSelf(@velocity)

    # maybe replace with Array#rotate! once it's available in new ruby version
    @trail.unshift(@trail.pop.set(@position)) if @options[:allow_trails]
  end

  def set_age
    @age += 1 if @age < @lifespan
    @age_countdown = 1.0 - @age.to_f / @lifespan.to_f
  end

  def draw_trail(gl)
    gl.glPushAttrib(GL::GL_ENABLE_BIT)
    gl.glDisable(GL::GL_TEXTURE_2D)
    gl.glBegin(GL::GL_QUAD_STRIP)

    v = Vec3D.new(0, 1, 0)
    trail_length = @trail.length

    (trail_length - 1).times do |i|
      per = 1.0 - i.to_f / trail_length
      point = @trail[i]

      xp = point.x
      yp = point.y
      zp = point.z

      perp0 = @trail[i].sub(@trail[i+1])
      perp1 = perp0.cross(v).normalize
      perp2 = perp0.cross(perp1).normalize
      perp1 = perp0.cross(perp2).normalize

      xoff = perp1.x * @diameter * @age_countdown * per * 0.1
      yoff = perp1.y * @diameter * @age_countdown * per * 0.1
      zoff = perp1.z * @diameter * @age_countdown * per * 0.1

      gl.glColor4f(per, per * 0.25, 1.0 - per, per * 0.5)
      gl.glVertex3f(xp - xoff, yp - yoff, zp - zoff)
      gl.glVertex3f(xp + xoff, yp + yoff, zp + zoff)
    end

    gl.glEnd
    gl.glPopAttrib
  end

  def draw_trail_inline(gl)
    gl.glPushAttrib(GL::GL_ENABLE_BIT)
    gl.glDisable(GL::GL_TEXTURE_2D)
    gl.glBegin(GL::GL_QUAD_STRIP)

    trail_length = @trail.length

    (trail_length - 1).times do |i|
      per = 1.0 - i.to_f / trail_length
      point = @trail[i]
      nextpoint = @trail[i+1]

      xp = point.x
      yp = point.y
      zp = point.z

      # perp0 = @trail[i].sub(@trail[i+1])
      x0 = point.x - nextpoint.x
      y0 = point.y - nextpoint.y
      z0 = point.z - nextpoint.z

      # perp1 = perp0.cross(Vec3D.new(0, 1, 0)).normalize
      length = Math.sqrt(z0 * z0 + x0 * x0)
      if length != 0
        x1 = -z0 / length
        y1 = 0.0
        z1 = x0 / length
      else
        x1 = y1 = z1 = 0.0
      end

      # perp2 = perp0.cross(perp1).normalize
      x2 = (y0 * z1) - (z0 * y1)
      y2 = (z0 * x1) - (x0 * z1)
      z2 = (x0 * y1) - (y0 * x1)

      length = Math.sqrt(x2 * x2 + y2 * y2 + z2 * z2)
      if length != 0
        x2 /= length
        y2 /= length
        z2 /= length
      else
        x2 = y2 = z2 = 0.0
      end

      # perp1 = perp0.cross(perp2).normalize
      x1 = (y0 * z2) - (z0 * y2)
      y1 = (z0 * x2) - (x0 * z2)
      z1 = (x0 * y2) - (y0 * x2)
      length = Math.sqrt(x1 * x1 + y1 * y1 + z1 * z1)
      x1 /= length
      y1 /= length
      z1 /= length

      # calculate offset
      mult = @diameter * @age_countdown * per * 0.1
      xoff = x1 * mult
      yoff = y1 * mult
      zoff = z1 * mult

      # draw trail segment
      gl.glColor4f(per, per * 0.25, 1.0 - per, per * 0.5)
      gl.glVertex3f(xp - xoff, yp - yoff, zp - zoff)
      gl.glVertex3f(xp + xoff, yp + yoff, zp + zoff)
    end

    gl.glEnd
    gl.glPopAttrib
  end

end
