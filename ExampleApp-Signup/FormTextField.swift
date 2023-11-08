//
//  FormTextField.swift
//  ExampleApp-Signup
//
//  Created by Dmitry Rybakov on 11/08/23.
//

import UIKit

@IBDesignable
class FormTextField: UITextField {
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10))
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10))
    }
}
