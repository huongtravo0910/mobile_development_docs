import UIKit

// CONCURRENCY PROBLEM AND SOLUTIONS SWIFT


//THREAD EXPLOSION
//Cyclic creation of a big quantity of threads.
// Problems
//let queue = DispatchQueue(label: "thread explosion code", attributes: .concurrent)
//
//for i in 0 ... 1000 {
//    // Async Tasks
//    queue.async {
//        Thread.sleep(forTimeInterval: 1)
//        print("Executed Task \(i)")
//    }
//}
//
//// Sync Task
//DispatchQueue.main.sync {
//    print("All Tasks Completed")
//}

//Solution: Limit number of thread at a time
//let concurrentTasks = 4
//
//let queue1 = DispatchQueue(label: "thread explosion solution", attributes: .concurrent)
//
//let semaphore = DispatchSemaphore(value: concurrentTasks)
//
//for i in 0 ... 1000 {
//    queue1.async {
//        Thread.sleep(forTimeInterval: 1)
//        print("Executed Task \(i)")
//        semaphore.signal()   // Sema Count Increased
//    }
//    semaphore.wait() // Sema Count Decreased
//}
//
//// Async Task
//DispatchQueue.main.async {
//    print("All Tasks Completed")
//}



// ------------------
//DEALOCK
//Deadlocks happens when two threads are waiting for each other to release a shared resource, ending up blocked for infinity.
//let aSerialQueue = DispatchQueue(label: "Deadlocks")
//
//aSerialQueue.sync {
//    // The code inside this closure will be executed synchronously.
//    aSerialQueue.sync {
//        // The code inside this closure should also be executed synchronously and on the same queue that is still executing the outer closure ==> It will keep waiting for it to finish ==> it will never be executed ==> Deadlock.
//    }
//}
// Dependency in operation
// Cause1 : Thread explosion
// Cause2 : Dispatch synchronously to the current thread

// Example for cause 1: above
// Example for cause 2:


//let waiter = DispatchQueue(label: "waiter")
//let chef = DispatchQueue(label: "chef")

// synchronously order the soup
//waiter.sync {
//  print("Waiter: hi chef, please make me 1 soup.")
//
//  // synchronously prepare the soup
//  chef.sync {
//    print("Chef: sure thing! Please ask the customer what soup they wanted.")
//
//    // synchronously ask for clarification
//    waiter.sync {
//      print("Waiter: Sure thing!")
//
//      print("Waiter: Hello customer. What soup did you want again?")
//    }
//  }
//}

//func deadLock() {
//    let myQueue = DispatchQueue(label: "myLabel")
//    myQueue.async {
//        myQueue.sync {
//            print("Inner block called")
//        }
//        print("Outer block called")
//    }
//}
//
//deadLock()

// Solutions for deadlock
// Solution 2: using async
//let waiter = DispatchQueue(label: "waiter")
//let chef = DispatchQueue(label: "chef")

//// synchronously order the soup
//waiter.async {
//  print("Waiter: hi chef, please make me 1 soup.")
//
//  // synchronously prepare the soup
//  chef.async {
//    print("Chef: sure thing! Please ask the customer what soup they wanted.")
//
//    // synchronously ask for clarification
//    waiter.async {
//      print("Waiter: Sure thing!")
//
//      print("Waiter: Hello customer. What soup did you want again?")
//    }
//  }
//}

// Solution 2: using sync responsibly
//let waiter = DispatchQueue(label: "waiter")
//let chef = DispatchQueue(label: "chef")
//
//waiter.sync {
//  print("Waiter: hi chef, please make me 1 soup.")
//
//  // synchronously prepare the soup
//  chef.sync {
//    print("Chef: sure thing! Please ask the customer what soup they wanted.")
//
//  }
//}
//
//waiter.sync {
//  print("Waiter: Sure thing!")
//
//  print("Waiter: Hello customer. What soup did you want again?")
//}


// ------------------
//RACE CONDITION
//Race condition happens when two or more threads access a shared data and change it’s value at the same time.

// Example:
//        let concurrentQueue = DispatchQueue(label: "Race codition", attributes: .concurrent)
//        var number = 0
//        var strings: [String:Int] = [:]
//        concurrentQueue.async {
//          for _ in 0...10 {
//              number += 1
//              strings["🔴 \(number)"] = number
//              print("🔴: \(number)")
//          }
//      }
//      concurrentQueue.async {
//          for _ in 0...10 {
//              number += 1
//              strings["🔵 \(number)"] = number
//              print("🔵: \(number)")
//          }
//      }
//
//      DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
//          print("Number = \(number)")
//          for item in strings {
//              print(item)
//          }
//      }

