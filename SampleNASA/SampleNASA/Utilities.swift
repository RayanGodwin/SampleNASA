//
//  Utilities.swift
//  SampleNASA
//
//  Created by Rayan Godwin Sequeira on 18/06/22.
//

import Foundation
import UIKit

struct DateUtility
{
    static func stringFrom(date: Date, format: String) -> String?
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: date)
    }
}

struct FileUtility
{
    static let imageSaveCount = 30
    static let modelFilePathURL = FileManager.default.urls(for: .cachesDirectory,
                                                              in: .userDomainMask)[0].appendingPathComponent("ItemOfTheDay")
    static let imageFilePathURL = FileManager.default.urls(for: .cachesDirectory,
                                                              in: .userDomainMask)[0].appendingPathComponent("ImageOfItem")
    static func saveModel(model: PlanetaryModel)
    {
        do
        {
            let archivedData = try PropertyListEncoder().encode(model)
            try archivedData.write(to: FileUtility.modelFilePathURL)
        }
        catch
        {
            print("Found error while writing data \(error)")
        }
    }
    
    static func fetchCachedModelFromLocation() -> PlanetaryModel?
    {
        var modelToReturn: PlanetaryModel?
        do
        {
            let data = try Data(contentsOf: FileUtility.modelFilePathURL)
            modelToReturn = try PropertyListDecoder().decode(PlanetaryModel.self, from: data)
        }
        catch
        {
            print("Found error while reading model data \(error)")
        }
        return modelToReturn
    }
    
    static func save(image: UIImage, imageURLString: String)
    {
        try? FileManager.default.createDirectory(atPath: FileUtility.imageFilePathURL.path, withIntermediateDirectories: true, attributes: nil)
        
        do
        {
            let contents = try FileManager.default.contentsOfDirectory(atPath: FileUtility.imageFilePathURL.path)
            if contents.count > FileUtility.imageSaveCount
            {
                for path in contents
                {
                    try? FileManager.default.removeItem(atPath: path)
                }
            }
            
            let data = image.pngData()
            let lastPathComponent = URL(string: imageURLString)?.lastPathComponent ?? "Default"
            try data?.write(to: FileUtility.imageFilePathURL.appendingPathComponent(lastPathComponent))
        }
        catch let error
        {
            print("Found error while writing the data \(error)")
        }
    }
    
    static func image(with urlString: String) -> UIImage?
    {
        var imageToReturn: UIImage?
        do
        {
            let lastPathComponent = URL(string: urlString)?.lastPathComponent ?? "Default"
            let data = try Data(contentsOf: FileUtility.imageFilePathURL.appendingPathComponent(lastPathComponent))
            imageToReturn = UIImage(data: data)
        }
        catch
        {
            print("Found error while writing the data \(error)")
        }
        return imageToReturn
    }
}
