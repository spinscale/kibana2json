class Parser
  def parse(data : String)
    # data = %q({ "foo" : """what"ever""" } )
    matcher = %q(""")
    pos = 0
    startOffset = data.index(matcher)
    if startOffset.nil?
      return data
    end
    escaped = String.new

    while !startOffset.nil?
      # include the first characters before the first """
      if pos == 0 && startOffset > 0
        escaped += data[pos..startOffset - 1]
      end
      endOffset = data.index(matcher, startOffset + 1)

      if endOffset.nil?
        raise Exception.new("Uneven number of triple ticks")
      else
        # this only works for one more character now, but should work for an arbitrary amount
        if data[endOffset + 3]?
          if data[endOffset + 3] == '"'
            endOffset += 1
          end
        end

        # now do all the replace magic here
        # but double ticks at beginning and end
        # remove triple ticks
        # replace double ticks with double ticks + backspace
        escaped += %q(")
        escaped += data[startOffset + 3..endOffset - 1].gsub(%q("), %q(\")).gsub(/\n/, "")
        escaped += %q(")
        startOffset = data.index(matcher, endOffset + 1)
        # no more startOffset means, there are no more occurences
        if startOffset.nil?
          escaped += data[endOffset + 3..-1]
        else
          # ensure the last """ is not included
          escaped += data[endOffset + 3..startOffset - 1]
        end
        pos = endOffset
      end
    end

    return escaped
  end
end
