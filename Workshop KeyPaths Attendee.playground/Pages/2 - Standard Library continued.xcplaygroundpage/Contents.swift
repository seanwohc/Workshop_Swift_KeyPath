//: [Previous](@previous)

import Foundation

// Now let's look at some more complex functions 💪

struct Person {
    let name: String
    let age: Int
}

let unorderedDictionary: [String: Person] = ["EpicTeam2": Person(name: "Lee", age: 44),
                                             "EpicTeam1": Person(name: "Coco", age: 21),
                                             "EpicTeam4": Person(name: "Poco", age: 73),
                                             "EpicTeam3": Person(name: "Xixi", age: 33)]

let unordered = [Person(name: "John", age: 45),
                 Person(name: "Xavier", age: 12),
                 Person(name: "Charlie", age: 12),
                 Person(name: "Alexia", age: 23),
                 Person(name: "Franck", age: 86),
                 Person(name: "Tony", age: 16)]


unorderedDictionary.sorted(by: { $0.key < $1.key })

unordered.sorted(by: { $0.age < $1.age })

// How can we introduce a KeyPath-based syntax here 🤔

// Let's at the closure sorted() takes as argument
// Here's what its signature looks like: (Element, Element) -> Bool

// How do we go from a KeyPath to this signature?

func their<Root, Value: Comparable>(_ keyPath: KeyPath<Root, Value>) -> (Root, Root) -> Bool {
    // 👩🏽‍💻👨🏼‍💻 Implement `their()`
    return { (left: Root, right: Root) -> Bool in
        return left[keyPath: keyPath] < right[keyPath: keyPath]
    }
}

unorderedDictionary.sorted(by: their(\.key))
unordered.sorted(by: their(\.age))

// We could also introduce a custom operator, to shorten it even more
// However, I think most people will agree that it would damage readability

// Now let's go even further, and handle sorting over several attributes!

// This one is a bit more tricky. Here's what a naïve implementation looks like:

extension Sequence {
    func sorted<Value: Comparable>(by keyPaths: KeyPath<Element, Value>...) -> [Element] {
        // 👩🏽‍💻👨🏼‍💻 Implement `sorted()`
        return self.sorted{ (first, second) -> Bool in
            for keyPath in keyPaths {
                if first[keyPath: keyPath] >= second[keyPath: keyPath] {
                    return false
                }
            }
            return true
        }
    }
}

// However, when we try to use it...

// unordered.sorted(by: \.age, \.name)

// ❌ Won't compile unless all the KeyPaths refer to the same Comparable type...

// How do we solve this? Through a technique called type-erasure

struct SortDescriptor<Element> {
    private(set) var compare: (Element, Element) -> ComparisonResult

    static func ascending<T: Comparable>(_ attribute: KeyPath<Element, T>) -> SortDescriptor<Element> {
        // 👩🏽‍💻👨🏼‍💻 Implement `func ascending()`
        return SortDescriptor { (left, right) -> ComparisonResult in
            let (x, y) = (left[keyPath: attribute], right[keyPath: attribute])
            
            if x == y {
                return .orderedSame
            }else if x < y{
                return .orderedAscending
            }else{
                return .orderedDescending
            }
        }
    }
}

extension Sequence {
    func sorted(by sortCriteria: SortDescriptor<Element>...) -> [Element] {
        return sorted(by: { (elm1, elm2) -> Bool in
            for sortCriterion in sortCriteria {
                switch sortCriterion.compare(elm1, elm2) {
                case .orderedSame:
                    break
                case .orderedAscending:
                    return true
                case .orderedDescending:
                    return false
                }
            }
            
            return false
        })
    }
}

unordered.sorted(by: .ascending(\.age), .ascending(\.name))

// Now let's implement a descending sort criterion

extension SortDescriptor {
    static func descending<T: Comparable>(_ attribute: KeyPath<Element, T>) -> SortDescriptor<Element> {
        // 👩🏽‍💻👨🏼‍💻 Implement `func descending()`
        return SortDescriptor { (left, right) -> ComparisonResult in
            let (x, y) = (left[keyPath: attribute], right[keyPath: attribute])
            
            if x == y {
                return .orderedSame
            }else if x > y{
                return .orderedDescending
            }else{
                return .orderedAscending
            }
        }
    }
}

unordered.sorted(by: .ascending(\.age), .descending(\.name))
let result = unorderedDictionary.sorted(by: .ascending(\.key))

let values = unorderedDictionary.values.sorted(by: .ascending(\.age))

unorderedDictionary.sorted(by: .ascending(\.value.age))
//: [Next](@next)
