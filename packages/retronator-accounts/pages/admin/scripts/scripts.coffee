AM = Artificial.Mirage
RA = Retronator.Accounts

class RA.Pages.Admin.Scripts extends AM.Component
  @register 'Retronator.Accounts.Pages.Admin.Scripts'

  events: ->
    super.concat
      'click .imported-users-emails-to-lowercase-button': => Meteor.call 'Retronator.Accounts.ImportedUsersEmailsToLowerCase'
      'click .update-documents': => Meteor.call 'Retronator.Accounts.UpdateDocuments'
