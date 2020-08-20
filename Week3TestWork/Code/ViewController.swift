//
//  ViewController.swift
//  Week3TestWork
//
//  Copyright © 2018 E-legion. All rights reserved.
//

import UIKit

struct EmptyArraysCount {
    var count: Int = 0
}

class BruteForceOperation: Operation {
    
    var result: String?
    
    private let characterArray = Consts.characterArray
    lazy private var maxIndexArray = Consts.characterArray.count
    
    private var inputPassword: String
        private var startIndexArray:[Int]
        private var endIndexArray:[Int]
        
        init(password: String, startIndex: [Int], endIndex: [Int]) {
            inputPassword = password
            startIndexArray = startIndex
            endIndexArray = endIndex
        }
        
        override func main() {
            
             var currentIndexArray = startIndexArray
            // Цикл подбора пароля
             while true {
                 
                 // Формируем строку проверки пароля из элементов массива символов
                 let currentPass = self.characterArray[currentIndexArray[0]] + self.characterArray[currentIndexArray[1]] + self.characterArray[currentIndexArray[2]] + self.characterArray[currentIndexArray[3]]
                 
                 // Выходим из цикла если пароль найден, или, если дошли до конца массива индексов
                 if inputPassword == currentPass {
                    result = currentPass
                    break
                 } else {
                     if currentIndexArray.elementsEqual(endIndexArray) {
                         break
                     }
                     
                     for index in (0 ..< currentIndexArray.count).reversed() {
                         guard currentIndexArray[index] < maxIndexArray - 1 else {
                             currentIndexArray[index] = 0
                             continue
                         }
                         currentIndexArray[index] += 1
                         break
                     }
                 }
             }
        }
    }


class ViewController: UIViewController {
    @IBOutlet private weak var inputTextField: UITextField!
    @IBOutlet private weak var statusLabel: UILabel!
    @IBOutlet private weak var passwordLabel: UILabel!
    @IBOutlet private weak var bruteForcedTimeLabel: UILabel!
    @IBOutlet private weak var indicator: UIActivityIndicatorView!
    @IBOutlet private weak var startButton: UIButton!
    @IBOutlet private weak var generatePasswordButton: UIButton!
    
    private let passwordGenerate = PasswordGenerator()
    private let characterArray = Consts.characterArray
    private let maxTextLength = Consts.maxTextFieldTextLength
    private var password = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        indicator.isHidden = true
        disableStartButton()
        
        //Hide keyboard on screen tap
        let tap = UITapGestureRecognizer(target: self, action: #selector(ViewController.handleTap))
        view.addGestureRecognizer(tap)
        inputTextField.delegate = self
    }
    
    @objc func handleTap() {
        view.endEditing(true)
    }
    
    @IBAction func generatePasswordButtonPressed(_ sender: UIButton) {
        clearText()
        inputTextField.text = passwordGenerate.randomString(length: 4)
        enableStartButton()
    }
    
    @IBAction func startBruteFoceButtonPressed(_ sender: Any) {
        guard let text = inputTextField.text else {
            return
        }
        password = text
        clearText()
        disableStartButton()
        statusLabel.text = "Status: in process"
        indicator.isHidden = false
        indicator.startAnimating()
        generatePasswordButton.isEnabled = false
        generatePasswordButton.alpha = 0.5
        start()
    }
    
    private func start() {
        bruteForceOperation(password: password)
    }
    
    private func bruteForceOperation(password: String) {
        let searchingPassword = password
        let queue = OperationQueue()
        let startTime = Date()

        let operation1 = BruteForceOperation(password: searchingPassword, startIndex: [0,0,0,0], endIndex: [14,14,14,14])
        let operation2 = BruteForceOperation(password: searchingPassword, startIndex: [15,15,15,15], endIndex: [29,29,29,29])
        let operation3 = BruteForceOperation(password: searchingPassword, startIndex: [30,30,30,30], endIndex: [44,44,44,44])
        let operation4 = BruteForceOperation(password: searchingPassword, startIndex: [45,45,45,45], endIndex: [61,61,61,61])
        
        queue.addOperations([operation1,operation2,operation3,operation4], waitUntilFinished: false)
        
        operation1.completionBlock = {
            if let result = operation1.result
            {
                queue.cancelAllOperations()
                OperationQueue.main.addOperation {
                    self.stop(password: result , startTime: startTime)
                    self.indicator.isHidden = true
                }
                //operation1.isCancelled == false - необходим для отключения ложного срабатывания. Иначе одна из операций, которая будет последней, отработает данный код
            } else if operation2.isFinished && operation3.isFinished && operation4.isFinished && operation1.isCancelled == false{
                OperationQueue.main.addOperation {
                    self.stop(password: "Error1" , startTime: startTime)
                    self.indicator.isHidden = true
                }
            }
        }
        operation2.completionBlock = {
            if let result = operation2.result
            {
                queue.cancelAllOperations()
                OperationQueue.main.addOperation {
                    self.stop(password: result , startTime: startTime)
                    self.indicator.isHidden = true
                }
            } else if operation1.isFinished && operation3.isFinished && operation4.isFinished && operation2.isCancelled == false{
                OperationQueue.main.addOperation {
                    self.stop(password: "Error2" , startTime: startTime)
                    self.indicator.isHidden = true
                }
            }
        }
        operation3.completionBlock = {
            if let result = operation3.result
            {
                queue.cancelAllOperations()
                OperationQueue.main.addOperation {
                    self.stop(password: result , startTime: startTime)
                    self.indicator.isHidden = true
                }
            } else if operation1.isFinished && operation2.isFinished && operation4.isFinished && operation3.isCancelled == false{
                OperationQueue.main.addOperation {
                    self.stop(password: "Error3" , startTime: startTime)
                    self.indicator.isHidden = true
                }
            }
        }
        operation4.completionBlock = {
            if let result = operation4.result
            {
                queue.cancelAllOperations()
                OperationQueue.main.addOperation {
                    self.stop(password: result , startTime: startTime)
                    self.indicator.isHidden = true
                }
            } else if operation1.isFinished && operation2.isFinished && operation3.isFinished && operation4.isCancelled == false{
                OperationQueue.main.addOperation {
                    self.stop(password: "Error4" , startTime: startTime)
                    self.indicator.isHidden = true
                }
            }
        }
    }
    
