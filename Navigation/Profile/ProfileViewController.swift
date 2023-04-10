
import UIKit
import Firebase
import FirebaseStorage

class ProfileViewController: UIViewController, UIGestureRecognizerDelegate {
    
    private enum LocalizedKeys: String {
        case publicFirstPost = "publicFirstPost"
        case numberOfPosts = "numberOfPosts"
        case publicMore = "publicMore"
    }
    
    var didSendEventClosure: ((ProfileViewController.Event) -> Void)?
    
    private let storage = Storage.storage().reference()
    
    private let uid = Auth.auth().currentUser?.uid ?? "uid"
    
    private let profileHeaderView = ProfileHeaderView()
    
    private let firestoreManager = FirestoreManager()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(PostTableViewCell.self, forCellReuseIdentifier: String(describing: PostTableViewCell.self))
        
        tableView.register(Cell.self, forCellReuseIdentifier: "Cell")
        return tableView
    }()
    
    private lazy var logoutButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "rectangle.portrait.and.arrow.forward"), for: .normal)
        return button
    }()
    
    private lazy var changeAvatarButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(changeAvatarPressed), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "square.and.pencil"), for: .normal)
        return button
    }()
    
    @objc private func buttonPressed() {
        do {
            try Auth.auth().signOut()
        } catch {
            print(error.localizedDescription)
        }
        didSendEventClosure?(.logout)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        layout()
        view.backgroundColor = UIColor.createColor(lightMode: .white, darkMode: .black)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(self.hideKeyboardOnSwipeDown))
        swipeDown.delegate = self
        swipeDown.direction =  UISwipeGestureRecognizer.Direction.down
        view.addGestureRecognizer(swipeDown)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        reloadData()
    }
    
    @objc private func hideKeyboardOnSwipeDown() {
        view.endEditing(true)
    }
    
    private func reloadData() {
        firestoreManager.reloadPosts() { errorString in
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    private func layout() {
        profileHeaderView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(profileHeaderView)
        NSLayoutConstraint.activate([
            profileHeaderView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            profileHeaderView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            profileHeaderView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: profileHeaderView.bottomAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        view.addSubview(logoutButton)
        NSLayoutConstraint.activate([
            logoutButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            logoutButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
        
        view.addSubview(changeAvatarButton)
        NSLayoutConstraint.activate([
            changeAvatarButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100),
            changeAvatarButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16)
        ])
    }
    
    @objc private func changeAvatarPressed() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.allowsEditing = true
        present(imagePickerController, animated: true, completion: nil)
    }
}

extension ProfileViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
}

extension ProfileViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        if section == 1 {
            let user = Auth.auth().currentUser?.email ?? ""
            let myPosts = firestoreManager.posts.filter { $0.author == user }
            if myPosts.count != 0 {
                return myPosts.count
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let user = Auth.auth().currentUser?.email ?? ""
            let myPosts = firestoreManager.posts.filter { $0.author == user }
            let post = myPosts[indexPath.row]
            firestoreManager.deletePost(post: post) { error in
                self.firestoreManager.reloadPosts() { errorString in
                    if error == nil {
                        DispatchQueue.main.async {
                            self.tableView.deleteRows(at: [indexPath], with: .fade)
                        }
                    }
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            let user = Auth.auth().currentUser?.email ?? ""
            let myPosts = firestoreManager.posts.filter { $0.author == user }
            if myPosts.count == 0 {
                cell.textLabel?.text = ~LocalizedKeys.publicFirstPost.rawValue
            } else {
                cell.textLabel?.text = "\(~LocalizedKeys.numberOfPosts.rawValue) \(myPosts.count). \(~LocalizedKeys.publicMore.rawValue)"
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: PostTableViewCell.self), for: indexPath) as! PostTableViewCell
            let user = Auth.auth().currentUser?.email ?? ""
            let myPosts = firestoreManager.posts.filter { $0.author == user }
            if myPosts.count != 0 {
                cell.setupCell(post: myPosts[indexPath.row])
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
                cell.textLabel?.text = ~LocalizedKeys.publicFirstPost.rawValue
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            didSendEventClosure?(.createPost)
        }
    }
}

extension ProfileViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else { return }
        guard let imageData = image.pngData() else { return }
        
        let uploadTask = storage.child("avatars/\(uid)/avatar.png").putData(imageData, metadata: nil, completion: { _, error in
            guard error == nil else {
                print("Ошибка загрузки")
                return
            }
        })
        
        uploadTask.resume()
        uploadTask.observe(.success, handler: {_ in
            
            NotificationCenter.default.post(name: NSNotification.Name("avatarLoaded"), object: nil)
        })
    }
}

extension ProfileViewController {
    enum Event {
        case logout
        case createPost
    }
}





