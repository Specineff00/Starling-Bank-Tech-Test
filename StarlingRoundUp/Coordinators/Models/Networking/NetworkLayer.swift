//
//  NetworkContract.swift
//  StackOverflow
//
//  Created by Yogesh N Ramsorrrun on 28/07/2019.
//  Copyright © 2019 Yogesh N Ramsorrrun. All rights reserved.
//

import Foundation

enum StarlingError: Error {
    case noAccountUid
    case noDefaultCategory
    case networkError
    case decodeFail
    case unknown
}

enum StarlingResult<T> {
    case success(T)
    case failure(StarlingError)
}

public enum HTTPMethod: String {
    case get
    case put
    
    public var rawValue: String {
        return "\(self)".uppercased()
    }
}

typealias CompletionClosure = (Result<(URLResponse, Data), Error>) -> Void

protocol NetworkLayerContract {
    func saveAccount(_ account: Account) // I'm not too keen on this method as the DAO decodes the Account and the network layer needs these properties so this is to pass it back
    func getAccount(onCompletion: @escaping CompletionClosure)
    func getFeed(onCompletion: @escaping CompletionClosure)
    func saveSavingsGoal(goalTitle:String, onCompletion: @escaping CompletionClosure)
    func getSavingsGoals(onCompletion: @escaping CompletionClosure)
    func addFundsToSavingGoal(amount: Int, savingsGoalUid: String, onCompletion: @escaping CompletionClosure)
}


class NetworkLayer: NetworkLayerContract {

    let baseUrl: URL
    
    let feedComponent = "/feed"
    let accountComponent = "/account"
    let categoryComponent = "/category"
    let savingGoalsComponent = "/savings-goals"
    let addMoneyComponent = "/add-money"
    
    var accountUid: String?
    var defaultCategory: String?
    
    lazy var accountsUrl: URL = {
        return self.baseUrl.appendingPathComponent("/accounts")
    }()
    
    init(baseUrl: URL) {
        self.baseUrl = baseUrl
    }
    
    func saveAccount(_ account: Account) {
        self.accountUid = account.accountUid
        self.defaultCategory = account.defaultCategory
    }
    
    
    func getAccount(onCompletion: @escaping CompletionClosure) {
        URLSession.shared.dataTask(withUrl: accountsUrl, result: onCompletion).resume()
    }
    
    func getFeed(onCompletion: @escaping CompletionClosure) {
        guard let accountUid = accountUid else {
            onCompletion(.failure(StarlingError.noAccountUid))
            return
        }
        
        guard let defaultCategory = defaultCategory else {
            onCompletion(.failure(StarlingError.noDefaultCategory))
            return
        }
    
        let pathComponents = feedComponent + accountComponent + "/\(accountUid)" + categoryComponent + "/\(defaultCategory)"
        let endpoint = baseUrl.appendingPathComponent(pathComponents)
        
        URLSession.shared.dataTask(withUrl: endpoint, result: onCompletion).resume()
        
    }
    
    func saveSavingsGoal(goalTitle: String, onCompletion: @escaping CompletionClosure) {
        guard let accountUid = accountUid else {
            onCompletion(.failure(StarlingError.noAccountUid))
            return
        }
        
        let pathComponents = accountComponent + "/\(accountUid)" + savingGoalsComponent
        let endpoint = baseUrl.appendingPathComponent(pathComponents)
        let headersHelper = HeadersHelper(additionalHeaders: ["Content-Type": "application/json"])
        
        
        //Not much time to create the JSON
        var json = [String: Any]()
        json["name"] = goalTitle
        json["currency"] = "GBP"
        
        var target = [String: Any]()
        target["currency"] = "GBP"
        target["minorUnits"] = 1000000
        json["target"] = target
        
        json["base64EncodedPhoto"] = "string"
        
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        
        URLSession.shared.dataTask(withUrl: endpoint, headerFields: headersHelper.headers, method: .put, jsonData: jsonData, result: onCompletion).resume()
    }
    
    //Not used anymore
    func getSavingsGoals(onCompletion: @escaping CompletionClosure) {
        guard let accountUid = accountUid else {
            onCompletion(.failure(StarlingError.noAccountUid))
            return
        }

        let pathComponents = accountComponent + "/\(accountUid)" + savingGoalsComponent
        let endpoint = baseUrl.appendingPathComponent(pathComponents)

        URLSession.shared.dataTask(withUrl: endpoint, result: onCompletion).resume()
    }
    
    
    func addFundsToSavingGoal(amount: Int, savingsGoalUid: String, onCompletion: @escaping CompletionClosure) {
        guard let accountUid = accountUid else {
            onCompletion(.failure(StarlingError.noAccountUid))
            return
        }
        
        let transferID = "d8770f9d-4ee9-4cc1-86e1-83c26bcfcd4f" //Not sure how to generate ID so static for now
        let pathComponents = accountComponent + "/\(accountUid)" + savingGoalsComponent + "/\(savingsGoalUid)" + addMoneyComponent + "/\(transferID)"
        let endpoint = baseUrl.appendingPathComponent(pathComponents)
        let headersHelper = HeadersHelper(additionalHeaders: ["Content-Type": "application/json"])
        
        
        URLSession.shared.dataTask(withUrl: endpoint, headerFields: headersHelper.headers, method: .get, result: onCompletion).resume()
    }
    
}
