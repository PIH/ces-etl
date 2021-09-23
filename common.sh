LOGS=./logs/
  
DATE=$(date -d "yesterday" "+%Y%m%d")

SITES=(
ces-prod
ces-capitan
ces-honduras
ces-laguna
ces-letrero
ces-matazano
ces-plan
ces-reforma
ces-salvador
ces-soledad
)

declare -A HEALTHCHECK_FOR_SITE
HEALTHCHECK_FOR_SITE[ces-prod]=https://hcping.pih-emr.org/ping/943613dd-515c-44ba-af6b-43574eecd272
HEALTHCHECK_FOR_SITE[ces-capitan]=https://hcping.pih-emr.org/ping/442dcafa-0f89-4013-b8ba-1cfc519351f4
HEALTHCHECK_FOR_SITE[ces-honduras]=https://hcping.pih-emr.org/ping/18cc1722-23af-4185-8240-245746f16316
HEALTHCHECK_FOR_SITE[ces-laguna]=https://hcping.pih-emr.org/ping/f13d85c7-6b49-4f1e-a0ac-1649c86703fe
HEALTHCHECK_FOR_SITE[ces-letrero]=https://hcping.pih-emr.org/ping/73892a14-523d-4ca3-82a0-087384e6fb44
HEALTHCHECK_FOR_SITE[ces-matazano]=https://hcping.pih-emr.org/ping/9f615190-0935-43eb-bf35-6b03221ebdaa
HEALTHCHECK_FOR_SITE[ces-plan]=https://hcping.pih-emr.org/ping/24e43535-a721-41ac-a30c-38592d990e0c
HEALTHCHECK_FOR_SITE[ces-plan-alta]=https://hcping.pih-emr.org/ping/47de9b40-3469-429b-b650-6086e339e685
HEALTHCHECK_FOR_SITE[ces-reforma]=https://hcping.pih-emr.org/ping/73f39dff-018c-40ae-88eb-7e735926a779
HEALTHCHECK_FOR_SITE[ces-salvador]=https://hcping.pih-emr.org/ping/38e34dbc-81b6-448f-b5f5-40e92aeb9ebd
HEALTHCHECK_FOR_SITE[ces-soledad]=https://hcping.pih-emr.org/ping/e0997cb7-2d56-4784-913f-bc1f59c670f8
