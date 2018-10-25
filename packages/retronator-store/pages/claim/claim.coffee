AB = Artificial.Base
AM = Artificial.Mirage
RA = Retronator.Accounts
RS = Retronator.Store

class RS.Pages.Claim extends AM.Component
  @register 'Retronator.Store.Pages.Claim'
  
  onCreated: ->
    super arguments...

    @subscribe 'Retronator.Accounts.Transactions.Item.all'

    @enteredKeyCode = new ReactiveField null

    @keyCode = new ComputedField =>
      keyCode = AB.Router.getParameter('keyCode') or @enteredKeyCode()
      
    @receivingTransaction = new ComputedField =>
      keyCode = @keyCode()
      return unless keyCode

      @subscribe 'Retronator.Accounts.Transactions.Transaction.forReceivedGiftKeyCode', keyCode

      RS.Transaction.documents.findOne 'items.receivedGift.keyCode': keyCode

    @giftingTransaction = new ComputedField =>
      keyCode = @keyCode()
      return unless keyCode
      
      @subscribe 'Retronator.Accounts.Transactions.Transaction.forGivenGiftKeyCode', keyCode
      
      RS.Transaction.documents.findOne 'items.givenGift.keyCode': keyCode

    @giftedItem = new ComputedField =>
      keyCode = @keyCode()
      transaction = @giftingTransaction()
      return unless keyCode and transaction?.items?

      for purchasedItem in transaction.items when purchasedItem.givenGift?.keyCode is keyCode
        # HACK: For some reason refresh returns an array with a bunch of undefines, so here we do it as a separate call.
        purchasedItem.item.refresh()
        return purchasedItem.item

    @claimError = new ReactiveField null
    @submittingClaim = new ReactiveField false
    @claimCompleted = new ReactiveField false

  giftedItem: ->
    RS.shoppingCart

  claimButtonAttributes: ->
    disabled: true if @submittingClaim()

  events: ->
    super(arguments...).concat
      'submit .claim-form': @onSubmitClaimForm
      'input .key-code': @onInputKeyCode

  onInputKeyCode: (event) ->
    @enteredKeyCode $(event.target).val()

  onSubmitClaimForm: (event) ->
    event.preventDefault()

    # Clear the error that may have accrued and start submitting the claim.
    @claimError null
    @submittingClaim true

    # Create a payment on the server. If user is logged in, the email can be null.
    email = @$('.claim-email').val() unless Meteor.user()

    console.log "calling insert claim with", @keyCode(), email

    Meteor.call 'Retronator.Accounts.Transactions.Transaction.insertClaimedItem', @keyCode(), email, (error, data) =>
      @submittingClaim false

      console.log "got response", error, data

      if error
        @claimError error.reason
        return

      @claimCompleted true
      @$('.claim-form input').val('')
