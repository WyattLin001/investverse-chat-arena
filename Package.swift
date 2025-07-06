// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "InvestVerseApp",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "InvestVerseApp",
            targets: ["InvestVerseApp"]),
    ],
    dependencies: [
        .package(url: "https://github.com/supabase/supabase-swift.git", from: "2.0.0"),
        .package(url: "https://github.com/socketio/socket.io-client-swift.git", from: "16.0.0")
    ],
    targets: [
        .target(
            name: "InvestVerseApp",
            dependencies: [
                .product(name: "Supabase", package: "supabase-swift"),
                .product(name: "SocketIO", package: "socket.io-client-swift")
            ]
        )
    ]
)