#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'robot'

RobotWorld.new(size: ARGV[0]&.to_i || 5).run
