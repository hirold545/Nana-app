//
//  ViewController.swift
//  Nana App
//
//  Created by test test on 10/25/26.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground // Sets screen background
        setupMyButton()
    }
    
    func setupMyButton() {
            // 1. Create the GUI object
            let myButton = UIButton(type: .system)
            myButton.setTitle("Click Me", for: .normal)
            myButton.backgroundColor = .systemBlue
            myButton.setTitleColor(.white, for: .normal)
            myButton.layer.cornerRadius = 8
            
            // 2. Disable default resizing and add to screen
            myButton.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(myButton)
            
            // 3. Define layout positioning (Constraints)
            NSLayoutConstraint.activate([
                myButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                myButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                myButton.widthAnchor.constraint(equalToConstant: 200),
                myButton.heightAnchor.constraint(equalToConstant: 50)
            ])
        }

}

// Add this snippet at the very bottom of your ViewController.swift file:
#Preview {
    ViewController()
}


