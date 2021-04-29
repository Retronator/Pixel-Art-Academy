AB = Artificial.Babel
AE = Artificial.Everywhere
LOI = LandsOfIllusions
PAA = PixelArtAcademy

PAA.PixelBoy.Apps.AdmissionWeek.DayView.AppInfo =
  "#{PAA.PixelBoy.Apps.Journal.id()}":
    features: [
      "Reflect on your learning by writing journal entries. This contributes to your commitment goal."
      "Plan your day from a selection of available tasks to reach your goals. The goals are added through the Study Plan app."
    ]
    factors:
      2: -1
      3: 1
      4: -3

  "#{PAA.PixelBoy.Apps.StudyPlan.id()}":
    features: [
      "Discover available learning goals. Track tasks required to achieve those goals."
      "Enables you to add and complete learning tasks in the Journal."
    ]
    factors:
      3: 4
      5: -1

  "#{PAA.PixelBoy.Apps.Calendar.id()}":
    features: [
      "Set weekly drawing commitment goal."
      "Track progress towards your commitment goal."
    ]
    factors:
      3: -2
      4: -2
      5: -1

  "#{PAA.PixelBoy.Apps.Yearbook.id()}":
    features: [
      "Introduce yourself to your classmates."
      "Meet other participants of Admission Week and form a study group."
    ]
    factors:
      1: 3
      2: 2

  "#{PAA.PixelBoy.Apps.Drawing.id()}":
    features: [
      "Learn how to use the basic pixel art drawing tools."
      "Complete your Admission Project."
    ]
    factors:
      1: -3
      2: -2
