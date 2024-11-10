AM = Artificial.Mirage
AMu = Artificial.Mummification
AEc = Artificial.Echo
LOI = LandsOfIllusions
PAA = PixelArtAcademy
FM = FataMorgana

PAE = PAA.Practice.PixelArtEvaluation

class PAA.PixelPad.Apps.Drawing.Editor.Desktop.Publications extends LOI.View
  @id: -> 'PixelArtAcademy.PixelPad.Apps.Drawing.Editor.Desktop.Publications'
  @register @id()
    
  constructor: ->
    super arguments...

    @active = new ReactiveField false
    
  onCreated: ->
    super arguments...
    
    @designConstants =
      revealedHeight: 20
      verticalPadding: 30
      horizontalPadding: 30
    
    @desktop = @ancestorComponentOfType PAA.PixelPad.Apps.Drawing.Editor.Desktop
    
    @publicationReferenceIds = new ComputedField =>
      return unless asset = @desktop.activeAsset()
      asset.constructor.publications?()
    
    @autorun (computation) =>
      return unless publicationReferenceIds = @publicationReferenceIds()
      PAA.Publication.forReferenceIds.subscribeContent @, publicationReferenceIds
      PAA.Publication.forReferenceIds.subscribe @, publicationReferenceIds
    
    @currentPublicationIndex = new ReactiveField 0
    
    @publications = new ComputedField =>
      return unless publicationReferenceIds = @publicationReferenceIds()
      
      Tracker.nonreactive => @currentPublicationIndex 0
      
      publications = for referenceId in publicationReferenceIds
        PAA.Publication.documents.findOne {referenceId}
        
      randomOffset = => if index is publications.length - 1 then 0 else Math.floor(Math.random() * 5 + 5) * Math.sign Math.random() - 0.5
      
      activeOffset = 0
      
      for publication, index in publications when publication
        publicationInfo =
          publication: publication
          index: index
          component: new PAA.Publication.Component publication._id
          offset:
            x: randomOffset()
            y: randomOffset()
          activeOffset: activeOffset
        
        activeOffset += publication.design.size.width + @designConstants.horizontalPadding
        
        publicationInfo
        
    @currentPublication = new ComputedField =>
      return unless publications = @publications()

      publications[@currentPublicationIndex()]
      
    @activeDisplayed = new ReactiveField false
    
    # Automatically enter focused mode when active.
    @autorun (computation) =>
      @desktop.focusedMode @active()
  
    # Automatically deactivate when exiting focused mode.
    @autorun (computation) =>
      return if @desktop.focusedMode()
      
      @deactivate()
      
  onBackButton: ->
    return unless currentPublication = @currentPublication()
    currentPublication.component.back()
    
  activate: ->
    @active true
    
    @currentPublication().component.enable()
    
    @_activeDisplayedTimeout = Meteor.setTimeout =>
      @activeDisplayed true
    ,
      1000
    
  deactivate: ->
    @active false
    
    @currentPublication()?.component.disable()
    
    Meteor.clearTimeout @_activeDisplayedTimeout
    @activeDisplayed false
  
  moveToPublicationIndex: (index) ->
    return unless publications = @publications()
    
    publications[@currentPublicationIndex()].component.disable()
    
    @currentPublicationIndex index
    
    publications[index].component.enable()
    
  activeClass: ->
    'active' if @active()

  publicationStyle: ->
    publication = @currentData()
    currentPublication = @currentPublication()
    
    if @active()
      left = publication.activeOffset - currentPublication.activeOffset
      
      if currentPublication.component.opened() and publication isnt currentPublication
        if publication.index < currentPublication.index
          left -= 480
          
        else
          left += 480
        
      top: "-100%"
      left: "#{left}rem"
      
    else
      left: "#{publication.offset.x}rem"
      top: "-#{@designConstants.revealedHeight + @designConstants.verticalPadding + publication.offset.y}rem"
  
  showPublicationSelectButtons: ->
    @active() and not @currentPublication()?.component.opened()
  
  canMoveLeft: ->
    @currentPublicationIndex()
    
  canMoveRight: ->
    @currentPublicationIndex() < @publications().length - 1
  
  publicationSelectButtonStyle: ->
    return unless currentPublication = @currentPublication()
    
    width: "calc(50% - #{currentPublication.publication.design.size.width / 2}rem)"
    
  events: ->
    super(arguments...).concat
      'click .publication': @onClickPublication
      'click .previous-publication-button': @onClickPreviousPublicationButton
      'click .next-publication-button': @onClickNextPublicationButton
  
  onClickPublication: (event) ->
    return if @active()

    @activate()
    
  onClickPreviousPublicationButton: (event) ->
    return unless currentPublicationIndex = @currentPublicationIndex()
    
    @moveToPublicationIndex currentPublicationIndex - 1
    
    
  onClickNextPublicationButton: (event) ->
    currentPublicationIndex = @currentPublicationIndex()
    return unless currentPublicationIndex < @publications().length
    
    @moveToPublicationIndex currentPublicationIndex + 1
