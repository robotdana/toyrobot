#!/usr/bin/env ruby

require_relative 'robot'

RobotWorld.new(size: ARGV[0]&.to_i || 5).run


