# WIP

Backend service offers a model with file references, e.g.
- `scene.referenceAnchor.data`
- `scene.annotationAnchor[0].card.image`

and for quick & easy **internal** client related APIs the `APIClient` and model imlementations were generated in Swift based on the backend service specification.

However, a different SDK API is recommended to hide internal aspects and provides more conviennce, e.g.
- set technical keys
- ability to resolve cards information with related files in one shot

|SDK Public|SDK Internal|
|---|---|
|`ARCardsNetworkingService`|`APIClient`|
|`ARCardsNetworkingServiceError`|`APIClientError`|
|`CodableCardItem` which implements `CardItemModel` |`Card`|
|???|`Scene` and other sub-types

*Note: names are not yet finalized*
