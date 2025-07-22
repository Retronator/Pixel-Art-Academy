AB = Artificial.Base
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Pico8.Cartridges.Invasion.DesignDocument extends AM.Component
  @id: -> 'PixelArtAcademy.Pico8.Cartridges.Invasion.DesignDocument'
  @register @id()
  
  @Options =
    HorizontalAlignments:
      Left: 'Left'
      Center: 'Center'
      Right: 'Right'
    VerticalAlignments:
      Top: 'Top'
      Middle: 'Middle'
      Bottom: 'Bottom'
    Themes:
      ScienceFiction: 'ScienceFiction'
      DeepSea: 'DeepSea'
      CosmicHorror: 'CosmicHorror'
      MicroscopicWorld: 'MicroscopicWorld'
    Entities:
      Defender: 'Defender'
      Invader: 'Invader'
      DefenderProjectile: 'DefenderProjectile'
      InvaderProjectile: 'InvaderProjectile'
      DefenderProjectileExplosion: 'DefenderProjectileExplosion'
      InvaderProjectileExplosion: 'InvaderProjectileExplosion'
    Defender:
      Movement:
        Horizontal: 'Horizontal'
        Vertical: 'Vertical'
        AllDirections: 'AllDirections'
        
  @Texts =
    Themes:
      ScienceFiction: "science fiction"
      DeepSea: "the deep sea"
      CosmicHorror: "cosmic horror"
      MicroscopicWorld: "the microscopic world"
    GameFlow:
      Defender:
        Movement:
          Horizontal: 'left and right'
          Vertical: 'up and down'
          AllDirections: "in all 4 directions"
        StartingAlignment:
          TopLeft: 'top-left corner'
          TopCenter: 'top side'
          TopRight: 'top-right corner'
          MiddleLeft: 'left side'
          MiddleCenter: 'center'
          MiddleRight: 'right side'
          BottomLeft: 'bottom-left corner'
          BottomCenter: 'bottom side'
          BottomRight: 'bottom-right corner'
    Properties:
      Defender:
        Movement:
          Horizontal: 'horizontal'
          Vertical: 'vertical'
          AllDirections: "4-directional"
            
  @DesignSchema =
    theme: @Options.Themes
    entities: [@Options.Entities]
    defender:
      movement: @Options.Defender.Movement
      startingAlignment:
        horizontal: @Options.HorizontalAlignments
        vertical: @Options.VerticalAlignments
        
  @getOptionByNumber: (optionNumber, options) ->
    _.keys(options)[optionNumber - 1]
    
  @getOptionNumber: (optionId, options) ->
    _.values(options).indexOf(optionId) + 1
  
  @designStringForProjectId: (projectId) ->
    project = PAA.Practice.Project.documents.findOne projectId
    @_designStringsForObject(project.design, '').join '\n'
    
  @_designStringsForObject: (object, path) ->
    if _.isArray object
      for item in object
        @_designStringsForObject item, if path then "#{path}.0" else "0"
      
    else if _.isObject object
      valueStrings = for key, value of object
        keyPath = if path then "#{path}.#{key}" else key
        
        if _.isArray(value) or _.isObject(value)
          [
            "#{key}={"
            @_designStringsForObject(value, keyPath)...
            "}"
          ]
        
        else
          # See if we can replace the value with a number.
          if options = _.nestedProperty @DesignSchema, keyPath
            index = _.values(options).indexOf value
            value = index + 1 if index > -1
          
          ["#{key}=#{value}"]
          
      _.flatten valueStrings
      
  onCreated: ->
    super arguments...
    
    @window = @ancestorComponentOfType PAA.Pixeltosh.OS.Interface.Window
    
    @projectId = new ComputedField => PAA.Pico8.Cartridges.Invasion.Project.state 'activeProjectId'
    
    @project = new ComputedField =>
      return unless projectId = @projectId()
      PAA.Practice.Project.documents.findOne projectId
      
    @design = new ComputedField => @project()?.design
    @writtenUnits = new ComputedField => @project()?.designDocument.writtenUnits
      
    @skipAnimation = new ReactiveField false
    
  onRendered: ->
    super arguments...
    
    @autorun (computation) =>
      return unless writtenUnits = @writtenUnits()
      computation.stop()
      
      elements = @$('article').toArray()
      textElements = []
      
      while elements.length
        parent = elements.shift()
        
        if parent.dataset?.unit
          continue if parent.dataset.unit in writtenUnits
          parent._unit ?= parent.dataset.unit
        
        expandedChildren = []
      
        for child in parent.childNodes
          child._unit ?= parent._unit

          if child.nodeType is Node.TEXT_NODE
            text = child.textContent.replace /\s+/g, ' '
            continue unless text.length and text isnt ' '
            
            child.textContent = ' '
            textElements.push
              text: text
              element: parent
              textNode: child
            
          else if child.classList.contains 'choice'
            child.classList.add 'hidden'
            textElements.push
              choice: true
              element: child
              editingField: child.dataset.editingField
          
          else if child.classList.contains 'chosen-choice'
            text = child.textContent
            child.textContent = ' '
            textElements.push
              text: text
              element: parent
              textNode: child.firstChild
              
          else
            expandedChildren.push child
            
        elements.unshift expandedChildren...
        
      @writeTextElements textElements
      
  writeTextElements: (textElements) ->
    return unless textElements.length
    
    cursor = $('<span class="cursor"></span>')[0]
    textElements[0].element.prepend cursor

    await _.waitForSeconds 0.5 unless @skipAnimation()
    cursor.remove()
    
    for textElement, index in textElements
      previousTextElement = textElements[index - 1]
      nextTextElement = textElements[index + 1]

      if textElement.choice
        textElement.element.classList.remove 'hidden'
        cursor.remove()
        @window.scrollToElement textElement.element
        await _.waitForNextFrame() while textElement.element.parentElement
        
      else
        # Wait before starting to type in a new element.
        if previousTextElement?.element isnt textElement.element
          await _.waitForSeconds 0.5 unless @skipAnimation()

        textNode = textElement.textNode
        textNode.textContent = textElement.text[0]
        textNode.after cursor
        
        for character in textElement.text[1..]
          textNode.textContent += character

          unless @skipAnimation()
            @window.scrollToElement cursor
            await _.waitForSeconds 0.03
      
      # See if this was the last element of this unit.
      currentUnit = textElement.element._unit
      if currentUnit and nextTextElement?.element._unit isnt currentUnit
        # Mark that we've written it.
        PAA.Practice.Project.documents.update @projectId(),
          $set:
            lastEditTime: Date.now()
          $addToSet:
            'designDocument.writtenUnits': currentUnit
          
    await _.waitForSeconds 1 unless @skipAnimation()

    cursor.remove()
  
  getDesignValue: (property) ->
    _.nestedProperty @design(), property
    
  setDesignValue: (property, value) ->
    PAA.Practice.Project.documents.update @projectId(),
      $set:
        lastEditTime: Date.now()
        "design.#{property}": value
  
  hasEntity: (entity) ->
    entity in (@getDesignValue('entities') or [])
  
  hasEntities: ->
    @getDesignValue('entities')?.length > 0
  
  themeChoice: ->
    options: ({value, text} for value, text of @constructor.Texts.Themes)
    property: 'theme'
    
  gameFlowDefenderMovementChoice: ->
    options: ({value, text} for value, text of @constructor.Texts.GameFlow.Defender.Movement)
    property: 'defender.movement'
  
  gameFlowDefenderStartingAlignmentPrepositionAt: ->
    # We need 'at' (insted of 'in') when we are at a side and not in the corner/center.
    return unless horizontalAlignment = @getDesignValue 'defender.startingAlignment.horizontal'
    return unless verticalAlignment = @getDesignValue 'defender.startingAlignment.vertical'
    
    center = horizontalAlignment is @constructor.Options.HorizontalAlignments.Center
    middle = verticalAlignment is @constructor.Options.VerticalAlignments.Middle
    
    (center or middle) and not (center and middle)
  
  gameFlowDefenderStartingAlignmentChoice: ->
    options = for value, text of @constructor.Texts.GameFlow.Defender.StartingAlignment
      alignments = value.match /[A-Z][a-z]*/g
      
      value: value
      text: text
      designValues:
        'defender.startingAlignment.horizontal': alignments[1]
        'defender.startingAlignment.vertical': alignments[0]
      
    options: options
    value: =>
      return unless horizontalAlignment = @getDesignValue 'defender.startingAlignment.horizontal'
      return unless verticalAlignment = @getDesignValue 'defender.startingAlignment.vertical'

      "#{verticalAlignment}#{horizontalAlignment}"
  
  propertiesDefenderMovementChoice: ->
    options: ({value, text} for value, text of @constructor.Texts.Properties.Defender.Movement)
    property: 'defender.movement'
    
  events: ->
    super(arguments...).concat
      'click': @onClick
      
  onClick: (event) ->
    return if $(event.target).closest('.choice').length

    @skipAnimation true
