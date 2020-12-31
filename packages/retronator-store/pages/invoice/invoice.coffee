AB = Artificial.Base
AM = Artificial.Mirage
RA = Retronator.Accounts
RS = Retronator.Store

class RS.Pages.Invoice extends AM.Component
  @id: -> 'Retronator.Store.Pages.Invoice'
  @register @id()

  onCreated: ->
    super arguments...

    RS.Item.all.subscribe @

    @accessSecret = new ComputedField =>
      AB.Router.getParameter 'accessSecret'
      
    @subscribed = new ReactiveField false

    @autorun (computation) =>
      accessSecret = @accessSecret()

      @subscribed false

      RS.Transaction.forAccessSecret.subscribe @, accessSecret,
        onReady: =>
          @subscribed true
          
        onStop: =>
          @subscribed true

  transaction: ->
    RS.Transaction.documents.findOne accessSecret: @accessSecret()
