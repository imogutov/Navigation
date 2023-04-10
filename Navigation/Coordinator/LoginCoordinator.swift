
import Foundation
import UIKit
import Firebase

protocol LoginCoordinatorProtocol: Coordinator {
    func showLoginViewController()
}

class LoginCoordinator: LoginCoordinatorProtocol {
    
    weak var finishDelegate: CoordinatorFinishDelegate?
    
    var navigationController: UINavigationController
    
    var childCoordinators: [Coordinator] = []
    
    var type: CoordinatorType { .login }
        
    required init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
        
    func start() {
        if Auth.auth().currentUser == nil {
            showLoginViewController()
        } else {
            showAuthViewController()
        }
    }
    
    deinit {
        print("LoginCoordinator deinit")
    }
    
    func showAuthViewController() {
        let authVC: AuthenticationViewController = .init()
        authVC.didSendEventClosure = { [weak self] event in
            self?.finish()
        }
        navigationController.pushViewController(authVC, animated: true)
    }
    
    func showLoginViewController() {
        let loginVC: LoginViewController = .init()
        loginVC.didSendEventClosure = { [weak self] event in
            self?.finish()
        }
        
        navigationController.pushViewController(loginVC, animated: true)
    }
}

