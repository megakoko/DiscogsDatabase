//
//  ArtistModel.swift
//  DiscogsDatabase
//
//  Created by Andy on 07/10/2018.
//  Copyright © 2018 Andy Chukavin. All rights reserved.
//

import Foundation
import UIKit

class ArtistModel {
    static let artistInfoUpdateNotification = "artistInfoUpdateNotification"
    static let artistReleasesUpdateNotification = "artistReleasesUpdateNotification"
    static let releaseThumbnailUpdateNotification = "releaseThumbnailUpdateNotification"
    static let releaseThumbnailIndex = "releaseThumbnailIndex"

    private var artistUrl: URL? = nil
    private (set) var profile: String? = nil
    private var artistReleases = [ArtistRelease]()

    private var artistDataTask: URLSessionDataTask?
    private var releasesDataTask: URLSessionDataTask?
    private var thumbnailDataTasks = [Int: URLSessionDataTask]()

    private var lastReleasesPage: Int? = nil

    func setArtistUrl(_ url: URL) {
        artistUrl = url

        clearData()
        downloadArtistInfo()
        downloadReleases(onPage: 1)
    }

    func releaseCount() -> Int {
        return artistReleases.count
    }

    func releaseAt(_ row: Int) -> ArtistRelease? {
        if row < 0 || row >= artistReleases.count {
            return nil
        }

        let release = artistReleases[row]

        if release.thumbnailImage == nil && release.thumbnailUrl != nil {
            downloadReleaseThumbnail(row)
        }

        return release
    }

    private func clearData() {
        artistReleases.removeAll()
        lastReleasesPage = nil

        for task in thumbnailDataTasks.values {
            task.cancel()
        }
        thumbnailDataTasks.removeAll()

        if artistDataTask != nil {
            artistDataTask?.cancel()
            artistDataTask = nil
        }

        if releasesDataTask != nil {
            releasesDataTask?.cancel()
            releasesDataTask = nil
        }
    }


    private func downloadArtistInfo() {
        let request = URLRequest(url: artistUrl!)

        artistDataTask = URLSession.shared.dataTask(with: request) {
            data, response, error in

            if error != nil {
                print("Failed to fetch artist data. Error=\(error!)")
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary {
                    var profile = json["profile"] as? String

                    if profile != nil {
                        profile = profile?.trimmingCharacters(in: .whitespacesAndNewlines)
                    }
                    
                    self.profile = profile

                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: ArtistModel.artistInfoUpdateNotification),
                                                        object: nil)
                    }
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }

        artistDataTask?.resume()
    }

    private func downloadReleases(onPage page: Int) {
        var urlComponents = URLComponents(url: artistUrl!, resolvingAgainstBaseURL: false)
        if urlComponents == nil {
            return
        }

        urlComponents!.path += "/releases"
        urlComponents!.queryItems = [URLQueryItem(name: "page", value: "\(page)")]

        var releasesRequest = URLRequest(url: urlComponents!.url!)

        let key = ProcessInfo.processInfo.environment["DiscogsKey"] ?? ""
        let secret = ProcessInfo.processInfo.environment["DiscogsSecret"] ?? ""

        if key.isEmpty || secret.isEmpty {
            print("Discogs API key or secret is empty")
        }

        releasesRequest.addValue("Discogs key=\(key), secret=\(secret)", forHTTPHeaderField: "Authorization")

        releasesDataTask = URLSession.shared.dataTask(with: releasesRequest) {
            data, response, error in

            if error != nil {
                print("Failed to fetch artist's releases")
                return
            }

            self.lastReleasesPage = page

            do {
                if let json = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary {
                    if let releases = json["releases"] as? [[String:Any]] {
                        for release in releases {
                            let artistRelease = ArtistRelease(artist: release["artist"] as? String,
                                                              type: release["type"] as? String,
                                                              title: release["title"] as? String,
                                                              year: release["year"] as? Int,
                                                              thumbnailUrl: URL(string: release["thumb"] as? String ?? ""),
                                                              thumbnailImage: nil,
                                                              url: URL(string: release["resource_url"] as? String ?? ""))
                            self.artistReleases += [artistRelease]
                        }
                    }
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }

            DispatchQueue.main.async {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: ArtistModel.artistReleasesUpdateNotification),
                                                object: nil)

            }
        }

        releasesDataTask?.resume()
    }

    private func downloadReleaseThumbnail(_ row: Int) {
        let request = URLRequest(url: artistReleases[row].thumbnailUrl!)
        let task = URLSession.shared.dataTask(with: request) {
            data, response, error in

            if error != nil {
                print("Failed to download artist thumbnail. Error: \(error!)")
                return
            }

            self.thumbnailDataTasks[row] = nil

            if let thumbnail = UIImage(data: data!) {
                self.artistReleases[row].thumbnailImage = thumbnail
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: Notification.Name(rawValue: ArtistModel.releaseThumbnailUpdateNotification),
                                                    object: nil,
                                                    userInfo: [ArtistModel.releaseThumbnailIndex: row])
                }
            }
        }

        thumbnailDataTasks[row] = task

        task.resume()
    }
}
