AB = Artificial.Base
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Pico8.Cartridges.Invasion.DesignDocument extends AM.Component
  @id: -> 'PixelArtAcademy.Pico8.Cartridges.Invasion.DesignDocument'
  
  @designStringForProjectId: (projectId) ->
    project = PAA.Practice.Project.documents.findOne projectId
    
    design = _.defaultsDeep {}, project.design, @DesignDefaults
    
    @_designStringsForObject(design, '').join '\n'
    
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
      
    else
      if options = _.nestedProperty @DesignSchema, path
        index = _.values(options).indexOf object
        object = index + 1 if index > -1
      
      object
      
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

      # Depend on design changes.
      @design()
      
      Tracker.afterFlush =>
        elements = @$('article').toArray()
        textElements = []
        
        while elements.length
          parent = elements.shift()
          
          # Skip auto-resize measuring divs.
          continue if parent.style?.visibility is 'hidden'

          if parent.dataset?.unit
            parent._unit ?= parent.dataset.unit
          
          expandedChildren = []
        
          for child in parent.childNodes
            child._unit ?= parent._unit
    
            if child.nodeType is Node.TEXT_NODE
              text = child.textContent.replace /\s+/g, ' '
              
              # If this is a new node, make sure it's not empty.
              # Old nodes can be empty since they were cleared to be written out.
              existingNode = _.find @_textElements, (textElement) => textElement.node is child
              continue unless text.length and text isnt ' ' or existingNode
              
              textElements.push
                text: text
                element: parent
                textNode: child
                node: child
              
            else if child.classList.contains 'choice'
              textElements.push
                choice: true
                element: child
                editingField: child.dataset.editingField
                node: child
            
            else if child.classList.contains 'chosen-choice'
              text = child.textContent
              textElements.push
                text: text
                element: parent
                textNode: child.firstChild
                node: child
                
            else if child.tagName is 'INPUT'
              text = child.value
              textElements.push
                text: text
                element: parent
                input: child
                node: child
            
            else
              expandedChildren.push child
              
          elements.unshift expandedChildren...
          
        @writeTextElements textElements, writtenUnits
        
  writeTextElements: (textElements, writtenUnits) ->
    return unless textElements.length
    
    @_textElements ?= []
    @_cursor ?= $('<span class="cursor"></span>')[0]

    # Add new text elements.
    @_newCurrentTextElementIndex = null
    currentInsertionIndex = 0
    
    for textElement, index in textElements
      # See if this text element has already been added.
      found = false
      for searchIndex in [currentInsertionIndex...@_textElements.length]
        unless nodeIsSame = textElement.node is @_textElements[searchIndex].node
          textIsSame = textElement.text is @_textElements[searchIndex].text
          siblingIsSame = textElements[index - 1]?.node is @_textElements[searchIndex - 1]?.node or textElements[index + 1]?.node is @_textElements[searchIndex + 1]?.node
        
        continue unless nodeIsSame or textIsSame and siblingIsSame

        found = true
        currentInsertionIndex = searchIndex + 1
        break
          
      continue if found
      
      # This is a new text element.
      @_textElements.splice currentInsertionIndex, 0, textElement
      
      # If this unit wasn't written previously, blank it out and set for writing.
      if textElement.node._unit in writtenUnits
        textElement.written = true
        
      else
        @_newCurrentTextElementIndex ?= currentInsertionIndex

        if textElement.textNode
          textElement.textNode.textContent = ' '
          
        else if textElement.choice
          textElement.element.classList.add 'hidden'
          
        else if textElement.input
          textElement.input.value = ''
          textElement.input.classList.add 'hidden'
      
      currentInsertionIndex++
      
    # Nothing to do if no new elements were inserted.
    return unless @_newCurrentTextElementIndex?
    
    # Start writing unless we're already doing it.
    return if @_writing
    @_writing = true
    
    # Place cursor at the start and wait a bit before writing.
    @_currentTextElementIndex = @_newCurrentTextElementIndex
    initialTextElement = @_textElements[@_currentTextElementIndex]
    
    initialTextElement.element.prepend @_cursor
    await _.waitForNextFrame()
    await @window.scrollToElement initialTextElement.element
    await _.waitForSeconds 0.5

    @skipAnimation false
    
    # Iterate over all text elements.
    while @_currentTextElementIndex < @_textElements.length
      previousTextElement = @_textElements[@_currentTextElementIndex - 1]
      textElement = @_textElements[@_currentTextElementIndex]
      nextTextElement = @_textElements[@_currentTextElementIndex + 1]

      if textElement.written
        @_currentTextElementIndex++
        continue

      if textElement.choice
        textElement.element.classList.remove 'hidden'
        @_cursor.remove()
        await @window.scrollToElement textElement.element, animate: not @skipAnimation(), skipAnimation: @skipAnimation
        @skipAnimation false
    
        await _.waitForNextFrame() while textElement.element.parentElement
        
      else
        # Wait before starting to type in a new element.
        if previousTextElement?.element isnt textElement.element
          await _.waitForSeconds 0.5 unless @skipAnimation()

        text = textElement.text[0]

        if textElement.input
          input = textElement.input
          $input = $(input)
          inputType = input.type
          input.type = 'text'
          input.classList.remove 'hidden'
          input.after @_cursor

          input.value = text
          # Trigger auto-resizing of the input.
          $input.trigger 'input'
          
        else
          textNode = textElement.textNode
          textNode.textContent = text
          textNode.after @_cursor
        
        for character in textElement.text[1..]
          text += character
          
          if textElement.input
            input.value = text
            $input.trigger 'input'
            
          else
            textNode.textContent = text

          unless @skipAnimation()
            await @window.scrollToElement @_cursor, animate: not @skipAnimation(), skipAnimation: @skipAnimation
            waitDuration = if _.endsWith text, '. ' then 0.5 else 0.03
            await _.waitForSeconds waitDuration
      
        if textElement.input
          input.type = inputType
          
      # See if this was the last element of this unit.
      currentUnit = textElement.element._unit
      if currentUnit and nextTextElement?.element._unit isnt currentUnit
        # Mark that we've written it.
        PAA.Practice.Project.documents.update @projectId(),
          $set:
            lastEditTime: Date.now()
          $addToSet:
            'designDocument.writtenUnits': currentUnit
      
      textElement.written = true
      
      if @_newCurrentTextElementIndex
        @_currentTextElementIndex = @_newCurrentTextElementIndex
        @_newCurrentTextElementIndex = null
        
      else
        @_currentTextElementIndex++
        
    @_writing = false
    
    await _.waitForSeconds 1 unless @skipAnimation()

    @_cursor.remove() unless @_writing
  
  getDesignValue: (property) ->
    _.nestedProperty @design(), property
    
  setDesignValue: (property, value) ->
    PAA.Practice.Project.documents.update @projectId(),
      $set:
        lastEditTime: Date.now()
        "design.#{property}": value
  
  events: ->
    super(arguments...).concat
      'click': @onClick
      
  onClick: (event) ->
    $target = $(event.target)
    return if $target.closest('.choice').length
    return if $target.closest('.chosen-choice').length
    return if $target.closest('.entities').length
    return if $target.closest('.entities-add').length

    @skipAnimation true
  
  class @Property extends AM.DataInputComponent
    constructor: ->
      super arguments...
      
      @type = AM.DataInputComponent.Types.Number
      @autoResizeInput = true
      @realtime = false
      @customAttributes =
        step: 'any'
    
    onCreated: ->
      super arguments...

      @designDocument = @parentComponent()
      @display = @callAncestorWith 'display'
      
    onRendered: ->
      super arguments...
      
      @$input = @$('input')
      
      @autorun (computation) =>
        scale = @display.scale()
        @autoResizeInputPadding = 5 * scale
        @$input.trigger 'input'
      
    property: -> throw new AE.NotImplementedException 'Property must define its design property field.'
    
    load: ->
      property = @property()
      value = @designDocument.getDesignValue property
      # Note: We can't use @ to reference the DesignDocument class since DesignDefaults get added in the child.
      value ?= _.nestedProperty PAA.Pico8.Cartridges.Invasion.DesignDocument.DesignDefaults, property
      
      if @isRendered()
        Tracker.afterFlush => @$input.trigger 'input'
      
      value
    
    save: (value) ->
      property = @property()
      float = parseFloat value
      @designDocument.setDesignValue property, if _.isFinite float then float else undefined
