LOI = LandsOfIllusions
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.PixelArtFundamentals.Fundamentals.Publications extends LOI.Adventure.Scene
  @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Publications'

  @location: -> PAA.Publication.Location

  @initialize()

  @getUnlockedIds: ->
    publications = []
    publicationParts = []
    
    activePinballProjectId = PAA.Pixeltosh.Programs.Pinball.Project.state 'activeProjectId'

    if activePinballProjectId
      if pinballProject = PAA.Practice.Project.documents.findOne activePinballProjectId
        for asset in pinballProject.assets
          assetClass = PAA.Practice.Project.Asset.getClassForId asset.id
          
          if unlockedPublications = assetClass.unlockedPublications?()
            publications.push unlockedPublications...
          
          if unlockedPublicationParts = assetClass.unlockedPublicationParts?()
            publicationParts.push unlockedPublicationParts...
    
    {publications, publicationParts}

  things: -> @constructor.getUnlockedIds().publications

  class @Parts extends LOI.Adventure.Scene
    @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.PublicationParts'

    @location: -> PAA.Publication.Part.Location
  
    @initialize()
  
    things: -> Publications.getUnlockedIds().publicationParts
