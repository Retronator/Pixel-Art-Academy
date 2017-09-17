AM = Artificial.Mirage
LOI = LandsOfIllusions
C3 = SanFrancisco.C3

class C3.Design.Terminal.Properties.Array extends AM.Component
  @register 'SanFrancisco.C3.Design.Terminal.Properties.Array'

  onCreated: ->
    super

    @showTypes = new ReactiveField false

  parts: ->
    property = @data()
    
    property.parts()

  events: ->
    super.concat
      'click .parts .part': @onClickPart
      'click .new-array-part-button': @onClickNewArrayPartButton
      'click .new-array-part-type-button': @onClickNewArrayPartTypeButton

  onClickPart: (event) ->
    part = @currentData()

    terminal = @ancestorComponentOfType C3.Design.Terminal
    terminal.screens.avatarPart.pushPart part

  onClickNewArrayPartButton: (event) ->
    property = @data()

    if property.options.type
      @_goToNewPart property.options.type
      
    else
      @showTypes not @showTypes()

  onClickNewArrayPartTypeButton: (event) ->
    type = @currentData()
    @_goToNewPart type
    
  _goToNewPart: (type) ->
    property = @data()
    part = property.newPart type

    terminal = @ancestorComponentOfType C3.Design.Terminal
    terminal.screens.avatarPart.pushPart part
