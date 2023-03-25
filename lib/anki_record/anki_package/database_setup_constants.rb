# frozen_string_literal: true

module AnkiRecord
  ANKI_SCHEMA_DEFINITION = <<~SQL # :nodoc:
    CREATE TABLE col (
      id integer PRIMARY KEY,
      crt integer NOT NULL,
      mod integer NOT NULL,
      scm integer NOT NULL,
      ver integer NOT NULL,
      dty integer NOT NULL,
      usn integer NOT NULL,
      ls integer NOT NULL,
      conf text NOT NULL,
      models text NOT NULL,
      decks text NOT NULL,
      dconf text NOT NULL,
      tags text NOT NULL
    );
    CREATE TABLE notes (
      id integer PRIMARY KEY,
      guid text NOT NULL,
      mid integer NOT NULL,
      mod integer NOT NULL,
      usn integer NOT NULL,
      tags text NOT NULL,
      flds text NOT NULL,
      sfld integer NOT NULL,
      csum integer NOT NULL,
      flags integer NOT NULL,
      data text NOT NULL
    );
    CREATE TABLE cards (
      id integer PRIMARY KEY,
      nid integer NOT NULL,
      did integer NOT NULL,
      ord integer NOT NULL,
      mod integer NOT NULL,
      usn integer NOT NULL,
      type integer NOT NULL,
      queue integer NOT NULL,
      due integer NOT NULL,
      ivl integer NOT NULL,
      factor integer NOT NULL,
      reps integer NOT NULL,
      lapses integer NOT NULL,
      left integer NOT NULL,
      odue integer NOT NULL,
      odid integer NOT NULL,
      flags integer NOT NULL,
      data text NOT NULL
    );
    CREATE TABLE revlog (
      id integer PRIMARY KEY,
      cid integer NOT NULL,
      usn integer NOT NULL,
      ease integer NOT NULL,
      ivl integer NOT NULL,
      lastIvl integer NOT NULL,
      factor integer NOT NULL,
      time integer NOT NULL,
      type integer NOT NULL
    );
    CREATE INDEX ix_notes_usn ON notes (usn);
    CREATE INDEX ix_cards_usn ON cards (usn);
    CREATE INDEX ix_revlog_usn ON revlog (usn);
    CREATE INDEX ix_cards_nid ON cards (nid);
    CREATE INDEX ix_cards_sched ON cards (did, queue, due);
    CREATE INDEX ix_revlog_cid ON revlog (cid);
    CREATE INDEX ix_notes_csum ON notes (csum);
    CREATE TABLE graves (
      usn integer NOT NULL,
      oid integer NOT NULL,
      type integer NOT NULL
    );
  SQL

  ##
  # This is the SQL insert statement (as a Ruby string/here document) for the
  # default col record in the collection.anki2 database exported from a new Anki 2.1.54 profile
  INSERT_COLLECTION_ANKI_2_COL_RECORD = <<~SQL
    INSERT INTO col VALUES(1,1676883600,1676902390012,1676902390005,11,0,0,0,'{"addToCur":true,"_deck_1_lastNotetype":1676902390008,"nextPos":2,"sortType":"noteFld","newSpread":0,"schedVer":2,"collapseTime":1200,"estTimes":true,"curDeck":1,"creationOffset":300,"dayLearnFirst":false,"timeLim":0,"activeDecks":[1],"sortBackwards":false,"_nt_1676902390008_lastDeck":1,"curModel":1676902390008,"dueCounts":true}','{"1676902390010":{"id":1676902390010,"name":"Basic (optional reversed card)","type":0,"mod":0,"usn":0,"sortf":0,"did":null,"tmpls":[{"name":"Card 1","ord":0,"qfmt":"{{Front}}","afmt":"{{FrontSide}}\\n\\n<hr id=answer>\\n\\n{{Back}}","bqfmt":"","bafmt":"","did":null,"bfont":"","bsize":0},{"name":"Card 2","ord":1,"qfmt":"{{#Add Reverse}}{{Back}}{{/Add Reverse}}","afmt":"{{FrontSide}}\\n\\n<hr id=answer>\\n\\n{{Front}}","bqfmt":"","bafmt":"","did":null,"bfont":"","bsize":0}],"flds":[{"name":"Front","ord":0,"sticky":false,"rtl":false,"font":"Arial","size":20,"description":""},{"name":"Back","ord":1,"sticky":false,"rtl":false,"font":"Arial","size":20,"description":""},{"name":"Add Reverse","ord":2,"sticky":false,"rtl":false,"font":"Arial","size":20,"description":""}],"css":".card {\\n    font-family: arial;\\n    font-size: 20px;\\n    text-align: center;\\n    color: black;\\n    background-color: white;\\n}\\n","latexPre":"\\\\documentclass[12pt]{article}\\n\\\\special{papersize=3in,5in}\\n\\\\usepackage[utf8]{inputenc}\\n\\\\usepackage{amssymb,amsmath}\\n\\\\pagestyle{empty}\\n\\\\setlength{\\\\parindent}{0in}\\n\\\\begin{document}\\n","latexPost":"\\\\end{document}","latexsvg":false,"req":[[0,"any",[0]],[1,"all",[1,2]]]},"1676902390009":{"id":1676902390009,"name":"Basic (and reversed card)","type":0,"mod":0,"usn":0,"sortf":0,"did":null,"tmpls":[{"name":"Card 1","ord":0,"qfmt":"{{Front}}","afmt":"{{FrontSide}}\\n\\n<hr id=answer>\\n\\n{{Back}}","bqfmt":"","bafmt":"","did":null,"bfont":"","bsize":0},{"name":"Card 2","ord":1,"qfmt":"{{Back}}","afmt":"{{FrontSide}}\\n\\n<hr id=answer>\\n\\n{{Front}}","bqfmt":"","bafmt":"","did":null,"bfont":"","bsize":0}],"flds":[{"name":"Front","ord":0,"sticky":false,"rtl":false,"font":"Arial","size":20,"description":""},{"name":"Back","ord":1,"sticky":false,"rtl":false,"font":"Arial","size":20,"description":""}],"css":".card {\\n    font-family: arial;\\n    font-size: 20px;\\n    text-align: center;\\n    color: black;\\n    background-color: white;\\n}\\n","latexPre":"\\\\documentclass[12pt]{article}\\n\\\\special{papersize=3in,5in}\\n\\\\usepackage[utf8]{inputenc}\\n\\\\usepackage{amssymb,amsmath}\\n\\\\pagestyle{empty}\\n\\\\setlength{\\\\parindent}{0in}\\n\\\\begin{document}\\n","latexPost":"\\\\end{document}","latexsvg":false,"req":[[0,"any",[0]],[1,"any",[1]]]},"1676902390008":{"id":1676902390008,"name":"Basic","type":0,"mod":0,"usn":0,"sortf":0,"did":null,"tmpls":[{"name":"Card 1","ord":0,"qfmt":"{{Front}}","afmt":"{{FrontSide}}\\n\\n<hr id=answer>\\n\\n{{Back}}","bqfmt":"","bafmt":"","did":null,"bfont":"","bsize":0}],"flds":[{"name":"Front","ord":0,"sticky":false,"rtl":false,"font":"Arial","size":20,"description":""},{"name":"Back","ord":1,"sticky":false,"rtl":false,"font":"Arial","size":20,"description":""}],"css":".card {\\n    font-family: arial;\\n    font-size: 20px;\\n    text-align: center;\\n    color: black;\\n    background-color: white;\\n}\\n","latexPre":"\\\\documentclass[12pt]{article}\\n\\\\special{papersize=3in,5in}\\n\\\\usepackage[utf8]{inputenc}\\n\\\\usepackage{amssymb,amsmath}\\n\\\\pagestyle{empty}\\n\\\\setlength{\\\\parindent}{0in}\\n\\\\begin{document}\\n","latexPost":"\\\\end{document}","latexsvg":false,"req":[[0,"any",[0]]]},"1676902390011":{"id":1676902390011,"name":"Basic (type in the answer)","type":0,"mod":0,"usn":0,"sortf":0,"did":null,"tmpls":[{"name":"Card 1","ord":0,"qfmt":"{{Front}}\\n\\n{{type:Back}}","afmt":"{{Front}}\\n\\n<hr id=answer>\\n\\n{{type:Back}}","bqfmt":"","bafmt":"","did":null,"bfont":"","bsize":0}],"flds":[{"name":"Front","ord":0,"sticky":false,"rtl":false,"font":"Arial","size":20,"description":""},{"name":"Back","ord":1,"sticky":false,"rtl":false,"font":"Arial","size":20,"description":""}],"css":".card {\\n    font-family: arial;\\n    font-size: 20px;\\n    text-align: center;\\n    color: black;\\n    background-color: white;\\n}\\n","latexPre":"\\\\documentclass[12pt]{article}\\n\\\\special{papersize=3in,5in}\\n\\\\usepackage[utf8]{inputenc}\\n\\\\usepackage{amssymb,amsmath}\\n\\\\pagestyle{empty}\\n\\\\setlength{\\\\parindent}{0in}\\n\\\\begin{document}\\n","latexPost":"\\\\end{document}","latexsvg":false,"req":[[0,"any",[0,1]]]},"1676902390012":{"id":1676902390012,"name":"Cloze","type":1,"mod":0,"usn":0,"sortf":0,"did":null,"tmpls":[{"name":"Cloze","ord":0,"qfmt":"{{cloze:Text}}","afmt":"{{cloze:Text}}<br>\\n{{Back Extra}}","bqfmt":"","bafmt":"","did":null,"bfont":"","bsize":0}],"flds":[{"name":"Text","ord":0,"sticky":false,"rtl":false,"font":"Arial","size":20,"description":""},{"name":"Back Extra","ord":1,"sticky":false,"rtl":false,"font":"Arial","size":20,"description":""}],"css":".card {\\n    font-family: arial;\\n    font-size: 20px;\\n    text-align: center;\\n    color: black;\\n    background-color: white;\\n}\\n.cloze {\\n    font-weight: bold;\\n    color: blue;\\n}\\n.nightMode .cloze {\\n    color: lightblue;\\n}\\n","latexPre":"\\\\documentclass[12pt]{article}\\n\\\\special{papersize=3in,5in}\\n\\\\usepackage[utf8]{inputenc}\\n\\\\usepackage{amssymb,amsmath}\\n\\\\pagestyle{empty}\\n\\\\setlength{\\\\parindent}{0in}\\n\\\\begin{document}\\n","latexPost":"\\\\end{document}","latexsvg":false,"req":[[0,"any",[0]]]}}','{"1":{"id":1,"mod":0,"name":"Default","usn":0,"lrnToday":[0,0],"revToday":[0,0],"newToday":[0,0],"timeToday":[0,0],"collapsed":true,"browserCollapsed":true,"desc":"","dyn":0,"conf":1,"extendNew":0,"extendRev":0}}','{"1":{"id":1,"mod":0,"name":"Default","usn":0,"maxTaken":60,"autoplay":true,"timer":0,"replayq":true,"new":{"bury":false,"delays":[1.0,10.0],"initialFactor":2500,"ints":[1,4,0],"order":1,"perDay":20},"rev":{"bury":false,"ease4":1.3,"ivlFct":1.0,"maxIvl":36500,"perDay":200,"hardFactor":1.2},"lapse":{"delays":[10.0],"leechAction":1,"leechFails":8,"minInt":1,"mult":0.0},"dyn":false,"newMix":0,"newPerDayMinimum":0,"interdayLearningMix":0,"reviewOrder":0,"newSortOrder":0,"newGatherPriority":0,"buryInterdayLearning":false}}','{}');
  SQL

  ##
  # This is the SQL insert statement (as a Ruby string/here document) for the
  # default col record in the collection.anki21 database exported from a new Anki 2.1.54 profile
  INSERT_COLLECTION_ANKI_21_COL_RECORD = <<~SQL
    INSERT INTO col VALUES(1,1676883600,0,1676902364657,11,0,0,0,'{"activeDecks":[1],"curDeck":1,"nextPos":1,"schedVer":2,"sortType":"noteFld","estTimes":true,"collapseTime":1200,"dayLearnFirst":false,"curModel":1676902364661,"sortBackwards":false,"newSpread":0,"creationOffset":300,"timeLim":0,"addToCur":true,"dueCounts":true}','{"1676902364664":{"id":1676902364664,"name":"Basic (type in the answer)","type":0,"mod":0,"usn":0,"sortf":0,"did":null,"tmpls":[{"name":"Card 1","ord":0,"qfmt":"{{Front}}\\n\\n{{type:Back}}","afmt":"{{Front}}\\n\\n<hr id=answer>\\n\\n{{type:Back}}","bqfmt":"","bafmt":"","did":null,"bfont":"","bsize":0}],"flds":[{"name":"Front","ord":0,"sticky":false,"rtl":false,"font":"Arial","size":20,"description":""},{"name":"Back","ord":1,"sticky":false,"rtl":false,"font":"Arial","size":20,"description":""}],"css":".card {\\n    font-family: arial;\\n    font-size: 20px;\\n    text-align: center;\\n    color: black;\\n    background-color: white;\\n}\\n","latexPre":"\\\\documentclass[12pt]{article}\\n\\\\special{papersize=3in,5in}\\n\\\\usepackage[utf8]{inputenc}\\n\\\\usepackage{amssymb,amsmath}\\n\\\\pagestyle{empty}\\n\\\\setlength{\\\\parindent}{0in}\\n\\\\begin{document}\\n","latexPost":"\\\\end{document}","latexsvg":false,"req":[[0,"any",[0,1]]]},"1676902364663":{"id":1676902364663,"name":"Basic (optional reversed card)","type":0,"mod":0,"usn":0,"sortf":0,"did":null,"tmpls":[{"name":"Card 1","ord":0,"qfmt":"{{Front}}","afmt":"{{FrontSide}}\\n\\n<hr id=answer>\\n\\n{{Back}}","bqfmt":"","bafmt":"","did":null,"bfont":"","bsize":0},{"name":"Card 2","ord":1,"qfmt":"{{#Add Reverse}}{{Back}}{{/Add Reverse}}","afmt":"{{FrontSide}}\\n\\n<hr id=answer>\\n\\n{{Front}}","bqfmt":"","bafmt":"","did":null,"bfont":"","bsize":0}],"flds":[{"name":"Front","ord":0,"sticky":false,"rtl":false,"font":"Arial","size":20,"description":""},{"name":"Back","ord":1,"sticky":false,"rtl":false,"font":"Arial","size":20,"description":""},{"name":"Add Reverse","ord":2,"sticky":false,"rtl":false,"font":"Arial","size":20,"description":""}],"css":".card {\\n    font-family: arial;\\n    font-size: 20px;\\n    text-align: center;\\n    color: black;\\n    background-color: white;\\n}\\n","latexPre":"\\\\documentclass[12pt]{article}\\n\\\\special{papersize=3in,5in}\\n\\\\usepackage[utf8]{inputenc}\\n\\\\usepackage{amssymb,amsmath}\\n\\\\pagestyle{empty}\\n\\\\setlength{\\\\parindent}{0in}\\n\\\\begin{document}\\n","latexPost":"\\\\end{document}","latexsvg":false,"req":[[0,"any",[0]],[1,"all",[1,2]]]},"1676902364665":{"id":1676902364665,"name":"Cloze","type":1,"mod":0,"usn":0,"sortf":0,"did":null,"tmpls":[{"name":"Cloze","ord":0,"qfmt":"{{cloze:Text}}","afmt":"{{cloze:Text}}<br>\\n{{Back Extra}}","bqfmt":"","bafmt":"","did":null,"bfont":"","bsize":0}],"flds":[{"name":"Text","ord":0,"sticky":false,"rtl":false,"font":"Arial","size":20,"description":""},{"name":"Back Extra","ord":1,"sticky":false,"rtl":false,"font":"Arial","size":20,"description":""}],"css":".card {\\n    font-family: arial;\\n    font-size: 20px;\\n    text-align: center;\\n    color: black;\\n    background-color: white;\\n}\\n.cloze {\\n    font-weight: bold;\\n    color: blue;\\n}\\n.nightMode .cloze {\\n    color: lightblue;\\n}\\n","latexPre":"\\\\documentclass[12pt]{article}\\n\\\\special{papersize=3in,5in}\\n\\\\usepackage[utf8]{inputenc}\\n\\\\usepackage{amssymb,amsmath}\\n\\\\pagestyle{empty}\\n\\\\setlength{\\\\parindent}{0in}\\n\\\\begin{document}\\n","latexPost":"\\\\end{document}","latexsvg":false,"req":[[0,"any",[0]]]},"1676902364661":{"id":1676902364661,"name":"Basic","type":0,"mod":0,"usn":0,"sortf":0,"did":null,"tmpls":[{"name":"Card 1","ord":0,"qfmt":"{{Front}}","afmt":"{{FrontSide}}\\n\\n<hr id=answer>\\n\\n{{Back}}","bqfmt":"","bafmt":"","did":null,"bfont":"","bsize":0}],"flds":[{"name":"Front","ord":0,"sticky":false,"rtl":false,"font":"Arial","size":20,"description":""},{"name":"Back","ord":1,"sticky":false,"rtl":false,"font":"Arial","size":20,"description":""}],"css":".card {\\n    font-family: arial;\\n    font-size: 20px;\\n    text-align: center;\\n    color: black;\\n    background-color: white;\\n}\\n","latexPre":"\\\\documentclass[12pt]{article}\\n\\\\special{papersize=3in,5in}\\n\\\\usepackage[utf8]{inputenc}\\n\\\\usepackage{amssymb,amsmath}\\n\\\\pagestyle{empty}\\n\\\\setlength{\\\\parindent}{0in}\\n\\\\begin{document}\\n","latexPost":"\\\\end{document}","latexsvg":false,"req":[[0,"any",[0]]]},"1676902364662":{"id":1676902364662,"name":"Basic (and reversed card)","type":0,"mod":0,"usn":0,"sortf":0,"did":null,"tmpls":[{"name":"Card 1","ord":0,"qfmt":"{{Front}}","afmt":"{{FrontSide}}\\n\\n<hr id=answer>\\n\\n{{Back}}","bqfmt":"","bafmt":"","did":null,"bfont":"","bsize":0},{"name":"Card 2","ord":1,"qfmt":"{{Back}}","afmt":"{{FrontSide}}\\n\\n<hr id=answer>\\n\\n{{Front}}","bqfmt":"","bafmt":"","did":null,"bfont":"","bsize":0}],"flds":[{"name":"Front","ord":0,"sticky":false,"rtl":false,"font":"Arial","size":20,"description":""},{"name":"Back","ord":1,"sticky":false,"rtl":false,"font":"Arial","size":20,"description":""}],"css":".card {\\n    font-family: arial;\\n    font-size: 20px;\\n    text-align: center;\\n    color: black;\\n    background-color: white;\\n}\\n","latexPre":"\\\\documentclass[12pt]{article}\\n\\\\special{papersize=3in,5in}\\n\\\\usepackage[utf8]{inputenc}\\n\\\\usepackage{amssymb,amsmath}\\n\\\\pagestyle{empty}\\n\\\\setlength{\\\\parindent}{0in}\\n\\\\begin{document}\\n","latexPost":"\\\\end{document}","latexsvg":false,"req":[[0,"any",[0]],[1,"any",[1]]]}}','{"1":{"id":1,"mod":0,"name":"Default","usn":0,"lrnToday":[0,0],"revToday":[0,0],"newToday":[0,0],"timeToday":[0,0],"collapsed":true,"browserCollapsed":true,"desc":"","dyn":0,"conf":1,"extendNew":0,"extendRev":0}}','{"1":{"id":1,"mod":0,"name":"Default","usn":0,"maxTaken":60,"autoplay":true,"timer":0,"replayq":true,"new":{"bury":false,"delays":[1.0,10.0],"initialFactor":2500,"ints":[1,4,0],"order":1,"perDay":20},"rev":{"bury":false,"ease4":1.3,"ivlFct":1.0,"maxIvl":36500,"perDay":200,"hardFactor":1.2},"lapse":{"delays":[10.0],"leechAction":1,"leechFails":8,"minInt":1,"mult":0.0},"dyn":false,"newMix":0,"newPerDayMinimum":0,"interdayLearningMix":0,"reviewOrder":0,"newSortOrder":0,"newGatherPriority":0,"buryInterdayLearning":false}}','{}');
  SQL
end
