require "rubygems"
require "simple-spreadsheet"

agenzia_entrate = SimpleSpreadsheet::Workbook.read("data/ESTERI.XLS")
agenzia_entrate.selected_sheet = agenzia_entrate.sheets.first
agenzia_entrate.first_row.upto(agenzia_entrate.last_row) do |line|
  italian_country_name_1 = agenzia_entrate.cell(line, 3)
  italian_country_code = agenzia_entrate.cell(line, 4)
  puts "#{italian_country_name_1} #{italian_country_code}"
end

wikipedia = SimpleSpreadsheet::Workbook.read("data/wikipedia.tab", ".csvt")
wikipedia.first_row.upto(wikipedia.last_row) do |line|
  english_country_name = wikipedia.cell(line, 1)
  iso3361_2_characters = wikipedia.cell(line, 2)
  iso3361_3_characters = wikipedia.cell(line, 3)
  puts "#{english_country_name} #{iso3361_2_characters} #{iso3361_3_characters}"
end

insiel = SimpleSpreadsheet::Workbook.read("data/COD_EXT.xls")
insiel.selected_sheet = insiel.sheets.first
insiel.first_row.upto(insiel.last_row) do |line|
  italian_country_name_2 = insiel.cell(line, 1)
  iso3361_3_characters = insiel.cell(line, 5)
  italian_country_code = insiel.cell(line, 8)
  puts "#{italian_country_name_2} #{iso3361_3_characters} #{italian_country_code}"
end
