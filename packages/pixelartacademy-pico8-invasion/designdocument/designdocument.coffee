AB = Artificial.Base
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Pico8.Cartridges.Invasion.DesignDocument extends AM.Component
  @id: -> 'PixelArtAcademy.Pico8.Cartridges.Invasion.DesignDocument'
  @register @id()
  
  @designStringForProjectId: (projectId) ->
    project = PAA.Practice.Project.documents.findOne projectId
    @_designStringsForObject(project.design).join '\n'
    
  @_designStringsForObject: (object) ->
    if _.isArray object
      for item in object
        @_designStringsForObject item
      
    else if _.isObject object
      valueStrings = for key, value of object
        if _.isArray(value) or _.isObject(value)
          [
            "#{key}={"
            @_designStringsForObject(value)...
            "}"
          ]
        
        else
          ["#{key}=#{value}"]
          
      _.flatten valueStrings
      
  onCreated: ->
    super arguments...
    
    @projectId = new ComputedField => PAA.Pico8.Cartridges.Invasion.Project.state 'activeProjectId'
    
    @project = new ComputedField =>
      return unless projectId = @projectId()
      PAA.Practice.Project.documents.findOne projectId
  
  getDesignValue: (property) ->
    _.nestedProperty @project()?.design, property
    
  setDesignValue: (property, value) ->
    PAA.Practice.Project.documents.update @projectId(),
      $set:
        lastEditTime: Date.now()
        "design.#{property}": value
  
  Component = @
  
  class @Subtitle extends AM.DataInputComponent
    @register "#{Component.id()}.Subtitle"
    
    onCreated: ->
      super arguments...
      
      @designDocument = @parentComponent()
      
      @type = AM.DataInputComponent.Types.Text
      @property = 'subtitle'
      
    load: ->
      @designDocument.getDesignValue @property
      
    save: (value) ->
      @designDocument.setDesignValue @property, value
