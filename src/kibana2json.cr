VERSION = "0.1.0"
require "option_parser"
require "./json_parser"

wait_for_input_in_seconds = Time::Span.new(seconds: 5, nanoseconds: 0)

OptionParser.parse! do |parser|
  parser.banner = "Usage: kibana2json < your_json.json"
  parser.on("-v", "--version", "Version info and exit") {
    puts VERSION
    exit(0)
  }
  parser.on("-h", "--help", "Show this help") {
    puts parser
    exit(0)
  }
  parser.on("-w", "--wait", "wait this much seconds for input, defaults to 5") { | input |
    wait_for_input_in_seconds = Time::Span.new(seconds: input.to_i, nanoseconds: 0)
  }
  parser.invalid_option do |flag|
    STDERR.puts "ERROR: #{flag} is not a valid option."
    STDERR.puts parser
    exit(1)
  end
end

spawn do
  sleep wait_for_input_in_seconds.seconds
  puts "No input received within five seconds, exiting"
  puts "Make sure you are getting input from stdin!"
  exit
end

# TODO would be nice to peek into STDIN and if there is nothing to be read exit
# maybe by waiting two seconds
json_parser = Parser.new
data = STDIN.gets_to_end

begin
  puts json_parser.parse(data)
rescue ex : Exception
  puts "Exiting: #{ex.message}"
end
