// demo

let easy1:String = "003020600900305001001806400008102900700000008006708200002609500800203009005010300"
let easy2:String = "600057010408106003010203080050674000970000000080920050140080039703009825002060041"
let hard1:String = "850002400720000009004000000000107002305000900040000000000080070017000000000036040"
let hard2:String = "001006004060070010400900300100800200020030080004007003003008002090060050500100700"

var solver:SudokuSolver = SudokuSolver()
//3 public functions
//solve() takes a string and solve the sodoku
//printFormattedSudoku() prints the most recent solved sodoku
//getRawSudoku() returns the most recent solved sodoku as a string

func solveAndPrint(sodoku:String) throws{
    try solver.solve(sudokuFromString: sodoku)
    try solver.printFormattedSudoku()
    try print(solver.getRawSudoku())
    print("\n")
}

do{
    
    try solveAndPrint(easy1)
    try solveAndPrint(easy2)
    try solveAndPrint(hard1)
    try solveAndPrint(hard2)
    
}catch SudokuError.ParsingError{
    print("Error in parsing the sodoku")
}catch SudokuError.IncorrectSudokuError{
    print("This sodoku has no solution")
}catch SudokuError.UnsolvedSudokuError{
    print("Call solve() function before print")
}catch _{
    print("Unexpected Error")
}


