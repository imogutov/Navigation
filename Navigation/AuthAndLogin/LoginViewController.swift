
import UIKit
import Firebase

class LoginViewController: UIViewController {
    
    var didSendEventClosure: ((LoginViewController.Event) -> Void)?
    
    private let db = Firestore.firestore()
    
    private enum LocalizedKeys: String {
        case loginLabelSingUp = "loginLabeleSignUp"
        case logIn = "logIn"
        case emailTextFieldText = "emailTextFieldText"
        case password = "password"
        case loginLabelRegister = "loginLabelRegister"
        case signUp = "signUp"
        case blankFields = "blankFields"
        case tryAgain = "tryAgain"
        case error = "error"
        case done = "done"
        case successReg = "successRegistration"
        case pleaseLogin = "pleaseLogin"
        case enterNickname = "enterNickname"
        case enterNickAndLogin = "enterNickAndLogin"
        case statusNotSet = "statusNotSet"
    }
    
    private var signUp: Bool = true {
        willSet {
            if newValue {
                signUpButton.setTitle(~LocalizedKeys.signUp.rawValue, for: .normal)
                logInLabel.text = ~LocalizedKeys.loginLabelSingUp.rawValue
                buttonLogIn.setTitle(~LocalizedKeys.logIn.rawValue, for: .normal)
                print("singUP")
            } else {
                signUpButton.setTitle(~LocalizedKeys.logIn.rawValue, for: .normal)
                logInLabel.text = ~LocalizedKeys.loginLabelRegister.rawValue
                buttonLogIn.setTitle(~LocalizedKeys.signUp.rawValue, for: .normal)
                print("logIN")
            }
        }
    }
    
    private lazy var logoImageView: UIImageView = {
        let logoImageView = UIImageView(image: UIImage(named: "logo"))
        logoImageView.layer.masksToBounds = true
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        return logoImageView
    }()
    
    private let stackView = UIStackView()
    
    private var emailTextField: UITextField = {
        let emailTextField = UITextField()
        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        emailTextField.placeholder = ~LocalizedKeys.emailTextFieldText.rawValue
        emailTextField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        emailTextField.indent(size: 10)
        emailTextField.backgroundColor = .systemGray6
        emailTextField.textColor = UIColor.createColor(lightMode: .black, darkMode: .white)
        emailTextField.font = UIFont.systemFont(ofSize: 16)
        emailTextField.autocapitalizationType = .none
        return emailTextField
    }()
    
    private lazy var passwordTextField: UITextField = {
        let passwordTextField = UITextField()
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        passwordTextField.placeholder = ~LocalizedKeys.password.rawValue
        passwordTextField.layer.borderWidth = 0.5
        passwordTextField.layer.borderColor = UIColor.lightGray.cgColor
        passwordTextField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        passwordTextField.indent(size: 10)
        passwordTextField.backgroundColor = .systemGray6
        passwordTextField.isSecureTextEntry = true
        passwordTextField.textColor = UIColor.createColor(lightMode: .black, darkMode: .white)
        passwordTextField.font = UIFont.systemFont(ofSize: 16)
        passwordTextField.autocapitalizationType = .none
        return passwordTextField
    }()
    
