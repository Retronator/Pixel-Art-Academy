AE = Artificial.Everywhere
RA = Retronator.Accounts
RS = Retronator.Store

# Dates are passed as calendar days, avoiding timezone changes to the invoice year and exchange rate.
parseInvoiceDate = (value) ->
  check value, String
  date = new Date "#{value}T00:00:00.000Z"
  unless /^\d{4}-\d{2}-\d{2}$/.test(value) and isFinite(date.getTime()) and date.toISOString().slice(0, 10) is value
    throw new AE.ArgumentException "Enter a valid date of issue."
  throw new AE.ArgumentException "The date of issue cannot be in the future." if value > new Date().toISOString().slice(0, 10)
  date

RS.Pages.Admin.IssueInvoice.invoiceDefaults.method (dateOfIssue) ->
  RA.authorizeAdmin()
  date = parseInvoiceDate dateOfIssue
  invoiceId: RS.Transaction.nextInvoiceId date
  usdToEurExchangeRate: RS.Vat.ExchangeRate.usdToEurForDate date

RS.Pages.Admin.IssueInvoice.issueInvoice.method (invoice) ->
  RA.authorizeAdmin()
  check invoice,
    dateOfIssue: String
    customer:
      name: String
      address: String
      vatId: String
      country: String
      email: String
    items: [{catalogKey: String, description: String, price: Number, create: Boolean}]
    vatRate: Number

  date = parseInvoiceDate invoice.dateOfIssue
  customer = invoice.customer
  for field in ['name', 'address', 'email', 'country']
    throw new AE.ArgumentException "Customer #{field} is required." unless customer[field].trim().length
  unless /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test customer.email.trim()
    throw new AE.ArgumentException "Enter a valid customer email."
  unless Artificial.Babel.Region.documents.findOne code: customer.country
    throw new AE.ArgumentException "Select a country."
  throw new AE.ArgumentException "Select a VAT rate of 0 or 22%." unless invoice.vatRate in [0, 0.22]
  throw new AE.ArgumentException "Add at least one item." unless invoice.items.length

  # Validate every line before creating any catalog entries or assigning an invoice number.
  totalUsd = 0
  newCatalogKeys = []
  for line in invoice.items
    unless isFinite(line.price) and line.price > 0
      throw new AE.ArgumentException "Item prices must be positive finite USD amounts."
    line.catalogKey = line.catalogKey.trim()
    existingItem = RS.Item.documents.findOne catalogKey: line.catalogKey
    if line.create
      unless line.catalogKey.length and line.description.trim().length
        throw new AE.ArgumentException "New items require a catalog key and description."
      if existingItem or line.catalogKey in newCatalogKeys
        throw new AE.ArgumentException "The new catalog key already exists or is repeated."
      newCatalogKeys.push line.catalogKey
    else
      throw new AE.ArgumentException "Select an existing catalog key." unless existingItem
    totalUsd += line.price

  throw new AE.ArgumentException "The invoice total is too large." unless isFinite totalUsd

  exchangeRate = RS.Vat.ExchangeRate.usdToEurForDate date
  amounts = RS.Vat.calculateVat
    desiredTotalAmountUsd: totalUsd
    usdToEurExchangeRate: exchangeRate
    vatRate: invoice.vatRate

  transactionItems = for line in invoice.items
    if line.create
      RS.Item.create
        catalogKey: line.catalogKey
        name: line.description.trim()
        description: line.description.trim()
    item = RS.Item.documents.findOne catalogKey: line.catalogKey
    item: {_id: item._id}
    price: line.price

  accessSecret = Random.id()

  # The preview may be stale by now, so determine the number from the latest issued invoice again.
  invoiceId = RS.Transaction.nextInvoiceId date
  transactionId = RS.Transaction.documents.insert
    time: date
    items: transactionItems
    payments: []
    accessSecret: accessSecret
    email: customer.email.trim().toLowerCase()
    taxInfo:
      country:
        billing: customer.country
        payment: customer.country
      business: _.pick customer, 'name', 'address', 'vatId'
      vatRate: invoice.vatRate
      usdToEurExchangeRate: exchangeRate
      amountEur:
        net: amounts.netAmountEur
        vat: amounts.vatAmountEur
      invoiceId: invoiceId

  {transactionId, accessSecret, invoiceId}
