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
  return {
    let data = try! JSONEncoder().encode(favoritePrimes)
    let documentsPath = NSSearchPathForDirectoriesInDomains(
      .documentDirectory, .userDomainMask, true
      )[0]
    let documentsUrl = URL(fileURLWithPath: documentsPath)
    let favoritePrimesUrl = documentsUrl
      .appendingPathComponent("favorite-primes.json")
    try! data.write(to: favoritePrimesUrl)
    return nil
  }
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
    else { return [{.showError("Nothing to load")}] }

  return [{ .loadedFavoritePrimes(favoritePrimes) }]
}

let saveDateEffect: Effect<FavoritePrimesAction> = {
  .lastSavedAt
}

let failLoadEffect: Effect<FavoritePrimesAction> = { .showError("Nothing to load") }
