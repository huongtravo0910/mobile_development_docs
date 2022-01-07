# Repository pattern
  
1. WHAT?
- Design pattern
- Encapsulate the data logic required to access data sources
- Centralize data access functionality
- Map between the data storage object and domain objects

2. WHY?
- Decouple business logic and data logic by separating concerns of where / how data is stored away from the rest of your app
- Code is easier to change if switch data source or data structure
  #### For example:
  - Change API (local -> remote, remote <-> remote) 
  - Change returned format type
  - https://jsonplaceholder.typicode.com/users/1 vs https://randomuser.me/api/
- Makes code more testable by allowing us to inject as a dependency a mock repository

1. HOW?
- (1) Use a RepositoryProtocol, centralizing data access functionality
- (2) Create repositories that inheriting the protocol, mapping data objects to domain objects if needed
- (3) Use repo in the app without caring how data is stored or how to get data, just care about domain objects
- (4) Use mock repository to test app logic, be independent with data source
#### Example for (1):
```swift
protocol TodoRepositoryProtocol {
    func fetch(completion: @escaping ([Todo]?) -> Void)
    func delete(todo: Todo)
    func save(todos: [Todo])
    func update(oldTodo: Todo, newTodo: Todo)
}
```

#### Example for (2)
```swift
struct TodoUserDefaultRepository: TodoRepositoryProtocol {
    func delete(todo: Todo) {
        guard var savedTodos = UserDefaults.standard.object(forKey: "todo") as? [String] else {return}
        guard var savedDates = UserDefaults.standard.object(forKey: "date") as? [Date] else {return}
        savedTodos.removeAll { value in
            return value == todo.todo
        }
        savedDates.removeAll { value in
            return value == todo.date
        }
        
        UserDefaults.standard.set(savedTodos, forKey: "todo")
        UserDefaults.standard.set(savedDates, forKey: "date")
    }
    
    func save(todos: [Todo]) {
        var todosTobeSaved:[String] = []
        var datesTobeSaved:[Date] = []
        for todo in todos {
            todosTobeSaved.append(todo.todo)
            datesTobeSaved.append(todo.date)
        }
        
        UserDefaults.standard.set(todosTobeSaved, forKey: "todo")
        UserDefaults.standard.set(datesTobeSaved, forKey: "date")
    }
    
    func update(oldTodo: Todo, newTodo: Todo) {
        guard var savedTodos = UserDefaults.standard.object(forKey: "todo") as? [String] else {return}
        guard var savedDates = UserDefaults.standard.object(forKey: "date") as? [Date] else {return}
                
        if let row = savedTodos.firstIndex(where: {$0 == oldTodo.todo}) {
            savedTodos[row] = newTodo.todo
            print(savedTodos[row],"savedTodos[row]")
        }
        
        if let row = savedDates.firstIndex(where: {$0 == oldTodo.date}) {
            savedDates[row] = newTodo.date
            print(savedDates[row], "savedDates[row]")
        }        
        UserDefaults.standard.set(savedTodos, forKey: "todo")
        UserDefaults.standard.set(savedDates, forKey: "date")
    }
    
    
    
    func fetch(completion: @escaping ([Todo]?) -> Void){
        var todos: [Todo] = []
        guard let savedTodos = UserDefaults.standard.object(forKey: "todo") as? [String] else {return}
        guard let savedDates = UserDefaults.standard.object(forKey: "date") as? [Date] else {return}
        for i in 1...savedTodos.count {
            todos.append(Todo(todo: savedTodos[i-1], date: savedDates[i-1]))
        }
        completion(todos)
    }
}

```

#### Example for (3):

```swift
class TodoViewModel {
    var fetchedTodos : [Todo] = []
    var currentTodo: Todo!
    var isDelete: Bool = false
    let container: Container
    
    init(_ container: Container){
        self.container = container
        fetchTodo()
    }
    
    func fetchTodo(){
        let todoRepo = container.resolve(TodoRepositoryProtocol.self)!
        todoRepo.fetch{todos in
            self.fetchedTodos = todos!
        }
    }
    
    func saveTodos(todos: [Todo]){
        let todoRepo = container.resolve(TodoRepositoryProtocol.self)!
        todoRepo.save(todos: todos)
        self.fetchedTodos = todos
    }
    
    func deleteTodo(todo: Todo){
        let todoRepo = container.resolve(TodoRepositoryProtocol.self)!
        todoRepo.delete(todo: todo)
        self.fetchedTodos.removeAll { value in
            return value == todo
        }
    }
    
    func editTodo(oldTodo: Todo, newTodo: Todo){
        let todoRepo = container.resolve(TodoRepositoryProtocol.self)!
        todoRepo.update(oldTodo: oldTodo, newTodo: newTodo)
        if let index = self.fetchedTodos.firstIndex(where: {$0 == oldTodo}) {
            self.fetchedTodos[index] = newTodo
        }
    }
}
```

