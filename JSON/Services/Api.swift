//
//  Api.swift
//  JSON
//
//  Created by Павел on 11.05.2022.
//

import Foundation
import UIKit

class RapidApi {
    
    private let host = "https://love-calculator.p.rapidapi.com/getPercentage"
    private var headers = [
        "X-RapidAPI-Host": "love-calculator.p.rapidapi.com",
        "X-RapidAPI-Key": "d5b6ef208bmsh2fbf6edede06488p1882a5jsn90f0430aac13"
    ]
    private let firstName: String
    private let secondName: String
    private var urlAPI: URL? {

        let fName = firstName
            .applyingTransform(.toLatin, reverse: false)?
            .applyingTransform(.stripDiacritics, reverse: false)?
            .addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
        
        let sName = secondName
            .applyingTransform(.toLatin, reverse: false)?
            .applyingTransform(.stripDiacritics, reverse: false)?
            .addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
        
        let urlString = "\(host)?sname=\(fName)&fname=\(sName)"
            
        return URL(string: urlString)
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
    
    func sendRequest(closure:  @escaping (ResponseResult?) -> ()) {
        
        getRawData { rawData in
            
            if rawData == nil {
                closure(nil)
                return
            }
            
            guard let responeResult = self.decodeDataToResponseResult(data: rawData!) else {
                closure(nil)
                return}
            closure(responeResult)
            
        }
    }
    
    private func getRawData(closure:  @escaping (Data?) -> ()) {
        
        guard let urlAPI = urlAPI else {
            closure(nil)
            return}
        
        let request = NSMutableURLRequest(
            url: urlAPI,
            cachePolicy: .useProtocolCachePolicy,
            timeoutInterval: 10.0
        )
        
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
    
        URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { ( data, response, error) -> Void in
            if data == nil {
                print(error?.localizedDescription ?? "Some error, without description")
            }
            
            closure(data)
            
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

}


