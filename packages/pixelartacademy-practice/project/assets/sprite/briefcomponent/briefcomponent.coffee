AM = Artificial.Mirage
PAA = PixelArtAcademy
LOI = LandsOfIllusions

class PAA.Practice.Project.Asset.Sprite.BriefComponent extends AM.Component
  @register 'PixelArtAcademy.Practice.Project.Asset.Sprite.BriefComponent'

  constructor: (@sprite) ->
    super
    
  onCreated: ->
    super
    
    @parent = @ancestorComponentWith 'editAsset'

  events: ->
    super.concat
      'click .edit-button': @onClickEditButton

  onClickEditButton: (event) ->
    @parent.editAsset()
