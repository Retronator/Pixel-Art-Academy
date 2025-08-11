AM = Artificial.Mirage

Block = AM.Quill.import 'blots/block'

class AM.Quill.Small extends Block
  @blotName: 'small'
  @tagName: 'small'

AM.Quill.register AM.Quill.Small

icons = AM.Quill.import 'ui/icons'
icons['small'] = """
<svg viewBox="-128 -128 768 768"><g><polygon class="ql-fill ql-stroke" points="501.539,169.221 453.886,86.7 303.669,
  173.449 303.669,0 208.365,0 208.365,173.479 58.114,86.73 10.461,169.261 160.674,255.99 10.501,342.71 58.154,
  425.231 208.365,338.482 208.365,512 303.669,512 303.669,338.542 453.846,425.271 501.499,342.74 351.267,255.99"/></g></svg>
"""
