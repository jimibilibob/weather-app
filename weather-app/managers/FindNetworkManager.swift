//
//  FindNetworkManager.swift
//  weather-app
//
//  Created by user on 23/6/22.
//

import Foundation

enum FindResponseError: Error {
    case invalidUrl
}

class FindNetworkManager {
    static let shared = FindNetworkManager()
    
    let baseUrlString = "https://api.openweathermap.org"
    
    func getFind(query: String, completion: @escaping (Result<Find, Error>) -> Void) -> Void {
        guard let scapedQuery = query.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed),
            let url = URL(string: "\(baseUrlString)/data/2.5/find?q=\(scapedQuery)&appid=7ffef1dd25f9c3190367bf2e3c66e63c") else { return completion(.failure(FindResponseError.invalidUrl)) }
        
        NetworkManager.shared.get(Find.self, from: url) { result in
            switch result {
                case .success(let draw):
                completion(.success(draw))
                case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
