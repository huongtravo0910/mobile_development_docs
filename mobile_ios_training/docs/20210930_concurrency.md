
# CONCURRENCY

## Concurrency

### What?
- Concurrency means multiple computations are happening at the same time (https://web.mit.edu/6.005/www/fa14/classes/17-concurrency/)

### Why?
-  To support that your app runs as smoothly as possible and that the end user is not ever forced to wait for something to happen

### How?
- Grand Central Dispatch
  - simpler to work with for simple tasks
  - working with methods or chunks of code that need to be executed
- Operation
  - keep track of a job
  - maintain the ability to cancel it
  - working with objects that need to encapsulate data and functionality

* Operations is built on top of GCD

## Grand Central Dispatch (GCD)

### What?

- GCD is Apple's implementation of C's libdispatch library.
- Its purpose is to queue up tasks — either a method or a closure — that can be run in parallel, depending on availability of resources; it then executes the tasks on an available processor core.
- Each task that you submit to a queue is then executed against a pool of threads fully managed by the system.

### How?
- By Dispatch queues
  - DispatchQueue.init(label:, qos:, attributes:)
  -  By type of thread
       - DispatchQueue.main -> main queue for main thread
       - DispatchQueue.global(qos: .) -> background thread
  - Quality of service (define priority)
    - `.userInteractive` : r tasks that the user directly interacts with. UI, keep the UI responsive and fast
    - `.userInitiated` : when the user kicks off a task from the UI that needs to happen immediately, but can be done asynchronously
    - `.utility` : dispatch queue for tasks that would typically include a progress indicator such as long-running computations, I/O, networking or continuous data feeds
    - `.background` : for tasks that the user is not directly aware of
    - `.default and .unspecified` 
  - By type of queue
    - concurrent queue : DispatchQueue(attributes: .concurrent), DispatchQueue.global(qos: .), Dispatch.main
      - concurrent queue is able to utilize as many threads as the system has resources for.
    - serial queue : DispatchQueue() (no attribute)
      - serial queues only have a single thread associated with them and thus only allow a single task to be executed at any given time. 
- Using built-in method : It's not always necessary to grab a dispatch queue yourself. Many of the standard iOS libraries handle that for you.
- Semaphores
  - control how many threads have access to a shared resource
  - using a DispatchSemaphore
  ```swift
   let semaphore = DispatchSemaphore(value: 4)
  ```
- DispatchGroup
  - use when you want to track the completion of a group of tasks


## Concurrency Problems

### Race conditions
- multiple threads are trying to write to the same variable at the same time
- solution: 
   - use serial queue (single thread)
   - thread barrier

### Deadlock
- you are both waiting on another task that can never complete
- Reasons:
  - semaphores
  - other explicit locking mechanisms
  - accidentally calling sync against the current dispatch queue
- Solution: 
  - semaphores
    - ask for resources in the same order
  
### Priority inversion
- priority inversion occurs when a queue with a lower quality of service is given higher system priority than a queue with a higher quality of service, or QoS
- reasons: when a higher quality of service queue shares a resource with a lower quality of service queue.


## Operation
### What?
### How







