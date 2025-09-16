AB = Artificial.Babel
AM = Artificial.Mummification
AR = Artificial.Reality
LOI = LandsOfIllusions
PAA = PixelArtAcademy

_currentAxis = new THREE.Vector3

class PAA.Tutorials.Drawing.Simplification.Silhouette.RotateStep extends PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap.Step
  constructor: ->
    super arguments...
    
    @goalAxis = new THREE.Vector3().setFromSphericalCoords 1, @options.goalRotation.polarAngle, @options.goalRotation.azimuthalAngle
    @goalCosineTolerance = Math.cos AR.Degrees 30
      
  completed: ->
    return unless super arguments...
    return unless stepAreaData = @stepArea.data()
    return unless referenceData = @tutorialBitmap.getReferenceDataForUrl stepAreaData.referenceUrl

    camera = referenceData.displayOptions.camera
    
    _currentAxis.setFromSphericalCoords 1, camera.polarAngle or 0, camera.azimuthalAngle or 0
    
    # Cosine difference is the better the closest to 1 it is.
    cosineDifference = Math.abs @goalAxis.dot _currentAxis
    cosineDifference >= @goalCosineTolerance

  solve: ->
    stepAreaData = @stepArea.data()
    
    asset = @tutorialBitmap.getAssetData()
    reference = _.find asset.references, (reference) -> reference.url is stepAreaData.referenceUrl

    # Replace the layer pixels in this bitmap.
    updateReferenceAction = new LOI.Assets.VisualAsset.Actions.UpdateReference @tutorialBitmap.id(), bitmap, reference.image._id,
      displayOptions:
        camera:
          azimuthalAngle: 0
          polarAngle: 0
        
    AM.Document.Versioning.executeAction bitmap, bitmap.lastEditTime, updateReferenceAction, new Date
