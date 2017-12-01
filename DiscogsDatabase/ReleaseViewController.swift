//
//  ReleaseViewController.swift
//  DiscogsDatabase
//
//  Created by Andy on 01/12/2017.
//  Copyright © 2017 Andy Chukavin. All rights reserved.
//

import UIKit

class ReleaseViewController: UIViewController, UITableViewDataSource {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!

    private var releaseUrl: URL?

    private var trackCollections = [TrackCollection]()

    func setReleaseUrl(_ url: URL) {
        releaseUrl = url
        downloadReleaseInfo()
    }

    private func downloadReleaseInfo() {
        let releasesRequest = URLRequest(url: releaseUrl!)
        let task = URLSession.shared.dataTask(with: releasesRequest) {
            data, response, error in

            if error != nil {
                print("Failed to fetch release information")
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary {
                    let title = json["title"] as? String
                    let year = json["year"] as? Int
                    let genres = json["genres"] as? [String]

                    var releaseArtistNames = [String]()
                    if let releaseArtists = json["artists"] as? [[String:Any]] {
                        for releaseArtist in releaseArtists {
                            if let name = releaseArtist["name"] as? String {
                                releaseArtistNames += [name]
                            }
                        }
                    }

                    DispatchQueue.main.async {
                        self.titleLabel.text = title
                        if !releaseArtistNames.isEmpty {
                            self.artistLabel.text = "by " + releaseArtistNames.joined(separator: ", ")
                        }
                        if year != nil {
                            self.yearLabel.text = "\(year!)"
                        }
                        if genres != nil {
                            self.genreLabel.text = genres!.joined(separator: ", ")
                        }
                    }

                    if let tracklist = json["tracklist"] as? [[String:Any]] {
                        for item in tracklist {
                            let type = item["type_"] as? String
                            if type == "heading" {
                                self.trackCollections += [TrackCollection(tracks: [Track](),
                                                                          title: item["title"] as? String,
                                                                          duration: item["duration"] as? String)]
                            } else if type == "track" {
                                if self.trackCollections.isEmpty {
                                    self.trackCollections += [TrackCollection(tracks: [Track](), title: nil, duration: nil)]
                                }

                                var artists = [String]()
                                if let artistObjects = item["artists"] as? [[String:Any]] {
                                    for artist in artistObjects {
                                        if let name = artist["name"] as? String {
                                            artists += [name]
                                        }
                                    }
                                }

                                let track = Track(artists: artists,
                                                  position: item["position"] as? String,
                                                  title: item["title"] as? String,
                                                  duration: item["duration"] as? String)

                                self.trackCollections[self.trackCollections.count-1].tracks += [track]
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

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return trackCollections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trackCollections[section].tracks.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "releaseCellIdentifier", for: indexPath)

        cell.textLabel?.text = trackCollections[indexPath.section].tracks[indexPath.row].title

        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return trackCollections[section].title
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
