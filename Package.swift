// Add this to your dependencies
.package(url: "https://github.com/aws-amplify/aws-sdk-ios-spm", from: "2.33.0"),

// And add "AWSIAM" to your target dependencies
.target(
    name: "Instancify",
    dependencies: [
        .product(name: "AWSIAM", package: "aws-sdk-ios-spm"),
        .product(name: "AWSSTS", package: "aws-sdk-ios-spm"),
        // ... other dependencies
    ]
) 