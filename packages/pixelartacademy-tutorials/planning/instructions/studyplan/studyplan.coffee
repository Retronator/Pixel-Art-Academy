AB = Artificial.Babel
AM = Artificial.Mirage
AEc = Artificial.Echo
LOI = LandsOfIllusions
PAA = PixelArtAcademy

Instructions = PAA.PixelPad.Systems.Instructions

class PAA.Tutorials.Planning.Instructions.StudyPlan extends PAA.PixelPad.Systems.Instructions
  # instructions: state variables needed for the instructions
  #   chessNotStarted:
  #     hovered2D: boolean whether the player hovered over the 2D entry task
  #     hovered3D: boolean whether the player hovered over the 3D entry task
  @id: -> 'PixelArtAcademy.Tutorials.Planning.Instructions.StudyPlan'

  @version: -> '0.1.0'

  @register @id()
  template: -> @constructor.id()

  @fullName: -> "Study Plan instructions"
  @description: ->
    "
      System for on-demand display of information in the Study Plan app.
    "

  @initialize()
  
  @Audio = new LOI.Assets.Audio.Namespace @id(),
    variables:
      lotusVisible: AEc.ValueTypes.Boolean
      lotusEngine: AEc.ValueTypes.Boolean
      lotusAccelerating: AEc.ValueTypes.Boolean
      lotusSpeed: AEc.ValueTypes.Number
      lotusPan: AEc.ValueTypes.Number
  
  @LotusStates =
    Hidden: 1
    DrivingIn: 2
    Opening: 3
    Open: 4
    ReadyToSpeak: 5
    ReadyToClose: 6
    Closing: 7
    DrivingOut: 8
    
  @drivingTimes =
    In: 1.5
    Out: 2.5
    
  @hiddenTime = 0.1
  @openingTime = 0.5
  @closingTime = 1
  @speakingTime = 0.5
  @leavingTime = 10.1
  
  onCreated: ->
    super arguments...
    
    # Subscribe to tutorial translations since the system doesn't render components (which would do this otherwise).
    AB.subscribeNamespace 'PixelArtAcademy.Tutorials.Planning'
    
    @lotusState = new ReactiveField @constructor.LotusStates.Hidden

    @waitingTime = new ReactiveField 0
    @waiting = new ComputedField => @waitingTime() > 0
    
    @shouldBeHidden = new ComputedField =>
      return true unless displayState = @displayState()
      displayState is Instructions.DisplayStates.Hidden
      
    @audio.lotusVisible false
    @audio.lotusEngine true
    @audio.lotusAccelerating true
    
    @autorun (computation) =>
      lotusState = @lotusState()
      shouldBeHidden = @shouldBeHidden()
      waiting = @waiting()
      
      Tracker.nonreactive =>
        switch lotusState
          when @constructor.LotusStates.Hidden
            # Drive in if we shouldn't be hidden.
            unless waiting or shouldBeHidden
              @lotusState @constructor.LotusStates.DrivingIn
              @waitingTime @constructor.drivingTimes.In
              @audio.lotusAccelerating false
              @audio.lotusVisible true
              
          when @constructor.LotusStates.DrivingIn
            # Drive all the way out if we should be hidden.
            if shouldBeHidden
              @lotusState @constructor.LotusStates.DrivingOut
              @waitingTime @constructor.drivingTimes.Out
              @audio.lotusAccelerating true
            
            # Start opening the door when the drive is over.
            else unless waiting
              @lotusState @constructor.LotusStates.Opening
              @waitingTime @constructor.openingTime
              @audio.lotusEngine false
              
          when @constructor.LotusStates.Opening
            # Drive out if we should be hidden.
            if shouldBeHidden
              @lotusState @constructor.LotusStates.DrivingOut
              @waitingTime @constructor.drivingTimes.Out
              @audio.lotusEngine true
              
            # Open the door when the drive is over.
            else unless waiting
              @lotusState @constructor.LotusStates.Open
              @waitingTime @constructor.speakingTime
          
          when @constructor.LotusStates.Open
            # Close the door if we should be hidden.
            if shouldBeHidden
              @lotusState @constructor.LotusStates.Closing
              
            # Get ready to speak.
            else unless waiting
              @lotusState @constructor.LotusStates.ReadyToSpeak

          when @constructor.LotusStates.ReadyToSpeak
            # Get ready to close the door if we should be hidden.
            if shouldBeHidden
              @lotusState @constructor.LotusStates.ReadyToClose
              @waitingTime @constructor.leavingTime
              
          when @constructor.LotusStates.ReadyToClose
            # Be ready to speak if we shouldn't be hidden.
            unless shouldBeHidden
              @lotusState @constructor.LotusStates.ReadyToSpeak
              @waitingTime 0
              
            # Close the door when ready.
            else unless waiting
              @lotusState @constructor.LotusStates.Closing
              @waitingTime @constructor.closingTime
              @audio.lotusEngine true
          
          when @constructor.LotusStates.Closing
            # Open the door if we shouldn't be hidden.
            unless shouldBeHidden
              @lotusState @constructor.LotusStates.Open
              @waitingTime @constructor.speakingTime
              @audio.lotusEngine false
              
            # Drive away when the door is closed.
            else unless waiting
              @lotusState @constructor.LotusStates.DrivingOut
              @waitingTime @constructor.drivingTimes.Out
              @audio.lotusAccelerating true
              
          when @constructor.LotusStates.DrivingOut
            # Become hidden when the drive is over.
            unless waiting
              @lotusState @constructor.LotusStates.Hidden
              @waitingTime @constructor.hiddenTime
              @audio.lotusVisible false
              
  onRendered: ->
    super arguments...
    
    @lotusElement = @$('.lotus')[0]
  
  lotusDrivingClass: ->
    'driving' if @lotusState() in [@constructor.LotusStates.DrivingIn, @constructor.LotusStates.DrivingOut]
  
  lotusOpenClass: ->
    'open' if @lotusState() in [@constructor.LotusStates.Open, @constructor.LotusStates.ReadyToSpeak, @constructor.LotusStates.ReadyToClose]
  
  lotusPositionClass: ->
     switch @lotusState()
      when @constructor.LotusStates.Hidden then 'right'
      when @constructor.LotusStates.DrivingOut then 'left'
      else 'center'
  
  speechBalloonOptions: ->
    text: =>
      return unless @displayState() is Instructions.DisplayStates.Open
      return unless @lotusState() is @constructor.LotusStates.ReadyToSpeak
      
      @displayedInstruction()?.message()
  
  update: (appTime) ->
    super arguments...
    
    if @lotusState() in [@constructor.LotusStates.DrivingIn, @constructor.LotusStates.DrivingOut]
      boundingRectangle = @lotusElement.getBoundingClientRect()
      lotusCenter = boundingRectangle.left + boundingRectangle.width / 2
      @audio.lotusPan AEc.getPanForPosition lotusCenter
      
      if @lotusCenter?
        scale = LOI.adventure.interface.display.scale()
        distance = Math.abs(@lotusCenter - lotusCenter) / scale
        @audio.lotusSpeed distance / appTime.elapsedAppTime
        
      @lotusCenter = lotusCenter
    
    if waitingTime = @waitingTime()
      @waitingTime Math.max 0, waitingTime - appTime.elapsedAppTime
