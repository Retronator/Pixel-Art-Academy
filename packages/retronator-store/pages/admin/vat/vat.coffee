AE = Artificial.Everywhere
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

    @year = new ReactiveField null
    @month = new ReactiveField null
    @quarter = new ReactiveField null
    @range = new AE.DateRange

    @setYear new Date().getFullYear()

  setYear: (year) ->
    @year year
    @range.start new Date year, 0, 1
    @range.end new Date year + 1, 0, 1
    @month null
    @quarter null

  setMonth: (month) ->
    year = @year()
    @range.start new Date year, month, 1
    @range.end new Date year, month + 1, 1
    @quarter null

  setQuarter: (quarter) ->
    year = @year()
    @range.start new Date year, (quarter - 1) * 3, 1
    @range.end new Date year, quarter * 3, 1
    @month null

  setStart: (date) ->
    @range.start date
    @year null
    @month null
    @quarter null

  setEnd: (date) ->
    @range.end date
    @year null
    @month null
    @quarter null

  transactions: ->
    query = taxInfo: $exists: true
    @range.addToMongoQuery query, 'time'

    RS.Transaction.documents.find query,
      sort:
        time: 1

  totalAmountEur: ->
    totalAmount =
      net: 0
      vat: 0

    for transaction in @transactions().fetch()
      totalAmount.net += transaction.taxInfo.amountEur.net
      totalAmount.vat += transaction.taxInfo.amountEur.vat if transaction.taxInfo.amountEur.vat

    totalAmount

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

  class @DataInput extends AM.DataInputComponent
    onCreated: ->
      super

      @vat = @ancestorComponentOfType RS.Pages.Admin.Vat

  class @Year extends @DataInput
    @register 'Retronator.Store.Pages.Admin.Vat.Year'

    constructor: ->
      super

      @type = AM.DataInputComponent.Types.Number

    load: -> @vat.year()
    save: (value) -> @vat.setYear parseInt value

  class @Month extends @DataInput
    @register 'Retronator.Store.Pages.Admin.Vat.Month'

    constructor: ->
      super

      @type = AM.DataInputComponent.Types.Select

    options: ->
      options = [
        value: ''
        name: ''
      ]

      for month in [0..11]
        options.push
          value: month
          name: new Date(2018, month, 1).toLocaleString 'en-US', month: 'long'

      options

    load: -> @vat.month()
    save: (value) -> @vat.setMonth parseInt value

  class @Quarter extends @DataInput
    @register 'Retronator.Store.Pages.Admin.Vat.Quarter'

    constructor: ->
      super

      @type = AM.DataInputComponent.Types.Select

    options: ->
      options = [
        value: ''
        name: ''
      ]

      for quarter in [1..4]
        options.push
          value: quarter
          name: "Q#{quarter}"

      options

    load: -> @vat.quarter()
    save: (value) -> @vat.setQuarter parseInt value

  class @DateInput extends @DataInput
    constructor: ->
      super

      @type = AM.DataInputComponent.Types.Date

    _dateValue: (date) ->
      "#{date.getFullYear()}-#{_.padStart date.getMonth() + 1, 2, '0'}-#{_.padStart date.getDate(), 2, '0'}"

  class @Start extends @DateInput
    @register 'Retronator.Store.Pages.Admin.Vat.Start'

    load: -> @_dateValue @vat.range.start()
    save: (value) -> @vat.setStart new Date value

  class @End extends @DateInput
    @register 'Retronator.Store.Pages.Admin.Vat.End'

    load: ->  @_dateValue  @vat.range.end()
    save: (value) -> @vat.setEnd new Date value
