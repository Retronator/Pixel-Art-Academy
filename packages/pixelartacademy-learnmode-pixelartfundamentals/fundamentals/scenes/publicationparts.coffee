LOI = LandsOfIllusions
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.PixelArtFundamentals.Fundamentals.PublicationParts extends LOI.Adventure.Scene
  @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.PublicationParts'

  @location: -> PAA.Publication.Part.Location

  @initialize()

  things: ->
    things = []
    
    activePinballProjectId = PAA.Pixeltosh.Programs.Pinball.Project.state 'activeProjectId'

    if activePinballProjectId
      if pinballProject = PAA.Practice.Project.documents.findOne activePinballProjectId
        for asset in pinballProject.assets
          assetClass = PAA.Practice.Project.Asset.getClassForId asset.id
          if unlockedPublicationParts = assetClass.unlockedPublicationParts?()
            things.push unlockedPublicationParts...

    things
