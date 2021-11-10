build:
	xcodebuild -scheme FioriAR -destination 'generic/platform=iOS' -sdk iphoneos CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO ONLY_ACTIVE_ARCH=NO clean build
jazzy:
	sourcekitten doc --module-name FioriAR -- -scheme FioriAR -destination 'generic/platform=iOS' -sdk iphoneos CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO ONLY_ACTIVE_ARCH=NO > fioriar.json
	jazzy --sourcekitten-sourcefile fioriar.json --module "FioriAR" --clean
	rm fioriar.json
