//: Playground - noun: a place where people can play

import Foundation

func cross(A A:String,B:String)->[String]{
    var result = [String]()
    for a in A.characters{
        for b in B.characters{
            result.append("\(a)\(b)")
        }
    }
    return result
}

var cellLabels:[String] = cross(A:"ABCDEFGHI", B: "123456789")
var subGrids:[[String]] = [
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

func createPeerMap(labels: [String],subGrids: [[String]]) -> [String: [String]]{
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

var peerMap = createPeerMap(cellLabels, subGrids: subGrids)


func parseSudoku(source:String) -> [String: Set<Int>]{
    var sodoku = [String: Set<Int>]()
    //    print (source.characters.count)
    assert(source.characters.count == 81)
    for i in 0..<cellLabels.count{
        let number: Int = Int(String(source[source.startIndex.advancedBy(i)]))!
        let label:String = cellLabels[cellLabels.startIndex.advancedBy(i)]
        if number != 0 {
            sodoku.updateValue(Set([number]), forKey: label)
        }else{
            sodoku.updateValue(Set([1,2,3,4,5,6,7,8,9]), forKey: label)
        }
    }
    return sodoku
}
func printSodoku(let sodoku:[String: Set<Int>]){
    var counter = 0
    for label in cellLabels{
        ++counter
        for n in sodoku[label]!{
            print(n,terminator:"")
        }
        print("  ",terminator:"")
        if counter % 9 == 0{
            print("")
        }else if counter % 3 == 0{
            print("|",terminator:"")
        }
    }
}
let source:String = "003020600900305001001806400008102900700000008006708200002609500800203009005010300"
let source2:String = "400000805030000000000700000020000060000080400000010000000603070500200000104000000"
var mySodoku = parseSudoku(source2)
//printSodoku(mySodoku)
func eliminate(inout sodoku:[String: Set<Int>]){
    for label in cellLabels{
        if sodoku[label]!.count == 1{
            let peers = peerMap[label]!
            let value = sodoku[label]!.first!
            eliminatePeers(&sodoku, peers: peers,valueToRemove: value)
        }
    }
}
func eliminatePeers(inout sodoku:[String: Set<Int>],let peers:[String],valueToRemove:Int){
    for label in peers{
        if sodoku[label]!.contains(valueToRemove) == false {
            continue
        }
        if sodoku[label]!.count == 1 && sodoku[label]!.first! != valueToRemove{
            continue
        }
        sodoku[label]!.remove(valueToRemove)
        if sodoku[label]!.count == 0{
            //assert(false,"Eliminate last value")
            print("Error")
            return
        }else if sodoku[label]!.count == 1{
            let value = sodoku[label]!.first!
            let newPeers = peerMap[label]!
            eliminatePeers(&sodoku, peers: newPeers, valueToRemove: value)
        }
    }
}
//print (mySodoku.keys)
eliminate(&mySodoku)
printSodoku(mySodoku)

