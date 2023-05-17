import moduleJson from './module.json';
import {app} from 'electron';
import fs from 'fs';
import path from 'path';

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
export default class FileSystem {
  constructor({log, skeletonApp, appSettings, eventsBus, modules, settings, Module}) {
    this.module = new Module(moduleJson.name);

    // Get the automatically predefined logger instance.
    this.log = log;
    this.eventsBus = eventsBus;

    this.module.on('getApplicationPaths', (event, fetchId) => {
      this.log.verbose('getApplicationPaths received');
      this.module.respond('getApplicationPaths', fetchId, this.getApplicationPaths());
    });

    this.module.on('writeFile', (event, fetchId, filePath, fileData) => {
      this.log.verbose('writeFile received', filePath);
      fs.writeFile(filePath, fileData, error => {
        if (error?.code === 'ENOENT') {
          const directoryPath = path.dirname(filePath);
          fs.mkdir(directoryPath, error => {
            if (error) {
              this.module.respond('writeFile', fetchId, error)
            } else {
              fs.writeFile(filePath, fileData, error => {
                this.module.respond('writeFile', fetchId, error);
              });
            }
          });
        } else {
          this.module.respond('writeFile', fetchId, error);
        }
      })
    });

    this.module.on('deleteFile', (event, fetchId, filePath) => {
      this.log.verbose('deleteFile received', filePath);
      fs.unlink(filePath, (error) => {
        this.module.respond('deleteFile', fetchId, error);
      })
    });
  }

  getApplicationPaths() {
    let applicationPaths = {};

    const pathVariables = ['home', 'appData', 'userData', 'sessionData', 'temp', 'exe', 'module',
      'desktop', 'documents', 'downloads', 'music', 'pictures', 'videos', 'recent', 'logs', 'crashDumps'];

    for (let pathVariable of pathVariables) {
      try {
        applicationPaths[pathVariable] = app.getPath(pathVariable)
        this.log.verbose("Path for", pathVariable, "is", applicationPaths[pathVariable]);
      }
      catch (e) {
        this.log.verbose("Path for", pathVariable, "is not defined.");
      }
    }

    return applicationPaths;
  }
}
