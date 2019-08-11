//
//  DataAccessObjectContract.swift
//  StarlingRoundUp
//
//  Created by Nikash Ramsorrun on 11/08/2019.
//  Copyright © 2019 Yogesh Nikash Ramsorrun. All rights reserved.
//

import Foundation

typealias AccountsClosure = (StarlingResult<AccountsList>) -> Void
typealias FeedItemsClosure = (StarlingResult<FeedItems>) -> Void
typealias SaveSavingGoalsClosure = (StarlingResult<SavedSavingsGoal>) -> Void
typealias GetSavingGoalsClosure = (StarlingResult<SavingsGoalsList>) -> Void

protocol DataAccessObjectContract {
    func getAccount(onCompletion: @escaping AccountsClosure)
    func getFeed(onCompletion: @escaping FeedItemsClosure)
    func saveSavingsGoal(onCompletion: @escaping SaveSavingGoalsClosure)
    func getSavingsGoals(onCompletion: @escaping GetSavingGoalsClosure)
    func addFundsToSavingGoal(amount: Int, savingsGoalsUid: String, onCompletion: @escaping CompletionClosure)
}

class DataAccessObject: DataAccessObjectContract {
    
    func addFundsToSavingGoal(amount: Int, savingsGoalsUid: String, onCompletion: @escaping CompletionClosure) {
        networkLayer.addFundsToSavingGoal(amount: amount, savingsGoalUid: savingsGoalsUid, onCompletion: onCompletion)
    }
    
    let networkLayer: NetworkLayerContract
    
    init(networkLayer: NetworkLayerContract) {
        self.networkLayer = networkLayer
    }
    
    func getAccount(onCompletion: @escaping AccountsClosure) {
        networkLayer.getAccount { [weak self] result in
            guard let strongSelf = self else {
                onCompletion(.failure(.unknown))
                return
            }
            DispatchQueue.main.async {
                switch result {
                case .success(_, let data):
                    do {
                        let accountsList = try JSONDecoder().decode(AccountsList.self, from: data)
                        guard let account = accountsList.accounts.first else {
                            onCompletion(.failure(.decodeFail))
                            return
                        }
                        strongSelf.networkLayer.saveAccount(account)
                        onCompletion(.success(accountsList))
                    } catch {
                        onCompletion(.failure(.decodeFail))
                    }
                case .failure(let error):
                    guard let starlingError = error as? StarlingError else {
                        onCompletion(.failure(StarlingError.unknown))
                        return
                    }
                    onCompletion(.failure(starlingError))
                }
            }
        }
    }
    
    
    func getFeed(onCompletion: @escaping FeedItemsClosure) {
        networkLayer.getFeed { result in
            DispatchQueue.main.async {
                switch result {
                case .success(_, let data):
                    do {
                        let feedItems = try JSONDecoder().decode(FeedItems.self, from: data)
                        onCompletion(.success(feedItems))
                    } catch {
                        onCompletion(.failure(.decodeFail))
                    }
                case .failure(let error):
                    guard let starlingError = error as? StarlingError else {
                        onCompletion(.failure(StarlingError.unknown))
                        return
                    }
                    onCompletion(.failure(starlingError))
                }
            }
        }
    }
    
    func saveSavingsGoal(onCompletion: @escaping SaveSavingGoalsClosure) {
        networkLayer.saveSavingsGoal(goalTitle: "Round Up") { result in
            DispatchQueue.main.async {
                switch result {
                case .success(_, let data):
                    do {
                        let savedSavingsGoal = try JSONDecoder().decode(SavedSavingsGoal.self, from: data)
                        onCompletion(.success(savedSavingsGoal))
                    } catch {
                        onCompletion(.failure(.decodeFail))
                    }
                case .failure(let error):
                    guard let starlingError = error as? StarlingError else {
                        onCompletion(.failure(StarlingError.unknown))
                        return
                    }
                    onCompletion(.failure(starlingError))
                }
            }
        }
    }
    
    //Not used anymore
    func getSavingsGoals(onCompletion: @escaping GetSavingGoalsClosure) {
        networkLayer.getSavingsGoals { result in
            DispatchQueue.main.async {
                switch result {
                case .success(_, let data):
                    do {
                        let accountsList = try JSONDecoder().decode(SavingsGoalsList.self, from: data)
                        onCompletion(.success(accountsList))
                    } catch {
                        onCompletion(.failure(.decodeFail))
                    }
                case .failure(let error):
                    guard let starlingError = error as? StarlingError else {
                        onCompletion(.failure(StarlingError.unknown))
                        return
                    }
                    onCompletion(.failure(starlingError))
                }
            }
        }
    }
    
}
