# Business Logic

## WHAT?
- Business logic: 
  * encodes the real-world business rules 
  * determine how data can be created, stored, and changed. 
  * prescribes how business objects interact with one another
(https://en.wikipedia.org/wiki/Business_logic)

- Business Logic Layer: 
  * A multitier architecture formalizes this decoupling by creating a business logic layer which is separate from other tiers or layers, such as the data access layer, presentation or service layer. 
  * The most widespread use of multitier architecture is the three-tier architecture: Presentation layer, Business Logic Layer and Data Layer.
  (demonstration: https://en.wikipedia.org/wiki/Multitier_architecture#/media/File:Overview_of_a_three-tier_application_vectorVersion.svg)
  * Business Logic Layer is a middle layer between Presentation layer and Data Layer
  * coordinate the application, process commands, make logical decision and evaluation, and performs calculation
  * move and process data between two surrounding layers

## WHERE?
- Business logic can be put in Model or ViewModel (MVC, MVVM). (Model : https://stackoverflow.com/questions/16338536/mvvm-viewmodel-and-business-logic-connection ,
https://decode.agency/mvvm-architecture-a-step-by-step-guide/
)

- As recommended by https://developer.android.com/jetpack/guide, business logic is included in a ViewModel in a MVVM architecture.
-  The ViewModel of MVVM is a value converter, meaning the ViewModel is responsible for exposing (converting) the data objects from the model in such a way that objects are easily managed and presented. (https://en.wikipedia.org/wiki/Model%E2%80%93view%E2%80%93viewmodel)
  
- A ViewModel object: (https://developer.android.com/jetpack/guide)
  * provides the data for a specific UI component
  * contains data-handling business logic to communicate with the model. 
  * For example, the ViewModel can call other components to load the data, and it can forward user requests to modify the data. 
  * th ViewModel doesn't know about UI components, so it isn't affected by configuration changes, such as recreating an activity when rotating the device.

## HOW?

1. Connect Business Logic Layer vs Data Layer
    - Use repository pattern 
    - Use API calls (processed in repository)
  ```swift
    import Swinject
    import UIKit

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


2. Connect Business Logic Layer vs Presentation Layer
   - Use ViewModel to provide the data for a specific UI component
  ```swift
  import UIKit
import Swinject

class MainViewController: UITableViewController{
    
    fileprivate let cellID = "cellID"
    fileprivate var todos:[Todo] = []
    private var container : Container!
    
    
    func setContainer(_ container : Container){
        self.container = container
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = .lightGray
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(handleAddTap))
        navigationItem.rightBarButtonItem?.tintColor = .systemPink
        let todoViewModel = container.resolve(TodoViewModel.self)
        todos = todoViewModel!.fetchedTodos
        self.tableView.reloadData()
        view.isUserInteractionEnabled = true
        addSubview()
        setupConstraint()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let todoViewModel = container.resolve(TodoViewModel.self)!
        todoViewModel.fetchTodo()
        todos = todoViewModel.fetchedTodos
        self.tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let todoViewModel = container.resolve(TodoViewModel.self)!
        todoViewModel.fetchTodo()
        todos = todoViewModel.fetchedTodos
        self.tableView.reloadData()
        
        self.userActivity = self.view.window?.windowScene?.userActivity
        
    }
    
    lazy var mainButton : UIButton = {
        let mainButton = UIButton()
        mainButton.translatesAutoresizingMaskIntoConstraints = false
        mainButton.addTarget(self, action: #selector(MainViewController.handleAddTap) , for: .touchUpInside)
        
        mainButton.setTitle("+", for: .normal)
        mainButton.setTitleColor(.white, for: .normal)
        
        mainButton.layer.cornerRadius = 75/2
        mainButton.layer.backgroundColor = UIColor.systemPink.cgColor
        mainButton.layer.borderColor = .init(red: 0.9686, green: 0, blue: 0.4353, alpha: 1)
        mainButton.layer.borderWidth = 1.0
        
        return mainButton
    }()
    
    func addSubview(){
        view.addSubview(mainButton)
    }
    
    
    private func setupConstraint(){
        
        let horizontalCenter = NSLayoutConstraint(item: mainButton, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerXWithinMargins, multiplier: 1.0, constant: 150)
        let verticalCenter = NSLayoutConstraint(item: mainButton, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerYWithinMargins, multiplier: 1.0, constant: 200)
        let height = NSLayoutConstraint(item: mainButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: 75)
        let width = NSLayoutConstraint(item: mainButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1.0, constant: 75)
        
        let constrains: [NSLayoutConstraint] = [verticalCenter, horizontalCenter , width, height]
        
        NSLayoutConstraint.activate(constrains)
        
    }
    
    
    
    
    @objc func handleAddTap(){
        //UserDefaults.standard.removeObject(forKey: "myKey")
        let alert = UIAlertController(title: "Add Todo", message: nil, preferredStyle: .alert)
        alert.addTextField{(textField) in
            textField.placeholder = "Enter a todo"
        }
        
        alert.addAction(UIAlertAction(title: "Add note", style: .default, handler: {(act) in
            guard let textField = alert.textFields?.first else {return}
            guard let text = textField.text else {return}
            guard text != "" else {return}
            self.todos.append(Todo(todo: text, date: Date()))
            self.tableView.beginUpdates()
            let indexPath = IndexPath(row: self.todos.count - 1 , section: 0)
            self.tableView.insertRows(at: [indexPath], with: .automatic)
            self.tableView.endUpdates()
            let todoViewModel = self.container.resolve(TodoViewModel.self)!
            todoViewModel.saveTodos(todos: self.todos)
            todoViewModel.fetchTodo()
            self.todos = todoViewModel.fetchedTodos
            self.tableView.reloadData()
            
            
        }))
        alert.view.tintColor = .systemPink
        present(alert, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (section  == 0 ) {
            return todos.count
        }
        return 0
    }
    
    func resetDefaults() {
        let defaults = UserDefaults.standard
        let dictionary = defaults.dictionaryRepresentation()
        dictionary.keys.forEach { key in
            defaults.removeObject(forKey: key)
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellID)
        cell.textLabel?.text = todos[indexPath.row].todo
        cell.detailTextLabel?.text = Utils().formatData(date: todos[indexPath.row].date, format: "hh:mm:ss")
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = DetailViewController()
        vc.setContainer(container)
        container.register(TodoViewModel.self) { r in  let todoViewModel = TodoViewModel(self.container)
            todoViewModel.fetchTodo()
            todoViewModel.currentTodo = Todo(todo:self.todos[indexPath.row].todo, date: self.todos[indexPath.row].date)
            return todoViewModel }
        //        vc.todo = Todo(todo:todos[indexPath.row].todo, date: todos[indexPath.row].date)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let todoViewModel = self.container.resolve(TodoViewModel.self)!
        todoViewModel.currentTodo = Todo(todo:self.todos[indexPath.row].todo, date: self.todos[indexPath.row].date)
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") {
            (action, view, completionHandler) in
            todoViewModel.deleteTodo(todo: todoViewModel.currentTodo)
            todoViewModel.fetchTodo()
            self.todos = todoViewModel.fetchedTodos
            self.tableView.reloadData()
        }
        deleteAction.backgroundColor = .gray
        let editAction = UIContextualAction(style: .destructive, title: "Edit") {
            (action, view, completionHandler) in
            let editScreen = self.container.resolve(TodoEditScreenViewController.self)!
            self.present(editScreen, animated: true, completion: nil)
        }
        editAction.backgroundColor = .systemPink
        return UISwipeActionsConfiguration(actions: [deleteAction, editAction])
    }
    
}


  ```


