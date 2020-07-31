# A state-machine-like class to take care of text decorations
class Decorations
  @foreground : Int8 | Nil
  @background : Int8 | Nil

  def initialize
    @foreground = nil
    @background = nil
    @bold = false
    @reverse = false
    @underline = false

    @prev_groups = [] of String
    @output = ""
  end

  def consume(token : String)
    return if token.size == 0
    case token[0]
    when LogConverter::STYLE[:bold]
      bold!
    when LogConverter::STYLE[:reverse]
      reverse!
    when LogConverter::STYLE[:underline]
      underline!
    when LogConverter::COLOR_CHAR
      color!(token[1..])
    else
      @output += token
    end
    return unless neutral?

    @prev_groups << @output
    @output = ""
  end

  def neutral?
    @foreground.nil? && @background.nil? && !@bold && !@reverse && !@underline
  end

  def finish!
    bold! if @bold
    reverse! if @reverse
    underline! if @underline
    color!("") if @foreground || @background

    @prev_groups << @output
    @output = @prev_groups.join
  end

  getter :output

  private def bold!
      @output = "<strong>#{@output}</strong>" if @bold

      @bold = !@bold
    end

    private def reverse!
      @output = %(<span class="reverse">#{@output}</span>) if @reverse

      @reverse = !@reverse
    end

    private def underline!
      @output = "<u>#{@output}</u>" if @underline

      @underline = !@underline
    end

    private def color!(colors : String)
      was_blank = @foreground.nil? && @background.nil?
      html_class = color_html_class(@foreground, @background)

      if colors.blank?
        fg_changed = fg!(nil)
        bg_changed = bg!(nil)
      elsif colors.includes? ','
        a, b = colors.split(",")
        fg_changed = fg!(a.to_i8)
        bg_changed = bg!(b.to_i8)
      else
        fg_changed = fg!(colors.to_i8)
        bg_changed = false
      end

      changed = fg_changed | bg_changed
      should_write = !was_blank && changed
      save_output(html_class) if should_write
    end

    private def save_output(html_class : String)
      @output = %(<span class="#{html_class}">#{@output}</span>) if html_class
      @prev_groups << @output
      @output = ""
    end

    private def bg!(background)
      if @background != background
        @background = background
        return true
      end
      false
    end

    private def fg!(foreground)
      if @foreground != foreground
        @foreground = foreground
        return true
      end
      false
    end

    private def color_html_class(foreground, background)
      if !background.nil?
        "color-f#{foreground}-b#{background}"
      else
        "color-f#{foreground}"
      end
    end
end
