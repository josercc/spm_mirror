import ArgumentParser
import SwiftShell
import Foundation
import XcodeProjectCore

/// Swift Package Manager 下载和更新依赖加速
struct SpmMirror: ParsableCommand {
    
    @Option(help: "请输入 DerivedData 的路径 默认为 $Home/Library/Developer/Xcode/DerivedData")
    var derivedDataPath:String?
    
    mutating func run() throws {
        let pwd = try pwd()
        let pbxPath = "/Users/king/Documents/swiftUI_win/Win+/Win+.xcodeproj" + "/project.pbxproj"
        let xcodeprojectFileURL = URL(fileURLWithPath: pbxPath)

        // Instanciate `XcodeProject`.
        let xcodeproject = try XcodeProject(xcodeprojectURL: xcodeprojectFileURL)
        for element in xcodeproject.objects {
            if let value = element.value as? XC.RemoteSwiftPackageReference {
                
            }
        }
//        SwiftShell.main.currentdirectory = pwd
//        print("swift package update --verbose")
//        let output = SwiftShell.run("swift", "package", "update", "--verbose")
//        guard output.succeeded else {
//            if let error = output.error {
//                throw error
//            } else {
//                throw NSError(domain: "未知错误", code: -1, userInfo: nil)
//            }
//        }
        let home = try home()
        let _derivedDataPath = derivedDataPath ?? "\(home)/Library/Developer/Xcode/DerivedData"
        for element in try FileManager.default.contentsOfDirectory(atPath: _derivedDataPath) {
            let infoPlistPath = "\(_derivedDataPath)/\(element)/info.plist"
            guard FileManager.default.fileExists(atPath: infoPlistPath) else {
                continue
            }
            guard let map = NSDictionary(contentsOfFile: infoPlistPath) else {
                continue
            }
            guard let workspancePath = map["WorkspacePath"] as? String, workspancePath == pwd else {
                continue
            }
            let buildPath = "\(pwd)/.build"
            let sourcePackagesPath = "\(_derivedDataPath)/\(element)/SourcePackages"
            try copy(fromDirectory: buildPath,
                     toDirectory: sourcePackagesPath,
                     name: "artifacts",
                     isDirectory: true)
            try copy(fromDirectory: buildPath,
                     toDirectory: sourcePackagesPath,
                     name: "checkouts",
                     isDirectory: true)
            try copy(fromDirectory: buildPath,
                     toDirectory: sourcePackagesPath,
                     name: "repositories",
                     isDirectory: true)
            try copy(fromDirectory: buildPath,
                     toDirectory: sourcePackagesPath,
                     name: "workspace-state.json",
                     isDirectory: false)
        }
    }
    
    func copy(fromDirectory:String, toDirectory:String, name:String, isDirectory:Bool) throws {
        let from = "\(fromDirectory)/\(name)"
        let to = "\(toDirectory)/\(name)"
        
        if isDirectory {
            try deleteDirectoryIfExit(path: to)
        } else {
            try deleteFileIfExit(path: to)
        }
        try FileManager.default.copyItem(atPath: from, toPath: to)
    }
    
    func deleteDirectoryIfExit(path:String) throws {
        var isDirectory:ObjCBool = .init(false)
        guard FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory) else {
            return
        }
        guard isDirectory.boolValue else {
            throw NSError(domain: "\(path)存在但是不是一个文件夹", code: -1, userInfo: nil)
        }
        try FileManager.default.removeItem(atPath: path)
    }
    
    func deleteFileIfExit(path:String) throws {
        guard FileManager.default.fileExists(atPath: path) else {
            return
        }
        try FileManager.default.removeItem(atPath: path)
    }
    
    func checkDirectoryExit(path:String) throws {
        var isDirectory:ObjCBool = .init(false)
        guard !FileManager.default.fileExists(atPath: path,
                                              isDirectory: &isDirectory) else {
            throw NSError(domain: "\(path)不存在", code: -1, userInfo: nil)
        }
        guard isDirectory.boolValue else {
            throw NSError(domain: "\(path)存在,但不是一个目录", code: -1, userInfo: nil)
        }
    }
    
    func checkFileExit(path:String) throws {
        guard !FileManager.default.fileExists(atPath: path) else {
            throw NSError(domain: "\(path)不存在", code: -1, userInfo: nil)
        }
    }
    
    func pwd() throws -> String {
        guard let pwd = ProcessInfo.processInfo.environment["PWD"] else {
            throw NSError(domain: "PWD不存在", code: -1, userInfo: nil)
        }
        return pwd
    }
    
    func home() throws -> String {
        guard let home = ProcessInfo.processInfo.environment["HOME"] else {
            throw NSError(domain: "HOME不存在", code: -1, userInfo: nil)
        }
        return home
    }
}

SpmMirror.main()
