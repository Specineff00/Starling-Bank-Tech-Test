//
//  SavingsGoal.swift
//  StarlingRoundUp
//
//  Created by Nikash Ramsorrun on 11/08/2019.
//  Copyright © 2019 Yogesh Nikash Ramsorrun. All rights reserved.
//

import Foundation

class SavingsGoal: Decodable {
    let savingsGoalUid: String
    let name: String
    let target: Target
    let totalSaved: TotalSaved
}
