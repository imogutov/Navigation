//
//  FeedViewController.swift
//  Navigation
//
//  Created by Иван Могутов on 17.04.2022.
//

import UIKit

class FeedViewController: UIViewController {
    
    
    var post = Post(title: "Мой пост")
    
    
    @objc private func buttonAction() {
        
        let postViewController = PostViewController()
        
        self.navigationController?.pushViewController(postViewController, animated: true)
        
        postViewController.titlePost = post.title
        
    }
    
    private lazy var button: UIButton = {
        
        let button = UIButton()
        
        button.backgroundColor = .systemBlue
        
        button.setTitle("Go to post", for: .normal)
        
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
        
    }()
    
    private func setupButton() {
        
        self.view.addSubview(self.button)
        
        self.button.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -100).isActive = true
        
        self.button.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20).isActive = true
        
        self.button.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20).isActive = true
        
        self.button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .systemBackground
        
        setupButton()
        // Do any additional setup after loading the view.
    }
    
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
