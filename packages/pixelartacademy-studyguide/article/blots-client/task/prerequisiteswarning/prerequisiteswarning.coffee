AM = Artificial.Mirage
PAA = PixelArtAcademy
Quill = AM.Quill

class PAA.StudyGuide.Article.Task.PrerequisitesWarning extends PAA.StudyGuide.Article.Task
  @id: -> 'PixelArtAcademy.StudyGuide.Article.PrerequisitesWarning'
  @version: -> '0.1.0'

  @register @id()
  template: -> @constructor.id()

  @registerBlot
    name: 'studyguide-prerequisiteswarning'
    tag: 'div'
    class: 'pixelartacademy-studyguide-article-prerequisiteswarning'
