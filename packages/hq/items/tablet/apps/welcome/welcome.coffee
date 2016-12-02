AM = Artificial.Mirage
HQ = Retronator.HQ

class HQ.Items.Tablet.Apps.Welcome extends HQ.Items.Tablet.OS.App
  @register 'Retronator.HQ.Items.Tablet.Apps.Welcome'

  @id: -> 'Retronator.HQ.Items.Tablet.Apps.Welcome'
  @url: -> 'welcome'

  @fullName: -> "Welcome to Retronator HQ"

  @shortName: -> "Welcome"

  @description: ->
    "
      The Welcome app shows a welcome screen when you pick up the tablet.
    "

  @showInMenu: -> false

  @initialize()    
