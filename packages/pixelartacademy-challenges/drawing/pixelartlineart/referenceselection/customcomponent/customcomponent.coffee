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
      binderOpen: AEc.ValueTypes.Trigger
      binderClose: AEc.ValueTypes.Trigger
      sheetMove: AEc.ValueTypes.Trigger
      referenceRemove: AEc.ValueTypes.Trigger
      
  onCreated: ->
    super arguments...
    
    @binderVisible = new ReactiveField false
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

    @autorun (computation) =>
      shouldBeActive = @drawingApp.activeAsset()?
  
      if shouldBeActive and not @_wasActive
        @_initialize()
        @binderVisible true
        
        Meteor.clearTimeout @_activeTimeout
        @_activeTimeout = Meteor.setTimeout =>
          @active true
        ,
          100
      
      else if @_wasActive and not shouldBeActive
        @_close()
        @active false
        
        Meteor.clearTimeout @_activeTimeout
        @_activeTimeout = Meteor.setTimeout =>
          @binderVisible false
        ,
          1000
  
      @_wasActive = shouldBeActive
  
  setPixelPadSize: (drawingApp) ->
    drawingApp.setMaximumPixelPadSize fullscreen: true
  
  _initialize: ->
    references =
      for drawLineArtClass, index in _.values PAA.Challenges.Drawing.PixelArtLineArt.remainingDrawLineArtClasses()
        id: drawLineArtClass.id()
        index: index
        imageUrl: drawLineArtClass.referenceImageUrl()
        imageStyle:
          top: "#{5 + Math.floor Math.random() * 5}rem"
          left: "#{5 + Math.floor Math.random() * 5}rem"
        referenceStyle:
          width: "#{@constructor.sheetWidth + 2 * index}rem"
    
    @references references
    @currentPage 0
    @referenceSelected false
    
  _close: ->
    @currentPage 0
    @referenceSelected false
    Meteor.clearTimeout @_switchToBitmapTimeout
  
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
      1000
  
  activeClass: ->
    'active' if @active()
    
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
    @currentPage @currentPage() + 1
  
  onClickPreviousReference: (event) ->
    @currentPage @currentPage() - 1
  
  onClickReference: (event) ->
    return if @referenceSelected()
    
    @_selectReference()
