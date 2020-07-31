# This module converts a file (or more precisely, any kind of enumerable) from the mirc format to a basic html
module LogConverter
  COLOR_CHAR = ""
  STYLE = {
    bold: "",
    underline: "",
    reverse: "",
    unstyle: ""
  }

  COLOR_REGEX = /#{COLOR_CHAR}(?<foreground>[0-9]{1,2})(,(?<background>[0-9]{1,2}))?(?<text>[^#{COLOR_CHAR}#{STYLE[:unstyle]}]*)/
  BOLD_REGEX = /#{STYLE[:bold]}(?<text>[^#{STYLE[:bold]}#{STYLE[:unstyle]}]*)[#{STYLE[:bold]}]?(?<unstyle>[#{STYLE[:unstyle]}]?)/
  UNDERLINE_REGEX = /#{STYLE[:underline]}(?<text>[^#{STYLE[:underline]}#{STYLE[:unstyle]}]*)[#{STYLE[:underline]}]?(?<unstyle>[#{STYLE[:unstyle]}]?)/
  REVERSE_REGEX = /#{STYLE[:reverse]}(?<text>[^#{STYLE[:reverse]}#{STYLE[:unstyle]}]*)[#{STYLE[:reverse]}]?(?<unstyle>[#{STYLE[:unstyle]}]?)/
  COLOR_HTML_PATTERN = %(<span class=\"color-f\\k<foreground>x\\k<background>\">\\k<text></span>)

  def self.color_convert(_str, match)
    foreground = match["foreground"].to_i
    background = match["background"].to_i unless match["background"]?.nil?
    text = match["text"]
    html_class = "color-f#{foreground}"
    html_class = "#{html_class}-b#{background}" unless background.nil?

    return "" if text.blank?

    "<span class=\"#{html_class}\">#{text}</span>"
  end

  def self.bold_convert(_str, match)
    text = match["text"]
    return "" if text.blank?

    "<strong>#{text}</strong>#{match["unstyle"]}"
  end

  def self.underline_convert(_str, match)
    text = match["text"]
    return "" if text.blank?

    "<u>#{text}</u>#{match["unstyle"]}"
  end

  COLORS = %w[white black #00007f #009300 red #7f0000 #9c009c #fc7f00 yellow #00fc00 #009393 #00ffff #0000fc #ff00ff #7f7f7f #d2d2d2]
  def self.reverse_convert(_str, match)
    text = match["text"]
    return "" if text.blank?

    "<span class=\"reverse\">#{text}</span>#{match["unstyle"]}"
  end

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
    # line = CGI.escapeHTML(line)
    line = line.gsub(BOLD_REGEX) { |str, m| bold_convert(str, m) }
    line = line.gsub(UNDERLINE_REGEX) { |str, m| underline_convert(str, m) }
    line = line.gsub(REVERSE_REGEX) { |str, m| reverse_convert(str, m) }
    line = line.gsub(COLOR_REGEX) { |str, m| color_convert(str, m) }
    line.tr("#{STYLE[:unstyle]}#{COLOR_CHAR}", "")
  end

  def self.convert_to_html(file)
    log_html = [] of String
    file.each do |line|
      log_html << convert_line(line)
    end
    puts BASE_HTML.gsub("<YIELD>", log_html.join("<br \\>"))
  end
end
