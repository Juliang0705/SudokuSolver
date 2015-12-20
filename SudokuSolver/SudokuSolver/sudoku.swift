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
typealias Sudoku = [String:Set<Int>]

// exception type
enum SudokuError: ErrorType{
    case ParsingError
    case IncorrectSudokuError
    case UnsolvedSudokuError
}

class SudokuSolver{
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
    
    private var originalSudoku:Sudoku? = nil
    private var solvedSudoku:Sudoku? = nil
    
    private let queue:dispatch_queue_t = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    private var group:dispatch_group_t = dispatch_group_create();
    
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
    
// parse a sodoku from a string horizontally
// 0 stands for empty

    private func parseSudoku(source: String) throws{
                if source.characters.count != 81{
                    throw SudokuError.ParsingError
                }
                var sodoku:Sudoku = Sudoku()
                for i in 0..<cellLabels.count{
                    let number: Int? = Int(String(source[source.startIndex.advancedBy(i)]))
                    if number == nil{
                        throw SudokuError.ParsingError
                    }
                    let label:String = cellLabels[cellLabels.startIndex.advancedBy(i)]
                    if number != 0 {
                        sodoku.updateValue(Set([number!]), forKey: label)
                    }else{
                        sodoku.updateValue(Set([1,2,3,4,5,6,7,8,9]), forKey: label)
                    }
                }
                self.originalSudoku = sodoku
    }
// eliminate possibilities based on given numbers
    
    private func initialEliminate() -> Bool{
                for label in self.cellLabels{
                    if self.originalSudoku![label]!.count == 1{
                        let peers = self.peerMap[label]!
                        let value = self.originalSudoku![label]!.first!
                        if eliminatePeers(&self.originalSudoku!, peers: peers,valueToRemove: value) == false{
                            return false
                        }
                    }
                }
                return true
    }
// recursively eliminates all its peers' possibilities
    
    private func eliminatePeers(inout sudoku:[String: Set<Int>],let peers:[String],valueToRemove:Int) -> Bool{
                for label in peers{
                    if sudoku[label]!.contains(valueToRemove) == false {
                        continue
                    }
                    if sudoku[label]!.count == 1 && sudoku[label]!.first! != valueToRemove{
                        continue
                    }
                    sudoku[label]!.remove(valueToRemove)
                    if sudoku[label]!.count == 0{
                        return false
                    }else if sudoku[label]!.count == 1{
                        let value = sudoku[label]!.first!
                        let newPeers = self.peerMap[label]!
                        if eliminatePeers(&sudoku, peers: newPeers, valueToRemove: value) == false{
                            return false
                        }
                    }
                }
                return true
    }
// check if a sodoku is completely solved
    private func isSolved(let sudoku:[String: Set<Int>]) -> Bool{
                for label in self.cellLabels{
                    if sudoku[label]!.count != 1{
                        return false
                    }
                }
                return true
    }
// return the label with the least possibilities
    private func cellWithleastPossibilities(let sudoku:[String: Set<Int>]) -> String{
                var current:String = self.cellLabels.first!
                for label in self.cellLabels{
                    if sudoku[current]!.count == 1 {
                        current = label
                    }
                    else if sudoku[label]!.count != 1 && sudoku[label]!.count < sudoku[current]!.count{
                        current = label
                    }
                }
                return current
    }
// recursively and concurrently try and eliminate possibilities until the sodoku is solved or the sodoku has no solution
    private func solveSudoku(let sudoku:[String:Set<Int>]){
        // solution has been found in one of the other threads
        if self.solvedSudoku != nil{
            return
        }
        // find the solution
        if isSolved(sudoku){
            self.solvedSudoku = sudoku
            return
        }
        
        let targetCell:String = self.cellWithleastPossibilities(sudoku)
        
        //concurrently eliminate possibilities
        for possibility in sudoku[targetCell]!{
            
            dispatch_group_async(self.group,self.queue){
                //doing work----
                var sudokuCopy:Sudoku = sudoku
                sudokuCopy[targetCell]!.remove(possibility)
                if sudokuCopy[targetCell]!.count == 1{
                    let peers = self.peerMap[targetCell]!
                    let value = sudokuCopy[targetCell]!.first!
                    if self.eliminatePeers(&sudokuCopy, peers: peers,valueToRemove: value){
                        self.solveSudoku(sudokuCopy)
                    }
                }else{
                    self.solveSudoku(sudokuCopy)
               }
                //end work-----
            }
        }
    }
    private func printSudoku(let sudoku:[String: Set<Int>]){
        var counter = 0
        for label in self.cellLabels{
            ++counter
            for n in sudoku[label]!{
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
    func solve(sudokuFromString source: String) throws{
        if solvedSudoku != nil{
            solvedSudoku = nil
        }
        try self.parseSudoku(source)
        self.initialEliminate()
        self.solveSudoku(self.originalSudoku!)
        dispatch_group_wait(self.group, DISPATCH_TIME_FOREVER);
        if (solvedSudoku == nil){
            throw SudokuError.IncorrectSudokuError
        }
    }
    func printFormattedSudoku() throws{
        if self.solvedSudoku == nil{
            throw SudokuError.UnsolvedSudokuError
        }
        self.printSudoku(self.solvedSudoku!)
    }
    func getRawSudoku() throws -> String{
        if self.solvedSudoku == nil{
            throw SudokuError.UnsolvedSudokuError
        }
        var result:String = ""
        for label in self.cellLabels{
            result += "\(self.solvedSudoku![label]!.first!)"
        }
        return result
    }
}