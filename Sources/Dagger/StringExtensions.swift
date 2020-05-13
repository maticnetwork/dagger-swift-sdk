import  Foundation

extension String {
    func join(src: Array<String>)-> String {
            var str = ""
            var i = 0
            let length = src.count
            while (i < length) {
                if (i > 0){
                    str = str+self
                }
                str+=src[i]
                i+=1
            }
            return str
    }

    func capitaliseFirstLetter(string: String)-> String {
        let first = String(string.prefix(1)).capitalized
        let other = String(string.dropFirst())
        return first + other
    }

    func lowercaseFirstLetter(string: String)-> String {
        let first = String(string.prefix(1)).lowercased()
        let other = String(string.dropFirst())
        return first + other
    }

    func zeros(n: Int)-> String {
        return "0".repeatCharacter(n: n)
    }

    func repeatCharacter(n: Int)-> String {
        var str = ""
        for _ in 1...n {
            str+=self
        }
        return str
    }

    func isEmpty(s: String?)-> Bool {
        return s == nil || s == ""
    }
    
    func index(from: Int) -> Index {
        return self.index(startIndex, offsetBy: from)
    }
    
    subscript (i: Int) -> String {
        return self[i ..< i + 1]
    }

    func substring(from: Int) -> String {
        let fromIndex = index(from: from)
        return String(self[fromIndex...])
    }

    func substring(to: Int) -> String {
        let toIndex = index(from: to)
        return String(self[..<toIndex])
    }

    func substring(with r: Range<Int>) -> String {
        let startIndex = index(from: r.lowerBound)
        let endIndex = index(from: r.upperBound)
        return String(self[startIndex..<endIndex])
    }
    
    subscript (bounds: CountableClosedRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start...end])
    }

    subscript (bounds: CountableRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start..<end])
    }
}
