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

    private var model: ArtistModel? = nil

    func setArtistUrl(_ url: URL) {
        if model == nil {
            model = ArtistModel()
        }
        model!.setArtistUrl(url)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        artistProfileLabel.text = nil

        NotificationCenter.default.addObserver(forName: Notification.Name(rawValue: ArtistModel.artistInfoUpdateNotification),
                                               object: nil,
                                               queue: nil) { _ in
            self.artistProfileLabel.text = self.model!.profile
        }


        NotificationCenter.default.addObserver(forName: Notification.Name(rawValue: ArtistModel.artistReleasesUpdateNotification),
                                               object: nil,
                                               queue: nil) { _ in
            self.tableView.reloadData()
        }

        NotificationCenter.default.addObserver(forName: Notification.Name(rawValue: ArtistModel.releaseThumbnailUpdateNotification),
                                               object: nil,
                                               queue: nil) {
            if let row = $0.userInfo?[ArtistModel.releaseThumbnailIndex] as? Int {
                let indexPath = IndexPath(row: row, section: 0)
                self.tableView.reloadRows(at: [indexPath], with: .none)
            }
        }
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
            if let release = model?.releaseAt(path!.row) {
                if release.url == nil {
                    return
                }

                let releaseViewController = segue.destination as! ReleaseViewController
                releaseViewController.setReleaseUrl(release.url!)
                releaseViewController.title = release.title

                navigationController?.setNavigationBarHidden(false, animated: true)
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model!.releaseCount()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "artistReleaseCellIdentifier", for: indexPath) as! ArtistReleaseCell

        let row = indexPath.row;
        if let artistRelease = model?.releaseAt(row) {
            cell.nameLabel.text = artistRelease.title
            cell.thumbnailView.image = artistRelease.thumbnailImage ?? UIImage(named: "no_image")
        }

        return cell
    }
}
