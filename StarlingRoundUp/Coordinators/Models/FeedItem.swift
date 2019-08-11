//
//  FeedItem.swift
//  StarlingRoundUp
//
//  Created by Nikash Ramsorrun on 11/08/2019.
//  Copyright © 2019 Yogesh Nikash Ramsorrun. All rights reserved.
//

import Foundation

class FeedItem: Decodable {
    let amount: Amount
    let direction: String
    let transactionTime: String //If given more time, this type would be Date
}
