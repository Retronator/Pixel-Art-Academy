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

    @selectedPerks = new ReactiveField []
    @availablePerks = new ReactiveField []
    @unavailablePerks = new ReactiveField []

    # Sort out the perks.
    @autorun (computation) =>
      selectedPerks = []
      availablePerks = []
      unavailablePerks = []

      behaviorPart = @behaviorPart()

      for perkKey in @allPerkKeys
        perk = LOI.Character.Behavior.Perk[perkKey]

        if perk.satisfiesRequirements behaviorPart
          availablePerks.push perkKey

        else
          unavailablePerks.push perkKey

      @selectedPerks selectedPerks
      @availablePerks availablePerks
      @unavailablePerks unavailablePerks

    @displayedPerk = new ReactiveField null

  name: -> @_translate 'name'
  description: -> @_translate 'description'
  requirements: -> @_translate 'requirements'
  effects: -> @_translate 'effects'

  _translate: (translationKey) ->
    perkKey = @currentData()

    namespace = "LandsOfIllusions.Character.Behavior.Perk.#{perkKey}"
    translation = AB.Translation.documents.findOne {namespace, key: translationKey}

    AB.translate(translation).text
    
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
    @displayedPerk perk

  onMouseLeavePerk: (event) ->
    @displayedPerk null
