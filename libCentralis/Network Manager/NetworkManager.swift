//
//  NetworkManager.swift
//  libCentralis
//
//  Created by AW on 18/10/2020.
//

import Foundation

public typealias completionHandler = (_ success: Bool, _ error: String?) -> ()

internal class NetworkManager {

    internal typealias rdc = (_ success: Bool, _ dict: [String : Any]) -> ()
    
    internal func generateStringFromDict(_ dict: [String : String]) -> String {
        let encoder = JSONEncoder()
        if let jsonData = try? encoder.encode(dict) {
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                return jsonString
            }
        }
        return "Error"
    }
    
    class internal func requestWithDict(url: String?, requestMethod: String, params: [String : String], completion: @escaping rdc) {
        var c = URLComponents(string: url ?? EduLinkAPI.shared.authorisedSchool.server!)!
        c.queryItems = [URLQueryItem(name: "method", value: requestMethod)]
        var request = URLRequest(url: c.url!)
        request.httpMethod = "POST"
        let b = EdulinkBody(method: requestMethod, params: params)
        guard let jd = try? JSONEncoder().encode(b) else { return completion(false, [String : Any]())}
        request.httpBody = jd
        request.setValue(requestMethod, forHTTPHeaderField: "x-api-method")
        request.setValue("application/json;charset=utf-8", forHTTPHeaderField: "Content-Type")
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) -> Void in
            if let data = data {
                do {
                    let dict = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String : Any] ?? [String : Any]()
                    completion(true, dict)
                } catch {
                    completion(false, [String : Any]())
                }
            } else { completion(false, [String : Any]()) }
        }
        task.resume()
    }
}

fileprivate struct EdulinkBody: Encodable {
    var jsonrpc = "2.0"
    var method: String!
    var uuid = UUID.uuid
    var id = "1"
    var params: [String : String]!
    
    init(method: String, params: [String : String]) {
        self.method = method
        self.params = params
    }
}
