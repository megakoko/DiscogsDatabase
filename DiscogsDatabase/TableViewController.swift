//
//  TableViewController.swift
//  DiscogsDatabase
//
//  Created by Andy on 24/11/2017.
//  Copyright © 2017 Andy. All rights reserved.
//

import UIKit

protocol TableProtocol {
    func search(searchString: String)
}

class TableViewController: UITableViewController, TableProtocol {
    var artists = [String]()

    func search(searchString: String) {
        artists.removeAll()
        
        var urlComponents = URLComponents(string: "https://api.discogs.com/database/search?type=artist")
        if urlComponents != nil {
            let query = URLQueryItem(name: "q", value: searchString)
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
                    if let results = convertedJsonIntoDict["results"] as? [Any] {
                        for result in results {
                            if let resultObject = result as? [String: Any] {
                                let title = resultObject["title"] as? String
                                self.artists += [title!]
                            }
                        }
                    }
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
        task.resume()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return artists.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "artistCellIdentifier", for: indexPath)

        cell.textLabel?.text = artists[indexPath.row]
        
        return cell
    }
}
