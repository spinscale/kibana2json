require "json"

class Parser

  # for testing
  def parse(str : String)
    output = IO::Memory.new
    input = IO::Memory.new str
    parse input, output
    output.to_s
  end

  def parse(input : IO, output : IO)
    while true
      read_until_ticks_start = input.gets %q(""")

      # are we done reading?
      end_of_input = read_until_ticks_start.nil?
      if end_of_input
        break
      else
        # no triple escapes, let's go home immediately
        if !read_until_ticks_start.nil? && !read_until_ticks_start.includes?(%q("""))
          output << read_until_ticks_start
          break
        end
      end

      # remove triple ticks here if they are the last three characters
      if !read_until_ticks_start.nil? && read_until_ticks_start.includes?(%q("""))
        output << read_until_ticks_start[0..-4]
      else
        output << read_until_ticks_start
      end

      # find the next three tickst that close this
      to_be_escaped = input.gets %q(""")

      # no second triple ticks found, bail out
      if to_be_escaped.nil? || (!to_be_escaped.nil? && !to_be_escaped.includes?(%q(""")))
        raise Exception.new("Uneven number of triple ticks")
      else
        # check next characters if they are also a double tick
        # be sure those are the last closing ticks
        next_char = input.read_char
        while next_char == '"'
          to_be_escaped = to_be_escaped + '"'
          next_char = input.read_char
        end

        builder = JSON::Builder.new output
        builder.start_document
        # remove the last triple ticks
        builder.string to_be_escaped[0..-4]
        builder.end_document

        # append next_char at the end, if at end of
        break if next_char.nil?
        output << next_char
      end
    end
  end
end
