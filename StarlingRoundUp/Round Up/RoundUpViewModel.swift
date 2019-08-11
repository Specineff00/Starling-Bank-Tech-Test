//
//  RoundupViewModel.swift
//  StarlingRoundUp
//
//  Created by Nikash Ramsorrun on 11/08/2019.
//  Copyright © 2019 Yogesh Nikash Ramsorrun. All rights reserved.
//

import Foundation

class RoundUpViewModel {
    
    var feedItems: [FeedItem]?
    var hasAddedFunds: Bool = false
    var savedSavingsGoals: SavedSavingsGoal?
    let dao: DataAccessObjectContract
    
    var alertMessage: String? {
        didSet {
            self.showAlertClosure?()
        }
    }
    var roundUpTotal: Int? {
        didSet {
            self.updateTotalClosure?()
        }
    }
    
    var showAlertClosure: (()->())?
    var updateTotalClosure: (()->())?
    
    init(dao: DataAccessObjectContract) {
        self.dao = dao
    }
    
    //MARK:- Public
    func getRoundUp() {
        dao.getAccount { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .success(_): //No use for account list in VM
                strongSelf.getFeed()
            case .failure(let starlingError):
                strongSelf.alertMessage = starlingError.localizedDescription
            }
        }
    }
    
    func saveRoundedUpTotal() {
        dao.saveSavingsGoal { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let savedSavingsGoals):
                strongSelf.savedSavingsGoals = savedSavingsGoals
                guard let feedItems = strongSelf.feedItems else {
                    print("no Feed items")
                    return }
                strongSelf.addFunds(from: feedItems, with: savedSavingsGoals.savingsGoalUid)
            case .failure(let starlingError):
                strongSelf.alertMessage = starlingError.localizedDescription
            }
        }
    }
    
    //MARK:- Private
    private func getFeed() {
        //        guard !hasAddedFunds,
        //            let _ = feedItems else { return } //Show alert
        
        dao.getFeed { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let feed):
                strongSelf.feedItems = feed.feedItems
                
                strongSelf.roundUpTotal = strongSelf
                    .getWeeksFeed(from: strongSelf.feedItems!)
                    .map { strongSelf.roundUp(amount: $0.amount.minorUnits) }
                    .reduce(0, +)
                
            case .failure(let starlingError):
                strongSelf.alertMessage = starlingError.localizedDescription
            }
        }
    }
    
    private func addFunds(from feedItems: [FeedItem], with savingsGoalsUid: String) {
        
        let roundedTotal = getWeeksFeed(from: feedItems)
            .map { roundUp(amount: $0.amount.minorUnits) }
            .reduce(0, +)
        
        dao.addFundsToSavingGoal(amount: roundedTotal, savingsGoalsUid: savingsGoalsUid) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .success(_):
                strongSelf.hasAddedFunds = true
                strongSelf.alertMessage = "Sucess"
            case .failure(let starlingError):
                strongSelf.alertMessage = starlingError.localizedDescription
            }
        }
    }
    
    private func getWeeksFeed(from feedItems: [FeedItem]) -> [FeedItem] {
        let weekTimeInterval: TimeInterval = 60 * 60  * 24 * 7
        let weekAgo = Date().addingTimeInterval(-weekTimeInterval)
        let now = Date()
        let weeksRange = weekAgo...now
        
        return feedItems
            .filter { feedItem -> Bool in
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                if let date = dateFormatter.date(from: feedItem.transactionTime) {
                    if weeksRange.contains(date) {
                        return true
                    }
                }
                return false
        }
    }
    
    private func roundUp(amount: Int) -> Int {
        return Int(( Double(amount) / Double(100)).rounded(.up)) * 100
    }
    
    //What it should do
    
    //Call to get the account
    //Call to get the feed
    //Get only a weeks worth ...can it be done via api?
    
    
    //With the weeks feed. take every item and round up to nearest quid
    //Subtract the rounded quid amount to the original
    //With that value add it to the total
    //Present round up total
    
    //Once all added up create savings goal called round up once button pressed
    //When saved transfer it into the pot
}
