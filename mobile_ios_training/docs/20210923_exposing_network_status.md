# EXPOSING NETWORK STATUS
It's common to load data from the network while showing the disk copy of that data, it's good to create a helper class that you can reuse in multiple places. (https://developer.android.com/jetpack/guide)



## Loading states
(https://www.swiftbysundell.com/articles/handling-loading-states-in-swiftui/)
- There are 4 main states of a loading:
  * idle : initial and last state
  * loading
  * loaded / success
  * failed
- Steps:
  * (1) Create a generic loading status enum
  * (2) In viewModel / state of a model that integrate with repository: embed the loading state
  * (3) Render to View
  
For example: 
- (1)
``` swift
enum LoadingState<Value> {
    case idle
    case loading
    case failed(Error)
    case loaded(Value)
}
```

- (2)
```swift
 class PublishedViewModel<Wrapped: Publisher>: LoadableObject {
    @Published private(set) var state = LoadingState<Wrapped.Output>.idle

    private let publisher: Wrapped
    private var cancellable: AnyCancellable?

    init(publisher: Wrapped) {
        self.publisher = publisher
    }

    func load() {
        state = .loading

        cancellable = publisher
            .map(LoadingState.loaded)
            .catch { error in
                Just(LoadingState.failed(error))
            }
            .sink { [weak self] state in
                self?.state = state
            }
    }
}
```

- (3)
```swift
struct AsyncContentView<Source: LoadableObject, Content: View>: View {
    @ObservedObject var source: Source
    var content: (Source.Output) -> Content

    var body: some View {
        switch source.state {
        case .idle:
            Color.clear.onAppear(perform: source.load)
        case .loading:
            ProgressView()
        case .failed(let error):
            ErrorView(error: error, retryHandler: source.load)
        case .loaded(let output):
            content(output)
        }
    }
}
```

## Network status (NetworkService)
For Http API, use URL
```swift
import Foundation
enum AppError: Error, Equatable {
    case badURL(description: String)
    case parsing(description: String)
    case network(description: String)
    
    var description: String{
        switch self {
        case .badURL(let value):
            return value
        case .parsing(let value):
            return value
        case .network(let value):
            return value
        }
    }
}

```
  
```swift 
import Resolver

// MARK: - NetworkServiceProtocol
protocol NetworkServiceProtocol {
    func fetch(
        with urlRequest: URLRequest,
        completion: @escaping (Result<Data, AppError>) -> Void
    )
}

// MARK: - NetworkService

class NetworkService: NetworkServiceProtocol {
    func fetch(with urlRequest: URLRequest, completion: @escaping (Result<Data, AppError>) -> Void) {
        guard urlRequest.httpMethod == "GET" else {
            completion(.failure(AppError.network(description: "Something went wrong! Please try again later.")))
            return
        }
        
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            guard
                error == nil,
                let dataContainer = data
            else {
                completion(.failure(AppError.network(description: "Something went wrong! Please try again later.")))
                return
            }
            guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
                print("Server error!")
                return
            }
            
            
            completion(.success(dataContainer))
        }
        .resume()
    }
}
```
