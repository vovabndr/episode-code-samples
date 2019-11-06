import Combine
import ComposableArchitecture
import Counter
import FavoritePrimes
import SwiftUI

struct AppState {
  var count = 0
  var favoritePrimes: [Int] = []
  var lastSavedAt: Date?
  var loadError: String?
  var loggedInUser: User? = nil
  var activityFeed: [Activity] = []
  var isPrimeModalShown: Bool = false
  var alertNthPrime: PrimeAlert?
  var isNthPrimeButtonDisabled: Bool = false


  struct Activity {
    let timestamp: Date
    let type: ActivityType

    enum ActivityType {
      case addedFavoritePrime(Int)
      case removedFavoritePrime(Int)
    }
  }

  struct User {
    let id: Int
    let name: String
    let bio: String
  }
}

enum AppAction {
//  case counter(CounterAction)
//  case primeModal(PrimeModalAction)
  case counterView(CounterViewAction)
  case favoritePrimes(FavoritePrimesAction)

  var favoritePrimes: FavoritePrimesAction? {
    get {
      guard case let .favoritePrimes(value) = self else { return nil }
      return value
    }
    set {
      guard case .favoritePrimes = self, let newValue = newValue else { return }
      self = .favoritePrimes(newValue)
    }
  }

  var counterView: CounterViewAction? {
    get {
      guard case let .counterView(value) = self else { return nil }
      return value
    }
    set {
      guard case .counterView = self, let newValue = newValue else { return }
      self = .counterView(newValue)
    }
  }
}

extension AppState: CounterViewState {
  var primeModalState: (count: Int, favoritePrimes: [Int]) {
    get { (count, favoritePrimes) }
    set {
      count = newValue.count
      favoritePrimes = newValue.favoritePrimes
    }
  }

  var counterView: CounterViewState {
    get { self }
    set {
      self.count = newValue.count
      self.favoritePrimes = newValue.favoritePrimes
      self.isPrimeModalShown = newValue.isPrimeModalShown
      self.alertNthPrime = newValue.alertNthPrime
      self.isNthPrimeButtonDisabled = newValue.isNthPrimeButtonDisabled
    }
  }
}

extension AppState: FavoritePrimesState {
  var favoritePrimesView: FavoritePrimesState {
    get { self }
    set {
      self.favoritePrimes = newValue.favoritePrimes
      self.lastSavedAt = newValue.lastSavedAt
      self.loadError = newValue.loadError
    }
  }
}

let appReducer: Reducer<AppState, AppAction> = combine(
  pullback(counterViewReducer, value: \.counterView, action: \.counterView),
  pullback(favoritePrimesReducer, value: \.favoritePrimesView, action: \.favoritePrimes)
)

func activityFeed(
  _ reducer: @escaping Reducer<AppState, AppAction>
) -> Reducer<AppState, AppAction> {

  return { state, action in
    switch action {
    case .counterView(.counter),
         .favoritePrimes(.loadedFavoritePrimes):
      break
    case .counterView(.primeModal(.removeFavoritePrimeTapped)):
      state.activityFeed.append(.init(timestamp: Date(), type: .removedFavoritePrime(state.count)))

    case .counterView(.primeModal(.saveFavoritePrimeTapped)):
      state.activityFeed.append(.init(timestamp: Date(), type: .addedFavoritePrime(state.count)))

    case let .favoritePrimes(.deleteFavoritePrimes(indexSet)):
      for index in indexSet {
        state.activityFeed.append(.init(timestamp: Date(), type: .removedFavoritePrime(state.favoritePrimes[index])))
      }
    case .favoritePrimes(.loadButtonTapped):
      break
    case .favoritePrimes(.saveButtonTapped):
      break
    case .favoritePrimes(.lastSavedAt):
      break
    case .favoritePrimes(.showError(_)):
      break
    case .favoritePrimes(.hideError):
      break
    case .favoritePrimes(.fail):
      break
    }

    let effects = reducer(&state, action)
    return effects
  }
}

struct ContentView: View {
  @ObservedObject var store: Store<AppState, AppAction>

  var body: some View {
    NavigationView {
      List {
        NavigationLink(
          "Counter demo",
          destination: CounterView(
            store: self.store
              .view(
                value: { $0.counterView },
                action: { .counterView($0) }
            )
          )
        )
        NavigationLink(
          "Favorite primes",
          destination: FavoritePrimesView(
            store: self.store.view(
              value: { $0.favoritePrimesView },
              action: { .favoritePrimes($0) }
            )
          )
        )
      }
      .navigationBarTitle("State management")
    }
  }
}
