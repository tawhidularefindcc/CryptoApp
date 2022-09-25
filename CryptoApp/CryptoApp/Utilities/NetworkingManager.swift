//
//  NetworkManager.swift
//  CryptoApp
//
//  Created by Md Najmuzzaman on 9/25/22.
//

import Foundation
import Combine

class NetworkingManager {
    
    enum NetworkingError: LocalizedError {
        case badUrlResponse(url: URL)
        case unknown
        
        var errorDescription: String? {
            switch self {
            case .badUrlResponse(url: let url):
                return "[🔥] Bad response from URL: \(url)"
            case .unknown:
                return "[⚠️] Unknown error occured"
            }
        }
    }
        
        static func download(url: URL) -> AnyPublisher<Data, Error>{
            return URLSession.shared.dataTaskPublisher(for: url).subscribe(on: DispatchQueue.global(qos: .default))
                .tryMap({ try handleUrlResponse(output: $0, url: url) })
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        }
        
        static func handleUrlResponse(output: URLSession.DataTaskPublisher.Output, url: URL) throws -> Data {
            guard let response = output.response as? HTTPURLResponse,
                  response.statusCode >= 200 && response.statusCode < 300 else {
                throw NetworkingError.badUrlResponse(url: url)
            }
            return output.data
        }
        
        static func handleCompletion(completion: Subscribers.Completion<Error>){
            switch completion {
            case .finished:
                break
            case .failure(let error):
                debugPrint(error.localizedDescription)
            }
        }
    }
