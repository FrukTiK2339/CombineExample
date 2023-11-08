//
//  ViewController.swift
//  ExampleApp-Signup
//
//  Created by Dmitry Rybakov on 11/08/23.
//

import UIKit
import Combine

// SIGN UP FORM RULES
// - email address must be valid (contain @ and .)
// - password must be at least 8 characters
// - password cannot be "password"
// - password confirmation must match
// - must agree to terms
// - BONUS: color email field red when invalid, password confirmation field red when it doesn't match the password
// - BONUS: email address must remove spaces, lowercased

class ViewController: UITableViewController {

    // MARK: - Outlets
    
    @IBOutlet weak var emailAddressField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var passwordConfirmationField: UITextField!
    @IBOutlet weak var agreeTermsSwitch: UISwitch!
    @IBOutlet weak var signUpButton: BigButton!
    
    // MARK: - Subjects
    
    private var emailSubject = CurrentValueSubject<String, Never>("")
    private var passwordSubject = CurrentValueSubject<String, Never>("")
    private var passwordConfirmationSubject = CurrentValueSubject<String, Never>("")
    private var agreeTermsSubject = CurrentValueSubject<Bool, Never>(false)
    
    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: - View Lifecycle
  
    override func viewDidLoad() {
        super.viewDidLoad()
        
        formIsValid
            .assign(to: \.isEnabled, on: signUpButton)
            .store(in: &cancellables)
        
        emailIsValid
            .map { $0 ? UIColor.label : UIColor.systemRed }
            .assign(to: \.textColor, on: emailAddressField)
            .store(in: &cancellables)
        
        setValidColor(field: emailAddressField, publisher: emailIsValid)
        setValidColor(field: passwordField, publisher: passwordIsValid)
        setValidColor(field: passwordConfirmationField, publisher: passwordMatchesConfirmation)
        
        formattedEmailAdress
            .filter { [unowned self] in $0 != emailSubject.value }
            .map { $0 as String? }
            .assign(to: \.text, on: emailAddressField)
            .store(in: &cancellables)
            
    }
    
    private func setValidColor<P: Publisher>(field: UITextField, publisher: P) where P.Output == Bool, P.Failure == Never {
        publisher
        .map { $0 ? UIColor.label : UIColor.systemRed }
        .assign(to: \.textColor, on: field)
        .store(in: &cancellables)
        
    }
    
    private func emailIsValid(_ email: String) -> Bool {
        email.contains("@") && email.contains(".")
    }
    
    // MARK: - Publishers
    
    private var formIsValid: AnyPublisher<Bool, Never> {
        Publishers.CombineLatest3(emailIsValid, passwordValidAndConfimed, agreeTermsSubject)
            .map { emailValid, passwordValid, agreeTermsOn in
                    emailValid && passwordValid && agreeTermsOn
            }
            .eraseToAnyPublisher()
    }
    
    private var formattedEmailAdress: AnyPublisher<String, Never> {
        emailSubject
            .map { $0.lowercased() }
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .eraseToAnyPublisher()
    }
    
    private var emailIsValid: AnyPublisher<Bool, Never> {
        formattedEmailAdress
            .map { [weak self] in self?.emailIsValid($0) }
            .replaceNil(with: false)
            .eraseToAnyPublisher()
    }
    
    private var passwordValidAndConfimed: AnyPublisher<Bool, Never> {
        passwordIsValid.combineLatest(passwordMatchesConfirmation)
            .map { valid, confirmed in
                    valid && confirmed
            }
            .eraseToAnyPublisher()
    }
    
    private var passwordIsValid: AnyPublisher<Bool, Never> {
        passwordSubject
            .map {
                $0 != "password" && $0.count >= 8
            }
            .eraseToAnyPublisher()
    }
    
    private var passwordMatchesConfirmation: AnyPublisher<Bool, Never> {
        passwordSubject.combineLatest(passwordConfirmationSubject)
            .map { pass, conf in
                pass == conf
            }
            .eraseToAnyPublisher()
            
    }
    
    // MARK: - Actions
    
    @IBAction func emailDidChange(_ sender: UITextField) {
        emailSubject.send(sender.text ?? "")
    }
    
    @IBAction func passwordDidChange(_ sender: UITextField) {
        passwordSubject.send(sender.text ?? "")
    }
    
    @IBAction func passwordConfirmationDidChange(_ sender: UITextField) {
        passwordConfirmationSubject.send(sender.text ?? "")
    }
    
    @IBAction func agreeSwitchDidChange(_ sender: UISwitch) {
        agreeTermsSubject.send(sender.isOn)
    }
    
    @IBAction func signUpTapped(_ sender: Any) {
        let alert = UIAlertController(title: "Welcome!", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
