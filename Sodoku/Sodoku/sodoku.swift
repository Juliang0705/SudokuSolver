//
//  sodoku.swift
//  Sodoku
//
//  Created by Juliang Li on 12/19/15.
//  Copyright © 2015 Juliang. All rights reserved.
//

import Foundation

//sodoku is defined as a dictionary with cell label as its key 
//and a set of a possible numbers as its value
typealias Sodoku = [String:Set<Int>]

// exception type
enum SodokuError: ErrorType{
    case ParsingError
    case IncorrectSodokuError
    case UnsolvedSodokuError
}

class SodokuSolver{
//internal data
    // an array with all the labels
    private var cellLabels:[String]!
    
    // a dictionary that has cellLabel as its key and the corresponding peers as its value
    private var peerMap:[String: [String]]!
    
    private let subGrids:[[String]] = [
        ["A1","A2","A3","B1","B2","B3","C1","C2","C3"],
        ["A4","A5","A6","B4","B5","B6","C4","C5","C6"],
        ["A7","A8","A9","B7","B8","B9","C7","C8","C9"],
        ["D1","D2","D3","E1","E2","E3","F1","F2","F3"],
        ["D4","D5","D6","E4","E5","E6","F4","F5","F6"],
        ["D7","D8","D9","E7","E8","E9","F7","F8","F9"],
        ["G1","G2","G3","H1","H2","H3","I1","I2","I3"],
        ["G4","G5","G6","H4","H5","H6","I4","I5","I6"],
        ["G7","G8","G9","H7","H8","H9","I7","I8","I9"]
    ]
    
    private var originalSodoku:Sodoku? = nil
    private var solvedSodoku:Sodoku? = nil
    
//internal helper functions
    private func makeLabels(A A:String,B:String)->[String]{
                var result = [String]()
                for a in A.characters{
                    for b in B.characters{
                        result.append("\(a)\(b)")
                    }
            }
            return result
    }
    
    private func createPeerMap(labels: [String],subGrids: [[String]]) -> [String: [String]]{
                var result = [String: [String]]()
                for label in labels{
                    var values:Set<String> = Set<String>()
                    
                    let firstLetter = label[label.startIndex]
                    for (var n = 1; n < 10; ++n){
                        values.insert("\(firstLetter)" + "\(n)")
                    }
                    let secondNumber = label[label.startIndex.advancedBy(1)]
                    for letter in "ABCDEFGHI".characters{
                        values.insert("\(letter)" + "\(secondNumber)")
                    }
                    outerLoop:        for subGrid in subGrids{
                        for elem in subGrid{
                            if elem == label{
                                for v in subGrid{
                                    values.insert(v)
                                }
                                values.remove(label)//don't contain itself
                                result.updateValue(Array(values), forKey: label)
                                break outerLoop
                            }
                        }
                    }
                }
                return result
    }
    private func parseSodoku(source: String) throws{
                if source.characters.count != 81{
                    throw SodokuError.ParsingError
                }
                var sodoku:Sodoku = Sodoku()
                for i in 0..<cellLabels.count{
                    let number: Int? = Int(String(source[source.startIndex.advancedBy(i)]))
                    if number == nil{
                        throw SodokuError.ParsingError
                    }
                    let label:String = cellLabels[cellLabels.startIndex.advancedBy(i)]
                    if number != 0 {
                        sodoku.updateValue(Set([number!]), forKey: label)
                    }else{
                        sodoku.updateValue(Set([1,2,3,4,5,6,7,8,9]), forKey: label)
                    }
                }
                self.originalSodoku = sodoku
    }
    private func initialEliminate() -> Bool{
                for label in self.cellLabels{
                    if self.originalSodoku![label]!.count == 1{
                        let peers = self.peerMap[label]!
                        let value = self.originalSodoku![label]!.first!
                        if eliminatePeers(&self.originalSodoku!, peers: peers,valueToRemove: value) == false{
                            return false
                        }
                    }
                }
                return true
    }
    private func eliminatePeers(inout sodoku:[String: Set<Int>],let peers:[String],valueToRemove:Int) -> Bool{
                for label in peers{
                    if sodoku[label]!.contains(valueToRemove) == false {
                        continue
                    }
                    if sodoku[label]!.count == 1 && sodoku[label]!.first! != valueToRemove{
                        continue
                    }
                    sodoku[label]!.remove(valueToRemove)
                    if sodoku[label]!.count == 0{
                        return false
                    }else if sodoku[label]!.count == 1{
                        let value = sodoku[label]!.first!
                        let newPeers = self.peerMap[label]!
                        if eliminatePeers(&sodoku, peers: newPeers, valueToRemove: value) == false{
                            return false
                        }
                    }
                }
                return true
    }
    private func isSolved(let sodoku:[String: Set<Int>]) -> Bool{
                for label in self.cellLabels{
                    if sodoku[label]!.count != 1{
                        return false
                    }
                }
                return true
    }
    private func cellWithleastPossibilities(let sodoku:[String: Set<Int>]) -> String{
                var current:String = self.cellLabels.first!
                for label in self.cellLabels{
                    if sodoku[current]!.count == 1 {
                        current = label
                    }
                    else if sodoku[label]!.count != 1 && sodoku[label]!.count < sodoku[current]!.count{
                        current = label
                    }
                }
                return current
    }
    private func solveSodoku(let sodoku:[String:Set<Int>]){
        if self.solvedSodoku != nil{
            return
        }
        if isSolved(sodoku){
            self.solvedSodoku = sodoku
            return
        }
        let targetCell:String = self.cellWithleastPossibilities(sodoku)
        
        for possibility in sodoku[targetCell]!{
            var sodokuCopy:Sodoku = sodoku
            
            sodokuCopy[targetCell]!.remove(possibility)
            
            if sodokuCopy[targetCell]!.count == 1{
                let peers = self.peerMap[targetCell]!
                let value = sodokuCopy[targetCell]!.first!
                if eliminatePeers(&sodokuCopy, peers: peers,valueToRemove: value){
                    solveSodoku(sodokuCopy)
                }
            }else{
                solveSodoku(sodokuCopy)
            }
        }
    }
    private func printSodoku(let sodoku:[String: Set<Int>]){
        var counter = 0
        for label in self.cellLabels{
            ++counter
            for n in sodoku[label]!{
                print(n,terminator:"")
            }
            print("  ",terminator:"")
            if counter % 27 == 0 {
                print("\n---------------------------")
            }
            else if counter % 9 == 0{
                print("")
            }else if counter % 3 == 0{
                print("|",terminator:"")
            }
        }
    }
// public functions
    init(){
        self.cellLabels = self.makeLabels(A:"ABCDEFGHI", B: "123456789")
        self.peerMap = self.createPeerMap(self.cellLabels, subGrids: self.subGrids)
    }
    func solve(sodokuFromString source: String) throws{
        if solvedSodoku != nil{
            solvedSodoku = nil
        }
        try self.parseSodoku(source)
        self.initialEliminate()
        self.solveSodoku(self.originalSodoku!)
        if (solvedSodoku == nil){
            throw SodokuError.IncorrectSodokuError
        }
    }
    func printFormattedSodoku() throws{
        if self.solvedSodoku == nil{
            throw SodokuError.UnsolvedSodokuError
        }
        self.printSodoku(self.solvedSodoku!)
    }
    func getRawSodoku() throws -> String{
        if self.solvedSodoku == nil{
            throw SodokuError.UnsolvedSodokuError
        }
        var result:String = ""
        for label in self.cellLabels{
            result += "\(self.solvedSodoku![label]!.first!)"
        }
        return result
    }
}