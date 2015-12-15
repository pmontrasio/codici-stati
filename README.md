# Country data

This repository contains some files with country data. They are useful to developers
that have to deal with data collected and exchanged in Italy, because they contain
the country codes at the end of the tax code (codice fiscale) for people born outside Italy,
the one used by ISTAT and the one used by the _Ministero dell'Interno_.

Country data:

* English name
* Italian name
* ISO3361 2 letter code
* ISO3361 3 letter code
* country code for the Italian tax code
* ISTAT code
* code used by the Ministero dell'Interno

The data is in the dist/ directory

## File formats

* PostgreSQL SQL dump format
* MySQL SQL dump format
* MongoDB mongoexport format
* two JSON objects, one indexed by the tax code and the other by the 3 letter code
* two Ruby modules that embed two Hash structures indexes as the JSON objects

The database tables contain no indexes. You must add them as required by your application.

## Examples

    $ irb
    2.2.3 :001 > require "./dist/ruby/countries/iso3361_1_alpha_3.rb"
     => true
    2.2.3 :002 > Countries::Iso3361_1_Alpha_3.get("GBR")
     => {"english_country_name"=>"United Kingdom of Great Britain and Northern Ireland",
      "iso3361_3_characters"=>"GBR", "iso3361_2_characters"=>"GB", "istat"=>219,
      "minint"=>219, "italian_country_name_1"=>"GR. BRET. - IRLANDA DEL NORD (REGNO UNITO)",
      "italian_country_code"=>"Z114", "taxcode_country_code"=>"Z114",
      "italian_country_name_2"=>"GRAN BRETAGNA E IRLANDA DEL NORD"}
    2.2.3 :003 > require "./dist/ruby/countries/tax_code.rb"
     => true
    2.2.3 :004 > Countries::TaxCode.get("Z102")
     => {"english_country_name"=>"Austria", "iso3361_3_characters"=>"AUT",
     "iso3361_2_characters"=>"AT", "istat"=>203, "minint"=>203,
     "italian_country_name_1"=>"AUSTRIA", "italian_country_code"=>"Z102",
     "taxcode_country_code"=>"Z102", "italian_country_name_2"=>"AUSTRIA"}

There are two ```italian_country_name``` fields because the data sources sometimes use different names for the same country. Both are included.

## Data sources

* ```wikipedia.csv``` tab separated data manually copied from https://en.wikipedia.org/wiki/ISO_3166-1#Current_codes
* ```ESTERI.XLS``` from http://www.agenziaentrate.gov.it/wps/content/Nsilib/Nsi/Strumenti/Codici+attivita+e+tributo/Codici+territorio/Comuni+italia+esteri/
* ```COD_EXT.xls``` unofficial data from an XLS embedded at the end of http://assistenzascot.insiel.it/reposit/Demografico%20-%20Documenti%20pubblicati/Codifica_esteri.doc

*The two Excel files are not included* in the repository because I'm unsure about their license.
If you want to run the generator script you must download them to the ```data``` directory.

## Generator script

The files in the ```dist``` directory have been generated with the ```make-tables.rb``` Ruby script.
It's not necessary to run it because the generated files are in the repository but in case you want to or have to (updates to the data, JSON and Ruby files with different indexes):

* Run ```bundle``` to install the gems
* Configure the script as explained below
* ```ruby make-tables.rb```

The script is likely to need some configuration to access the databases on your local machine.
Furthermore, you have to create those databases first.

Look for the ```# CONFIGURATION``` comments in the file. There are three of them
Each one introduces a database's section and is followed by the commands to create the database and
tables or (in the case of MongoDB) the collection.
Then there is a line that creates the connection to the database. You'll need to customize it.
The script is currently written to get the MySQL credentials from the environment and must be run like this
```MYSQL_USER=user MYSQL_PASS=pass ruby make-tables.rb```.
It assumes that no credential are needed to connect to the PostgreSQL. Works for me but probably not for you.
The connection details for mongo are in the ```mongo.yml``` file.

At the end of every database's section there is another comment with the CLI command to dump the country_codes tables/collection to the ```dist``` directory.

## License

```data/wikipedia.csv``` is subject to the license of https://en.wikipedia.org/wiki/ISO_3166-1 which at the time of writing is a [Creative Commons Attribution-ShareAlike 3.0](https://en.wikipedia.org/wiki/Wikipedia:Text_of_Creative_Commons_Attribution-ShareAlike_3.0_Unported_License)

The files in the ```dist``` directory, the ```Gemfile```, the ```make-tables.rb``` script and this ```README``` are released into the Public Domain:

```
This is free and unencumbered software released into the public domain.

Anyone is free to copy, modify, publish, use, compile, sell, or
distribute this software, either in source code form or as a compiled
binary, for any purpose, commercial or non-commercial, and by any
means.

In jurisdictions that recognize copyright laws, the author or authors
of this software dedicate any and all copyright interest in the
software to the public domain. We make this dedication for the benefit
of the public at large and to the detriment of our heirs and
successors. We intend this dedication to be an overt act of
relinquishment in perpetuity of all present and future rights to this
software under copyright law.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.
```

For more information, please refer to http://unlicense.org/
