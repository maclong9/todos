// swift-tools-version:6.0
import PackageDescription

let package = Package(
  name: "SwiftTodos",
  platforms: [.macOS(.v14)],
  dependencies: [
    .package(
      url: "https://github.com/apple/swift-argument-parser.git", from: "1.4.0"),
    .package(
      url: "https://github.com/hummingbird-project/hummingbird.git",
      from: "2.3.0"),
    .package(
      url: "https://github.com/hummingbird-project/hummingbird-auth.git",
      from: "2.0.0-rc.5"),
    .package(
      url: "https://github.com/hummingbird-project/hummingbird-compression.git",
      from: "2.0.0-rc"),
    .package(
      url: "https://github.com/hummingbird-project/hummingbird-fluent.git",
      from: "2.0.0-beta.2"),
    .package(url: "https://github.com/vapor/fluent-kit.git", from: "1.48.5"),
    .package(
      url: "https://github.com/vapor/fluent-sqlite-driver.git", from: "4.7.0"),
  ],
  targets: [
    .executableTarget(
      name: "App",
      dependencies: [
        .product(name: "ArgumentParser", package: "swift-argument-parser"),
        .product(name: "Bcrypt", package: "hummingbird-auth"),
        .product(name: "FluentKit", package: "fluent-kit"),
        .product(name: "FluentSQLiteDriver", package: "fluent-sqlite-driver"),
        .product(name: "Hummingbird", package: "hummingbird"),
        .product(name: "HummingbirdAuth", package: "hummingbird-auth"),
        .product(name: "HummingbirdBasicAuth", package: "hummingbird-auth"),
        .product(
          name: "HummingbirdCompression", package: "hummingbird-compression"),
        .product(name: "HummingbirdFluent", package: "hummingbird-fluent"),
      ],
      swiftSettings: [
        .unsafeFlags(
          ["-cross-module-optimization"], .when(configuration: .release))
      ]
    ),
    .testTarget(
      name: "AppTests",
      dependencies: [
        .byName(name: "App"),
        .product(name: "HummingbirdAuthTesting", package: "hummingbird-auth"),
        .product(name: "HummingbirdTesting", package: "hummingbird"),
      ]
    ),
  ]
)
