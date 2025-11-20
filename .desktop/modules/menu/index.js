import moduleJson from './module.json';
import {app, Menu, shell} from 'electron';

/**
 * @param {Object} log         - Winston logger instance
 * @param {Object} skeletonApp - reference to the skeleton app instance
 * @param {Object} appSettings - settings.json contents
 * @param {Object} eventsBus   - event emitter for listening or emitting events
 *                               shared across skeleton app and every module/plugin
 * @param {Object} modules     - references to all loaded modules
 * @param {Object} settings    - module settings
 * @param {Object} Module      - reference to the Module class
 * @constructor
 */
export default class ApplicationMenu {
  constructor({log, skeletonApp, appSettings, eventsBus, modules, settings, Module}) {
    this.module = new Module(moduleJson.name);

    // Get the automatically predefined logger instance.
    this.log = log;
    this.eventsBus = eventsBus;

    this.eventsBus.on('desktopLoaded', () => {
      this.start();
    });
  }

  start() {
    const isMac = process.platform === 'darwin';

    const template = [
      ...(isMac ? [{
        label: app.name,
        submenu: [
          { role: 'about' },
          { type: 'separator' },
          { role: 'hide' },
          { role: 'hideOthers' },
          { role: 'unhide' },
          { type: 'separator' },
          { role: 'quit' }
        ]
      }] : [{
        label: 'File',
        submenu: [
          { role: 'quit' }
        ]
      }]),
      {
        label: 'Window',
        submenu: [
          { role: 'minimize' },
          ...(isMac ? [
            { role: 'zoom' },
          ] : []),
          { type: 'separator' },
          { role: 'togglefullscreen' }
        ]
      },
      {
        label: 'Debug',
        submenu: [
          { role: 'reload' },
          { role: 'forceReload' },
          { role: 'toggleDevTools' },
          { type: 'separator'},
          {
            label: 'Report a bug',
            click: async () => {
              await shell.openExternal('mailto:hi@retronator.com?subject=Pixel%20Art%20Academy%3A%20Learn%20Mode%20bug%20report')
            }
          },
          { type: 'separator'},
          {
            label: 'Unlock Pixel art fundamentals',
            click: async () => {
              this.module.send('unlockPixelArtFundamentals');
            }
          },
          {
            label: 'Unlock Pinball',
            click: async () => {
              this.module.send('unlockPinball');
            }
          },
          {
            label: 'Unlock Draw Quickly',
            click: async () => {
              this.module.send('unlockDrawQuickly');
            }
          }
        ]
      },
      {
        role: 'help',
        submenu: [
          {
            label: 'Get help on Discord',
            click: async () => {
              await shell.openExternal('https://discord.gg/mngNfvTwG6')
            }
          }
        ]
      }
    ];

    const menu = Menu.buildFromTemplate(template);
    Menu.setApplicationMenu(menu);
  }
}
