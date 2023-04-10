
import UIKit
import Firebase
import FirebaseStorage

class FeedViewController: UIViewController {
    
    private enum LocalizedKeys: String {
        case feed = "feed"
    }
    
    private let storage = Storage.storage().reference()
    
    private let uid = Auth.auth().currentUser?.uid ?? "uid"
    
    private let firestoreManager = FirestoreManager()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(FeedPostTableViewCell.self, forCellReuseIdentifier: String(describing: FeedPostTableViewCell.self))
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = ~LocalizedKeys.feed.rawValue
        layout()
        view.backgroundColor = UIColor.createColor(lightMode: .white, darkMode: .black)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        reloadData()
    }
    
    private func reloadData() {
        firestoreManager.reloadPosts() { errorString in
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    private func layout() {
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
}

extension FeedViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
}

extension FeedViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return firestoreManager.posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: FeedPostTableViewCell.self), for: indexPath) as! FeedPostTableViewCell
            cell.setupCell(post: firestoreManager.posts[indexPath.row])
            return cell
    }
}





