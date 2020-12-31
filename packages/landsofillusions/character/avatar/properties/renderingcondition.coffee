LOI = LandsOfIllusions

class LOI.Character.Avatar.Properties.RenderingCondition extends LOI.Character.Part.Property
  # node
  #   fields
  #     combinationType
  #       value: enumeration denoting whether all or at least one part needs to pass the match test
  #     parts:
  #       node:
  #         fields:
  #           {type}: part type ID for which we're testing the presence of a template
  #             value: the regex that has to match the en-US entry of the template name
  @CombinationTypes:
    And: 'And'
    Or: 'Or'

  constructor: (@options = {}) ->
    super arguments...

    @type = 'renderingCondition'

    return unless @options.dataLocation

  combinationType: (value) ->
    conditionNode = @options.dataLocation()

    if value
      if conditionNode
        conditionNode 'combinationType', value

      else
        @options.dataLocation
          combinationType: value

    else
      conditionNode?('combinationType') or @constructor.CombinationTypes.And

  conditionParts: ->
    conditionNode = @options.dataLocation()
    partsNode = conditionNode? 'parts'
    fields = partsNode?.data()?.fields or {}

    parts = {}

    for fieldName, fieldValue of fields
      # Convert key underscores back to dots
      partType = fieldName?.replace /_/g, '.'
      parts[partType] = fieldValue.value

    parts

  addConditionPart: (partType) ->
    @_updateConditionPart null, partType, ''

  updateConditionPartType: (oldPartType, newPartType) ->
    @_updateConditionPart oldPartType, newPartType

  updateConditionPartRegex: (partType, regex) ->
    @_updateConditionPart null, partType, regex

  removeConditionPart: (partType) ->
    @_updateConditionPart partType

  _updateConditionPart: (oldPartType, newPartType, regex) ->
    # Convert key dots to underscores since we can't have them in the hierarchy keys.
    oldPartType = oldPartType?.replace /\./g, '_'
    newPartType = newPartType?.replace /\./g, '_'

    conditionNode = @options.dataLocation()
    partsNode = conditionNode? 'parts'

    if partsNode
      partsNode newPartType, regex ? partsNode oldPartType if newPartType
      partsNode oldPartType, null if oldPartType

    else if newPartType
      if conditionNode
        conditionNode newPartType, regex

      else
        @options.dataLocation
          parts:
            "#{newPartType}": regex
