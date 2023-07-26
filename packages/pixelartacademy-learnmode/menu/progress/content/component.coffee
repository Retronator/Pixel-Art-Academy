AB = Artificial.Babel
AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.Menu.Progress.Content.Component extends AM.Component
  onCreated: ->
    super arguments...
    
    @progress = @ancestorComponentOfType LM.Menu.Progress
    @progressContent = @ancestorComponentOfType LM.Menu.Progress.Content
    
    @tags = new ComputedField =>
      content = @data()
      
      for tag in content.tags()
        translationKey = tag
        
        # Apply any translation key overrides.
        translationKey = 'DLCAppStore' if tag is LM.Content.Tags.DLC and AB.DistributionPlatform.isAppStore
        
        # Create the tag information.
        tagClass: _.kebabCase tag
        displayName: LM.Content.Tags.getDisplayNameForKey translationKey
        description: LM.Content.Tags.getDescriptionForKey translationKey
  
  hasContentsClass: ->
    content = @data()
    'has-contents' if content.contents().length > 0
  
  showPreview: ->
    # Show preview only in the courses preview.
    return unless @progress.inPreview()
    
    # Show when the content has any child content.
    content = @data()
    content.contents().length
    
  previewVisibleClass: ->
    # The preview text is visible when the content is not expanded.
    'visible' if not @progressContent.contentsDisplayed()
  
  showCompletion: ->
    # Only show completion in game.
    return unless @progress.inGame()

    # Show completion when the content has been unlocked.
    content = @data()
    content.unlocked()
  
  showRequiredUnits: ->
    content = @data()
    content.progress.requiredUnits() and (not content.completed() or content.contents().length)

  showCompletedContentsCount: ->
    content = @data()
    content.contents().length and not @showRequiredUnits()

  completionistMode: ->
    LM.Menu.Progress.state('completionDisplayType') is LM.Menu.Progress.CompletionDisplayTypes.TotalPercentage

  totalPercentageTitleAttribute: ->
    content = @data()
    return unless units = content.progress.totalUnits()

    completedUnitsCount = content.progress.completedUnitsCount?()
    unitsCount = content.progress.unitsCount?()
    return unless completedUnitsCount? and unitsCount?

    title: "#{completedUnitsCount}/#{unitsCount} #{units}"

  requiredUnitsTitleAttribute: ->
    content = @data()
    return unless units = content.progress.requiredUnits()

    requiredCompletedUnitsCount = content.progress.requiredCompletedUnitsCount?()
    requiredUnitsCount = content.progress.requiredUnitsCount?()
    return unless requiredCompletedUnitsCount? and requiredUnitsCount?

    requiredCompletedRatio = content.progress.requiredCompletedRatio()
    title: "#{requiredCompletedUnitsCount}/#{requiredUnitsCount} #{units} (#{@percentageString requiredCompletedRatio})"
  
  completedContentsCountTitleAttribute: ->
    content = @data()
    return unless contents = content.contents()
  
    completedContentsCount = @completedContentsCount()
    completedRatio = completedContentsCount / contents.length
  
    title: "#{completedContentsCount}/#{contents.length} sections (#{@percentageString completedRatio})"

  percentageString: (ratio) ->
    "#{Math.floor ratio * 100}%"

  completedContentsCount: ->
    content = @data()
    return unless contents = content.contents()
  
    _.filter(contents, (content) => content.completed()).length