    private lazy var buttonLogIn: CustomButton = {
        let button = CustomButton(title: ~LocalizedKeys.logIn.rawValue, titleColor: .systemBlue)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var signUpButton: CustomButton = {
        let button = CustomButton(title: ~LocalizedKeys.signUp.rawValue, titleColor: .white)
        button.setBackgroundImage(UIImage(named: "blue_pixel"), for: UIControl.State.normal)
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        switch button.state {
        case .normal: button.alpha = 1
        case .selected: button.alpha = 0.8
        case .highlighted: button.alpha = 0.8
        case .disabled: button.alpha = 0.8
        default: break
        }
        return button
    }()
    
    private lazy var logInLabel: UILabel = {
        let label = UILabel()
        label.text = ~LocalizedKeys.loginLabelSingUp.rawValue
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.createColor(lightMode: .black, darkMode: .white)
        return label
    }()
    
    private let contentView: UIView = {
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        return contentView
    }()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private func alertToFillTextField() {
        let alert = UIAlertController(title: ~LocalizedKeys.blankFields.rawValue, message: ~LocalizedKeys.tryAgain.rawValue, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func alertAuthorization(message : String) {
        let alert = UIAlertController(title: ~LocalizedKeys.error.rawValue, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: ~LocalizedKeys.tryAgain.rawValue, style: .default))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func setupLogoIV() {
        let logoImageView = logoImageView
        contentView.addSubview(logoImageView)
        logoImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        logoImageView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        logoImageView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        logoImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 120).isActive = true
    }
    
    private func buttonAction() {
        
        signUpButton.action = { [weak self] in
            
            if self!.emailTextField.text?.isEmpty == true || self!.passwordTextField.text?.isEmpty == true {
                self?.alertToFillTextField()
            }
            
            if self?.signUp == true {
                
                Auth.auth().createUser(withEmail: self!.emailTextField.text!, password: self!.passwordTextField.text!) { result, error in
                    if error != nil {
                        let result = error?.localizedDescription as? String
                        if let res = result {
                            self?.alertAuthorization(message: res)
                        }
                    } else {
                        let uid = result?.user.uid ?? "unknownUser"
                        
                        self?.db.collection(uid).document("status").setData(["status": ~LocalizedKeys.statusNotSet.rawValue]) { err in
                            if let err = err {
                                print("Error writing document: \(err)")
                            } else {
                                print("Document successfully written!")
                            }
                            let alert = UIAlertController(title: ~LocalizedKeys.successReg.rawValue, message: ~LocalizedKeys.enterNickAndLogin.rawValue, preferredStyle: .alert)
                            alert.addTextField { textField in
                                textField.placeholder = ~LocalizedKeys.enterNickname.rawValue
                            }
                            
                            let okAction = UIAlertAction(title: "OK", style: .default) { action in
                                if let nickname = alert.textFields?[0].text,
                                   nickname != "" {
                                    let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                                    changeRequest?.displayName = nickname
                                    changeRequest?.commitChanges { error in
                                        guard error == nil else {
                                            print(error!.localizedDescription)
                                            return
                                        }
                                    }
                                }
                            }
                            alert.addAction(okAction)
                            self?.present(alert, animated: true, completion: nil)
                            self?.signUp = !self!.signUp
                        }
                    }
                }
            }
            
            if self?.signUp == false {
                
                Auth.auth().signIn(withEmail: self!.emailTextField.text!, password: self!.passwordTextField.text!) { result, error in
                    if error != nil {
                        let result = error?.localizedDescription as? String
                        if let res = result {
                            self?.alertAuthorization(message: res)
                        }
                    } else {
                        self?.didSendEventClosure?(.login)
                    }
                }
            }
        }
        
        buttonLogIn.action = { [weak self] in
            self?.signUp = !self!.signUp
        }
    }
    
    private func configureStackView() {
        contentView.addSubview(stackView)
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.layer.borderColor = UIColor.lightGray.cgColor
        stackView.layer.borderWidth = 0.5
        stackView.layer.cornerRadius = 10
        stackView.layer.masksToBounds = true
        stackView.addArrangedSubview(emailTextField)
        stackView.addArrangedSubview(passwordTextField)
        stackView.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 120).isActive = true
        stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16).isActive = true
        stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16).isActive = true
    }
    
    private func setupButton() {
        contentView.addSubview(signUpButton)
        signUpButton.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 16).isActive = true
        signUpButton.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor).isActive = true
        signUpButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16).isActive = true
        signUpButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16).isActive = true
        signUpButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    private func setupLabel() {
        view.addSubview(logInLabel)
        logInLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16).isActive = true
        logInLabel.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 100).isActive = true
        logInLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        view.addSubview(buttonLogIn)
        buttonLogIn.leadingAnchor.constraint(equalTo: logInLabel.trailingAnchor, constant: 6).isActive = true
        buttonLogIn.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 100).isActive = true
        buttonLogIn.heightAnchor.constraint(equalToConstant: 20).isActive = true
    }
    
    private func configureContentView() {
        let contentView = contentView
        let scrollView = scrollView
        scrollView.addSubview(contentView)
        contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
        contentView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
    }
    
    private func configureScrollView() {
        let scrollView = scrollView
        view.addSubview(scrollView)
        scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.tabBar.isHidden = true
        view.backgroundColor = UIColor.createColor(lightMode: .white, darkMode: .black)
        configureScrollView()
        configureContentView()
        setupLogoIV()
        configureStackView()
        buttonAction()
        setupLabel()
        setupButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(kbdShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        nc.addObserver(self, selector: #selector(kbdHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        let nc = NotificationCenter.default
        nc.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        nc.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func kbdShow(notification: NSNotification) {
        if let kbdSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            scrollView.contentInset.bottom = kbdSize.height
            scrollView.verticalScrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: kbdSize.height, right: 0)
        }
    }
    
    @objc private func kbdHide(notification: NSNotification) {
        scrollView.contentInset.bottom = .zero
        scrollView.verticalScrollIndicatorInsets = .zero
    }
}

extension UITextField {
    func indent(size:CGFloat) {
        self.leftView = UIView(frame: CGRect(x: self.frame.minX, y: self.frame.minY, width: size, height: self.frame.height))
        self.leftViewMode = .always
    }
}

extension LoginViewController {
    enum Event {
        case login
    }
}
