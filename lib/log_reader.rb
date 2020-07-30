# frozen_string_literal: true

require "charlock_holmes/string" # monkey patch string class for encoding

# This module is responsible for reading files. It takes care of encoding and some other weird stuff around the files
module LogReader
  def self.read(file_name)
    content = File.read(file_name)

    content.detect_encoding!
    content.encode!("UTF-8")

    content.each_line
  end
end
