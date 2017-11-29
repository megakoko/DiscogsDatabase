//
//  ArtistViewCellViewController.swift
//  DiscogsDatabase
//
//  Created by Andy on 29/11/2017.
//  Copyright © 2017 Andy. All rights reserved.
//

import UIKit

protocol ArtistViewProtocol {
    func setArtistUrl(_ url: URL)
}

class ArtistViewController: UIViewController, ArtistViewProtocol {
    @IBOutlet weak var artistNameLabel: UILabel!
    
    private var artistUrl: URL? = nil
        
    func setArtistUrl(_ url: URL) {
        artistUrl = url
        print(artistUrl!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
