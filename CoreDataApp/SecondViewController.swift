//
//  SecondViewController.swift
//  CoreDataApp
//
//  Created by YASIN AKCA on 17.04.2020.
//  Copyright © 2020 YASIN AKCA. All rights reserved.
//

import UIKit
import CoreData

class SecondViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var artistText: UITextField!
    @IBOutlet weak var yearText: UITextField!
    
    var chosenName: String?
    var chosenId: UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        imageView.isUserInteractionEnabled = true
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        imageView.addGestureRecognizer(recognizer)
        
        if chosenName != "" {
            //core data
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Art")
            let id = chosenId?.uuidString
            fetchRequest.predicate = NSPredicate(format: "id = %@", id!)
            fetchRequest.returnsObjectsAsFaults = false
            
            do {
                let results = try context.fetch(fetchRequest)
                if results.count > 0 {
                    for result in results as! [NSManagedObject] {
                        if let name = result.value(forKey: "name") as? String {
                            nameText.text = name
                        }
                        
                        if let artist = result.value(forKey: "artist") as? String {
                            artistText.text = artist
                        }
                        
                        if let year = result.value(forKey: "year") as? Int {
                            yearText.text = String(year)
                        }
                        
                        if let data = result.value(forKey: "image") as? Data {
                            let image = UIImage(data: data)
                            imageView.image = image
                        }
                    }
                }
            }catch {
                print("error")
            }
            
        }else {
            nameText.text = ""
            artistText.text = ""
            yearText.text = ""
            imageView.image = UIImage(named: "select.png")
        }
    }
    
    @objc func selectImage() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        self.present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func saveClicked(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let newArt = NSEntityDescription.insertNewObject(forEntityName: "Art", into: context)
        
        newArt.setValue(nameText.text!, forKey: "name")
        newArt.setValue(artistText.text!, forKey: "artist")
        newArt.setValue(UUID(), forKey: "id")
        if let year = Int(yearText.text!) {
            newArt.setValue(year, forKey: "year")
        }
        
        let data = imageView.image?.jpegData(compressionQuality: 0.5)
        newArt.setValue(data, forKey: "image")
        
        do {
            try context.save()
            print("success")
        }catch {
            print("error")
        }
        
        NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil)
        navigationController?.popViewController(animated: true)
    }
}
