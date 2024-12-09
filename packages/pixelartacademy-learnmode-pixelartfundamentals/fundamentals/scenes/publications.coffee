LOI = LandsOfIllusions
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.PixelArtFundamentals.Fundamentals.Publications extends LOI.Adventure.Scene
  @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Publications'

  @location: -> PAA.Publication.Location

  @initialize()

  things: ->
    things = []
    
    activePinballProjectId = PAA.Pixeltosh.Programs.Pinball.Project.state 'activeProjectId'

    if activePinballProjectId
      if pinballProject = PAA.Practice.Project.documents.findOne activePinballProjectId
        for asset in pinballProject.assets
          assetClass = PAA.Practice.Project.Asset.getClassForId asset.id
          if unlockedPublications = assetClass.unlockedPublications?()
            things.push unlockedPublications...

    things
