import moduleJson from './module.json';
import {app} from 'electron';
import fs from 'fs/promises';
import JSZip from 'jszip';
import path from 'path';

const profileClassName = 'Artificial.Mummification.Document.Persistence.Profile';
const classArchiveFileName = 'archive.zip';

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

    // Unordered methods (executed asap, return order will not necessarily be the same as the call order)

    this.module.on('getApplicationPaths', (event, fetchId) => {
      this.log.verbose('getApplicationPaths received', fetchId);
      this.module.respond('getApplicationPaths', fetchId, this.getApplicationPaths());
    });

    this.module.on('initializeProfileBackups', async (event, fetchId, backupDirectoryPath, backupDaysCount) => {
      this.log.verbose('initializeProfileBackups received', backupDirectoryPath, backupDaysCount, fetchId);
      this.initializeProfileBackups(backupDirectoryPath, backupDaysCount, fetchId);
    });

    // Ordered methods (executed and returned in order of calls)

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
      this.log.verbose('getProfiles received', directoryPath, fetchId);
      this.addOperation({getProfiles: {directoryPath, fetchId}});
    });

    this.module.on('getProfileDocuments', async (event, fetchId, rootDirectoryPath, backupDirectoryPath) => {
      this.log.verbose('getProfileDocuments received', rootDirectoryPath, backupDirectoryPath, fetchId);
      this.addOperation({getProfileDocuments: {rootDirectoryPath, backupDirectoryPath, fetchId}});
    });

    this.module.on('backupProfile', async (event, fetchId, rootDirectoryPath, backupDirectoryPath) => {
      this.log.verbose('backupProfile received', rootDirectoryPath, backupDirectoryPath, fetchId);
      this.addOperation({backupProfile: {rootDirectoryPath, backupDirectoryPath, fetchId}});
    });

    this.module.on('removeProfile', async (event, fetchId, rootDirectoryPath) => {
      this.log.verbose('removeProfile received', rootDirectoryPath, fetchId);
      this.addOperation({removeProfile: {rootDirectoryPath, fetchId}});
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

      } catch (e) {
        this.log.verbose("Path for", pathVariable, "is not defined.");
      }
    }

    return applicationPaths;
  }

  async initializeProfileBackups(backupDirectoryPath, backupDaysCount, fetchId) {
    try {
      try {
        await fs.access(backupDirectoryPath);

      } catch (error) {
        if (error.code !== 'ENOENT') throw error;

        this.log.verbose('Backup directory does not exist.', backupDirectoryPath, fetchId);
        this.module.respond('initializeProfileBackups', fetchId, true);
        return;
      }

      const backupDirectory = await fs.opendir(backupDirectoryPath);
      for await (const profileDirectoryEntry of backupDirectory) {
        if (!profileDirectoryEntry.isDirectory()) continue;

        const profileBackupDirectoryPath = path.join(backupDirectoryPath, profileDirectoryEntry.name);
        await this.compressBackupFoldersInProfileDirectory(profileBackupDirectoryPath, backupDaysCount);
      }

      this.log.verbose('initializeProfileBackups succeeded.', backupDirectoryPath, fetchId);
      this.module.respond('initializeProfileBackups', fetchId, true);

    } catch (error) {
      this.log.error('initializeProfileBackups error.', backupDirectoryPath, error, fetchId);
      this.module.respond('initializeProfileBackups', fetchId, false);
    }
  }

  async compressBackupFoldersInProfileDirectory(profileBackupDirectoryPath, backupDaysCount) {
    this.log.verbose('Compressing backup folders in profile backup directory', profileBackupDirectoryPath);

    const retainedBackupDayNames = await this.getRetainedBackupDayNames(profileBackupDirectoryPath, backupDaysCount);

    const profileBackupDirectory = await fs.opendir(profileBackupDirectoryPath);
    for await (const backupDirectoryEntry of profileBackupDirectory) {
      const backupEntryDayName = this.getBackupEntryDayName(backupDirectoryEntry.name);
      const backupEntryPath = path.join(profileBackupDirectoryPath, backupDirectoryEntry.name);

      if (!retainedBackupDayNames.has(backupEntryDayName)) {
        this.log.verbose('Removing old backup entry', backupEntryPath);
        await fs.rm(backupEntryPath, {recursive: true});
        continue;
      }

      if (backupDirectoryEntry.isDirectory()) {
        const destinationBackupZipFilePath = path.join(profileBackupDirectoryPath, `${backupDirectoryEntry.name}.zip`);
        await this.compressBackupFolder(backupEntryPath, destinationBackupZipFilePath);
      }
    }
  }

  async getRetainedBackupDayNames(profileBackupDirectoryPath, backupDaysCount) {
    const backupDayNames = new Set();
    const profileBackupDirectory = await fs.opendir(profileBackupDirectoryPath);

    for await (const backupDirectoryEntry of profileBackupDirectory) {
      const backupEntryDayName = this.getBackupEntryDayName(backupDirectoryEntry.name);
      if (!backupEntryDayName) continue;

      backupDayNames.add(backupEntryDayName);
    }

    return new Set([...backupDayNames].sort().reverse().slice(0, backupDaysCount));
  }

  getBackupEntryDayName(backupEntryName) {
    const timestampSeparatorIndex = backupEntryName.indexOf('T');
    if (timestampSeparatorIndex === -1) return null;

    return backupEntryName.substring(0, timestampSeparatorIndex);
  }

  async compressBackupFolder(sourceBackupDirectoryPath, destinationBackupZipFilePath) {
    this.log.verbose('Compressing backup folder', sourceBackupDirectoryPath);

    const backupZip = new JSZip();

    // Add folder contents relative to the timestamp folder, matching the layout of new backup zips.
    await this.addDirectoryToZip(backupZip, sourceBackupDirectoryPath, '');

    const backupZipData = await backupZip.generateAsync({type: 'nodebuffer', compression: 'DEFLATE'});
    await this.writeFileAtomically(destinationBackupZipFilePath, backupZipData);
    await fs.rm(sourceBackupDirectoryPath, {recursive: true});
  }

  async addDirectoryToZip(zip, directoryPath, zipDirectoryPath) {
    const directory = await fs.opendir(directoryPath);

    for await (const directoryEntry of directory) {
      const entryFilePath = path.join(directoryPath, directoryEntry.name);
      const entryZipPath = zipDirectoryPath ? `${zipDirectoryPath}/${directoryEntry.name}` : directoryEntry.name;

      if (directoryEntry.isDirectory()) {
        await this.addDirectoryToZip(zip, entryFilePath, entryZipPath);

      } else if (directoryEntry.isFile()) {
        const entryData = await fs.readFile(entryFilePath);
        zip.file(entryZipPath, entryData);
      }
    }
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

    // We kick off the asynchronous operations, but we don't have to await
    // for them since the handler doesn't do anything with the result.
    if (operation.write) {
      this.writeFile(operation.write);

    } else if (operation.delete) {
      this.deleteFile(operation.delete);

    } else if (operation.getProfiles) {
      this.getProfiles(operation.getProfiles);

    } else if (operation.getProfileDocuments) {
      this.getProfileDocuments(operation.getProfileDocuments);

    } else if (operation.removeProfile) {
      this.removeProfile(operation.removeProfile);

    } else if (operation.backupProfile) {
      this.backupProfile(operation.backupProfile);
    }
  }

  async writeFile(writeOperation) {
    const { filePath, fetchId, fileData } = writeOperation;

    this.log.verbose("writeFile processing for", filePath, fetchId);

    const directoryPath = path.dirname(filePath);
    const backupPath = `${filePath}.backup`;

    try {
      // Create directory if needed.
      await fs.mkdir(directoryPath, { recursive: true });

      // Backup the file if it exists.
      try {
        await fs.copyFile(filePath, backupPath);
      } catch {
        this.log.verbose("File does not exist yet, backup copy not made.", filePath, fetchId);
      }

      // Write to temporary file and rename it.
      await this.writeFileAtomically(filePath, fileData);

      // We are done.
      this.endWriteFile(filePath, fetchId, null);

    } catch (error) {
      // Report error.
      this.endWriteFile(filePath, fetchId, error);
    }
  }

  async writeFileAtomically(filePath, fileData) {
    const temporaryPath = `${filePath}.tmp`;

    try {
      const handle = await fs.open(temporaryPath, "w");

      try {
        await handle.writeFile(fileData);
        await handle.sync();

      } finally {
        await handle.close();
      }

      await fs.rename(temporaryPath, filePath);

    } catch (error) {
      try {
        await fs.unlink(temporaryPath);
      } catch {}

      throw error;
    }
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

  async deleteFile(deleteOperation) {
    const { filePath, fetchId } = deleteOperation;

    this.log.verbose("deleteFile processing for", filePath, fetchId);

    try {
      const classDirectoryPath = path.dirname(filePath);
      const className = path.basename(classDirectoryPath);
      const fileName = path.basename(filePath);

      // Remove the JSON file if it exists.
      try {
        await fs.unlink(filePath);

      } catch (error) {
        if (error.code !== "ENOENT") throw error;
      }

      // Remove an entry from the archive as well.
      if (className !== profileClassName) {
        await this.deleteFileFromClassArchive(className, classDirectoryPath, fileName);
      }

      this.log.verbose("deleteFile succeeded.", filePath, fetchId);
      this.module.respond("deleteFile", fetchId, null);

    } catch (error) {
      this.log.error("deleteFile error.", filePath, error, fetchId);
      this.module.respond("deleteFile", fetchId, error);

    } finally {
      this.moveToNextOperation();
    }
  }

  async deleteFileFromClassArchive(className, classDirectoryPath, fileName) {
    const classArchiveFilePath = path.join(classDirectoryPath, classArchiveFileName);

    try {
      const classArchiveData = await fs.readFile(classArchiveFilePath);
      const classArchiveZip = await JSZip.loadAsync(classArchiveData);

      // Missing archived files are already deleted.
      if (!classArchiveZip.file(fileName)) return;

      classArchiveZip.remove(fileName);

      const updatedClassArchiveData = await classArchiveZip.generateAsync({type: 'nodebuffer', compression: 'DEFLATE'});
      await this.writeFileAtomically(classArchiveFilePath, updatedClassArchiveData);

    } catch (error) {
      if (error.code === "ENOENT") {
        this.log.verbose('Class archive does not exist for delete.', className, classArchiveFilePath);
        return;
      }

      throw error;
    }
  }

  async getProfiles(getProfilesOperation) {
    const { directoryPath, fetchId } = getProfilesOperation;

    this.log.verbose('getProfiles processing for', directoryPath, fetchId);

    try {
      const profileJsons = [];

      // See if the directory has been created (it won't be before first save).
      try {
        await fs.access(directoryPath)

      } catch {
        this.log.verbose("Profile directory does not exist.", directoryPath, fetchId);
        this.module.respond('getProfiles', fetchId, []);
        return;
      }

      // Scan the directory for subdirectories, whose names correspond to profile IDs.
      const directory = await fs.opendir(directoryPath);
      for await (const directoryEntry of directory) {
        if (!directoryEntry.isDirectory()) continue;

        const profileId = directoryEntry.name;

        // Read the profile document.
        const profileDocumentPath = path.join(directoryPath, profileId, profileClassName, `${profileId}.json`);

        try {
          const profileJson = await fs.readFile(profileDocumentPath, {encoding: 'utf8'})
          profileJsons.push(profileJson);
          this.log.verbose("Found profile directory", profileId);

        } catch (e) {
          this.log.error("Invalid profile directory", profileId);
        }
      }

      this.log.verbose("getProfiles succeeded.", directoryPath, fetchId);
      this.module.respond('getProfiles', fetchId, profileJsons);

    } catch (error) {
      this.log.error('getProfiles error.', directoryPath, error, fetchId);
      this.module.respond('getProfiles', fetchId, []);

    } finally {
      this.moveToNextOperation();
    }
  }

  async getProfileDocuments(getProfileDocumentsOperation) {
    const { rootDirectoryPath, backupDirectoryPath, fetchId } = getProfileDocumentsOperation;

    this.log.verbose('getProfileDocuments processing for', rootDirectoryPath, backupDirectoryPath, fetchId);

    try {
      const documentJsons = {};
      const classDocumentCatalogs = [];

      const backupTimestamp = new Date().toISOString().replaceAll(':', '-');
      const backupZip = new JSZip();
      const backupZipFilePath = path.join(backupDirectoryPath, `${backupTimestamp}.zip`);

      // Create a catalog of documents that need to be loaded. JSON files override the archived versions.
      this.log.verbose('Cataloging save folder …');
      let totalDocumentsCount = 0;
      let loadedDocumentsCount = 0;
      let reportedProgress = 0;

      const rootDirectory = await fs.opendir(rootDirectoryPath);
      for await (const rootDirectoryEntry of rootDirectory) {
        if (!rootDirectoryEntry.isDirectory()) continue;

        const className = rootDirectoryEntry.name;
        const classDirectoryPath = path.join(rootDirectoryPath, className);
        const classDocumentCatalog = await this.createClassDocumentCatalog(className, classDirectoryPath);

        classDocumentCatalogs.push(classDocumentCatalog);
        totalDocumentsCount += classDocumentCatalog.documentEntries.length;
      }
      this.log.verbose('Number of documents to be loaded count:', totalDocumentsCount);

      for (const classDocumentCatalog of classDocumentCatalogs) {
        const {className, classArchiveZip, documentEntries} = classDocumentCatalog;
        documentJsons[className] = {}

        for (const documentEntry of documentEntries) {
          const fileJson = await this.readDocumentJson(documentEntry);
          documentJsons[className][documentEntry.fileName] = fileJson;

          // Add each file to the backup as it is read from the original save location.
          backupZip.file(`${className}/${documentEntry.fileName}`, fileJson);

          // Merge JSON files into the class archive so they can be removed after a successful archive write.
          classArchiveZip?.file(documentEntry.fileName, fileJson);

          loadedDocumentsCount++;
          const progress = totalDocumentsCount ? loadedDocumentsCount / totalDocumentsCount : 1;

          if (progress >= reportedProgress + 0.01 || progress === 1) {
            this.module.send('getProfileDocumentsProgress', progress);
            reportedProgress = progress;
          }
        }

        await this.updateClassArchive(classDocumentCatalog);
      }

      this.log.verbose('Writing backup zip.', backupZipFilePath);

      await fs.mkdir(backupDirectoryPath, { recursive: true });
      const backupZipData = await backupZip.generateAsync({type: 'nodebuffer', compression: 'DEFLATE'});
      await fs.writeFile(backupZipFilePath, backupZipData);

      this.log.verbose('getProfileDocuments succeeded.', rootDirectoryPath, backupDirectoryPath, fetchId);
      this.module.respond('getProfileDocuments', fetchId, documentJsons);

    } catch (error) {
      this.log.error('getProfileDocuments error.', rootDirectoryPath, backupDirectoryPath, error, fetchId);
      this.module.respond('getProfileDocuments', fetchId, null);

    } finally {
      this.moveToNextOperation();
    }
  }

  async createClassDocumentCatalog(className, classDirectoryPath) {
    this.log.verbose('Creating document catalog for class', className);

    const classArchiveZip = await this.loadClassArchive(className, classDirectoryPath);
    const documentEntriesByFileName = {};
    const jsonEntries = [];

    if (classArchiveZip) {
      for (const [fileName, archivedFile] of Object.entries(classArchiveZip.files)) {
        if (archivedFile.dir) continue;
        if (!fileName.endsWith('json')) continue;

        documentEntriesByFileName[fileName] = {
          fileName,
          archivedFile,
          source: 'archive'
        };
      }
    }

    const classDirectory = await fs.opendir(classDirectoryPath);
    for await (const classDirectoryEntry of classDirectory) {
      if (!classDirectoryEntry.isFile()) continue;
      if (!classDirectoryEntry.name.endsWith('json')) continue;

      const filePath = path.join(classDirectoryPath, classDirectoryEntry.name);
      const documentEntry = {
        fileName: classDirectoryEntry.name,
        filePath,
        source: 'file'
      };

      documentEntriesByFileName[classDirectoryEntry.name] = documentEntry;
      jsonEntries.push(documentEntry);
    }

    return {
      className,
      classDirectoryPath,
      classArchiveZip,
      documentEntries: Object.values(documentEntriesByFileName),
      jsonEntries
    };
  }

  async loadClassArchive(className, classDirectoryPath) {
    if (className === profileClassName) return null;

    const classArchiveFilePath = path.join(classDirectoryPath, classArchiveFileName);

    try {
      this.log.verbose('Reading class archive for', className);

      const classArchiveData = await fs.readFile(classArchiveFilePath);
      return await JSZip.loadAsync(classArchiveData);

    } catch (error) {
      if (error.code === 'ENOENT') {
        this.log.verbose('Class archive does not exist yet.');
        return new JSZip();
      }

      throw error;
    }
  }

  async readDocumentJson(documentEntry) {
    if (documentEntry.source === 'archive') {
      return await documentEntry.archivedFile.async('string');
    }

    return await fs.readFile(documentEntry.filePath, {encoding: 'utf8'});
  }

  async updateClassArchive(classDocumentCatalog) {
    const {className, classDirectoryPath, classArchiveZip, jsonEntries} = classDocumentCatalog;
    if (!classArchiveZip) return;
    if (!jsonEntries.length) return;

    const classArchiveFilePath = path.join(classDirectoryPath, classArchiveFileName);
    this.log.verbose('Writing class archive for', className);

    const classArchiveData = await classArchiveZip.generateAsync({type: 'nodebuffer', compression: 'DEFLATE'});
    await this.writeFileAtomically(classArchiveFilePath, classArchiveData);

    for (const documentEntry of jsonEntries) {
      await fs.unlink(documentEntry.filePath);
    }
  }

  async backupProfile(backupProfileOperation) {
    const { rootDirectoryPath, backupDirectoryPath, fetchId } = backupProfileOperation;

    this.log.verbose('backupProfile processing for', rootDirectoryPath);

    try {
      const backupTimestamp = new Date().toISOString().replaceAll(':', '-');
      const backupZip = new JSZip();
      const backupZipFilePath = path.join(backupDirectoryPath, `${backupTimestamp}.zip`);

      // Scan the root directory for subdirectories, whose names correspond to class names.
      const rootDirectory = await fs.opendir(rootDirectoryPath);
      this.log.verbose('Root directory opened.');

      for await (const rootDirectoryEntry of rootDirectory) {
        this.log.verbose('Processing directory entry', rootDirectoryEntry.name);
        if (!rootDirectoryEntry.isDirectory()) continue;

        const className = rootDirectoryEntry.name;
        const classDirectoryPath = path.join(rootDirectoryPath, className);
        const classDocumentCatalog = await this.createClassDocumentCatalog(className, classDirectoryPath);

        for (const documentEntry of classDocumentCatalog.documentEntries) {
          // Add each file to the archive as it is read from the original save location.
          const fileJson = await this.readDocumentJson(documentEntry);
          backupZip.file(`${className}/${documentEntry.fileName}`, fileJson);
        }
      }

      await fs.mkdir(backupDirectoryPath, { recursive: true });
      const backupZipData = await backupZip.generateAsync({type: 'nodebuffer', compression: 'DEFLATE'});
      await fs.writeFile(backupZipFilePath, backupZipData);

      this.log.verbose('backupProfile succeeded.', rootDirectoryPath, backupDirectoryPath, fetchId);
      this.module.respond('backupProfile', fetchId, true);

    } catch (error) {
      this.log.error('backupProfile error.', rootDirectoryPath, backupDirectoryPath, error, fetchId);
      this.module.respond('backupProfile', fetchId, false);

    } finally {
      this.moveToNextOperation();
    }
  }

  async removeProfile(removeProfileOperation) {
    const { rootDirectoryPath, fetchId } = removeProfileOperation;

    this.log.verbose('removeProfile processing for', rootDirectoryPath, fetchId);

    try {
      await fs.rm(rootDirectoryPath, {recursive: true});
      this.log.verbose('removeProfile succeeded.', rootDirectoryPath, fetchId);

      this.module.respond('removeProfile', fetchId, true);

    } catch (error) {
      this.log.error('removeProfile error.', rootDirectoryPath, error, fetchId);
      this.module.respond('removeProfile', fetchId, false);

    } finally {
      this.moveToNextOperation();
    }
  }

  moveToNextOperation() {
    // The first operation has been executed, so we can remove it.
    this.operations.shift();

    // Nothing left to do if we've cleared all operations.
    if (this.operations.length === 0) return;

    // Chain to the next operation.
    this.executeFirstOperation();
  }
}
