AB = Artificial.Base
AM = Artificial.Mirage
RA = Retronator.Accounts
RS = Retronator.Store

class RS.Pages.Admin.Payments extends AM.Component
  @id: -> 'Retronator.Store.Pages.Admin.Payments'
  @register @id()

  @paymentsForSearchFields: new AB.Subscription
    name: "#{@id()}.paymentsForSearchFields"
    query: (searchFields) =>
      query = $or: []

      if searchFields.patronEmail
        searchFields.patronEmail = new RegExp searchFields.patronEmail, 'i'

      for property, value of searchFields
        query.$or.push "#{property}": value

      return unless query.$or.length

      paymentsCursor = RS.Payment.documents.find query,
        sort:
          time: -1

      payments = paymentsCursor.fetch()
      paymentIds = (payment._id for payment in payments)

      transactionsCursor = RS.Transaction.documents.find
        'payments._id':
          $in: paymentIds

      [paymentsCursor, transactionsCursor]

  onCreated: ->
    super arguments...

    RS.Item.all.subscribe @

    @patronId = new ReactiveField null
    @patronEmail = new ReactiveField null

    @autorun (computation) =>
      searchFields = @getSearchFields()
      return unless _.keys(searchFields).length

      @constructor.paymentsForSearchFields.subscribe searchFields

  getSearchFields: ->
    searchFields =
      patronId: @patronId()
      patronEmail: @patronEmail()

    nonEmptySearchFields = {}

    for property, value of searchFields when value or value is false
      nonEmptySearchFields[property] = value

    nonEmptySearchFields

  payments: ->
    @constructor.paymentsForSearchFields.query(@getSearchFields())?[0]

  transaction: ->
    payment = @currentData()

    RS.Transaction.documents.findOne
      'payments._id': payment._id

  class @IdentificationInput extends AM.DataInputComponent
    onCreated: ->
      @paymentsComponent = @ancestorComponentOfType RS.Pages.Admin.Payments

    load: ->
      @paymentsComponent[@field()]()

    save: (value) ->
      @paymentsComponent[@field()] value

  class @PatronId extends @IdentificationInput
    @register 'Retronator.Store.Pages.Admin.Payments.PatronId'
    field: -> 'patronId'

  class @PatronEmail extends @IdentificationInput
    @register 'Retronator.Store.Pages.Admin.Payments.PatronEmail'
    field: -> 'patronEmail'
