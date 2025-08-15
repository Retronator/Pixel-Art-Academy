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

    this.operations = []

    this.module.on('writeFile', (event, fetchId, filePath, fileData) => {
      this.log.verbose('writeFile received', filePath, fileData.length, fetchId);
      try {
        JSON.parse(fileData);
      } catch (error) {
        this.log.error('Invalid JSON content');
        this.module.respond('writeFile', fetchId, new Error('Invalid JSON content'));
        return;
      }
      this.addOperation({write: {filePath, fetchId, fileData}});
    });

    this.module.on('deleteFile', (event, fetchId, filePath) => {
      this.log.verbose('deleteFile received', filePath, fetchId);
      this.addOperation({delete: {filePath, fetchId}});
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
        } catch (e) {
          this.log.error("Invalid profile directory", profileId);
        }
      }

      this.module.respond('getProfiles', fetchId, profileJsons);
    });

    this.module.on('getProfileDocuments', async (event, fetchId, rootDirectoryPath, backupDirectoryPath) => {
      try {
        this.log.verbose('getProfileDocuments received', rootDirectoryPath);
        const documentJsons = {};

        const backupTimestamp = new Date().toISOString().replaceAll(':', '-');
        const rootBackupDirectoryPath = path.join(backupDirectoryPath, backupTimestamp);

        // Count number of documents that need to be loaded.
        this.log.verbose('Counting number of documents to be loaded …');
        let totalDocumentsCount = 0;
        let loadedDocumentsCount = 0;

        let rootDirectory = await fs.promises.opendir(rootDirectoryPath);
        for await (const rootDirectoryEntry of rootDirectory) {
          if (!rootDirectoryEntry.isDirectory()) continue;

          const className = rootDirectoryEntry.name;
          const classDirectoryPath = path.join(rootDirectoryPath, className);
          const classDirectory = await fs.promises.opendir(classDirectoryPath);

          for await (const classDirectoryEntry of classDirectory) {
            if (!classDirectoryEntry.isFile()) continue;
            if (!classDirectoryEntry.name.endsWith('json')) continue;
            totalDocumentsCount++;
          }
        }
        this.log.verbose('Documents count:', totalDocumentsCount);

        // Scan the root directory for subdirectories, whose names correspond to class names.
        rootDirectory = await fs.promises.opendir(rootDirectoryPath);
        this.log.verbose('Root directory opened.');

        for await (const rootDirectoryEntry of rootDirectory) {
          this.log.verbose('Processing directory entry', rootDirectoryEntry.name);
          if (!rootDirectoryEntry.isDirectory()) continue;

          const className = rootDirectoryEntry.name;
          documentJsons[className] = []

          // Scan the directory for files, whose names correspond to document IDs.
          const classDirectoryPath = path.join(rootDirectoryPath, className);
          const classBackupDirectoryPath = path.join(rootBackupDirectoryPath, className);

          this.log.verbose('Opening class directory', className);
          const classDirectory = await fs.promises.opendir(classDirectoryPath);
          this.log.verbose('Class directory opened.');

          for await (const classDirectoryEntry of classDirectory) {
            if (!classDirectoryEntry.isFile()) continue;

            // Only parse json files (ignore backups).
            if (!classDirectoryEntry.name.endsWith('json')) continue;

            const filePath = path.join(classDirectoryPath, classDirectoryEntry.name);
            const fileJson = await fs.promises.readFile(filePath, {encoding: 'utf8'})
            documentJsons[className].push(fileJson);

            // Create a backup of the file.
            const backupFilePath = path.join(classBackupDirectoryPath, classDirectoryEntry.name);
            await fs.promises.cp(filePath, backupFilePath);

            loadedDocumentsCount++;
            this.module.send('getProfileDocumentsProgress', loadedDocumentsCount / totalDocumentsCount);
          }
        }

        this.log.verbose('getProfileDocuments processed');
        this.module.respond('getProfileDocuments', fetchId, documentJsons);

      } catch (error) {
        this.log.error('getProfileDocuments encountered an error', error);
        this.module.respond('getProfileDocuments', fetchId, null);
      }
    });

    this.module.on('backupProfile', async (event, fetchId, rootDirectoryPath, backupDirectoryPath) => {
      try {
        this.log.verbose('backupProfile received', rootDirectoryPath);

        const backupTimestamp = new Date().toISOString().replaceAll(':', '-');
        const rootBackupDirectoryPath = path.join(backupDirectoryPath, backupTimestamp);

        // Scan the root directory for subdirectories, whose names correspond to class names.
        let rootDirectory = await fs.promises.opendir(rootDirectoryPath);
        this.log.verbose('Root directory opened.');

        for await (const rootDirectoryEntry of rootDirectory) {
          this.log.verbose('Processing directory entry', rootDirectoryEntry.name);
          if (!rootDirectoryEntry.isDirectory()) continue;

          const className = rootDirectoryEntry.name;

          // Scan the directory for files, whose names correspond to document IDs.
          const classDirectoryPath = path.join(rootDirectoryPath, className);
          const classBackupDirectoryPath = path.join(rootBackupDirectoryPath, className);

          this.log.verbose('Opening class directory', className);
          const classDirectory = await fs.promises.opendir(classDirectoryPath);
          this.log.verbose('Class directory opened.');

          for await (const classDirectoryEntry of classDirectory) {
            if (!classDirectoryEntry.isFile()) continue;

            // Only copy json files (ignore backups).
            if (!classDirectoryEntry.name.endsWith('json')) continue;

            // Create a backup of the file.
            const filePath = path.join(classDirectoryPath, classDirectoryEntry.name);
            const backupFilePath = path.join(classBackupDirectoryPath, classDirectoryEntry.name);
            await fs.promises.cp(filePath, backupFilePath);
          }
        }

        this.log.verbose('backupProfile processed');
        this.module.respond('backupProfile', fetchId, true);

      } catch (error) {
        this.log.error('backupProfile encountered an error', error);
        this.module.respond('backupProfile', fetchId, false);
      }
    });

    this.module.on('removeProfile', async (event, fetchId, rootDirectoryPath) => {
      try {
        this.log.verbose('removeProfile received', rootDirectoryPath);

        // Scan the root directory for subdirectories, whose names correspond to class names.
        await fs.promises.rm(rootDirectoryPath, {recursive: true});
        this.log.verbose('Profile directory removed.');

        this.module.respond('removeProfile', fetchId, true);

      } catch (error) {
        this.log.error('removeProfile encountered an error', error);
        this.module.respond('removeProfile', fetchId, false);
      }
    });
  }

  addOperation(operation) {
    this.operations.push(operation);
    // If we have just this operation waiting to be executed, start the chain of execution.
    if (this.operations.length === 1) {
      this.executeFirstOperation();
    }
  }

  executeFirstOperation() {
    const operation = this.operations[0];
    if (operation.write) {
      this.writeFile(operation.write);
    } else if (operation.delete) {
      this.deleteFile(operation.delete);
    }
  }

  writeFile(writeOperation) {
    const filePath = writeOperation.filePath
    const fetchId = writeOperation.fetchId
    const fileData = writeOperation.fileData

    this.log.verbose("writeFile processing for", filePath, fetchId);

    fs.cp(filePath, `${filePath}.backup`, error => {
      if (error) {
        this.log.verbose("File does not exist yet, backup copy not made.", filePath, fetchId);
      }

      fs.writeFile(filePath, fileData, error => {
        if (error?.code === 'ENOENT') {
          this.log.verbose("Directory path does not exist, creating directories for", filePath);
          const directoryPath = path.dirname(filePath);
          fs.mkdir(directoryPath, {recursive: true}, error => {
            if (error) {
              this.log.error('mkdir error', directoryPath, error);
              this.endWriteFile(filePath, fetchId, error);
            } else {
              this.log.verbose("Directories made, retrying write", filePath);
              fs.writeFile(filePath, fileData, error => {
                this.endWriteFile(filePath, fetchId, error);
              });
            }
          });
        } else {
          this.endWriteFile(filePath, fetchId, error);
        }
      });
    });
  }

  endWriteFile(filePath, fetchId, error) {
    if (error) {
      this.log.error('writeFile error.', filePath, error, fetchId);
    } else {
      this.log.verbose("writeFile succeeded.", filePath, fetchId);
    }
    this.module.respond('writeFile', fetchId, error);
    this.moveToNextOperation();
  }

  deleteFile(deleteOperation) {
    const filePath = deleteOperation.filePath
    const fetchId = deleteOperation.fetchId

    fs.unlink(filePath, (error) => {
      if (error) {
        this.log.error('deleteFile error.', filePath, error, fetchId);
      } else {
        this.log.verbose("deleteFile succeeded.", filePath, fetchId);
      }
      this.module.respond('deleteFile', fetchId, error);
      this.moveToNextOperation();
    })
  }

  moveToNextOperation() {
    // The first operation has been executed, so we can remove it.
    this.operations.shift();

    // Nothing left to do if we've cleared all operations.
    if (this.operations.length === 0) return;

    // Chain to the next operation.
    this.executeFirstOperation();
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
