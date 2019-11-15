
# Compile ReCAP statistics

### why?

Of course

---

### fields

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

  - __author__\

  - __topicalterms__\

  - __tmp__\

  - __original_isbn__\

  - __original_issn__\

  - __original_lccall__\



---

### todo
  - Set up reproducible build environment with [Vagrant](https://www.vagrantup.com/)

---


