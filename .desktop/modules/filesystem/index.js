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

    this.writeOperationsByFilePath = {}

    this.module.on('writeFile', (event, fetchId, filePath, fileData) => {
      this.log.verbose('writeFile received', filePath);
      this.writeOperationsByFilePath[filePath] ??= []
      this.writeOperationsByFilePath[filePath].push({fetchId, fileData});
      // If we have just this file waiting to be written, start the write chain of operations.
      if (this.writeOperationsByFilePath[filePath].length === 1) {
        this.writeFirstFile(filePath);
      }
    });

    this.module.on('deleteFile', (event, fetchId, filePath) => {
      this.log.verbose('deleteFile received', filePath);
      fs.unlink(filePath, (error) => {
        this.module.respond('deleteFile', fetchId, error);
      })
    });

    this.module.on('getProfiles', async (event, fetchId, directoryPath) => {
      this.log.verbose('getProfiles received', directoryPath);
      const profileJsons = [];

      // Scan the directory for subdirectories, whose names correspond to profile IDs.
      const directory = await fs.promises.opendir(directoryPath);
      for await (const directoryEntry of directory) {
        if (!directoryEntry.isDirectory()) continue;

        const profileId = directoryEntry.name;

        // Read the profile document.
        const profileDocumentPath = path.join(directoryPath, profileId, `Artificial.Mummification.Document.Persistence.Profile/${profileId}.json`);

        try {
          const profileJson = await fs.promises.readFile(profileDocumentPath, {encoding: 'utf8'})
          profileJsons.push(profileJson);
          this.log.verbose("Found profile directory", profileId);
        }
        catch (e) {
          this.log.error("Invalid profile directory", profileId);
        }
      }

      this.module.respond('getProfiles', fetchId, profileJsons);
    });

    this.module.on('getProfileDocuments', async (event, fetchId, rootDirectoryPath) => {
      this.log.verbose('getProfileDocuments received', rootDirectoryPath);
      const documentJsons = {};

      // Scan the root directory for subdirectories, whose names correspond to class names.
      const rootDirectory = await fs.promises.opendir(rootDirectoryPath);
      for await (const rootDirectoryEntry of rootDirectory) {
        if (!rootDirectoryEntry.isDirectory()) continue;

        const className = rootDirectoryEntry.name;
        documentJsons[className] = []

        // Scan the directory for files, whose names correspond to document IDs.
        const classDirectoryPath = path.join(rootDirectoryPath, className);
        const classDirectory = await fs.promises.opendir(classDirectoryPath);
        for await (const classDirectoryEntry of classDirectory) {
          if (!classDirectoryEntry.isFile()) continue;

          const filePath = path.join(classDirectoryPath, classDirectoryEntry.name);
          const fileJson = await fs.promises.readFile(filePath, {encoding: 'utf8'})
          documentJsons[className].push(fileJson);
        }
      }

      this.module.respond('getProfileDocuments', fetchId, documentJsons);
    });
  }

  writeFirstFile(filePath) {
    let firstWriteOperation = this.writeOperationsByFilePath[filePath][0]
    let fetchId = firstWriteOperation.fetchId
    let fileData = firstWriteOperation.fileData

    fs.writeFile(filePath, fileData, error => {
      if (error?.code === 'ENOENT') {
        const directoryPath = path.dirname(filePath);
        fs.mkdir(directoryPath, {recursive: true}, error => {
          if (error) {
            this.endWriteFile(filePath, fetchId, error);
          } else {
            fs.writeFile(filePath, fileData, error => {
              this.endWriteFile(filePath, fetchId, error);
            });
          }
        });
      } else {
        this.endWriteFile(filePath, fetchId, error);
      }
    })
  }

  endWriteFile(filePath, fetchId, error) {
    this.module.respond('writeFile', fetchId, error);
    this.moveToNextFile(filePath);
  }

  moveToNextFile(filePath) {
    // The first file has been written to, so we can remove it.
    this.writeOperationsByFilePath[filePath].shift();

    // Nothing left to do if we've cleared all operations for this file.
    if (this.writeOperationsByFilePath[filePath].length === 0) return;

    // Chain to the next operation on this file.
    this.writeFirstFile(filePath);
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