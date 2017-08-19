AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions
C3 = SanFrancisco.C3

class C3.Behavior.Terminal.Perks extends AM.Component
  @register 'SanFrancisco.C3.Behavior.Terminal.Perks'

  constructor: (@terminal) ->
    super
    
  onCreated: ->
    super
    
    @_translationSubscription = AB.subscribeNamespace 'LandsOfIllusions.Character.Behavior.Perk'

    @allPerkKeys = _.values LOI.Character.Behavior.Perk.Keys

    @displayedPerk = new ReactiveField null

  availablePerks: ->
    @allPerkKeys

  name: -> @_translate 'name'
  description: -> @_translate 'description'
  requirements: -> @_translate 'requirements'
  effects: -> @_translate 'effects'

  _translate: (translationKey) ->
    perkKey = @currentData()

    namespace = "LandsOfIllusions.Character.Behavior.Perk.#{perkKey}"
    translation = AB.Translation.documents.findOne {namespace, key: translationKey}

    AB.translate(translation).text
    
  events: ->
    super.concat
      'click .done-button': @onClickDoneButton
      'mouseenter .perk': @onMouseEnterPerk
      'mouseleave .perk': @onMouseLeavePerk

  onClickDoneButton: (event) ->
    @terminal.switchToScreen @terminal.screens.character

  onMouseEnterPerk: (event) ->
    perk = @currentData()
    @displayedPerk perk

  onMouseLeavePerk: (event) ->
    @displayedPerk null
