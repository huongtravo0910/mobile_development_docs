# OPERATIONS

## WHAT
- Operations are fully-functional classes that can be submitted to an OperationQueue, just like you'd submit a closure of work to a DispatchQueue for GCD.
- State of operations:
  - isReady
  - isExecuting
  - isCancelled
  - isFinished
- Bonus features:
  -  reporting the state of the task
  -  wrapping tasks into an operation 
  -  specifying dependencies between various tasks
  -  cancelling the task
- Unlike GCD, an operation is run synchronously by default

## WHY
- Encapsulate data and functionality
- Reusability : 
  - an Operation is an actual Swift object, meaning you can pass inputs to set up the task, implement helper methods, etc
  - can wrap up a unit of work, or task, and execute it sometime in the future, and then easily submit that unit of work more than once.

## HOW
- (1) BlockOperation : 
  - BlockOperation subclasses Operation
  - for simple tasks
  - manages the concurrent execution of one or more closures on the default global queue
  - take advantage of all the other features of an operation
<br> Example for (1)

    ```swift
    let sentence = "Ray's courses are the best!"
    let wordOperation = BlockOperation()
    for word in sentence.split(separator: " ") {
    wordOperation.addExecutionBlock {
        print(word)
        sleep(2)
    }
    }
    wordOperation.completionBlock = {
        print("The execution has finished!")
    }
    logDuration{
        wordOperation.start()
    }
    ```

- (2) Operation subclass
    ```swift
    final class TiltShiftOperation: Operation {
    var outputImage: UIImage?
    private let inputImage: UIImage
    init(image: UIImage) {
        inputImage = image
        super.init()
    }
    }


    let op = TiltShiftOperation(image: image)
    op.start()
    cell.display(image: op.outputImage)
    ```
- (3) OperationQueue
    - OperationQueue class is what you use to manage the scheduling of an Operation and the maximum number of operations that can run simultaneously.
    - Add work: 
      - Pass an Operation.
      - Pass a closure.
      - Pass an array of Operations.
    - Waiting for completion : waitUntilAllOperationsAreFinished()
    - Quality of service : default is .background, if want to change -> override property
    - Pausing the queue : isSuspended = false
    - Maximum number of operations
      - if maxConcurrentOperationCount = 1 -> serial queue
    - concurrency benefits of operations
<br> Example for (3)

    ```swift
    private let queue = OperationQueue()
    let op = TiltShiftOperation(image: image)
    op.completionBlock = {
    DispatchQueue.main.async {
        guard let cell = tableView.cellForRow(at: indexPath)
        as? PhotoCell else { return }
        cell.isLoading = false
        cell.display(image: op.outputImage)
    }
    }
    queue.addOperation(op)
    ```

- (4) Asynchronous Operations
  
- (5) Add Dependencies
  ```swift
  let networkOp = NetworkImageOperation()
  let decryptOp = DecryptOperation()
  let tiltShiftOp = TiltShiftOperation()
  decryptOp.addDependency(op: networkOp)
  tiltShiftOp.addDependency(op: decryptOp)
  ```
- (6) Canceling Operations  