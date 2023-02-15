Tinytest.add('peerdb - defined', function (test) {
  var isDefined = false;
  try {
    Document;
    isDefined = true;
  }
  catch (e) {
  }
  test.isTrue(isDefined, "Document is not defined");
  test.isTrue(Package['retronator:peerdb'].Document, "Package.retronator:peerdb.Document is not defined");
});
