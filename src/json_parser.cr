class Parser

  # for testing
  def parse(str : String)
    parse IO::Memory.new str
  end

  def parse(input : IO)
    escaped = String.build do |escaped|

      while true
        read_until_ticks_start = input.gets %q(""")

        # are we done reading?
        end_of_input = read_until_ticks_start.nil?
        if end_of_input
          break
        else
          # no triple escapes, let's go home immediately
          if !read_until_ticks_start.nil? && !read_until_ticks_start.includes?(%q("""))
            escaped << read_until_ticks_start
            break
          end
        end

        # remove triple ticks here if they are the last three characters
        if !read_until_ticks_start.nil? && read_until_ticks_start.includes?(%q("""))
          escaped << read_until_ticks_start[0..-4]
        else
          escaped << read_until_ticks_start
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

          escaped << '"'

          # remove ending triple ticks
          reader = Char::Reader.new to_be_escaped[0..-4]
          loop do
            case reader.current_char

            when '\\'
              if reader.has_next?
                reader.next_char
                case reader.current_char
                when '\\', '\0', '\n'
                  escaped << '\\' << '\\'
                when '"'
                  # special case to keep already escaped \" as is without further escaping
                  # makes it a bit more readable
                  escaped << '\\' << '"'
                else
                  escaped << '\\' << '\\' << reader.current_char
                end
              else
                escaped << '\\' << '\\'
              end

            when '\0', '\n'
              # do nothing here

            when '"'
              # escape double tick to keep valid JSON
              escaped << '\\' << '"'
            else
              escaped << reader.current_char
            end

            break if !reader.has_next?
            reader.next_char
          end

          escaped << '"'

          # append next_char at the end, if at end of
          break if next_char.nil?
          escaped << next_char
        end
      end
    end

    escaped
  end

end
