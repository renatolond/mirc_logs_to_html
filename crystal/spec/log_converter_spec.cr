require "./spec_helper"

describe LogConverter do
  describe "test line convertions" do
    it "converts a line a foreground color" do
      expected_line = "<span class=\"color-f1\">Test</span>"
      line = "01Test01"
      expected_line.should eq(LogConverter.convert_line(line))
    end
    it "converts a line a foreground and background color" do
      expected_line = "<span class=\"color-f1-b3\">Test</span>"
      line = "01,3Test01,3"
      expected_line.should eq(LogConverter.convert_line(line))
    end
    it "converts a line with color missing" do
      expected_line = "<span class=\"color-f2\">Test</span>."
      line = "2Test."
      expected_line.should eq(LogConverter.convert_line(line))
    end
    it "converts a line with bold color" do
      expected_line = "<strong>Test</strong>."
      line = "Test."
      expected_line.should eq(LogConverter.convert_line(line))
    end
    it "converts a line with underline" do
      expected_line = "<u>Test</u>."
      line = "Test."
      expected_line.should eq(LogConverter.convert_line(line))
    end
    it "converts a line with reverse" do
      expected_line = "<span class=\"reverse\">Test</span>."
      line = "Test."
      expected_line.should eq(LogConverter.convert_line(line))
    end
  end
end
