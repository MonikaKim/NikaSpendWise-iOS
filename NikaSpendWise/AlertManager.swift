//
//  AlertManager.swift
//  NikaSpendWise
//
//  Created by Kim Monika on 22/7/25.
//

import UIKit

class AlertManager {
  
  static func showBasicAlert(on vc: UIViewController, title: String, message: String) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
    vc.present(alert, animated: true)
  }
}
