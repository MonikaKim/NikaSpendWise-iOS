//
//  AddExpenseViewController.swift
//  NikaSpendWise
//
//  Created by Kim Monika on 22/7/25.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class AddExpenseViewController: UIViewController {
  
  // MARK: - UI Components
  private let nameField: UITextField = {
    let field = UITextField()
    field.placeholder = "Expense Name (e.g., Coffee)"
    field.backgroundColor = UIColor(white: 1, alpha: 0.25)
    field.layer.cornerRadius = 12
    field.layer.borderWidth = 1
    field.layer.borderColor = UIColor(white: 1, alpha: 0.4).cgColor
    field.textColor = .white
    field.font = UIFont(name: "AvenirNext-Medium", size: 16)
    field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 0))
    field.leftViewMode = .always
    field.attributedPlaceholder = NSAttributedString(string: "Expense Name (e.g., Coffee)", attributes: [NSAttributedString.Key.foregroundColor: UIColor(white: 1, alpha: 0.7)])
    field.translatesAutoresizingMaskIntoConstraints = false
    return field
  }()
  
  private let amountField: UITextField = {
    let field = UITextField()
    field.placeholder = "Amount (e.g., 2.50)"
    field.backgroundColor = UIColor(white: 1, alpha: 0.25)
    field.keyboardType = .decimalPad
    field.textColor = .white
    field.layer.cornerRadius = 12
    field.layer.borderWidth = 1
    field.layer.borderColor = UIColor(white: 1, alpha: 0.4).cgColor
    field.font = UIFont(name: "AvenirNext-Medium", size: 16)
    field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 0))
    field.leftViewMode = .always
    field.attributedPlaceholder = NSAttributedString(string: "Amount (e.g., 2.50)", attributes: [NSAttributedString.Key.foregroundColor: UIColor(white: 1, alpha: 0.7)])
    field.translatesAutoresizingMaskIntoConstraints = false
    return field
  }()
  
  private lazy var saveButton: UIButton = {
    let button = UIButton(type: .system)
    button.setTitle("Save Expense", for: .normal)
    button.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 18)
    button.backgroundColor = .white
    button.setTitleColor(UIColor(red: 0.1, green: 0.4, blue: 0.8, alpha: 1.0), for: .normal)
    button.layer.cornerRadius = 8
    button.translatesAutoresizingMaskIntoConstraints = false
    button.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
    return button
  }()
  
  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    self.title = "Add Expense"
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
    view.addSubview(nameField)
    view.addSubview(amountField)
    view.addSubview(saveButton)
    
    NSLayoutConstraint.activate([
      nameField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
      nameField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
      nameField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
      nameField.heightAnchor.constraint(equalToConstant: 50),
      
      amountField.topAnchor.constraint(equalTo: nameField.bottomAnchor, constant: 15),
      amountField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
      amountField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
      amountField.heightAnchor.constraint(equalToConstant: 50),
      
      saveButton.topAnchor.constraint(equalTo: amountField.bottomAnchor, constant: 30),
      saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
      saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
      saveButton.heightAnchor.constraint(equalToConstant: 50)
    ])
  }
  
  @objc private func saveButtonTapped() {
    guard let name = nameField.text, !name.isEmpty,
          let amountText = amountField.text, !amountText.isEmpty,
          let amount = Double(amountText),
          let userId = Auth.auth().currentUser?.uid else {
      AlertManager.showBasicAlert(on: self, title: "Error", message: "Please fill all fields correctly.")
      return
    }
    
    let db = Firestore.firestore()
    let userDocRef = db.collection("users").document(userId)
    let newExpenseRef = db.collection("expenses").document()
    
    // This is the new, more robust Transaction code
    db.runTransaction({ (transaction, errorPointer) -> Any? in
      let userDocument: DocumentSnapshot
      do {
        try userDocument = transaction.getDocument(userDocRef)
      } catch let fetchError as NSError {
        errorPointer?.pointee = fetchError
        return nil
      }
      
      let oldTotal = userDocument.data()?["totalExpense"] as? Double ?? 0.0
      let newTotal = oldTotal + amount
      
      let expenseData: [String: Any] = [
        "userId": userId,
        "name": name,
        "amount": amount,
        "date": Timestamp(date: Date())
      ]
      
      // 1. Write the new expense
      transaction.setData(expenseData, forDocument: newExpenseRef)
      // 2. Update the user's total
      transaction.setData(["totalExpense": newTotal], forDocument: userDocRef, merge: true)
      
      return nil
    }) { (object, error) in
      if let error = error {
        print("Transaction failed: \(error.localizedDescription)")
        AlertManager.showBasicAlert(on: self, title: "Save Error", message: "Transaction failed: \(error.localizedDescription)")
      } else {
        print("Transaction successful! Expense saved and total updated.")
        self.navigationController?.popViewController(animated: true)
      }
    }
  }
}
