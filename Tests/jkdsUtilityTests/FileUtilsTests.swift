//
//  Test.swift
//  jkdsUtility
//
//  Created by 서창열 on 12/23/25.
//

import Testing
import jkdsUtility
import Foundation

struct FileUtilsTests {
    let directory = "test4"
    
    @Test func 존재하지않는디랙터리_삭제시도테스트() {
        #expect(throws: Error.self) {
            try FileUtils.removeFolder(directoryName: directory)
        }
    }
    
    @Test func 디렉터리생성_테스트() throws {
        try FileUtils.createFolder(directoryName: directory)
    }
    
    @Test func 디랙터리_중복생성_테스트() throws {
        #expect(throws: Error.self) {
            try FileUtils.createFolder(directoryName: directory)
            try FileUtils.createFolder(directoryName: directory)
        }
    }
    
    @Test func 디랙터리_삭제_테스트() throws {
        try FileUtils.removeFolder(directoryName: directory)
    }
   
    @Test func 존재하지않는_파일존재여부확인_테스트() {
        #expect(FileUtils.isExistFile(fileName: "test", inDirectory: "abc") == false)
    }
    
    @Test func 파일사이즈_정상계산() throws {
        let url = URL.documentsPath.appendingPathComponent("20482")

        let data = Data(repeating: 0, count: 2048)
        try? FileUtils.createFile(url: url, data: data)
        
        Log.debug(url.fileSize)
        Log.debug(url.fileSizeString)
        #expect(url.fileSizeString == "2KB")
    }
    
    
    @Test func 디렉토리_사이즈_계산() throws {
        let dir = URL.makeURL(withPath: "test")
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)

        let file = dir.appendingPathComponent("a.bin")
        let data = Data(repeating: 0, count: 2048)
        FileManager.default.createFile(atPath: file.path, contents: data)

        let size = dir.directorySizeString
        Log.debug(size)
        #expect(size == "2KB")
    }
}

