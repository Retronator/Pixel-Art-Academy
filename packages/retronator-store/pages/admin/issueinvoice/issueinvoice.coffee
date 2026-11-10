AB = Artificial.Babel
ABs = Artificial.Base
AM = Artificial.Mirage
RS = Retronator.Store

class RS.Pages.Admin.IssueInvoice extends AM.Component
  @id: -> 'Retronator.Store.Pages.Admin.IssueInvoice'
  @register @id()

  @invoiceDefaults: new ABs.Method name: "#{@id()}.invoiceDefaults"
  @issueInvoice: new ABs.Method name: "#{@id()}.issueInvoice"

  onCreated: ->
    super arguments...
    RS.Item.all.subscribe @

    @dateOfIssue = new ReactiveField new Date().toISOString().slice 0, 10
    @country = new ReactiveField ''
    @lines = new ReactiveField [{_id: Random.id()}]
    @defaults = new ReactiveField null
    @error = new ReactiveField null
    # Keep the last successful invoice available after a page recreation or development hot reload.
    # Scope the receipt to this tab and administrator rather than sharing it across signed-in users.
    @_issuedInvoiceStorageKey = "#{@constructor.id()}.issuedInvoice.#{Meteor.userId()}"
    @issuedInvoice = new ReactiveField @_loadIssuedInvoice()
    @issuing = new ReactiveField false
    @totalUsd = new ReactiveField 0
    @vatRate = new ReactiveField 0
    @_requestNumber = 0

    @autorun => @refreshDefaults @dateOfIssue()
    @_pollInterval = Meteor.setInterval (=> @refreshDefaults @dateOfIssue()), 60000

  onDestroyed: ->
    super arguments...
    Meteor.clearInterval @_pollInterval
    @_requestNumber++

  refreshDefaults: (date) ->
    requestNumber = ++@_requestNumber
    @defaults null
    return unless date
    @constructor.invoiceDefaults date, (error, defaults) =>
      # Ignore responses for dates that have since changed or components that have been destroyed.
      return unless requestNumber is @_requestNumber
      @error error?.reason or error?.message or null
      @defaults defaults unless error

  itemCatalogKeys: ->
    _.map RS.Item.documents.fetch({}, sort: catalogKey: 1), 'catalogKey'

  amountEur: ->
    return "—" unless @defaults() and @totalUsd() > 0
    amounts = RS.Vat.calculateVat
      desiredTotalAmountUsd: @totalUsd()
      usdToEurExchangeRate: @defaults().usdToEurExchangeRate
      vatRate: @vatRate()
    "#{(amounts.netAmountEur + amounts.vatAmountEur).toFixed(2)} (net #{amounts.netAmountEur.toFixed(2)}, VAT #{amounts.vatAmountEur.toFixed(2)})"

  issueDisabled: ->
    @issuing() or not @defaults() or not (@totalUsd() > 0)

  events: ->
    super(arguments...).concat
      'change .invoice-date': (event) => @dateOfIssue event.target.value
      'input .invoice-price': @updateTotal
      'change .invoice-vat-rate': (event) => @vatRate Number event.target.value
      'click .add-invoice-line': => @lines @lines().concat [{_id: Random.id()}]
      'click .remove-invoice-line': @removeLine
      'click .issue-invoice-button': @issueInvoice
      'submit .issue-invoice-form': @issueInvoice

  updateTotal: ->
    total = 0
    @$('.invoice-price').each (index, input) -> total += Number(input.value) or 0
    @totalUsd total

  removeLine: ->
    line = @currentData()
    @lines _.reject @lines(), (entry) -> entry._id is line._id
    Tracker.afterFlush => @updateTotal()

  issueInvoice: (event) ->
    event.preventDefault()
    event.stopPropagation()
    return if @issuing()

    # Chrome autofill can change values without the same input events as typing. Read the actual
    # form values before validating, and issue via a normal button so its click cannot navigate.
    @updateTotal()
    return unless @$('.issue-invoice-form')[0].reportValidity()
    return if @issueDisabled()
    @error null
    customer = country: @$('.invoice-customer-country').val()
    customer[field] = @$(".invoice-customer-#{field}").val().trim() for field in ['name', 'address', 'vatId', 'email']
    items = []
    @$('.invoice-line').each (index, element) ->
      $line = $(element)
      catalogKey = $line.find('.invoice-catalog-key').val()
      create = catalogKey is '__new__'
      items.push
        catalogKey: if create then $line.find('.invoice-new-catalog-key').val() else catalogKey
        description: $line.find('.invoice-description').val()
        price: Number $line.find('.invoice-price').val()
        create: create

    @issuing true
    @constructor.issueInvoice {customer, items, dateOfIssue: @dateOfIssue(), vatRate: @vatRate()}, (error, result) =>
      @issuing false
      if error
        @error error.reason or error.message
      else
        # Persist immediately: a component autorun may already have stopped if the page was recreated
        # while the server was processing the invoice.
        @_saveIssuedInvoice result
        @issuedInvoice result
        @lines [{_id: Random.id()}]
        @totalUsd 0
        @refreshDefaults @dateOfIssue()

  _loadIssuedInvoice: ->
    try
      storedInvoice = sessionStorage.getItem @_issuedInvoiceStorageKey
      return null unless storedInvoice
      invoice = EJSON.parse storedInvoice
      return invoice if invoice?.accessSecret and invoice.invoiceId?.year and invoice.invoiceId?.number

    catch error
      console.warn "Could not restore the last issued invoice.", error

    null

  _saveIssuedInvoice: (invoice) ->
    try
      sessionStorage.setItem @_issuedInvoiceStorageKey, EJSON.stringify invoice

    catch error
      # Storage can be unavailable in restricted browsers; still show the successful result in this page.
      console.warn "Could not preserve the last issued invoice across reloads.", error

  class @Country extends AB.Components.RegionSelection
    @register 'Retronator.Store.Pages.Admin.IssueInvoice.Country'

    onCreated: ->
      super arguments...
      @invoiceComponent = @ancestorComponentOfType RS.Pages.Admin.IssueInvoice

    customAttributes: ->
      class: 'invoice-customer-country'
      name: 'customer-country'
      autocomplete: 'section-invoice billing country'
      required: true

    load: -> @invoiceComponent.country()
    save: (value) -> @invoiceComponent.country value
