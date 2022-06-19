//
//  PlanetaryURLBuilder.swift
//  SampleNASA
//
//  Created by Rayan Godwin Sequeira on 18/06/22.
//

import Foundation

protocol PlanetaryURLBuilding
{
    func set(scheme: String) -> Self
    func set(host: String) -> Self
    func set(port: Int) -> Self
    func set(path: String) -> Self
    func addQueryItem(name: String, value: String) -> Self
    func build() -> URL?
}

class PlanetaryURLBuilder: PlanetaryURLBuilding
{
    private var components: URLComponents = URLComponents()
    
    final func set(scheme: String) -> Self
    {
        self.components.scheme = scheme
        return self
    }
    
    final func set(host: String) -> Self
    {
        self.components.host = host
        return self
    }
    
    final func set(port: Int) -> Self
    {
        self.components.port = port
        return self
    }
    
    final func set(path: String) -> Self
    {
        var path = path
        if !path.hasPrefix("/") {
            path = "/" + path
        }
        self.components.path = path
        return self
    }
    
    final func addQueryItem(name: String, value: String) -> Self
    {
        if self.components.queryItems == nil {
            self.components.queryItems = []
        }
        self.components.queryItems?.append(URLQueryItem(name: name, value: value))
        return self
    }
    
    final func build() -> URL?
    {
        return self.components.url
    }
}
