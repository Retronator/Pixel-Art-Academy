AB = Artificial.Babel
AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

Quill = AM.Quill

class PAA.Publication.Pages.Admin.Publications.Publication.Header extends AM.Component
  @id: -> 'PixelArtAcademy.Publication.Pages.Admin.Publications.Publication.Header'
  @register @id()

  @version: -> '0.1.0'

  @debug = false

  onCreated: ->
    super arguments...

    @publicationComponent = @ancestorComponentOfType PAA.Publication.Pages.Admin.Publications.Publication

    @quill = new AE.ReactiveWrapper null

    @header = new ComputedField =>
      @publicationComponent.data().design?.header or []

    @displayScale = 2

  onRendered: ->
    super arguments...

    # Initialize quill.
    quill = new Quill @$('.pixelartacademy-publication-header')[0],
      theme: 'snow'
      formats: PAA.Publication.Header.quillFormats
      modules:
        toolbar:
          container: [
            ['bold', 'italic']
            ['clean']
          ]

    @quill quill

    quill.on 'text-change', (delta, oldDelta, source) =>
      console.log "Text change", delta, oldDelta, source if @constructor.debug

      # Update the header if this was a user update.
      if source is Quill.sources.USER
        publication = @publicationComponent.data()
        PAA.Publication.updateHeader publication._id, delta.ops

    quill.on 'editor-change', =>
      # Trigger reactive updates.
      @quill.updated()
      
    # Update quill content.
    @autorun (computation) =>
      return unless header = @header()

      # See if we already have the correct content.
      currentHeader = quill.getContents().ops

      console.log "Updating header from database", header, currentHeader if @constructor.debug

      if EJSON.equals header, currentHeader
        console.log "Current content matches." if @constructor.debug
        return

      console.log "Updating content." if @constructor.debug

      # The content is new, update.
      quill.setContents header, Quill.sources.API

  focus: ->
    @quill().focus()
