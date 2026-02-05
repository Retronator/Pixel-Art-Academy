PAA = PixelArtAcademy
PAE = PAA.Practice.PixelArtEvaluation

class PAA.Practice.ReadabilityAnalysis
  # labels: the analysis of which labels get recognized in the image
  #   symbolic, realistic: arrays of label probabilities (1% or higher) sorted by probability descending
  #     label: string with the name
  #     probability: number between 0 and 1 how likely this label is drawn
  constructor: (@bitmap, @options = {}) ->
    @labels =
      symbolic: []
      realistic: []
    
    @pixelArtEvaluation = new PAE @bitmap, @options
    
    @_classificationDependency = new Tracker.Dependency
    
    @_classificationAutorun = Tracker.autorun (computation) =>
      @pixelArtEvaluation.depend()
      
      # TODO: Run classifiers.
  
      # Gather results.
      @_classificationDependency.changed()

  destroy: ->
    @_classificationAutorun.stop()
    
    @pixelArtEvaluation.destroy()
    
  depend: ->
    @_classificationDependency.depend()
