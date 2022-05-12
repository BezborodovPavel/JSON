//
//  ResultViewContollerViewController.swift
//  JSON
//
//  Created by Павел on 12.05.2022.
//

import UIKit

class ResultViewContoller: UIViewController {
    
    @IBOutlet weak var resultLabel: UILabel!
    
    var resultString: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        resultLabel.text = resultString
    }
}
