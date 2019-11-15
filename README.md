
# Compile ReCAP statistics

### why?

Ease of collaboration, of course

### say more

So, of course, MARC/SCSB XML is the most sensible lossless format
for the bibliographic metadata for the materials in ReCAP, but it
is _harrowing_ to work with, especially if unfamiliar with SAX,
XPath, regular expressions, etc...
Additionally, it's hierarchical nature is at odds with the "flat
spreadsheet" thing that most of us are used to.
Instead of all of us processing it in idiosyncratic ways, let's all
use one projection of these SCSB XML data to flat file. We can all
collectively decide on the fields to include and how to include them.

It's also nice to have a nice version-controlled place to put this
code. In addition, we can (and will) set up a devops toolchain
to make this whole thing reproducible

### what, though?

So this is a multistep procedure that yields three spreadsheets
(tab-delimited, "NA" is null, etc...) meant for direct consumption:
  - `RECAP.dat`\
    The projection of all the SCSB XML data. As of time of writing,
    this includes 12.8 million items.
  - `transactions.dat`\
    Takes all the transaction data exported from LAS and, because there
    are overlaps in the time, removes the duplicates.
    At time of writing, this is 550,350 transactions from
    2017-06-20 to 2019-09-20.
  - `las-transaction-bib-info.dat`\
    In order to answer questions about what kind of materials we're
    borrowing from each other, the bib metadata table has to be
    joined with the transaction table. This is that.
    A few caveats... 20% of the barcodes in the transaction data do
    not have matches in the ReCAP XML data. _Why_ is a mystery.
    These records are still included, but there is no associated
    bib metadata, just the request date, owning and requesting
    institution, etc...
    Harvard, ILL, etc... transactions are ALSO included here. The
    HUL don't have any bib metadata, though, as they are not in the
    SCSB XML data export

For space and privacy the input and output files are "git-ignored" and
not in this repository. The (output) files are available on our
"ReCAP Assessment" shared drive.

The locations and MD5 checksums of the input files are described in
the `DATA-CHECKSUMS` file. The scripts are coded to read the input
files there.

---

### fields of `RECAP.dat`

  - __inst_has_item__\
    this is just the institution that owns the item

  - __barcode__\
    this is from 876\$p

  - __vol__\
    This is from 876\$3. This is really useful. It's usually NA for
    bibs that just have one item.

  - __numitems__\
    This is really useful, too. It's the number of items under each
    bib record

  - __scsbid__\
    From 001

  - __sharedp__\
    Whether it's "shared" or "open"

  - __language__\
    This is from characters 35 to 38 from the 008 (I think this is
    the most reliable

  - __pubdate__\
    Characters 7 to 11 of the 008 field

  - __biblevel__\
    A human-readable translation of the seventh character of the
    MARC leader

  - __recordtype__\
    A human-readable translation of the sixth character of the
    MARC leader

  - __oclc__\
    More complicated than just the 035\$a... It only really allows
    035s that have (OCoCL) in them, but its more complicated than that

  - __lccn__\
    Taken from the 010\$a but then normalized/canonicalized to look pretty

  - __isbn__\
    Took all 020\$as, removed non-isbn-looking-ones, normalized and converted
    to ISBN13s, removed (now) duplicated numbers, and put them all in one
    cell separated by a semicolon

  - __issn__\
    Same with ISBN but didn't convert to ISBN13 (obv)

  - __lccall__\
    Probably the most complicated of the bunch...
    So we take 050\$a _and_ 090\$a. We preferentially chose the former
    but if it is missing, we take the later.
    _THEN_ a lot of call numbers appear to by missing but, upon closer
    inspection, they are often hiding in the local call number at
    field 852\$h (for institutions that are not NYPL). Those are looked
    through and, if the 050/090 thing is missing, the institution is _not_
    the NYPL, and there is a local call number that fits a regex pattern
    that strongly suggests that it is a LC call, it's brought into this
    column\
    _This is not perfect._ For example, Avery has books that appear to be
    LC call but actually aren't. There's nothing we can do about this
    until we join with, in this example, Columbia's complete ILS data.\
    For posterity, the LC call _without_ the procedure of taking it from
    the local call number is in a separate column called `original_lccall`

  - __localcallnum__\
    852\$h. Often Billings for NYPL and LC for CUL/PUL. Not always, though.
    See `lccall` directly above

  - __oh09__\
    The 090. For the NYPL it's our ILS' bibids. Idk what it is for CUL/PUL

  - __pubplace__\
    The country code found at character 15 to 18 of the 008

  - __pubsubplace__\
    A regex-processed version of the 260\$a (usually publication city).
    If multiple, they are separated by semicolons

  - __leader__\
    MARC leader in full

  - __oh08__\
    008 in full

  - __dateoflastxaction__\
    They allege that the date of the last transaction can be found at
    0-8 of the 005 control field. I'm suspicious.

  - __title__\
    245\$a

  - __author__\
    100\$a

  - __topicalterms__\
    All the Library of Congress subject headers (650\$a for ind2 of 0)
    separated by a semicolon

  - __tmp__\
    I used this internally and forgot to remove it. Whoops.

  - __original_isbn__\
    The isbn before normalizations (posterity)

  - __original_issn__\
    The issn before normalizations (posterity)

  - __original_lccall__\
    The lc call before frantic attempts to recover from
    other fields (posterity)


---

### todo
  - Set up reproducible build environment with [Vagrant](https://www.vagrantup.com/)

---


