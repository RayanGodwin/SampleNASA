//
//  NetworkManager.swift
//  SampleNASA
//
//  Created by Rayan Godwin Sequeira on 18/06/22.
//

import Foundation
import UIKit

fileprivate enum RequestType
{
    case APODSingle
    case APODDateRange
}

enum ManagerErrors : Error
{
    case couldNotFindData
    case couldNotBuildRequest
    case invalidResponse
    case invalidStatusCode(Int)
}

typealias FetchPictureOfTheDayCompletionBlock = (Result<PlanetaryModel,Error>) -> ()
typealias FetchPicturesCompletionBlock = (Result<[PlanetaryModel],Error>) -> ()
typealias DownloadImageCompletionBlock = (Result<UIImage,Error>) -> ()

protocol PlanetaryNetworkManagingProtocol
{
    func fetchAstronomyPictureOfTheDay(dateString: String, completionBlock: @escaping FetchPictureOfTheDayCompletionBlock)
    func fetchAstronomyPictures(from startDate: String, to endDate: String, completionBlock: @escaping FetchPicturesCompletionBlock)
    func downloadImage(from urlString: String, completion: @escaping DownloadImageCompletionBlock)
}

class PlanetaryNetworkManager: PlanetaryNetworkManagingProtocol
{
    let urlCreator: PlanetaryURLCreating
    let imageCache: PlanetaryImageCaching
    init (urlCreator: PlanetaryURLCreating = PlanetaryURLCreator(urlBuilder: PlanetaryURLBuilder()),
          imageCache: PlanetaryImageCaching = PlanetaryImageCache.publicCache)
    {
        self.urlCreator = urlCreator
        self.imageCache = imageCache
    }
    
    final func fetchAstronomyPictureOfTheDay(dateString: String, completionBlock: @escaping FetchPictureOfTheDayCompletionBlock)
    {
        let completionOnMain = { result in
            DispatchQueue.main.async {
                completionBlock(result)
            }
        }
        
        guard let urlRequest = self.urlCreator.buildURLForAstronomyPicturOfTheDay(dateString: dateString) else
        {
            completionOnMain(.failure(ManagerErrors.couldNotBuildRequest))
            return
        }
        
        let urlSession = URLSession.shared.dataTask(with: urlRequest) {[weak self] (data, response, error) in
            guard let self = self else { return }
            let result = self.handle(data: data, response: response, error: error)
            switch result
            {
            case .success(let dataReceived):
                do {
                    let model = try JSONDecoder().decode(PlanetaryModel.self, from: dataReceived)
                    completionOnMain(.success(model))
                } catch {
                    debugPrint("Could not translate the data to the requested type. Reason: \(error.localizedDescription)")
                    completionOnMain(.failure(error))
                }
                
            case .failure(let errorReceived):
                completionOnMain(.failure(errorReceived))
            }
        }
        urlSession.resume()
    }
    
    final func fetchAstronomyPictures(from startDate: String, to endDate: String, completionBlock: @escaping FetchPicturesCompletionBlock)
    {
        let completionOnMain = { result in
            DispatchQueue.main.async {
                completionBlock(result)
            }
        }
        
        guard let urlRequest = self.urlCreator.buildURLForAstronomyPictures(from: startDate, to: endDate) else
        {
            completionBlock(.failure(ManagerErrors.couldNotBuildRequest))
            return
        }
        
        let urlSession = URLSession.shared.dataTask(with: urlRequest) {[weak self] (data, response, error) in
            guard let self = self else { return }
            let result = self.handle(data: data, response: response, error: error)
            switch result
            {
            case .success(let dataReceived):
                do {
                    let models = try JSONDecoder().decode([PlanetaryModel].self, from: dataReceived)
                    completionOnMain(.success(models))
                } catch {
                    debugPrint("Could not translate the data to the requested type. Reason: \(error.localizedDescription)")
                    completionOnMain(.failure(error))
                }
                
            case .failure(let errorReceived):
                completionOnMain(.failure(errorReceived))
            }
        }
        urlSession.resume()
    }
    
    final func downloadImage(from urlString: String, completion: @escaping DownloadImageCompletionBlock)
    {
        self.imageCache.load(url: urlString) { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }
    
    private func handle(data:Data?, response: URLResponse?, error: Error?) -> Result<Data,Error>
    {
        if let errorReceived = error {
            return .failure(errorReceived)
        }
        
        // Lets check the status code, we are only interested in results between 200 and 300 in statuscode. If the statuscode is anything
        // else we want to return the error with the statuscode that was returned. In this case, we do not care about the data.
        guard let urlResponse = response as? HTTPURLResponse else {
            return .failure(ManagerErrors.invalidResponse)
        }
        
        if !(200..<300).contains(urlResponse.statusCode)
        {
            return .failure(ManagerErrors.invalidStatusCode(urlResponse.statusCode))
        }
        
        guard let dataReceived = data else
        {
            return .failure(ManagerErrors.couldNotFindData)
        }
        
        return .success(dataReceived)
    }
}
