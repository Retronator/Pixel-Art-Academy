AMe = Artificial.Melody

class AMe.Composition
  constructor: (@audioManager) ->
    @sections = []
    @initialSection = null
  
  destroy: ->
    section.destroy() for section in @sections
    
  ready: ->
    conditions = (section.ready() for section in @sections)
    
    console.log "Composition ready", conditions, @ if AMe.debug
    
    _.every conditions
