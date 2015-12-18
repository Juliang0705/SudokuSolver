//: Playground - noun: a place where people can play

import Cocoa

func cross(A A:String,B:String)->[String]{
    var result = [String]()
    for a in A.characters{
        for b in B.characters{
            result.append("\(a)\(b)")
        }
    }
    return result
}

var cellLabels:[String] = cross(A:"ABCDEFGI", B: "123456789")
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
                                    result.updateValue(Array(values), forKey: label)
                                    break outerLoop
                                }
                }
            }
        }
    return result
}

var peers = createPeerMap(cellLabels, subGrids: subGrids)


