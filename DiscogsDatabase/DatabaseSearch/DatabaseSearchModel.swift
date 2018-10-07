//
//  DatabaseSearchModel.swift
//  DiscogsDatabase
//
//  Created by Andy on 06/10/2018.
//  Copyright © 2018 Andy Chukavin. All rights reserved.
//

import Foundation
import UIKit

class DatabaseSearchModel {
    static let artistListUpdateNotification = "artistListUpdateNotification"
    static let artistThumbnailUpdateNotification = "artistThumbnailUpdateNotification"
    static let artistThumbnailIndex = "artistThumbnailIndex"

    private var artists = [DatabaseSearchItem]()
    private var thumbnailDataTasks = [Int: URLSessionDataTask]()
    private var artistListDataTask: URLSessionDataTask? = nil

    private var timer: Timer? = nil

    private var searchDelay = 0.3

    private var filterText: String?

    // Public
    func artistCount() -> Int {
        return artists.count
    }

    func artist(_ row: Int) -> DatabaseSearchItem? {
        if row < 0 || row >= artists.count {
            return nil
        }

        let artist = artists[row]

        if artist.thumbnailImage == nil && artist.thumbnailUrl != nil {
            downloadThumbnail(row)
        }

        return artist
    }

    func search(_ filterText: String?) {
        self.filterText = filterText
        
        if timer != nil {
            timer!.invalidate()
        }

        timer = Timer.scheduledTimer(timeInterval: searchDelay, target: self, selector: #selector(self.doSearch), userInfo: nil, repeats: false)
    }

    // Private
    private func clearData() {
        artists.removeAll()

        for task in thumbnailDataTasks.values {
            task.cancel()
        }
        thumbnailDataTasks.removeAll()

        if artistListDataTask != nil {
            artistListDataTask?.cancel()
            artistListDataTask = nil
        }
    }

    @objc private func doSearch() {
        timer = nil

        clearData()

        var urlComponents = URLComponents(string: "https://api.discogs.com/database/search?type=artist")
        if urlComponents != nil {
            urlComponents!.queryItems = [URLQueryItem(name: "q", value: filterText),
                                         URLQueryItem(name: "type", value: "artist")]
        }

        var request = URLRequest(url: urlComponents!.url!)

        let key = ProcessInfo.processInfo.environment["DiscogsKey"] ?? ""
        let secret = ProcessInfo.processInfo.environment["DiscogsSecret"] ?? ""

        if key.isEmpty || secret.isEmpty {
            print("Discogs API key or secret is empty")
        }

        request.addValue("Discogs key=\(key), secret=\(secret)", forHTTPHeaderField: "Authorization")

        artistListDataTask = URLSession.shared.dataTask(with: request) {
            data, response, error in

            if error != nil {
                print("Failed to perform search. Error=\(error!)")
                return
            }

            self.artistListDataTask = nil

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
                        DispatchQueue.main.async {
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: DatabaseSearchModel.artistListUpdateNotification),
                                                            object: nil)
                        }
                    }
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }

        artistListDataTask!.resume()
    }

    private func downloadThumbnail(_ row: Int) {
        let request = URLRequest(url: artists[row].thumbnailUrl!)
        let task = URLSession.shared.dataTask(with: request) {
            data, response, error in

            if error != nil {
                print("Failed to download artist thumbnail. Error: \(error!)")
                return
            }

            self.thumbnailDataTasks[row] = nil

            if let thumbnail = UIImage(data: data!) {
                self.artists[row].thumbnailImage = thumbnail
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: DatabaseSearchModel.artistThumbnailUpdateNotification),
                                                    object: nil,
                                                    userInfo: [DatabaseSearchModel.artistThumbnailIndex: row])
                }
            }
        }

        thumbnailDataTasks[row] = task

        task.resume()
    }
}
