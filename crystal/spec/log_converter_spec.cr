require "./spec_helper"

describe LogConverter do
  describe "test line convertions" do
    it "converts a line a foreground color" do
      expected_line = "<span class=\"color-f1\">Test</span>"
      line = "01Test01"
      LogConverter.convert_line(line).should eq(expected_line)
    end
    it "converts a line a foreground and background color" do
      expected_line = "<span class=\"color-f1-b3\">Test</span>"
      line = "01,3Test01,3"
      LogConverter.convert_line(line).should eq(expected_line)
    end
    it "converts a line with color missing" do
      expected_line = "<span class=\"color-f2\">Test</span>."
      line = "2Test."
      expected_line.should eq(LogConverter.convert_line(line))
      LogConverter.convert_line(line).should eq(expected_line)
    end
    it "converts a line with bold color" do
      expected_line = "<strong>Test</strong>."
      line = "Test."
      LogConverter.convert_line(line).should eq(expected_line)
    end
    it "converts a line with underline" do
      expected_line = "<u>Test</u>."
      line = "Test."
      LogConverter.convert_line(line).should eq(expected_line)
    end
    it "converts a line with reverse" do
      expected_line = "<span class=\"reverse\">Test</span>."
      line = "Test."
      LogConverter.convert_line(line).should eq(expected_line)
    end
    it "Changes foreground without changing background" do
      expected_line = "<span class=\"color-f6-b1\">testing</span><span class=\"color-f0-b1\">test</span>"
      line = "6,1testing0test"
      LogConverter.convert_line(line).should eq(expected_line)
    end

    it "Has everything mixed up" do
      expected_line = "<strong><span class=\"reverse\"><u>Test.</u>---</span>---</strong>."
      line = "Test.------."
      LogConverter.convert_line(line).should eq(expected_line)
    end
  end
end
