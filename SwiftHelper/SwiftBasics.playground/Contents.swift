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
 
func makeIncrementer(incrementAmount: Int) -> (Int) -> Int {
    var total = 0
 
    let incrementer: (Int) -> Int = { [total] resultIn in
        // Here, 'total' is captured in the closure
        // with a capture list to create a copy.
        var capturedTotal = total
        capturedTotal += incrementAmount
        print("result is \(resultIn)")
        return capturedTotal
    }
 
    return incrementer
}

var clousreExm: (Int) -> () = { _ in
    print("arg")
}
 
let incrementByTwo = makeIncrementer(incrementAmount: 2)
 
print(incrementByTwo(446))  // Prints 2
print(incrementByTwo(61))  // Prints 2 (captured value is not modified)
 
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

/*
 In Swift, protocols can include both read-only (get-only) and read-write (get-set) properties. Let's look at examples of protocols with variables for both scenarios:

*/

//Protocols with get set property:

protocol Vehicle {
    var speed: Double { get set }
    var isRunning: Bool { get set }
    
    func start()
    func stop()
}

class Car: Vehicle {
    var speed: Double = 0.0
    var isRunning: Bool = false
    
    func start() {
        if !isRunning {
            isRunning = true
            print("Car started.")
        } else {
            print("Car is already running.")
        }
    }
    
    func stop() {
        if isRunning {
            isRunning = false
            speed = 0.0
            print("Car stopped.")
        } else {
            print("Car is already stopped.")
        }
    }
}

var myCar = Car()
myCar.start()
print("Current speed: \(myCar.speed)")
myCar.speed = 60.0
print("Updated speed: \(myCar.speed)")
myCar.stop()


/*
 In this example, the Vehicle protocol includes both speed and isRunning properties with both get and set. The Car class conforms to this protocol and provides implementations for the properties and methods.
 */

//Protocols with get only property

protocol Shape {
    var area: Double { get }
}

class Circle: Shape {
    let radius: Double
    
    init(radius: Double) {
        self.radius = radius
    }
    
    var area: Double {
        return Double.pi * radius * radius
    }
}

class Square: Shape {
    let sideLength: Double
    
    init(sideLength: Double) {
        self.sideLength = sideLength
    }
    
    var area: Double {
        return sideLength * sideLength
    }
}

let circle = Circle(radius: 5.0)
print("Circle Area: \(circle.area)")

let square = Square(sideLength: 4.0)
print("Square Area: \(square.area)")

/*
 In this example, the Shape protocol includes an area property with only a get requirement. Both Circle and Square conform to this protocol and provide read-only implementations for the area property. The area is calculated based on the shape-specific formulas.
 */

@frozen enum MyFrozenEnum {
    case case1
    case case2
    // ... other cases
    case case3
}

class Animal {
    func makeSound() {
        print("Some generic animal sound")
    }
}

class Mammal: Animal {
    func giveBirth() {
        print("Giving birth to live young")
    }
}

class Dog: Mammal {
    func bark() {
        print("Woof woof!")
    }
}

let myDog = Dog()
myDog.makeSound()   // Inherits from Animal
myDog.giveBirth()   // Inherits from Mammal
myDog.bark()        // Specific to Dog


class A {
    func methodA() {
        print("Method A")
    }
}

class B {
    func methodB() {
        print("Method B")
    }
}

// This will result in a compilation error
//class C: A, B {
//    // Error: 'C' cannot inherit from multiple classes ('A' and 'B')
//}


protocol A1 {
    func methodA()
}

protocol B1 {
    func methodB()
}

class C: A1, B1 {
    func methodA() {
        print("Method A")
    }

    func methodB() {
        print("Method B")
    }
}

let instanceC = C()
instanceC.methodA()  // Output: Method A
instanceC.methodB()  // Output: Method B


// 1. Generic Function for Swapping Values:

func swapValues<T>(_ a: inout T, _ b: inout T) {
    let temp = a
    a = b
    b = temp
}

