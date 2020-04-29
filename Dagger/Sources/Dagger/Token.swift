import Foundation

class Token{
    var type: TokenType
    var name: String
    var piece: String
    var last : String
    
    init(type: TokenType = TokenType.SINGLE, name: String = "", piece: String = "", last: String = "") {
        self.type = type
        self.name = name
        self.piece = piece
        self.last = last
    }
}

enum TokenType {
      case SINGLE
      case MULTI
      case RAW
}
