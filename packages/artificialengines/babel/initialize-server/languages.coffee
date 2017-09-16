AB = Artificial.Babel
AE = Artificial.Everywhere

# On the server, create languages.
Document.startup ->
  return if Meteor.settings.startEmpty

  # Add the languages from the data string.
  dataRows = AE.CSVParser.parse AB.Language.data

  # Skip the first line since it's the header.
  for languageData in dataRows[1..]
    # Data format
    # 0: ISO 639-1
    # 1: ISO 639-2/B
    # 2: ISO 639-2/T
    # 3: en
    # 4: fr
    # 5: es
    # 6: it
    # 7: de
    # 8: pt
    # 9: ca
    # 10: native
    code = languageData[0]

    # Some names have multiple alternatives, separated with a semicolon. We use just the first.
    for i in [3..10]
      variants = languageData[i].split ';'
      languageData[i] = variants[0]

    languageDocument =
      code: code
      name:
        en: languageData[3]
        fr: languageData[4]
        es: languageData[5]
        it: languageData[6]
        de: languageData[7]
        pt: languageData[8]
        ca: languageData[9]
        "#{code}": languageData[10]

    AB.Language.create languageDocument
