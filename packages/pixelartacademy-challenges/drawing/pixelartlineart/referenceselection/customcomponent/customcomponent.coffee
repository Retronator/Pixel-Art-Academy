AB = Artificial.Base
AM = Artificial.Mirage
AEc = Artificial.Echo
PAA = PixelArtAcademy
LOI = LandsOfIllusions

class PAA.Challenges.Drawing.PixelArtLineArt.ReferenceSelection.CustomComponent extends LOI.Component
  @id: -> 'PixelArtAcademy.Challenges.Drawing.PixelArtLineArt.ReferenceSelection.CustomComponent'
  @register @id()
  
  @sheetWidth = 139
  
  @Audio = new LOI.Assets.Audio.Namespace @id(),
    variables:
      binderDrag: AEc.ValueTypes.Boolean
      binderOpen: AEc.ValueTypes.Trigger
      binderClose: AEc.ValueTypes.Trigger
      turnSheet: AEc.ValueTypes.Trigger
      selectReference: AEc.ValueTypes.Trigger
      
  onCreated: ->
    super arguments...
    
    # Controls whether the binder is visible anywhere in the screen.
    @binderVisible = new ReactiveField false
    
    # Controls whether the binder should be displayed in the center of the table.
    @binderDisplayed = new ReactiveField false
    
    @_wasActive = false
    @active = new ReactiveField false
    
    @drawingApp = @ancestorComponentOfType PAA.PixelPad.Apps.Drawing
    
    @references = new ReactiveField []
    @currentPage = new ReactiveField 0
    @currentReferenceIndex = new ComputedField => Math.max 0, @currentPage() - 1
    @referenceSelected = new ReactiveField false
    
    @previousReferences = new ComputedField => @references()[0...@currentReferenceIndex()]
    @nextReferences = new ComputedField => _.reverse @references()[@currentReferenceIndex()...]
    
  onRendered: ->
    super arguments...
    
    @audio.binderDrag false

    @autorun (computation) =>
      shouldBeActive = @drawingApp.activeAsset()?
  
      if shouldBeActive and not @_wasActive
        @_initializeReferences()
        
        # Start rendering the binder in closed state.
        @currentPage 0
        @binderVisible true
        
        @_resetActivateTimers()
        @_activeTimeout = Meteor.setTimeout =>
          # Fade in the component.
          @active true

          # Move the binder to the center of the table.
          @binderDisplayed true
        ,
          100
        
        @_binderDragTimeout = Meteor.setTimeout =>
          @audio.binderDrag true
        ,
          800
      
      else if @_wasActive and not shouldBeActive
        # End any animation for selecting a reference.
        @referenceSelected false
        Meteor.clearTimeout @_switchToBitmapTimeout
        Meteor.clearTimeout @_closeBinderTimeout

        # Close the binder and move it from the table.
        @currentPage 0
        @binderDisplayed false
        @audio.binderDrag false

        # Fade out the component.
        @_resetActivateTimers()
        @_deactivateTimeout = Meteor.setTimeout =>
          @active false
        ,
          500
        
        # Stop rendering the binder.
        @_hideTimeout = Meteor.setTimeout =>
          @binderVisible false
        ,
          1000
  
      @_wasActive = shouldBeActive
      
  _resetActivateTimers: ->
    Meteor.clearTimeout @_activeTimeout
    Meteor.clearTimeout @_deactivateTimeout
    Meteor.clearTimeout @_binderDragTimeout
    Meteor.clearTimeout @_hideTimeout
  
  setPixelPadSize: (drawingApp) ->
    drawingApp.setMaximumPixelPadSize fullscreen: true
  
  _initializeReferences: ->
    references =
      for drawLineArtClass, index in _.values PAA.Challenges.Drawing.PixelArtLineArt.remainingDrawLineArtClasses()
        scalePercentage = drawLineArtClass.binderScale() * 100
        offsetRangePercentage = 100 - scalePercentage
      
        id: drawLineArtClass.id()
        index: index
        imageUrl: drawLineArtClass.referenceImageUrl()
        imageStyle:
          top: "calc(#{5 + Math.floor Math.random() * 5}rem + #{offsetRangePercentage}%)"
          left: "calc(#{5 + Math.floor Math.random() * 5}rem + #{Math.random() * offsetRangePercentage}%)"
          width: "calc(#{scalePercentage}% - 15rem)"
          height: "calc(#{scalePercentage}% - 15rem)"
        referenceStyle:
          width: "#{@constructor.sheetWidth + 2 * index}rem"
    
    @references references
    @referenceSelected false

  _selectReference: ->
    selectedReferenceId = @references()[@currentReferenceIndex()].id
    @referenceSelected true
    
    @_switchToBitmapTimeout = Meteor.setTimeout =>
      PAA.Challenges.Drawing.PixelArtLineArt.addDrawLineArtAsset selectedReferenceId

      # Find out the bitmap ID.
      Tracker.autorun (computation) =>
        return unless assets = PAA.Challenges.Drawing.PixelArtLineArt.state('assets')
        return unless selectedAsset = _.find assets, (asset) -> asset.id is selectedReferenceId
        return unless bitmapId = selectedAsset.bitmapId
        computation.stop()
      
        AB.Router.changeParameters
          parameter3: bitmapId
          parameter4: 'edit'
    ,
      2500
    
    @_closeBinderTimeout = Meteor.setTimeout =>
      @currentPage 0
      @binderDisplayed false
      @audio.binderClose()
      @audio.binderDrag false
    ,
      1500
  
  activeClass: ->
    'active' if @active()
    
  binderDisplayedClass: ->
    'displayed' if @binderDisplayed()
    
  binderOpenClass: ->
    'open' if @currentPage() > 0
  
  canMoveBack: ->
    return if @referenceSelected()
    @currentPage() > 0
    
  canMoveForward: ->
    return if @referenceSelected()
    @nextReferences().length > 0
    
  binderReferenceSelectedClass: ->
    'selected' if @referenceSelected()
  
  referenceSelectedClass: ->
    reference = @currentData()
    return unless @currentReferenceIndex() is reference.index

    'selected' if @referenceSelected()
    
  events: ->
    super(arguments...).concat
      'click .next-reference': @onClickNextReference
      'click .previous-reference': @onClickPreviousReference
      'click .reference': @onClickReference
  
  onClickNextReference: (event) ->
    currentPage = @currentPage()
    
    if currentPage
      @audio.turnSheet()
      
    else
      @audio.binderOpen()

    @currentPage currentPage + 1
  
  onClickPreviousReference: (event) ->
    currentPage = @currentPage()
    
    if currentPage is 1
      @audio.binderClose()
      
    else
      @audio.turnSheet()
    
    @currentPage currentPage - 1
  
  onClickReference: (event) ->
    return if @referenceSelected()
    
    @audio.selectReference()
    
    @_selectReference()
