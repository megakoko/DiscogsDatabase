//
//  DatabaseSearchController
//  DiscogsDatabase
//
//  Created by Andy Chukavin on 24/11/2017.
//  Copyright © 2017 Andy Chukavin. All rights reserved.
//

import UIKit

class DatabaseSearchController: UIViewController, UITableViewDataSource {
    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var tableView: UITableView!

    private var timer: Timer? = nil
    
    private var searchDelay = 0.3

    var artists = [DatabaseSearchItem]()
    var thumbnailDownloads = [Int: URLSessionDataTask]()

    override func viewDidLoad() {
        super.viewDidLoad()

        if let defaultSearchText = ProcessInfo.processInfo.environment["DefaultSearchText"] {
            searchField.text = defaultSearchText
            search()
        }
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

    private func clearData() {
        artists.removeAll()
        for task in thumbnailDownloads.values {
            task.cancel()
        }
        thumbnailDownloads.removeAll()
    }

    @objc private func search() {
        timer = nil
        clearData()

        var urlComponents = URLComponents(string: "https://api.discogs.com/database/search?type=artist")
        if urlComponents != nil {
            urlComponents!.queryItems = [URLQueryItem(name: "q", value: searchField.text),
                                         URLQueryItem(name: "type", value: "artist")]
        }

        var request = URLRequest(url: urlComponents!.url!)

        let key = ProcessInfo.processInfo.environment["DiscogsKey"] ?? ""
        let secret = ProcessInfo.processInfo.environment["DiscogsSecret"] ?? ""

        if key.isEmpty || secret.isEmpty {
            print("Discogs API key or secret is empty")
        }

        request.addValue("Discogs key=\(key), secret=\(secret)", forHTTPHeaderField: "Authorization")

        let task = URLSession.shared.dataTask(with: request) {
            data, response, error in

            if error != nil {
                print("Failed to perform search. Error=\(error!)")
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary {
                    if let results = json["results"] as? [[String: Any]] {
                        for result in results {
                            let searchItem = DatabaseSearchItem(thumbnailUrl: URL(string: result["thumb"] as? String ?? ""),
                                                        thumbnailImage: nil,
                                                        title: result["title"] as? String ?? "",
                                                        url: URL(string: result["resource_url"] as? String ?? ""))
                            self.artists += [searchItem]
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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "artistSegue") {
            let path = tableView.indexPathForSelectedRow
            let artist = artists[path!.row]
            segue.destination.title = artist.title
            if artist.url != nil {
                if let artistView = segue.destination as? ArtistViewController {
                    artistView.setArtistUrl(artist.url!)
                }
            }

            navigationController?.setNavigationBarHidden(false, animated: true)
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return artists.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "artistCellIdentifier", for: indexPath) as! DatabaseSearchCell
        let row = indexPath.row
        let artist = artists[row]

        cell.nameLabel.text = artist.title
        cell.thumbnailView.image = artist.thumbnailImage ?? UIImage(named: "no_image")

        if artist.thumbnailImage == nil && artist.thumbnailUrl != nil {
            let request = URLRequest(url: artist.thumbnailUrl!)
            let task = URLSession.shared.dataTask(with: request) {
                data, response, error in

                if error != nil {
                    print("Failed to download artist thumbnail. Error: \(error!)")
                    return
                }

                self.thumbnailDownloads[row] = nil

                if let thumbnail = UIImage(data: data!) {
                    self.artists[row].thumbnailImage = thumbnail
                    DispatchQueue.main.async {
                        cell.thumbnailView.image = thumbnail
                    }
                }
            }

            thumbnailDownloads[row] = task

            task.resume()
        }

        return cell
    }
}
