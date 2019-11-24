//
//  getSongsViewController.swift
//  TuneCast
//
//  Created by CARFAX Ca on 2019-11-24.
//  Copyright © 2019 CARFAX Ca. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import Alamofire
import Spartan

struct songElement:Codable {
    var songName : String!
    var artistName : String!
    var trackId : String!
    var likes : Int!
    var username  : String!
    var email : String!
    var timestamp : String!
}

var search = ""


class songQueueTableCell: UITableViewCell {
    @IBOutlet weak var songName: UILabel!
    @IBOutlet weak var artistName: UILabel!
    @IBOutlet weak var userName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}

class getSongsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var searchArtist: UITextField!
    
    @IBAction func textInput(_ sender: UITextField) {
        search = searchArtist.text!
    }
    let cellSpacingHeight: CGFloat = 5
    
    func numberOfSections(in tableView: UITableView) -> Int {
           return self.songs.count
       }
       
       func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
           return cellSpacingHeight
       }
       
       func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int){
           view.tintColor = .clear
           let header = view as! UITableViewHeaderFooterView
           header.textLabel?.textColor = UIColor.white
       }
       
       func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
           return 1
       }
    
    var songs = [songElement]()
    var isDone = false
    func getSongs(hostEmail: String, completion: @escaping (_ message: String) -> Void){
        let db = Firestore.firestore()
        let ref = db.collection("hosts").whereField("email", isEqualTo: hostEmail)
        ref.getDocuments() {
            (querySnapshot, error) in
            if let error = error {
                print("Error getting host documents: \(error)")
            } else {
                for document in querySnapshot!.documents {
                    let hostRef = document.reference
                    //let state = document.data()["state"] as! Bool
                    //if state { // someone has added a new song to queue need to fetch and update tableview
                        self.getSongsHelper(ref: hostRef){(success) in
                            if success == "success" {
                                self.isDone = true
                                completion("success")
                            } else {
                                self.isDone = false
                                completion("failure")
                            }
                        
                    }
                }
            }
        }
    }
    func getSongsHelper(ref: DocumentReference?, completion: @escaping (_ message: String) -> Void){
        let songQueue = ref!.collection("songQueue").order(by: "likes", descending: true)
        songQueue.getDocuments() {
            (querySnapshotSongs, error) in
            if let error = error {
                print("Error getting song documents: \(error)")
            } else {
                for song in querySnapshotSongs!.documents {
                    let songName = song.data()["songName"] as! String
                    let artistName = song.data()["artistName"] as! String
                    let trackId = song.data()["trackID"] as! String
                    let likes = song.data()["likes"] as! Int
                    let username = song.data()["username"] as! String
                    let email = song.data()["email"] as! String
                    let time = song.data()["timestamp"] as! String
                    self.songs.append(songElement(songName: songName, artistName: artistName, trackId: trackId, likes: likes, username: username, email: email, timestamp: time))
                }
                completion("success")
            }
        }
    }
    
    override func viewDidLoad() {
        search = searchArtist.text!
        let hostEmail = myAccount.hostEmail
        print("the host EMAIL ISSSSSSSSSSS:  ", hostEmail)
        if hostEmail != ""{
            getSongs(hostEmail: hostEmail){ (success) in
                if success == "success"{
                    print("should be displaying these songs")
                    print(self.songs)
                    self.isDone = true
                    self.tableView.reloadData()
                }
                
            }
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        let hostEmail = myAccount.hostEmail
        if hostEmail != ""{
            getSongs(hostEmail: hostEmail){ (success) in
                if success == "success"{
                    self.isDone = true
                    self.tableView.reloadData()
                }
                
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
               let cell = tableView.dequeueReusableCell(withIdentifier: "songCell", for:indexPath) as! songQueueTableCell
                if isDone == true {
                    //print(self.songs[indexPath.section].songName)
                    cell.songName.text = songs[indexPath.section].songName
                    cell.userName.text = songs[indexPath.section].username
                    cell.artistName.text = songs[indexPath.section].artistName
                }
               cell.layer.borderColor = UIColor.black.cgColor
               return cell
           }
    func appendSongToPlaylist(userID: String, playlistID: String, trackUris: [String]){
           _ = Spartan.addTracksToPlaylist(userId: userID, playlistId: playlistID, trackUris: trackUris, success: { (snapshot) in
               // Do something with the snapshot
           }, failure: { (error) in
               print(error)
           })
       }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedSong = songs[indexPath.row]
        let playId = myAccount.playlistID
        var playID = playId as! String
        var tracks = [String]()
        tracks.append(selectedSong.trackId)
        appendSongToPlaylist(userID: "zynebbx", playlistID: playID, trackUris: tracks)
       }
    
}

struct Song {
    var id: String
    var name: String
    var mainImage: UIImage!
    var artist: String
    init(id: String, name: String, mainImage: UIImage, artist: String){
        self.id = id
        self.name = name
        self.mainImage = mainImage
        self.artist = artist
    }
}

class TableViewController: UITableViewController {
    var songs = [Song]()
    
    
//    var headers = ["Authorization": "Bearer \(AppDelegate.accessToken)" ]
    var headers = ["Authorization": " Bearer BQBCtYBbg8Q1gIt7V5B3Yf3l84iJsmu48MN676EpkG1B2UTgJ3mMTTNeWTZU22x9_qttOkhwWaRoAnH-HSQh4homIxcUdYXMvM3vq8TZoPauz0G1F_TWEYNzsHz5CNVXi96w-Iqxxp2uLuWHYNiXNDlKVFugEl2WjnpIEE5zHjq8f68ZmPmZVkcb9edWd4R3PhxtlQesMt45SzO12jbwTi2M42pgXavmOJK4dMkuweVhq0ECUOe46LqiucK4JweL7Az_mz6iAA"]
//    var searchURL = ""
//    let artist = search
    let searchURL = "https://api.spotify.com/v1/search?q=\(search)&type=track&limit=10&offset=5"
    typealias JSONStandard = [String: AnyObject]
    override func viewDidLoad() {
        super.viewDidLoad()
//        headers = ["Authorization": "Bearer \(AppDelegate.accessToken)" ]
        print(headers)
        print("Lol")
        print(search)
        
//        let searchURL = "https://api.spotify.com/v1/search?q=" + artist + "&type=track%2Cartist&market=US&limit=10&offset=5"
        print(searchURL)
        // Do any additional setup after loading the view.
        callAlamo(url: searchURL)
    }
    
    func callAlamo(url: String){
//        AF.request(url, method: .get, headers: headers).responseJSON(completionHandler: {
        
        Alamofire.request(searchURL, method: .get, headers: headers).responseJSON(completionHandler: {
            response in
            self.parseData(response.data!)
            
        })
    }
    
    func parseData(_ JSONData: Data){
        do{
            
            var readableJSON = try JSONSerialization.jsonObject(with: JSONData, options: .mutableContainers) as! JSONStandard
            if let tracks = readableJSON["tracks"] as? JSONStandard{
                if let items = tracks["items"] as? [[String : Any]]{
                    for song in items{
                        let name = song["name"]
                        let id = song["id"]
                        
//                        names.append(name as! String)
//                        idList.append(id as! String)
                        if let album = song["album"] as? JSONStandard{
                            if let images = album["images"] as? [JSONStandard]{
                                let imageData = images[0]
                                let mainImageURL = URL(string: imageData["url"] as! String)
                                let mainImageData = NSData(contentsOf: mainImageURL!)
                                if let artist = album["name"]{
                                    let mainImage = UIImage(data: mainImageData as! Data)
                                    songs.append(Song(id: id as! String, name: name as! String, mainImage: mainImage!, artist: artist as! String))
                                    print(Song(id: id as! String, name: name as! String, mainImage: mainImage!, artist: artist as! String))
                                    print("ok man", Song(id: id as! String, name: name as! String, mainImage: mainImage!, artist: artist as! String))
                                }
                                
                            }
                            
                        }
                        
                    }
                    tableView.reloadData()
                }
                
            }
//            print(songs)
            print(readableJSON)
        }
        catch{
            print(error)
        }
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songs.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        cell?.textLabel?.text = songs[indexPath.row].name
        cell?.imageView?.image = songs[indexPath.row].mainImage
        print("SONGS", songs)
//        let mainImageView = cell?.viewWithTag(3) as! UIImageView
//        mainImageView.image = songs[indexPath.row].mainImage
//        let mainLabel = cell?.viewWithTag(2) as! UILabel
//        mainLabel.text = songs[indexPath.row].name
        return cell!
    }
    func addSongToQueueHelper(song: songElement, completion: @escaping (_ message: String) -> Void){
        let db = Firestore.firestore()
        let hostRef = db.collection("hosts").whereField("email", isEqualTo: myAccount.hostEmail)
        hostRef.getDocuments() {
            (querySnapshot, error) in
            if let error = error {
                print("Error getting host documents: \(error)")
            } else {
                for document in querySnapshot!.documents {
                    let host = document.reference
                    self.addSongToQueue(ref: host, song: song)
                    completion("success")
                }
            }
        }
    }
    func addSongToQueue(ref: DocumentReference?, song: songElement){
        let docData : [String:Any] = [
            "songName"    : song.songName!,
            "artistName"  : song.artistName!,
            "trackID"     : song.trackId!,
            "likes"       : song.likes!,
            "username"    : song.username!,
            "email"       : song.email!,
            "timestamp"   : song.timestamp!
        ]
        _ = ref!.collection("songQueue").addDocument(data: docData){ err in
            if let err = err{
                print("error adding document: \(err)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
            }
        }
    }
   
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let trackId = songs[indexPath.row].id
        let artist = songs[indexPath.row].artist
        let name = songs[indexPath.row].name
        
        let newSongElement = songElement(songName: name, artistName: artist, trackId: trackId, likes: 0, username: myAccount.UserName, email: myAccount.email, timestamp: "test")
        addSongToQueueHelper(song: newSongElement){ (success) in
            if success == "success"{
                print("added to firebase")
            }
        }
        print(songs[indexPath.row].id)
    }
    
    
    
}



