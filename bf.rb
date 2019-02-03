#!/usr/bin/env ruby
require 'byebug'
require 'io/console'


@opts = ARGV.reject do |arg| File.file?(arg) end

ARGV.delete_if do |arg| #Remove non-file arguments
  @opts.include? arg
end

@program_name = ARGV.clone.first
@program = gets(nil) if @program_name #Read whole program in

@tape = Array.new
@pointer = 0

@debug = @opts.include?("-d") || @opts.include?("--debug") #Allows code debugging

if @opts.include?("-i") || @opts.include?("--interactive")
  @debug = true
  @program = "!"
end

if @opts.include?("-h") || @opts.include?("--help") || @program == nil
  puts "usage #{$0} [-dih] [file]"
  puts ""
  puts "#{$0} is a brainfuck interpreter with debugging support"
  puts ""
  puts "-h : shows this screen"
  puts "-d : enable debugging brainfuck scripts"
  puts "-i : use interactive mode (enables debugging automatically)"
  puts ""
  # puts "#{$0} will allso accept brainfuck scripts via pipes"

  abort
end


def @tape.[](index)
  return self.at(index) || 0 #All Unvisited cells should start with 0
end

# String.ord -> Number
# Number.chr -> String

def interpreter(program)
  skip = Array.new
  program.chars.each_with_index do |char, index|
    next if skip.include?(index)
    case char
    when '>'
      @pointer += 1
    when '<'
      @pointer -= 1 unless @pointer == 0
    when '+'
      @tape[@pointer] += 1
    when '-'
      @tape[@pointer] -= 1
    when '.'
      print @tape[@pointer].chr
    when ','
      @tape[@pointer] = STDIN.getch.ord
    when '['
      program_loop = program[index+1 .. -1]
      until @tape[@pointer] == 0
        stop = interpreter(program_loop)
      end
      skip += (index+1 .. index+1+stop).to_a
    when ']'
      return index
    when '!'
      next unless @debug
      puts "Code Near Breakpoint"
      puts program[index-20..index+20] if index > 20
      puts program[0..index+20] if index <= 20
      puts "BrainFuck Debugger, type help"
      loop do
        command = STDIN.gets.chomp
        case command
        when "exit"
          break
        when "tape"
          puts @tape.to_s
        when "pointer"
          puts @pointer
        when "cell"
          puts @tape[@pointer]
        when "byebug"
          byebug
        when "help"
          puts "Commands"
          puts "exit - Stops debugger and continues execution"
          puts "tape - Display contents of memory tape (all cells)"
          puts "pointer - Display the index of the cell currenly selected"
          puts "cell - Display contets of cell currently selected"
          puts "byebug - Start byebug ruby debugger (debug interpreter)"
          puts ""
          puts "Type any command, or brainfuck code to execute"
        else
          interpreter(command)
        end
      end
    end
  end
end

interpreter @program