// Solution
// Solution 1: Sersial Queue
//let serialQueue = DispatchQueue(label: "Sersial Queue")
//        var number = 0
//        var strings: [String:Int] = [:]
//      serialQueue.async {
//          for _ in 0...10 {
//              number += 1
//              strings["🔴 \(number)"] = number
//              print("🔴: \(number)")
//          }
//      }
//      serialQueue.async {
//          for _ in 0...10 {
//              number += 1
//              strings["🔵 \(number)"] = number
//              print("🔵: \(number)")
//          }
//      }
//
//      DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
//          print("Number = \(number)")
//          for item in strings {
//              print(item)
//          }
//      }

// Solution 2: Synchronous
//        let concurrentQueue = DispatchQueue(label:  "Synchronous", attributes: .concurrent)
//        var number = 0
//        var strings: [String:Int] = [:]
//        concurrentQueue.sync {
//          for _ in 0...10 {
//              number += 1
//              strings["🔴 \(number)"] = number
//              print("🔴: \(number)")
//          }
//      }
//      concurrentQueue.sync {
//          for _ in 0...10 {
//              number += 1
//              strings["🔵 \(number)"] = number
//              print("🔵: \(number)")
//          }
//      }
//
////sThread.sleep(forTimeInterval: 3)
//
//      DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
//          print("Number = \(number)")
//          for item in strings {
//              print(item)
//          }
//      }


// Solution 3: Lock queue
//        let concurrentQueue = DispatchQueue(label: "Lock queue", attributes: .concurrent)
//        let serialQueue = DispatchQueue(label: "Sersial Queue")
//        var number = 0
//        var strings: [String:Int] = [:]
//        concurrentQueue.async {
//            serialQueue.sync {
//              for _ in 0...10 {
//                  number += 1
//                  strings["🔴 \(number)"] = number
//                  print("🔴: \(number)")
//              }
//            }
//      }
//      concurrentQueue.async {
//        serialQueue.sync {
//          for _ in 0...10 {
//              number += 1
//              strings["🔵 \(number)"] = number
//              print("🔵: \(number)")
//          }
//        }
//      }
//
//      DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
//          print("Number = \(number)")
//          for item in strings {
//              print(item)
//          }
//      }

// Solution 4: Barrier
//        let concurrentQueue = DispatchQueue(label: "Race codition", attributes: .concurrent)
//        var number = 0
//        var strings: [String:Int] = [:]
//concurrentQueue.async(flags: .barrier) {
//          for _ in 0...10 {
//              number += 1
//              strings["🔴 \(number)"] = number
//              print("🔴: \(number)")
//          }
//      }
//concurrentQueue.async(flags: .barrier) {
//          for _ in 0...10 {
//              number += 1
//              strings["🔵 \(number)"] = number
//              print("🔵: \(number)")
//          }
//      }
//DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
//          print("Number = \(number)")
//    for (item) in strings.enumerated() {
//              print("\(item.offset): \(item)")
//          }
//      }
//
//
//var someDict:[Int:String] = [1:"One", 2:"Two", 3:"Three"]
//DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
//
//          for item in someDict {
//              print(item)
//          }
//      }



// ------------------
// PRIORITY INVERSION
// Priority inversion happens when a high priority task is prevented from running by a lower priority task, effectively inverting their relative priorities.

//enum Color: String {
//    case blue = "🔵"
//    case white = "⚪️"
//}
//
//func output(color: Color, times: Int) {
//    for _ in 1...times {
//        print(color.rawValue)
//    }
//}
//
//let starterQueue = DispatchQueue(label: "starterQueue", qos: .userInteractive)
//let utilityQueue = DispatchQueue(label: "starterQueue", qos: .utility)
//let backgroundQueue = DispatchQueue(label: "starterQueue", qos: .background)
//let count = 10
//
//starterQueue.async {
//
//    backgroundQueue.async {
//        output(color: .white, times: count)
//    }
//
//    backgroundQueue.async {
//        output(color: .white, times: count)
//    }
//
//    utilityQueue.async {
//        output(color: .blue, times: count)
//    }
//
//    utilityQueue.async {
//        output(color: .blue, times: count)
//    }
//backgroundQueue.sync {}
//}
// Solution: using async


//var dictionary = ["one":1,"two":2,"three":3]
//for item in dictionary {
//    print(item)
//}
//DispatchQueue(label: "sync run").sync {
//    for item in dictionary {
//        print(item)
//    }
//}
//DispatchQueue.main.async {
//    for item in dictionary {
//        print(item)
//    }
//}


