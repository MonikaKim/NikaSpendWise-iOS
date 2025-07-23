//
//  ViewController.swift
//  NikaSpendWise
//
//  Created by Kim Monika on 22/7/25.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var onLogoutSuccess: (() -> Void)?
    
    // MARK: - Properties for Grouping
    private var groupedExpenses: [Date: [Expense]] = [:]
    private var sectionDates: [Date] = []
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    private let db = Firestore.firestore()
    private var expenseListener: ListenerRegistration?
    private var totalListener: ListenerRegistration?

    // MARK: - UI Components
    private let totalHeaderView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 1, alpha: 0.15)
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let totalTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Total Expenses"
        label.font = UIFont(name: "AvenirNext-Regular", size: 16)
        label.textColor = UIColor(white: 1, alpha: 0.8)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let totalAmountLabel: UILabel = {
        let label = UILabel()
        label.text = "$0.00"
        label.font = UIFont(name: "AvenirNext-Bold", size: 32)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ExpenseCell")
        // Hide the default separators
        tableView.separatorStyle = .none
        return tableView
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        setupBackground()
        setupNavigation()
        setupHeaderView()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
        fetchTotal()
        fetchExpenseList()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        expenseListener?.remove()
        totalListener?.remove()
    }
    
    // MARK: - UI Setup
    private func setupNavigation() {
        self.title = "NikaSpendWise"
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        let barButtonItemAppearance = UIBarButtonItemAppearance(style: .plain)
        barButtonItemAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.buttonAppearance = barButtonItemAppearance
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = .white
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(logoutButtonTapped))
    }

    private func setupHeaderView() {
        view.addSubview(totalHeaderView)
        totalHeaderView.addSubview(totalTitleLabel)
        totalHeaderView.addSubview(totalAmountLabel)
        
        NSLayoutConstraint.activate([
            totalHeaderView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            totalHeaderView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            totalHeaderView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            totalTitleLabel.topAnchor.constraint(equalTo: totalHeaderView.topAnchor, constant: 15),
            totalTitleLabel.leadingAnchor.constraint(equalTo: totalHeaderView.leadingAnchor, constant: 20),
            totalAmountLabel.topAnchor.constraint(equalTo: totalTitleLabel.bottomAnchor, constant: 5),
            totalAmountLabel.leadingAnchor.constraint(equalTo: totalHeaderView.leadingAnchor, constant: 20),
            totalAmountLabel.trailingAnchor.constraint(equalTo: totalHeaderView.trailingAnchor, constant: -20),
            totalAmountLabel.bottomAnchor.constraint(equalTo: totalHeaderView.bottomAnchor, constant: -15)
        ])
    }
    
    private func setupBackground() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor(red: 221/255.0, green: 160/255.0, blue: 221/255.0, alpha: 1.0).cgColor,
            UIColor(red: 230/255.0, green: 230/255.0, blue: 250/255.0, alpha: 1.0).cgColor
        ]
        gradientLayer.locations = [0.0, 1.0]
      gradientLayer.frame = UIScreen.main.bounds
        view.layer.insertSublayer(gradientLayer, at: 0)
    }

    private func setupTableView() {
        tableView.backgroundColor = .clear
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: totalHeaderView.bottomAnchor, constant: 10),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    // MARK: - Data
    private func fetchTotal() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        print("FETCH TOTAL: Listening for document for userId: \(userId)")
        totalListener = db.collection("users").document(userId)
            .addSnapshotListener { [weak self] documentSnapshot, error in
                guard let document = documentSnapshot, document.exists else {
                    print("FETCH TOTAL ERROR: \(error?.localizedDescription ?? "Unknown error")")
                    print("User document could not be found")
                    self?.totalAmountLabel.text = "$0.00"
                    return
                }
              if document.exists {
                // NEW: Print the data we receive
                print("FETCH TOTAL SUCCESS: Document data received: \(document.data() ?? [:])")
                let data = document.data()
                let total = data?["totalExpense"] as? Double ?? 0.0
                DispatchQueue.main.async {
                  self?.totalAmountLabel.text = String(format: "$%.2f", total)
                }
              } else {
                print("FETCH TOTAL: User document does not exist.")
                self?.totalAmountLabel.text = "$0.00"
              }
                let data = document.data()
                let total = data?["totalExpense"] as? Double ?? 0.0
                DispatchQueue.main.async {
                    self?.totalAmountLabel.text = String(format: "$%.2f", total)
                }
            }
    }
    
    private func fetchExpenseList() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        expenseListener = db.collection("expenses")
            .whereField("userId", isEqualTo: userId)
            .order(by: "date", descending: true)
            .addSnapshotListener { [weak self] querySnapshot, error in
                guard let self = self, let documents = querySnapshot?.documents else {
                    print("Error fetching expense list: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                
                let expenses = documents.compactMap { doc -> Expense? in
                    let data = doc.data()
                    let id = doc.documentID
                    let name = data["name"] as? String ?? "No Name"
                    let amount = data["amount"] as? Double ?? 0.0
                    let timestamp = data["date"] as? Timestamp
                    let date = timestamp?.dateValue() ?? Date()
                    return Expense(id: id, name: name, amount: amount, date: date)
                }
                
                self.groupedExpenses = Dictionary(grouping: expenses) { expense in
                    return Calendar.current.startOfDay(for: expense.date)
                }
                
                self.sectionDates = self.groupedExpenses.keys.sorted(by: >)
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
    }
    
    // MARK: - Actions
    @objc private func addButtonTapped() {
        let addExpenseVC = AddExpenseViewController()
        navigationController?.pushViewController(addExpenseVC, animated: true)
    }
    
    @objc private func logoutButtonTapped() {
        do {
            try Auth.auth().signOut()
            onLogoutSuccess?()
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
            AlertManager.showBasicAlert(on: self, title: "Logout Error", message: signOutError.localizedDescription)
        }
    }
    
    // MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionDates.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let date = sectionDates[section]
        return dateFormatter.string(from: date)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let date = sectionDates[section]
        return groupedExpenses[date]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ExpenseCell", for: indexPath)
        let date = sectionDates[indexPath.section]
        if let expensesForDate = groupedExpenses[date] {
            let expense = expensesForDate[indexPath.row]
            cell.backgroundColor = .clear
            cell.selectionStyle = .none
            cell.textLabel?.textColor = .white
            cell.textLabel?.font = UIFont(name: "AvenirNext-Medium", size: 17)
            cell.textLabel?.text = "\(expense.name): $\(String(format: "%.2f", expense.amount))"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let date = sectionDates[indexPath.section]
            guard let expenseToDelete = groupedExpenses[date]?[indexPath.row] else { return }
            guard let userId = Auth.auth().currentUser?.uid else { return }
            
            let expenseDocRef = db.collection("expenses").document(expenseToDelete.id)
            let userDocRef = db.collection("users").document(userId)
            let amountToDecrement = -expenseToDelete.amount
            
            let batch = db.batch()
            batch.deleteDocument(expenseDocRef)
            batch.setData(["totalExpense": FieldValue.increment(amountToDecrement)], forDocument: userDocRef, merge: true)
            
            batch.commit { error in
                if let error = error {
                    print("Error deleting expense: \(error.localizedDescription)")
                    AlertManager.showBasicAlert(on: self, title: "Delete Error", message: error.localizedDescription)
                } else {
                    print("Document successfully removed and total updated!")
                }
            }
        }
    }

    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView {
            header.backgroundView?.backgroundColor = .clear
            header.textLabel?.textColor = .white
            header.textLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 16)
        }
    }
    
    // NEW: Creates the custom footer view for the daily total
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        // Get the date and calculate the total for this day
        let date = sectionDates[section]
        let dailyTotal = groupedExpenses[date]?.reduce(0) { $0 + $1.amount } ?? 0
        
        // Create the footer view
        let footerView = UIView()
        let totalLabel = UILabel()
        totalLabel.text = String(format: "Daily Total: $%.2f", dailyTotal)
        totalLabel.font = UIFont(name: "AvenirNext-DemiBoldItalic", size: 16)
        totalLabel.textColor = UIColor(white: 1, alpha: 0.9)
        totalLabel.textAlignment = .right
        totalLabel.translatesAutoresizingMaskIntoConstraints = false
        
        footerView.addSubview(totalLabel)
        NSLayoutConstraint.activate([
            totalLabel.trailingAnchor.constraint(equalTo: footerView.trailingAnchor, constant: -15),
            totalLabel.centerYAnchor.constraint(equalTo: footerView.centerYAnchor)
        ])
        
        return footerView
    }
    
    // NEW: Sets the height for the custom footer
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 40
    }
}
