//
//  ViewController.swift
//  Weather
//
//  Created by 장태현 on 2021/04/17.
//

import UIKit

class MainVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        Indicator.INSTANCE.startAnimating()
        
        view.backgroundColor = .systemBackground
        // Do any additional setup after loading the view.
        
        let label = UILabel(frame: .zero)
        view.addSubview(label)
        
        label.text = "Hiroo"
        label.sizeToFit()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            Indicator.INSTANCE.stopAnimating()
        }
        
    }


}

