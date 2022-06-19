//
//  PlanetaryViewModel.swift
//  SampleNASA
//
//  Created by Rayan Godwin Sequeira on 18/06/22.
//

import Foundation
import UIKit

struct PlanetaryModelToDisplay
{
    let title: String
    let displayDate: String
    let explanation: String
}

typealias FetchCurrentItemOfDayDownloadCallback = (Result<PlanetaryModelToDisplay, Error>) -> ()
typealias FetchCurrentItemOfDayImageDownloadCallback = (Result<UIImage, Error>) -> ()

protocol PlanetaryViewModeling
{
    var networkManager: PlanetaryNetworkManagingProtocol { get }
    func fetchCurrentItemOfTheDay(modelDownloadCompletion: @escaping FetchCurrentItemOfDayDownloadCallback, imageDownloadCompletion: @escaping FetchCurrentItemOfDayImageDownloadCallback)
}

struct PlanetaryDownloadContext
{
    let modelDownloadCallback: FetchCurrentItemOfDayDownloadCallback
    let imageDownloadBlock: FetchCurrentItemOfDayImageDownloadCallback
}

class PlanetaryViewModel: PlanetaryViewModeling
{
    var networkManager: PlanetaryNetworkManagingProtocol
    init(networkManager: PlanetaryNetworkManagingProtocol = PlanetaryNetworkManager())
    {
        self.networkManager = networkManager
    }
    
    func fetchCurrentItemOfTheDay(modelDownloadCompletion: @escaping FetchCurrentItemOfDayDownloadCallback, imageDownloadCompletion: @escaping FetchCurrentItemOfDayImageDownloadCallback)
    {
        let downloadContext = PlanetaryDownloadContext(modelDownloadCallback: modelDownloadCompletion, imageDownloadBlock: imageDownloadCompletion)
        self.networkManager.fetchAstronomyPictureOfTheDay { [weak self] result in
            guard let self = self else { return }
            self.handleModelDownload(result: result, downloadContext: downloadContext)
        }
    }
    
    private func handleModelDownload(result: Result<PlanetaryModel, Error>, downloadContext: PlanetaryDownloadContext)
    {
        switch result
        {
        case .success(let model):
            FileUtility.saveModel(model: model)
            self.handleDownloadDidFinish(model: model, downloadContext: downloadContext)

        case .failure(let error):
            guard let urlError = error as? URLError, urlError.code == URLError.Code.notConnectedToInternet,
                    let oldModel = FileUtility.fetchCachedModelFromLocation() else
            {
                self.invokeModelDownloadCompletionOnMainThread(completion: downloadContext.modelDownloadCallback, result: .failure(error))
                self.invokeImageDownloadCompletionOnMainThread(completion: downloadContext.imageDownloadBlock, result: .failure(error))
                return
            }
            self.handleDownloadDidFinish(model: oldModel, downloadContext: downloadContext)
        }
    }
    
    private func handleDownloadDidFinish(model: PlanetaryModel, downloadContext: PlanetaryDownloadContext)
    {
        let modelToDisplay = PlanetaryModelToDisplay(title: model.title, displayDate: model.date, explanation: model.explanation)
        self.invokeModelDownloadCompletionOnMainThread(completion: downloadContext.modelDownloadCallback, result: .success(modelToDisplay))
        self.initiateImageDownload(model: model, downloadContext: downloadContext)
    }
    
    private func initiateImageDownload(model: PlanetaryModel, downloadContext: PlanetaryDownloadContext)
    {
        self.networkManager.downloadImage(from: model.url) { [weak self] result in
            guard let self = self else { return }
            switch result
            {
            case .success(let image):
                FileUtility.save(image: image, imageURLString: model.url)
                self.invokeImageDownloadCompletionOnMainThread(completion: downloadContext.imageDownloadBlock, result: .success(image))
                
            case .failure(let error):
                guard let urlError = error as? URLError, urlError.code == URLError.Code.notConnectedToInternet,
                      let previousImage = FileUtility.image(with: model.url) else
                {
                    self.invokeImageDownloadCompletionOnMainThread(completion: downloadContext.imageDownloadBlock, result: .failure(error))
                    return
                }
                self.invokeImageDownloadCompletionOnMainThread(completion: downloadContext.imageDownloadBlock, result: .success(previousImage))
            }
        }
    }
    
    private func invokeModelDownloadCompletionOnMainThread(completion: @escaping FetchCurrentItemOfDayDownloadCallback, result: Result<PlanetaryModelToDisplay, Error>)
    {
        DispatchQueue.main.async {
            completion(result)
        }
    }
    
    private func invokeImageDownloadCompletionOnMainThread(completion: @escaping FetchCurrentItemOfDayImageDownloadCallback, result: Result<UIImage, Error>)
    {
        DispatchQueue.main.async {
            completion(result)
        }
    }
}
