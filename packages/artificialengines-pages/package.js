Package.describe({
  name: 'retronator:artificialengines-pages',
  version: '1.0.0'
});

Npm.depends({
  'archiver': '3.0.0'
});

Package.onUse(function(api) {
  api.use('retronator:artificialengines');
  api.use('retronator:retronator');
  api.use('retronator:retronator-accounts');

  api.use('jparker:crypto-aes');

  api.use('webapp');

  api.export('Artificial');

  api.addFile('pages');

  api.addFile('layouts..');
  api.addComponent('layouts/publicaccess..');

  api.addFile('babel/pages');
  api.addUnstyledComponent('babel/admin..');
  api.addUnstyledComponent('babel/admin/scripts..');
  api.addServerFile('babel/admin/scripts/methods-server/generatebesttranslations');

  api.addFile('mummification/pages');
  api.addUnstyledComponent('mummification/admin..');
  api.addUnstyledComponent('mummification/admin/databasecontent..');
  api.addServerFile('mummification/admin/databasecontent/server');

  api.addFile('pyramid/pages');
  api.addComponent('pyramid/interpolation..');

  api.addFile('reality/pages');

  api.addFile('reality/chemistry..');

  api.addComponent('reality/chemistry/materials..');
  api.addFile('reality/chemistry/materials/materials-propertiesgraph');
  api.addFile('reality/chemistry/materials/materials-reflectancegraph');
  api.addFile('reality/chemistry/materials/materials-reflectancepreview');
  api.addFile('reality/chemistry/materials/materials-dispersionpreview');

  api.addComponent('reality/chemistry/gases..');
  api.addFile('reality/chemistry/gases/gases-measurements');
  api.addFile('reality/chemistry/gases/gases-propertiesgraph');
  api.addFile('reality/chemistry/gases/gases-spectrumgraph');

  api.addFile('reality/optics..');

  api.addComponent('reality/optics/scattering..');
  api.addFile('reality/optics/scattering/scattering-rayleighcells');
  api.addFile('reality/optics/scattering/scattering-rayleighcellsanimated');
  api.addFile('reality/optics/scattering/scattering-rayleighcellsinscatteringanimated');
  api.addFile('reality/optics/scattering/scattering-rayleighsingle');
  api.addFile('reality/optics/scattering/scattering-rayleighsingleanimated');

  api.addComponent('reality/optics/sky..');
  api.addFile('reality/optics/sky/sky-computepreviewdata');
  api.addFile('reality/optics/sky/sky-computenishita');
  api.addFile('reality/optics/sky/sky-computeformulated');
  api.addFile('reality/optics/sky/sky-computeformulated-xyz');
  api.addFile('reality/optics/sky/sky-computeformulated-rgb');
  api.addFile('reality/optics/sky/sky-drawpreviewelements');
  api.addFile('reality/optics/sky/sky-drawpreviews');

  api.addFile('spectrum/pages');
  api.addFile('spectrum/color..');
  api.addComponent('spectrum/color/chromaticity..');
  api.addFile('spectrum/color/chromaticity/chromaticity-spectrum');
  api.addFile('spectrum/color/chromaticity/chromaticity-chromaticitydiagram');
});
