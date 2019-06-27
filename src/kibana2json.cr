VERSION = "0.1.0"
require "option_parser"
require "./json_parser"

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
  parser.invalid_option do |flag|
    STDERR.puts "ERROR: #{flag} is not a valid option."
    STDERR.puts parser
    exit(1)
  end
end

isPiped = LibC.isatty(0) == 0
if isPiped == false
  puts "No input received from STDIN, exiting"
  puts "Make sure you are getting input from stdin!"
  exit
end

json_parser = Parser.new

begin
  puts json_parser.parse(STDIN)
rescue ex : Exception
  puts "Exiting: #{ex.message}"
end
