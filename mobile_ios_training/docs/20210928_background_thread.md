# SWIFT BACKGROUND THREAD

## WHAT?
- A thread is a subprocess of your app that can execute even while other subprocesses are also executing.
- The main thread is the interface thread
- There is only one main thread; other threads are background threads.

## WHY
There are two kinds of situation in which your code will need to be explicitly aware of background threads:
- Your code is called back, but not on the main thread
- Your code takes significant time

## HOW
- (1) Callback in main thread use `DispatchQueue.main`
- (2) Callback in background thread use `DispatchQueue.global()` 

Example for (1)
```swift
DispatchQueue.main.async {
    self.tableView.reloadData()
}
```


Example for (2)
```swift
DispatchQueue.global(qos: .userInitiated).async {
    if let url = URL(string: urlString) {
        if let data = try? Data(contentsOf: url) {
            self.parse(json: data)
            return
        }
    }

    self.showError()
}
```
