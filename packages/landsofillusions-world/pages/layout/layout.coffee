AM = Artificial.Mirage
AB = Artificial.Base
LOI = LandsOfIllusions

class LOI.World.Pages.Layout extends LOI.Components.EmbeddedWebpage
  @register 'LandsOfIllusions.World.Pages.Layout'

  @title: -> LOI.Adventure.title()
  @description: -> LOI.Adventure.description()

  onCreated: ->
    super arguments...

    @loginButtonsSession = Accounts._loginButtonsSession

  rootClass: -> 'landsofillusions-world'

  inChangePasswordFlow: ->
    console.log "pass", @loginButtonsSession.get 'inChangePasswordFlow'
    @loginButtonsSession.get 'inChangePasswordFlow'

  inMessageOnlyFlow: ->
    console.log "mess", @loginButtonsSession.get 'inMessageOnlyFlow'
    @loginButtonsSession.get 'inMessageOnlyFlow'
