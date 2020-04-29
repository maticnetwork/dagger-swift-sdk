import Foundation

public class MqttRegex{
    
    var topic: String
    var rawTopic: String
    var regexp: NSRegularExpression
    
    init(t : String) {
        self.topic = t.lowercased()
        let tokens : Array<String> = MqttRegex.tokanize(topicArg : self.topic)
        self.rawTopic = topic
        var tokenObjects = Array<Token>()
        for index in 0..<tokens.count {
            tokenObjects.append(try! MqttRegex.processToken(token: tokens[index], index: index, tokens: tokens))
        }
        self.regexp = MqttRegex.makeRegex(tokens: tokenObjects)
    }
    
    static func tokanize(topicArg: String)-> Array<String> {
        var topic = topicArg
        topic = topic.lowercased()
        var tokens = topic.components(separatedBy: "/")
        if (tokens.count >= 4 && tokens[0].contains(":log")) {
            for i in 4...tokens.count {
                if (tokens[i] != "+" && tokens[i] != "#") {
                    tokens[i] = Numeric.toStringPadded(input : tokens[i], length : 64)
                }
            }
        }
        return tokens
    }

    static func makeRegex(tokens: Array<Token?>) -> NSRegularExpression {
        let lastToken = tokens[tokens.count - 1]
        var result = Array<String>()
        for index in 0..<tokens.count {
            let token = tokens[index]
            let isLast = index == tokens.count - 1
            let beforeMulti = index == tokens.count - 2
                && lastToken?.type == TokenType.MULTI
            if isLast || beforeMulti{
                result.append(token!.last)
            }  else {
                result.append(token!.piece)
            }
        }
        let pattern = "^"+"".join(src : result)+"$"
        return try! NSRegularExpression(pattern: pattern)
    }


    static func processToken(token: String?, index: Int, tokens: Array<String>)throws -> Token {
        let last = index == tokens.count - 1
        if (token == nil || "" == token?.trimmingCharacters(in: .whitespacesAndNewlines)) {
            throw DaggerError(message: "Topic must not be empty in pattern path.")
        }
        let cleanToken = token?.trimmingCharacters(in: .whitespacesAndNewlines)
        if (cleanToken?[0] == "+") {
            return Token(type: TokenType.SINGLE, name: "", piece: "([^/#+]+/)", last: "([^/#+]+/?)")
        } else if (cleanToken?[0] == "#") {
            if (!last) {
                throw DaggerError(message: "# wildcard must be at the end of the pattern")
            }
            return Token(type: TokenType.MULTI, name: "#", piece: "((?:[^/#+]+/)*)", last: "((?:[^/#+]+/?)*)")
        }
        return Token(type: TokenType.RAW, name: cleanToken!, piece: cleanToken!+"/",
                     last: cleanToken!+"/?")
    }
    
    func matches(rawTopic: String)-> Bool {
        var topic = rawTopic.lowercased()
        return regexp.firstMatch(in: topic, range: NSRange(location: 0, length: topic.utf16.count)) != nil
    }
}
