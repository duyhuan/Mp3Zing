//
//  OnlineVC.swift
//  ZingMp3
//
//  Created by techmaster on 2/22/17.
//  Copyright © 2017 techmaster. All rights reserved.
//

import UIKit

let kDOCUMENT_DIRECTORY_PATH = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.allDomainsMask, true).first

class OnlineVC: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableViewOnline: UITableView!
    
    var listSongs = [Song]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        getData()
    }
    
    func getData() {
        let data = NSData(contentsOf: URL(string: "http://mp3.zing.vn/bang-xep-hang/bai-hat-Viet-Nam/IWZ9Z08I.html")!)
        let doc = TFHpple(htmlData: data as Data!)
        if let elements = doc?.search(withXPathQuery: "//h3[@class='title-item']/a") as? [TFHppleElement] {
            for element in elements {
                DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async(execute: { 
                    let id = self.getID(path: element.object(forKey: "href") as NSString)
                    let url = URL(string: "http://api.mp3.zing.vn/api/mobile/song/getsonginfo?keycode=fafd463e2131914934b73310aa34a23f&requestdata={\"id\":\"\(id)\"}".addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)
                    var stringData = ""
                    do {
                        stringData = try String(contentsOf: url!)
                    } catch let error as NSError {
                        print(error)
                    }
                    let json = self.convertStringToDictionary(string: stringData)
                    if json != nil {
                        self.addSongToList(json: json!)
                    } else {
                        print("json is nil")
                    }
                })
            }
        }
    }
    
    func getID(path: NSString) -> String {
        let id = (path.lastPathComponent as NSString).deletingPathExtension
        return id
    }
    
    func convertStringToDictionary(string: String) -> [String: AnyObject]? {
        if let data = string.data(using: String.Encoding.utf8) {
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers)
                return json as? [String : AnyObject]
            } catch let error as NSError {
                print(error)
            }
        }
        return nil
    }
    
    func addSongToList(json: [String: AnyObject]) {
        let title = json["title"] as! String
        let artist = json["artist"] as! String
        let thumbnailOnlinePath = json["thumbnail"] as! String
        let sourceOnline = json["source"]?["128"] as! String
        
        let currentSong = Song(title: title, artist: artist, thumbnailOnlinePath: thumbnailOnlinePath, sourceOnline: sourceOnline)
        listSongs.append(currentSong)
        reloadTableView()
    }
    
    func reloadTableView() {
        DispatchQueue.main.async { 
            self.tableViewOnline.reloadData()
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
        let edit = UITableViewRowAction(style: .normal, title: "Download") { (action, index) in
            DispatchQueue.global(qos: .default).async(execute: { 
                self.downloadSong(index: indexPath.row)
            })
            self.reloadTableView()
        }
        edit.backgroundColor = UIColor(red: 248/255, green: 55/255, blue: 186/255, alpha: 1.0)
        return [edit]
    }
    
    func downloadSong(index: Int) {
        if let dir = kDOCUMENT_DIRECTORY_PATH {
            let pathToWriteSong = "\(dir)/\(listSongs[index].title)"
            do {
                try FileManager.default.createDirectory(atPath: pathToWriteSong, withIntermediateDirectories: false, attributes: nil)
            } catch let error as NSError {
                print(error)
            }
            
            let dataSong = NSData(contentsOf: URL(string: listSongs[index].sourceOnline)!)
            writeDataToPath(data: dataSong!, path: "\(pathToWriteSong)/\(listSongs[index].title).mp3")
            
            
            
            writeInfoSong(song: listSongs[index], path: pathToWriteSong)
        }
    }
    
    func writeDataToPath(data: NSObject, path: String) {
        if let dataToWrite = data as? NSData {
            dataToWrite.write(toFile: path, atomically: true)
        } else if let dataInfo = data as? NSDictionary {
            dataInfo.write(toFile: path, atomically: true)
        }
    }
    
    func writeInfoSong(song: Song, path: String) {
        let dicData = NSMutableDictionary()
        dicData.setValue(song.title, forKey: "title")
        dicData.setValue(song.artist, forKey: "artist")
        dicData.setValue("/\(song.title)/thumbnail.png", forKey: "thumbnailLocal")
        dicData.setValue(song.sourceOnline, forKey: "sourceOnline")
        
        writeDataToPath(data: dicData, path: "\(path)/Info.plist")
        //dicData.write(toFile: "\(path)/Info.plist", atomically: true)
        
        let dataThumbnail = NSData(data: UIImagePNGRepresentation(song.thumbnail)!)
        writeDataToPath(data: dataThumbnail, path: "\(path)/thumbnail.png")
    }
    
}
