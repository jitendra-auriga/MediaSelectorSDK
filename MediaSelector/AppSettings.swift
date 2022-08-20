//
//  AppSettings.swift
//  MediaSelector
//
//  Created by mac on 2022-08-19.
//

import UIKit

class AppSettings {
    
    func askUserToOpenSettings(msg: String, viewController: UIViewController) {
        
        let alert = UIAlertController(title: msg, message: nil, preferredStyle: .alert)
        let laterAction = UIAlertAction(title: "Later", style: .destructive){
            UIAlertAction in
        }
        let allowAction = UIAlertAction(title: "Allow", style: .default){
            UIAlertAction in
            DispatchQueue.main.async {
                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                    return
                }
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    DispatchQueue.main.async {
                        UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                        })
                    }
                }
            }
        }
        alert.addAction(laterAction)
        alert.addAction(allowAction)
        DispatchQueue.main.async {
            alert.popoverPresentationController?.sourceView = viewController.view
            viewController.present(alert, animated: true, completion: nil)
        }
    }

    
}
