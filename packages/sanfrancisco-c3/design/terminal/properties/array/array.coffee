AM = Artificial.Mirage
LOI = LandsOfIllusions
C3 = SanFrancisco.C3

class C3.Design.Terminal.Properties.Array extends C3.Design.Terminal.Properties.Property
  @register 'SanFrancisco.C3.Design.Terminal.Properties.Array'

  onCreated: ->
    super arguments...

    @showTypes = new ReactiveField false
    @draggingPart = new ReactiveField null
    @draggingPartIndex = new ReactiveField null
    @draggingVisiblyActive = new ReactiveField false

    # We display only main parts and merge their counterparts into them.
    @displayedParts = new ComputedField =>
      property = @data()
      displayedParts = []
      lastTemplatePart = null
      lastTemplate = null

      # Merge counterparts.
      for part, arrayIndex in property.parts()
        delete part.counterpartTemplateParts

        field = part.options.dataLocation.field()
        template = if field.isTemplate() then field.getTemplate() else null

        # Make sure the template was actually retrieved.
        if template
          [prefix, ..., suffix] = template.name.translations.best.text.split ' '

          if lastTemplate and suffix in ['middle', 'behind']
            if template.name.translations.best.text is "#{lastTemplate.name.translations.best.text} #{suffix}"
              # Merge the counterpart.
              lastTemplatePart.counterpartTemplateParts ?= []
              lastTemplatePart.counterpartTemplateParts.push part
              continue

          lastTemplate = template
          lastTemplatePart = part

        else
          lastTemplate = null
          lastTemplatePart = null

        displayedParts.push part

      displayedParts

    # Actual displayed parts also have the dragging part put into the future order as a preview.
    @parts = new ComputedField =>
      parts = @displayedParts()
      draggingPart = @draggingPart()
      draggingPartIndex = @draggingPartIndex()

      return parts unless draggingPart and draggingPartIndex?

      # Place dragging part to requested index.
      parts = _.without parts, draggingPart
      parts.splice draggingPartIndex, 0, draggingPart

      parts

  avatarPartPreviewOptions: ->
    chooseNonEmptyViewingAngle: true

  draggingClass: ->
    'dragging' if @draggingVisiblyActive()

  draggingPartClass: ->
    part = @currentData()

    'dragging-part' if @draggingPart() is part

  events: ->
    super(arguments...).concat
      'mousedown .parts .part': @onMouseDownPart
      'mouseenter .parts .part': @onMouseEnterPart
      'click .parts .part': @onClickPart
      'click .new-array-part-button': @onClickNewArrayPartButton
      'click .new-array-part-type-button': @onClickNewArrayPartTypeButton

  onMouseDownPart: (event) ->
    part = @currentData()
    startingIndex = @parts().indexOf part

    @draggingPart part
    @draggingPartIndex null

    Meteor.clearTimeout @_draggingActiveTimeout

    @_draggingActiveTimeout = Meteor.setTimeout =>
      @draggingVisiblyActive true
    ,
      200

    # Wire end of dragging on mouse up anywhere in the window.
    $(document).on 'mouseup.sanfrancisco-c3-design-terminal-properties-array', =>
      $(document).off '.sanfrancisco-c3-design-terminal-properties-array'

      draggingPartIndex = @draggingPartIndex()

      if draggingPartIndex? and draggingPartIndex isnt startingIndex
        # Determine actual array index of where the part was dragged to.
        if draggingPartIndex > startingIndex
          # We're moving forward so we need to get at the end of the last part (which might have more counterparts).
          precedingParts = @displayedParts()[..draggingPartIndex]
          arrayIndex = precedingParts.length - 1

        else
          # We're moving backwards so we need to get at the location before the part we're moving to.
          precedingParts = @displayedParts()[...draggingPartIndex]
          arrayIndex = precedingParts.length

        for precedingPart in precedingParts
          arrayIndex += precedingPart.counterpartTemplateParts.length if precedingPart.counterpartTemplateParts

        property = @data()
        property.reorderPart part, arrayIndex

        if part.counterpartTemplateParts
          # Place all counterparts after the part.
          for counterpart, offset in part.counterpartTemplateParts
            # We need to flush computations so the parts get updated correctly before sending another reorder request.
            Tracker.flush()

            # Place the counterpart in order after the main part.
            if draggingPartIndex > startingIndex
              # We're moving forward so the main index will keep moving backwards as we
              # displace parts forward and we just need to keep inserting in the same space.
              property.reorderPart counterpart, arrayIndex

            else
              # We're moving backwards so we need to keep increasing the position where we're inserting the counterparts.
              property.reorderPart counterpart, arrayIndex + offset + 1

      @draggingPart null
      @draggingPartIndex null

      Meteor.clearTimeout @_draggingActiveTimeout

      @_draggingActiveTimeout = Meteor.setTimeout =>
        @draggingVisiblyActive false

  onMouseEnterPart: (event) ->
    enteredPart = @currentData()
    return unless @draggingPart()

    parts = @parts()
    enteredPartIndex = parts.indexOf enteredPart

    @draggingPartIndex enteredPartIndex

  onClickPart: (event) ->
    part = @currentData()

    return if @draggingVisiblyActive()

    terminal = @ancestorComponentOfType C3.Design.Terminal
    terminal.screens.avatarPart.pushPart part

  onClickNewArrayPartButton: (event) ->
    property = @data()

    if property.options.type
      @_goToNewPart property.options.type
      
    else
      @showTypes not @showTypes()

  onClickNewArrayPartTypeButton: (event) ->
    type = @currentData()
    @_goToNewPart type
    
  _goToNewPart: (type) ->
    property = @data()
    part = property.newPart type

    terminal = @ancestorComponentOfType C3.Design.Terminal
    terminal.screens.avatarPart.pushPart part
