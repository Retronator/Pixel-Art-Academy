AE = Artificial.Everywhere
AB = Artificial.Base
AM = Artificial.Mirage
AMu = Artificial.Mummification
PAA = PixelArtAcademy
LOI = LandsOfIllusions

Extras = PAA.PixelPad.Apps.Drawing.Portfolio.Forms.Extras

JSZip = require 'jszip'

class PAA.PixelPad.Apps.Drawing.Portfolio.ArtworkAsset.ExportArtwork extends AM.Component
  @register 'PixelArtAcademy.PixelPad.Apps.Drawing.Portfolio.ArtworkAsset.ExportArtwork'
  @initializeDataComponent()
  
  constructor: (@artworkAsset) ->
    super arguments...
    
  onCreated: ->
    super arguments...
    
    @bounds = new ComputedField =>
      return unless document = @artworkAsset.document()
      document.bounds
    
    @originalScale = new ComputedField =>
      return unless bounds = @bounds()
      
      factor: 1
      width: bounds.width
      height: bounds.height
      
    @scaleFactors = new ComputedField =>
      return unless bounds = @bounds()
      
      # Prioritize publishing online where one side has to be at least 1000 pixels.
      minimumPublishingFactor = Math.ceil 1000 / Math.max bounds.width, bounds.height
      publishing = [minimumPublishingFactor]
      
      # Add preview factors from 2 to 5 when they are lower than the minimum publishing factor.
      preview = (factor for factor in [2..5] when factor < minimumPublishingFactor)
      
      # Add wallpaper factors when bigger than the minimum publishing factor.
      longerSide = Math.max bounds.width, bounds.height
      shorterSide = Math.min bounds.width, bounds.height
      
      hdWidthFactor = Math.ceil 1920 / longerSide
      hdHeightFactor = Math.ceil 1080 / shorterSide
      hdFactor = Math.max hdWidthFactor, hdHeightFactor
      
      fiveKWidthFactor = Math.ceil 5120 / longerSide
      fiveKHeightFactor = Math.ceil 2880 / shorterSide
      fiveKFactor = Math.max fiveKWidthFactor, fiveKHeightFactor
      
      wallpaper = []
      wallpaper.push hdFactor if hdFactor > minimumPublishingFactor
      wallpaper.push fiveKFactor if fiveKFactor > minimumPublishingFactor
      
      # Add 5x and 10x where they fit.
      publishing.push 5 if hdFactor > 5 and 5 not in publishing and 5 not in preview
        
      preview.push 10 if minimumPublishingFactor > 10
      publishing.push 10 if hdFactor > 10 and 10 not in publishing and 10 not in preview
      
      {preview, publishing, wallpaper}
      
    @previewScales = new ComputedField => @_createScales @scaleFactors()?.preview
    @publishingScales = new ComputedField => @_createScales @scaleFactors()?.publishing
    @wallpaperScales = new ComputedField =>
      scales = @_createScales @scaleFactors()?.wallpaper

      for scale in scales
        longerSide = Math.max scale.width, scale.height
        scale.factorDescription = if longerSide < 5120 then 'HD' else '5K'
        
      scales
    
  _createScales: (factors) ->
    return unless factors
    return unless bounds = @bounds()
    
    for factor in factors
      factor: factor
      width: bounds.width * factor
      height: bounds.height * factor
    
  events: ->
    super(arguments...).concat
      'submit .export-artwork-form': @onSubmitExportArtworkForm

  onSubmitExportArtworkForm: (event) ->
    event.preventDefault()
    
    # Navigate back to the first page.
    # HACK: We do this at the start since waiting on the Electron save dialog will throw a timeout error.
    @artworkAsset.clipboardComponent.closeSecondPage()
    
    factors = for factorInput in @$('.factor-input:checked')
      parseInt $(factorInput).data('factor')
    
    engineBitmap = new LOI.Assets.Engine.PixelImage.Bitmap
      asset: @artworkAsset.document
      
    sourceCanvas = engineBitmap.getCanvas()
    
    canvases = for factor in factors
      resizedCanvas = new AM.ReadableCanvas sourceCanvas.width * factor, sourceCanvas.height * factor
      resizedCanvas.context.imageSmoothingEnabled = false
      resizedCanvas.context.drawImage sourceCanvas, 0, 0, sourceCanvas.width, sourceCanvas.height, 0, 0, resizedCanvas.width, resizedCanvas.height
      resizedCanvas._factor = factor
      resizedCanvas
    
    artwork = @artworkAsset.artwork()
    name = artwork.title or "untitled"
    
    blobPromises = for canvas in canvases
      do (canvas) =>
        new Promise (resolve, reject) =>
          canvas.toBlob (blob) =>
            resolve
              blob: blob
              fileName: "#{name} x#{canvas._factor}.png"
    
    blobs = await Promise.all blobPromises
    
    if blobs.length is 1
      # Download the single png directly.
      fileBlob = blobs[0].blob
      filename = blobs[0].fileName
      
    else
      # Create a ZIP file with all the images.
      zip = new JSZip
      zip.file blob.fileName, blob.blob for blob in blobs
      
      # Generate the zip file blob.
      fileBlob = await zip.generateAsync type: 'blob'
      filename = "#{name}.zip"

    switch AB.ApplicationEnvironment.type
      when AB.ApplicationEnvironment.Types.Browser
        $link = $('<a style="display: none">')
        $('body').append $link

        link = $link[0]
        link.href = URL.createObjectURL fileBlob
        link.download = filename
        link.click()

        $link.remove()
        
      when AB.ApplicationEnvironment.Types.Electron
        arrayBuffer = await fileBlob.arrayBuffer()
      
        result = await Desktop.call 'dialogs', 'saveAs', arrayBuffer,
          title: 'Save Artwork'
          defaultPath: filename
          buttonLabel: 'Save'
      
        throw new AE.ExternalException "Saving failed.", filename, result if result and result isnt true
