import UIKit

//Hello World

var greeting = "Hello, playground"
print(greeting)

// Mutating concept in structures
struct Testing{
    var age: Int
    
    // we need mutating here, because self is immuatable and the instance can implement it as let and var both, so by default structures are immutable
    mutating func changeAge() -> Int{
        self.age = self.age + 10
        return self.age
    }
}

var example = Testing(age: 10)
print(example.age)

let age2 = example.changeAge() // this will give error if example is let constant

print(age2)
print(example.age)


// concept of capturing of things inside closure and related strong reference retain cycle posibilites:

//func makeIncrementer(incrementAmount: Int) -> () -> Int {
//    var total = 0
//
//    let incrementer: () -> Int = {
//        total += incrementAmount
//        return total
//    }
//
//    total += 10
//
//    return incrementer
//}
//
//let incrementByTwo = makeIncrementer(incrementAmount: 2)
//
//print(incrementByTwo())  // Prints 2
//print(incrementByTwo())  // Prints 4
//print(incrementByTwo())  // Prints 6
 
func makeIncrementer(incrementAmount: Int) -> () -> Int {
    var total = 0
 
    let incrementer: () -> Int = { [total] in
        // Here, 'total' is captured in the closure
        // with a capture list to create a copy.
        var capturedTotal = total
        capturedTotal += incrementAmount
        return capturedTotal
    }
 
    return incrementer
}
 
let incrementByTwo = makeIncrementer(incrementAmount: 2)
 
print(incrementByTwo())  // Prints 2
print(incrementByTwo())  // Prints 2 (captured value is not modified)
 
class ObjectA {
    var completionHandler: (() -> Void)?
 
    deinit {
        print("ObjectA deinitialized")
    }
}
 
class ObjectB {
    weak var objectA: ObjectA?
 
    deinit {
        print("ObjectB deinitialized")
    }
}
 
var objectA: ObjectA? = ObjectA()
var objectB: ObjectB? = ObjectB()
 
objectA?.completionHandler = { [weak objectB] in
    guard let objectB = objectB else {
        return
    }
 
    print("Closure executed")
    objectB.objectA = objectA
}
 
// The following line is not needed here
// objectB?.objectA = objectA
 
// Setting both references to nil to deallocate the objects
objectA = nil
objectB = nil
 
