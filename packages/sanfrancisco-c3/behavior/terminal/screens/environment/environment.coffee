AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions
C3 = SanFrancisco.C3

class C3.Behavior.Terminal.Environment extends AM.Component
  @register 'SanFrancisco.C3.Behavior.Terminal.Environment'

  constructor: (@terminal) ->

  onCreated: ->
    super

    @part = new ReactiveField null
    @behaviorPart = new ReactiveField null

    # Get the environment from the character.
    @autorun (computation) =>
      behaviorPart = @terminal.screens.character.character()?.behavior.part
      @behaviorPart behaviorPart

      environmentPart = behaviorPart.properties.environment.part
      @part environmentPart

  backButtonCallback: ->
    @closeScreen()

    # Instruct the back button to cancel closing (so it doesn't disappear).
    cancel: true

  closeScreen: ->
    @terminal.switchToScreen @terminal.screens.character

  events: ->
    super.concat
      'click .done-button': @onClickDoneButton
      'click .modify-people-button': @onClickModifyPeopleButton

  onClickDoneButton: (event) ->
    @closeScreen()

  onClickModifyPeopleButton: (event) ->
    @terminal.switchToScreen @terminal.screens.people
    
  # Components
  class @Clutter extends AM.DataInputComponent
    constructor: ->
      super

      @type = AM.DataInputComponent.Types.Select

      # Override with property name.
      @property = null

    options: ->
      options = [
        value: 1
        name: "Minimal"
      ,
        value: 2
        name: "Tidy"
      ,
        value: 3
        name: "Average"
      ,
        value: 4
        name: "Messy"
      ,
        value: 5
        name: "Chaos"
      ]

      unless @load()
        options.unshift
          value: null
          name: ''

      options

    load: ->
      dataLocation = @_dataLocation()
      dataLocation()

    save: (value) ->
      dataLocation = @_dataLocation()
      dataLocation parseInt value

    _dataLocation: ->
      environmentComponent = @ancestorComponentOfType C3.Behavior.Terminal.Environment
      environmentComponent.part().properties.clutter.part.properties[@property].options.dataLocation

  class @AverageClutter extends @Clutter
    @register 'SanFrancisco.C3.Behavior.Terminal.Environment.AverageClutter'

    constructor: ->
      super

      @property = 'average'

  class @IdealClutter extends @Clutter
    @register 'SanFrancisco.C3.Behavior.Terminal.Environment.IdealClutter'

    constructor: ->
      super

      @property = 'ideal'
