import moduleJson from './module.json';
import { dialog, BrowserWindow } from 'electron';
import fs from "fs";

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
export default class Hyperlink {
  constructor({log, skeletonApp, appSettings, eventsBus, modules, settings, Module}) {
    this.module = new Module(moduleJson.name);

    // Get the automatically predefined logger instance.
    this.log = log;
    this.eventsBus = eventsBus;

    this.module.on('saveAs', async (event, fetchId, fileData, options) => {
      this.log.verbose('save as received');

      if (fileData instanceof ArrayBuffer) {
        fileData = Buffer.from(fileData);
      }

      // Display the Save As dialog.
      try {
        const window = BrowserWindow.getFocusedWindow();

        // Await the result of the save dialog.
        const result = await dialog.showSaveDialog(window, options);

        if (!result.canceled && result.filePath) {
          console.log('File will be saved to:', result.filePath);

          fs.writeFile(result.filePath, fileData, error => {
            this.module.respond('saveAs', fetchId, true);
          });
        } else {
          this.module.respond('saveAs', fetchId, false);
        }
      } catch (error) {
        this.log.error(error);
        this.module.respond('saveAs', fetchId, error);
      }
   });
  }
}
