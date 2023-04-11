
import UIKit
import Firebase
import FirebaseStorage
import FirebaseFirestore

class FeedPostTableViewCell: UITableViewCell {
    
    private let storage = Storage.storage()
    
    private let inCellView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var stringUrlImage = ""
    private var authorUID = ""
    
    private let imagePostView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFit
        view.backgroundColor = .systemGray6
        return view
    }()
    
    private let authorLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.numberOfLines = 2
        label.textColor = UIColor.createColor(lightMode: .black, darkMode: .white)
        return label
    }()
    
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 18)
        label.numberOfLines = 2
        label.textColor = UIColor.createColor(lightMode: .systemGray, darkMode: .lightGray)
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 0
        label.textColor = UIColor.createColor(lightMode: .black, darkMode: .white)
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor.createColor(lightMode: .systemGray, darkMode: .lightGray)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func getImage() {
        
        let avatarRef = storage.reference().child("pictures/\(stringUrlImage).png")
        
        avatarRef.getData(maxSize: 2 * 2048 * 2048) { data, error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                let image = UIImage(data: data!)
                self.imagePostView.image = image
            }
        }
    }
    
    private func getStatus() {
        let db = Firestore.firestore()
        
        db.collection(authorUID).getDocuments { querySnapshot, error in
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
                self.statusLabel.text = "(\(status))"
            }
        }
    }
    
    func setupCell(post: Post) {
        authorUID = post.authorUID
        authorLabel.text = post.authorName
        descriptionLabel.text = post.description
        dateLabel.text = post.date.formatted()
        stringUrlImage = post.image
        getImage()
        getStatus()
    }
    
    private func layout() {
        
        contentView.addSubview(inCellView)
        
        let screenWidth = UIScreen.main.bounds.width
        
        NSLayoutConstraint.activate([
            inCellView.topAnchor.constraint(equalTo: contentView.topAnchor),
            inCellView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            inCellView.widthAnchor.constraint(equalToConstant: screenWidth),
            inCellView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        contentView.addSubview(authorLabel)
        NSLayoutConstraint.activate([
            authorLabel.topAnchor.constraint(equalTo: inCellView.topAnchor, constant: 16),
            authorLabel.leadingAnchor.constraint(equalTo: inCellView.leadingAnchor, constant: 16)
        ])
        
        contentView.addSubview(statusLabel)
        NSLayoutConstraint.activate([
            statusLabel.topAnchor.constraint(equalTo: inCellView.topAnchor, constant: 16),
            statusLabel.leadingAnchor.constraint(equalTo: authorLabel.trailingAnchor, constant: 4),
            statusLabel.trailingAnchor.constraint(equalTo: inCellView.trailingAnchor, constant: -16),
        ])
        
        contentView.addSubview(imagePostView)
        NSLayoutConstraint.activate([
            imagePostView.topAnchor.constraint(equalTo: authorLabel.bottomAnchor, constant: 12),
            imagePostView.leadingAnchor.constraint(equalTo: inCellView.leadingAnchor, constant: 16),
            imagePostView.heightAnchor.constraint(equalToConstant: screenWidth-32),
            imagePostView.widthAnchor.constraint(equalToConstant: screenWidth-32)
        ])
        
        contentView.addSubview(descriptionLabel)
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: imagePostView.bottomAnchor, constant: 16),
            descriptionLabel.leadingAnchor.constraint(equalTo: inCellView.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: inCellView.trailingAnchor, constant: -16)
        ])
        
        contentView.addSubview(dateLabel)
        NSLayoutConstraint.activate([
            dateLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 16),
            dateLabel.leadingAnchor.constraint(equalTo: inCellView.leadingAnchor, constant: 16),
            dateLabel.bottomAnchor.constraint(equalTo: inCellView.bottomAnchor, constant: -16)
        ])
    }
}


