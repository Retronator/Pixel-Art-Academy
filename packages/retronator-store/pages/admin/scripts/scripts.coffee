AM = Artificial.Mirage
RS = Retronator.Store

class RS.Pages.Admin.Scripts extends AM.Component
  @register 'Retronator.Store.Pages.Admin.Scripts'

  events: ->
    super.concat
      'click .convert-imported-users': => Meteor.call 'Retronator.Store.Pages.Admin.Scripts.ConvertImportedUsers'
      'click .convert-preorders': => Meteor.call 'Retronator.Store.Pages.Admin.Scripts.ConvertPreOrders'
      'click .user-ontransactionsupdated': => Meteor.call 'Retronator.Store.Pages.Admin.Scripts.UserOnTransactionsUpdated'