var x = 5
var y = 10
swapValues(&x, &y)
print("Swapped values: x = \(x), y = \(y)")

// 2. Generic Stack:

struct Stack<Element> {
    private var elements: [Element] = []

    mutating func push(_ element: Element) {
        elements.append(element)
    }

    mutating func pop() -> Element? {
        return elements.popLast()
    }
}

var intStack = Stack<Int>()
intStack.push(1)
intStack.push(2)
print("Popped: \(intStack.pop() ?? 0)")

var stringStack = Stack<String>()
stringStack.push("Hello")
stringStack.push("World")
print("Popped: \(stringStack.pop() ?? "")")

// 3. Generic Protocol:

protocol Printable {
    associatedtype DataType
    func printValue(_ value: DataType)
}

struct Printer<T>: Printable {
    typealias DataType = T

    func printValue(_ value: T) {
        print(value)
    }
}

let intPrinter = Printer<Int>()
intPrinter.printValue(42)

let stringPrinter = Printer<String>()
stringPrinter.printValue("Hello, Generics!")

// 4. Generic Optionals:

func unwrap<T>(_ value: T?) -> T {
    guard let unwrappedValue = value else {
        fatalError("Unexpected nil value")
    }
    return unwrappedValue
}

let optionalInt: Int? = 42
let unwrappedInt = unwrap(optionalInt)
print("Unwrapped Int: \(unwrappedInt)")

let optionalString: String? = "Hello, Generics!"
let unwrappedString = unwrap(optionalString)
print("Unwrapped String: \(unwrappedString)")

// 5. Generic Where Clause:

func combine<T, U>(_ a: T, _ b: U) -> String where T: CustomStringConvertible, U: CustomStringConvertible {
    return a.description + b.description
}

let result1 = combine(42, " is the meaning of life")
print(result1)

let result2 = combine("Hello", 2023)
print(result2)


class Solution {
    func lengthOfLIS(_ nums: [Int]) -> Int {
        var lis = [Int]()
        
        var lis2 = Array(repeating: 1, count: nums.count)

        for i in 0..<nums.count{
            lis.append(1)
        }

        for j in 0..<nums.count{
            for k in 0..<j{
                if(nums[j] > nums[k] && lis[j] < lis[k] + 1){
                    lis[j] += 1
                }
            }
        }

        var result = 0

        for i in lis{
            result = max(result, i)
        }

        return result
    }
}

let s1 = Solution()
let ans = s1.lengthOfLIS([1, 5, 4, 2, 7, 12, 8, 2, 9])
print("length of LIS is \(ans)")


  public class ListNode {
      public var val: Int
      public var next: ListNode?
      public init() { self.val = 0; self.next = nil; }
      public init(_ val: Int) { self.val = val; self.next = nil; }
      public init(_ val: Int, _ next: ListNode?) { self.val = val; self.next = next; }
  }
 
class Solution2 {
    func middleNode(_ head: ListNode?) -> ListNode? {
        
        var size = 0

        if head == nil{
            return head
        }

        if head?.next == nil{
            return head
        }

        var head2 = head

        while(head2?.next != nil){
            head2 = head2?.next
            size += 1
        }
        
        print("now size is \(size)")

       var count = size/2
       var temp = head

       while(count>0){

           temp = temp?.next

           count -= 1

       }
        print("now temp val is \(String(describing: temp?.val) )")

       if size%2 != 0{
           temp = temp?.next
       }

       return temp





    }
}

let temp1 = Solution2()

//[1,2,3,4,5,6]

let head = ListNode(1)
head.next = ListNode(2)
head.next?.next = ListNode(3)
head.next?.next?.next = ListNode(4)
head.next?.next?.next?.next = ListNode(5)
head.next?.next?.next?.next?.next = ListNode(6)

temp1.middleNode(head)
//demo

//Unwrapping optionals:

let optionalValue: Int? = 42
let unwrappedValue = optionalValue!
print("Forced Unwrapped Value: \(unwrappedValue)")


