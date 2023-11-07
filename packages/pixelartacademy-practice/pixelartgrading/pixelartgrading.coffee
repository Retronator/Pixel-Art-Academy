PAA = PixelArtAcademy

class PAA.Practice.PixelArtGrading
  @Criteria =
    PixelPerfectDiagonals: 'PixelPerfectDiagonals'
    SmoothCurves: 'SmoothCurves'
    ConsistentLineWidth: 'ConsistentLineWidth'
    
  @getLetterGrade = (grade) ->
    grade10 = grade * 10
    
    letterBracket = Math.min 9, Math.floor grade10
    letterBracket = 4 if letterBracket < 6
    
    letterGrade = String.fromCharCode(65 + 9 - letterBracket)
    
    if letterBracket > 4
      gradeRemainder100 = Math.round (grade10 - letterBracket) * 10
      
      letterGrade += '-' if gradeRemainder100 < 3
      letterGrade += '+' if gradeRemainder100 >= 7
    
    letterGrade
