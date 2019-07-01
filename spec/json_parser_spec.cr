require "spec"
require "../src/json_parser"
require "json"

parser = Parser.new

describe "text parser" do

  it "leaves text untouched" do
    parser.parse(%q(some text)).should eq("some text")
  end

  it "parses simple text" do
    parser.parse(%q("""what"ever""")).should eq(%q("what\"ever"))
  end

  it "supports multiple occurences" do
    input = %q(beginning """what"ever""" middle """test"test""" end)
    output = %q(beginning "what\"ever" middle "test\"test" end)
    parser.parse(input).should eq(output)
  end

  it "parses simple json" do
    output = parser.parse(%q({ "foo" : """what"ever""" }))
    output.should eq(%q({ "foo" : "what\"ever" }))
    JSON.parse(output)
  end

  it "throws an unxception on uneven triple ticks" do
    expect_raises(Exception) do
      parser.parse(%q("""what"ever"))
    end
  end

  it "escapes new lines inside of the quotes" do
    input = <<-INPUT
    """ foo bar

    foo bar """
    INPUT
    output = %q(" foo bar\n\nfoo bar ")
    parser.parse(input).should eq(output)
  end

  it "leaves new lines outside of the quotes" do
    input = <<-INPUT
    begin
    """foo bar"""
    end
    INPUT
    output = <<-OUTPUT
    begin
    "foo bar"
    end
    OUTPUT
    parser.parse(input).should eq(output)
  end

  it "catches the outmost three ticks" do
    input = %q("""field:"Land"""" something else here and """five ticks""""")
    output = %q("field:\"Land\"" something else here and "five ticks\"\"")
    parser.parse(input).should eq(output)
  end

  it "catches outmost ticks and keeps rest of the text intact" do
    input = <<-INPUT
    {
    "indices": [
      """foo:"bar""""
    ],
    "spam": """eggs"""
    }
    INPUT
    expected_output = <<-OUTPUT
    {
    "indices": [
      "foo:\\\"bar\\\""
    ],
    "spam": "eggs"
    }
    OUTPUT
    output = parser.parse(input)
    output.should eq(expected_output)
    JSON.parse(output)
  end

  it "check single backslash with space is handled" do
    input = %q({ "key" : """backslash\ """ })
    expected_output = %q({ "key" : "backslash\\ " })
    output = parser.parse(input)
    JSON.parse(output)
    output.should eq(expected_output)
  end

  it "check single backslash without space is handled" do
    input = %q({ "key" : """backslash\""" })
    expected_output = %q({ "key" : "backslash\\" })
    output = parser.parse(input)
    output.should eq(expected_output)
    JSON.parse(output)
  end

  it "check single backslash with newline is handled" do
    input = "{ \"key\" : \"\"\"backslash\"\\\nfoo\"\"\" }"
    expected_output = "{ \"key\" : \"backslash\\\"\\\\\\nfoo\" }"
    output = parser.parse(input)
    JSON.parse(output)
    output.should eq(expected_output)
  end
end
