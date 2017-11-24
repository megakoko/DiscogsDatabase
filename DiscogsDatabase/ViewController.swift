//
//  ViewController.swift
//  DiscogsDatabase
//
//  Created by Andy on 24/11/2017.
//  Copyright © 2017 Andy. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var mainView: UIView!
    
    @IBOutlet weak var searchField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        print("did load")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func fetchData2(_ sender: Any) {
        var urlComponents = URLComponents(string: "https://api.discogs.com/database/search?type=artist")
        if urlComponents != nil {
            let query = URLQueryItem(name: "q", value: searchField.text)
            urlComponents!.queryItems = [query]
        }
        
        var request = URLRequest(url: urlComponents!.url!)
        request.httpMethod = "GET"
        
        let key = ProcessInfo.processInfo.environment["DiscogsKey"] ?? ""
        let secret = ProcessInfo.processInfo.environment["DiscogsSecret"] ?? ""
        
        if key.isEmpty || secret.isEmpty {
            print("Discogs API key or secret is empty")
        }
        
        request.addValue("Discogs key=\(key), secret=\(secret)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) {
            data, response, error in
            
            if error != nil {
                print("error=\(error!)")
                return
            }
            
            do {
                if let convertedJsonIntoDict = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary {
                    print(convertedJsonIntoDict)
                    
                    if let results = convertedJsonIntoDict["results"] as? [Any] {
                        for result in results {
                            if let resultObject = result as? [String: Any] {
                                let title = resultObject["title"] as? String
                                print(title!)
                            }
                        }
                        if let result = results[1] as? [String: Any] {
                            let title = result["title"] as? String
                            print(title!)
                        }
                    }
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
        
        task.resume()
    }
    
    @IBAction func fetchData(_ sender: UITextField) {
        print("ad")
    }
    
}
