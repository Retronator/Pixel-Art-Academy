AB = Artificial.Base
AM = Artificial.Mirage
RS = Retronator.Store

class RS.Pages.Admin.AuthorizedPayments extends AM.Component
  @id: -> 'Retronator.Store.Pages.Admin.AuthorizedPayments'
  @register @id()

  @sendReminderEmail: new AB.Method name: "#{@id()}.sendReminderEmail"
  @sendAllReminderEmails: new AB.Method name: "#{@id()}.sendAllReminderEmails"

  @chargePayment: new AB.Method name: "#{@id()}.chargePayment"
  @chargeAllPayments: new AB.Method name: "#{@id()}.chargeAllPayments"

  events: ->
    super(arguments...).concat
      'click .email-all': @onClickEmailAll
      'click .charge-all': @onClickChargeAll

  onClickEmailAll: (event) ->
    @constructor.sendAllReminderEmails()

  onClickChargeAll: (event) ->
    @constructor.chargeAllPayments()
