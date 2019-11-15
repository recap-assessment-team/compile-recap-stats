
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

  - __localcallnum__\

  - __oh09__\

  - __pubplace__\

  - __pubsubplace__\

  - __leader__\

  - __oh08__\

  - __dateoflastxaction__\

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


