
import UIKit
import LocalAuthentication
import Firebase

class AuthenticationViewController: UIViewController {
    
    var didSendEventClosure: ((AuthenticationViewController.Event) -> Void)?
    
    private let authService = LocalAuthorizationService()
    private let authContext = LAContext()
    
    private func auth() {
        authService.canEvaluate { (canEvaluate, _, canEvaluateError) in
            guard canEvaluate else {
                alert(
                    title: "Error",
                    message: canEvaluateError?.localizedDescription ?? "Face ID/Touch ID may not be configured, try again",
                    okActionTitle: "OK!"
                )
                return
            }
            
            authService.evaluate { [weak self] (success, error) in
                guard success else {
                    alert(
                        title: "Error",
                        message: error?.localizedDescription ?? "Face ID/Touch ID may not be configured",
                        okActionTitle: "OK!")
                    return
                }
                self?.didSendEventClosure?(.login)
            }
        }
        
        func alert(
            title: String,
            message: String,
            okActionTitle: String
        ) {
            let alertView = UIAlertController(
                title: title,
                message: message,
                preferredStyle: .alert
            )
            let okAction = UIAlertAction(
                title: okActionTitle,
                style: .default
            )
            alertView.addAction(okAction)
            present(
                alertView,
                animated: true
            )
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        self.navigationController?.tabBarController?.tabBar.isHidden = true
        auth()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.tabBarController?.viewControllers?.remove(at: 0)
    }
}

extension AuthenticationViewController {
    enum Event {
        case login
    }
}
