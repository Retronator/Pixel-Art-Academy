AM = Artificial.Mirage
PAA = PixelArtAcademy

Block = AM.Quill.import 'blots/block'
Container = AM.Quill.import 'blots/container'

class PAA.Publication.Article.Header extends Container
  @blotName: 'publication-header'
  @tagName: 'header'
  @className: 'pixelartacademy-publication-article-header'

  class @Heading extends Block
    @blotName: 'publication-header-heading'
    @tagName: ['H1', 'H2', 'H3']
    @className: 'pixelartacademy-publication-article-header-heading'
    
    @formats: (domNode) ->
      @tagName.indexOf(domNode.tagName) + 1;

PAA.Publication.Article.Header.allowedChildren = [PAA.Publication.Article.Header.Heading]
PAA.Publication.Article.Header.Heading.requiredContainer = PAA.Publication.Article.Header

AM.Quill.register PAA.Publication.Article.Header
AM.Quill.register PAA.Publication.Article.Header.Heading
