AE = Artificial.Everywhere
AB = Artificial.Babel

# On the server, create regions.
Document.startup ->
  return if Meteor.settings.startEmpty

  # Add the regions from the data string.
  dataRows = AE.CSVParser.parse AB.Region.data

  # Skip the first line since it's the header.
  for regionData in dataRows[1..]
    # Data format
    # 0: name,
    # 1: official_name_en
    # 2: official_name_fr
    # 3: ISO3166-1-Alpha-2
    # 4: ISO3166-1-Alpha-3
    # 5: M49
    # 6: ITU
    # 7: MARC
    # 8: WMO
    # 9: DS
    # 10: Dial
    # 11: FIFA
    # 12: FIPS
    # 13: GAUL
    # 14: IOC
    # 15: ISO4217-currency_alphabetic_code
    # 16: ISO4217-currency_country_name
    # 17: ISO4217-currency_minor_unit
    # 18: ISO4217-currency_name
    # 19: ISO4217-currency_numeric_code
    # 20: is_independent
    # 21: Capital
    # 22: Continent
    # 23: TLD
    # 24: Languages
    # 25: Geoname ID
    # 26: EDGAR
    regionCode = regionData[3].toLowerCase()
    continue unless regionCode.length

    regionDocument =
      code: regionCode
      name:
        en: regionData[0]

    AB.Region.create regionDocument

    # Add regions to languages.
    for languageRegion, regionRank in regionData[24].split ','
      languageCode = languageRegion.split('-')[0]

      # We only support 2-letter language codes.
      continue unless languageCode.length is 2

      AB.Language.addRegion languageCode, regionCode, regionRank + 1
