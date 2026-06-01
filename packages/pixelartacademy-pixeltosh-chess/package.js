Package.describe({
  name: 'retronator:pixelartacademy-pixeltosh-chess',
  version: '0.1.0',
  // Brief, one-line summary of the package.
  summary: '',
  // URL to the Git repository containing the source code for this package.
  git: '',
  // By default, Meteor will default to using README.md for documentation.
  // To avoid submitting documentation, set this field to null.
  documentation: 'README.md'
});

Npm.depends({
  'js-chess-engine': '2.4.6'
});

Package.onUse(function(api) {
  api.use('retronator:fatamorgana');
  api.use('retronator:pixelartacademy');
  api.use('retronator:pixelartacademy-learnmode');
  api.use('retronator:pixelartacademy-pixeltosh');
  api.use('retronator:pixelartacademy-practice');

  api.export('PixelArtAcademy');

  api.addFile('chess');
  api.addFile('assets..');
  api.addUnstyledComponent('assets/briefcomponent..');
  api.addFile('project');
  api.addFile('project-startend');
  api.addFile('square');
  api.addFile('move');
  api.addFile('piece');
  api.addFile('gamestate');
  api.addFile('gamestate-moves');

  api.addFile('interfacemanager');
  api.addFile('gamemanager');
  api.addFile('lessonmanager');

  api.addStyledFile('interface..');
  api.addComponent('interface/chessboard..');
  api.addFile('interface/chessboard/chessboard-animation');
  api.addFile('interface/chessboard/chessboard-dragging');
  api.addComponent('interface/chessboard/square..');
  api.addComponent('interface/chessboard/piece..');
  api.addComponent('interface/chessboard/markup..');
  api.addComponent('interface/chessboard/promotion..');
  api.addComponent('interface/intro..');
  api.addComponent('interface/playerstatus..');
  api.addComponent('interface/lessons..');
  api.addComponent('interface/lesson..');
  api.addComponent('interface/playstart..');
  api.addComponent('interface/play..');
  api.addComponent('interface/play/playercard..');
  api.addComponent('interface/play/moveshistory..');
  api.addComponent('interface/about..');
  api.addComponent('interface/shop..');

  api.addFile('interface/actions..');
  api.addFile('interface/actions/action');
  api.addFile('interface/actions/about');
  api.addFile('interface/actions/backtomenu');
  api.addFile('interface/actions/displayboardcoordinates');
  api.addFile('interface/actions/flipboard');
  api.addFile('interface/actions/boarddisplaytype');
  api.addFile('interface/actions/autopromotion');

  api.addFile('lesson..');
  api.addFile('lesson/lesson-ai');
  api.addFile('lesson/category');
  api.addFile('lesson/piececategory');
  api.addUnstyledComponent('lesson/steps/step');
  api.addFile('lesson/steps/positionstep');
  api.addUnstyledComponent('lesson/steps/endstep');

  api.addFile('lessons..');
  api.addFile('lessons/pawnmovement');
  api.addFile('lessons/pawndoublestep');
  api.addFile('lessons/pawncapture');
  api.addFile('lessons/stuckpawns');
  api.addFile('lessons/enpassant');
  api.addFile('lessons/pawnsstrongertogether');
  api.addFile('lessons/pawnchains');
  api.addFile('lessons/pawnpromotion');
  api.addFile('lessons/knightmovement');
  api.addFile('lessons/knightscenicroute');
  api.addFile('lessons/knightjumps');
  api.addFile('lessons/knightcapture');
  api.addFile('lessons/knightinpursuit');
  api.addFile('lessons/knightonrim');
  api.addFile('lessons/bishopmovement');
  api.addFile('lessons/blockedbishop');
  api.addFile('lessons/twobishopstwocolors');
  api.addFile('lessons/bishopcapture');
  api.addFile('lessons/rookmovement');
  api.addFile('lessons/rookcapture');
  api.addFile('lessons/blockedrook');
  api.addFile('lessons/openingthefile');
  api.addFile('lessons/rooknevertires');
  api.addFile('lessons/queenmovement');
  api.addFile('lessons/queencapture');
  api.addFile('lessons/respectthequeen');
  api.addFile('lessons/kingmovement');
  api.addFile('lessons/check');
  api.addFile('lessons/kingdanger');
  api.addFile('lessons/capturingattacker');
  api.addFile('lessons/blockingcheck');
  api.addFile('lessons/checkmate');
  api.addFile('lessons/stalemate');
  api.addFile('lessons/castling');
  api.addFile('lessons/kingscanttouch');
  api.addFile('lessons/kingjoinsfight');
  api.addFile('lessons/categories..');
  api.addFile('lessons/categories/pawn');
  api.addFile('lessons/categories/knight');
  api.addFile('lessons/categories/bishop');
  api.addFile('lessons/categories/rook');
  api.addFile('lessons/categories/queen');
  api.addFile('lessons/categories/king');
});
