<?php

// Observability (ADR-043): Prometheus metrics for the API and readiness
// checks (the Sentry hook is the `sentry` log channel). No secrets in the
// repo: the metrics token comes from the environment (Kubernetes secret).
return [
    // Bearer token for GET /api/v1/internal/metrics; empty disables it (404).
    'metrics_token' => (string) env('METRICS_TOKEN', ''),

    // Dependencies GET /readyz checks (comma separated: database, redis).
    'readiness_checks' => array_values(array_filter(array_map('trim', explode(',', (string) env('READINESS_CHECKS', 'database,redis'))))),
];
