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
    'studyguide-practicesection'
    'studyguide-prerequisiteswarning'
    'studyguide-task-reading'
    'studyguide-task-upload'
  ]

  @figureUploadContext = new LOI.Assets.Upload.Context
    name: "PixelArtAcademy.StudyGuide.Article.figure"
    folder: 'studyguide'
    maxSize: 50 * 1024 * 1024 # 50 MB
    fileTypes: LOI.Assets.Upload.Context.FileTypes.Images
    cacheControl: LOI.Assets.Upload.Context.CacheControl.RequireRevalidation
