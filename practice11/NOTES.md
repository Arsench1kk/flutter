# Practice 11 notes

## JSONPlaceholder wire format

The server returned `Content-Type: application/json; charset=utf-8` for the following requests. The create probe used sample data and submitted a JSON body with `Content-Type: application/json`.

| Request | Status | Observed body |
| --- | --- | --- |
| GET `/users` | 200 | JSON array with 10 users |
| GET `/users/1` | 200 | A single JSON object for Leanne Graham |
| GET `/users/999` | 404 | `{}` |
| GET `/users?id=3` | 200 | A one-element array, with Clementine Bauch |
| POST `/users` | 201 | Echoed the submitted name, username, and email, and added `"id": 11` |

Use `Uri.https(host, '/users', {'id': '3'})` for query parameters. `getById` uses the resource path `/users/3` and expects an object.

### User

| Field | JSON type | Dart type | Nullable? |
| --- | --- | --- | --- |
| `id` | integer | `int` | No |
| `name` | string | `String` | No |
| `username` | string | `String` | No |
| `email` | string | `String` | No |
| `address` | object | `Address` | No |
| `phone` | string | `String` | No |
| `website` | string | `String?` | Yes in the model |
| `company` | object | named Dart record and a separate `String` for `bs` | No |

All ten observed users had non-null fields. The model accepts an absent or null website. The raw phone string is retained, and `phoneDigits` removes everything except digits and `+`.

### Address

| Field | JSON type | Dart type | Nullable? |
| --- | --- | --- | --- |
| `street` | string | `String` | No |
| `suite` | string | `String` | No |
| `city` | string | `String` | No |
| `zipcode` | string | `String` | No |
| `geo` | object | `Geo` | No |
| `geo.lat` | string | `double` | No |
| `geo.lng` | string | `double` | No |

`address.geo` is nested two levels deep. `double.parse` converts both coordinate strings. Serialization writes them back as strings.

### Company

| Field | JSON type | Dart type | Nullable? |
| --- | --- | --- | --- |
| `name` | string | `String` | No |
| `catchPhrase` | string | `String` | No |
| `bs` | string | `String` | No |

The named `company` record carries `name` and `catchPhrase`. The additional observed `bs` value is preserved in `companyBusiness` so the JSON round trip keeps all server fields.

## Repository and network observations

The macOS Flutter app loaded all ten users. A temporary debug probe running inside the app called the repository directly. It verified the full JSON round trip for the first user, returned `NotFoundException` for `getById(999)`, and received ID 11 from `create`. The probe was removed after verification.

| Scenario | Simulation | Measured in app | Result |
| --- | --- | --- | --- |
| Immediate connection failure | Local HTTPS port with no listener | 9 ms | `NoConnectionException` |
| Connection with no response | Local HTTPS listener accepted GET `/users` and withheld the response | 10,024 ms | `NoConnectionException` |

Both errors map to the Offline view with Retry. These timings are controlled macOS reproductions. Airplane mode and Wi-Fi with no internet were not tested on a phone or emulator.

- [Successful request](screenshot_200.png) shows HTTP 200 with the response body expanded.
- [No response](screenshot_timeout.png) shows the GET with no HTTP status and the corresponding socket closing in 10 s. The second capture run measured 10,007 ms in Dart. DevTools leaves the HTTP row marked Pending after the local cancellation.
