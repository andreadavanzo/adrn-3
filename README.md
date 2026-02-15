# Audax Development Research Notes - 3 (ADRN-3)
## Quantifying Green IT: Architectural Complexity and Runtime Power Dynamics for Web Frameworks

**Author:** Andrea Davanzo

**ORCID:** [0009-0000-5170-1737](https://orcid.org/0009-0000-5170-1737)

**License:** MPL-2.0

## Overview

This repository contains the experimental datasets, telemetry logs, plotting utilities,
and automation scripts used in **Audax Development Research Notes – 3 (ADRN-3)**.

The study investigates how **software architectural complexity influences electrical power consumption** across multiple programming language web frameworks.
Building on the **Accidental Complexity Score (ACS)** introduced in ADRN-1 and the energy measurements of ADRN-2, this work extends the analysis to PHP, Ruby, Python, and JavaScript web frameworks.

Electrical power draw is measured using **Intel Running Average Power Limit (RAPL)** telemetry under controlled hardware conditions.

ADRN-3 introduces two energy-centric metrics:

* **Software Median Power Overhead (SMPO)** – Steady-state architectural overhead
* **Software Complexity Power Jitter (SCPJ)** – Runtime variability and burst dynamics

---

## Repository Structure

```
framework/        Minimal applications for each framework
    baseline/     Hardware baseline reference workload
    f3/           Fat-Free Framework (PHP)
    laravel/      Laravel (PHP)
    sinatra/      Sinatra (Ruby)
    rail/         Ruby on Rails (Ruby)
    flask/        Flask (Python)
    django/       Django (Python)
    fastify/      Fastify (Node.js)
    express/      Express (Node.js)

log/              Raw telemetry and event datasets
plot/             Plotting utilities and generated charts
    plot_results.py         Utility for plotting the results
    charts/
    venv/

script/           Supporting utilities
    test-framework.sh       Main test script
    stats.php               Utility for print stats
```


