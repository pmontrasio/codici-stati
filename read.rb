require "rubygems"
require "simple-spreadsheet"

spreadsheet = SimpleSpreadsheet::Workbook.read("data/ESTERI.XLS")
spreadsheet.selected_sheet = spreadsheet.sheets.first
spreadsheet.first_row.upto(spreadsheet.last_row) do |line|
  country_name = spreadsheet.cell(line, 3)
  italian_country_code = spreadsheet.cell(line, 4)
  puts "#{country_name} #{italian_country_code}"
end