if let unwrappedValue3 = optionalValue {
    print("Optional Binding Value: \(unwrappedValue3)")
} else {
    print("Optional is nil")
}

func processOptionalValue(_ optionalValue: Int?) {
    guard let unwrappedValue = optionalValue else {
        print("Optional is nil")
        return
    }
    
    print("Guard Statement Value: \(unwrappedValue)")
}

processOptionalValue(42)


let unwrappedValue2 = optionalValue ?? 0
print("Nil Coalescing Value: \(unwrappedValue2)")


switch optionalValue {
case let .some(unwrappedValue):
    print("Switch Case Value: \(unwrappedValue)")
case .none:
    print("Switch Case: Optional is nil")
}

// Optional Chaining in swift

struct Person {
    var residence: Residence?
}

struct Residence {
    var address: Address?
}

struct Address {
    var street: String
}

let person = Person()

// Accessing a nested property with optional chaining
let street = person.residence?.address?.street
print(street) // Output: nil (person.residence is nil)

// Define a custom error enum
enum FileError: Error {
    case fileNotFound
    case permissionDenied
    case fileCorrupted(reason: String)
}

// Function that throws custom errors
func readFileContent(fileName: String) throws -> String {
    // Assume some logic that may throw errors
    guard let fileContent = try? String(contentsOfFile: fileName) else {
        throw FileError.fileNotFound
    }
    
    // Additional logic that may throw other errors
    guard hasPermission() else {
        throw FileError.permissionDenied
    }
    
    // Yet more logic that may throw a different error
    guard isFileContentValid(fileContent) else {
        throw FileError.fileCorrupted(reason: "Invalid content")
    }
    
    return fileContent
}

// Helper function to simulate permission check
func hasPermission() -> Bool {
    return false // Change to true to simulate having permission
}

// Helper function to simulate content validation
func isFileContentValid(_ content: String) -> Bool {
    // Assume some validation logic
    return content.count > 10
}

// Example usage with do-catch and switch case
do {
    let fileName = "example.txt"
    let fileContent = try readFileContent(fileName: fileName)
    print("File content: \(fileContent)")
} catch let error as FileError {
    // Handle specific errors using switch case
    switch error {
    case .fileNotFound:
        print("File not found error")
    case .permissionDenied:
        print("Permission denied error")
    case let .fileCorrupted(reason):
        print("File corrupted error: \(reason)")
    }
} catch {
    // Handle other generic errors
    print("An unexpected error occurred: \(error)")
}

let numbers = [1, 2, 3, 4, 5]
let squaredNumbers = numbers.map { $0 * $0 }
print(squaredNumbers) // Output: [1, 4, 9, 16, 25]

//let numbers = [1, 2, 3, 4, 5]
let evenNumbers = numbers.filter { $0 % 2 == 0 }
print(evenNumbers) // Output: [2, 4]

//let numbers = [1, 2, 3, 4, 5]
let sum = numbers.reduce(0) { $0 + $1 }
print(sum) // Output: 15

let words = ["apple", "banana", "orange", "grape"]
let sortedWords = words.sorted { $0.count < $1.count }
print(sortedWords) // Output: ["grape", "apple", "banana", "orange"]

// Using map with explicit types
//let numbers = [1, 2, 3, 4, 5]
let squaredNumbers2 = numbers.map { (val: Int) -> Int in
    return val * val
}
print(squaredNumbers2) // Output: [1, 4, 9, 16, 25]

// Using filter with explicit types
let evenNumbers2 = numbers.filter { (val: Int) -> Bool in
    return val % 2 == 0
}
print(evenNumbers2) // Output: [2, 4]

numbers.forEach { (val: Int) in
    print(val * 2)
}

//temp

let setNumbers: Set<Int> = [1, 2, 3, 4, 5]
let squaredSetNumbers = setNumbers.map { $0 * $0 }
squaredSetNumbers
// squaredSetNumbers is a Set containing the squares of the elements

