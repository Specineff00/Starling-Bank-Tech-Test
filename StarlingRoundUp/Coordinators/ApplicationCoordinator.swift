//
//  Coordinator.swift
//  StarlingRoundUp
//
//  Created by Nikash Ramsorrun on 11/08/2019.
//  Copyright © 2019 Yogesh Nikash Ramsorrun. All rights reserved.
//

import UIKit

protocol Coordinator {
    func start()
}


class ApplicationCoordinator: Coordinator {
   
    let window: UIWindow
    let rootViewController: UINavigationController
    let roundUpCoordinator: RoundUpCoordinator
    let baseUrl = URL(string: "https://api-sandbox.starlingbank.com/api/v2")!

    init(window: UIWindow) {
        self.window = window
        rootViewController = UINavigationController()
        rootViewController.navigationBar.prefersLargeTitles = true
        
        let networkLayer = NetworkLayer(baseUrl: baseUrl)
        let dao = DataAccessObject(networkLayer: networkLayer)
        self.roundUpCoordinator = RoundUpCoordinator(presenter: rootViewController, viewModel: RoundUpViewModel(dao: dao))
    }
    
    
    func start() {
        window.rootViewController = rootViewController
        roundUpCoordinator.start()
        window.makeKeyAndVisible()
    }
}
