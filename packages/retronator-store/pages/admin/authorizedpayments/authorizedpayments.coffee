AB = Artificial.Base
AM = Artificial.Mirage
RS = Retronator.Store

class RS.Pages.Admin.AuthorizedPayments extends AM.Component
  @id: -> 'Retronator.Store.Pages.Admin.AuthorizedPayments'
  @register @id()

  @sendReminderEmail: new AB.Method name: "#{@id()}.sendReminderEmail"
  @sendAllReminderEmails: new AB.Method name: "#{@id()}.sendAllReminderEmails"
 
  events: ->
    super.concat
      'click .email-all': @onClickEmailAll

  onClickEmailAll: (event) ->
    @constructor.sendAllReminderEmails()
