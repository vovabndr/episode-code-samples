//
//  CounterEffect.swift
//  Counter
//
//  Created by Volodymyr Bondar on 06.11.2019.
//  Copyright © 2019 Point-Free. All rights reserved.
//

import Foundation
import ComposableArchitecture

func getNthPrime(number: Int) -> Effect<CounterAction> {
  return { cb in
    nthPrime(number) { prime in
      DispatchQueue.main.async {
        cb(.show(prime: prime))
      }
    }
  }
}
