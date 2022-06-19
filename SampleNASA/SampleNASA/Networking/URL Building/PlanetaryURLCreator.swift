//
//  PlanetaryURLHelper.swift
//  SampleNASA
//
//  Created by Rayan Godwin Sequeira on 18/06/22.
//

import Foundation

enum PlanetaryPathComponents : CustomStringConvertible {
    case APOD
    case AsteroidsNeoWs
    
    var description : String {
        switch self {
        case .APOD: return "planetary/apod"
        case .AsteroidsNeoWs: return "neo/rest/v1/feed"
        }
    }
}

enum PlanetaryHTTPMethods : CustomStringConvertible
{
    case GET
    case POST
    
    var description: String
    {
        switch self {
        case .GET: return "GET"
        case .POST: return "POST"
        }
    }
}

protocol PlanetaryURLCreating
{
    func buildURLForAstronomyPicturOfTheDay() -> URLRequest?
    func buildURLForAstronomyPictures(from startDate: String, to endDate: String) -> URLRequest?
}

struct PlanetaryURLCreator: PlanetaryURLCreating
{
    private let urlBuilder: PlanetaryURLBuilding
    private let host = "api.nasa.gov"
    private let demoKey = "DEMO_KEY"
    init(urlBuilder: PlanetaryURLBuilding)
    {
        self.urlBuilder = urlBuilder
    }
    
    func buildURLForAstronomyPicturOfTheDay() -> URLRequest?
    {
        var urlRequestToreturn: URLRequest? = nil
        if let url = self.urlBuilder.set(scheme: "https").set(host: host).set(path: PlanetaryPathComponents.APOD.description).addQueryItem(name: "api_key", value: demoKey).build()
        {
            urlRequestToreturn = URLRequest(url: url)
            urlRequestToreturn?.httpMethod = PlanetaryHTTPMethods.GET.description
        }
        return urlRequestToreturn
    }
    
    func buildURLForAstronomyPictures(from startDate: String, to endDate: String) -> URLRequest?
    {
        var urlRequestToreturn: URLRequest? = nil
        if let url = self.urlBuilder.set(scheme: "https").set(host: host).set(path: PlanetaryPathComponents.APOD.description).addQueryItem(name: "start_date", value: startDate).addQueryItem(name: "end_date", value: endDate).addQueryItem(name: "api_key", value: demoKey).build()
        {
            urlRequestToreturn = URLRequest(url: url)
            urlRequestToreturn?.httpMethod = PlanetaryHTTPMethods.GET.description
        }
        return urlRequestToreturn
    }
}
