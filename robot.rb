
class RobotWorld
  Position = Struct.new(:x, :y) do
    def resolve(size)
      self.x = x % size
      self.y = y % size
    end
  end

  class Robot
    FACING_OPTIONS=%i{top right bottom left}
    attr_reader :position, :facing
    def initialize
      @position = Position.new(0,0)
      @facing = :right
    end

    def draw
      case facing
      when :top then '^'
      when :right then '>'
      when :bottom then 'v'
      when :left then '<'
      end
    end

    def face(direction)
      @facing = case direction
      when 'top', 'up','north','n' then :top
      when 'right', 'east', 'e' then :right
      when 'bottom', 'down', 'south', 's' then :bottom
      when 'left', 'west', 'w' then :left
      else raise "Direction not recognised: #{direction.inspect}"
      end
    end

    def move(direction, distance = 1)
      distance = 1 if distance.to_i == 0 && distance != 0
      case direction
      when 'top', 'up','north','n', 'u'then position.y -= distance.to_i
      when 'right', 'east', 'e', 'r' then position.x += distance.to_i
      when 'bottom', 'down', 'south', 's', 'd' then position.y += distance.to_i
      when 'left', 'west', 'w', 'l' then position.x -= distance.to_i
      else raise "Direction not recognised: #{direction.inspect}"
      end
    end

    def forward(distance)
      move(facing.to_s, distance)
    end
  end

  attr_reader :size, :stdin, :stdout, :robot

  def initialize(size: 5, stdin: $stdin, stdout: $stdout)
    @stdin = stdin
    @stdout = stdout
    @size = size
    @robot = Robot.new
  end

  def run
    loop do
      draw
      read
    end
  end

  def draw
    stdout.puts "# " * (size + 2)
    size.times do |y|
      stdout.print "# "
      size.times do |x|
        draw_cell(Position.new(x, y))
      end
      stdout.print "# \n"
    end
    stdout.puts "# " * (size + 2)
  end

  def draw_cell(cell)
    if robot.position == cell
      stdout.print "#{robot.draw} "
    else
      stdout.print '  '
    end
  end

  def read
    stdout.print '> '
    parse(stdin.gets.chomp)
    stdout.puts "\e[1A\e[2K\e[1T\e[#{size + 2}A"
  rescue Interrupt
    exit
  end

  DIRECTION = /(?:up|right|down|left|north|south|east|west|\b[nsewrlud]\b)/
  def parse(command)
    case command
    when "exit", "quit"
      exit
    when /(?:face|turn) (#{DIRECTION})/
      robot.face(Regexp.last_match[1])
    when /(?:move|go)(?: (\d+))?/
      robot.forward(Regexp.last_match[1])
      robot.position.resolve(size)
    when /(?:(?:move|go) )?(#{DIRECTION})(?: (\d+))?/
      robot.move(*Regexp.last_match.captures)
      robot.position.resolve(size)
    else raise "Command not recognised: #{command.inspect}"
    end
  end
end
