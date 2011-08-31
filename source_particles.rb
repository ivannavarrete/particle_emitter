require 'ruby-processing'
require 'lib/toxiclibscore'

require 'emitter.rb'
require 'mygl.rb'


Processing::App.load_library 'opengl'

java_import 'javax.media.opengl.GL'
java_import 'toxi.geom.Vec3D'


GRAVITY = Vec3D.new(0, 0.35, 0)
FLOORLEVEL = 400


class SourceParticles < Processing::App

  def setup
    render_mode(OPENGL)
    color_mode(RGB, 1.0)

    hint(ENABLE_OPENGL_4X_SMOOTH)

    gl = g.gl

    # wait for vrefresh until swapping buffers
    gl.setSwapInterval(1)

    g.beginGL

    @squarelist = MyGl.init_square_display_list(gl)

    g.endGL

    # options; turning all of them on will slow things down
    @options = {:allow_gravity => false,      # gravity vector
                :allow_trails => false,       # particle trails
                :allow_floor => false}        # add a floor

    @emitter = Emitter.new(@options)
  end

  def draw
    background(0.0)

    pgl = g
    gl = pgl.gl

    # turn on additive blending so we can draw glowing images
    # without needing to do any depth testing
    gl.glDepthMask(false)
    gl.glEnable(GL::GL_BLEND)
    gl.glBlendFunc(GL::GL_SRC_ALPHA, GL::GL_ONE)

    pgl.beginGL

    gl.glEnable(GL::GL_TEXTURE_2D)
    @emitter.draw(g, gl, @squarelist)
    gl.glDisable(GL::GL_TEXTURE_2D)

    pgl.endGL

    # add particles on mouse press; fewer if trails are on to avoid slowing things down too much
    if mouse_pressed?
      n = @options[:allow_trails] ? 5 : 10
      @emitter.add_particles(n, @options)
    end
  end

  def key_pressed
    case key.to_s.downcase
      when 'g' then @options[:allow_gravity] = ! @options[:allow_gravity]
      when 't' then @options[:allow_trails]  = ! @options[:allow_trails]
      when 'f' then @options[:allow_floor]   = ! @options[:allow_floor]
      when 'n' then @emitter.add_particles(1, @options)
      when 'q' then exit()
    end

    @emitter.options = @options
  end

end


SourceParticles.new(:title => 'Source Particles', :width => 800, :height => 600)
