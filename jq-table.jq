 [.[]| with_entries( .key |= ascii_downcase ) ]
      |    (.[0] |keys_unsorted | @tsv)
         , (.[]  |map(.) |@tsv)
