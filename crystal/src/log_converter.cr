require "./decorations"
require "html"

# This module converts a file (or more precisely, any kind of enumerable) from the mirc format to a basic html
module LogConverter
  COLOR_CHAR = ''
  STYLE = {
    bold: '',
    underline: '',
    reverse: '',
    unstyle: ''
  }

  COLORS = %w[white black #00007f #009300 red #7f0000 #9c009c #fc7f00 yellow #00fc00 #009393 #00ffff #0000fc #ff00ff #7f7f7f #d2d2d2]

  def self.generate_colors_classes
    color_classes = [] of String
    16.times do |n|
      color_classes << ".color-f#{n} {
        color: #{COLORS[n]}
      }"
      16.times do |m|
        color_classes << ".color-f#{n}-b#{m} {
          color: #{COLORS[n]};
          background-color: #{COLORS[m]};
        }"
      end
    end
    color_classes
  end

  BASE_HTML = <<-HTML
    <!doctype html>
    <html lang="en">
    <head>
        <meta charset="utf-8">
        <title>mIRC logs</title>
        <link rel="stylesheet" type="text/css" href="https://cdn.jsdelivr.net/gh/kneedeepincode/fsex-webfont@v1.0.1/fsex300.css">
        <style>
          .irc-logs {
            font-family:"Fixedsys Excelsior 3.01",monospace;
          }
          #{generate_colors_classes.join("\n")}
        </style>
    </head>
    <body>
    <div class="irc-logs">
    <YIELD>
    </div>
    </body>
  HTML

  def self.convert_line(line)
    line = HTML.escape(line).tr("\n\r", "")
    groups = line.split(STYLE[:unstyle])
    groups.map { |g| convert_group(g) }.join("")
  end

  COLOR_REGEX = /(#{COLOR_CHAR}[0-9]{0,2}(?:,[0-9]{1,2})?)/
  TOKENIZATION_RE = /([#{STYLE[:bold]}#{STYLE[:underline]}#{STYLE[:reverse]}])/

  def self.convert_group(group)
    tokenized = group.split(TOKENIZATION_RE).map { |t| t.split(COLOR_REGEX) }.flatten
    decorations = Decorations.new
    tokenized.each { |t| decorations.consume(t) }
    decorations.finish!
    decorations.output
  end

  def self.convert_to_html(file)
    log_html = [] of String
    file.each do |line|
      log_html << convert_line(line)
    end
    puts BASE_HTML.gsub("<YIELD>", log_html.join("<br \\>\n"))
  end
end
