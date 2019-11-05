import ComposableArchitecture
import SwiftUI

public enum FavoritePrimesAction {
  case deleteFavoritePrimes(IndexSet)
  case loadButtonTapped
  case loadedFavoritePrimes([Int])
  case saveButtonTapped
  case lastSavedAt
  case showError(String)
  case hideError
  case fail
}

public protocol FavoritePrimesState {
  var favoritePrimes: [Int] { get set }
  var lastSavedAt: Date? { get set }
  var loadError: String? { get set }
}

public func favoritePrimesReducer(state: inout FavoritePrimesState, action: FavoritePrimesAction) -> [Effect<FavoritePrimesAction>] {
  switch action {
  case let .deleteFavoritePrimes(indexSet):
    for index in indexSet {
      state.favoritePrimes.remove(at: index)
    }
    return []

  case let .loadedFavoritePrimes(favoritePrimes):
    state.favoritePrimes = favoritePrimes
    return []

  case .saveButtonTapped:
    return [saveEffect(favoritePrimes: state.favoritePrimes), saveDateEffect]

  case .loadButtonTapped:
    return loadEffect()

  case .showError(let message):
    state.loadError = message
    return []

  case .hideError:
    state.loadError = nil
    return []

  case .lastSavedAt:
    state.lastSavedAt = Date()
    return []

  case .fail:
    return [failLoadEffect]
  }
}

public struct FavoritePrimesView: View {
  @ObservedObject var store: Store<FavoritePrimesState, FavoritePrimesAction>
  @State var errorMessageShown: Bool = false

  public init(store: Store<FavoritePrimesState, FavoritePrimesAction>) {
    self.store = store
  }

  public var body: some View {
    List {
      ForEach(self.store.value.favoritePrimes, id: \.self) { (prime: Int) in
        Text("\(prime)")
      }
      .onDelete { indexSet in
        self.store.send(.deleteFavoritePrimes(indexSet))
      }
    }
    .alert(isPresented: self.$errorMessageShown) {
      Alert(
        title: Text(self.store.value.loadError ?? "unknown"),
        dismissButton: .default(
          Text("ok"),
          action: { self.store.send(.hideError) }
        )
      )
    }
    .navigationBarTitle("Favorite primes")
    .onReceive(self.store.$value.map(\.loadError)) { errorMessage in
      self.errorMessageShown = errorMessage != nil
    }
    .navigationBarItems(
      trailing:
        HStack {
          if self.store.value.lastSavedAt != nil {
            Text("Last saved at:  \(self.store.value.lastSavedAt!.timeIntervalSince1970.rounded().description)")
          }
          Button("Save") { self.store.send(.saveButtonTapped) }
          Button("Load") { self.store.send(.loadButtonTapped) }
          Button("Fail") { self.store.send(.fail) }
        }
    )
  }
}

