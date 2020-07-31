require "icu"

module LogReader
  def self.read(file_name : String)
    content = File.read(file_name)
    charset_detect = ICU::CharsetDetector.new

    csm = charset_detect.detect(content)
    String.new(File.read(file_name, encoding: csm.name).encode("UTF-8")).each_line
  end
end
