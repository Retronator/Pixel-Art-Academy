AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions
C3 = SanFrancisco.C3

class C3.Behavior.Terminal.Perks extends AM.Component
  @register 'SanFrancisco.C3.Behavior.Terminal.Perks'

  constructor: (@terminal) ->
    super

    @property = new ReactiveField null

  onCreated: ->
    super
    
    @_translationSubscription = AB.subscribeNamespace 'LandsOfIllusions.Character.Behavior.Perk'

    @behaviorPart = new ReactiveField null

    # Get the perks from the character.
    @autorun (computation) =>
      behaviorPart = @terminal.screens.character.character()?.behavior.part
      @behaviorPart behaviorPart

      perksProperty = behaviorPart.properties.perks
      @property perksProperty

    @allPerkKeys = _.values LOI.Character.Behavior.Perk.Keys

    @activePerkKeys = new ReactiveField []
    @availablePerkKeys = new ReactiveField []
    @unavailablePerkKeys = new ReactiveField []

    # Sort out the perks.
    @autorun (computation) =>
      perksProperty = @property()
      selectedPerkKeys = (perkPark.properties.key.options.dataLocation() for perkPark in perksProperty.parts())
      
      activePerkKeys = []
      availablePerkKeys = []
      unavailablePerkKeys = []

      behaviorPart = @behaviorPart()

      for perkKey in @allPerkKeys
        perk = LOI.Character.Behavior.Perk[perkKey]

        if perk.satisfiesRequirements behaviorPart
          if perkKey in selectedPerkKeys
            activePerkKeys.push perkKey
            
          else
            availablePerkKeys.push perkKey

        else
          unavailablePerkKeys.push perkKey

      @activePerkKeys activePerkKeys
      @availablePerkKeys availablePerkKeys
      @unavailablePerkKeys unavailablePerkKeys

    @displayedPerkKey = new ReactiveField null

  onDestroyed: ->
    super

    @_translationSubscription.stop()

  name: -> @_translate 'name'
  description: -> @_translate 'description'
  requirements: -> @_translate 'requirements'

  effects: ->
    # Split effects into an array of lines.
    @_translate('effects').split '\n'

  _translate: (translationKey) ->
    perkKey = @currentData()

    namespace = "LandsOfIllusions.Character.Behavior.Perk.#{perkKey}"
    translation = AB.existingTranslation namespace, translationKey

    AB.translate(translation).text

  satisfiedClass: ->
    perkKey = @currentData()
    perk = LOI.Character.Behavior.Perk[perkKey]

    behaviorPart = @behaviorPart()
    'satisfied' if perk.satisfiesRequirements behaviorPart

  backButtonCallback: ->
    @closeScreen()

    # Instruct the back button to cancel closing (so it doesn't disappear).
    cancel: true

  closeScreen: ->
    @terminal.switchToScreen @terminal.screens.character

  events: ->
    super.concat
      'click .done-button': @onClickDoneButton
      'mouseenter .perk': @onMouseEnterPerk
      'mouseleave .perk': @onMouseLeavePerk

  onClickDoneButton: (event) ->
    @closeScreen()

  onMouseEnterPerk: (event) ->
    perk = @currentData()
    @displayedPerkKey perk

  onMouseLeavePerk: (event) ->
    @displayedPerkKey null

  class @Perk extends AM.Component
    @register 'SanFrancisco.C3.Behavior.Terminal.Perks.Perk'

    onCreated: ->
      super

      @perksComponent = @ancestorComponentOfType C3.Behavior.Terminal.Perks

    available: ->
      perkKey = @data()
      perk = LOI.Character.Behavior.Perk[perkKey]

      behaviorPart = @perksComponent.behaviorPart()
      perk.satisfiesRequirements behaviorPart

    name: ->
      @perksComponent.name()

    class @Selected extends AM.DataInputComponent
      @register 'SanFrancisco.C3.Behavior.Terminal.Perks.Perk.Selected'

      constructor: ->
        super

        @type = AM.DataInputComponent.Types.Checkbox

      onCreated: ->
        super

        @perksComponent = @ancestorComponentOfType C3.Behavior.Terminal.Perks

      load: ->
        perksProperty = @perksComponent.property()
        selectedPerkKeys = (perkPark.properties.key.options.dataLocation() for perkPark in perksProperty.parts())

        perkKey = @data()
        perkKey in selectedPerkKeys

      save: (value) ->
        perkKey = @data()
        perksProperty = @perksComponent.property()

        if value
          # Add perk.
          perkType = LOI.Character.Part.Types.Behavior.Perk[perkKey].options.type
          newPart = perksProperty.newPart perkType
          newPart.options.dataLocation
            key: perkKey

        else
          # Remove perk.
          perkPart = _.find perksProperty.parts(), (perkPart) => perkPart.properties.key.options.dataLocation() is perkKey
          perkPart.options.dataLocation.remove()
