AB = Artificial.Base
AM = Artificial.Mirage
LOI = LandsOfIllusions
C3 = SanFrancisco.C3

class C3.Design.Terminal.Properties.Sprite.OpenDialog extends AM.Component
  @id: -> 'SanFrancisco.C3.Design.Terminal.Properties.Sprite.OpenDialog'
  @register @id()

  constructor: (@options) ->
    super arguments...

  onCreated: ->
    super arguments...

    @fileManager = new LOI.Assets.Editor.FileManager
      documents: LOI.Assets.Sprite.documents
      multipleSelect: false
      defaultOperation: (selectedItem) => @_open selectedItem

  events: ->
    super(arguments...).concat
      'click .cancel-button': @onClickCancelButton
      'click .deselect-button': @onClickDeselectButton
      'click .open-button': @onClickOpenButton

  onClickCancelButton: (event) ->
    @options.close()

  @onClickDeselectButton: (event) ->
    @options.setSpriteId null
    @options.close()

  onClickOpenButton: (event) ->
    @_open()

  _open: (selectedItem) =>
    selectedItem ?= @fileManager.selectedItems()[0]

    @options.setSpriteId selectedItem._id if selectedItem
    @options.close()
