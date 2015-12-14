require "rubygems"
require "simple-spreadsheet"
require "byebug"

countries = {} # countries indexed by iso3361_3_characters
country_codes = {} # countries indexed by the taxcode country code

wikipedia = SimpleSpreadsheet::Workbook.read("data/wikipedia.csv", ".csvt")
wikipedia.first_row.upto(wikipedia.last_row) do |line|
  english_country_name = wikipedia.cell(line, 1)
  iso3361_2_characters = wikipedia.cell(line, 2)
  iso3361_3_characters = wikipedia.cell(line, 3)
  countries[iso3361_3_characters] = {
    english_country_name: english_country_name,
    iso3361_3_characters: iso3361_3_characters,
    iso3361_2_characters: iso3361_2_characters
  }
  #puts "#{english_country_name} #{iso3361_2_characters} #{iso3361_3_characters}"
end

insiel = SimpleSpreadsheet::Workbook.read("data/COD_EXT.xls")
insiel.selected_sheet = insiel.sheets.first
4.upto(insiel.last_row) do |line|
  iso3361_3_characters = insiel.cell(line, 5)
  italian_country_name_1 = insiel.cell(line, 1)
  istat = insiel.cell(line, 2).to_i
  minint = insiel.cell(line, 3).to_i
  taxcode_country_code = insiel.cell(line, 8)
  if iso3361_3_characters
    record = countries[iso3361_3_characters]
    if record
      countries[iso3361_3_characters][:istat] = istat
      countries[iso3361_3_characters][:minint] = minint
      countries[iso3361_3_characters][:italian_country_name_1] = italian_country_name_1
      countries[iso3361_3_characters][:italian_country_code] = taxcode_country_code
    else
      countries[iso3361_3_characters] = {
        english_country_name: "",
        italian_country_name_1: italian_country_name_1,
        iso3361_3_characters: iso3361_3_characters,
        iso3361_2_characters: "",
        taxcode_country_code: taxcode_country_code,
        istat: istat,
        minint: minint
      }
    end
    country_codes[taxcode_country_code] = countries[iso3361_3_characters]
    country_codes[taxcode_country_code][:taxcode_country_code] = taxcode_country_code
  else
    country_codes[taxcode_country_code] = {
      english_country_name: "",
      italian_country_name_1: italian_country_name_1,
      iso3361_3_characters: iso3361_3_characters,
      iso3361_2_characters: "",
      taxcode_country_code: taxcode_country_code,
      istat: istat,
      minint: minint
    }
  end
end

agenzia_entrate = SimpleSpreadsheet::Workbook.read("data/ESTERI.XLS")
agenzia_entrate.selected_sheet = agenzia_entrate.sheets.first
2.upto(agenzia_entrate.last_row) do |line|
  italian_country_name_2 = agenzia_entrate.cell(line, 3)
  taxcode_country_code = agenzia_entrate.cell(line, 4)
  record = country_codes[taxcode_country_code]
  if record
    country_codes[taxcode_country_code][:italian_country_name_2] = italian_country_name_2
    iso3361_3_characters = country_codes[taxcode_country_code][:iso3361_3_characters]
    if countries[iso3361_3_characters]
      countries[iso3361_3_characters][:italian_country_name_2] = italian_country_name_2
    else
      countries[iso3361_3_characters] = {
        italian_country_name_2: italian_country_name_2,
        iso3361_3_characters: iso3361_3_characters
      }
    end
  else
    country_codes[taxcode_country_code] = {
      english_country_name: "",
      italian_country_name_1: "",
      italian_country_name_2: italian_country_name_2,
      iso3361_3_characters: "",
      iso3361_2_characters: "",
      taxcode_country_code: taxcode_country_code,
      istat: nil,
      minint: nil
    }
  end
end


#countries.each do |iso3361_3_characters, data|
#  puts "#{data[:english_country_name]}\t#{data[:italian_country_name_1]}\t#{data[:italian_country_name_2]}\t#{data[:iso3361_3_characters]}\t#{data[:iso3361_2_characters]}\t#{data[:taxcode_country_code]}\t#{data[:istat]}\t#{data[:minint]}"
#end

#puts "--------------------"

country_codes.each do |taxcode_country_code, data|
  puts "#{data[:english_country_name]}\t#{data[:italian_country_name_1]}\t#{data[:italian_country_name_2]}\t#{data[:iso3361_3_characters]}\t#{data[:iso3361_2_characters]}\t#{data[:taxcode_country_code]}\t#{data[:istat]}\t#{data[:minint]}"
end

puts "Italy\tItalia\t\tITA\tIT\t\t\t"
