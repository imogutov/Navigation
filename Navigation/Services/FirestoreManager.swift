
import Foundation
import FirebaseFirestore

class Post {
    var firestoreID: String?
    var authorUID: String
    var author: String
    var authorName: String
    var description: String
    var date: Date
    var image: String
    
    init(authorUID: String, author: String, authorName: String, description: String, date: Date, image: String) {
        self.authorUID = authorUID
        self.author = author
        self.authorName = authorName
        self.description = description
        self.date = date
        self.image = image
    }
    
    init(document: QueryDocumentSnapshot) {
        self.firestoreID = document.documentID
        self.authorUID = document.data()["authorUID"] as? String ?? ""
        self.author = document.data()["author"] as? String ?? ""
        self.authorName = document.data()["authorName"] as? String ?? ""
        self.description = document.data()["description"] as? String ?? ""
        self.date = (document.data()["date"] as? Timestamp)?.dateValue() ?? Date(timeIntervalSince1970: 0)
        self.image = document.data()["image"] as? String ?? ""
    }
    
    var dictionaryForFirestore: [String: Any] {
        return ["authorUID": authorUID, "author" : author, "authorName" : authorName, "description" : description, "date" : date, "image" : image]
    }
}

class Status {
    var uid: String
    var status: String
    
    init(uid: String, status: String) {
        self.uid = uid
        self.status = status
    }
}

class FirestoreManager {
    
    var firebaseDB = Firestore.firestore()
    
    var posts: [Post] = []
    
    func reloadPosts(completion: @escaping (_ errorString: String?)->() ) {
        firebaseDB.collection("posts").getDocuments { querySnaphot, error in
            if let error {
                print(error)
                completion(error.localizedDescription)
                return
            }
            guard let querySnaphot else {
                print("querySnaphot = nil")
                completion(error?.localizedDescription)
                return
            }
            self.posts = []
            for document in querySnaphot.documents {
                let post = Post(document: document)
                self.posts.append(post)
                let sortedByValueDictionary = self.posts.sorted { $0.date > $1.date }
                self.posts = sortedByValueDictionary
            }
            
            completion(nil)
        }
    }
    
    func addPost(post: Post, completion: @escaping (_ errorString: String?) -> ()) {
        firebaseDB.collection("posts").addDocument(data: post.dictionaryForFirestore) { error in
            completion(error?.localizedDescription)
        }
    }
    
    func deletePost(post: Post, completion: @escaping (_ errorString: String?) -> ()) {
        guard let firestoreID = post.firestoreID else { return }
    
        firebaseDB.collection("posts").document(firestoreID).delete() { error in
            completion(error?.localizedDescription)
        }
    }
}
