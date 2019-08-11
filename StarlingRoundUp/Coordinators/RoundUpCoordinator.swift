//
//  RoundupCoordinator.swift
//  StarlingRoundUp
//
//  Created by Nikash Ramsorrun on 11/08/2019.
//  Copyright © 2019 Yogesh Nikash Ramsorrun. All rights reserved.
//

import UIKit

class RoundUpCoordinator: Coordinator {
    
    private let presenter: UINavigationController
    private let viewModel: RoundUpViewModel
    private var roundupViewController: RoundupViewController?
    
    init(presenter: UINavigationController, viewModel: RoundUpViewModel) {
        self.presenter = presenter
        self.viewModel = viewModel
    }

    func start() {
        let roundupViewController = RoundupViewController(viewModel: viewModel)
        roundupViewController.view.backgroundColor = .cyan
        roundupViewController.title = "Round Up Time!"
        presenter.pushViewController(roundupViewController, animated: true)
        self.roundupViewController = roundupViewController
    }
    
}
