
let easy1:String = "003020600900305001001806400008102900700000008006708200002609500800203009005010300"
let east2:String = "600057010408106003010203080050674000970000000080920050140080039703009825002060041"
let hard1:String = "850002400720000009004000000000107002305000900040000000000080070017000000000036040"

var solver:SodokuSolver = SodokuSolver()
do{
    try solver.solve(sodokuFromString: east2)
    try solver.printFormattedSodoku()
    print(try solver.getRawSodoku())
    
}catch SodokuError.ParsingError{
    print("Error in parsing the sodoku")
}catch SodokuError.IncorrectSodokuError{
    print("This sodoku has no solution")
}catch SodokuError.UnsolvedSodokuError{
    print("Call solve() function before print")
}catch is ErrorType{
    print("Unexpected Error")
}