let dictionaryNumbers = ["one": 1, "two": 2, "three": 3]
let doubledValues = dictionaryNumbers.mapValues { $0 * 2 }
// doubledValues is a dictionary with values doubled

let stuff: [Any] = ["imp", "arr", 0, 1, 2]

let filteredArr = stuff.compactMap { (val: Any) -> String? in
    return val as? String
}

struct Man: Equatable, Hashable {
    var name: String
    var age: Int

    // Implementing Equatable
    static func == (lhs: Man, rhs: Man) -> Bool {
        return lhs.name == rhs.name && lhs.age == rhs.age
    }
    
    // Implementing Hashable
    func hash(into hasher: inout Hasher) {
        // Combine hash values of properties using XOR (^)
        hasher.combine(name.hashValue)
        hasher.combine(age.hashValue)
    }
}

// Example usage
let person1 = Man(name: "John", age: 30)
let person2 = Man(name: "Jane", age: 25)
let person3 = Man(name: "John", age: 30)

print(person1 == person2)  // false
print(person1 == person3)  // true

// Using in a Set (requires Hashable)
let uniquePeople: Set<Man> = [person1, person2, person3]
print(uniquePeople.count)  // 2, as person1 and person3 are considered equal in the Set

// Using as a key in a Dictionary (requires Hashable)
let personDictionary = [person1: "Engineer", person2: "Doctor"]
print(personDictionary[person3])  // Prints: Optional("Engineer"), as person3 is equal to person1

// enums by default are hashable and equatable


struct P: Codable {
    var personName: String
    var personAge: Int
    var personAddress: String

    // Custom encoding logic
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(personName, forKey: .personName)
        try container.encode(personAge, forKey: .personAge)

        // You can perform additional encoding logic if needed
        // ...

        // For example, encoding address as uppercase
        try container.encode(personAddress.uppercased(), forKey: .personAddress)
    }

    // Custom decoding logic
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        personName = try container.decode(String.self, forKey: .personName)
        personAge = try container.decode(Int.self, forKey: .personAge)

        // You can perform additional decoding logic if needed
        // ...

        // For example, decoding address as lowercase
        personAddress = try container.decode(String.self, forKey: .personAddress).lowercased()
    }

    enum CodingKeys: String, CodingKey {
        case personName = "name"
        case personAge = "age"
        case personAddress = "address"
    }
}

prefix operator +++

prefix func +++(value: Int) -> Int {
    return value + 1
}

var myNumber = 5
let result = +++myNumber
print(result) // Output: 6

postfix operator ---

postfix func ---(value: Int) -> Int {
    return value - 1
}

var anotherNumber = 8
let decrementedResult = anotherNumber---
print(decrementedResult) // Output: 7

struct Op {
    var x: Double
    var y: Double
}

infix operator +-: AdditionPrecedence

func +-(left: Op, right: Op) -> Op {
    return Op(x: left.x + right.x, y: left.y - right.y)
}

let point1 = Op(x: 2.0, y: 3.0)
let point2 = Op(x: 1.0, y: 2.0)
let resultPoint = point1 +- point2
print(resultPoint) // Output: Point(x: 3.0, y: 1.0)

func loadImage(index: Int) async -> UIImage {
    let imageURL = URL(string: "https://picsum.photos/200/300")!
    let request = URLRequest(url: imageURL)
    let (data, _) = try! await URLSession.shared.data(for: request, delegate: nil)
    print("Finished loading image \(index)")
    return UIImage(data: data)!
}

func loadImages() {
    Task {
        let firstImage = await loadImage(index: 1)
        let secondImage = await loadImage(index: 2)
        let thirdImage = await loadImage(index: 3)
        let images = [firstImage, secondImage, thirdImage]
    }
}

loadImages()

func loadImages2() {
    Task {
        async let firstImage = loadImage(index: 1)
        async let secondImage = loadImage(index: 2)
        async let thirdImage = loadImage(index: 3)
        let images = await [firstImage, secondImage, thirdImage]
    }
}

loadImages2()
