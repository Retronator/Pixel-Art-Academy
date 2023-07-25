AB = Artificial.Base
AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.Menu.Progress extends AM.Component
  @id: -> 'PixelArtAcademy.LearnMode.Menu.Progress'
  @inGameUrl: -> 'progress'
  @inPreviewUrl: -> 'courses'
  
  @version: -> '0.1.0'

  @register @id()

  @CompletionDisplayTypes =
    RequiredUnits: 'RequiredUnits'
    TotalPercentage: 'TotalPercentage'
  
  @stateAddress = new LOI.StateAddress "things.#{@id()}"
  @state = new LOI.StateObject address: @stateAddress
  
  @completionDisplayType: -> @state('completionDisplayType') or @CompletionDisplayTypes.RequiredUnits
  
  template: -> @constructor.id()
  
  mixins: -> [@activatable]
  
  inGame: -> LOI.adventure.profileId()
  inPreview: -> not @inGame()
  
  url: -> if @inGame() then @constructor.inGameUrl() else @constructor.inPreviewUrl()
  
  constructor: ->
    super arguments...
  
    @activatable = new LOI.Components.Mixins.Activatable
  
    for url in [@constructor.inGameUrl(), @constructor.inPreviewUrl()]
      LOI.Adventure.registerDirectRoute "/#{url}", =>
        @show() unless _.find LOI.adventure.modalDialogs(), (modalDialog) => modalDialog.dialog is @
  
  show: ->
    LOI.adventure.showActivatableModalDialog
      dialog: @
      
  onDeactivate: (finishedDeactivatingCallback) ->
    Meteor.setTimeout =>
      finishedDeactivatingCallback()
    ,
      500
  
  courses: ->
    return unless LOI.adventureInitialized()
    _.flatten (chapter.courses for chapter in LOI.adventure.currentChapters())
  
  class @Completionist extends AM.DataInputComponent
    @register 'PixelArtAcademy.LearnMode.Menu.Progress.Completionist'
    
    constructor: ->
      super arguments...

      @type = AM.DataInputComponent.Types.Checkbox

    load: ->
      LM.Menu.Progress.state('completionDisplayType') is LM.Menu.Progress.CompletionDisplayTypes.TotalPercentage

    save: (value) ->
      LM.Menu.Progress.state 'completionDisplayType', if value then LM.Menu.Progress.CompletionDisplayTypes.TotalPercentage else LM.Menu.Progress.CompletionDisplayTypes.RequiredUnits
