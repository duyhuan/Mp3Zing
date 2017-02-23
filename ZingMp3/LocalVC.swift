//
//  LocalVC.swift
//  ZingMp3
//
//  Created by techmaster on 2/23/17.
//  Copyright © 2017 techmaster. All rights reserved.
//

import UIKit

class LocalVC: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableViewLocal: UITableView!
    
    var listSongs = [Song]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //getData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getData()
    }
    
    func getData() {
        listSongs.removeAll()
        if let dir = kDOCUMENT_DIRECTORY_PATH {
            do {
                let folders = try FileManager.default.contentsOfDirectory(atPath: dir)
                for folder in folders {
                    if folder != ".DS_Store" {
                        let infoPath = dir + "/" + folder + "/" + "/" + "Info.plist"
                        let info = NSDictionary(contentsOfFile: infoPath)
                        let title = info?["title"] as! String
                        let artist = info?["artist"] as! String
                        let thumbnail = info?["thumbnailLocal"] as! String
                        let sourceLocal = dir + "/" + folder + "/" + "\(title).mp3"
                        
                        let thumbnailLocal = dir + thumbnail
                        
                        let currentSong = Song(title: title, artist: artist, thumbnailLocal: thumbnailLocal, sourceLocal: sourceLocal)
                        
                        listSongs.append(currentSong)
                        tableViewLocal.reloadData()
                    }
                }
                //tableViewLocal.reloadData()
                
            } catch let error as NSError {
                print(error)
            }
            
        }
    }
    
    // Table view datasource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listSongs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let item = listSongs[indexPath.row]
        cell.imageView?.image = item.thumbnail
        cell.textLabel?.text = item.title
        cell.textLabel?.textColor = UIColor.white
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75.0
    }
    
    // Table view delegate
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "Delete") { (action, index) in
            self.removeSongAtIndex(index: indexPath.row)
        }
        delete.backgroundColor = UIColor(red: 248/255, green: 55/255, blue: 186/255, alpha: 1/0)
        return [delete]
    }
    
    func removeSongAtIndex(index: Int) {
        if let dir = kDOCUMENT_DIRECTORY_PATH {
            do {
                let path = dir + "/\(listSongs[index].title)"
                try FileManager.default.removeItem(atPath: path)
                listSongs.remove(at: index)
                tableViewLocal.reloadData()
            } catch let error as NSError {
                print(error)
            }
        }
    }

}
