# frozen_string_literal: true

require "cgi"
require "active_support/core_ext/object/blank"
require "English"

# This module converts a file (or more precisely, any kind of enumerable) from the mirc format to a basic html
module LogConverter
  COLOR_CHAR = ""
  STYLE = {
    bold: "",
    underline: "",
    reverse: "",
    unstyle: ""
  }.freeze

  COLOR_REGEX = /#{COLOR_CHAR}(?<foreground>[0-9]{1,2})(,(?<background>[0-9]{1,2}))?(?<text>[^#{COLOR_CHAR}]*)(#{COLOR_CHAR}(?![0-9]{1,2}))?/.freeze
  BOLD_REGEX = /#{STYLE[:bold]}(?<text>[^#{STYLE[:bold]}]*)[#{STYLE[:bold]}]?/.freeze
  UNDERLINE_REGEX = /#{STYLE[:underline]}(?<text>[^#{STYLE[:underline]}]*)[#{STYLE[:underline]}]?/.freeze
  REVERSE_REGEX = /#{STYLE[:reverse]}(?<text>[^#{STYLE[:reverse]}]*)[#{STYLE[:reverse]}]?/.freeze
  COLOR_HTML_PATTERN = %(<span class=\"color-f\\k<foreground>x\\k<background>\">\\k<text></span>)

  def self.color_convert(match, _str)
    foreground = match["foreground"]&.to_i
    background = match["background"]&.to_i
    text = match["text"]
    html_class = "color-f#{foreground}"
    html_class = "#{html_class}-b#{background}" if background.present?

    return "" if text.blank?

    "<span class=\"#{html_class}\">#{text}</span>"
  end

  def self.bold_convert(match, _str)
    text = match["text"]
    return "" if text.blank?

    "<strong>#{text}</strong>"
  end

  def self.underline_convert(match, _str)
    text = match["text"]
    return "" if text.blank?

    "<u>#{text}</u>"
  end

  COLORS = %w[white black #00007f #009300 red #7f0000 #9c009c #fc7f00 yellow #00fc00 #009393 #00ffff #0000fc #ff00ff #7f7f7f #d2d2d2].freeze
  def self.reverse_convert(match, _str)
    text = match["text"]
    return "" if text.blank?

    "<span class=\"reverse\">#{text}</span>"
  end

  def self.generate_colors_classes
    color_classes = []
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

  BASE_HTML = <<~HTML
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
    line = CGI.escapeHTML(line)
    groups = line.split(STYLE[:unstyle])
    groups.map { |g| convert_group(g) }.join("")
  end

  def self.convert_group(group)
    group.gsub!(BOLD_REGEX) { |m| bold_convert($LAST_MATCH_INFO, m) }
    group.gsub!(UNDERLINE_REGEX) { |m| underline_convert($LAST_MATCH_INFO, m) }
    group.gsub!(REVERSE_REGEX) { |m| reverse_convert($LAST_MATCH_INFO, m) }
    group.gsub!(COLOR_REGEX) { |m| color_convert($LAST_MATCH_INFO, m) }
    group
  end

  def self.convert_to_html(file)
    log_html = []
    file.each do |line|
      log_html << convert_line(line)
    end
    puts BASE_HTML.gsub("<YIELD>", log_html.join("<br \\>"))
  end
end
