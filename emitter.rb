require 'particle.rb'


class Emitter

  def initialize
    @emitter_img = $app.loadImage('data/emitter.png')
    @particle_img = $app.loadImage('data/particle.png')

    @position = Vec3D.new(0, 0, 0)
    @velocity = Vec3D.new(0, 0, 0)
    @color = {:r => 1.0, :g => 1.0, :b => 1.0}
    @diameter = 70

    @particles = []
  end

  def draw(pgl, gl, squarelist)
    set_velocity
    set_position

    draw_emitter(pgl, gl, squarelist)
    draw_particles(pgl, gl, squarelist)
  end

  def add_particles(n, options = {})
    n.times { @particles << Particle.new(@position, @velocity, options) }
  end

private

  def set_velocity
    velocity_to_mouse = Vec3D.new($app.mouseX - @position.x, $app.mouseY - @position.y, 0)
    @velocity.interpolateToSelf(velocity_to_mouse, 0.35)
  end

  def set_position
    @position.addSelf(@velocity)
  end

  def draw_emitter(pgl, gl, squarelist)
    pgl.bindTexture(@emitter_img)
    MyGl.render_image(gl, squarelist, @position, @diameter, @color)
  end

  def draw_particles(pgl, gl, squarelist)
    pgl.bindTexture(@particle_img)

    @particles.each {|particle| particle.draw(gl, squarelist) }
    @particles.delete_if {|particle| particle.is_dead? }
  end

end
