AM = Artificial.Mirage
PAA = PixelArtAcademy
Quill = AM.Quill

class PAA.StudyGuide.Pages.Home.Submissions.Picture extends AM.Component
  @id: -> 'PixelArtAcademy.StudyGuide.Pages.Home.Submissions.Picture'
  @register @id()

  constructor: ->
    super arguments...

    @autoScaledImageMixin = new PAA.Components.AutoScaledImageMixin

  mixins: -> [
    @autoScaledImageMixin
  ]

  onCreated: ->
    super arguments...

    @submissions = @ancestorComponentOfType PAA.StudyGuide.Pages.Home.Submissions

  autoScaledImageMaxHeight: ->
    # Images shouldn't be taller than half the page, but add some diversity.
    imageInfo = @autoScaledImageMixin.imageInfo()

    110 - imageInfo.height % 7

  autoScaledImageMaxWidth: ->
    # Images shouldn't be wider than the folder, but add some diversity.
    imageInfo = @autoScaledImageMixin.imageInfo()

    160 - imageInfo.width % 7

  autoScaledImageDisplayScale: ->
    @submissions.display.scale()

  loadedClass: ->
    'loaded' if @autoScaledImageMixin.imageInfo()

  displayedClass: ->
    entry = @data()

    'displayed' if entry in @submissions.displayedEntries()

  hoveredClass: ->
    entry = @data()

    'hovered' if entry is @submissions.hoveredEntry()

  componentStyle: ->
    return unless imageInfo = @autoScaledImageMixin.imageInfo()

    # Randomize right position slightly.
    right = 3 + imageInfo.width % 5

    right: "#{right}rem"
