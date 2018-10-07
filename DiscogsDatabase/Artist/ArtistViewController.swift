//
//  ArtistViewCellViewController.swift
//  DiscogsDatabase
//
//  Created by Andy Chukavin on 29/11/2017.
//  Copyright © 2017 Andy Chukavin. All rights reserved.
//

import UIKit

class ArtistViewController: UIViewController, UITableViewDataSource {
    @IBOutlet weak var artistProfileLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!

    private var artistUrl: URL? = nil

    private var artistReleases = [ArtistRelease]()
    var thumbnailDownloads = [Int: URLSessionDataTask]()

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

        for task in thumbnailDownloads.values {
            task.cancel()
        }
        thumbnailDownloads.removeAll()
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
                    var profile = json["profile"] as? String

                    if profile != nil {
                        profile = profile?.trimmingCharacters(in: .whitespacesAndNewlines)
                    }

                    DispatchQueue.main.async {
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
        urlComponents!.queryItems = [URLQueryItem(name: "page", value: "\(page)")]

        var releasesRequest = URLRequest(url: urlComponents!.url!)

        let key = ProcessInfo.processInfo.environment["DiscogsKey"] ?? ""
        let secret = ProcessInfo.processInfo.environment["DiscogsSecret"] ?? ""

        if key.isEmpty || secret.isEmpty {
            print("Discogs API key or secret is empty")
        }

        releasesRequest.addValue("Discogs key=\(key), secret=\(secret)", forHTTPHeaderField: "Authorization")

        let task = URLSession.shared.dataTask(with: releasesRequest) {
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
                self.tableView.reloadData()
            }
        }

        task.resume()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        artistProfileLabel.text = nil
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // Update table's header size to fit artist's description
        if let headerView = tableView.tableHeaderView {
            let height = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
            var headerFrame = headerView.frame

            if height != headerFrame.size.height {
                headerFrame.size.height = height
                headerView.frame = headerFrame
                tableView.tableHeaderView = headerView
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "releaseSegue" {
            let path = tableView.indexPathForSelectedRow
            let release = artistReleases[path!.row]

            if release.url == nil {
                return
            }

            let releaseViewController = segue.destination as! ReleaseViewController
            releaseViewController.setReleaseUrl(release.url!)
            releaseViewController.title = release.title

            navigationController?.setNavigationBarHidden(false, animated: true)
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return artistReleases.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "artistReleaseCellIdentifier", for: indexPath) as! ArtistReleaseCell

        let row = indexPath.row;
        let artistRelease = artistReleases[row]

        cell.nameLabel.text = artistRelease.title

        if artistRelease.thumbnailImage == nil && artistRelease.thumbnailUrl != nil {
            let request = URLRequest(url: artistRelease.thumbnailUrl!)
            let task = URLSession.shared.dataTask(with: request) {
                data, response, error in

                if error != nil {
                    print("Failed to download artist thumbnail. Error: \(error!)")
                    return
                }

                self.thumbnailDownloads[row] = nil

                if let thumbnail = UIImage(data: data!) {
                    self.artistReleases[row].thumbnailImage = thumbnail
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}