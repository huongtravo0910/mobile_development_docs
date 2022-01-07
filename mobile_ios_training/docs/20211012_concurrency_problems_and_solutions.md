# CONCURRENCY PROBLEM AND SOLUTIONS SWIFT

## THREAD EXPLOSION
- What? 
  - Cyclic creation of a big quantity of threads.
  - Example code: 
    ```swift
    let queue = DispatchQueue(label: "thread explosion code", attributes: .concurrent)

    for i in 0 ... 1000 {
        queue.async {
            Thread.sleep(forTimeInterval: 1)
            print("Executed Task \(i)")
        }
    }

    DispatchQueue.main.sync {
        print("All Tasks Completed")
    }
- Solution:
  - Limit number of thread at a time
  - Example code:
  ```swift
    let concurrentTasks = 4

    let queue1 = DispatchQueue(label: "thread explosion solution", attributes: .concurrent)

    let semaphore = DispatchSemaphore(value: concurrentTasks)

    for i in 0 ... 1000 {
        queue1.async {
            Thread.sleep(forTimeInterval: 1)
            print("Executed Task \(i)")
            semaphore.signal()   
            // Sema Count Increased 
        }
        semaphore.wait() //Sema Count Decreased
    }

    // Async Task
    DispatchQueue.main.async {
        print("All Tasks Completed")
    }
    ```

## DEADLOCK
- What?
  - Deadlocks happens when two threads are waiting for each other to release a shared resource, ending up blocked for infinity.
  - "Do not call the dispatch_sync function from a task that is executing on the same queue that you pass to your function call. Doing so will deadlock the queue. If you need to dispatch to the current queue, do so asynchronously using the dispatch_async function." (https://developer.apple.com/library/archive/documentation/General/Conceptual/ConcurrencyProgrammingGuide/OperationQueues/OperationQueues.html#//apple_ref/doc/uid/TP40008091-CH102-SW28)
  - Accidentally calling sync against the current dispatch queue is the most common occurrence of this that you'll run into. (Book Concurrency - Swift)
  - Example code :
  ```swift
    func deadLock() {
        let myQueue = DispatchQueue(label: "deadLock")
        myQueue.async {
            myQueue.sync {
                print("Inner block called")
            }
            print("Outer block called")
        }	
    }
  ```
- Solutions:
  - "The asynchronous dispatching of tasks to a dispatch queue cannot deadlock the queue."  (https://developer.apple.com/library/archive/documentation/General/Conceptual/ConcurrencyProgrammingGuide/ConcurrencyandApplicationDesign/ConcurrencyandApplicationDesign.html#//apple_ref/doc/uid/TP40008091-CH100-SW8)
  - Example code: 
  ```swift
    let myQueue = DispatchQueue(label: "deadLockSolved")
        myQueue.async {
            myQueue.async {
                print("Inner block called")
            }
            print("Outer block called")
        }	  
  ```

## RACE CONDITION
- What?
  - Race condition happens when two or more threads access a shared data and change it’s value at the same time.
  - Read and write problem ()
  - Array, String, and Dictionary are not thread-safe by default.
  - When they’re modified, their reference is fully replaced with a new copy of the structure. However, because updating instance variables on Swift objects is not atomic, they are not thread-safe. Two threads can update a dictionary (for example by adding a value) at the same time, and both attempt to write at the same block of memory, which can cause memory corruption. (https://khanlou.com/2016/04/the-GCD-handbook/)
  - Example:
  ```swift
    let concurrentQueue = DispatchQueue(label: "Race condition", attributes: .concurrent)
        var number = 0
        var strings: [String:Int] = [:]
        concurrentQueue.async {
          for _ in 0...10 {
              number += 1
              strings["🔴 \(number)"] = number
              print("🔴: \(number)")
          }
      }
      concurrentQueue.async {
          for _ in 0...10 {
              number += 1
              strings["🔵 \(number)"] = number
              print("🔵: \(number)")
          }
      }

      DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
          print("Number = \(number)")
          for item in strings {
              print(item)
          }
      }
  ```
- Solution:
  - Make only one task changes data source at one time.
  - Solution 1: Serial Queue
    - Example code:
    ```swift
    let serialQueue = DispatchQueue(label: "Serial Queue")
        var number = 0
        var strings: [String:Int] = [:]
      serialQueue.async {
          for _ in 0...10 {
              number += 1
              strings["🔴 \(number)"] = number
              print("🔴: \(number)")
          }
      }
      serialQueue.async {
          for _ in 0...10 {
              number += 1
              strings["🔵 \(number)"] = number
              print("🔵: \(number)")
          }
      }

      DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
          print("Number = \(number)")
          for item in strings {
              print(item)
          }
      }
    ```
  - Solution 2: Synchronous
    - Example code:
    ```swift
    let concurrentQueue = DispatchQueue(label:  "Synchronous", attributes: .concurrent)
        var number = 0
        var strings: [String:Int] = [:]
        concurrentQueue.sync {
          for _ in 0...10 {
              number += 1
              strings["🔴 \(number)"] = number
              print("🔴: \(number)")
          }
      }
      concurrentQueue.sync {
          for _ in 0...10 {
              number += 1
              strings["🔵 \(number)"] = number
              print("🔵: \(number)")
          }
      }

      DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
          print("Number = \(number)")
          for item in strings {
              print(item)
          }
      }
    ```
  - Solution 3: Lock queue
  - Example code:
    ```swift
        let concurrentQueue = DispatchQueue(label: "Lock queue", attributes: .concurrent)
            let serialQueue = DispatchQueue(label: "Sersial Queue")
            var number = 0
            var strings: [String:Int] = [:]
            concurrentQueue.async {
                serialQueue.sync {
                for _ in 0...10 {
                    number += 1
                    strings["🔴 \(number)"] = number
                    print("🔴: \(number)")
                }
                }
        }
        concurrentQueue.async {
            serialQueue.sync {
            for _ in 0...10 {
                number += 1
                strings["🔵 \(number)"] = number
                print("🔵: \(number)")
            }
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            print("Number = \(number)")
            for item in strings {
                print(item)
            }
        }
    ```
  - Solution 4: Barrier (recommended by Apple)
    - Example code:
    ```swift
    let concurrentQueue = DispatchQueue(label: "Race codition", attributes: .concurrent)
            var number = 0
            var strings: [String:Int] = [:]
    concurrentQueue.async(flags: .barrier) {
            for _ in 0...10 {
                number += 1
                strings["🔴 \(number)"] = number
                print("🔴: \(number)")
            }
        }
    concurrentQueue.async(flags: .barrier) {
            for _ in 0...10 {
                number += 1
                strings["🔵 \(number)"] = number
                print("🔵: \(number)")
            }
        }
    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            print("Number = \(number)")
        for (item) in strings.enumerated() {
                print("\(item.offset): \(item)")
            }
        }


    var someDict:[Int:String] = [1:"One", 2:"Two", 3:"Three"]
    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {

            for item in someDict {
                print(item)
            }
        } 
    ```
    - User Thread Sanitizer to detect race condition
## READER AND WRITER PROBLEM
- What ?
  - The readers–writers problem occurs when multiple threads share a resource (variable or a data structure in memory), and some threads may write, some may read. When multiple threads read from the shared resource simultaneously nothing wrong can happen. But when one thread write — others must wait, otherwise ending up with corrupted data. (https://dmytro-anokhin.medium.com/concurrency-in-swift-reader-writer-lock-4f255ae73422)
  - https://dmytro-anokhin.medium.com/concurrency-in-swift-reader-writer-lock-4f255ae73422 
- Problem
- Solution:  Thread barrier
  ```swift
  class ThreadSafeCollection<Element> {
  
    // Concurrent synchronization queue
    private let queue = DispatchQueue(label: "ThreadSafeCollection.queue", attributes: .concurrent)
  
    private var _elements: [Element] = []
  
    var elements: [Element] {
        var result: [Element] = []
        
        queue.sync { // Read
            result = _elements
        }

        return result
    }
  
    func append(_ element: Element) {
        // Write with .barrier
        // This can be performed synchronously or asynchronously not to block calling thread.
        queue.async(flags: .barrier) {
            self._elements.append(element)
        }
      }
    }
  ```

  

## PRIORITY INVERSION
- What?
  - A high priority task is prevented from running by a lower priority task, effectively inverting their relative priorities
  - This situation often occurs when a high QoS queue shares a resources with a low QoS queue, and the low QoS queue gets a lock on that resource.(https://medium.com/flawless-app-stories/concurrency-visualized-part-3-pitfalls-and-conclusion-2b893e04b97d)
- Solution: GCD resolves priority inversion by temporarily raising the QoS of the entire queue that contains the low priority tasks which are ‘ahead’ of, or blocking, your high priority task.
- Example:
  ```swift
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

        backgroundQueue.async {
            output(color: .white, times: count)
        }

        backgroundQueue.async {
            output(color: .white, times: count)
        }

        utilityQueue.async {
            output(color: .blue, times: count)
        }

        utilityQueue.async {
            output(color: .blue, times: count)
        }

        // next statement goes here
    }
    //backgroundQueue.sync {}
  ```