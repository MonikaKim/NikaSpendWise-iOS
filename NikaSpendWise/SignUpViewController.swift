//
//  SignUpViewController.swift
//  NikaSpendWise
//
//  Created by Kim Monika on 22/7/25.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class SignUpViewController: UIViewController {
  
  var onAccountCreated: (() -> Void)?
  
  // MARK: - UI Components
  private let titleLabel: UILabel = {
    let label = UILabel()
    label.text = "Create Account"
    label.font = UIFont(name: "AvenirNext-Bold", size: 32)
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
    field.keyboardType = .emailAddress
    field.autocapitalizationType = .none
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
    field.placeholder = "Password (min. 6 characters)"
    field.backgroundColor = UIColor(white: 1, alpha: 0.25)
    field.layer.cornerRadius = 12
    field.layer.borderWidth = 1
    field.layer.borderColor = UIColor(white: 1, alpha: 0.4).cgColor
    field.isSecureTextEntry = true
    field.textColor = .white
    field.font = UIFont(name: "AvenirNext-Medium", size: 16)
    field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 0))
    field.leftViewMode = .always
    field.attributedPlaceholder = NSAttributedString(string: "Password (min. 6 characters)", attributes: [NSAttributedString.Key.foregroundColor: UIColor(white: 1, alpha: 0.7)])
    field.translatesAutoresizingMaskIntoConstraints = false
    return field
  }()
  
  private lazy var createButton: UIButton = {
    let button = UIButton(type: .system)
    button.setTitle("Create Account", for: .normal)
    button.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 18)
    button.backgroundColor = UIColor(white: 1, alpha: 0.9)
    button.setTitleColor(UIColor(red: 0.1, green: 0.4, blue: 0.8, alpha: 1.0), for: .normal)
    button.layer.cornerRadius = 12
    button.translatesAutoresizingMaskIntoConstraints = false
    button.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
    return button
  }()
  
  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    setupBackground()
    setupUI()
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
    view.addSubview(createButton)
    
    NSLayoutConstraint.activate([
      titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
      titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      
      emailField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 50),
      emailField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
      emailField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
      emailField.heightAnchor.constraint(equalToConstant: 50),
      
      passwordField.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: 20),
      passwordField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
      passwordField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
      passwordField.heightAnchor.constraint(equalToConstant: 50),
      
      createButton.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 40),
      createButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
      createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
      createButton.heightAnchor.constraint(equalToConstant: 50)
    ])
  }
  
  // MARK: - Actions
  @objc private func createButtonTapped() {
    guard let email = emailField.text, !email.isEmpty,
          let password = passwordField.text, !password.isEmpty else {
      AlertManager.showBasicAlert(on: self, title: "Error", message: "Please fill in all fields.")
      return
    }
    
    Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
      guard let self = self else { return }
      if let error = error {
        AlertManager.showBasicAlert(on: self, title: "Account Error", message: error.localizedDescription)
        return
      }
      
      guard let userId = authResult?.user.uid else { return }
      print("SIGNUP: Attempting to create document for userId: \(userId)")
      
      let db = Firestore.firestore()
      
      // THIS IS THE CORRECTED LINE
      db.collection("users").document(userId).setData(["totalExpense": 0.0]) { err in
        if let err = err {
          print("SIGNUP ERROR: \(err.localizedDescription)")
          AlertManager.showBasicAlert(on: self, title: "Database Error", message: "Error: \(err.localizedDescription)")
        } else {
          print("SIGNUP SUCCESS: User document created.")
          self.dismiss(animated: true) {
            self.onAccountCreated?()
          }
        }
      }
    }
  }
}
