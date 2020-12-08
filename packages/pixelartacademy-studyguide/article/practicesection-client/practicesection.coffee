AM = Artificial.Mirage
PAA = PixelArtAcademy

Block = AM.Quill.import 'blots/block'

class PAA.StudyGuide.Article.PracticeSection extends Block
  @blotName: 'practice-section'
  @tagName: 'div'
  @className: 'practice-section'

AM.Quill.register PAA.StudyGuide.Article.PracticeSection