    // Возвращает подобранный пароль
    private func bruteForce(startString: String, endString: String) -> String? {
        let inputPassword = password
        var startIndexArray = [Int]()
        var endIndexArray = [Int]()
        let maxIndexArray = characterArray.count
        // Создает массивы индексов из входных строк
        for char in startString {
            for (index, value) in characterArray.enumerated() where value == "\(char)" {
                startIndexArray.append(index)
            }
        }
        for char in endString {
            for (index, value) in characterArray.enumerated() where value == "\(char)" {
                endIndexArray.append(index)
            }
        }
        
        var currentIndexArray = startIndexArray
        
        // Цикл подбора пароля
        while true {
            // Формируем строку проверки пароля из элементов массива символов
            let currentPass = self.characterArray[currentIndexArray[0]] + self.characterArray[currentIndexArray[1]] + self.characterArray[currentIndexArray[2]] + self.characterArray[currentIndexArray[3]]
            
            // Выходим из цикла если пароль найден, или, если дошли до конца массива индексов
            if inputPassword == currentPass {
                print("Current password \(currentPass)")
                return currentPass
            } else {
                if currentIndexArray.elementsEqual(endIndexArray) {
                    break
                }
                
                // Если пароль не найден, то происходит увеличение индекса. Для этого в цикле, начиная с последнего элемента осуществляется проверка текущего значения. Если оно меньше максимального значения (61), то индекс просто увеличивается на 1.
                //Например было [0, 0, 0, 5] а станет [0, 0, 0, 6]. Если же мы уже проверили последний индекс, например [0, 0, 0, 61], то нужно сбросить его в 0, а "старший" индекс увеличить на 1. При этом далее в цикле проверяется переполение "старшего" индекса тем же алгоритмом.
                //Таким образом [0, 0, 0, 61] станет [0, 0, 1, 0]. И поиск продолжится дальше:  [0, 0, 1, 1],  [0, 0, 1, 2],  [0, 0, 1, 3] и т.д.
                for index in (0 ..< currentIndexArray.count).reversed() {
                    guard currentIndexArray[index] < maxIndexArray - 1 else {
                        currentIndexArray[index] = 0
                        continue
                    }
                    currentIndexArray[index] += 1
                    break
                }
            }
        }
        return nil
    }
    
    //Обновляем UI
    private func stop(password: String, startTime: Date) {
        
        indicator.stopAnimating()
        indicator.isHidden = true
        enableStartButton()
        generatePasswordButton.isEnabled = true
        generatePasswordButton.alpha = 1
        passwordLabel.text = "Password is: \(password)"
        statusLabel.text = "Status: Complete"
        bruteForcedTimeLabel.text = "\(String(format: "Time: %.2f", Date().timeIntervalSince(startTime))) seconds"
        
    }
    
    private func clearText() {
        statusLabel.text = "Status: "
        bruteForcedTimeLabel.text = "Time:"
        passwordLabel.text = "Password is:"
    }
    
    private func disableStartButton() {
        startButton.isEnabled = false
        startButton.alpha = 0.5
    }
    
    private func enableStartButton() {
        startButton.isEnabled = true
        startButton.alpha = 1
    }
}

// Добавляем делегат для управления вводом текста в UITextField
extension ViewController: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let charCount = inputTextField.text?.count else {
            return
        }
        if charCount != maxTextLength {
            Alert.showBasic(title: "Incorrect password", message: "Password must be 4 characters long", vc: self)
        }
        if charCount > 3 {
            enableStartButton()
        } else {
            disableStartButton()
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        clearText()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else {
            return false
        }
        
        let acceptableCharacters = Consts.joinedString
        let characterSet = CharacterSet(charactersIn: acceptableCharacters).inverted
        let newString = NSString(string: text).replacingCharacters(in: range, with: string)
        let filtered = newString.rangeOfCharacter(from: characterSet) == nil
        return newString.count <= maxTextLength && filtered
    }
    
}
