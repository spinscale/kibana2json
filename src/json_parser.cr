class Parser
  def parse(data : String)
    matcher = %q(""")
    pos = 0
    startOffset = data.index(matcher)
    if startOffset.nil?
      return data
    end
    escaped = String.build do |escaped|

      # include the first characters before the first """
      if pos == 0 && !startOffset.nil? && startOffset > 0
        escaped << data[pos..startOffset - 1]
      end

      while !startOffset.nil?
        endOffset = 0
        elapsed_start_offset_time = Time.measure do
          endOffset = data.index(matcher, startOffset + 1)
        end

        if endOffset.nil?
          raise Exception.new("Uneven number of triple ticks")
        else
          # make sure the end offset are the outer most triple ticks
          # i.e. when """", pick the last three
          elapsed_three_ticks_time = Time.measure do
            while data[endOffset + 3]? && data[endOffset + 3] == '"'
                endOffset += 1
            end
          end

          # now do all the replace magic here
          # but double ticks at beginning and end
          # remove triple ticks
          # replace double ticks with double ticks + backspace
          # one exception: if there is already an escaped character like `\"` do not double escape, as this can break JSON

          elapsed_escaping_time = Time.measure do
            # begin escape
            escaped << '"'
            currentStartOffset = startOffset + 3
            currentEndOffset = endOffset - 1
            while currentStartOffset <= currentEndOffset
              currentChar = data[currentStartOffset]
              if currentChar == '"' && data[currentStartOffset-1] != '\\'
                escaped << '\\' << '"'
              elsif currentChar == '\n' # do nothing in case of newline
              else
                escaped << data[currentStartOffset]
              end

              currentStartOffset += 1
            end

            # end escape
            escaped << '"'
          end

          elapsed_next_endoffset_time = Time.measure do
            # find the next triple quotes
            startOffset = data.index(matcher, endOffset + 1)
            # no more startOffset means, there are no more occurences
            if startOffset.nil?
              escaped << data[endOffset + 3..-1]
            else
              # ensure the last """ is not included
              escaped << data[endOffset + 3..startOffset - 1]
            end
            pos = endOffset
          end

          #STDERR.puts "next start offset #{elapsed_start_offset_time.milliseconds}ms, escaping #{elapsed_escaping_time.milliseconds}ms, next endoffset quotes #{elapsed_next_endoffset_time.milliseconds}ms, elapsed_three_ticks_time #{elapsed_three_ticks_time.milliseconds}ms"

        end
      end
    end

    return escaped
  end
end
