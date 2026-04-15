  #!/bin/bash

# Check if TOKEN_JIRA is set
if [ -z "$TOKEN_JIRA" ]; then
    echo "❌ Error: TOKEN_JIRA environment variable is not set"
    echo "Please run: export TOKEN_JIRA='your-jira-api-token'"
    exit 1
fi

curl -X POST \
    "https://contaazul.atlassian.net/rest/api/3/issue/CHAMADO-65984/transitions" \
    -H "Content-Type: application/json" \
    -u "gilmar.filho@contaazul.com:$TOKEN_JIRA" \
    -d '{"transition": {"id": "151"}}'