//
//  FileUtils.swift
//  jkdsUtility
//
//  Created by 서창열 on 12/23/25.
//
import Foundation

import SwiftUI

public enum FileIOError : Error {
    /** 파일이 이미 존재함 */
    case isExist
    /** 파일 생성 실패*/
    case failedToSave
}

fileprivate extension Double {
    var fileSizeString:String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB, .useGB, .useTB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(self))
    }
}

public extension URL {
    /**
     도큐먼트 디랙토리 URL 생성
     let url:URL = .documentsPath
     */
    static var documentsPath:URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    /**
     
     디랙토리 URL 만들기 (/test)
     let url:URL = .makeURL(withPath : "test")
     파일 URL 만들기 (/test/test.png)
     let url:URL = .makeURL(withPath : "test", fileName: "test.png")
     */
    static func makeURL(withPath path:String, fileName:String? = nil)->URL {
        let url:URL = .documentsPath.appendingPathComponent(path, isDirectory: true)
        if let fileName = fileName {
            return url.appendingPathComponent(fileName, isDirectory: false)
        } else {
            return url
        }
    }
    
    /** 파일사이즈 구하기 (byte 단위) */
    var fileSize:Double {
        guard let attributes = try? FileManager.default.attributesOfItem(
            atPath: self.path
        ) else {
            return 0.0
        }
            
        let fileSize = attributes[.size] as? UInt64 ?? 0
        return Double(fileSize)
    }
    
    var fileSizeString:String {
        return self.fileSize.fileSizeString
    }
    
    var directorySize:Double {
        guard let enumerator = FileManager.default.enumerator(
            at: self,
            includingPropertiesForKeys: [.fileSizeKey, .isDirectoryKey],
            options: [.skipsHiddenFiles]
        ) else {
            return 0
        }
        
        var totalSize: UInt64 = 0
        
        for case let fileURL as URL in enumerator {
            let values = try? fileURL.resourceValues(
                forKeys: [.isDirectoryKey, .fileSizeKey]
            )
            
            if values?.isDirectory == true {
                continue
            }
            
            totalSize += UInt64(values?.fileSize ?? 0)
        }
        
        return Double(totalSize)
    }
    
    var directorySizeString:String {
        directorySize.fileSizeString
    }
    
    var isExist:Bool {
        FileManager.default.fileExists(atPath: self.path)
    }
    
    func delete() throws {
        try FileManager.default.removeItem(atPath: self.path)
    }
    
}
public struct FileUtils {
    
    // MARK: - folder
    /**
     Document Folder 아래에 폴더 생성하기
     
     - parameter directoryName : 폴더명 ( / 포함 경로 )
     - returns: ActionResult(enum) (Failure, Success)
     */
    public static func createFolder(directoryName: String) throws {
        let url:URL = .makeURL(withPath: directoryName)
        if url.isExist {
            throw FileIOError.isExist
        }
        try FileManager.default.createDirectory(
            at: url,
            withIntermediateDirectories: true,
            attributes: nil
        )
    }
    
    /**
     Document Folder 아래에 폴더 삭제
     
     - parameter directoryName : 폴더명 ( / 포함 경로 )
     - returns: ActionResult(enum) (Failure, Success)
     */
    public static func removeFolder(directoryName: String) throws {
        let url:URL = .documentsPath.appendingPathComponent(
            directoryName,
            isDirectory: true
        )
        Log.debug(#function, directoryName)
        try FileManager.default.removeItem(at: url)
    }
    
    
    /**
     iCloud 폴더 백업 제외
     - parameter directoryName : 폴더명 ( / 포함 경로 )
     - returns: ActionResult(enum) (Failure, Success)
     */
    public static func excludeBackup(directoryName: String) throws {
        var url:URL = .documentsPath.appendingPathComponent(
            directoryName,
            isDirectory: true
        )
        var values = URLResourceValues()
        values.isExcludedFromBackup = true
        try url.setResourceValues(values)
    }


    //MARK: - file
    /**
     파일 존재여부 검사
     
     - parameter fileName : 파일명
     - parameter fileDirectory : 파일이 있는 디렉토리 ( / 포함 경로 )
     - returns: ExistResult(enum) (NotExist, Exist)
     */
    public static func isExistFile(
        fileName: String,
        inDirectory fileDirectory: String
    ) -> Bool {
        URL.documentsPath
            .appendingPathComponent(fileDirectory, isDirectory: true)
            .appendingPathComponent(fileName)
            .isExist
    }
    /**
     파일 생성
     **/
    public static func createFile(url:URL, data:Data) throws {
        if url.isExist {
            throw FileIOError.isExist
        }
        if FileManager.default
            .createFile(
                atPath: url.path,
                contents: data
            ) == false {
            throw FileIOError.failedToSave
        }
    }
    
    public static func deleteFile(filePath: String) throws {
        try FileManager.default.removeItem(atPath: filePath)
    }
    
    public static func fileSizeInKB(at url: URL) throws -> Double {
        url.fileSize
    }
}

extension NSURL {
    func excludeFromBackup() throws {
        try setResourceValue(true, forKey: .isExcludedFromBackupKey)
    }
}


