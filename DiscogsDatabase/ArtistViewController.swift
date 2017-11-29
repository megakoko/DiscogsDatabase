//
//  ArtistViewCellViewController.swift
//  DiscogsDatabase
//
//  Created by Andy Chukavin on 29/11/2017.
//  Copyright © 2017 Andy Chukavin. All rights reserved.
//

import UIKit

class ArtistViewController: UIViewController {
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var artistProfileLabel: UILabel!

    private var artistUrl: URL? = nil

    func setArtistUrl(_ url: URL) {
        artistUrl = url

        let request = URLRequest(url: artistUrl!)

        let task = URLSession.shared.dataTask(with: request) {
            data, response, error in

            if error != nil {
                print("Failed to fetch artist data. Error=\(error!)")
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary {
                    let name = json["name"] as? String
                    let profile = json["profile"] as? String
                    DispatchQueue.main.async {
                        self.artistNameLabel.text = name ?? ""
                        self.artistProfileLabel.text = profile ?? ""
                    }

                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }

        task.resume()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        artistNameLabel.text = nil
        artistProfileLabel.text = nil
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
