require "spec"
require "../src/json_parser"

# TODO ensure JSON is valid by running JSON.parse is some scripts
context "kibana2json parser" do

  it "leaves text untouched" do
    Parser.new.parse(%q(some text)).should eq("some text")
  end

  it "parses simple text" do
    Parser.new.parse(%q("""what"ever""")).should eq(%q("what\"ever"))
  end

  it "supports multiple occurences" do
    input = %q(beginning """what"ever""" middle """test"test""" end)
    output = %q(beginning "what\"ever" middle "test\"test" end)
    Parser.new.parse(input).should eq(output)
  end

  it "parses simple json" do
    Parser.new.parse(%q({ "foo" : """what"ever""" })).should eq(%q({ "foo" : "what\"ever" }))
  end

  it "throws an unxception on uneven triple ticks" do
    expect_raises(Exception) do
      Parser.new.parse(%q("""what"ever"))
    end
  end

  it "removes new lines inside of the quotes" do
    input = <<-INPUT
    """ foo bar

    foo bar """
    INPUT
    output = %q(" foo barfoo bar ")
    Parser.new.parse(input).should eq(output)
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
    Parser.new.parse(input).should eq(output)
  end

  it "catches the outmost three ticks" do
    input = %q("""field:"Land"""" something else here and """five ticks""""")
    output = %q("field:\"Land\"" something else here and "five ticks\"\"")
    Parser.new.parse(input).should eq(output)
  end

  it "catches outmost ticks and keeps rest of the text intact" do
    input = <<-INPUT
    "indices": [
      """foo:"bar""""
    ],
    "spam": """eggs"""
    INPUT
    output = <<-OUTPUT
    "indices": [
      "foo:\\\"bar\\\""
    ],
    "spam": "eggs"
    OUTPUT
    Parser.new.parse(input).should eq(output)
  end

end
