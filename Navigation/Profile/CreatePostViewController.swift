
import UIKit
import Firebase
import FirebaseFirestore
import FirebaseStorage

class CreatePostViewController: UIViewController, UIGestureRecognizerDelegate {
    
    var didSendEventClosure: ((CreatePostViewController.Event) -> Void)?
    
    private enum LocalizedKeys: String {
        case publishPost = "publishPost"
        case addImage = "addImage"
        case postText = "postText"
    }
    
    private let firestoreManager = FirestoreManager()
    
    private let storage = Storage.storage().reference()
    
    private var imageUrlString = ""
    
    private lazy var previewImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var userNameLabel: UILabel = {
        let label = UILabel()
        label.text = ~LocalizedKeys.postText.rawValue
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.createColor(lightMode: .black, darkMode: .white)
        return label
    }()
    
    private lazy var descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isEditable = true
        textView.backgroundColor = .systemGray6
        textView.textColor = UIColor.createColor(lightMode: .black, darkMode: .white)
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.autocapitalizationType = .none
        return textView
    }()
    
    private lazy var buttonPublishPost: CustomButton = {
        let button = CustomButton(title: ~LocalizedKeys.publishPost.rawValue, titleColor: .white)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 4
        return button
    }()
    
    private lazy var buttonAddImage: CustomButton = {
        let button = CustomButton(title: ~LocalizedKeys.addImage.rawValue, titleColor: .white)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 4
        return button
    }()
    
    @objc private func photoButtonPressed() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.allowsEditing = true
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    private func layout() {
        view.backgroundColor = UIColor.createColor(lightMode: .white, darkMode: .black)
        view.addSubview(userNameLabel)
        NSLayoutConstraint.activate([
            userNameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            userNameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20)
        ])
        
        view.addSubview(descriptionTextView)
        NSLayoutConstraint.activate([
            descriptionTextView.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: 20),
            descriptionTextView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            descriptionTextView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            descriptionTextView.heightAnchor.constraint(equalToConstant: 150)
        ])
        
        view.addSubview(buttonPublishPost)
        NSLayoutConstraint.activate([
            buttonPublishPost.topAnchor.constraint(equalTo: descriptionTextView.bottomAnchor, constant: 20),
            buttonPublishPost.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            buttonPublishPost.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20)
        ])
        
        view.addSubview(buttonAddImage)
        NSLayoutConstraint.activate([
            buttonAddImage.topAnchor.constraint(equalTo: buttonPublishPost.bottomAnchor, constant: 20),
            buttonAddImage.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            buttonAddImage.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20)
        ])
        
        let width = UIScreen.main.bounds.width
        
        view.addSubview(previewImageView)
        NSLayoutConstraint.activate([
            previewImageView.topAnchor.constraint(equalTo: buttonAddImage.bottomAnchor, constant: 20),
            previewImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            previewImageView.heightAnchor.constraint(equalToConstant: width-80),
            previewImageView.widthAnchor.constraint(equalToConstant: width-80)
        ])
    }
    
    private func getImage() {
        
        let previewImageRef = storage.child("pictures/\(imageUrlString).png")
        
        previewImageRef.getData(maxSize: 2 * 2048 * 2048) { data, error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                let image = UIImage(data: data!)
                self.previewImageView.image = image
            }
        }
    }
    
    private func buttonAction() {
        buttonPublishPost.action = { [weak self] in
            let userEmail = Auth.auth().currentUser?.email ?? "Unknown email"
            let displayName = Auth.auth().currentUser?.displayName ?? "Unknown Author"
            let uid = Auth.auth().currentUser?.uid ?? "Unknown UID"
            
            let newPost = Post(authorUID: uid, author: userEmail, authorName: displayName, description: self?.descriptionTextView.text ?? "", date: Date(), image: self?.imageUrlString ?? "")
            self!.firestoreManager.addPost(post: newPost) { errorString in
                if errorString == nil {
                    self?.descriptionTextView.text = ""
                    self?.previewImageView.image = nil
                    self?.didSendEventClosure?(.creatingDone)
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
        navigationController?.navigationBar.isHidden = true
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(self.hideKeyboardOnSwipeDown))
        swipeDown.delegate = self
        swipeDown.direction =  UISwipeGestureRecognizer.Direction.down
        view.addGestureRecognizer(swipeDown)
    }
    
    @objc func hideKeyboardOnSwipeDown() {
        view.endEditing(true)
    }
}

extension CreatePostViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else { return }
        guard let imageData = image.pngData() else { return }
        let uuid = UUID().uuidString
        self.imageUrlString = uuid
        
        let uploadTask = storage.child("pictures/\(uuid).png").putData(imageData, metadata: nil) { _, error in
            guard error == nil else {
                print("Ошибка загрузки")
                return
            }
        }
        
        uploadTask.resume()
        
        let child = SpinnerViewController()
        addChild(child)
        child.view.frame = view.frame
        view.addSubview(child.view)
        child.didMove(toParent: self)
        
        uploadTask.observe(.success, handler: {_ in
            self.getImage()
            child.willMove(toParent: nil)
            child.view.removeFromSuperview()
            child.removeFromParent()
        })
        
    }
}

extension CreatePostViewController {
    enum Event {
        case creatingDone
    }
}


