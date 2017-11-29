//
//  ViewController.swift
//  DiscogsDatabase
//
//  Created by Andy on 24/11/2017.
//  Copyright © 2017 Andy. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var searchField: UITextField!

    private var tableDelegate: TableProtocol?
    
    private var timer: Timer? = nil
    
    private var searchDelay = 0.3

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "embeddedArtistTableViewSegue") {
            let embeddedController = segue.destination as! TableViewController
            tableDelegate = embeddedController
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func editingChanged(_ sender: Any) {
        if timer != nil {
            timer!.invalidate()
        }
        
        timer = Timer.scheduledTimer(timeInterval: searchDelay, target: self, selector: #selector(self.search), userInfo: nil, repeats: false)
    }
    
    @objc private func search() {
        timer = nil
        if tableDelegate != nil {
            tableDelegate?.search(searchString: searchField.text!)
        }
    }
}
