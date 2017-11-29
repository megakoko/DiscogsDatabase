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
    var artists = [Artist]()

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
                                let thumbnailUrl = URL(string: resultObject["thumb"] as? String ?? "")
                                let title = resultObject["title"] as? String
                                let url = URL(string: resultObject["resource_url"] as? String ?? "")
                                self.artists += [Artist(thumbnailUrl: thumbnailUrl, title: title!, url: url)]
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "artistSegue") {
            let path = tableView.indexPathForSelectedRow
            segue.destination.title = artists[path!.row].title
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return artists.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "artistCellIdentifier", for: indexPath) as! ArtistTableViewCell

        let artist = artists[indexPath.row]
        
        cell.nameLabel.text = artist.title
        
        var thumbnail: UIImage? = nil
        if artist.thumbnailUrl != nil {
            if let imageData = try? Data(contentsOf: artist.thumbnailUrl!) {
                thumbnail = UIImage(data: imageData)
            }
        }
        cell.thumbnailView.image = thumbnail ?? UIImage(named: "no_image")
        
        return cell
    }
}
