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
* two json objects, one indexed by the tax code and the other by the 3 letter code.

## Data sources

* wikipedia.csv  tab separated data manually copied from https://en.wikipedia.org/wiki/ISO_3166-1#Current_codes
* ESTERI.XLS     from http://www.agenziaentrate.gov.it/wps/content/Nsilib/Nsi/Strumenti/Codici+attivita+e+tributo/Codici+territorio/Comuni+italia+esteri/
* COD_EXT.xls    unofficial data from an XLS embedded at the end of http://assistenzascot.insiel.it/reposit/Demografico%20-%20Documenti%20pubblicati/Codifica_esteri.doc

The two Excel files are not included in the repository because I'm unsure about their license.

## Generator

The files in the dist/ directory have been generated with the make-tables.rb Ruby file.
It's not necessary to run it because the generated files are in the repository but in case you want to or have to (updates to the data).

Run ```bundle``` to install the gems and ```ruby make-tables.rb``` to run the script.

Before running it you'll have to configure it to access the databases and prepare the databases.
Look for the ```# CONFIGURATION``` comment in the file for the commands to setup the databases
and for connecting to them from within the script.

At the end of every database's section there is a comment with the command to dump the database.

## License

The files in the dist/ directory and the generator script are Public Domain.
