//
//  BruteForceOperation.swift
//  Week3TestWork
//
//  Created by Alexey Golovin on 28.08.2020.
//  Copyright © 2020 E-legion. All rights reserved.
//

import UIKit

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
