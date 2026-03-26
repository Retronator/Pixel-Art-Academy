AM = Artificial.Mirage
PAA = PixelArtAcademy

Block = AM.Quill.import 'blots/block'
Container = AM.Quill.import 'blots/container'

class PAA.Publication.Article.CustomClass extends Block
  @blotName: 'publication-customclass'
  @tagName: 'p'
  @className: 'pixelartacademy-publication-article-customclass'
  
  @_classes = []
  
  @create: (value) ->
    domNode = super value
    domNode.className = "#{@className} #{value}"
    domNode
    
  @formats: (domNode) ->
    classes = _.without [domNode.classList...], @className
    result = classes.join(' ') or undefined
    result
  
  format: (name, value) ->
    if name is @constructor.blotName and value
      if value
        @domNode.className = "#{@constructor.className} #{value}"
        
      else
        @domNode.className = @constructor.className
      
    else
      super name, value
  
  @registerClass: (className) ->
    @_classes.push className

  @getClasses: -> @_classes
  
  class @Container extends Container
    @blotName: 'publication-customclass-container'
    @tagName: 'div'
    @className: 'pixelartacademy-publication-article-customclass-container'

PAA.Publication.Article.CustomClass.Container.allowedChildren = [PAA.Publication.Article.CustomClass]
PAA.Publication.Article.CustomClass.requiredContainer = PAA.Publication.Article.CustomClass.Container

AM.Quill.register PAA.Publication.Article.CustomClass.Container
AM.Quill.register PAA.Publication.Article.CustomClass
