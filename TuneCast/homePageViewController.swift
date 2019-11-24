//
//  homePageViewController.swift
//  TuneCast
//
//  Created by CARFAX Ca on 2019-10-20.
//  Copyright © 2019 CARFAX Ca. All rights reserved.
//
import Foundation
import UIKit
import Firebase
import CoreLocation
import Geofirestore
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

class homePageViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIGestureRecognizerDelegate {
    var hostId: String!
    let locManager = CLLocationManager()
    public static var authorizationToken: String?
    public static var loggingEnabled: Bool = true
    var loginUrl: URL?
    @IBOutlet weak var profilePhoto: UIImageView!
    @IBOutlet weak var loader: UIImageView!
    @IBOutlet weak var loaderView: UIView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userPoints: UILabel!
    @IBOutlet weak var modelName: UIDevice!
    @IBOutlet weak var phoneName: UILabel!
    @IBOutlet weak var connectToHost: UIButton!
    @IBOutlet weak var createHost: UIButton!
    
    func openCamera() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
        else
        {
            let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    func openGallery() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary){
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
        }
        else
        {
            let alert  = UIAlertController(title: "Warning", message: "You don't have permission to access gallery.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        guard let image = info[.editedImage] as? UIImage else {
            print("No image found")
            return
        }
        DispatchQueue.main.async {
            self.profilePhoto.image = image
            self.profilePhoto.setNeedsDisplay()
        }
//        DispatchQueue.main.async {
//            let uploadRef = Storage.storage().reference(withPath: "profilePhotos/\(myAccount.email).png")
//            guard let imageData = image.jpegData(compressionQuality: 0.7) else {return}
//            let metaData = StorageMetadata.init()
//            metaData.contentType = "image/png"
//            uploadRef.putData(imageData, metadata: metaData){ (downloadMetaData, error) in
//                if let error = error{
//                    print("Error, \(error)")
//                } else {
//                    myAccount.profilePhotos[myAccount.email] = imageData
//                    print("Succesful upload \(String(describing: downloadMetaData))")
//                }
//            }
//        }
    }
    func createHostRef(playlistID: String,completion: @escaping (_ message: String) -> Void){
        let db = Firestore.firestore()
        var ref:DocumentReference? = nil
        let docData : [String:Any] = [
            "email" : myAccount.email,
            "username" : myAccount.UserName,
            "playlistID" : playlistID
            ]
        ref = db.collection("hosts").addDocument(data: docData) { err in
            if let err = err {
                print("error adding document: \(err)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
                self.hostId = ref!.documentID
                completion("success")
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
        let songRef = ref!.collection("songQueue").addDocument(data: docData){ err in
            if let err = err{
                print("error adding document: \(err)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
            }
        }
    }
    func updateLikes(){
        
    }
    func appendSongToPlaylist(userID: String, playlistID: String, trackUris: [String]){
        _ = Spartan.addTracksToPlaylist(userId: userID, playlistId: playlistID, trackUris: trackUris, success: { (snapshot) in
            // Do something with the snapshot
        }, failure: { (error) in
            print(error)
        })
    }
    func createPlaylist(userID: String, name: String){
        _ = Spartan.createPlaylist(userId: userID, name: name, isPublic: true, isCollaborative: false, success: { (playlist) in
            // Do something with the playlist
        }, failure: { (error) in
            print(error)
        })
    }
    @IBAction func joinHost(_ sender: Any) {
        let newToken = "BQC3wYhc4B3FzUJaW1a6RmjsNSYgcWkyx37IVNLSiTQcbX07-HUDQg3jvHs505xAppCKuNe0fSC4zF5XRPFxP80GlZakElMJMRFJJBc1QgD7PYEFaglt6WgJtiVlEw1OQV_IlpzkXTJwVciE_xlPuU_ShPqS4GRwEPfPUTiHvDGYznwtEIPAPTm8X1If0SHd0EoiZyPunE7WHK45Oihylgt0TKavcdl7v52T31ZRziiKaS1Oj-EBd_d-tMHHZWDrdzab8hmYnQ"
        Spartan.authorizationToken = newToken
        Spartan.loggingEnabled = true
        var greatSuccess = Spartan.createPlaylist(userId: "zynebbx", name: "testing", isPublic: true, isCollaborative: false, success: { (playlist) in
            print("we fucking made a playlist boys")
            // Do something with the playlist
        }, failure: { (error) in
            print(error)
        })
    }
    
    @IBAction func createHostEvent(_ sender: Any) {
        var currentLocation: CLLocation!
        if( CLLocationManager.authorizationStatus() == .authorizedWhenInUse ||
            CLLocationManager.authorizationStatus() ==  .authorizedAlways){
            print("recognized create host event")
            currentLocation = locManager.location
            let geoFirestoreRef = Firestore.firestore().collection("hosts")
            let geoFirestore = GeoFirestore(collectionRef: geoFirestoreRef)
            createHostRef(playlistID: "Hello") { (success) in
                if success == "success" {
                    print("added host document to collection hosts")
                    geoFirestore.setLocation(location: currentLocation, forDocumentWithID: self.hostId) { (error) in
                        if let error = error {
                            print("An error occured: \(error)")
                        } else {
                            print("Saved location successfully!")
                            self.performSegue(withIdentifier: "goToHosts", sender: self)
                        }
                    }
                } else {
                    print("couldn't load top ten")
                }
            }
            
        }
    }
    
    @IBAction func changePicture(_ sender: UIButton) {
        let alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            self.openCamera()
        }))
        alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in
            self.openGallery()
        }))
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.loaderView.isHidden = false
        locManager.requestWhenInUseAuthorization()
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true;
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil;
        profilePhoto.layer.cornerRadius = profilePhoto.frame.size.width/2
        profilePhoto.layer.borderColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0).cgColor
        profilePhoto.layer.borderWidth = 2.4
        UIView.animate(withDuration: 1, animations: {
                           self.loader.transform = CGAffineTransform(rotationAngle: (20.0 * .pi) / 180.0)
                       }, completion: { (value: Bool) in
                           UIView.animate(withDuration: 1, animations: {
                               self.loader.transform = CGAffineTransform(rotationAngle: (-20.0 * .pi) / 180.0)
                           }, completion: {(value: Bool) in
                           UIView.animate(withDuration: 1, animations: {
                               self.loader.transform = CGAffineTransform(rotationAngle: (20.0 * .pi) / 180.0)
                           }, completion: {(value: Bool) in
                           UIView.animate(withDuration: 1, animations: {
                               self.loader.transform = CGAffineTransform(rotationAngle: (-20.0 * .pi) / 180.0)
                           }, completion: {(value: Bool) in
                            UIView.animate(withDuration: 1, animations: {
                                self.loader.transform = CGAffineTransform(rotationAngle: (-20.0 * .pi) / 180.0)
                            }, completion: {(value: Bool) in
                                UIView.animate(withDuration: 1, animations: {
                                    self.loader.transform = CGAffineTransform(rotationAngle: (-20.0 * .pi) / 180.0)
                                }, completion: {(value: Bool) in
                                    UIView.animate(withDuration: 1, animations: {
                                        self.loader.transform = CGAffineTransform(rotationAngle: (-20.0 * .pi) / 180.0)
                                    }, completion: {(value: Bool) in
                                        UIView.animate(withDuration: 1, animations: {
                                            self.loader.transform = CGAffineTransform(rotationAngle: (-20.0 * .pi) / 180.0)
                                        }, completion: {(value: Bool) in
                                            self.loaderView.isHidden = true
                           })
                        })
                    })
                })
                            })
                            })
                        })
        })
        self.userName.text = myAccount.UserName
        //self.userPoints.text = String(myAccount.points)
        //self.phoneName.text = modelName.systemName
    }
    
    override func viewWillAppear(_ animated: Bool) {
           super.viewWillAppear(animated)
           if let data = myAccount.profilePhotos[myAccount.email]{
               if data != Data(){
                   profilePhoto.image = UIImage(data: data)
               }else{
                   profilePhoto.image = UIImage(named: "SUV-Placeholder-Img")
               }
           } else{
               profilePhoto.image = UIImage(named: "SUV-Placeholder-Img")
           }
       }
}



