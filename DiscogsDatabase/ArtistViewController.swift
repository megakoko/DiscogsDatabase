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

    private var artistReleases = [ArtistRelease]()

    private var lastReleasesPage: Int? = nil

    func setArtistUrl(_ url: URL) {
        artistUrl = url

        clearData()
        downloadArtistInfo()
        downloadReleases(onPage: 1)
    }

    private func clearData() {
        artistReleases.removeAll()
        lastReleasesPage = nil
    }

    private func downloadArtistInfo() {
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

    private func downloadReleases(onPage page: Int) {
        var urlComponents = URLComponents(url: artistUrl!, resolvingAgainstBaseURL: false)
        if urlComponents == nil {
            return
        }

        urlComponents!.path += "/releases"

        let query = URLQueryItem(name: "page", value: "\(page)")
        urlComponents!.queryItems = [query]

        print(urlComponents!.url!)
        let releasesRequest = URLRequest(url: urlComponents!.url!)
        let task = URLSession.shared.dataTask(with: releasesRequest) {
            data, response, error in

            if error != nil {
                print("Failed to fetch artist's releases")
                return
            }

            self.lastReleasesPage = page

            do {
                if let json = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary {
                    if let releases = json["releases"] as? [Any] {
                        for release in releases {
                            if let releaseObject = release as? [String: Any] {
                                let artistRelease = ArtistRelease(artist: releaseObject["artist"] as? String,
                                                                  type: releaseObject["type"] as? String,
                                                                  title: releaseObject["title"] as? String,
                                                                  year: releaseObject["year"] as? Int,
                                                                  thumbnailUrl: URL(string: releaseObject["thumb"] as? String ?? ""),
                                                                  url: URL(string: releaseObject["resource_url"] as? String ?? ""))
                                self.artistReleases += [artistRelease]
                            }
                        }
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
