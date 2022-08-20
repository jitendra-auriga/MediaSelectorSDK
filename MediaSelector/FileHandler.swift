//
//  FileHandler.swift
//  MediaSelector
//
//  Created by mac on 2022-08-22.
//

import Foundation


class FileHandler
{
    static let shared = FileHandler()
    private init() {}
    
    let fileManagerObj = FileManager.default

    var fileManagerPath: URL {
        return fileManagerObj.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    var documentDirPath: URL {
        return URL(string: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!)!
    }
    
    func saveFileInDir(url: URL, fileName: String, pathToSaveOn: URL? = nil, completion: @escaping (String?, Error?) -> Void) {
        
        createDraftFolder()
        var destinationUrl = fileManagerPath.appendingPathComponent(fileName)

        if pathToSaveOn != nil {
            destinationUrl = pathToSaveOn!
        }

        if FileManager().fileExists(atPath: destinationUrl.path) {
            print("File already exists [\(destinationUrl.path)]")
            completion(destinationUrl.relativePath, nil)
//            do {
//                try FileManager().removeItem(atPath: destinationUrl.path)
//            }
//            catch {
//                print("Error while removing file")
//            }

        }else if let dataFromURL = NSData(contentsOf: url)  {
            if dataFromURL.write(to: destinationUrl, atomically: true) {
                //print("file saved [\(destinationUrl.path)]")
                completion(destinationUrl.relativePath, nil)
            }
            else {
                print("error saving file")
                let error = NSError(domain:"Error saving file.", code:1001, userInfo:nil)
                completion("", error)
            }
        }
        else {
            let error = NSError(domain:"Error saving file", code:1002, userInfo:nil)
            completion("", error)
        }
    }
    
    func saveImageInDir(imageData: Data, fileName: String, pathToSaveOn: URL? = nil, completion: @escaping (String?, Error?) -> Void) {
        createDraftFolder()
        do {
            let fileURL = fileManagerPath.appendingPathComponent(fileName)
            try imageData.write(to: fileURL)
            //print("file saved [\(documentDirPath.path)]")
            completion(fileURL.relativePath, nil)
        }
        catch {
            let error = NSError(domain:"Error saving file", code:1002, userInfo:nil)
            completion("", error)
        }
        
    }
    
    func createDraftFolder() {
        do {
            try fileManagerObj.createDirectory(at: fileManagerPath.appendingPathComponent("Temprary"), withIntermediateDirectories: true)
                print("Draft path created:")
            } catch let error {
                print("error: \(error)")
            }
    }
    
    func clearDraft() {
        
        let draftPath = fileManagerPath.appendingPathComponent("Temprary")
        do {
            let content = try fileManagerObj.contentsOfDirectory(atPath: draftPath.relativePath)
                content.forEach { file in
                    do {
                        try fileManagerObj.removeItem(atPath: URL(fileURLWithPath: draftPath.absoluteString).appendingPathComponent(file).path)
                    } catch {
                        print(error.localizedDescription)
                    }
                }
        }catch let error {
                print(error.localizedDescription)
        }
    }

    func loadFileAsync(url: URL, pathToSaveOn: URL? = nil, completion: @escaping (String?, Error?) -> Void)
    {
        var destinationUrl = documentDirPath.appendingPathComponent(url.lastPathComponent)

        if pathToSaveOn != nil {
            destinationUrl = pathToSaveOn!
        }
        
        if FileManager().fileExists(atPath: destinationUrl.path) {
            print("File already exists [\(destinationUrl.path)]")
            completion(destinationUrl.path, nil)
        }
        else {
            let session = URLSession(configuration: URLSessionConfiguration.default, delegate: nil, delegateQueue: nil)
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            let task = session.dataTask(with: request, completionHandler: {
                data, response, error in
                if error == nil {
                    if let response = response as? HTTPURLResponse {
                        if response.statusCode == 200 {
                            if let data = data {
                                if let _ = try? data.write(to: destinationUrl, options: Data.WritingOptions.atomic) {
                                    completion(destinationUrl.path, error)
                                }
                                else {
                                    completion(destinationUrl.path, error)
                                }
                            }
                            else {
                                completion(destinationUrl.path, error)
                            }
                        }
                    }
                }
                else {
                    completion(destinationUrl.path, error)
                }
            })
            task.resume()
        }
    }
}
