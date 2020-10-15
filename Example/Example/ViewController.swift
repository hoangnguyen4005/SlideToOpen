//
//  ViewController.swift
//  Example
//
//  Created by Chi Hoang on 15/10/20.
//  Copyright © 2020 Hoang Nguyen Chi. All rights reserved.
//

import UIKit
import SlideToOpen

class ViewController: UIViewController {
    @IBOutlet weak var slideOpenView: SlideToOpenView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setAutoLayoutSildeOpenView()
    }

    func setAutoLayoutSildeOpenView() {
        slideOpenView.text = "Slide to Right".uppercased()
        slideOpenView.textFont = UIFont.systemFont(ofSize: 14.0)
        slideOpenView.delegate = self
        slideOpenView.icon = UIImage(named: "right")
    }
}

extension ViewController: SlideToOpenViewDelegate {

    func didFinishSlideToOpenView(_ sender: SlideToOpenView) {
        let alertController = UIAlertController(title: "", message: "Done!", preferredStyle: .alert)
        let doneAction = UIAlertAction(title: "Okay", style: .default) { (_) in
            sender.resetStateWithAnimation(false)
        }
        alertController.addAction(doneAction)
        self.present(alertController, animated: true, completion: nil)
    }

}
