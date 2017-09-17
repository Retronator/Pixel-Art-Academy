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
    @factorPartField = new ReactiveField null
    @personalityPartField = new ReactiveField null
    
    @traitsProperty = new ComputedField =>
      factorPartField = @factorPartField()
      return unless factorPart = factorPartField?()

      factorPart.properties.traits

  onCreated: ->
    super
    
  # Provide personality part to the factor axis.
  personalityPart: ->
    personalityPartField = @personalityPartField()
    personalityPartField?()

  isEditable: ->
    partTemplate = @personalityPart()?.options.dataLocation()?.template

    userId = Meteor.userId()
    isOwnTemplate = partTemplate?.author?._id is userId

    # We can edit the template if it's not using a template, or if the template is our own.
    not partTemplate or isOwnTemplate

  editableClass: ->
    'editable' if @isEditable()

  selectorDisabledAttribute: ->
    disabled: true unless @isEditable()

  setFactor: (factor, partField, personalityPartField) ->
    @factor factor
    @factorPartField partField
    @personalityPartField personalityPartField

  primaryTraits: ->
    LOI.Character.Behavior.Personality.Trait.documents.find
      'primaryFactor.type': @factor().options.type

  secondaryTraits: ->
    LOI.Character.Behavior.Personality.Trait.documents.find
      'secondaryFactor.type': @factor().options.type

  middleSelectorActiveClass: (weight) ->
    'active' if @_selectorActive 0

  _selectorActive: (weight) ->
    traitInfo = @currentData()
    return unless traits = @traitsProperty()?.parts()

    return unless trait = _.find traits, (trait) => trait.properties.key.options.dataLocation() is traitInfo.key

    trait.properties.weight.options.dataLocation() is weight

  leftSelectorActiveStyle: -> @_selectorActiveStyle -1, false
  rightSelectorActiveStyle: -> @_selectorActiveStyle 1, true

  _selectorActiveStyle: (weight, right) ->
    return unless palette = LOI.palette()

    # We should flip the weight if the trait's positive weight isn't on the right side.
    weight *= -1 unless @_rightIsPositive()

    return unless @_selectorActive weight

    trait = @currentData()
    factor = LOI.Character.Behavior.Personality.Factors[trait.primaryFactor.type]

    colorData = @_getFactorSide(factor, right).color
    borderColor = palette.color colorData.hue, colorData.shade
    backgroundColor = palette.color colorData.hue, colorData.shade - 2

    borderColor: "##{borderColor.getHexString()}"
    backgroundColor: "##{backgroundColor.getHexString()}"

  traitNameStyle: ->
    trait = @currentData()

    # See if the trait's positive weight is on the right side.
    right = @_rightIsPositive()

    # Don't let long words to be on the edge.
    iCharCount = trait.key.match(/i/gi)?.length or 0
    offset = Math.max 0, (trait.key.length - iCharCount - 10) * 5

    leftPercentage = if right then 100 - offset else offset

    left: "#{leftPercentage}%"

  _rightIsPositive: ->
    trait = @currentData()

    # The positive weight is on the right by default.
    positive = true

    # If the primary factor is negative, positive weight will be on the left.
    positive = false if trait.primaryFactor.sign < 0

    # We should reverse the side if the factor display is reversed.
    factor = LOI.Character.Behavior.Personality.Factors[trait.primaryFactor.type]
    positive = not positive if factor.options.displayReversed

    positive

  leftPrimaryFactorName: -> @_primaryFactorName false
  rightPrimaryFactorName: -> @_primaryFactorName true

  leftSecondaryFactorName: -> @_secondaryFactorName false
  rightSecondaryFactorName: -> @_secondaryFactorName true

  _primaryFactorName: (right) ->
    trait = @currentData()
    factor = LOI.Character.Behavior.Personality.Factors[trait.primaryFactor.type]

    @_getFactorSide(factor, right).key

  _secondaryFactorName: (right) ->
    trait = @currentData()

    # Don't display if it's the same factor.
    return if trait.primaryFactor.type is trait.secondaryFactor.type

    factor = LOI.Character.Behavior.Personality.Factors[trait.secondaryFactor.type]

    right = @_negateSecondaryRight trait, right

    @_getFactorSide(factor, right).key

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
      'click .left-selector-button': @onClickLeftSelectorButton
      'click .middle-selector-button': @onClickMiddleSelectorButton
      'click .right-selector-button': @onClickRightSelectorButton

  onClickDoneButton: (event) ->
    # We return back to the personality screen.
    @terminal.switchToScreen @terminal.screens.personality

  onClickLeftSelectorButton: (event) ->
    @_applySelectorButton -1

  onClickMiddleSelectorButton: (event) ->
    @_applySelectorButton 0

  onClickRightSelectorButton: (event) ->
    @_applySelectorButton 1
    
  _applySelectorButton: (weight) ->
    traitInfo = @currentData()
    traitsProperty = @traitsProperty()
    traits = traitsProperty?.parts()

    # We should flip the weight if the trait's positive weight isn't on the right side.
    weight *= -1 unless @_rightIsPositive()

    existingTrait = null

    if traits
      # See if we have an existing trait.
      existingTrait = _.find traits, (trait) => trait.properties.key.options.dataLocation() is traitInfo.key

    if existingTrait
      # Modify the weight of existing trait.
      existingTrait.properties.weight.options.dataLocation weight

    else
      # Create a new entry.
      traitType = LOI.Character.Part.Types.Behavior.Personality.Trait.options.type
      traitPart = traitsProperty.newPart traitType
      traitPart.options.dataLocation
        key: traitInfo.key
        weight: weight
