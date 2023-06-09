# PerfAI Action

PerfAI is an AI-driven Performance Action for APIs & Modern Apps.  It deliver high-performance APIs/apps to enable an improved customer engagement.  It monitor marketing campaigns, and analyze user analytics.  

Deliver High-Performance APIs and achieve 3x engagement and upsell.

## How PerfAI Works

**No Engineering Required** - No code and no data is required. PerfAI automatically learns your API and creates its own data.

**Performance Top 10** - PerfAI creates a custom performance plan for your APIs based on industry's first performance top 10 list. 

**Simplified Scoring** - No complex graphs or CSV files to deal with. Instead get a simplified score for your entire API. 

**Active Performance** - PerfAI is delivered as a GitHub Action. It enables shift-left and continuous performance validation. 

![image](https://github.com/P10-ai/Perf-Actions/assets/134328549/4c7ab821-bcff-40c8-85d8-c2dc97f8b1cc)

## 

# Usage

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
    
```
