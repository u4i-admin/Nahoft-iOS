//
//  URL+Extension.swift
//  Nahoft
//
//  Created by Work Account on 16.08.2023.
//

import Foundation

public extension URL {
    /// Returns a URL for the given app group and database pointing to the sqlite database.
    static func storeURL(for appGroup: String, databaseName: String) -> URL {
        guard let fileContainer = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroup) else {
            fatalError("Shared file container could not be created.")
        }

        var fileUrl = fileContainer.appendingPathComponent("\(databaseName).sqlite")
        
        var resourceValues = URLResourceValues()
        resourceValues.isExcludedFromBackup = true
        
        do {
            try fileUrl.setResourceValues(resourceValues)
        } catch {
            //fatalError("Shared file container could not be created.")
            print("Shared file container could not be created.")
        }
        
        return fileUrl
    }
}
