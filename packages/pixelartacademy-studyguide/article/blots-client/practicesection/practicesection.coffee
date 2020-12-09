AM = Artificial.Mirage
PAA = PixelArtAcademy

Block = AM.Quill.import 'blots/block'

class PAA.StudyGuide.Article.PracticeSection extends Block
  @blotName: 'studyguide-practicesection'
  @tagName: 'div'
  @className: 'practicesection'

AM.Quill.register PAA.StudyGuide.Article.PracticeSection
