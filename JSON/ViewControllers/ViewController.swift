//
//  ViewController.swift
//  JSON
//
//  Created by Павел on 11.05.2022.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var secondNameField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var result: ResponseResult?
    
    @IBAction func calculateButtonPress() {
        
        guard checkNames() else {return}
        
        let api = RapidApi(firstName: firstNameField.text!, secondName: secondNameField.text!) //Так как только что проверили на nil в методе checkNames() можно быть увереным в содержимом и извлекать принудительно
        
        activityIndicator.startAnimating()
        view.alpha = 0.5
        api.sendRequest { responseResult in
            
            switch responseResult{
                
            case let .success(responseResult):
                self.result = responseResult
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "segueToResult", sender: nil)
                    self.activityIndicator.stopAnimating()
                    self.view.alpha = 1
                }
                
            case let .failure(error):
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.view.alpha = 1
                    self.showAlert(title: "Ошибка", message: "\(error.localizedDescription) Не удалось соединиться с сервером, попробуйте позднее", titleButton: "Ок")
                }
                return
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        firstNameField.delegate = self
        secondNameField.delegate = self
        
        decorateElemets()
        setupToolBar()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let resultContoller = segue.destination as? ResultViewContoller else {return}
        
        resultContoller.resultString = result?.percentage ?? ""        
    }

    @objc private func hintSelected(sender: UIBarButtonItem) {
        
        let textFromToolBar = sender.title
        
        if firstNameField.isEditing {
            firstNameField.text = textFromToolBar
        } else {
            secondNameField.text = textFromToolBar
        }
        view.endEditing(true)
    }
    
    private func decorateElemets() {
        
        firstNameField.layer.borderColor = UIColor.systemPink.cgColor
        firstNameField.layer.borderWidth = 1.0
        firstNameField.layer.cornerRadius = 5
        firstNameField.attributedPlaceholder = NSAttributedString(string: "Его имя", attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 1, green: 0.782, blue: 0.824, alpha: 1)])
        
        secondNameField.layer.borderColor = UIColor.systemPink.cgColor
        secondNameField.layer.borderWidth = 1.0
        secondNameField.layer.cornerRadius = 5
        secondNameField.attributedPlaceholder = NSAttributedString(string: "Её имя", attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 1, green: 0.782, blue: 0.824, alpha: 1)])
      
        setGradient()
    }
    
    private func checkNames() -> Bool {
        
        let enteredFirstName = firstNameField.text ?? ""
        if enteredFirstName.isEmpty {

            showAlert(title: "Не заполнено его имя",
                      message: "Пожалуйста укажите имя мужчины",
                      titleButton: "Ok")
            return false
        }
        
        let enteredSecondName = secondNameField.text ?? ""
        if enteredSecondName.isEmpty {

            showAlert(title: "Не заполнено её имя",
                      message: "Пожалуйста укажите имя девушки",
                      titleButton: "Ok")
            return false
        }
        
        return true
    }
}

// MARK: Delegate
extension ViewController {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super .touchesBegan(touches, with: event)
        view.endEditing(true)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == firstNameField {
            secondNameField.becomeFirstResponder()
        }else {
            view.endEditing(true)
        }
        
        return true
    }
}
// MARK: System
extension ViewController {
    
    private func showAlert(title: String, message: String, titleButton: String) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let buttonController = UIAlertAction(title: titleButton, style: .default)
        alertController.addAction(buttonController)
        
        present(alertController, animated: true)
    }
    
}

// MARK: Visual
extension ViewController {
    
    
    private func addCustomToolBar(for textField: UITextField, hints: [String]) {
        
        let customToolBar = UIToolbar()
        
        let titleButton = UIBarButtonItem(title: "Если забыли: ", style: .plain, target: self, action: nil)
        let flexibleSpace = UIBarButtonItem.flexibleSpace()
        var buttons: [UIBarButtonItem] =  [titleButton, flexibleSpace]
        
        for hint in hints {
            let hintButton = UIBarButtonItem(title: hint, style: .done, target: self, action: #selector(hintSelected(sender:)))
            buttons.append(hintButton)
        }
        
        customToolBar.setItems(buttons, animated: false)
        customToolBar.sizeToFit()
        textField.inputAccessoryView = customToolBar
        
    }
    
    private func setupToolBar() {
        
        addCustomToolBar(for: firstNameField, hints: DataManager.shared.manHints)
        addCustomToolBar(for: secondNameField, hints: DataManager.shared.womanHints)
        
    }
    
    private func setGradient() {
        
        let primaryColor = UIColor(
            red: 0.182,
            green: 0.460,
            blue: 0.890,
            alpha: 1
        )
        
        let secondaryColor = UIColor(
            red: 0.831,
            green: 0.607,
            blue: 0.890,
            alpha: 1
        )
        
        let gradient = CAGradientLayer()
        gradient.frame = view.bounds
        gradient.colors = [primaryColor.cgColor, secondaryColor.cgColor]
        gradient.locations = [0.0, 1.0]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 0, y: 1)
        view.layer.insertSublayer(gradient, at: 0)
        
    }
    
}
