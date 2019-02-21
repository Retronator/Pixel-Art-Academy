AM = Artificial.Mirage
LOI = LandsOfIllusions
C3 = SanFrancisco.C3

class C3.Design.Terminal.Properties.RenderingCondition extends AM.Component
  @register 'SanFrancisco.C3.Design.Terminal.Properties.RenderingCondition'

  onCreated: ->
    super arguments...

    @property = @data()

    @combinationTypeInput = new @constructor.CombinationTypeInput @

  parts: ->
    property = @data()

    # Mark indices so we know which condition part is being edited.
    parts = for partType, regex of property.conditionParts()
      {property, partType, regex}

    parts.push {property}
    
    parts
    
  class @CombinationTypeInput extends AM.DataInputComponent
    constructor: (@renderingCondition) ->
      super arguments...
  
      @type = AM.DataInputComponent.Types.Select
  
    options: ->
      for combinationType of LOI.Character.Avatar.Properties.RenderingCondition.CombinationTypes
        name: combinationType
        value: combinationType
  
    load: ->
      @renderingCondition.property.combinationType()
  
    save: (value) ->
      @renderingCondition.property.combinationType value

  class @ConditionPartTypeInput extends AM.DataInputComponent
    @register 'SanFrancisco.C3.Design.Terminal.Properties.RenderingCondition.ConditionPartTypeInput'

    constructor: ->
      super arguments...

      @type = AM.DataInputComponent.Types.Select

    options: ->
      options = [
        name: ''
        value: null
      ]

      for partTypeId in LOI.Character.Part.getPartTypeIdsUnderType 'Avatar.Body'
        options.push
          name: partTypeId
          value: partTypeId

      options

    load: ->
      part = @data()
      part.partType

    save: (value) ->
      part = @data()
      property = part.property

      oldType = @load()

      if part.partType
        if value.length
          # We're modifying a condition part.
          property.updateConditionPartType oldType, value

        else
          # We're removing the condition part.
          property.removeConditionPart oldType

      else
        # We're adding a new condition part.
        property.addConditionPart value

  class @ConditionPartRegexInput extends AM.DataInputComponent
    @register 'SanFrancisco.C3.Design.Terminal.Properties.RenderingCondition.ConditionPartRegexInput'

    load: ->
      part = @data()
      part.regex

    save: (value) ->
      part = @data()
      part.property.updateConditionPartRegex part.partType, value
