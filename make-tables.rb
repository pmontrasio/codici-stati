require "rubygems"
require "simple-spreadsheet"
require "byebug"
require "pg"
require "mysql2"
require "mongoid"

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
  istat = nil if istat == 0
  minint = insiel.cell(line, 3).to_i
  minint = nil if minint == 0
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

countries["ITA"] = {
  english_country_name: "Italy",
  italian_country_name_1: "Italia",
  italian_country_name_2: "",
  iso3361_3_characters: "ITA",
  iso3361_2_characters: "IT",
  taxcode_country_code: "",
  istat: nil,
  minint: nil
}

def record_to_s(data)
  "#{data[:english_country_name]}\t#{data[:italian_country_name_1]}\t#{data[:italian_country_name_2]}\t#{data[:iso3361_3_characters]}\t#{data[:iso3361_2_characters]}\t#{data[:taxcode_country_code]}\t#{data[:istat]}\t#{data[:minint]}"
end


iso_csv = File.open("dist/iso.csv", "w")
countries.each do |iso3361_3_characters, data|
  iso_csv.puts record_to_s(data)
end
iso_csv.close

tax_csv = File.open("dist/tax.csv", "w")
country_codes.each do |taxcode_country_code, data|
  tax_csv.puts record_to_s(data)
end
tax_csv.close

File.open("dist/country_codes.json", "w") do |file|
  file.puts country_codes.to_json
end

File.open("dist/countries.json", "w") do |file|
  file.puts countries.to_json
end

records = (country_codes.values + countries.values).uniq

# insert in postgres
#psql -U postgres
#create database country_codes encoding='UTF8' lc_collate='en_US.UTF-8' lc_ctype='en_US.UTF-8';
#psql -U postgres country_codes
#create table country_codes (english_country_name text, italian_country_name_1 text, italian_country_name_2 text, iso3361_3_characters char(3), iso3361_2_characters char(2), taxcode_country_code char(4), istat integer, minint integer);

pg_conn = PG.connect( dbname: 'country_codes', user: "postgres" )
psql_query = "INSERT INTO country_codes (english_country_name, italian_country_name_1, italian_country_name_2, iso3361_3_characters, iso3361_2_characters, taxcode_country_code, istat, minint) VALUES ($1::text, $2::text, $3::text, $4::text, $5::char(3), $6::char(4), $7::int, $8::int)"
pg_conn.prepare("insert_data", psql_query)
pg_conn.exec("DELETE FROM country_codes")

time_start = Time.now
pg_conn.transaction do |conn|
  records.each do |country|
    conn.exec_prepared("insert_data", [country[:english_country_name], country[:italian_country_name_1],
                                       country[:italian_country_name_2], country[:iso3361_3_characters],
                                       country[:iso3361_2_characters], country[:taxcode_country_code],
                                       country[:istat], country[:minint]])
  end
end
time_end = Time.now
pg_conn.close
psql_time = time_end - time_start
# pg_dump -U postgres --table country_codes country_codes > dist/country_codes.psql

# insert in mysql
#mysql -u root -p
#create database country_codes default character set utf8 collate utf8_unicode_ci;
#mysql -u root -p country_codes
#create table country_codes (english_country_name text, italian_country_name_1 text, italian_country_name_2 text, iso3361_3_characters char(3), iso3361_2_characters char(2), taxcode_country_code char(4), istat integer, minint integer);

mysql_conn = Mysql2::Client.new(host: "localhost", username: ENV["MYSQL_USER"], password: ENV["MYSQL_PASS"], database: "country_codes")
mysql_query = "INSERT INTO country_codes (english_country_name, italian_country_name_1, italian_country_name_2, iso3361_3_characters, iso3361_2_characters, taxcode_country_code, istat, minint) VALUES (?, ?, ?, ?, ?, ?, ?, ?)"
insert_data = mysql_conn.prepare(mysql_query)
mysql_conn.query("DELETE FROM country_codes")
time_start = Time.now
begin
  mysql_conn.query("BEGIN")
  records.each do |country|
    insert_data.execute(country[:english_country_name], country[:italian_country_name_1],
                        country[:italian_country_name_2], country[:iso3361_3_characters],
                        country[:iso3361_2_characters], country[:taxcode_country_code],
                        country[:istat], country[:minint])
  end
  mysql_conn.query("COMMIT")
rescue => e
  p e
  mysql_conn.query("ROLLBACK")
end
time_end = Time.now
mysql_conn.close
mysql_time = time_end - time_start
# mysqldump -u root -p country_codes country_codes > dist/country_codes.mysql

# insert in mongo
class CountryCode
  include Mongoid::Document
  field :english_country_name, type: String
  field :italian_country_name_1, type: String
  field :iso3361_3_characters, type: String
  field :iso3361_2_characters, type: String
  field :taxcode_country_code, type: String
  field :istat, type: Integer
  field :minint, type: Integer
end

#mongo
#use country_codes
#db.createCollection("countryCodes")
Mongoid.load!("mongo.yml", :development)
Mongoid.logger.level = Logger::INFO
Mongo::Logger.logger.level = Logger::INFO
CountryCode.delete_all
time_start = Time.now
records.each do |country|
  CountryCode.create(
                     english_country_name: country[:english_country_name],
                     italian_country_name_1: country[:italian_country_name_1],
                     iso3361_3_characters: country[:iso3361_3_characters],
                     iso3361_2_characters: country[:iso3361_2_characters],
                     taxcode_country_code: country[:taxcode_country_code],
                     istat: country[:istat],
                     minint: country[:minint])
end
time_end = Time.now
mongo_time = time_end - time_start
# mongoexport --collection country_codes --out dist/country_codes.json --db country_codes > dist/country_codes.mongodb.json

#puts "PostgreSQL,MySQL,MongoDB"
#puts "#{psql_time},#{mysql_time},#{mongo_time}"
