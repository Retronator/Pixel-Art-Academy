AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelPad.Systems.Instructions extends PAA.PixelPad.System
  @DisplayState =
    Open: 'Open'
    Closed: 'Closed'
    Hidden: 'Hidden'
    
  @DisplaySide =
    Top: 'Top'
    Bottom: 'Bottom'
  
  constructor: ->
    super arguments...
    
    @headerHeight = 0
    @hideTop = 0
    @animationDuration = 0
  
  onCreated: ->
    super arguments...
  
    @app = @ancestorComponentOfType Artificial.Base.App
    @app.addComponent @
    
    @mouseHovering = new ReactiveField false
    
    @contentWidth = new ReactiveField 0
    @previousContentWidth = new ReactiveField 0
    
    @contentHeight = new ReactiveField 0
    @previousContentHeight = new ReactiveField 0
  
    @defaultDisplayState = new ReactiveField null
    @manualDisplayState = new ReactiveField null

    @displayState = new ComputedField =>
      @manualDisplayState() or @defaultDisplayState()
      
    @instructions = for instructionClass in PAA.PixelPad.Systems.Instructions.Instruction.getClasses()
      new instructionClass @
  
    @activeInstructions = new ComputedField =>
      activeInstructions = _.filter @instructions, (instruction) -> instruction.activeConditions() and not instruction.completed()
      
      # Sort by priority
      _.sortBy activeInstructions, (instruction) -> -instruction.priority()
      
    @targetDisplayedInstruction = new ComputedField =>
      # Show the first active instruction that isn't delayed.
      for instruction in @activeInstructions()
        continue if instruction.delayed()

        return instruction
        
      null

    @targetDisplaySide = new ComputedField =>
      @targetDisplayedInstruction()?.displaySide()
      
    @displaySide = new ReactiveField @constructor.DisplaySide.Bottom
    
    @displayedInstruction = new ReactiveField null

    @interfaceMarkings = new ComputedField =>
      return unless markup = @targetDisplayedInstruction()?.markup?()
      marking.interface for marking in markup when marking.interface
  
  onRendered: ->
    super arguments...
    
    @content$ = @$('.content')
    @_resizeObserver = new ResizeObserver =>
      @previousContentWidth @contentWidth()
      @contentWidth @content$.outerWidth()

      @previousContentHeight @contentHeight()
      @contentHeight @content$.outerHeight()
    
    @_resizeObserver.observe @content$[0]
  
    @animating = new ReactiveField false
  
    @autorun (computation) =>
      return if @animating()
      
      if targetDisplayedInstruction = @targetDisplayedInstruction()
        targetDisplaySide = @targetDisplaySide()
        displaySide = @displaySide()
        
        # If we're changing sides, hide the current instruction.
        unless displaySide is targetDisplaySide
          await @animateHide()

          # Wait for a frame for the new side style to apply to allow for animations starting with new positioning.
          @animating true
          @displaySide targetDisplaySide
          @displayedInstruction null
          await _.waitForFlush()
          await _.waitForNextAnimationFrame()
          @animating false
          
          return
        
        # Nothing to do if we're displaying the correct instruction.
        displayedInstruction = @displayedInstruction()
        return if displayedInstruction is targetDisplayedInstruction
        
        # If another instruction is open we have to first close it.
        if @displayState() is @constructor.DisplayState.Open
          await @animateClose()
          
          @displayedInstruction null
          
        else
          # Show the new instruction.
          @displayedInstruction targetDisplayedInstruction
          
          targetDisplayedInstruction.onDisplay()

          await @animateDisplayState targetDisplayedInstruction.activeDisplayState()
    
          targetDisplayedInstruction.onDisplayed()
      
      else
        # We shouldn't be showing any instructions.
        await @animateHide() unless @displayState() is @constructor.DisplayState.Hidden
        
        @displayedInstruction null
        
  onDestroyed: ->
    super arguments...
    
    instruction.destroy() for instruction in @instructions
  
    @app.removeComponent @
    
  getInstruction: (classOrId) ->
    id = classOrId?.id() or classOrId
    
    _.find @instructions, (instruction) -> instruction.id() is id
    
  animateOpen: -> @animateDisplayState @constructor.DisplayState.Open
  animateClose: -> @animateDisplayState @constructor.DisplayState.Closed
  animateHide: -> @animateDisplayState @constructor.DisplayState.Hidden
  
  animateDisplayState: (state) ->
    @animating true
  
    @manualDisplayState null
    @defaultDisplayState state
  
    await _.waitForSeconds @animationDuration
    @animating false
    
  update: (appTime) ->
    # Reduce delay time on all instructions above the displayed one.
    targetDisplayedInstruction = @targetDisplayedInstruction()

    for instruction in @activeInstructions()
      return if instruction is targetDisplayedInstruction
      
      instruction.reduceDelayTime appTime.elapsedAppTime
    
  displayStateClass: ->
    _.kebabCase @displayState()
    
  displaySideClass: ->
    _.kebabCase @displaySide()
    
  containerStyle: ->
    maxContentHeight = Math.max @contentHeight(), @previousContentHeight()

    height: "#{maxContentHeight}px"
  
  events: ->
    super(arguments...).concat
      'click': @onClick
      'mouseenter .pixelartacademy-pixelpad-systems-instructions': @onMouseEnterInstructions
      'mouseleave .pixelartacademy-pixelpad-systems-instructions': @onMouseLeaveInstructions
      'click .header': @onClickHeader
    
  onClick: (event) ->
    Meteor.clearTimeout @_animateCloseTimeout
    
  onMouseEnterInstructions: (event) ->
    @mouseHovering true

  onMouseLeaveInstructions: (event) ->
    @mouseHovering false

  onClickHeader: (event) ->
    defaultDisplayState = @defaultDisplayState()
    
    targetDisplayState = if @displayState() is @constructor.DisplayState.Open then @constructor.DisplayState.Closed else @constructor.DisplayState.Open
    @manualDisplayState if targetDisplayState is defaultDisplayState then null else targetDisplayState
