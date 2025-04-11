struct GameModel {
    let playersCount: Int
    let spyCount: Int
    let time: Int
    var commonWord: String
    var spyIndexes: Set<Int>
    var currentPlayerIndex: Int
}
