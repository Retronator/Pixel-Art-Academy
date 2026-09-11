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
    
    activeProjectIds = [
      PAA.Pixeltosh.Programs.Pinball.Project.state 'activeProjectId'
      PAA.Pixeltosh.Programs.Chess.Project.TwoDimensional.state 'activeProjectId'
      PAA.Pixeltosh.Programs.Chess.Project.ThreeDimensional.state 'activeProjectId'
    ]

    for activeProjectId in activeProjectIds when activeProjectId
      continue unless project = PAA.Practice.Project.documents.findOne activeProjectId

      for asset in project.assets
        assetClass = PAA.Practice.Asset.getClassForId asset.id

        if unlockedPublications = assetClass.unlockedPublications?()
          publications = _.union publications, unlockedPublications

        if unlockedPublicationParts = assetClass.unlockedPublicationParts?()
          publicationParts = _.union publicationParts, unlockedPublicationParts
    
    {publications, publicationParts}

  things: -> @constructor.getUnlockedIds().publications

  class @Parts extends LOI.Adventure.Scene
    @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.PublicationParts'

    @location: -> PAA.Publication.Part.Location
  
    @initialize()
  
    things: -> Publications.getUnlockedIds().publicationParts
