#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0
# SPDX-FileCopyrightText: 2025 The Linux Foundation

set -euo pipefail

output_file="README.md"
graph_out="graph.png"
api_endpoint="https://api.github.com/graphql"
email="askb23@gmail.com"
linkedin="abelur"
twitter="askb23"
keybase="askb"

pop_repos_q='
query {
  viewer {
    repositories(
        first: 5,
        isFork: false,
        orderBy: {field: STARGAZERS, direction: DESC},
        privacy: PUBLIC
    ) {
      nodes {
        name
        url
        stargazerCount
        description
      }
    }
  }
}
'

langs_q='
query {
  viewer {
    topRepositories(first: 100, orderBy: {field: STARGAZERS, direction: ASC}) {
      nodes {
        languages(first: 2) {
          nodes {
            name
          }
        }
      }
    }
  }
}
'

starred_q='
query {
  viewer {
    starredRepositories(
        first: 5,
        orderBy: {field: STARRED_AT, direction: DESC}
    ) {
      nodes {
        name
        url
        owner {
          login
        }
        description
      }
    }
  }
}
'

load_dotenv() {
    local dotenv=./.env

    if [ -e "$dotenv" ]; then
        # shellcheck source=/dev/null
        . "$dotenv"
        echo ".env loaded"
    fi

    # Check if ACCESS_TOKEN is set (from env or .env)
    if [ -z "${ACCESS_TOKEN:-}" ]; then
        echo "ERROR: ACCESS_TOKEN not set" >&2
        exit 1
    fi
}

perform_request() {
    local q=$1
    local filter=$2
    local processed
    processed=$(echo "$q" | perl -pe 's/\n/\\n/g' | perl -pe 's/"/\\"/g')

    local req="{\"query\": \"$processed\"}"

    local result
    result=$(curl -s -H "Authorization: bearer $ACCESS_TOKEN" -X POST \
        -d "$req" "$api_endpoint")

    sleep 0.1
    echo "$result" | jq -c -r "$filter"
}

pop_repos() {
    local data
    data=$(perform_request "$pop_repos_q" '.data.viewer.repositories.nodes[]')

    local result=""
    for obj in $data; do
        local name url desc stars
        name=$(printf '%s' "$obj" | jq -r '.name')
        url=$(printf '%s' "$obj" | jq -r '.url')
        desc=$(printf '%s' "$obj" | jq -r '.description // "No description"')
        stars=$(printf '%s' "$obj" | jq -r '.stargazerCount')

        result+="| [$name]($url) | $desc | ⭐ $stars |"$'\n'
    done

    echo "$result"
}

languages() {
    local data
    data=$(perform_request "$langs_q" \
        '.data.viewer.topRepositories.nodes[].languages.nodes[].name')
    data=$(echo "$data" | tr -d '[:blank:]' | sort | uniq -c | sort -nr)
    data=$(echo "$data" | tr -d '[:digit:][:blank:]')
    data=$(echo "$data" | perl -pe 's/\n/ • /g' | sed 's/ • $//')

    echo "$data"
}

starred() {
    local data
    data=$(perform_request "$starred_q" '.data.viewer.starredRepositories.nodes[]')

    local result=""
    for obj in $data; do
        local name url owner desc
        name=$(echo "$obj" | jq -r '.name')
        url=$(echo "$obj" | jq -r '.url')
        owner=$(echo "$obj" | jq -r '.owner.login')
        desc=$(echo "$obj" | jq -r '.description // "No description"' | cut -c1-60)

        result+="- [$owner/$name]($url) - $desc"$'\n'
    done

    echo "$result"
}

plot_contributions() {
    if command -v graph &> /dev/null; then
        graph contributions.csv -f '' --fontsize 7 --width 3 --marker '' \
            --style='-,-' --xscale 5 -o "$1"
    fi
}

load_dotenv

langs=$(languages)

plot_contributions "$graph_out"

cat > "$output_file" << EOF
<div align="center">

# 👋 Hey, I'm Anil (askb)

**Senior IT Engineer | Release Engineering • Infrastructure Automation • AI-Assisted Development**

