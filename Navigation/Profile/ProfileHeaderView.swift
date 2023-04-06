
import Foundation
import UIKit
import Firebase
import FirebaseStorage
import FirebaseFirestore


class ProfileHeaderView: UIView {
    
    private let userID = Auth.auth().currentUser?.displayName ?? "123333@we.ru"
    
    private let uid = Auth.auth().currentUser?.uid ?? "mHd5qbFLKKTtEVRm3buLGEni9Jm2"
    
    private let storage = Storage.storage()
    
    @objc private func getAvatar() {
        
        let avatarRef = storage.reference().child("avatars/\(uid)/avatar.png")
        
        avatarRef.getData(maxSize: 1 * 2048 * 2048) { data, error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                let image = UIImage(data: data!)
                self.avatarImageView.image = image
            }
        }
    }
    
    private enum LocalizedKeys: String {
        case setYourStatus = "setYourStatus"
        case setStatus = "setStatus"
    }
    
    public lazy var avatarImageView: UIImageView = {
        let avatarImageView = UIImageView()
        avatarImageView.layer.masksToBounds = true
        avatarImageView.layer.cornerRadius = 50
        avatarImageView.layer.borderWidth = 3
        avatarImageView.layer.borderColor = UIColor.white.cgColor
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        return avatarImageView
    }()
    
    private lazy var fullNameLabel: UILabel = {
        let fullNameLabel = UILabel()
        fullNameLabel.text = userID
        fullNameLabel.font = UIFont.boldSystemFont(ofSize: 18)
        fullNameLabel.translatesAutoresizingMaskIntoConstraints = false
        return fullNameLabel
    }()
    
    private lazy var statusLabel: UILabel = {
        let statusLabel = UILabel()
        statusLabel.text = ""
        statusLabel.textColor = UIColor.gray
        statusLabel.font = UIFont.systemFont(ofSize: 14)
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        return statusLabel
    }()
    
    private var statusText: String = ""
    
    private lazy var statusTextField: UITextField = {
        let statusTextField = UITextField()
        statusTextField.layer.borderWidth = 1
        statusTextField.layer.borderColor = UIColor.createColor(lightMode: .black, darkMode: .white).cgColor
        statusTextField.backgroundColor = UIColor.createColor(lightMode: .white, darkMode: .black)
        statusTextField.layer.backgroundColor = UIColor.createColor(lightMode: .white, darkMode: .black).cgColor
        statusTextField.layer.cornerRadius = 12
        statusTextField.textColor = UIColor.createColor(lightMode: .black, darkMode: .white)
        statusTextField.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        statusTextField.placeholder = ~LocalizedKeys.setYourStatus.rawValue
        statusTextField.indent(size: 10)
        statusTextField.translatesAutoresizingMaskIntoConstraints = false
        return statusTextField
    }()
    
    private lazy var setStatusButton: CustomButton = {
        let setStatusButton = CustomButton(title: ~LocalizedKeys.setStatus.rawValue, titleColor: .white)
        setStatusButton.backgroundColor = .systemBlue
        setStatusButton.translatesAutoresizingMaskIntoConstraints = false
        setStatusButton.layer.cornerRadius = 4
//        setStatusButton.layer.shadowOffset = CGSize(width: 4, height: 4)
//        setStatusButton.layer.shadowRadius = 4
//        setStatusButton.layer.shadowColor = UIColor.black.cgColor
//        setStatusButton.layer.shadowOpacity = 0.7
        return setStatusButton
    }()
    
    func layout() {
        
        addSubview(avatarImageView)
        addSubview(fullNameLabel)
        addSubview(setStatusButton)
        addSubview(statusLabel)
        addSubview(statusTextField)
        
        NSLayoutConstraint.activate([
            avatarImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            avatarImageView.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            avatarImageView.widthAnchor.constraint(equalToConstant: 100),
            avatarImageView.heightAnchor.constraint(equalToConstant: 100),
            
            fullNameLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 16),
            fullNameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            fullNameLabel.topAnchor.constraint(equalTo: topAnchor, constant: 27),
            
            setStatusButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            setStatusButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            setStatusButton.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 16),
            setStatusButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            
            statusLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 16),
            statusLabel.topAnchor.constraint(equalTo: fullNameLabel.bottomAnchor, constant: 5),
            
            statusTextField.widthAnchor.constraint(equalTo: widthAnchor, constant: -148),
            statusTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 132),
            statusTextField.bottomAnchor.constraint(equalTo: setStatusButton.topAnchor, constant: -16),
            statusTextField.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemGray6
        getAvatar()
        layout()
        buttonAction()
        NotificationCenter.default.addObserver(self, selector: #selector(getAvatar), name: NSNotification.Name("avatarLoaded"), object: nil)
        loadStatus()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loadStatus() {
        
        let db = Firestore.firestore()
        
        db.collection(uid).getDocuments { querySnapshot, error in
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            guard let querySnapshot else {
                print("querySnapshot = nil")
                return
            }
            for document in querySnapshot.documents {
                let status = document.data()["status"] as? String ?? ""
                self.statusLabel.text = status
            }
        }
    }
    
    func buttonAction() {
        setStatusButton.action = { [weak self] in
            let status = self?.statusTextField.text! ?? ""
            
            let db = Firestore.firestore()
            db.collection(self!.uid).document("status").setData(["status" : status]) { err in
                if let err = err {
                    print("Error writing document: \(err)")
                } else {
                    print("Document successfully written!")
                }
            }
            self!.loadStatus()
            self?.statusTextField.text = ""
        }
    }
}