#### Example for (4)
```swift
class MockTodoUserDefaultRepository: TodoRepositoryProtocol {
    let someDateTime = MockTime().mockTime
    func fetch(completion: @escaping ([Todo]?) -> Void) {
        var todos: [Todo] = []
        let mockTodo = Todo(todo: "Mock Todo", date: someDateTime)
        todos.append(mockTodo)
        completion(todos)
    }
    
    func delete(todo: Todo) {
        
    }
    
    func save(todos: [Todo]) {
        
    }
    
    func update(oldTodo: Todo, newTodo: Todo) {
        
    }
}
```

```swift
class Todo_AppTests: XCTestCase {
    
    let container = Container()

    override func setUp() {
        let container = Container()
        container.register(TodoRepositoryProtocol.self) { _ in MockTodoUserDefaultRepository.init() }
        container.register(TodoViewModel.self) { r in  let todoViewModel = TodoViewModel(container)
            return todoViewModel }
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
    }
    
    func testDefaultTodo() throws {
        let todoViewModel = container.resolve(TodoViewModel.self)
        let todo = todoViewModel?.fetchedTodos
        XCTAssertEqual(todo, nil)
    }

    func testAddTodo() throws {
        let someDateTime = MockTime().mockTime
        let mockTodo = Todo(todo: "Mock Todo", date: someDateTime)
        container.register(TodoRepositoryProtocol.self) { _ in MockTodoUserDefaultRepository.init() }
        container.register(TodoViewModel.self) { r in  let todoViewModel = TodoViewModel(self.container)
            todoViewModel.fetchedTodos = []
            todoViewModel.saveTodos(todos: [mockTodo])
            todoViewModel.fetchTodo()
            return todoViewModel }
        let todoViewModel = container.resolve(TodoViewModel.self)
        let todo = todoViewModel?.fetchedTodos
        XCTAssertEqual(todo, [mockTodo])
    }
    
    func testGetTodos() throws {
        container.register(TodoRepositoryProtocol.self) { _ in MockTodoUserDefaultRepository.init() }
        container.register(TodoViewModel.self) { r in  let todoViewModel = TodoViewModel(self.container)
            todoViewModel.fetchedTodos = []
            todoViewModel.fetchTodo()
            return todoViewModel }
        let todoViewModel = container.resolve(TodoViewModel.self)
        let todo = todoViewModel?.fetchedTodos
        let someDateTime = MockTime().mockTime
        let mockTodo = Todo(todo: "Mock Todo", date: someDateTime)
        XCTAssertEqual(todo, [mockTodo])
        
    }
    
    func testDeleteTodo() throws {
        let someDateTime = MockTime().mockTime
        let mockTodo1 = Todo(todo: "Mock Todo 1", date: someDateTime)
        let mockTodo2 = Todo(todo: "Mock Todo 2", date: someDateTime)
        container.register(TodoRepositoryProtocol.self) { _ in MockTodoUserDefaultRepository.init() }
        container.register(TodoViewModel.self) { r in  let todoViewModel = TodoViewModel(self.container)
            todoViewModel.fetchedTodos = [mockTodo1, mockTodo2]
            todoViewModel.deleteTodo(todo: mockTodo1)
            return todoViewModel }
        let todoViewModel = container.resolve(TodoViewModel.self)
        let todo = todoViewModel?.fetchedTodos
        XCTAssertEqual(todo, [mockTodo2])
    }
    
    func testEditTodo() throws {
        let someDateTime = MockTime().mockTime
        let mockTodo1 = Todo(todo: "Mock Todo 1", date: someDateTime)
        let mockTodo2 = Todo(todo: "Mock Todo 2", date: someDateTime)
        let editedMockTodo3 = Todo(todo: "Edited Mock Todo 3", date: someDateTime)
        container.register(TodoRepositoryProtocol.self) { _ in MockTodoUserDefaultRepository.init() }
        container.register(TodoViewModel.self) { r in  let todoViewModel = TodoViewModel(self.container)
            todoViewModel.fetchedTodos = [mockTodo1, mockTodo2]
            todoViewModel.editTodo(oldTodo: mockTodo2, newTodo: editedMockTodo3 )
            return todoViewModel }
        let todoViewModel = container.resolve(TodoViewModel.self)
        let todo = todoViewModel?.fetchedTodos
        XCTAssertEqual(todo, [mockTodo1, editedMockTodo3])
    }
}
```

![alt text](https://en.wikipedia.org/wiki/Business_logic#/media/File:Overview_of_a_three-tier_application_vectorVersion.svg)

<img src="[./2/to/img.jpg](https://en.wikipedia.org/wiki/Business_logic#/media/File:Overview_of_a_three-tier_application_vectorVersion.svg)" alt="Getting started" />