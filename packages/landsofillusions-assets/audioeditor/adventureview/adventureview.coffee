AC = Artificial.Control
AE = Artificial.Everywhere
AM = Artificial.Mirage
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.AudioEditor.AdventureView extends FM.View
  # locationId: the location being shown in the view
  @id: -> 'LandsOfIllusions.Assets.AudioEditor.AdventureView'
  @register @id()
  
  @componentDataFields: -> [
    'locationId'
  ]
  
  onCreated: ->
    super arguments...

    @adventure = new @constructor.Adventure @
    LOI.adventure = @adventure

  onRendered: ->
    super arguments...

    $adventureView = $('.landsofillusions-assets-audioeditor-adventureview')

    # Set illustration size to view size.
    @autorun (computation) =>
      # Depend on editor view size.
      AM.Window.clientBounds()

      # Depend on application area changes.
      @interface.currentApplicationAreaData().value()

      # After update, measure the size.
      Tracker.afterFlush =>
        @adventure.interface.illustrationSize.width $adventureView.width()
        @adventure.interface.illustrationSize.height $adventureView.height()
