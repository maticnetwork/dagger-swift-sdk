import Foundation


class Numeric {
    
    private static let HEX_PREFIX :String = "0x";

    public static func toStringPadded(input : String, length : Int) -> String {
        let cleanInput = cleanHexPrefix(input : input);
        if (cleanInput.count > length) {
            return prependHexPrefix(input : cleanInput);
        }

        var builder = ""
        builder.append("0".repeatCharacter(n: length - cleanInput.count));
        builder.append(cleanInput);

        return prependHexPrefix(input : builder);
    }
    
    public static func cleanHexPrefix(input : String)-> String {
        if (containsHexPrefix(input : input)) {
            return input.substring(from : 2);
        } else {
            return input;
        }
    }
    
    public static func prependHexPrefix(input : String) -> String {
        if (!containsHexPrefix(input : input)) {
            return HEX_PREFIX + input;
        } else {
            return input;
        }
    }
    
    public static func containsHexPrefix(input : String)-> Bool {
        return input != ""
                && input.count > 1
                && input[0] == "0"
                && input[1] == "x";
    }
    
    
}
