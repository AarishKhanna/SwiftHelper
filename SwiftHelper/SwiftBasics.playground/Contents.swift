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
