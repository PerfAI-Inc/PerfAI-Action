
# PerfAI

PerfAI is an innovative active performance platform that supports a wide range of APIs, including public, private, mobile, and web APIs. By leveraging PerfAI, you can deliver high-performance APIs, resulting in reduced churn, 3x higher user engagement, and increased upsell opportunities..




## How PerfAI Works

PerfAI is built on four fundamental principles:

1. No Engineering Effort Required: PerfAI eliminates the need for coding or data input. It autonomously learns your entire API and generates its own data.

2. Performance Top 10 Coverage: Save valuable time by avoiding the laborious task of creating a performance plan. PerfAI develops a comprehensive and tailored performance plan based on the industry's first performance top-10 list.

3. Simplified Scoring & Reporting: Say goodbye to complex graphs and CSV files. PerfAI provides a simplified score for your entire API, along with a list of underperforming endpoints.

4. Active Performance: Delivered as a GitHub Action, PerfAI facilitates shift-left and continuous performance validation. It actively identifies poorly performing critical paths as your developers write and update code.



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

    licenseKey: 'your-license-key'
    A code or token that allows the user to identify him/herself as a legal customer, and it is optional.
    
    [Terms of Use](https://www.perfai.ai/terms-of-use)
    [Privacy Policy](https://www.perfai.ai/privacy-policy)
    
```

# Output Logs

![image](https://lh5.googleusercontent.com/4WE6geJfYky9qH93P681EqYm9rhYood4r3neQsb2Y1ueu5dlZwWvZyw4WvVEYHwvxY6047C_adcYd5aSJ-HY1nd2FDHwk1j_EJ6uZ1iBNcKd5g_LH6DB5rpC6vLXgoZWfxsWO_CNXXuZlcEdJX7bgKk)


