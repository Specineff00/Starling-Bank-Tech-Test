//
//  RoundupViewController.swift
//  StarlingRoundUp
//
//  Created by Nikash Ramsorrun on 11/08/2019.
//  Copyright © 2019 Yogesh Nikash Ramsorrun. All rights reserved.
//

import UIKit

class RoundupViewController: UIViewController {

    @IBOutlet weak var roundUpButton: UIButton!
    @IBOutlet weak var totalRoundUpLabel: UILabel!
    @IBOutlet weak var saveButton: UIButton!
    
    let viewModel: RoundUpViewModel

    init(viewModel: RoundUpViewModel) {
        self.viewModel = viewModel
        let bundle = Bundle(for: type(of: self))
        super.init(nibName: nil, bundle: bundle)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViewModel() {
        viewModel.showAlertClosure = { [weak self] () in
            DispatchQueue.main.async {
                if let message = self?.viewModel.alertMessage {
                    self?.showAlert( message )
                }
            }
        }
        viewModel.updateTotalClosure = { [weak self] () in
            DispatchQueue.main.async {
                if let total = self?.viewModel.roundUpTotal {
                    self?.update(total: total)
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        saveButton.isUserInteractionEnabled = false
        saveButton.tintColor = .white
        saveButton.backgroundColor = .gray
        setupViewModel()
    }
    
    func update(total: Int) {
        saveButton.isUserInteractionEnabled = true
        saveButton.backgroundColor = .green
        saveButton.tintColor = .black
        totalRoundUpLabel.text = "\(total)"
    }

    @IBAction func getAccountTapped(_ sender: Any) {
        viewModel.getRoundUp()
    }
    @IBAction func saveButtonTapped(_ sender: Any) {
        viewModel.saveRoundedUpTotal()
    }
    
    func showAlert( _ message: String ) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction( UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
