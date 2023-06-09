# Perf-Action

PerfAI is an AI-driven Performance Action for APIs & Modern Apps.  It deliver high-performance APIs/apps to enable an improved customer engagement.  It monitor marketing campaigns, and analyze user analytics.  

Deliver High-Performance APIs and achieve 3x engagement and upsell.

## How PerfAI Works

**No Engineering Required** - No code and no data is required. PerfAI automatically learns your API and creates its own data.

**Performance Top 10** - PerfAI creates a custom performance plan for your APIs based on industry's first performance top 10 list. 

**Simplified Scoring** - No complex graphs or CSV files to deal with. Instead get a simplified score for your entire API. 

**Active Performance** - PerfAI is delivered as a GitHub Action. It enables shift-left and continuous performance validation. 

![image](https://github.com/P10-ai/Perf-Actions/assets/134328549/4c7ab821-bcff-40c8-85d8-c2dc97f8b1cc)


# Usage

See [action.yml](action.yml)

```yaml
steps:
- uses: docker://ghcr.io/p10-ai/perf-engine:main
  with:
    apiSpecURL: 'https://petstore.swagger.io/v2/swagger.yaml'
    apiBasePath: 'https://petstore.swagger.io/v2'
    authUrl: 'https://api.petstore.io/auth/credentials'
    authBody: '{"login":"your-username","password":"your-password"}'
```



See [action.yml](https://github.com/P10-ai/Perf-Actions/blob/main/action.yml)
