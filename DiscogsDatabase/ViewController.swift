//
//  ViewController.swift
//  DiscogsDatabase
//
//  Created by Andy on 24/11/2017.
//  Copyright © 2017 Andy. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    private var tableDelegate: TableProtocol?
    
    @IBOutlet weak var searchField: UITextField!
    
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

    @IBAction func fetchData2(_ sender: Any) {
        if tableDelegate != nil {
            tableDelegate?.search(searchString: searchField.text!)
        }
    }
    
    @IBAction func fetchData(_ sender: UITextField) {
        print("ad")
    }
}
