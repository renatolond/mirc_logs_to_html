require "./log_reader"
require "./log_converter"

LogConverter.convert_to_html(LogReader.read("file.log"))
