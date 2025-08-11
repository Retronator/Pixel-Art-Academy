LOI = LandsOfIllusions
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.Design.Fundamentals.Publications extends LOI.Adventure.Scene
  @id: -> 'PixelArtAcademy.LearnMode.Design.Fundamentals.Publications'

  @location: -> PAA.Publication.Location

  @initialize()
  
  @getChronoscopeIds: ->
    publications = []
    publicationParts = []
    
    activeInvasionProjectId = PAA.Pico8.Cartridges.Invasion.Project.state 'activeProjectId'
    
    if activeInvasionProjectId
      if invasionProject = PAA.Practice.Project.documents.findOne activeInvasionProjectId
        if theme = invasionProject.design?.theme
          IssueIds = LM.Design.Fundamentals.Publications.Chronoscope.IssueIDs
          
          if IssueIds[theme]
            publications.push IssueIds[theme]
            
          else if theme is PAA.Pico8.Cartridges.Invasion.DesignDocument.Options.Themes.Everything
            publications.push _.values(IssueIds)...
            
    for referenceId in publications
      continue unless publication = PAA.Publication.documents.findOne {referenceId}
      for content in publication.contents
        referenceId = content.part.referenceId
        continue unless publicationPart = PAA.Publication.Part.documents.findOne {referenceId}
        publicationParts.push referenceId if publicationPart.design?.class is 'unlocked'
    
    {publications, publicationParts}

  things: -> @constructor.getChronoscopeIds().publications

  class @Parts extends LOI.Adventure.Scene
    @id: -> 'PixelArtAcademy.LearnMode.Design.Fundamentals.PublicationParts'
  
    @location: -> PAA.Publication.Part.Location
  
    @initialize()
  
    things: -> Publications.getChronoscopeIds().publicationParts
