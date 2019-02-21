AC = Artificial.Control
AE = Artificial.Everywhere
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.AudioEditor.AdventureView extends FM.View
  # 
  # locationId: the location being shown in the view
  @id: -> 'LandsOfIllusions.Assets.AudioEditor.AdventureView'
  @register @id()
  
  onCreated: ->
    super arguments...

    @activeFileData = new ComputedField =>
      @interface.getComponentDataForActiveFile @

    @adventure = new @constructor.Adventure @
