//
//  ResponseResult.swift
//  JSON
//
//  Created by Павел on 12.05.2022.
//

struct ResponseResult: Decodable {
    
    let fname: String
    let sname: String
    let percentage: String
    let result: String
    
    init(responseData: [String: Any]) {
        fname = responseData["fname"] as? String ?? ""
        sname = responseData["sname"] as? String ?? ""
        percentage = responseData["percentage"] as? String ?? ""
        result = responseData["result"] as? String ?? ""
    }
    
    static func getResult(from value: Any) -> ResponseResult? {
        guard let result = value as? [String: Any] else {return nil}
        return ResponseResult(responseData: result)
    }
}
