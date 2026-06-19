AB = Artificial.Babel
AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

Quill = AM.Quill
Block = Quill.import 'blots/block'

class PAA.Publication.Component.Header extends AM.Component
  @id: -> 'PixelArtAcademy.Publication.Component.Header'
  @register @id()

  @version: -> '0.1.0'
  
  onCreated: ->
    super arguments...

    @publicationComponent = @ancestorComponentOfType PAA.Publication.Component
    @publication = new ComputedField => @publicationComponent.publication()

    @quill = new AE.ReactiveWrapper null
  
  onRendered: ->
    super arguments...

    # Initialize quill.
    quill = new Quill @$('.pixelartacademy-publication-header')[0],
      formats: PAA.Publication.Header.quillFormats
      readOnly: true

    @quill quill

    # Update quill content.
    @autorun (computation) =>
      return unless publication = @data()

      quill.setContents publication.design?.header, Quill.sources.API
