import UIKit

struct GameModel {
    let playersCount: Int
    let spyCount: Int
    let time: Int
    var commonWord: String
    var spyIndexes: Set<Int>
    var currentPlayerIndex: Int
}
enum GameAccessKey: String {
    case playedGamesCount
    case fullVersionUnlocked
}

extension UserDefaults {
    func incrementPlayedGames() {
        let key = GameAccessKey.playedGamesCount.rawValue
        let count = integer(forKey: key)
        set(count + 1, forKey: key)
    }
    func playedGamesCount() -> Int {
        integer(forKey: GameAccessKey.playedGamesCount.rawValue)
    }
    func isFullVersionUnlocked() -> Bool {
        bool(forKey: GameAccessKey.fullVersionUnlocked.rawValue)
    }
    func unlockFullVersion() {
        set(true, forKey: GameAccessKey.fullVersionUnlocked.rawValue)
    }
}
