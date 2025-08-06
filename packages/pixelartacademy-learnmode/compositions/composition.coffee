AEc = Artificial.Echo
AMe = Artificial.Melody
LOI = LandsOfIllusions
LM = PixelArtAcademy.LearnMode

class LM.Compositions.Composition extends AMe.Composition
  constructor: ->
    super arguments...
    
  _homeScreenTransitionCondition: =>
    return unless app = @_getCurrentApp()
    app instanceof PAA.PixelPad.Apps.HomeScreen
  
  _tutorialStartTransitionCondition: =>
    return unless drawingAppInfo = @_getDrawingAppInfo()
    return unless drawingAppInfo.activeSection.nameKey is PAA.PixelPad.Apps.Drawing.Portfolio.Sections.Tutorials
    drawingAppInfo.groupProgress < 1 / 3
  
  _tutorialMiddleTransitionCondition: =>
    return unless drawingAppInfo = @_getDrawingAppInfo()
    return unless drawingAppInfo.activeSection.nameKey is PAA.PixelPad.Apps.Drawing.Portfolio.Sections.Tutorials
    1 / 3 <= drawingAppInfo.groupProgress < 2 / 3
  
  _tutorialEndingTransitionCondition: =>
    return unless drawingAppInfo = @_getDrawingAppInfo()
    return unless drawingAppInfo.activeSection.nameKey is PAA.PixelPad.Apps.Drawing.Portfolio.Sections.Tutorials
    2 / 3 <= drawingAppInfo.groupProgress

  _getCurrentApp: ->
    # When no app is opened, reset the music to default.
    return unless pixelPad = LOI.adventure.getCurrentThing PAA.PixelPad
    
    pixelPad.os.currentApp()
    
  _getDrawingAppInfo: ->
    return unless currentApp = @_getCurrentApp()
    
    # React to drawing app changes.
    return unless currentApp instanceof PAA.PixelPad.Apps.Drawing
    drawing = currentApp
    
    # Wait until an asset is activated.
    return unless portfolio = drawing.portfolio()
    return unless activeAsset = portfolio.activeAsset()
    
    # See which section we're in and how far along in the group.
    activeSection = portfolio.activeSection()
    activeGroup = portfolio.activeGroup()
    activeAssets = activeGroup.assets()
    
    activeAssetIndex = _.findIndex activeAssets, (asset) => asset is activeAsset
    unitIndex = activeAssets.length - 1 - activeAssetIndex
    
    unitsCount = activeGroup.content?()?.progress.unitsCount() or 1
    groupProgress = if unitsCount > 1 then unitIndex / (unitsCount - 1) else 0
    
    {activeAsset, activeSection, groupProgress}

  _drawingCondition: ->
    return unless currentApp = @_getCurrentApp()
    return unless currentApp instanceof PAA.PixelPad.Apps.Drawing
    drawing = currentApp
    drawing.editor()?.drawingActive()