//// Change name
////let nameChangingPerson = Person(firstName:"Tra", lastName: "Vo")
//let nameChangingPerson = ThreadSafePerson(firstName:"Tra", lastName: "Vo")
////nameChangingPerson.changeName(firstName: "Tran", lastName: "Voo")
////nameChangingPerson.name
//
//let workerQueue = DispatchQueue(label: "race conditions", attributes: .concurrent)
//let nameChangeGroup = DispatchGroup()
//
//let nameList = [("fn1","ln1"), ("fn2","ln2"),("fn3","ln3"),("fn4","ln4")]
//
//for (index, name) in nameList.enumerated() {
//    workerQueue.async(group: nameChangeGroup) {
//        usleep(UInt32(10_000 * index))
//        nameChangingPerson.changeName(firstName: name.0, lastName: name.1)
//        print("Current name: \(nameChangingPerson.name)")
//    }
//}
//
//nameChangeGroup.notify(queue: DispatchQueue.global()){
//    print("Final name \(nameChangingPerson.name)")
//}
//
//class ThreadSafePerson: Person {
//    let isolationQueue = DispatchQueue(label: "ThreadSafe", attributes: .concurrent)
//    override func changeName(firstName: String, lastName: String) {
//        isolationQueue.async(flags: .barrier) {
//            super.changeName(firstName: firstName, lastName: lastName)
//        }
//    }
//    override var name: String{
//        return isolationQueue.sync {
//            return super.name
//        }
//    }
//}

// ---------- READER AND WRITER PROBLEM ---------

// Initialization of lock, pthread_rwlock_t is a value type and must be declared as var in order to refer it later. Make sure not to copy it.
//var lock = pthread_rwlock_t()
//pthread_rwlock_init(&lock, nil)
//
//// Protecting read section:
//pthread_rwlock_rdlock(&lock)
//// Read shared resource
//pthread_rwlock_unlock(&lock)
//
//// Protecting write section:
//pthread_rwlock_wrlock(&lock)
//// Write shared resource
//pthread_rwlock_unlock(&lock)
//
//// Clean up
//pthread_rwlock_destroy(&lock)

//let threadSafeCollection = ThreadSafeCollection<String>()
//
//let workerQueue1 = DispatchQueue(label: "Read and Write Example1", attributes: .concurrent)
//let workerQueue2 = DispatchQueue(label: "Read and Write Example2", attributes: .concurrent)
//let group = DispatchGroup()
//workerQueue1.async(group: group) {
//    threadSafeCollection.append("Hai")
//    threadSafeCollection.append("Ba")
//    threadSafeCollection.remove(1)
//    threadSafeCollection.append("Bon")
//    threadSafeCollection.append("Nam")
//    threadSafeCollection.append("Hai")
//    threadSafeCollection.append("Ba")
//    threadSafeCollection.remove(1)
//    threadSafeCollection.append("Bon")
//    threadSafeCollection.append("Nam")
//    threadSafeCollection.remove(2)
//    for element in threadSafeCollection.elements {
//        print(element)
//    }
//}
//
//workerQueue2.async(group: group) {
//    threadSafeCollection.append("Sau")
//    threadSafeCollection.remove(0)
//    threadSafeCollection.append("Bay")
//    threadSafeCollection.append("Tam")
//    threadSafeCollection.remove(3)
//    threadSafeCollection.append("Chin")
//    threadSafeCollection.append("Sau")
//    threadSafeCollection.remove(0)
//    threadSafeCollection.append("Bay")
//    threadSafeCollection.append("Tam")
//    threadSafeCollection.remove(3)
//    threadSafeCollection.append("Chin")
//    for element in threadSafeCollection.elements {
//        print(element)
//    }
//}
//
//group.notify(queue: DispatchQueue.global()){
//    for element in threadSafeCollection.elements {
//        print("final :",element)
//    }
//}
//
//
//class ThreadSafeCollection<Element> {
//
//  // Concurrent synchronization queue
//  private let queue = DispatchQueue(label: "ThreadSafeCollection.queue", attributes: .concurrent)
//
//  private var _elements: [Element] = []
//
//  var elements: [Element] {
//      var result: [Element] = []
//
//      queue.sync { // Read
//          result = _elements
//      }
//
//      return result
//  }
//
//  func append(_ element: Element) {
//      // Write with .barrier
//      // This can be performed synchronously or asynchronously not to block calling thread.
//    queue.async() {
//          self._elements.append(element)
//      }
//    }
//    func remove(_ index: Int) {
//        // Write with .barrier
//        // This can be performed synchronously or asynchronously not to block calling thread.
//      queue.async() {
//            self._elements.remove(at: index)
//        }
//      }
//  }

enum Color: String {
  case blue = "🔵"
  case white = "⚪️"
  }

  func output(color: Color, times: Int) {
      for _ in 1...times {
          print(color.rawValue)
      }
  }

  let starterQueue = DispatchQueue(label: "com.besher.starter", qos: .userInteractive)
  let utilityQueue = DispatchQueue(label: "com.besher.utility", qos: .utility)
  let backgroundQueue = DispatchQueue(label: "com.besher.background", qos: .background)
  let count = 10

  starterQueue.async {

      backgroundQueue.sync {
          output(color: .white, times: count)
      }

      utilityQueue.async {
          output(color: .blue, times: count)
      }

      // next statement goes here
  }
  //backgroundQueue.sync {}
