AB = Artificial.Babel
AM = Artificial.Mirage
RA = Retronator.Accounts
RS = Retronator.Store

class RS.Pages.Admin.Vat extends AM.Component
  @id: -> 'Retronator.Store.Pages.Admin.Vat'
  @register @id()

  onCreated: ->
    super

    @subscribe Retronator.Store.Item.all

    RS.Transaction.withTaxInfo.subscribe @

  transactions: ->
    RS.Transaction.documents.find taxInfo: $exists: true

  transactionClass: ->
    transaction = @currentData()

    if transaction.taxInfo.country.billing is 'si'
      'si'

    else if transaction.taxInfo.country.billing in AB.Region.Lists.EuropeanUnion
      if transaction.taxInfo.business
        'eu-business'

      else
        'eu-consumer'

    else
      'non-eu'

  formatDate: (date) ->
    date.toLocaleString 'en',
      year: 'numeric'
      month: 'long'
      day: 'numeric'
      timeZone: 'UTC'

  dobaveBlagaInStoritev: ->
    Math.round _.sum (transaction.taxInfo.amountEur.net for transaction in @transactions().fetch() when transaction.taxInfo.country.billing is 'si')

  euBusinessesTransactions: ->
    euCountriesExceptSi = _.without AB.Region.Lists.EuropeanUnion, 'si'
    transaction for transaction in @transactions().fetch() when transaction.taxInfo.business and transaction.taxInfo.country.billing in euCountriesExceptSi

  dobaveBlagaInStoritevVDrugeDrzaveClaniceEU: ->
    Math.round _.sum (transaction.taxInfo.amountEur.net for transaction in @euBusinessesTransactions())

  poStopnji22: ->
    Math.round _.sum (transaction.taxInfo.amountEur.vat for transaction in @transactions().fetch() when transaction.taxInfo.country.billing is 'si')

  euBusinesses: ->
    transactions = @euBusinessesTransactions()

    vatIds = _.uniq (transaction.taxInfo.business.vatId for transaction in transactions)

    for vatId in vatIds
      vatIdCountry: vatId[0..1]
      vatIdNumber: vatId[2..]
      totalAmount: _.sum (transaction.taxInfo.amountEur.net for transaction in _.filter transactions, (transaction) => transaction.taxInfo.business.vatId is vatId)

  totalEuBusinessAmount: ->
    _.sum (transaction.taxInfo.amountEur.net for transaction in @euBusinessesTransactions())

  euCountries: ->
    euCountriesExceptSi = _.without AB.Region.Lists.EuropeanUnion, 'si'
    transactions = (transaction for transaction in @transactions().fetch() when not transaction.taxInfo.business and transaction.taxInfo.country.billing in euCountriesExceptSi)

    countries = _.uniq (transaction.taxInfo.country.billing for transaction in transactions)

    for country in countries
      countryTransactions = _.filter transactions, (transaction) => transaction.taxInfo.country.billing is country
      vatRate = countryTransactions[0].taxInfo.vatRate

      country: country
      vatRate: vatRate
      taxableAmount: _.sum (transaction.taxInfo.amountEur.net for transaction in countryTransactions)
      vatAmount: _.sum (transaction.taxInfo.amountEur.vat for transaction in countryTransactions)
