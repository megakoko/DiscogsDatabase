//
//  DatabaseSearchController
//  DiscogsDatabase
//
//  Created by Andy Chukavin on 24/11/2017.
//  Copyright © 2017 Andy Chukavin. All rights reserved.
//

import UIKit

class DatabaseSearchController: UIViewController, UITableViewDataSource, UITextFieldDelegate {
    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var tableView: UITableView!

    private var model: DatabaseSearchModel!

    override func viewDidLoad() {
        super.viewDidLoad()

        model = DatabaseSearchModel()

        NotificationCenter.default.addObserver(forName: Notification.Name(rawValue: DatabaseSearchModel.artistListUpdateNotification),
                                               object: nil,
                                               queue: nil) { _ in
            self.tableView.reloadData()
        }

        NotificationCenter.default.addObserver(forName: Notification.Name(rawValue: DatabaseSearchModel.artistThumbnailUpdateNotification),
                                               object: nil,
                                               queue: nil) {
            if let row = $0.userInfo?[DatabaseSearchModel.artistThumbnailIndex] as? Int {
                let indexPath = IndexPath(row: row, section: 0)
                self.tableView.reloadRows(at: [indexPath], with: .none)
            }
        }

        if let defaultSearchText = ProcessInfo.processInfo.environment["DefaultSearchText"] {
            searchField.text = defaultSearchText
        }
        search()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func editingChanged(_ sender: Any) {
        search()
    }

    @objc private func search() {
        model.search(searchField.text)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "artistSegue") {
            let path = tableView.indexPathForSelectedRow
            if let artist = model.artist(path!.row) {
                segue.destination.title = artist.title
                if artist.url != nil {
                    if let artistView = segue.destination as? ArtistViewController {
                        artistView.setArtistUrl(artist.url!)
                    }
                }
            }

            navigationController?.setNavigationBarHidden(false, animated: true)
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.artistCount()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "artistCellIdentifier", for: indexPath) as! DatabaseSearchCell
        let row = indexPath.row

        if let artist = model.artist(row) {
            cell.nameLabel.text = artist.title
            cell.thumbnailView.image = artist.thumbnailImage ?? UIImage(named: "no_image")
        }

        return cell
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchField.resignFirstResponder()
        return true
    }
}
