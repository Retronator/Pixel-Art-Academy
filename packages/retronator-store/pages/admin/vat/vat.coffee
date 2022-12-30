AE = Artificial.Everywhere
AB = Artificial.Babel
AM = Artificial.Mirage
RA = Retronator.Accounts
RS = Retronator.Store

class RS.Pages.Admin.Vat extends AM.Component
  @id: -> 'Retronator.Store.Pages.Admin.Vat'
  @register @id()

  onCreated: ->
    super arguments...

    RS.Item.all.subscribe @

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

  csvExport: ->
    lines = for transaction in @transactions().fetch()
      taxInfo = transaction.taxInfo

      values = [
        "#{taxInfo.invoiceId.year}-#{taxInfo.invoiceId.number}"
        transaction.time.toLocaleString 'sl',
          year: 'numeric'
          month: 'numeric'
          day: 'numeric'
          timeZone: 'UTC'
        taxInfo.business?.name or "fizična oseba"
        taxInfo.country.access or taxInfo.country.payment
        taxInfo.vatRate.toLocaleString 'sl'
        taxInfo.amountEur.net.toLocaleString 'sl'
        taxInfo.amountEur.vat?.toLocaleString 'sl'
      ]

      values = ("\"#{value}\"" for value in values)

      values.join ', '

    lines.join '\n'

  transactionClass: ->
    transaction = @currentData()

    # All transactions in Slovenia are bundled together as they get
    # accounted directly, regardless if they are consumers of business.
    if transaction.taxInfo.country.billing is 'si'
      'si'

    # When not a Slovenian transaction, as long as we have a vat ID, it must have been an European business (at the time
    # of the transaction). Note that we can't just check for the vat rate to be set since it will be zero due to the
    # reverse charge.
    else if transaction.taxInfo.business?.vatId
      'eu-business'

    # If there was a vat rate specified and since it's not a Slovenian transaction,
    # it must have been sold to an EU consumer (at the time of the transaction).
    else if transaction.taxInfo.vatRate
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
    transaction for transaction in @transactions().fetch() when transaction.taxInfo.business?.vatId and transaction.taxInfo.country.billing isnt 'si'

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

  euConsumerCountries: ->
    transactions = (transaction for transaction in @transactions().fetch() when not transaction.taxInfo.business and transaction.taxInfo.vatRate and transaction.taxInfo.country.billing isnt 'si')

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
      super arguments...

      @vat = @ancestorComponentOfType RS.Pages.Admin.Vat

  class @Year extends @DataInput
    @register 'Retronator.Store.Pages.Admin.Vat.Year'

    constructor: ->
      super arguments...

      @type = AM.DataInputComponent.Types.Number

    load: -> @vat.year()
    save: (value) -> @vat.setYear parseInt value

  class @Month extends @DataInput
    @register 'Retronator.Store.Pages.Admin.Vat.Month'

    constructor: ->
      super arguments...

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
      super arguments...

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
      super arguments...

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
