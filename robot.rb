# frozen_string_literal: true

# everthing
class RobotWorld
  Position = Struct.new(:x, :y) do
    def resolve(size)
      self.x = x % size
      self.y = y % size
    end
  end

  # position, facing, movement
  class Robot
    attr_reader :position, :facing, :grid_size
    def initialize(size)
      @position = Position.new(0, 0)
      @facing = :right
      @grid_size = size
    end

    def draw
      case facing
      when :up then '^'
      when :right then '>'
      when :down then 'v'
      when :left then '<'
      end
    end

    def face(direction)
      @facing = parse_direction(direction)
    end

    def move(direction, distance = 1)
      send(parse_direction(direction), parse_distance(distance))
    end

    def parse_direction(direction)
      case direction
      when 'up', 'north', 'n', 'u' then :up
      when 'right', 'east', 'e', 'r' then :right
      when 'down', 'south', 's', 'd' then :down
      when 'left', 'west', 'w', 'l' then :left
      end
    end

    def parse_distance(distance = 1)
      return 1 if distance.to_i.zero? && distance != 0

      distance.to_i
    end

    def up(distance)
      position.y -= distance
      position.resolve(grid_size)
    end

    def right(distance)
      position.x += distance
      position.resolve(grid_size)
    end

    def down(distance)
      position.y += distance
      position.resolve(grid_size)
    end

    def left(distance)
      position.x -= distance
      position.resolve(grid_size)
    end

    def forward(distance)
      send(facing, parse_distance(distance))
    end
  end

  attr_reader :size, :stdin, :stdout, :robot

  def initialize(size: 5, stdin: $stdin, stdout: $stdout)
    @stdin = stdin
    @stdout = stdout
    @size = size
    @robot = Robot.new(size)
  end

  def run
    loop do
      draw
      read
    end
  end

  def draw
    draw_wall
    size.times do |y|
      draw_edge
      size.times do |x|
        draw_cell(Position.new(x, y))
      end
      draw_edge
      stdout.puts ''
    end
    draw_wall
  end

  def draw_edge
    stdout.print '# '
  end

  def draw_wall
    stdout.puts '# ' * (size + 2)
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
    stdout.puts ''
    exit
  end

  DIRECTION = /(?:up|right|down|left|north|south|east|west|\b[nsewrlud]\b)/
              .freeze # hi rubocop how you doing

  def parse(command)
    case command
    when 'exit', 'quit' then exit
    when /(?:face|turn) (#{DIRECTION})/
      robot.face(Regexp.last_match[1])
    when /(?:(?:move|go) )?(#{DIRECTION})(?: (\d+))?/
      robot.move(*Regexp.last_match.captures)
    when /(?:move|go)(?: (\d+))?/
      robot.forward(Regexp.last_match[1])
    else raise "Command not recognised: #{command}"
    end
  end
end
