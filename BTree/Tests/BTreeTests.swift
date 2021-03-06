/**
 * Copyright (c) 2017 Ivan Magda
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import XCTest

class BTreeTests: XCTestCase {
    
    typealias Tree = BTree<Int, Int>
    
    static let order = 3
    
    var bTree: Tree!
    
    override func setUp() {
        super.setUp()
        bTree = Tree(order: BTreeTests.order)
    }
    
    // MARK: - Tests on empty tree
    
    func testOrder() {
        XCTAssertEqual(bTree.order, BTreeTests.order)
    }
    
    func testRootNode() {
        XCTAssertNotNil(bTree.root)
    }
    
    func testNumberOfNodesOnEmptyTree() {
        XCTAssertEqual(bTree.numberOfKeys, 0)
    }
    
    func testInorderTraversalOfEmptyTree() {
        bTree.traverseKeysInOrder { _ in
            XCTFail("Inorder travelsal fail.")
        }
    }
    
    func testSubscriptOnEmptyTree() {
        XCTAssertEqual(bTree[1], nil)
    }
    
    func testSearchEmptyTree() {
        XCTAssertEqual(bTree.value(for: 1), nil)
    }
    
    func testDescriptionOfEmptyTree() {
        XCTAssertEqual(bTree.description, "[]")
    }
    
    func testInsertToEmptyTree() {
        bTree.insert(1, for: 1)
        
        XCTAssertEqual(bTree[1]!, 1)
    }
    
    func testRemoveFromEmptyTree() {
        bTree.remove(1)
        XCTAssertEqual(bTree.description, "[]")
    }
    
    func testInorderArrayFromEmptyTree() {
        XCTAssertEqual(bTree.inorderArrayFromKeys, [Int]())
    }
    
    // MARK: - Travers
    
    func testInorderTravelsal() {
        for i in 1...100 {
            bTree.insert(i, for: i)
        }
        
        var j = 1
        
        bTree.traverseKeysInOrder { i in
            XCTAssertEqual(i, j)
            j += 1
        }
    }
    
    // MARK: - Conversion
    
    func testInorderArray() {
        bTree.insertKeysUpTo(100)
        
        let returnedArray = bTree.inorderArrayFromKeys
        let targetArray = Array<Int>(1...100)
        
        XCTAssertEqual(returnedArray, targetArray)
    }
    
    // MARK: - Search
    
    func testSearchForMaximum() {
        for i in 1...20 {
            bTree.insert(i, for: i)
        }
        
        XCTAssertEqual(bTree.value(for: 20)!, 20)
    }
    
    func testSearchForMinimum() {
        for i in 1...20 {
            bTree.insert(i, for: i)
        }
        
        XCTAssertEqual(bTree.value(for: 1)!, 1)
    }
    
    // MARK: - Insertion
    
    func testInsertion() {
        let upperBound = 100
        bTree.insertKeysUpTo(upperBound)
        
        XCTAssertEqual(bTree.numberOfKeys, upperBound)
        
        for i in 1...upperBound {
            XCTAssertNotNil(bTree[i])
        }
        
        do {
            try bTree.checkBalance()
        } catch {
            XCTFail("BTree is not balanced")
        }
    }
    
    // MARK: - Deletion
    
    func testRemoveMaximum() {
        for i in 1...20 {
            bTree.insert(i, for: i)
        }
        
        bTree.remove(20)
        
        XCTAssertNil(bTree[20])
        
        do {
            try bTree.checkBalance()
        } catch {
            XCTFail("BTree is not balanced")
        }
    }
    
    func testRemoveMinimum() {
        bTree.insertKeysUpTo(20)
        
        bTree.remove(1)
        
        XCTAssertNil(bTree[1])
        
        do {
            try bTree.checkBalance()
        } catch {
            XCTFail("BTree is not balanced")
        }
    }
    
    func testRemoveSome() {
        bTree.insertKeysUpTo(20)
        
        bTree.remove(6)
        bTree.remove(9)
        
        XCTAssertNil(bTree[6])
        XCTAssertNil(bTree[9])
        
        do {
            try bTree.checkBalance()
        } catch {
            XCTFail("BTree is not balanced")
        }
    }
    
    func testRemoveSomeFrom4thOrder() {
        bTree = Tree(order: 4)
        bTree.insertKeysUpTo(40)
        
        bTree.remove(6)
        bTree.remove(9)
        
        XCTAssertNil(bTree[6])
        XCTAssertNil(bTree[9])
        
        do {
            try bTree.checkBalance()
        } catch {
            XCTFail("BTree is not balanced")
        }
    }
    
    func testRemoveAll() {
        bTree.insertKeysUpTo(20)
        
        XCTAssertEqual(bTree.numberOfKeys, 20)
        
        for i in (1...20).reversed() {
            bTree.remove(i)
        }
        
        do {
            try bTree.checkBalance()
        } catch {
            XCTFail("BTree is not balanced")
        }
        
        XCTAssertEqual(bTree.numberOfKeys, 0)
    }
    
    // MARK: Stress Test
    
    func testStress() {
        func getRandom(_ array: [Int]) -> Int {
            let randomIndex = Int(arc4random_uniform(UInt32(array.count)))
            return array[randomIndex]
        }
        
        let orders = 16
        let epochs = 10
        
        for order in 3...orders {
            for _ in 0..<epochs {
                bTree = Tree(order: order)
                
                let input = Array(0...1000).shuffled()
                for (index, value) in input.enumerated() {
                    bTree.insert(value, for: value)
                    
                    if index % 10 == 0 {
                        bTree.remove(getRandom(bTree.inorderArrayFromKeys))
                    }
                    
                    do {
                        try bTree.checkBalance()
                    } catch {
                        XCTFail("BTree is not balanced")
                    }
                }
            }
        }
    }
}

// MARK: - Node (checkBalance) -

enum BTreeError: Error {
    case tooManyNodes
    case tooFewNodes
}

extension Node {
    func checkBalance(isRoot root: Bool) throws {
        if isTooLarge {
            throw BTreeError.tooManyNodes
        } else if !root && isTooSmall {
            throw BTreeError.tooFewNodes
        }
        
        if !isLeaf {
            for child in children! {
                try child.checkBalance(isRoot: false)
            }
        }
    }
}

// MARK: - BTree where Key: SignedInteger, Value: SignedInteger -

extension BTree where Key: SignedInteger, Value: SignedInteger {
    func insertKeysUpTo(_ to: Int) {
        var k: Key = 1
        var v: Value = 1
        
        for _ in 1...to {
            insert(v, for: k)
            k = k + 1
            v = v + 1
        }
    }
    
    func checkBalance() throws {
        try root.checkBalance(isRoot: true)
    }
}
