//
//  SearchViewController.swift
//  SampleNASA
//
//  Created by Rayan Godwin Sequeira on 18/06/22.
//

import UIKit

class SearchViewController: UIViewController
{
    @IBOutlet var fetchItemButton: UIButton!
    @IBOutlet var dateTextField: UITextField!
    private var dateStringSelected: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.setDate(Date(), animated: false)
        datePicker.addTarget(self, action: #selector(updateTextField(_:)), for: .valueChanged)
        self.dateTextField.inputView = datePicker
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        self.addKeyboardNotificationsObserver()
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        self.removeKeyboardNotificationObserver()
    }
    
    private func addKeyboardNotificationsObserver()
    {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func removeKeyboardNotificationObserver() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @IBAction func didBeginEditing(_ sender: Any)
    {
        self.handleSelectionOf(date: Date())
    }
    
    @objc func updateTextField(_ sender: UIDatePicker)
    {
        self.handleSelectionOf(date: sender.date)
    }
    
    private func handleSelectionOf(date: Date)
    {
        self.dateStringSelected = DateUtility.stringFrom(date: date)
        self.dateTextField.text = self.dateStringSelected
        self.fetchItemButton.isEnabled = ((self.dateStringSelected?.count ?? 0) > 0)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if let destinationVC = segue.destination as? DetailViewController
        {
            destinationVC.dateString = self.dateStringSelected
            self.dateTextField.resignFirstResponder()
        }
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
              if self.view.frame.origin.y == 0{
                  self.view.frame.origin.y -= keyboardSize.height
              }
         }
     }

    @objc func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
              if self.view.frame.origin.y != 0{
                  self.view.frame.origin.y += keyboardSize.height
              }
         }
     }

}
