AB = Artificial.Babel
AM = Artificial.Mirage
RS = Retronator.Store

class RS.Components.Invoice extends AM.Component
  @id: -> 'Retronator.Store.Components.Invoice'
  @register @id()

  onCreated: ->
    super

    @language = new ReactiveField 'en'

    @autorun (computation) =>
      transaction = @data()

      for transactionItem in transaction.items
        continue unless item = RS.Item.documents.findOne transactionItem.item._id
        AB.Translation.forId.subscribe @, item.name._id, ['en', 'sl']

  formatDate: (date) ->
    language = @language()

    date.toLocaleString language,
      year: 'numeric'
      month: 'long'
      day: 'numeric'
      timeZone: 'UTC'
      
  items: ->
    transaction = @data()
    language = @language()
    vatRate = transaction.taxInfo.vatRate

    items = for transactionItem, index in transaction.items
      item = RS.Item.documents.findOne transactionItem.item._id
      item?.name.refresh()
      
      index: index + 1
      name: item?.name.translate(language).text
      value: transactionItem.price

    if transaction.tip
      items.push
        index: items.length + 1
        name: AB.translationForComponent(@, 'Tip')?.translate(language).text
        value: transaction.tip.amount

    for item in items
      # Item price is the value without VAT
      item.unitPrice = @_usdPrecision item.value / (1 + vatRate)

    items

  _usdPrecision: (value) ->
    Math.round(value * 100000) / 100000

  vatRatePercentage: ->
    transaction = @data()
    transaction.taxInfo.vatRate * 100

  subtotal: ->
    # The sum of all unit prices.
    @_usdPrecision _.sum (item.unitPrice for item in @items())

  storeCredit: ->
    transaction = @data()

    storeCredit = 0

    for payment in transaction.payments when payment.type is RS.Payment.Types.StoreCredit
      storeCredit += payment.storeCreditAmount

    storeCredit

  discount: ->
    transaction = @data()
    vatRate = transaction.taxInfo.vatRate

    # Discount is store credit without VAT
    @_usdPrecision @storeCredit() / (1 + vatRate)

  totalWithoutVat: ->
    @subtotal() - @discount()

  total: ->
    transaction = @data()

    # This is the total value of transaction minus store credit used.
    transaction.totalValue - @storeCredit()

  reverseCharge: ->
    transaction = @data()
    country = transaction.taxInfo.country.billing

    # Reverse charge applies to all business in the EU outside Slovenia.
    transaction.taxInfo.business and country in AB.Region.Lists.EuropeanUnion and country isnt 'si'

  electronicPurchase: ->
    transaction = @data()
    country = transaction.taxInfo.country.billing

    # Electronic purchase notice applies to all non-businesses outside Slovenia.
    not transaction.taxInfo.business and country isnt 'si'
