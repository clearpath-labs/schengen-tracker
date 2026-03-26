import Foundation

struct SchengenCountry: Identifiable, Hashable, Codable {
    let name: String
    let flag: String

    var id: String { name }
    var display: String { "\(flag) \(name)" }
}

let schengenCountries: [SchengenCountry] = [
    SchengenCountry(name: "Austria", flag: "🇦🇹"),
    SchengenCountry(name: "Belgium", flag: "🇧🇪"),
    SchengenCountry(name: "Bulgaria", flag: "🇧🇬"),
    SchengenCountry(name: "Croatia", flag: "🇭🇷"),
    SchengenCountry(name: "Czech Republic", flag: "🇨🇿"),
    SchengenCountry(name: "Denmark", flag: "🇩🇰"),
    SchengenCountry(name: "Estonia", flag: "🇪🇪"),
    SchengenCountry(name: "Finland", flag: "🇫🇮"),
    SchengenCountry(name: "France", flag: "🇫🇷"),
    SchengenCountry(name: "Germany", flag: "🇩🇪"),
    SchengenCountry(name: "Greece", flag: "🇬🇷"),
    SchengenCountry(name: "Hungary", flag: "🇭🇺"),
    SchengenCountry(name: "Iceland", flag: "🇮🇸"),
    SchengenCountry(name: "Italy", flag: "🇮🇹"),
    SchengenCountry(name: "Latvia", flag: "🇱🇻"),
    SchengenCountry(name: "Liechtenstein", flag: "🇱🇮"),
    SchengenCountry(name: "Lithuania", flag: "🇱🇹"),
    SchengenCountry(name: "Luxembourg", flag: "🇱🇺"),
    SchengenCountry(name: "Malta", flag: "🇲🇹"),
    SchengenCountry(name: "Netherlands", flag: "🇳🇱"),
    SchengenCountry(name: "Norway", flag: "🇳🇴"),
    SchengenCountry(name: "Poland", flag: "🇵🇱"),
    SchengenCountry(name: "Portugal", flag: "🇵🇹"),
    SchengenCountry(name: "Romania", flag: "🇷🇴"),
    SchengenCountry(name: "Slovakia", flag: "🇸🇰"),
    SchengenCountry(name: "Slovenia", flag: "🇸🇮"),
    SchengenCountry(name: "Spain", flag: "🇪🇸"),
    SchengenCountry(name: "Sweden", flag: "🇸🇪"),
    SchengenCountry(name: "Switzerland", flag: "🇨🇭"),
]
