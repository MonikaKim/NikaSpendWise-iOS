//
//  LoginViewController.swift
//  NikaSpendWise
//
//  Created by Kim Monika on 22/7/25.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {
  
  var onLoginSuccess: (() -> Void)?
  
  // MARK: - UI Components
  private let titleLabel: UILabel = {
    let label = UILabel()
    label.text = "NikaSpendWise"
    label.font = UIFont(name: "AvenirNext-Bold", size: 36)
    label.textColor = .white
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()
  
  private let emailField: UITextField = {
    let field = UITextField()
    field.placeholder = "Email"
    field.backgroundColor = UIColor(white: 1, alpha: 0.25)
    field.layer.cornerRadius = 12
    field.layer.borderWidth = 1
    field.layer.borderColor = UIColor(white: 1, alpha: 0.4).cgColor
    field.textColor = .white
    field.font = UIFont(name: "AvenirNext-Medium", size: 16)
    field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 0))
    field.leftViewMode = .always
    
    field.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [NSAttributedString.Key.foregroundColor: UIColor(white: 1, alpha: 0.7)])
    field.translatesAutoresizingMaskIntoConstraints = false
    return field
  }()
  
  private let passwordField: UITextField = {
    let field = UITextField()
    field.placeholder = "Password"
    field.backgroundColor = UIColor(white: 1, alpha: 0.25)
    field.layer.cornerRadius = 12
    field.layer.borderWidth = 1
    field.layer.borderColor = UIColor(white: 1, alpha: 0.4).cgColor
    field.isSecureTextEntry = true
    field.textColor = .white
    field.font = UIFont(name: "AvenirNext-Medium", size: 16)
    
    field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 0))
    field.leftViewMode = .always
    
    field.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSAttributedString.Key.foregroundColor: UIColor(white: 1, alpha: 0.7)])
    field.translatesAutoresizingMaskIntoConstraints = false
    return field
  }()
  
  private lazy var loginButton: UIButton = {
    let button = UIButton(type: .system)
    button.setTitle("Login", for: .normal)
    button.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 18)
    
    button.backgroundColor = UIColor(white: 1, alpha: 0.9) // Almost solid white for primary button
    button.setTitleColor(UIColor(red: 0.2, green: 0.6, blue: 0.8, alpha: 1.0), for: .normal)
    
    button.layer.cornerRadius = 12
    button.translatesAutoresizingMaskIntoConstraints = false
    button.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
    return button
  }()
  
  private lazy var goToSignUpButton: UIButton = {
    let button = UIButton(type: .system)
    button.setTitle("Don't have an account? Sign Up", for: .normal)
    button.titleLabel?.font = UIFont(name: "AvenirNext-Regular", size: 16)
    button.setTitleColor(.white, for: .normal)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.addTarget(self, action: #selector(goToSignUpTapped), for: .touchUpInside)
    return button
  }()
  
  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    setupBackground()
    setupUI()
    navigationController?.navigationBar.isHidden = true
  }
  
  // MARK: - UI Setup
  private func setupBackground() {
    let gradientLayer = CAGradientLayer()
    gradientLayer.colors = [
      UIColor(red: 221/255.0, green: 160/255.0, blue: 221/255.0, alpha: 1.0).cgColor,
      UIColor(red: 230/255.0, green: 230/255.0, blue: 250/255.0, alpha: 1.0).cgColor
    ]
    gradientLayer.locations = [0.0, 1.0]
    gradientLayer.frame = view.bounds
    view.layer.insertSublayer(gradientLayer, at: 0)
  }
  
  private func setupUI() {
    view.addSubview(titleLabel)
    view.addSubview(emailField)
    view.addSubview(passwordField)
    view.addSubview(loginButton)
    view.addSubview(goToSignUpButton)
    
    NSLayoutConstraint.activate([
      titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 80),
      titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      
      emailField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 60),
      emailField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
      emailField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
      emailField.heightAnchor.constraint(equalToConstant: 50),
      
      passwordField.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: 20),
      passwordField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
      passwordField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
      passwordField.heightAnchor.constraint(equalToConstant: 50),
      
      loginButton.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 40),
      loginButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
      loginButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
      loginButton.heightAnchor.constraint(equalToConstant: 50),
      
      goToSignUpButton.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 20),
      goToSignUpButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
    ])
  }
  
  // MARK: - Actions
  @objc private func loginButtonTapped() {
    guard let email = emailField.text, !email.isEmpty,
          let password = passwordField.text, !password.isEmpty else {
      AlertManager.showBasicAlert(on: self, title: "Error", message: "Please fill in all fields.")
      return
    }
    
    Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
      if let error = error {
        AlertManager.showBasicAlert(on: self!, title: "Login Error", message: error.localizedDescription)
      } else {
        print("User signed in successfully!")
        self?.onLoginSuccess?()
      }
    }
  }
  
  @objc private func goToSignUpTapped() {
    let signUpVC = SignUpViewController()
    signUpVC.onAccountCreated = { [weak self] in
      guard let self = self else { return }
      AlertManager.showBasicAlert(on: self, title: "Success!", message: "Your account has been created. Please log in.")
    }
    present(signUpVC, animated: true)
  }
}
