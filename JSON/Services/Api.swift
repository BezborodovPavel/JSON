//
//  Api.swift
//  JSON
//
//  Created by Павел on 11.05.2022.
//

import Foundation
import Alamofire

enum NetworkError: Error {
    case invaliddURL
    case noData
    case decodingError
}

class RapidApi {
    
    private let host = "https://love-calculator.p.rapidapi.com/getPercentage"
    private var headers = [
        "X-RapidAPI-Host": "love-calculator.p.rapidapi.com",
        "X-RapidAPI-Key": "d5b6ef208bmsh2fbf6edede06488p1882a5jsn90f0430aac13"
    ]
    private let firstName: String
    private var firstNameEncoded: String {
        firstName
            .applyingTransform(.toLatin, reverse: false)?
            .applyingTransform(.stripDiacritics, reverse: false)?
            .addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
    }
    
    private let secondName: String
    private var secondNameEncoded: String {
        secondName
            .applyingTransform(.toLatin, reverse: false)?
            .applyingTransform(.stripDiacritics, reverse: false)?
            .addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
    }
    
    private var urlAPI: URL? {
        URL(string: "\(host)?sname=\(firstNameEncoded)&fname=\(secondNameEncoded)")
    }
    
    
    init (firstName: String, secondName: String) {
        self.firstName = firstName
        self.secondName = secondName
    }
    
    convenience init (firstName: String, secondName: String, apiKey: String) {
        self.init(firstName: firstName, secondName: secondName)
        headers = [
            "X-RapidAPI-Host": "love-calculator.p.rapidapi.com",
            "X-RapidAPI-Key": apiKey
        ]
    }
    
    // MARK: URLSession
    func sendRequest(closure:  @escaping (Result<ResponseResult, NetworkError>) -> ()) {
        
        getRawData { resultRawData in
            
            switch resultRawData {
            case let .failure(error):
                closure(.failure(error))
                
            case let .success(rawData):
                guard let responeResult = self.decodeDataToResponseResult(data: rawData) else {
                    closure(.failure(.decodingError))
                    return}
                closure(.success(responeResult))
            }
        }
    }
    
    private func getRawData(closure:  @escaping (Result<Data, NetworkError>) -> ()) {
        
        guard let urlAPI = urlAPI else {
            closure(.failure(.invaliddURL))
            return}
        
        let request = NSMutableURLRequest(
            url: urlAPI,
            cachePolicy: .useProtocolCachePolicy,
            timeoutInterval: 10.0
        )
        
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
    
        URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { ( data, response, error) -> Void in
            guard let data = data  else {
                closure(.failure(.noData))
                return
            }
            
            closure(.success(data))
            
        }).resume()
    }
    
    private func decodeDataToResponseResult(data: Data) -> ResponseResult?{
        
        do {
            
            let responseResult = try JSONDecoder().decode(ResponseResult.self, from: data)
            return responseResult
            
        } catch let error {
            print(error.localizedDescription)
            return nil
        }
    }
    
    //MARK: Alamofire
    func sendRequestAF(closure:  @escaping (Result<ResponseResult, NetworkError>) -> ()) {
        
        // Тут я не понял как сделать GET запрос без параметров но с Headers, на пустые, nil или
        // отсутсвующие параметры возвращалась ошибка
        AF.request(host, method: .get, parameters: ["sname":secondNameEncoded, "fname": firstNameEncoded], encoder: .urlEncodedForm, headers: HTTPHeaders(headers)).validate().responseData { dataResponse in
            switch dataResponse.result {
            case .success(let dataFromResponse):
                do {
                    
                    // Так как пример учебный и нам надо получить сырой json для ручного парсинга. Метод
                    // responseJson не используем так как он Depricated
                    let jsonDataFromResponse = try JSONSerialization.jsonObject(with: dataFromResponse)
                    guard let response = ResponseResult.getResult(from: jsonDataFromResponse) else {
                        closure(.failure(.decodingError))
                        return
                    }
                    closure(.success(response))
                } catch {
                    closure(.failure(.decodingError))
                }
            case .failure:
                closure(.failure(.noData))
            }
        }
    }
}


