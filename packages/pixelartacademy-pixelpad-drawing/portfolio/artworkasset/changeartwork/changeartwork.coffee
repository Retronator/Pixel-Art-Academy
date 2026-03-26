AB = Artificial.Base
AM = Artificial.Mirage
AMu = Artificial.Mummification
PAA = PixelArtAcademy
LOI = LandsOfIllusions

Extras = PAA.PixelPad.Apps.Drawing.Portfolio.Forms.Extras

class PAA.PixelPad.Apps.Drawing.Portfolio.ArtworkAsset.ChangeArtwork extends AM.Component
  @register 'PixelArtAcademy.PixelPad.Apps.Drawing.Portfolio.ArtworkAsset.ChangeArtwork'
  @initializeDataComponent()
  
  constructor: (@artworkAsset) ->
    super arguments...
    
  onCreated: ->
    super arguments...
    
    documentProperties = @artworkAsset.document().properties
    properties = []
    
    if documentProperties.pixelArtEvaluation
      properties.push type: Extras.Extra.Types.PixelArtEvaluation, value: true
    
    if documentProperties.canvasBorder
      properties.push type: Extras.Extra.Types.CanvasBorder, value: true
    
    @extras = new Extras
      allowedTypes: [
        Extras.Extra.Types.CanvasBorder
        Extras.Extra.Types.PixelArtEvaluation
      ]
      initialProperties: properties
    
  events: ->
    super(arguments...).concat
      'submit .change-artwork-form': @onSubmitChangeArtworkForm

  onSubmitChangeArtworkForm: (event) ->
    event.preventDefault()
  
    # Add properties.
    freshProperties =
      pixelArtScaling: true
    
    for property in @extras.properties()
      if property.type is Extras.Extra.Types.PixelArtEvaluation
        # Convert from a boolean to an editable pixel art evaluation.
        freshProperties.pixelArtEvaluation = editable: true
        
      else
        freshProperties[_.camelCase property.type] = property.value
        
    bitmap = @artworkAsset.document()
    
    refreshedProperties = _.clone bitmap.properties
    
    action = null

    # Remove old properties that are not selected anymore.
    for oldProperty of refreshedProperties when not freshProperties[oldProperty]
      updatePropertyAction = new LOI.Assets.VisualAsset.Actions.UpdateProperty bitmap._id, bitmap, oldProperty, null

      if action
        action.append updatePropertyAction
      
      else
        action = updatePropertyAction
    
    # Add new properties that don't exist yet.
    for newProperty, value of freshProperties when not refreshedProperties[newProperty]
      updatePropertyAction = new LOI.Assets.VisualAsset.Actions.UpdateProperty bitmap._id, bitmap, newProperty, value
      
      if action
        action.append updatePropertyAction
      
      else
        action = updatePropertyAction
      
    # Update the document if any changes were made.
    AMu.Document.Versioning.executeAction bitmap, bitmap.lastEditTime, action, new Date if action
    
    # Navigate back to the first page.
    @artworkAsset.clipboardComponent.closeSecondPage()
