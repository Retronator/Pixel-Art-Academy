AE = Artificial.Everywhere
AB = Artificial.Base
AM = Artificial.Mirage
LOI = LandsOfIllusions
LM = PixelArtAcademy.LearnMode

class LM.Menu.Items extends LOI.Components.Menu.Items
  @register 'PixelArtAcademy.LearnMode.Menu.Items'

  template: -> 'PixelArtAcademy.LearnMode.Menu.Items'

  onCreated: ->
    # On desktop we have to ask the window for its full-screen status.
    if Meteor.isDesktop
      @_isFullscreen = new ReactiveField false

      # Listen to fullscreen changes.
      Desktop.on 'window', 'isFullscreen', (event, isFullscreen) =>
        console.log "GOT IT", isFullscreen
        @_isFullscreen isFullscreen
      
      # Request initial value.
      Desktop.send 'window', 'isFullscreen'
    
  isFullscreen: ->
    if Meteor.isDesktop
      @_isFullscreen()
    
    else
      super arguments...

  onClickQuit: (event) ->
    if Meteor.isDesktop
      Desktop.send 'desktop', 'closeApp'
  
  onClickSettings: (event) ->
    @currentScreen @constructor.Screens.Settings
  
    # Store current state of settings.
    @_oldSettings = LOI.settings.toObject()

  onClickFullscreen: (event) ->
    if Meteor.isDesktop
      if @_isFullscreen()
        Desktop.send 'window', 'setFullscreen', false
    
      else
        Desktop.send 'window', 'setFullscreen', true
        
    else
      if AM.Window.isFullscreen()
        AM.Window.exitFullscreen()
    
      else
        AM.Window.enterFullscreen()
      
    # Do a late UI resize to accommodate any fullscreen transitions.
    Meteor.setTimeout =>
      LOI.adventure.interface.resize()
    ,
      1000
