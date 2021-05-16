# generate overview page
jazzy --sourcekitten-sourcefile ./jazzy/empty.json --clean --readme=./jazzy/Overview_README.md --disable-search --hide-documentation-coverage
# generate ARCards documentation
sourcekitten doc --module-name FioriARKit -- -scheme FioriARKit -sdk iphoneos CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO ONLY_ACTIVE_ARCH=NO > arcards.json
jazzy --sourcekitten-sourcefile arcards.json --output docs/arcards --readme=./jazzy/ARCards_README.md --module "FioriARKit"