[![LinkedIn](https://img.shields.io/badge/LinkedIn-Connect-0077B5?style=flat&logo=linkedin)](https://linkedin.com/in/${linkedin})
[![Twitter](https://img.shields.io/badge/Twitter-Follow-1DA1F2?style=flat&logo=twitter)](https://twitter.com/${twitter})
[![Keybase](https://img.shields.io/badge/Keybase-askb-33A0FF?style=flat&logo=keybase)](https://keybase.io/${keybase})
[![Email](https://img.shields.io/badge/Email-${email}-EA4335?style=flat&logo=gmail)](mailto:${email})

</div>

---

## 🚀 About Me

Senior IT Engineer at **The Linux Foundation**, specializing in release engineering, cloud infrastructure automation, and developer tooling. I architect and maintain CI/CD pipelines that power some of the largest open source projects, focusing on scalability, reliability, and intelligent automation.

Currently building **AI-powered agentic workflows** across DevOps and home automation—from GitHub Copilot agentic CI/CD pipelines to smart home systems with AI health coaching, solar energy monitoring, and Garmin fitness tracking. Experimenting with LLM-assisted development to make infrastructure smarter and more autonomous.

When I'm not optimizing build systems or tinkering with smart home automations, you'll find me on two wheels (🚴 bicycle or 🏍️ motorcycle) or exploring trails on foot 🥾.

### 🔧 Core Competencies

- **Infrastructure Engineering** - Cloud platforms, container orchestration, distributed systems
- **Release & Deployment Automation** - CI/CD pipelines, automated testing, deployment strategies
- **Developer Experience** - CLI tools, APIs, workflow optimization, productivity automation
- **AI-Assisted Development** - LLM integration, agentic workflows, intelligent automation
- **Smart Home & IoT** - Home Assistant, energy monitoring, AI health coaching, Garmin fitness
- **Infrastructure as Code** - Declarative automation, configuration management, immutable infrastructure

---

## 🌟 Featured Projects

### 🔨 [OpenDaylight Release Engineering](https://github.com/opendaylight/releng-builder)
Complete CI/CD infrastructure for OpenDaylight—orchestrating automated builds, testing, and deployment across 60+ repositories.

**Impact:** Supports 100+ developers | 500K+ builds executed | 99.8% uptime

### 🐳 [Packer Build Action](https://github.com/askb/packer-build-action)
GitHub Action for automated cloud image building with secure bastion integration. Enables ephemeral infrastructure provisioning in CI pipelines.

**Tech:** GitHub Actions • Cloud Automation • Security

### 🛠️ [LF Release Engineering Actions](https://github.com/lfit/releng-reusable-workflows)
Suite of 40+ reusable GitHub Actions and workflows for the Linux Foundation ecosystem. Production-grade automation for multi-cloud deployments.

**Used by:** 50+ LF projects | 1000+ workflow runs/month

### ⚡ [LFTools](https://github.com/lfit/releng-lftools)
Python CLI tool for Linux Foundation infrastructure management—cloud resource orchestration, build automation, and developer utilities.

**Tech:** Python • CLI Development • API Integration

### 🤖 [AI Experiments](https://github.com/askb/ai-n8domata)
Exploring AI-assisted automation, LLM integration workflows, and intelligent tooling. Experimenting with n8n, vector databases, and AI agents.

**Status:** Active experimentation | Learning in public

### 🏠 [Smart Home Configuration](https://github.com/askb/askb-ha-config)
Home Assistant OS configuration featuring **GitHub Copilot agentic workflows**—automated daily health reports via GitHub Issues, AI-powered PR reviews for config validation, energy/solar monitoring (Fronius inverter, Wattpilot EV charger), multi-camera security with Frigate + Coral TPU object detection, and multi-user Garmin health coaching pipelines.

**Tech:** Home Assistant • Agentic Workflows • Frigate • Solar/EV Monitoring • Spec-Driven Development

### 💪 [Garmin Fitness Coach Addon](https://github.com/askb/ha-garmin-fitness-coach-addon)
Home Assistant addon for Garmin Connect data sync with AI-powered coaching dashboard. Multi-user health tracking with InfluxDB time-series storage and Grafana visualizations at \`grafana.askb.dev\`.

**Tech:** Python • Home Assistant Addon • InfluxDB • Grafana • AI Coaching

### 🏋️ [Garmin Fitness Coach App](https://github.com/askb/ha-garmin-fitness-coach-app)
AI-powered sport scientist web app—transforms Garmin health data into evidence-based coaching with personalized workout recommendations, diabetes tracking, and fitness analytics.

**Tech:** Next.js • TypeScript • tRPC • Drizzle ORM • AI/ML

---

## 💻 Tech Stack

<div align="center">

### Languages & Scripting
![Shell](https://img.shields.io/badge/Shell-4EAA25?style=for-the-badge&logo=gnu-bash&logoColor=white)
![Python](https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white)
![TypeScript](https://img.shields.io/badge/TypeScript-3178C6?style=for-the-badge&logo=typescript&logoColor=white)
![Go](https://img.shields.io/badge/Go-00ADD8?style=for-the-badge&logo=go&logoColor=white)
![JavaScript](https://img.shields.io/badge/JavaScript-F7DF1E?style=for-the-badge&logo=javascript&logoColor=black)

### Infrastructure & Cloud
![Linux](https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black)
![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![Kubernetes](https://img.shields.io/badge/Kubernetes-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)
![OpenStack](https://img.shields.io/badge/OpenStack-ED1944?style=for-the-badge&logo=openstack&logoColor=white)
![Packer](https://img.shields.io/badge/Packer-02A8EF?style=for-the-badge&logo=packer&logoColor=white)
![Ansible](https://img.shields.io/badge/Ansible-EE0000?style=for-the-badge&logo=ansible&logoColor=white)

### CI/CD & Automation
![GitHub Actions](https://img.shields.io/badge/GitHub_Actions-2088FF?style=for-the-badge&logo=github-actions&logoColor=white)
![Jenkins](https://img.shields.io/badge/Jenkins-D24939?style=for-the-badge&logo=jenkins&logoColor=white)
![Terraform](https://img.shields.io/badge/Terraform-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)

### Smart Home & IoT
![Home Assistant](https://img.shields.io/badge/Home_Assistant-41BDF5?style=for-the-badge&logo=home-assistant&logoColor=white)
![Grafana](https://img.shields.io/badge/Grafana-F46800?style=for-the-badge&logo=grafana&logoColor=white)
![InfluxDB](https://img.shields.io/badge/InfluxDB-22ADF6?style=for-the-badge&logo=influxdb&logoColor=white)
![Raspberry Pi](https://img.shields.io/badge/Raspberry_Pi-A22846?style=for-the-badge&logo=raspberry-pi&logoColor=white)

</div>

---

## 📊 GitHub Stats

<div align="center">

### Daily Contribution Activity
![contributions graph]($graph_out)

### Overall Metrics
![Metrics](https://github.com/askb/askb/blob/main/github-metrics.svg)

</div>

---

## 🌏 Open Source Contributions

Contributing across multiple Linux Foundation projects and communities:

- **OpenDaylight** - Release Engineering Lead
- **Linux Foundation IT** - Infrastructure Automation
- **OPNFV** - CI/CD Pipeline Development
- **FD.io** - Build System Maintenance

### Languages by Contribution Volume
$langs

---

## 🤝 Let's Connect

I'm always interested in discussing:
- 🔧 Release engineering and deployment strategies
- 🐧 Infrastructure optimization and cloud architecture
- 🚀 CI/CD pipeline design and best practices
- 🤖 LLM integration and AI-assisted agentic workflows
- 🏠 Smart home automation, energy monitoring, and IoT
- 💪 Health tracking, Garmin fitness, and AI coaching
- 🌐 Open source community building and collaboration
- 🚴 Trail recommendations (tech conferences or bike trails!)

### How to Reach Me
- **Email:** [$email](mailto:$email)
- **Twitter/X:** [@${twitter}](https://twitter.com/${twitter})
- **Keybase:** [${keybase}](https://keybase.io/${keybase})
- **LinkedIn:** [${linkedin}](https://linkedin.com/in/${linkedin})
- **Telegram:** *Available on request*

---

## ☕ Support My Work

If my open source contributions have helped you, consider buying me a coffee! Your support helps me dedicate more time to building tools that benefit the community.

<div align="center">

[![Ko-fi](https://img.shields.io/badge/Ko--fi-Support-FF5E5B?style=for-the-badge&logo=ko-fi&logoColor=white)](https://ko-fi.com/askb23)
[![GitHub Sponsors](https://img.shields.io/badge/GitHub_Sponsors-Sponsor-EA4AAA?style=for-the-badge&logo=github-sponsors&logoColor=white)](https://github.com/sponsors/askb)

</div>

---

<div align="center">

### 💡 "Automating infrastructure by day, exploring trails by weekend"

![Profile Views](https://komarev.com/ghpvc/?username=askb&color=brightgreen&style=flat-square&label=Profile+Views)

*Last updated: Auto-generated via GitHub Actions • $(date -u +"%Y-%m-%d %H:%M UTC")*

</div>
EOF

echo "✅ README generated successfully!"
