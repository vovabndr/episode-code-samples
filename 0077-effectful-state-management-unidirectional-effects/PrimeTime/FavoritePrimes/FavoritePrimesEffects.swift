//
//  FavoritePrimesEffects.swift
//  FavoritePrimes
//
//  Created by Volodymyr Bondar on 06.11.2019.
//  Copyright © 2019 Point-Free. All rights reserved.
//

import Foundation
import ComposableArchitecture


func saveEffect(favoritePrimes: [Int]) -> Effect<FavoritePrimesAction> {
  let data = try! JSONEncoder().encode(favoritePrimes)
  let documentsPath = NSSearchPathForDirectoriesInDomains(
    .documentDirectory, .userDomainMask, true
    )[0]
  let documentsUrl = URL(fileURLWithPath: documentsPath)
  let favoritePrimesUrl = documentsUrl
    .appendingPathComponent("favorite-primes.json")
  try! data.write(to: favoritePrimesUrl)
  return syncEffect(nil)
}

func loadEffect() -> [Effect<FavoritePrimesAction>] {
  let documentsPath = NSSearchPathForDirectoriesInDomains(
    .documentDirectory, .userDomainMask, true
    )[0]
  let documentsUrl = URL(fileURLWithPath: documentsPath)
  let favoritePrimesUrl = documentsUrl
    .appendingPathComponent("favorite-primes.json")
  guard
    let data = try? Data(contentsOf: favoritePrimesUrl),
    let favoritePrimes = try? JSONDecoder().decode([Int].self, from: data)
    else { return syncEffect(.showError("Nothing to load")) }

  return syncEffect(.loadedFavoritePrimes(favoritePrimes))
}

let saveDateEffect: Effect<FavoritePrimesAction> = { cb in
  cb(.lastSavedAt)
}

let failLoadEffect: Effect<FavoritePrimesAction> = { cb in
  cb(.showError("Nothing to load"))
}
