import ArgumentParser
import SwiftShell
import Foundation
import SwiftyJSON

/// Swift Package Manager 下载和更新依赖加速
struct SpmMirror: ParsableCommand {
    
    @Option(help: "请输入 DerivedData 的路径 默认为 $Home/Library/Developer/Xcode/DerivedData")
    var derivedDataPath:String?
    
    mutating func run() throws {
        let pwd = try pwd()
//        pwd = "/Users/king/Documents/Request/"
        SwiftShell.main.currentdirectory = pwd
        let command = runAsync("swift", "package", "dump-package")
        try command.finish()
        /// 获取 Swift Package 的描述 JSON
        let json = JSON(parseJSON: command.stdout.read())
        /// 获取 Swift Package 名字
        let name = json["name"].string
        try runAndPrint("swift", "package", "resolve")
        let home = try home()
        let _derivedDataPath = derivedDataPath ?? "\(home)/Library/Developer/Xcode/DerivedData"
        var currentDerivedDataPath:String?
        /// 推荐相似的 DerivedData 路径数组
        var recommendDerivedDataPaths:[String] = []
        for element in try FileManager.default.contentsOfDirectory(atPath: _derivedDataPath) {
            let path = "\(_derivedDataPath)/\(element)"
            let infoPlistPath = "\(_derivedDataPath)/\(element)/info.plist"
            guard let name = name else {
                continue
            }
            guard element.contains(name) else {
                continue
            }
            guard FileManager.default.fileExists(atPath: infoPlistPath) else {
                /// 如果包含 Swift Package Name 且不存在info.plist 则代表是推荐的
                recommendDerivedDataPaths.append(path)
                continue
            }
            guard let map = NSDictionary(contentsOfFile: infoPlistPath) else {
                recommendDerivedDataPaths.append(path)
                continue
            }
            guard let workspancePath = map["WorkspacePath"] as? String, workspancePath == pwd else {
                continue
            }
            currentDerivedDataPath = path
        }
        var _currentDerivedDataPath:String
        if let currentDerivedDataPath = currentDerivedDataPath {
            _currentDerivedDataPath = currentDerivedDataPath
        } else {
            guard let recommandPath = recommendDerivedDataPaths.first else {
                throw "当前项目还没有 DerivedData 目录 请先用 Xcode 打开 Package.swift,暂停Xcode拉取Swift Package Manager,重新执行此命令即可！"
            }
            _currentDerivedDataPath = recommandPath
            /// 自动创建info.plist
            let infoContent = """
            <?xml version="1.0" encoding="UTF-8"?>
            <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
            <plist version="1.0">
            <dict>
                <key>LastAccessedDate</key>
                <date>\(Date().description)</date>
                <key>WorkspacePath</key>
                <string>\(pwd)</string>
            </dict>
            </plist>
            """
            FileManager.default.createFile(atPath: "\(recommandPath)/info.plist", contents: infoContent.data(using: .utf8))
        }
        let buildPath = "\(pwd)/.build"
        let sourcePackagesPath = "\(_currentDerivedDataPath)/SourcePackages"
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


extension String: LocalizedError {
    public var errorDescription: String? {self}
}
