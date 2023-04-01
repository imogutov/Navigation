//
//  CreatePostViewController.swift
//  Navigation
//
//  Created by Ivan Mogutov on 28.03.2023.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseStorage

class CreatePostViewController: UIViewController {

    let firestoreManager = FirestoreManager()
    
    let storage = Storage.storage().reference()
    
    var imageUrlString = ""
    
    private lazy var previewImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var userNameLabel: UILabel = {
        let label = UILabel()
        label.text = Auth.auth().currentUser?.email ?? ""
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.createColor(lightMode: .black, darkMode: .white)
        return label
    }()
    
    private var descriptionTextField: UITextView = {
        let textField = UITextView()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.isEditable = true
//        textField.placeholder = "Введите текст вашего поста"
//        textField.indent(size: 10)
        textField.backgroundColor = .systemGray6
        textField.textColor = UIColor.createColor(lightMode: .black, darkMode: .white)
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.autocapitalizationType = .none
        return textField
    }()
    
    private lazy var buttonPublishPost: CustomButton = {
        let button = CustomButton(title: "Опубликовать пост", titleColor: .systemBlue)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var buttonAddImage: CustomButton = {
        let button = CustomButton(title: "Добавить изображение", titleColor: .systemBlue)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    @objc private func photoButtonPressed() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.allowsEditing = true
        present(imagePickerController, animated: true, completion: nil)
    }
    
    private func layout() {
        view.addSubview(userNameLabel)
        NSLayoutConstraint.activate([
            userNameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            userNameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20)
            ])
        
        view.addSubview(descriptionTextField)
        NSLayoutConstraint.activate([
            descriptionTextField.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: 20),
            descriptionTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            descriptionTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            descriptionTextField.heightAnchor.constraint(equalToConstant: 200)
        ])
        
        view.addSubview(buttonPublishPost)
        NSLayoutConstraint.activate([
            buttonPublishPost.topAnchor.constraint(equalTo: descriptionTextField.bottomAnchor, constant: 20),
            buttonPublishPost.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20)
        ])
        
        view.addSubview(previewImageView)
        NSLayoutConstraint.activate([
            previewImageView.topAnchor.constraint(equalTo: buttonPublishPost.bottomAnchor, constant: 20),
            previewImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            previewImageView.heightAnchor.constraint(equalToConstant: 50),
            previewImageView.widthAnchor.constraint(equalToConstant: 50)
            ])
        
        view.addSubview(buttonAddImage)
        NSLayoutConstraint.activate([
            buttonAddImage.topAnchor.constraint(equalTo: previewImageView.bottomAnchor, constant: 20),
            buttonAddImage.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20)
        ])
    }
    
    func getImage() {
        
        // Create a reference to the file you want to download
        let previewImageRef = storage.child("pictures/\(imageUrlString).png")
        
        // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
        previewImageRef.getData(maxSize: 1 * 2048 * 2048) { data, error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                // Data for "images/island.jpg" is returned
                let image = UIImage(data: data!)
                self.previewImageView.image = image
            }
        }
    }
    
    private func buttonAction() {
        buttonPublishPost.action = { [weak self] in
            let userEmail = Auth.auth().currentUser?.email ?? "Unknown Author"
            let newPost = Post(author: userEmail, description: self?.descriptionTextField.text ?? "", date: Date(), image: self?.imageUrlString ?? "")
            self!.firestoreManager.addPost(post: newPost) { errorString in
                if errorString == nil {
                    let profileViewController = ProfileViewController()
                    self?.navigationController?.pushViewController(profileViewController, animated: true)
                }
            }
        }
        
        buttonAddImage.action = {
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = .photoLibrary
            imagePickerController.allowsEditing = true
            self.present(imagePickerController, animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        layout()
        buttonAction()
        navigationController?.navigationBar.isHidden = false
    }
}

extension CreatePostViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else { return }
//        photoImageView.image = image
        guard let imageData = image.pngData() else { return }
        
        let uuid = UUID().uuidString
        self.imageUrlString = uuid
        
        let uploadTask = storage.child("pictures/\(uuid).png").putData(imageData, metadata: nil) { _, error in
            guard error == nil else {
                print("Ошибка загрузки")
                return
            }
//            self.storage.child("pictures/\(uuid).png").downloadURL(completion: { url, error in
//                guard let url = url, error == nil else { return }
//                
//                let urlString = url.absoluteString
//                print("Download URL: \(urlString)")
//                
//                self.imageUrlString = urlString
//            })
            print(uuid)
            
        }
        
        uploadTask.resume()
        uploadTask.observe(.success, handler: {_ in
            self.getImage()
        })
    }
}


