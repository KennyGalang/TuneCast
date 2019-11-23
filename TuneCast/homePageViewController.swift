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

class homePageViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var profilePhoto: UIImageView!
    @IBOutlet weak var loader: UIImageView!
    @IBOutlet weak var loaderView: UIView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userPoints: UILabel!
    @IBOutlet weak var modelName: UIDevice!
    @IBOutlet weak var phoneName: UILabel!
    
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
        DispatchQueue.main.async {
            let uploadRef = Storage.storage().reference(withPath: "profilePhotos/\(myAccount.email).png")
            guard let imageData = image.jpegData(compressionQuality: 0.7) else {return}
            let metaData = StorageMetadata.init()
            metaData.contentType = "image/png"
            uploadRef.putData(imageData, metadata: metaData){ (downloadMetaData, error) in
                if let error = error{
                    print("Error, \(error)")
                } else {
                    myAccount.profilePhotos[myAccount.email] = imageData
                    print("Succesful upload \(String(describing: downloadMetaData))")
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
        self.userPoints.text = String(myAccount.points)
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



