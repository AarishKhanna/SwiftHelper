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
//print(incrementByTwo())  // Prints 12
//print(incrementByTwo())  // Prints 14
//print(incrementByTwo())  // Prints 16
 
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
 
// example of traling closures

enum NetworkError: Error {
    case badURL
    case requestFailed
    // Add more cases as needed
}

func fetchData(from urlString: String, completion: @escaping (Result<Data, NetworkError>) -> Void) {
    // Check if the URL is valid
    guard let url = URL(string: urlString) else {
        completion(.failure(.badURL))
        return
    }

    // Create a URLSession task for making the network request
    let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
        // Check for errors
        if let error = error {
            completion(.failure(.requestFailed))
            print("Error: \(error)")
            return
        }

        // Check if there is data
        guard let data = data else {
            completion(.failure(.requestFailed))
            print("No data received")
            return
        }

        // Call the completion handler with the successful result
        completion(.success(data))
    }

    // Start the network request
    task.resume()
}

// Example usage:
let urlString = "https://jsonplaceholder.typicode.com/todos/1"
fetchData(from: urlString) { result in
    switch result {
    case .success(let data):
        // Handle successful result with the data
        print("Data received:", data)
    case .failure(let error):
        // Handle the error
        print("Error: \(error)")
    }
}

func performOperation(completion: () -> Int) -> Int {
    let result = completion()
    let doubledResult = result * 2
    print("Result of the operation: \(result), Doubled result: \(doubledResult)")

    // Store the result in another variable
    let storedResult = result
    print("Stored result: \(storedResult)")

    // Return the stored result
    return storedResult
}

// Using trailing closure syntax and storing the result
let returnedResult = performOperation {
    return 42
}

// Now you can use the returned result elsewhere in your code
print("Returned result: \(returnedResult)")

// some examples of enum

enum Color: String {
    case red = "FF0000"
    case green = "00FF00"
    case blue = "0000FF"
}

// Example of getting a case from its raw value
let rawValue = "00FF00"

if let color = Color(rawValue: rawValue) {
    print("Found color: \(color)")
} else {
    print("No matching color found for raw value: \(rawValue)")
}

enum Measurement {
    case length(Double)
    case weight(Double)
    case temperature(Double)
}

let measurement = Measurement.length(5.0)

if case let .length(value) = measurement {
    print("Length: \(value) meters")
} else if case let .weight(value) = measurement {
    print("Weight: \(value) kilograms")
} else if case let .temperature(value) = measurement {
    print("Temperature: \(value) degrees Celsius")
}

enum Measurement2 {
    case length(Double)
    case weight(Double)
    case temperature(Double)
}

let measurement2 = Measurement2.length(5.0)

switch measurement2 {
case let .length(value):
    print("Length: \(value) meters")
    
case let .weight(value):
    print("Weight: \(value) kilograms")
    
case let .temperature(value):
    print("Temperature: \(value) degrees Celsius")
}


/* In Swift, the distinction between classes and structs is similar in some aspects, but there are some differences. Here's how Swift handles mutability and assignment for structs and classes:

Structs:

Structs in Swift are value types.
If a struct is assigned to a constant (let), the entire struct becomes immutable, and you cannot modify any of its properties.
Reassignment of the entire struct itself is allowed. */


struct Point {
    var x: Int
    var y: Int
}

let p = Point(x: 1, y: 2) // Immutable, cannot modify p.x or p.y

/* Classes:

Classes in Swift are reference types.
If a class instance is assigned to a constant (let), the reference cannot be changed (reassigned), but the internal properties can still be modified. */

class Points {
    var x: Int
    var y: Int
    
    func changeVal(){
        self.y = self.y * 2
        self.x = self.x * 2
    }

    init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }
}

let p2 = Points(x: 1, y: 2)
p2.changeVal()
print("value x- \(p2.x)")
print("value y- \(p2.y)")

// p cannot be reassigned, but p.x and p.y can be modified

/*In summary:

For structs in Swift, when assigned to a constant (let), the entire struct becomes immutable.
For classes in Swift, when assigned to a constant (let), the reference cannot be changed, but the internal state of the class instance can be modified.
This behavior is consistent with the idea that structs are value types, and their immutability is enforced when assigned to constants, while classes are reference types, and constant references prevent reassignment but not modification of the referenced instance.
*/

//test commit
//test commit 2

