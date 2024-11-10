AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Publication.Pages.Admin.Parts.Part extends AM.Component
  @id: -> 'PixelArtAcademy.Publication.Pages.Admin.Parts.Part'
  @register @id()

  onCreated: ->
    super arguments...

    @autorun (computation) =>
      part = @data()
      PAA.Publication.Part.articleForPart.subscribe @, part._id

  events: ->
    super(arguments...).concat
      'click .remove-part-button': @onClickRemovePartButton

  onClickRemovePartButton: (event) ->
    part = @data()
    return unless confirm "Remove part #{part.goalId}?"

    PAA.Publication.Part.remove part._id

  class @ReferenceId extends AM.DataInputComponent
    @register 'PixelArtAcademy.Publication.Pages.Admin.Parts.Part.ReferenceId'
    
    constructor: ->
      super arguments...
      
      @realtime = false
    
    load: -> @currentData()?.referenceId
    save: (value) ->
      partId = @currentData()._id
      PAA.Publication.Part.update partId, "referenceId": value
