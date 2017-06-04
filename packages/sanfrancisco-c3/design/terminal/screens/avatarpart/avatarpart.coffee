AM = Artificial.Mirage
LOI = LandsOfIllusions
C3 = SanFrancisco.C3

class C3.Design.Terminal.AvatarPart extends AM.Component
  @register 'SanFrancisco.C3.Design.Terminal.AvatarPart'

  constructor: (@terminal) ->
    super

    @part = new ReactiveField null

  setPart: (part) ->
    @part part

  partProperties: ->
    _.values @part().options.properties

  events: ->
    super.concat
      'click .done-button': @onClickDoneButton

  onClickDoneButton: (event) ->
    @terminal.switchToScreen @terminal.screens.character
