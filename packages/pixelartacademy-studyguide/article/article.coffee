LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.StudyGuide.Article
  @quillFormats: [
    'bold'
    'italic'
    'strike'
    'underline'
    'script'
    'link'
    'code'
    'blockquote'
    'header'
    'list'
    'code-block'
    'image'
    'video'

    'figure'
    'practice-section'
    'studyguide-task-reading'
  ]

  @figureUploadContext = new LOI.Assets.Upload.Context
    name: "PixelArtAcademy.StudyGuide.Article.figure"
    folder: 'studyguide'
    maxSize: 50 * 1024 * 1024 # 50 MB
    fileTypes: [
      'image/png'
      'image/jpeg'
      'image/gif'
    ]
    cacheControl: LOI.Assets.Upload.Context.CacheControl.RequireRevalidation
