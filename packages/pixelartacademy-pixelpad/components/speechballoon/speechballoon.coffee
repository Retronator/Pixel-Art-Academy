AB = Artificial.Base
AM = Artificial.Mirage
PAA = PixelArtAcademy

class PAA.PixelPad.Components.SpeechBalloon extends AM.Component
  @id: -> 'PixelArtAcademy.PixelPad.Components.SpeechBalloon'
  @register @id()
  
  constructor: (@options) ->
    super arguments...
    
  onCreated: ->
    super arguments...
    
    @contentWidth = new ReactiveField 0
    @contentHeight = new ReactiveField 0
    
    @text = new ReactiveField null
    @displayed = new ReactiveField false
    
    @autorun (computation) =>
      # Depend on text changes.
      @options.text()
      
      Tracker.nonreactive =>
        # Nothing to do if we've already scheduled a re-evaluation.
        return if @_displayTimeout
        
        # Hide the currently displayed text in any case.
        if @displayed()
          @displayed false
          timeoutDuration = 400
          
        else
          timeoutDuration = 0
         
        # Schedule evaluation of the new text.
        @_displayTimeout = Meteor.setTimeout =>
          @_displayTimeout = null
          return unless text = @options.text()

          @text text
          @displayed true
        ,
          timeoutDuration
        
  onRendered: ->
    super arguments...
    
    @$contentMeasuring = @$('.content-measuring')
    @_resizeObserver = new ResizeObserver =>
      @contentWidth @$contentMeasuring.outerWidth()
      @contentHeight @$contentMeasuring.outerHeight()
    
    @_resizeObserver.observe @$contentMeasuring[0]
    
  onDestroyed: ->
    super arguments...
    
    @_resizeObserver?.disconnect()
    
  displayedClass: ->
    'displayed' if @displayed()
  
  contentAreaStyle: ->
    if @displayed()
      height = @contentHeight()
      width = @contentWidth()
      
    else
      width = 0
      height = 0
    
    width: "#{width}px"
    height: "#{height}px"
    
  contentStyle: ->
    width: "#{@contentWidth()}px"
    height: "#{@contentHeight()}px"
  
  contentMeasuringStyle: ->
    return unless characters = @options.text()?.length

    # Calculate how wide the content should be to be in a desired width to height ratio.
    widthToHeightRatio = 5
    lineHeight = 9
    averageLetterWidth = 4
    widthCharacters = Math.round Math.sqrt widthToHeightRatio * characters * lineHeight / averageLetterWidth
    
    minWidth: "#{Math.min 200, widthCharacters * averageLetterWidth}rem"
