//
//  Constants.swift
//  Din Din Demo
//
//  Created by jeet_gandhi on 9/11/20.
//

import Foundation

class Constants {

    static let shared = Constants()

    static let ApiKey = Constants.shared.getAPIBaseURL(key: "APIKEY")
    static let BaseURL = URL(string: Constants.shared.getAPIBaseURL(key: "APIURLEndpoint"))!
    static let BaseImgURL = URL(string: Constants.shared.getAPIBaseURL(key: "APIIMGURLENDPOINT"))!

    fileprivate func getAPIBaseURL(key: String) -> String {
        guard let urlStr = (Bundle.main.object(forInfoDictionaryKey: key) as? String)?.trimmingCharacters(in: .whitespaces) else {
            return ""
        }
        return urlStr
    }

}

