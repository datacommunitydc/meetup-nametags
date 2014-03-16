meetup-nametags
===============

This tool lets you generate a CSV file that can be used to mail-merge
nametags using the process of your choice.

By [Harlan Harris](https://github.com/HarlanH) for 
[Data Community DC](http://datacommunitydc.org).

Prerequisites:

* R
* the following packages: plyr, httr, rjson

To run:

`./meetup-nametags MEETUP_API_KEY Meetup-URL-Name > tagslist.csv`

Once you have the CSV file, here's what I do to make labels:

1. Open the CSV file in LibreOffice and save it as a Spreadsheet.
2. Create a new Database in LibreOffice, using the existing Spreadsheet.
3. From LibreOffice Writer, create new Labels, using the Database you created. Select the `name` and `titlerole` columns, in that order. (In some versions, you may need to force the tool to sync in Options.)
4. Edit the formatting of the first cell.
5. Press the sync button to make the other cells reflect the first one.
6. Use the Mail Merge feature to populate and print the result onto labels.

(If you've got a simpler way to do it, pull requests on this documentation appreciated!)
