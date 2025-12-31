//
//  DetailsVC.swift
//  ImageBookApp
//
//  Created by Togrul Hashimov on 29.12.25.
//

import UIKit
import CoreData

class DetailsVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var artistText: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var yearText: UITextField!
    
    var chosenImage = ""
    var chosenImageId : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
            nameText.addTarget(self, action: #selector(textFieldsChanged), for: .editingChanged)
            artistText.addTarget(self, action: #selector(textFieldsChanged), for: .editingChanged)
            yearText.addTarget(self, action: #selector(textFieldsChanged), for: .editingChanged)

           updateSaveButtonState()
        
        getData()
        
        navigationItem.title = "Add New"
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(gestureRecognizer)
        
       
        let imageRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapImageView))
        imageView.addGestureRecognizer(imageRecognizer)
    }
    
    func getData() {
        if chosenImage != "" {
            imageView.isUserInteractionEnabled = false
            saveButton.isHidden = true
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Images")
            if let idString = chosenImageId?.uuidString {
                fetchRequest.predicate = NSPredicate(format: "id = %@", idString)
            }
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
                        if let pic = result.value(forKey: "image") as? Data {
                            let image = UIImage(data: pic)
                            imageView.image = image
                        }
                    }
                }
            } catch {
                print("error")
            }
            
            
            
        } else {
            imageView.isUserInteractionEnabled = true
            saveButton.isHidden = false
            saveButton.isEnabled = false
        }
    }
    

    @IBAction func saveButtonClicked(_ sender: Any) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let newImages = NSEntityDescription.insertNewObject(forEntityName: "Images", into: context)
        
        newImages.setValue(nameText.text, forKey: "name")
        newImages.setValue(artistText.text, forKey: "artist")
        newImages.setValue(UUID(), forKey: "id")

        if let year = Int(yearText.text!) {
            newImages.setValue(year, forKey: "year")
        }
        
        if let data = imageView.image!.jpegData(compressionQuality: 0.5) {
            newImages.setValue(data, forKey: "image")
        }
        
        do {
            try context.save()
            print("success")
        } catch {
            print("error")
        }
        
        self.navigationController?.popViewController(animated: true)
        
            
    }
    
  
    
    // MARK: - imageRecognizer func
    
    
    @objc func didTapImageView() {
        let picker = UIImagePickerController()
        picker.delegate = self
        
        let alert = UIAlertController(title: "Choose image", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "📷 Camera", style: .default, handler: { (_) in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                picker.sourceType = .camera
                self.present(picker, animated: true, completion: nil)
            }
        }))
        
        alert.addAction(UIAlertAction(title: "📚 Photo Library", style: .default, handler: { (_) in
            picker.sourceType = .photoLibrary
            picker.allowsEditing = true
            self.present(picker, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                                      
        present(alert, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let edited =  info[.editedImage] as? UIImage {
            imageView.image = edited
        } else if let original = info[.originalImage] as? UIImage {
            imageView.image = original
            
        }
        
        updateSaveButtonState()
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    func updateSaveButtonState() {
        let nameEmpty = (nameText.text ?? "").trimmingCharacters(in: .whitespaces).isEmpty
        let artistEmpty = (artistText.text ?? "").trimmingCharacters(in: .whitespaces).isEmpty
        let yearEmpty = (yearText.text ?? "").trimmingCharacters(in: .whitespaces).isEmpty
        let imageIsEmpty = imageView.image == nil
        
        saveButton.isEnabled = !(nameEmpty || artistEmpty || yearEmpty || imageIsEmpty)
    }
    @objc func textFieldsChanged() {
        updateSaveButtonState()
    }
}
