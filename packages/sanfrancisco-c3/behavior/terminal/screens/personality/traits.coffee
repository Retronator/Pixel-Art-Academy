AM = Artificial.Mirage
AMu = Artificial.Mummification
LOI = LandsOfIllusions
C3 = SanFrancisco.C3

# Note that we can't create the Personality variable since the class below would overwrite it.
Factors = LOI.Character.Behavior.Personality.Factors

class C3.Behavior.Terminal.Personality.Traits extends AM.Component
  @register 'SanFrancisco.C3.Behavior.Terminal.Personality.Traits'

  constructor: (@terminal) ->
    super

    @factor = new ReactiveField null
    @part = new ReactiveField null

  onCreated: ->
    super

  setFactor: (factor, part) ->
    @factor factor
    @part part

  mainTraits: ->
    LOI.Character.Behavior.Personality.Trait.documents.find
      'primaryFactor.type': @factor().options.typeNumber

  traitNameStyle: ->
    trait = @currentData()

    # The trait name is on the right by default
    right = true

    # If the primary factor is negative we should display on the left.
    right = false if trait.primaryFactor.sign < 0

    # We should reverse the side if the factor display is reversed.
    factor = LOI.Character.Behavior.Personality.Factors[trait.primaryFactor.type]
    right = not right if factor.options.displayReversed

    # Don't let long words to be on the edge.
    iCharCount = trait.name.match(/i/gi)?.length or 0
    offset = Math.max 0, (trait.name.length - iCharCount - 10) * 5

    leftPercentage = if right then 100 - offset else offset

    left: "#{leftPercentage}%"

  leftPrimaryFactorName: -> @_primaryFactorName false
  rightPrimaryFactorName: -> @_primaryFactorName true

  leftSecondaryFactorName: -> @_secondaryFactorName false
  rightSecondaryFactorName: -> @_secondaryFactorName true

  _primaryFactorName: (right) ->
    trait = @currentData()
    factor = LOI.Character.Behavior.Personality.Factors[trait.primaryFactor.type]

    @_getFactorSide(factor, right).name

  _secondaryFactorName: (right) ->
    trait = @currentData()

    # Don't display if it's the same factor.
    return if trait.primaryFactor.type is trait.secondaryFactor.type

    factor = LOI.Character.Behavior.Personality.Factors[trait.secondaryFactor.type]

    right = @_negateSecondaryRight trait, right

    @_getFactorSide(factor, right).name

  _negateSecondaryRight: (trait, right) ->
    # By default right is just right.
    result = right

    # If the primary factor's axis is reversed, we should reverse too.
    primaryFactor = LOI.Character.Behavior.Personality.Factors[trait.primaryFactor.type]
    result = not result if primaryFactor.options.displayReversed

    # If the secondary factor's axis is reversed, we should reverse too.
    secondaryFactor = LOI.Character.Behavior.Personality.Factors[trait.secondaryFactor.type]
    result = not result if secondaryFactor.options.displayReversed

    # If the primary factor's sign is negative, we're defining what should display on the negative side.
    result = not result if trait.primaryFactor.sign < 0

    result = not result if trait.secondaryFactor.sign < 0

    result

  _getFactorSide: (factor, right) ->
    if right is not factor.options.displayReversed then factor.options.positive else factor.options.negative

  leftPrimaryFactorStyle: -> @_primaryFactorStyle false
  rightPrimaryFactorStyle: -> @_primaryFactorStyle true

  leftSecondaryFactorStyle: -> @_secondaryFactorStyle false
  rightSecondaryFactorStyle: -> @_secondaryFactorStyle true

  _primaryFactorStyle: (right) ->
    return unless palette = LOI.palette()

    trait = @currentData()
    factor = LOI.Character.Behavior.Personality.Factors[trait.primaryFactor.type]

    colorData = @_getFactorSide(factor, right).color
    color = palette.color colorData.hue, colorData.shade

    color: "##{color.getHexString()}"

  _secondaryFactorStyle: (right) ->
    return unless palette = LOI.palette()

    trait = @currentData()
    factor = LOI.Character.Behavior.Personality.Factors[trait.secondaryFactor.type]

    right = @_negateSecondaryRight trait, right

    colorData = @_getFactorSide(factor, right).color
    color = palette.color colorData.hue, colorData.shade

    color: "##{color.getHexString()}"

  events: ->
    super.concat
      'click .done-button': @onClickDoneButton

  onClickDoneButton: (event) ->
    # We return back to the personality screen.
    @terminal.switchToScreen @terminal.screens.personality
