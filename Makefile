build:
	xcodebuild -scheme FioriARKit -destination 'generic/platform=iOS' -sdk iphoneos CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO ONLY_ACTIVE_ARCH=NO clean build
jazzy:
	sourcekitten doc --module-name FioriARKit -- -scheme FioriARKit -destination 'generic/platform=iOS' -sdk iphoneos CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO ONLY_ACTIVE_ARCH=NO > fioriarkit.json
	jazzy --sourcekitten-sourcefile fioriarkit.json --module "FioriARKit" --clean
	rm fioriarkit.json
