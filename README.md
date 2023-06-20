
# PerfAI

AI-powered Active Performance. Unleash High-performance APIs for 3x User Engagement and Upsell.

PerfAI is an active performance platform that supports a wide range of APIs, including public, private, mobile, and web APIs. By leveraging PerfAI, you can deliver high-performance APIs, resulting in reduced churn, 3x higher user engagement, and increased upsell opportunities.

## How PerfAI Works

PerfAI is built on four fundamental principles:

1. No Code / No Config: PerfAI's innovative approach eliminates the need for coding, configuration, and extensive engineering efforts. It harnesses the power of AI to autonomously learn API flows and generate appropriate request data, enabling efficient and effective active performance for APIs.

2. Performance Top-10 Coverage: PerfAI introduces a groundbreaking concept in API performance with its industry-first Performance Top-10 List. This feature revolutionizes the way API flows are validated, ensuring comprehensive and accurate performance coverage.

3. Simplified Scoring: PerfAI simplifies the process of interpreting and understanding API performance results through its simplified scoring system. With PerfAI, you no longer need to navigate complex graphs or analyze CSV files to assess the performance of your API.

4. Shift-Left & CI/CD: PerfAI brings the concept of Shift-Left to API active performance by seamlessly integrating with popular development tools such as GitHub Actions and CI/CD marketplaces. This integration enables you to incorporate performance early in the development cycle, ensuring that performance issues are identified and addressed proactively.


## Frequently Asked Questions
- [Read here](https://www.perfai.ai/pricing#FAQ)


## Request a Demo
- [Talk to our team](https://www.perfai.ai/demo)
- [Request a Free POC](https://www.perfai.ai/demo)


## Pricing
- [Free Developer license available](https://www.perfai.ai/pricing)
- [Startup friendly pricing](https://www.perfai.ai/pricing)
- [Request Custom quotes](https://www.perfai.ai/pricing)


## Case Studies & Blogs
- [Recent case studies, read here](https://www.perfai.ai/blog)

## Open Source Contributions / Hiring
- If you're interested in solving active performance and AI-driven automation, please email us at opensource@perfai.ai.
- If you're interested in joining us full-time, we are constantly looking for problem solvers. Email us your LinkedIn profile at hiring@perfai.ai.


# Let's get started

See [action.yml](action.yml)

```yaml
steps:
- uses: docker://ghcr.io/perfai-inc/perfai-engine:main
  with:
  
    apiSpecURL: 'https://petstore.swagger.io/v2/swagger.yaml'
    This is a sample URL pointing to the location where the API specification document 
    (e.g., in OpenAPI or Swagger format) can be found.
    
    apiBasePath: 'https://petstore.swagger.io/v2'
    This represents the base path of an API, indicating that all endpoints related to product 
    operations would be appended to this base path.
  
    authUrl: 'https://api.petstore.io/auth/credentials'
    This is an example URL for the authentication service, where users are redirected to 
    log in and obtain authentication credentials.
    
    authBody: '{"login":"your-username","password":"your-password"}'
    This is a sample JSON object representing the body of an authentication request. 
    It contains the username and password of the user attempting to authenticate.

    authHeaders: 'Authorization: Basic <Base64EncodedCredentials>' 
    Sample headers
    Bearer token "Authorization: Bearer <AccessToken>" 
    API Key "Authorization: APIKey <APIKey>"
    HMAC (Hash-based Message Authentication Code) Authentication "Authorization: HMAC <APIKey>:<Signature>"
    JSON Web Token (JWT) Authentication "Authorization: Bearer <JWT>"
    Cookie Header "Cookie: sessionID=abc123; userID=12345"
    Session Header "Session: 1234567890abcdef"
    Auth headers can be included in the HTTP request's Authorization header field to authenticate and authorize the client making the API request. The specific header and authentication method used will depend on the API and authentication mechanism being implemented.

    licenseKey: 'your-license-key'
    A code or token that allows the user to identify him/herself as a legal customer, and it is optional.
   
   
    [Terms of Use](https://www.perfai.ai/terms-of-use)
    [Privacy Policy](https://www.perfai.ai/privacy-policy)
    
```

# Output Logs

![image](https://lh5.googleusercontent.com/4WE6geJfYky9qH93P681EqYm9rhYood4r3neQsb2Y1ueu5dlZwWvZyw4WvVEYHwvxY6047C_adcYd5aSJ-HY1nd2FDHwk1j_EJ6uZ1iBNcKd5g_LH6DB5rpC6vLXgoZWfxsWO_CNXXuZlcEdJX7bgKk)


