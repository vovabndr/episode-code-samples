import ComposableArchitecture
import PrimeModal
import SwiftUI

public enum CounterAction {
  case decrTapped
  case incrTapped
  case getPrime
  case show(prime: Int?)
}

public func counterReducer(state: inout CounterViewState, action: CounterAction) -> [Effect<CounterAction>] {
  switch action {
  case .decrTapped:
    state.count -= 1
    return []

  case .incrTapped:
    state.count += 1
    return []

  case .getPrime:
    state.isNthPrimeButtonDisabled = true
    return [getNthPrime(number: state.count)]

  case let .show(prime: prime):
    state.alertNthPrime = prime.map(PrimeAlert.init(prime:))
    state.isNthPrimeButtonDisabled = false

    return []
  }
}

public let counterViewReducer = combine(
  pullback(counterReducer, value: \.self, action: \CounterViewAction.counter),
  pullback(primeModalReducer, value: \.primeModalState, action: \CounterViewAction.primeModal)
)

public struct PrimeAlert: Identifiable {
  let prime: Int
  public var id: Int { self.prime }
}

public protocol CounterViewState {
  var count: Int { get set }
  var favoritePrimes: [Int] { get set }
  var isPrimeModalShown: Bool { get set }
  var alertNthPrime: PrimeAlert? { get set }
  var isNthPrimeButtonDisabled: Bool { get set }
  var primeModalState: (count: Int, favoritePrimes: [Int]) { get set }
}

public enum CounterViewAction {
  case counter(CounterAction)
  case primeModal(PrimeModalAction)

  var counter: CounterAction? {
    get {
      guard case let .counter(value) = self else { return nil }
      return value
    }
    set {
      guard case .counter = self, let newValue = newValue else { return }
      self = .counter(newValue)
    }
  }

  var primeModal: PrimeModalAction? {
    get {
      guard case let .primeModal(value) = self else { return nil }
      return value
    }
    set {
      guard case .primeModal = self, let newValue = newValue else { return }
      self = .primeModal(newValue)
    }
  }
}

public struct CounterView: View {
  @ObservedObject var store: Store<CounterViewState, CounterViewAction>
  @State var isPrimeModalShown = false
  @State var alertNthPrime: PrimeAlert?
  @State var isNthPrimeButtonDisabled = false

  public init(store: Store<CounterViewState, CounterViewAction>) {
    self.store = store
  }

  public var body: some View {
    VStack {
      HStack {
        Button("-") { self.store.send(.counter(.decrTapped)) }
        Text("\(self.store.value.count)")
        Button("+") { self.store.send(.counter(.incrTapped)) }
      }
      Button("Is this prime?") { self.isPrimeModalShown = true }
      Button(
        "What is the \(ordinal(self.store.value.count)) prime?",
        action: { self.store.send(.counter(.getPrime)) }
      )
      .disabled(self.isNthPrimeButtonDisabled)
    }
    .font(.title)
    .navigationBarTitle("Counter demo")
    .sheet(isPresented: self.$isPrimeModalShown) {
      IsPrimeModalView(
        store: self.store
          .view(
            value: { ($0.count, $0.favoritePrimes) },
            action: { .primeModal($0) }
        )
      )
      }
    .onReceive(self.store.$value) {
      self.isPrimeModalShown = $0.isPrimeModalShown
      self.alertNthPrime = $0.alertNthPrime
      self.isNthPrimeButtonDisabled = $0.isNthPrimeButtonDisabled
    }
    .alert(item: self.$alertNthPrime) { alert in
      Alert(
        title: Text("The \(ordinal(self.store.value.count)) prime is \(alert.prime)"),
        dismissButton: .default(Text("Ok"))
      )
    }
  }
}

func ordinal(_ n: Int) -> String {
  let formatter = NumberFormatter()
  formatter.numberStyle = .ordinal
  return formatter.string(for: n) ?? ""
}
