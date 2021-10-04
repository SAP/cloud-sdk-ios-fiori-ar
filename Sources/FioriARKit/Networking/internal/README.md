# ARService

This is an api generated from a OpenAPI 3.0 spec with [SwagGen](https://github.com/yonaskolb/SwagGen) and a [custom template](https://github.com/MarcoEidinger/SwagGen/tree/sap/Swift-SAPURLSession) to use `SAPFoundation.SAPURLSession` from [SAP BTP SDK for iOS](https://developers.sap.com/topics/sap-btp-sdk-for-ios.html) with no further dependencies.

## Operation

Each operation lives under the `ARService` namespace and within an optional tag: `ARService(.tagName).operationId`. If an operation doesn't have an operationId one will be generated from the path and method.

Each operation has a nested `Request` and a `Response`, as well as a static `service` property

#### Service

This is the struct that contains the static information about an operation including it's id, tag, method, pre-modified path, and authorization requirements. It has a generic `ResponseType` type which maps to the `Response` type.
You shouldn't really need to interact with this service type.

#### Request

Each request is a subclass of `APIRequest` and has an `init` with a body param if it has a body, and a `options` struct for other url and path parameters. There is also a convenience init for passing parameters directly.
The `options` and `body` structs are both mutable so they can be modified before actually sending the request.

#### Response

The response is an enum of all the possible responses the request can return. it also contains getters for the `statusCode`, whether it was `successful`, and the actual decoded optional `success` response. If the operation only has one type of failure type there is also an optional `failure` type.

## Model
Models that are sent and returned from the API are mutable classes. Each model is `Equatable` and `Codable`.

`Required` properties are non optional and non-required are optional

All properties can be passed into the initializer, with `required` properties being mandatory.

If a model has `additionalProperties` it will have a subscript to access these by string

## APIClient
The `APIClient` is used to encode, authorize, send, monitor, and decode the requests. Initialization:

```swift
public init(baseURL: String, sapURLSession: SAPURLSession)
```

### APIClient properties

- `baseURL`: The base url that every request `path` will be appended to
- `sapURLSession`: An `SAPFoundation.SAPURLSession` that can be customized
- `decodingQueue`: The `DispatchQueue` to decode responses on

### Making a request (Combine/Publisher-based)

Combine/Publisher-based API is **recommended**, especially if you have to chain multiple network requests (e.g. load profile images for all users)

To make a request first initialize a [Request](#request) and then pass it to `makeRequest`. The `complete` closure will be called with an `APIResponse`

```swift
func makeRequest<T>(_ request: APIRequest<T>) -> AnyPublisher<APIResponse<T>, Never>
```

Example request (that is not neccessarily in this api):

```swift
private var cancellables = Set<AnyCancellable>()

let getUserRequest = ARService.User.GetUser.Request(id: 123)
let apiClient = APIClient(baseURL: "https://mytrial-dev-userDirectory.cfapps.eu10.hana.ondemand.com/serviceDestination", sapURLSession: OnboardingSessionManager.shared.onboardingSession!.sapURLSession) // note that OnboardingSessionManager belongs to SAPFioriFlows framework from the SAP BTP SDK for iOS

apiClient.makeRequest(getUserRequest)
	.receive(on: DispatchQueue.main)
    .sink { completion in
        print(completion)
    } receiveValue: { apiResponse in
    	switch apiResponse {
        case .result(let apiResponseValue):
        	if let user = apiResponseValue.success {
        		print("GetUser returned user \(user)")
        	} else {
        		print("GetUser returned \(apiResponseValue)")
        	}
        case .error(let apiError):
        	print("GetUser failed with \(apiError)")
    	}
    }
    .store(in: &self.cancellables)
}
```

### Making a request (Callback-based)

To make a request first initialize a [Request](#request) and then pass it to `makeRequest`. The `complete` closure will be called with an `APIResponse`

```swift
func makeRequest<T>(_ request: APIRequest<T>, completionQueue: DispatchQueue = DispatchQueue.main, complete: @escaping (APIResponse<T>) -> Void) -> SAPURLSessionTask?
```

Example request (that is not neccessarily in this api):

```swift
let getUserRequest = ARService.User.GetUser.Request(id: 123)
let apiClient = APIClient(baseURL: "https://mytrial-dev-userDirectory.cfapps.eu10.hana.ondemand.com/serviceDestination", sapURLSession: OnboardingSessionManager.shared.onboardingSession!.sapURLSession) // note that OnboardingSessionManager belongs to SAPFioriFlows framework from the SAP BTP SDK for iOS

apiClient.makeRequest(getUserRequest) { apiResponse in
    switch apiResponse {
        case .result(let apiResponseValue):
        	if let user = apiResponseValue.success {
        		print("GetUser returned user \(user)")
        	} else {
        		print("GetUser returned \(apiResponseValue)")
        	}
        case .error(let apiError):
        	print("GetUser failed with \(apiError)")
    }
}
```

### APIResponse
The `APIResponse` that gets passed to the completion closure contains the following properties:

- `request`: The original request
- `result`: A `Result` type either containing an `APIClientError` or the [Response](#response) of the request
- `urlRequest`: The `URLRequest` used to send the request
- `urlResponse`: The `HTTPURLResponse` that was returned by the request
- `data`: The `Data` returned by the request.

### Encoding and Decoding
Only JSON requests and responses are supported. These are encoded and decoded by `JSONEncoder` and `JSONDecoder` respectively, using Swift's `Codable` apis.
There are some options to control how invalid JSON is handled when decoding and these are available as static properties on `ARService`:

- `safeOptionalDecoding`: Whether to discard any errors when decoding optional properties. Defaults to `true`.
- `safeArrayDecoding`: Whether to remove invalid elements instead of throwing when decoding arrays. Defaults to `true`.

Dates are encoded and decoded differently according to the swagger date format. They use different `DateFormatter`'s that you can set.
- `date-time`
    - `DateTime.dateEncodingFormatter`: defaults to `yyyy-MM-dd'T'HH:mm:ss.Z`
    - `DateTime.dateDecodingFormatters`: an array of date formatters. The first one to decode successfully will be used
- `date`
    - `DateDay.dateFormatter`: defaults to `yyyy-MM-dd`

### APIClientError
This is error enum that `APIResponse.result` may contain:

```swift
public enum APIClientError: Error {
    case unexpectedStatusCode(statusCode: Int, data: Data)
	case encodingError(Error)
    case decodingError(DecodingError)
    case requestEncodingError(String)
    case validationError(String)
    case networkError(Error)
    case unknownError(Error)
}
```

## Models

- **AnnotationAnchor**
- **Card**
- **Marker**
- **ReferenceAnchor**
- **Scene**
- **SupportLanguage**

## Requests

- **ARService.AnnotationAnchor**
	- **DeleteAnnotation**: DELETE `/scene/{sceneid}/annotationanchor/{id}`
	- **GetAnnotation**: GET `/scene/{sceneid}/annotationanchor/{id}`
	- **GetAnnotationAnchorsByScene**: GET `/annotationanchor/findbyscene`
	- **UdpateAnnotation**: PUT `/scene/{sceneid}/annotationanchor/{id}`
- **ARService.File**
	- **DeleteFileById**: DELETE `/file/{fileid}`
	- **GetFileById**: GET `/file/{fileid}`
	- **UpdateFileById**: PUT `/file/{fileid}`
- **ARService.Scene**
	- **AddScene**: POST `/scene`
	- **DeleteScene**: DELETE `/scene/{sceneid}`
	- **GetSceneById**: GET `/scene/{sceneid}`
	- **GetScenesByAliases**: GET `/scene/findbyalias`
	- **GetScenesByIds**: GET `/scene`
	- **UpdateScene**: PATCH `/scene/{sceneid}`
