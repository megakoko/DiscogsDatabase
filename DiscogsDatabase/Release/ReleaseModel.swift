//
//  ReleaseModel.swift
//  DiscogsDatabase
//
//  Created by Andy on 07/10/2018.
//  Copyright © 2018 Andy Chukavin. All rights reserved.
//

import Foundation

class ReleaseModel {
    static let dataUpdatedNotification = "dataUpdatedNotification"

    private(set) var trackCollections = [TrackCollection]()
    private(set) var artist: String?
    private(set) var genre: String?
    private(set) var year: String?

    private var releaseUrl: URL? = nil

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
                        if !releaseArtistNames.isEmpty {
                            self.artist = releaseArtistNames.joined(separator: ", ")
                        }
                        if year != nil {
                            self.year = "\(year!)"
                        }
                        if genres != nil {
                            self.genre = genres!.joined(separator: ", ")
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
                NotificationCenter.default.post(name: Notification.Name(rawValue: ReleaseModel.dataUpdatedNotification),
                                                object: nil,
                                                userInfo: nil)
            }
        }

        task.resume()
    }
}
